extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through guarded native helper. Forced tiers are labelled.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review")
func clean() -> void:
	game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.visible=false
func review() -> void:
	var dimensions:=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x");root.size=Vector2i(int(dimensions[0]),int(dimensions[1]))
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false)
	folder="res://.godot_test_data/phase4e/visible-owner-final-v22/"+OS.get_environment("LOOTLINGS_CAPTURE_SIZE")+"/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game.startup_ui.show_title();await capture("01_title")
	game.retention.progress.data.free_spins=2;game.retention.progress.save();game.show_hideout();clean();await capture("02_home_world")
	for speaker in ["Patch","Sera","Ilex"]:
		game.hideout_ui.request_dialogue("idle",speaker);await capture("03_dialogue_"+speaker.to_lower());game.hideout_ui.dismiss_dialogue()
	game.hideout_ui.show_campaign();await capture("04_expeditions")
	await tap(game.hideout_ui.campaign_list.get_child(0));assert(game.hideout_ui.region_sheet.visible);await capture("05_region_detail")
	game.navigate_back();assert(not game.hideout_ui.region_sheet.visible)
	game.campaign.completed.append("act_i");game.retention.show_modes("dungeons");await capture("06_dungeons")
	game.retention.show_modes("siege");await capture("07_siege")
	game.navigate_back();assert(game.hideout_ui.visible and not game.retention.panel.visible)
	game.inventory.scrap=3000;game.hideout_ui.configure(game.inventory,game.hideout_shop,game.meta_shards,game.meta_power,Callable(game,"build_item_comparison"),game.gold,game.profile,game.gold_upgrades,game.achievements)
	game.hideout_ui.show_shop();game.hideout_ui.select_shop_offer(0);await capture("08_home_shop_comparison")
	game.navigate_back();game.inventory.stash.append(game.ItemCatalog.create_item("scrapfang_blade","EPIC",1841));game.hideout_ui.show_stash();game.hideout_ui.select_entry(0);await capture("09_gear_comparison")
	game.navigate_back();game.navigate_back();game.hideout_ui.show_upgrades();await capture("10_shrine")
	game.show_hideout();game.hideout_ui.show_contracts();await capture("11_jobs")
	game.show_hideout();game.hideout_ui.show_phase4("archive");await capture("12_archive")
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	helper.prepare("relic_beast","greatsword");game.player_x=game.target_player_x();game.enemy_entry_anim=0;game.wave_banner_timer=0;game.enemy_hp=10000;game.enemy_max_hp=10000;clean()
	await capture("13_combat_attack_control")
	var sequence: int=game.attack_sequence;await tap(game.combat_controls.attack);assert(game.attack_sequence==sequence+1);await capture("14_actual_attack")
	game.coins=1500;game.shop.stock.clear();game.show_merchant();game.inspect_merchant_item(0);await capture("15_merchant_comparison")
	game.navigate_back();game.pending_levels=1;game.show_upgrade_choices();game.inspect_upgrade(0);await capture("16_perk_comparison")
	game.navigate_back();game.pending_items=[game.ItemCatalog.create_item("tiny_bell","EPIC",1852)];game.show_next_item();await capture("17_found_item_keep_current")
	game.navigate_back()
	game.boss_reward_options=[game.ItemCatalog.create_item("scrapfang_blade","EPIC",1853),game.ItemCatalog.create_item("bonebow","EPIC",1854),game.ItemCatalog.create_item("gravebloom_staff","LEGENDARY",1855)]
	game.show_boss_reward();clean();await capture("17b_boss_finds_keep_current");game.inspect_boss_reward(0);await capture("17c_boss_find_comparison");game.navigate_back();game.navigate_back()
	game.wave=6;game.wave_kills=1;game.retention.round_rule={"count":1,"boss":false,"event":true};game.retention.killed();await capture("17d_boost_current_new_leave");game.retention.selected_at=0;game.navigate_back()
	game.total_kills=20;game.end_run(false);clean();await capture("18_results_earned_later")
	game.show_hideout();await tap(game.hideout_ui.engine_button);assert(game.state=="relic_spinner" and game.retention.spinner_from_home);await capture("19_free_engine_home")
	game.retention.selected_at=0;var wallet: int=game.retention.progress.data.spin_wallet;var bank: int=game.retention.progress.data.free_spins
	game.retention.choose(0);assert(game.retention.progress.data.spin_wallet==wallet and game.retention.progress.data.free_spins==bank-1)
	await create_timer(.3).timeout;await capture("20_actual_free_spin")
	await create_timer(6).timeout;assert(not game.retention.spin_busy);await capture("21_actual_free_result")
	game.retention.pool_panel.visible=true;await capture("21b_pool_odds_earned_rules");game.navigate_back();assert(not game.retention.pool_panel.visible and game.state=="relic_spinner")
	game.retention.close_spinner();assert(game.state=="hideout")
	game.state="result";game.retention.show_spinner()
	for rarity in preload("res://relic_spin_catalog.gd").TIERS:
		var machine=game.retention.machine
		game.retention.spin_reward={"kind":"material","rarity":rarity,"amount":8 if rarity in ["LEGENDARY","RED"] else 2}
		game.retention.spin_message="FORCED TIER PREVIEW / no reward granted";game.retention.spin_kind="material"
		if rarity=="RED":
			game.retention.spin_reward={"kind":"item","rarity":"RED","item":game.ItemCatalog.create_item("gravebloom_staff","RED",1941)};game.retention.spin_kind="item"
		machine.wind_up(game.retention.spin_kind,rarity,false);machine.set_process(false)
		machine._process(machine.reel_seconds*.55);await capture("22_"+rarity.to_lower()+"_reels_FORCED")
		machine._process(machine.reel_seconds*.45+.01);await capture("23_"+rarity.to_lower()+"_anticipation_FORCED")
		machine._process(preload("res://relic_spin_catalog.gd").anticipation(rarity));await capture("24_"+rarity.to_lower()+"_reveal_FORCED")
		machine._process(2);await capture("25_"+rarity.to_lower()+"_settled_FORCED")
	game.free();helper.free();print("VISIBLE NATIVE: title, world/NPCs, regions/dungeons/Siege, comparisons/Keep, actual Attack, earned free reveal and all six labelled tier previews; "+OS.get_environment("LOOTLINGS_CAPTURE_SIZE"));quit()
