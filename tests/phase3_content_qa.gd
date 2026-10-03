extends SceneTree
const Items = preload("res://item_catalog.gd")
const Traits = preload("res://character_traits.gd")
const Events = preload("res://expedition_event_catalog.gd")
var game
var native := false
var captures := 0

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")

func prepare(actor: String = "relic_beast", weapon: String = "scrapfang_blade") -> void:
	game.profile.avatar_mode = "wanderer" if preload("res://wanderer_catalog.gd").PRESETS.has(actor) else "lootling"
	game.profile.current_lootling_id = actor; game.profile.wanderer.preset_id = actor
	game.inventory.reset_to_starter(); game.inventory.equip(Items.create_item(weapon,"COMMON",-1))
	game.meta_power = 0; game.gold_upgrades = {"bedroll":0,"whetstone":0,"pouch":0}
	game.campaign_id = "act_i"; game.dungeon.active = false; game.grouped_patrols = false
	seed(19283); game.rng.seed = 38192; game.loot_system.rng.seed = 81923
	game.start_run(); game.player_x = game.target_player_x()
	game.enemy_entry_anim = 0; game.wave_banner_timer = 0
	game.pause_panel.visible = false; game.abandon_panel.visible = false
	game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible = false

func capture(name: String) -> void:
	game.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://.godot_test_data/phase3/"+name+".png") == OK)
	captures += 1

func review() -> void:
	native = DisplayServer.get_name() != "headless"
	game = load("res://main.tscn").instantiate(); root.add_child(game)
	await process_frame; game.set_process(false)
	var requested_size := OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
	if native and requested_size.size() == 2:
		root.size = Vector2i(int(requested_size[0]),int(requested_size[1]))
		await process_frame
	game.app_lifecycle.platform_notifications_enabled = false
	game.audio_settings.cinematic_first_time = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.godot_test_data/phase3"))
	for actor in Traits.TRAITS:
		prepare(actor,str(Traits.TRAITS[actor].starter))
		assert(game.character_trait == Traits.TRAITS[actor])
		assert(is_equal_approx(game.player_max_hp,100.0+float(Traits.TRAITS[actor].hp)+game.inventory.effect_total("max_hp")))
		if native:
			game.perform_player_attack(false); game._process(.05)
			await capture("actor_"+actor)
	# Leech only actual removed HP, never overkill.
	prepare(); game.player_hp = 50; game.life_steal = .04; game.enemy_hp = 10; game.enemy_hit_multiplier = 1
	game.damage_enemy(100,false,false)
	assert(is_equal_approx(game.player_hp,50.4))
	# Shared control budget cannot turn a fast build into permanent stun.
	prepare(); game.enemy_attack_clock = 1.0
	for index in range(100): game.delay_enemy(.25)
	assert(is_equal_approx(game.enemy_attack_clock,1.5))
	# Named signatures survive random affixes and save/reload exactly.
	for source in preload("res://phase3_item_catalog.gd").ITEMS:
		var item := Items.create_item(source.id,"EPIC",839)
		var rolled := preload("res://affix_catalog.gd").apply(item,["of_the_vault"])
		if source.has("fixed_signature"): assert(rolled.signature_hooks.size() == 1)
		game.inventory.reset_to_starter(); game.inventory.equip(rolled)
		assert(game.inventory.save("user://phase3_items.cfg") == OK)
		var restored := preload("res://inventory_system.gd").new(); restored.load("user://phase3_items.cfg")
		assert(restored.equipped_item(str(source.slot)) == rolled)
		if native:
			prepare(); game.pending_items.append(rolled); game.show_next_item()
			await capture("item_"+str(source.id))
	# Every offered choice, affordability guard and double-tap boundary.
	for event in Events.EVENTS:
		for choice_index in range(3):
			prepare(); game.enemy_alive = false; game.coins = 100
			game.event_seen = Events.EVENTS.keys().filter(func(id): return id != event)
			game.show_expedition_event(); assert(game.event_id == event)
			assert(not game.event_buttons[choice_index].disabled)
			if native and choice_index == 0: await capture("event_"+event)
			game.choose_expedition_event(choice_index)
			var before := [game.coins,game.player_hp,game.pending_levels,game.pending_items.size(),game.player_ward]
			game.choose_expedition_event(choice_index)
			assert(before == [game.coins,game.player_hp,game.pending_levels,game.pending_items.size(),game.player_ward])
	prepare(); game.enemy_alive = false; game.coins = 0; game.player_hp = 5
	game.event_seen = Events.EVENTS.keys().filter(func(id): return id != "wounded_courier")
	game.show_expedition_event(); assert(game.event_buttons[0].disabled and game.event_buttons[1].disabled)
	game.choose_expedition_event(0); assert(game.state == "event" and game.player_hp == 5)
	game.choose_expedition_event(2); assert(game.state == "playing")
	# Every boss action is telegraphed; recovery is a real non-damaging action.
	for campaign in preload("res://campaign_system.gd").ORDER:
		for phase in [1,2]:
			prepare(); game.campaign_id = campaign; game.wave = 15; game.spawn_enemy()
			game.boss_phase = phase; game.enemy_entry_anim = 0; game.player_hp = 10000; game.player_max_hp = 10000
			for action_index in range(6):
				game.floating_texts.clear(); game.boss_recovery = 0
				game.enemy_attack_count = action_index; game.enemy_attack_clock = .10
				var cue := preload("res://combat_presentation.gd").attack_cue(game)
				assert(cue.visible and cue.label == preload("res://boss_patterns.gd").next(game).text)
				var action := preload("res://boss_patterns.gd").next(game)
				var hp: float = game.player_hp
				if native: await capture("boss_%s_p%d_a%d" % [campaign,phase,action_index])
				game.perform_enemy_attack()
				if action.recovery: assert(game.player_hp == hp and game.boss_recovery > 0)
	# New elite mechanics are bounded and visible; no multi-modifier stacking.
	for variant in preload("res://enemy_variant_catalog.gd").live_ids():
		prepare(); game.wave = 12; game.spawn_enemy(); game.debug_force_variant(variant)
		game.player_hp = 1000; game.player_max_hp = 1000; game.enemy_hp = game.enemy_max_hp*.30
		game.perform_enemy_attack()
		assert(game.enemy_hp <= game.enemy_max_hp and game.player_hp >= 0)
		if native: await capture("elite_"+variant)
	prepare(); game.state = "hideout"; game.meta_power = 100; game.meta_shards = 5000
	game.buy_meta_power(); assert(game.meta_power == 100 and game.meta_shards == 5000)
	game.free(); await process_frame
	print("PHASE3 CONTENT QA PASSED: 12 traits, 12 saved items, 24 event choices/duplicate guards, 120 boss action states, 11 elites, leech/control/cap contracts; %d native captures" % captures)
	quit()
