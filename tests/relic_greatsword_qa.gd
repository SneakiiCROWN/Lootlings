extends SceneTree

const Fit = preload("res://weapon_fit_catalog.gd")
const Items = preload("res://item_catalog.gd")
var game
var failures: Array[String] = []
var observations: Array = []
var native := false

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func check(ok: bool, detail: String) -> void:
	if not ok:
		failures.append(detail)
		push_error("RELIC GREATSWORD QA: " + detail)

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.app_lifecycle.platform_notifications_enabled = false
	game.profile.avatar_mode = "lootling"
	game.profile.current_lootling_id = "relic_beast"
	game.inventory.reset_to_starter()
	game.meta_power = 0
	game.gold_upgrades = {"bedroll":0,"whetstone":0,"pouch":0}
	game.campaign_id = "act_i"
	game.rng.seed = 87312
	game.loot_system.rng.seed = 91322
	game.start_run()
	game.player_facing = 1; game.forced_facing_test=1
	game.player_x = game.target_player_x()
	game.wave_banner_timer = 0.0
	game.enemy_entry_anim = 0.0
	game.run_time = 1.0
	game.presentation_director.active_toast.clear()
	game.presentation_director.toast_queue.clear()
	game.presentation_director.toast_panel.visible = false
	var rng_state: int = game.rng.state
	var loot_state: int = game.loot_system.rng.state
	var frames := [
		{"label":"idle","anim":0.0,"clock":0.8,"hurt":false,"reward":0.0,"move":false},
		{"label":"movement","anim":0.0,"clock":0.8,"hurt":false,"reward":0.0,"move":true},
		{"label":"anticipation","anim":0.0,"clock":0.025,"hurt":false,"reward":0.0,"move":false},
		{"label":"strike","anim":0.22,"clock":0.8,"hurt":false,"reward":0.0,"move":false},
		{"label":"impact","anim":0.18,"clock":0.8,"hurt":false,"reward":0.0,"move":false},
		{"label":"recovery","anim":0.10,"clock":0.8,"hurt":false,"reward":0.0,"move":false},
		{"label":"settle","anim":0.025,"clock":0.8,"hurt":false,"reward":0.0,"move":false},
		{"label":"hurt","anim":0.0,"clock":0.8,"hurt":true,"reward":0.0,"move":false},
		{"label":"reward","anim":0.0,"clock":0.8,"hurt":false,"reward":0.225,"move":false}]
	var ready_path := ""
	var release_path := ""
	for frame in frames:
		game.attack_anim = frame.anim
		game.attack_clock = frame.clock
		game.player_flash = 0.16 if frame.hurt else 0.0
		game.player_reward_flash = frame.reward
		game.player_x = game.PLAYER_HOME_X if frame.move else game.target_player_x()
		var pose := Fit.sample(game,frame.hurt)
		check_pose(pose,frame.label)
		if frame.label == "idle": ready_path = pose.texture.resource_path
		if frame.label == "strike": release_path = pose.texture.resource_path
		observations.append({"label":frame.label,"phase":pose.action.phase,"texture":pose.texture.resource_path,"support":pose.support_status,"root":str(pose.root),"primary":str(pose.primary_hand),"secondary":str(pose.secondary_hand),"grip_error":pose.secondary_grip.distance_to(pose.secondary_hand)})
		if native: await capture(frame.label)
	check(ready_path != release_path,"ready and strike use distinct authored bodies")
	check(game.rng.state == rng_state and game.loot_system.rng.state == loot_state,"pose sampling/rendering preserves gameplay RNG streams")
	game.attack_anim = 0.0
	game.player_flash = 0.0
	game.player_reward_flash = 0.0
	game.player_facing = -1; game.forced_facing_test=-1
	var left := Fit.sample(game)
	check(left.support_status != "authored_two_hand" and left.opposite_art_required,"right-only authored set uses honest left fallback")
	game.player_facing = 1; game.forced_facing_test=1
	for weapon in ["greataxe","maul"]:
		game.inventory.equip(Items.create_item("scrap_axe" if weapon == "greataxe" else "mimic_mallet","COMMON",456))
		var other := Fit.sample(game)
		check(other.weapon_type == weapon,"fallback fixture equips actual " + weapon)
		check(other.texture.resource_path != ready_path and other.texture.resource_path != release_path,"focused pose does not leak to " + weapon)
	game.inventory.reset_to_starter()
	game.player_x = game.target_player_x()
	game.enemy_hp = 10000.0
	game.enemy_max_hp = 10000.0
	game.attack_anim = 0.0
	var hp: float = game.enemy_hp
	game.perform_player_attack(false)
	check(game.enemy_hp < hp and game.attack_projectiles.is_empty(),"real greatsword hit still deals immediate melee damage")
	# Step the real presentation clock after the real attack; preserve contact
	# throughout transition boundaries rather than checking endpoint art only.
	for step in range(15):
		game.update_effects(0.02)
		check_pose(Fit.sample(game,game.player_flash > 0.0),"live_step_%d" % step)
		if native and step in [0,4,8,14]: await capture("live_step_%d" % step)
	game.attack_anim = 0.0
	game.attack_clock = 0.16
	game.enemy_attack_clock = 99.0
	game.player_reward_flash = 0.0
	var auto_before: int = game.attack_sequence
	var auto_phases: Array[String] = []
	for step in range(23):
		game._process(0.02)
		var live := Fit.sample(game)
		check_pose(live,"real_process_%d" % step)
		if str(live.action.phase) not in auto_phases: auto_phases.append(str(live.action.phase))
		if native and step in [0,6,8,12,17,22]: await capture("real_process_%d" % step)
	check(game.attack_sequence == auto_before + 1,"actual game process produces one clock-driven auto attack")
	for phase in ["ANTICIPATE","ATTACK","IMPACT","RECOVER","SETTLE","IDLE"]:
		check(phase in auto_phases,"actual game process visibly traverses " + phase)
	print("RELIC_GREATSWORD_REAL_PROCESS_PHASES " + JSON.stringify(auto_phases))
	print("RELIC_GREATSWORD_OBSERVATIONS " + JSON.stringify(observations))
	print("RELIC GREATSWORD QA %s: nine visible states, source-pixel hand/shaft contacts, focused weapon/facing fallback, RNG isolation, immediate melee and real effect-clock transitions" % ("PASSED" if failures.is_empty() else "FAILED"))
	game.free()
	quit(0 if failures.is_empty() else 1)

func check_pose(pose: Dictionary,label: String) -> void:
	check(pose.actor_id == "relic_beast" and pose.weapon_type == "greatsword",label + " default actor/starter weapon")
	check(pose.support_status == "authored_two_hand",label + " authored two-hand support")
	check(pose.secondary_grip.distance_to(pose.secondary_hand) < 0.01,label + " support hand shaft alignment")
	check(pose.root.determinant() > 0.0,label + " unmirrored right anatomy")
	var image := Image.load_from_file(ProjectSettings.globalize_path(pose.texture.resource_path))
	check(image.get_size() == Vector2i(1254,1254) and image.get_format() == Image.FORMAT_RGBA8,label + " original authored source canvas RGBA")
	check(pose.texture.get_size() == Vector2(768,768),label + " bounded imported runtime texture")
	var body_rect: Rect2 = pose.body_rect
	for anchor in [pose.primary_hand,pose.secondary_hand]:
		var normalized: Vector2 = (Vector2(anchor)-body_rect.position)/body_rect.size
		var pixel := Vector2i(normalized*Vector2(image.get_size()))
		check(Rect2i(Vector2i.ZERO,image.get_size()).has_point(pixel),label + " body anchor in source bounds")
		if Rect2i(Vector2i.ZERO,image.get_size()).has_point(pixel): check(image.get_pixelv(pixel).a > 0.5,label + " body anchor touches opaque authored anatomy")
	if pose.geometry.has("held_path"):
		var held := Image.load_from_file(ProjectSettings.globalize_path(pose.geometry.held_path))
		for grip in [pose.geometry.grip,pose.geometry.secondary_grip]:
			var pixel := Vector2i(Vector2(grip)*Vector2(held.get_size()))
			check(held.get_pixelv(pixel).a > 0.5,label + " grip touches opaque weapon handle")
	else: check(false,label + " registered held weapon source")

func capture(label: String) -> void:
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image.save_png("res://.godot_test_data/relic_greatsword_%s.png" % label) == OK,label + " native capture")
