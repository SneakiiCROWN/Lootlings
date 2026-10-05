extends SceneTree
# Development-only matrix/view; never attached to the shipping scene.
const Fit = preload("res://weapon_fit_catalog.gd")
const Wanderers = preload("res://wanderer_catalog.gd")
const Lootlings = preload("res://lootling_catalog.gd")
const Weapons = preload("res://weapon_catalog.gd")
const Items = preload("res://item_catalog.gd")
const EvolutionQA = preload("res://tests/evolution_qa.gd")
var game
var actors: Array = []
var actor_index := 0
var weapon_index := 0
var label: Label
var interactive := false
var initialized := false

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	if not OS.is_debug_build():
		quit(0)
		return
	call_deferred("run_qa")

func select_actor(id: String) -> void:
	if Wanderers.PRESETS.has(id):
		game.profile.avatar_mode = "wanderer"
		game.profile.wanderer = Wanderers.create_default()
		game.profile.wanderer.preset_id = id
	else:
		game.profile.avatar_mode = "lootling"
		game.profile.current_lootling_id = id

func prepare(id: String, weapon: String) -> void:
	select_actor(id)
	game.inventory.reset_to_starter()
	game.inventory.equip(Items.create_item(EvolutionQA.base_id(weapon),"COMMON",81))
	game.start_run()
	game.set_process(false)
	game.player_x = game.target_player_x()
	game.wave_banner_timer = 0
	game.special_intro_timer = 0
	game.presentation_director.toast_panel.visible = false
	game.attack_anim = 0
	game.attack_clock = game.current_attack_interval()
	game.run_time = 0
	game.queue_redraw()

func run_qa() -> void:
	actors.append_array(Wanderers.selectable_ids())
	actors.append_array(Lootlings.selectable_ids())
	assert(actors.size() == 12 and Weapons.live_ids().size() == 12)
	assert(Fit.HUMANOID_PROFILES.size() == 6 and Fit.CREATURE_PROFILES.size() == 7)
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var native := "--visual" in OS.get_cmdline_user_args()
	interactive = "--interactive" in OS.get_cmdline_user_args()
	label = Label.new()
	label.position = Vector2(12,566)
	label.size = Vector2(456,100)
	label.add_theme_font_size_override("font_size",14)
	root.add_child(label)
	var checks := 0
	var pending_by_facing := {"right":0,"left":0}
	var technical_by_facing := {"right":0,"left":0}
	var production_matrix: Array = []
	for id in actors:
		var sheet: Image
		if native: sheet = Image.create(1280,825,false,Image.FORMAT_RGBA8)
		var sling_sheet := Image.create(1440,854,false,Image.FORMAT_RGBA8) if native else null
		var index := 0
		for weapon in Weapons.live_ids():
			prepare(id,weapon)
			var rng: int = game.rng.state
			var loot_rng: int = game.loot_system.rng.state
			var damage: float = game.base_damage
			var interval: float = game.current_attack_interval()
			for facing in [1,-1]:
				game.player_facing = facing; game.forced_facing_test=facing
				for phase in [0.0,.1,.22]:
					game.attack_clock = .02 if phase == 0.0 else interval
					game.attack_anim = phase
					var pose := Fit.sample(game)
					var transform: Transform2D = pose.root*Transform2D(pose.weapon_rotation,pose.weapon_scale,0,pose.hand)
					var grip: Vector2 = pose.weapon_rect.position+Vector2(pose.geometry.grip)*pose.weapon_rect.size
					assert((transform*grip).distance_to(pose.root*pose.hand) < .001)
					var socket: Vector2 = pose.weapon_rect.position+Vector2(pose.geometry.socket)*pose.weapon_rect.size
					assert((transform*socket).distance_to(pose.projectile) < .001)
					assert(pose.secondary_hand is Vector2)
					assert(pose.texture != null)
					assert(pose.weapon_rect.size.x < 150 and pose.weapon_rect.size.y < 180)
					assert(game.rng.state == rng and game.loot_system.rng.state == loot_rng)
					assert(game.base_damage == damage and game.current_attack_interval() == interval)
					checks += 1
					production_matrix.append({"actor":id,"body_profile":pose.body_profile,"weapon":weapon,
						"stance":pose.stance,"facing":facing,"attack_anim":phase,"wardrobe":pose.wardrobe,
						"support_status":pose.support_status,"authored_facing":pose.authored_facing,
						"opposite_art_required":pose.opposite_art_required,"sprite_rig":pose.get("sprite_rig",false)})
					if phase == 0.0:
						var side: String="left" if facing<0 else "right"
						if pose.support_status in ["authored_pose_required","rigged_two_hand","rigged_paired"]: pending_by_facing[side]+=1
						if pose.support_status=="authored_pose_required": technical_by_facing[side]+=1
			game.player_facing = 1; game.forced_facing_test=1
			game.attack_anim = 0
			game.attack_clock = interval
			var pose := Fit.sample(game)
			label.text = "%s / %s\n%s · %s\n%s" % [id,weapon,pose.body_profile,pose.stance,pose.support_status]
			if native:
				game.queue_redraw()
				await create_timer(.05).timeout
				await RenderingServer.frame_post_draw
				var capture := root.get_texture().get_image()
				assert(capture.get_size() == Vector2i(480,854))
				capture.save_png("res://.godot_test_data/fit_%s_%s.png" % [id,weapon])
				if weapon == "sling": sling_sheet.blit_rect(capture,Rect2i(0,0,480,854),Vector2i.ZERO)
				sheet.blit_rect(capture,Rect2i(130,290,320,275),Vector2i((index%4)*320,(index/4)*275))
			game.perform_player_attack(false)
			if game.current_weapon_family() in ["RANGER","MAGE"]:
				assert(not game.attack_projectiles.is_empty())
				assert(Vector2(game.attack_projectiles[0].start).distance_to(Fit.projectile_origin(game)) < .001)
			if weapon == "sling":
				var held: Texture2D = Weapons.presentation_texture("sling","held",load("res://art/sprites/weapons/ranger_bow.png"))
				assert(held.resource_path == "res://art/sprites/weapons/sling_held.png")
				assert(held.get_image().get_pixelv(Vector2i(Fit.GEOMETRY.sling.grip*512)).a > .5)
				assert(Weapons.presentation_texture("sling","inventory",held).get_size() == Vector2(256,256))
				if id == "mosskin":
					var socket: Vector2 = Fit.sample(game).projectile
					# Compare to the live rig grip, not the retired portrait socket.
					var current_pose: Dictionary=Fit.sample(game)
					assert(socket.x < Vector2(current_pose.weapon_origin).x - 30.0)
				var hp: float = game.enemy_hp
				game.update_attack_projectiles(float(game.attack_projectiles[0].max_life)*.35)
				assert(game.enemy_hp == hp and game.attack_projectiles.size() == 1)
			if native and weapon in ["maul","crossbow","bow","staff","sling"]:
				for facing in [1,-1]:
					game.player_facing = facing; game.forced_facing_test=facing
					game.attack_anim = .22
					# Facing-preview is not a new leftward combat mode. Do not
					# retain a rightward projectile fired before changing facing.
					if facing == -1: game.attack_projectiles.clear()
					game.queue_redraw()
					await create_timer(.05).timeout
					await RenderingServer.frame_post_draw
					var release_image := root.get_texture().get_image()
					release_image.save_png("res://.godot_test_data/fit_release_%s_%s_%d.png" % [id,weapon,facing])
					if weapon == "sling": sling_sheet.blit_rect(release_image,Rect2i(0,0,480,854),Vector2i(480 if facing > 0 else 960,0))
			index += 1
		if native: sheet.save_png("res://.godot_test_data/fit_sheet_%s.png" % id)
		if native: sling_sheet.save_png("res://.godot_test_data/fit_sling_%s_sheet.png" % id)
	assert(not Fit.register_stance("invalid","bow",{}))
	# Exercise the genuine two-anchor solver with a synthetic test fixture ONLY.
	prepare("vault_runner","greatsword")
	var neutral := Fit.sample(game)
	var span: Vector2 = (Fit.STANCES.greatsword.secondary_grip-Fit.GEOMETRY.greatsword.grip)*neutral.weapon_rect.size
	assert(Fit.register_stance("vault_runner","heavy_two_hand",{"texture":neutral.texture,"body_rect":neutral.body_rect,"primary_hand":neutral.hand,"secondary_hand":neutral.hand+span,"supports_two_hand":true}))
	var paired := Fit.sample(game)
	assert(paired.support_status == "authored_two_hand")
	assert(paired.secondary_grip.distance_to(paired.secondary_hand) < .001)
	assert(Fit.register_stance("vault_runner","wand",{"texture":neutral.texture,"body_rect":neutral.body_rect,"primary_hand":neutral.hand+Vector2(100,100),"secondary_hand":neutral.secondary_hand,"wardrobe_requires":{"headwear":"unavailable_hat"}}))
	prepare("vault_runner","wand")
	var incompatible_pose: Dictionary=Fit.sample(game)
	assert(incompatible_pose.sprite_rig)
	assert(incompatible_pose.hand != neutral.hand+Vector2(100,100))
	Fit.stance_assets.clear()
	if not interactive or native or "--report" in OS.get_cmdline_user_args():
		var report := FileAccess.open("res://.godot_test_data/weapon_fit_report.json",FileAccess.WRITE)
		assert(report != null)
		report.store_string(JSON.stringify({"checks":production_matrix,"support_art_pending":pending_by_facing,"technical_support_pending":technical_by_facing,"count_unit":"unique actor/weapon/facing cell; rig contacts do not establish canonical art"},"\t"))
	print("PRODUCTION MATRIX authored support-art debt per facing: ",pending_by_facing,"; unresolved technical contacts: ",technical_by_facing)
	print("WEAPON FIT QA PASSED: 144 combinations; %d facing/phase checks; grip/socket transforms; stat/gameplay/loot RNG isolation; authored two-anchor solver. %d actor/weapon/facing cells still need approved authored support/paired art (NOT visual passes)." % [checks,int(pending_by_facing.right)+int(pending_by_facing.left)])
	if interactive:
		prepare(actors[0],Weapons.live_ids()[0])
		initialized = true
		update_label()
	else:
		game.queue_free()
		await process_frame
		quit(0)

func update_label() -> void:
	var pose := Fit.sample(game)
	label.text = "%s / %s\n%s · %s\nArrows: actor/weapon · F: facing · Space: release\n%s" % [actors[actor_index],Weapons.live_ids()[weapon_index],pose.body_profile,pose.stance,pose.support_status]
	game.queue_redraw()

func _process(_delta: float) -> bool:
	if not initialized: return false
	var changed := false
	if Input.is_action_just_pressed("ui_up"):
		actor_index = wrapi(actor_index+1,0,actors.size())
		changed = true
	if Input.is_action_just_pressed("ui_down"):
		actor_index = wrapi(actor_index-1,0,actors.size())
		changed = true
	if Input.is_action_just_pressed("ui_right"):
		weapon_index = wrapi(weapon_index+1,0,Weapons.live_ids().size())
		changed = true
	if Input.is_action_just_pressed("ui_left"):
		weapon_index = wrapi(weapon_index-1,0,Weapons.live_ids().size())
		changed = true
	if changed: prepare(actors[actor_index],Weapons.live_ids()[weapon_index])
	if Input.is_physical_key_pressed(KEY_F):
		game.player_facing = -1; game.forced_facing_test=-1
	else: game.player_facing = 1; game.forced_facing_test=1
	game.attack_anim = .22 if Input.is_physical_key_pressed(KEY_SPACE) else 0.0
	update_label()
	return false
