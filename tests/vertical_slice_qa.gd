extends SceneTree

const Presentation = preload("res://combat_presentation.gd")
const Inventory = preload("res://inventory_system.gd")
const Campaign = preload("res://campaign_system.gd")
var game
var native := false
var captured := {}

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.app_lifecycle.platform_notifications_enabled = false
	game.audio_settings.cinematic_first_time = false
	game.start_run()
	game.wave_banner_timer = 0.0
	game.player_x = game.target_player_x()
	game.enemy_entry_anim = 0.0
	var director = game.presentation_director
	director.active_toast.clear()
	director.toast_queue.clear()
	director.present_toast("RELIC RECOVERED", "Ancient treasure. Questionable previous owner.")
	director.present_toast("BUILD AWAKENED", "Your next bad idea now hits harder.")
	director.update_toast(0.4)
	assert(director.toast_title.text == "RELIC RECOVERED" and director.toast_queue.size() == 1)
	assert(director.toast_panel.position.y >= 536 and director.toast_panel.position.y + director.toast_panel.size.y <= 662)
	assert(director.toast_panel.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	game.state = "upgrade"
	var reading_time: float = director.toast_elapsed
	director.update_toast(10.0)
	assert(not director.toast_panel.visible and director.toast_elapsed == reading_time)
	game.state = "playing"
	director.update_toast(0.0)
	assert(director.toast_panel.visible)
	if native: await capture("notification_lane")
	director.update_toast(4.0)
	director.update_toast(0.4)
	assert(director.toast_title.text == "BUILD AWAKENED")
	director.active_toast.clear()
	director.toast_queue.clear()
	director.toast_panel.visible = false
	# The windup reads the very same clock/attack count used by combat.
	for archetype in ["skirmisher", "tank", "hexer"]:
		game.enemy_archetype = archetype
		game.enemy_name = game.ZoneCatalog.enemy_for(game.current_zone, archetype).name
		game.enemy_attack_count = 2
		game.enemy_attack_clock = 0.12
		var cue := Presentation.attack_cue(game)
		assert(cue.visible and cue.progress > 0.0)
		assert(cue.label == {"skirmisher":"QUICK STRIKE", "tank":"HEAVY STRIKE", "hexer":"WARD"}[archetype])
		if native: await capture("windup_" + archetype)
		game.enemy_attack_clock = 2.0
		assert(not Presentation.attack_cue(game).visible)
	game.enemy_archetype = "tank"
	game.combat_presentation.step(game, 0.0)
	game.damage_enemy(8.0, true, true)
	game.combat_presentation.step(game, 0.05)
	assert(game.combat_presentation.health_ratio(game.enemy_serial) > game.enemy_hp / game.enemy_max_hp)
	if native: await capture("critical_impact")
	game.combat_presentation.step(game, 2.0)
	assert(is_equal_approx(game.combat_presentation.health_ratio(game.enemy_serial), game.enemy_hp / game.enemy_max_hp))
	# Each pack member retains its own trail when the player switches targets.
	game.grouped_patrols = true
	game.wave = 2
	game.wave_kills = 0
	game.spawn_enemy()
	game.combat_presentation.step(game, 0.0)
	var first_serial: int = game.enemy_serial
	game.damage_enemy(5.0, false, true)
	game.enemy_encounter.select(game, 1)
	game.combat_presentation.step(game, 0.05)
	assert(game.combat_presentation.health_ratio(first_serial) > game.enemy_encounter.actors[0].enemy_hp / game.enemy_encounter.actors[0].enemy_max_hp)
	assert(game.combat_presentation.health_ratio(game.enemy_serial) == 1.0)
	# A full controlled Act I run validates every decision and payout boundary.
	# Existing smoke/balance fixtures separately exercise unmodified combat balance.
	game.grouped_patrols = false
	game.inventory.reset_to_starter()
	game.campaign.completed.clear()
	game.campaign_id = "act_i"
	game.start_run()
	game.rng.seed = 73119
	game.loot_system.rng.seed = 82119
	var visited := {}
	var bought := false
	var guard := 0
	while game.state != "result" and guard < 2500:
		guard += 1
		visited[game.state] = true
		match game.state:
			"upgrade":
				if native: await capture_once("upgrade")
				game.choose_upgrade(0)
			"item":
				if native: await capture_once("equipment")
				game.accept_item_equip()
			"event": game.choose_expedition_event(2)
			"merchant":
				if native: await capture_once("merchant")
				if not bought:
					for index in range(game.shop.stock.size()):
						if game.coins >= int(game.shop.stock[index].price):
							var before: int = game.coins
							var price: int = game.shop.stock[index].price
							game.buy_merchant_item(index)
							assert(game.coins == before - price and game.state == "item")
							bought = true
							break
				if game.state == "merchant": game.leave_merchant()
			"hoard_chest":
				game._process(0.20)
				if game.hoard_chest_phase == "ready":
					if native: await capture_once("hoard_chest")
					game.open_hoard_chest()
			"boss_reward":
				assert(game.boss_reward_options.size() in [2,3] if game.normal_loot_choice else game.boss_reward_options.size() == 3)
				if not game.normal_loot_choice:
					for item in game.boss_reward_options: assert(item.rarity in ["EPIC", "LEGENDARY"])
				for visuals in game.boss_reward_visuals:
					assert(visuals.effects.get_minimum_size().y <= 48.0)
					assert(visuals.name.get_theme_font("font").get_string_size(visuals.name.text, HORIZONTAL_ALIGNMENT_LEFT, -1, visuals.name.get_theme_font_size("font_size")).x <= 270.0)
				if native: await capture_once("boss_choice")
				game.choose_boss_reward(0)
			_:
				if game.enemy_alive:
					if game.enemy_is_boss or game.enemy_is_miniboss:
						game.enemy_entry_anim = 0.0
						game.enemy_attack_clock = 0.18
						game.wave_banner_timer = 0.0
						game.floating_texts.clear()
						if native: await capture_once("boss" if game.enemy_is_boss else "miniboss")
					game.damage_enemy(game.enemy_hp * 2 + 1, false, true)
				game._process(0.2)
	assert(game.state == "result" and game.run_won and bought)
	for decision in ["merchant", "upgrade", "item", "hoard_chest", "boss_reward"]: assert(visited.has(decision), decision)
	assert("act_i" in game.campaign.completed)
	var final_gold: int = game.gold
	game.end_run(true)
	assert(game.gold == final_gold)
	if native: await capture_once("victory")
	game.show_hideout()
	game.app_lifecycle.persist()
	var restored := Inventory.new()
	restored.load(game.INVENTORY_SAVE_PATH)
	assert(equivalent(restored.equipped, game.inventory.equipped) and equivalent(restored.stash, game.inventory.stash), "Gear must round-trip, allowing ConfigFile float precision")
	var restored_campaign := Campaign.new()
	restored_campaign.load_progress("user://campaign.cfg")
	assert(restored_campaign.completed == game.campaign.completed)
	if native: await capture_once("home")
	game.queue_free()
	await process_frame
	print("VERTICAL SLICE QA PASSED: queued nonblocking notices, decision deferral, truthful windups, per-actor damage trails, Act I merchant/miniboss/boss/chest/upgrade/equip/victory, single payout, saved gear/campaign reload")
	quit(0)

func capture_once(label: String) -> void:
	if captured.has(label): return
	captured[label] = true
	await capture(label)

func equivalent(left: Variant, right: Variant) -> bool:
	if (left is float or left is int) and (right is float or right is int):
		return is_equal_approx(float(left), float(right))
	if left is Dictionary and right is Dictionary:
		if left.size() != right.size(): return false
		for key in left:
			if not right.has(key) or not equivalent(left[key], right[key]): return false
		return true
	if left is Array and right is Array:
		if left.size() != right.size(): return false
		for index in range(left.size()):
			if not equivalent(left[index], right[index]): return false
		return true
	return left == right

func capture(label: String) -> void:
	# Accelerated simulation can outrun a real-time travel tween. Wait for the
	# actual presentation to finish rather than capturing a covered encounter.
	if game.presentation_director.travel_active: await create_timer(1.0).timeout
	game.queue_redraw()
	await create_timer(0.28).timeout
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	assert(shot.get_size() == Vector2i(480, 854))
	assert(shot.save_png("res://.godot_test_data/slice_%s.png" % label) == OK)
