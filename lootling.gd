extends Control

const GameCatalog = preload("res://game_catalog.gd")
const BuildSystem = preload("res://build_system.gd")
const MetaStore = preload("res://meta_store.gd")
const CreatureRenderer = preload("res://creature_renderer.gd")
const ItemCatalog = preload("res://item_catalog.gd")
const LootSystem = preload("res://loot_system.gd")
const InventorySystem = preload("res://inventory_system.gd")
const ShopSystem = preload("res://shop_system.gd")
const HideoutUI = preload("res://hideout_ui.gd")
const HideoutShopSystem = preload("res://hideout_shop_system.gd")
const ZoneCatalog = preload("res://zone_catalog.gd")
const ProfileStore = preload("res://profile_store.gd")
const SettingsStore = preload("res://settings_store.gd")
const AnalyticsLogger = preload("res://analytics_logger.gd")
const AudioManager = preload("res://audio_manager.gd")
const VoiceIdentity = preload("res://voice_identity.gd")
const ProjectilePresentation = preload("res://projectile_presentation.gd")
const PickupPresentation = preload("res://pickup_presentation.gd")
const CharacterTraits = preload("res://character_traits.gd")
const Phase4 = preload("res://phase4_catalog.gd")
var expedition_progress := preload("res://expedition_progress.gd").new()
var expedition_tier := 0
var run_resolved := false
var retention=preload("res://retention_runtime.gd").new()
const BossPatterns = preload("res://boss_patterns.gd")
const ExpeditionEvents = preload("res://expedition_event_catalog.gd")
const StartupUI = preload("res://startup_ui.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")
const Avatar = preload("res://avatar_presentation.gd")
const WandererPose = preload("res://wanderer_pose_catalog.gd")
const WeaponFit = preload("res://weapon_fit_catalog.gd")
const ItemIcon = preload("res://item_icon.gd")
const DebugPanel = preload("res://debug_panel.gd")
const PresentationDirector = preload("res://presentation_director.gd")
const Vignettes = preload("res://vignette_catalog.gd")
const LootlingsUI = preload("res://lootlings_ui.gd")
const AffixCatalog = preload("res://affix_catalog.gd")
const EnemyVariantCatalog = preload("res://enemy_variant_catalog.gd")
const AchievementManager = preload("res://achievement_manager.gd")
const RewardRevealCatalog = preload("res://reward_reveal_catalog.gd")
const VANGUARD_WEAPON_TEXTURE = preload("res://art/sprites/weapons/vanguard_hammer.png")
const RANGER_WEAPON_TEXTURE = preload("res://art/sprites/weapons/ranger_bow.png")
const MAGE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/mage_staff.png")
const ROGUE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/rogue_daggers.png")
const HOARD_CHEST_X := 300.0
const HOARD_CHEST_TEXTURE = preload("res://art/sprites/rewards/hoard_chest.png")
const DESIGN_SIZE := Vector2(480.0, 854.0)
const SAVE_PATH := "user://lootlings_save.cfg"
const INVENTORY_SAVE_PATH := "user://lootlings_inventory.cfg"
const HIDEOUT_SHOP_SAVE_PATH := "user://lootlings_hideout_shop.cfg"
const PROFILE_SAVE_PATH := "user://lootlings_profile.cfg"
const SETTINGS_SAVE_PATH := "user://lootlings_settings.cfg"
const ANALYTICS_PATH := "user://lootlings_events.jsonl"
const RUN_LAST_WAVE := 15
const CampaignSystem = preload("res://campaign_system.gd")
var campaign := CampaignSystem.new()
var campaign_id := "act_i"
const ContractSystem = preload("res://contract_system.gd")
var contracts := ContractSystem.new()
const ENEMIES_PER_WAVE := 3
const PLAYER_HOME_X := 102.0
const PLAYER_ATTACK_X := 245.0
const ENEMY_X := 372.0

const UPGRADES := GameCatalog.UPGRADES

var rng := RandomNumberGenerator.new()
var visual_rng := RandomNumberGenerator.new()
var build = BuildSystem.new()
var creature_renderer = CreatureRenderer.new()
var loot_system = LootSystem.new()
var inventory = InventorySystem.new()
var shop = ShopSystem.new()
var hideout_shop = HideoutShopSystem.new()
var title_font: Font
var body_font: Font
var state := "boot"
var wave := 1
var wave_kills := 0
var last_spawned_wave := 0
var current_zone: Dictionary = ZoneCatalog.for_wave(1)
var current_zone_id := "outer_ruins"
var pending_zone_transition := false
var zone_transition_timer := 0.0
var zone_transition_title := ""
var zone_transition_subtitle := ""
var special_intro_timer := 0.0
var special_intro_wave := 0
var total_kills := 0
var coins := 0
var level := 1
var xp := 0.0
var xp_needed := 32.0
var pending_levels := 0
var run_time := 0.0
var player_x := PLAYER_HOME_X
var player_facing := 1
var forced_facing_test := 0 # Used only by explicitly labelled isolated pose fixtures.
var enemy_stage_x := ENEMY_X

func target_combat_position() -> Vector2:
	return enemy_encounter.target_position() if enemy_encounter.active else Vector2(enemy_stage_x,507)

func target_combat_visual_position() -> Vector2:
	return preload("res://combat_stage.gd").enemy_position(self,target_combat_position().x)

func combat_facing() -> int:
	if OS.get_environment("LOOTLINGS_QA")=="1" and forced_facing_test in [-1,1]: return forced_facing_test
	if state=="playing" and enemy_alive:
		return 1 if target_combat_position().x>=player_x else -1
	return player_facing

func enemy_facing_at(position_x: float) -> int:
	return 1 if player_x>position_x else -1
var player_hp := 100.0
var player_max_hp := 100.0
var base_damage := 11.0
var attack_interval := 0.85
var attack_clock := 0.0
var crit_chance := 0.08
var crit_mult := 2.0
var multi_hits := 1
var splash_ratio := 0.0
var life_steal := 0.0
var armor := 0.0
var frenzy := 0.0
var tap_mult := 0.65
var execute_ratio := 0.0
var regen_per_second := 0.0
var debug_perk_rarity := ""
var coin_reward_mult := 1.0
var xp_reward_mult := 1.0
var enemy_name := ""
var enemy_hp := 1.0
var enemy_max_hp := 1.0
var enemy_damage := 1.0
var enemy_attack_interval := 2.0
var enemy_attack_clock := 1.5
var enemy_is_boss := false
var enemy_is_miniboss := false
var enemy_weapon_opening_used := false
var enemy_trait_opening_used := false
var enemy_trait_crit_used := false
var enemy_control_budget := 0.5
var enemy_status_ward_used := false
var enemy_chime_primed := false
var player_ward := 0.0
var character_trait: Dictionary = {}
var survived_hits := 0
var delayed_hits: Array = []
var signature_targets: Dictionary = {}
var cache_hit_primed := false
var boss_recovery := 0.0
var boss_phase := 1
var wave_composition: Array = []
var wave_composition_wave := -1
var event_seen: Array = []
var event_due := false
var event_id := ""
var event_risk := 1.0
var event_power := 1.0
var event_panel: Panel
var event_title: Label
var event_line: Label
var event_buttons: Array[Button] = []
var enemy_archetype := "skirmisher"
var enemy_hit_multiplier := 1.0
var enemy_variant_id := ""
var enemy_variant_name := ""
var enemy_variant_color := Color.TRANSPARENT
var enemy_reward_multiplier := 1.0
var enemy_xp_multiplier := 1.0
var enemy_attack_count := 0
var enemy_first_crit_used := false
var enemy_frostbell_used := false
var enemy_variant_guarded := false
var enemy_post_guard_hit_multiplier := 1.0
var enemy_alive := true
var spawn_clock := 0.0
var carried_shockwave := 0.0
var attack_sequence := 0
var enemy_burn_dps := 0.0
var enemy_burn_time := 0.0
var enemy_poison_stacks := 0
var enemy_poison_time := 0.0
var dot_tick_clock := 0.4
var heavy_power := 0
var storm_power := 0
var ignite_power := 0
var wildfire_power := 0
var venom_power := 0
var plague_power := 0
var selected_upgrades: Array = []
var upgrade_counts := {}
var floating_texts: Array = []
var combat_number_pool: Array = []
var combat_number_allocations := 0
var particles: Array = []
var reward_pickups: Array = []
var loot_drops: Array = []
var pending_items: Array = []
var current_item: Dictionary = {}
var pending_victory := false
var run_won := false
var merchant_due := false
var item_review_due := false
var return_to_merchant := false
var equipment_hp_bonus := 0.0
var boss_reward_options: Array = []
var normal_loot_choice := false
var hoard_chest_phase := ""
var hoard_chest_timer := 0.0
var hoard_chest_y := 330.0
var hoard_reveal_profile := {}
var screen_shake := 0.0
var enemy_flash := 0.0
var player_flash := 0.0
var squash := 0.0
var attack_anim := 0.0
var attack_was_tap := false
var player_idle_reaction := 0.0
var player_idle_reaction_clock := 3.0
var player_idle_reaction_direction := 1.0
var enemy_attack_anim := 0.0
var enemy_recoil := 0.0
var enemy_squash := 0.0
var enemy_death_anim := 0.0
var enemy_entry_anim := 0.0
var impact_flash := 0.0
var crit_flash := 0.0
var element_flash := 0.0
var element_flash_color := Color.WHITE
var element_flash_identity := ""
var death_burst := 0.0
var death_burst_color := Color.WHITE
var hit_stop_timer := 0.0
var coin_counter_flash := 0.0
var xp_counter_flash := 0.0
var player_reward_flash := 0.0
var player_reward_color := Color.WHITE
var rarity_reveal_flash := 0.0
var rarity_reveal_color := Color.WHITE
var tap_pulse := 0.0
var upgrade_flash := 0.0
var wave_banner_timer := 0.0
var wave_banner_text := ""
var wave_banner_color := Color("#8fdcff")
var status_message := "Tap the arena to attack."
var responsive_backdrop: Control
var pause_build_details: RichTextLabel
var status_clock := 4.0
var tap_combo := 0
var combo_clock := 0.0
var tap_buffer_timer := 0.0
var tap_input_cooldown := 0.0
var tap_buffer_flash := 0.0
var tap_tutorial_seen := false
var rift_progress := preload("res://rift_progress.gd").defaults()
var meta_shards := 0
var meta_power := 0
var gold := 0
var gold_upgrades := preload("res://permanent_upgrade_catalog.gd").defaults()
var run_gold_earned := 0
var run_shards_earned := 0
var run_coins_earned := 0
var run_coins_spent := 0
var run_damage_taken := 0.0
var run_start_scrap := 0
var run_kept_loot: Array[String] = []
var run_notable_items: Array[Dictionary] = []
var result_loot_cards: Array[Control] = []
var upgrade_panel: Panel
var upgrade_title: Label
var upgrade_buttons: Array[Button] = []
var upgrade_take_button: Button
var upgrade_selection := -1
var merchant_buy_button: Button
var merchant_detail: RichTextLabel
var merchant_selection := -1
var selection_msec := 0
var proc_texture: Texture2D
var proc_timer := 0.0
var result_panel: Panel
var result_title: Label
var result_crest: TextureRect
var result_summary: RichTextLabel
var upgrade_visuals: Array[Dictionary] = []
var hud_header_surface := LootlingsUI.skin_style("hud_header_9slice", 32)
var hud_build_surface := LootlingsUI.skin_style("hud_build_ribbon_9slice", 32)
var restart_button: Button
var backup_menu
var contextual_guide
var help_label: Label
var combat_controls: Control
var upgrade_compare: RichTextLabel
var item_panel: Panel
var item_title: Label
var item_description: Label
var item_compare: RichTextLabel
var item_equip_button: Button
var item_keep_button: Button
var item_scrap_button: Button
var item_icon
var merchant_panel: Panel
var merchant_title: Label
var merchant_subtitle: Label
var merchant_coin_label: RichTextLabel
var merchant_buttons: Array[Button] = []
var merchant_icons: Array = []
var merchant_visuals: Array[Dictionary] = []
var merchant_reroll_button: Button
var merchant_continue_button: Button
var boss_reward_panel: Panel
var boss_reward_heading: Label
var boss_reward_footer: Label
var boss_reward_leave_button: Button
var boss_reward_buttons: Array[Button] = []
var boss_reward_icons: Array = []
var boss_reward_visuals: Array[Dictionary] = []
var hoard_chest_button: Button
var pause_button: Button
var pause_panel: Panel
var abandon_panel: Panel
var hideout_ui
var startup_ui
var combat_companion:=preload("res://companion_presentation.gd").new()
var personal_home
var personal_profile_return := false
var audio_manager
var presentation_director
var story_run_presentations := false
var story_life_was_processing := true
var debug_panel
var owner_test_access
var app_lifecycle
var safe_area_layout
var mobile_test_monitor
var touch_ux
var debug_enabled := false
var debug_god_mode := false
var debug_weapon_family_override := ""
var attack_projectiles: Array = []
var projectile_impacts: Array = []
var enemy_serial := 0
var combat_presentation = preload("res://combat_presentation.gd").new()
var enemy_encounter = preload("res://enemy_encounter.gd").new()
var grouped_patrols := false
var dungeon = preload("res://dungeon_route.gd").new()
var route_panel: Panel
var route_subtitle: Label
var route_buttons: Array[Button] = []
var route_visuals: Array[Dictionary] = []
var route_reseed_button: Button
var profile := {}
var audio_settings := {}
var achievements = AchievementManager.new()
var last_lantern_spent := false

func _ready() -> void:
	preload("res://save_scope.gd").transitioning=false
	if preload("res://economy_transaction.gd").recover()!=OK:
		set_process(false)
		var notice:=Label.new();notice.text="Your saved purchase could not be recovered.\nYour files have been retained. Restart after checking storage.";notice.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);notice.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;add_child(notice);return
	if preload("res://offline_backup.gd").recover()!=OK:
		set_process(false);var notice:=Label.new();notice.text="Your interrupted restore needs recovery. Files are retained. Restart after checking storage.";notice.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);notice.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;add_child(notice);return
	rng.randomize()
	visual_rng.randomize()
	preload("res://lootlings_typography.gd").install(self)
	title_font = preload("res://lootlings_typography.gd").heading()
	body_font = preload("res://lootlings_typography.gd").body()
	build_overlay_ui()
	var crest=preload("res://hud_portrait_crest.gd").new();crest.game=self;add_child(crest)
	load_meta()
	profile = ProfileStore.load_profile(PROFILE_SAVE_PATH)
	audio_settings = SettingsStore.load_settings(SETTINGS_SAVE_PATH)
	inventory.load(INVENTORY_SAVE_PATH)
	expedition_progress.load_progress()
	expedition_progress.recover_delivery(inventory,INVENTORY_SAVE_PATH)
	hideout_shop.load(HIDEOUT_SHOP_SAVE_PATH)
	hideout_shop.save(HIDEOUT_SHOP_SAVE_PATH)
	build_hideout()
	build_foundation_services()
	build_presentation_director()
	build_debug_tools()
	show_startup()
	app_lifecycle = preload("res://app_lifecycle.gd").new()
	add_child(app_lifecycle)
	app_lifecycle.configure(self)
	safe_area_layout = preload("res://safe_area_layout.gd").new()
	add_child(safe_area_layout)
	safe_area_layout.configure(self)
	var scenic_layer := CanvasLayer.new()
	scenic_layer.layer = -100
	add_child(scenic_layer)
	responsive_backdrop = preload("res://responsive_backdrop.gd").new()
	scenic_layer.add_child(responsive_backdrop)
	responsive_backdrop.configure(self)
	touch_ux = preload("res://touch_ux.gd").new()
	add_child(touch_ux)
	retention.configure(self)
	touch_ux.configure(self)
	backup_menu=preload("res://backup_menu.gd").new();add_child(backup_menu);backup_menu.configure(self)
	contextual_guide=preload("res://contextual_guide.gd").new();add_child(contextual_guide);contextual_guide.configure(self)
	combat_controls=preload("res://combat_controls.gd").new();add_child(combat_controls);combat_controls.configure(self)
	if OS.has_feature("s23_test") or OS.get_environment("LOOTLINGS_MOBILE_TEST") == "1":
		mobile_test_monitor = preload("res://mobile_test_monitor.gd").new()
		add_child(mobile_test_monitor)
		mobile_test_monitor.configure(self)
		var report_button := make_action_button(pause_panel, "TEST REPORT", Vector2(35, 442), Vector2(300, 52), Color("#172442"), Color("#78e4ff"), mobile_test_monitor.show_report)
		report_button.visible = OS.is_debug_build() and OS.get_environment("LOOTLINGS_DEV_UI")=="1"
		if report_button.visible: pause_panel.size.y = 526
		report_button.tooltip_text = "Device frame pacing, memory and lifecycle report"
	AnalyticsLogger.log_event(ANALYTICS_PATH, "app_start", {"profile_exists":ProfileStore.is_created(profile)})
	queue_redraw()

func build_presentation_director() -> void:
	presentation_director = PresentationDirector.new()
	add_child(presentation_director)
	presentation_director.vignette.sound_requested.connect(play_audio_event)
	presentation_director.vignette.active_changed.connect(on_story_playback_changed)
	presentation_director.bind_buttons(self)

func build_debug_tools() -> void:
	debug_enabled = DebugPanel.allowed(OS.is_debug_build())
	if not debug_enabled:
		return
	debug_panel = DebugPanel.new()
	add_child(debug_panel)
	debug_panel.configure(self)
	if preload("res://owner_test_access.gd").enabled():
		owner_test_access=preload("res://owner_test_access.gd").new();add_child(owner_test_access);owner_test_access.configure(self)
	if preload("res://save_scope.gd").open_debug:
		preload("res://save_scope.gd").open_debug=false
		debug_panel.call_deferred("open")

func current_weapon_family() -> String:
	if debug_enabled and not debug_weapon_family_override.is_empty():
		return debug_weapon_family_override
	return inventory.weapon_family()

func debug_snapshot() -> String:
	return "STATE %s  •  WAVE %d  •  SEED %d\nHP %.0f/%.0f  •  %s  •  %s\nBUILD %s" % [state.to_upper(), wave, rng.seed, player_hp, player_max_hp, current_weapon_family(), "GOD ON" if debug_god_mode else "GOD OFF", build.short_summary()]+"\nLOOTCOINS %d  •  LOOT DIAMONDS %d" % [gold,meta_shards]

func debug_wallet_change(coins_delta: int, diamonds_delta: int, reset: bool=false) -> String:
	if not debug_enabled or (not preload("res://save_scope.gd").active and OS.get_environment("LOOTLINGS_QA")!="1"):
		return "Enter the isolated test profile first."
	var before_coins := gold
	var before_diamonds := meta_shards
	gold = 0 if reset else clampi(gold+clampi(coins_delta,-999999999,999999999),0,999999999)
	meta_shards = 0 if reset else clampi(meta_shards+clampi(diamonds_delta,-999999,999999),0,999999)
	var result: Error = MetaStore.save_progress(SAVE_PATH,meta_shards,meta_power,gold,gold_upgrades,rift_progress)
	if result != OK:
		gold=before_coins;meta_shards=before_diamonds
		return "Could not save test wallet. Balances unchanged."
	refresh_hideout()
	return "Test wallet saved: %d Lootcoins / %d Loot Diamonds." % [gold,meta_shards]


func debug_value(field:String) -> float:
	return float({"sigils":rift_progress.sigils,"xp":xp,"wave":wave,"hp":player_hp,"max_hp":player_max_hp,"damage":base_damage,"crit":crit_chance,"armor":armor,"ward":player_ward,"attack_interval":attack_interval,"gold":gold,"diamonds":meta_shards,"scrap":inventory.scrap}.get(field,0))

func debug_adjust_value(request:Dictionary) -> String:
	if not debug_enabled or (not preload("res://save_scope.gd").active and OS.get_environment("LOOTLINGS_QA")!="1"):return "Enter the isolated test profile first."
	var field:String=request.get("field","")
	var operation:String=request.get("operation","")
	var amount:float=float(request.get("amount",0))
	var bounds:Dictionary=preload("res://debug_panel.gd").VALUE_FIELDS
	if not bounds.has(field) or operation not in ["set","add","remove"] or not is_finite(amount):return "Invalid test value."
	var previous:=debug_value(field)
	var next:=amount if operation=="set" else previous+amount*(1 if operation=="add" else -1)
	next=clampf(next,bounds[field][1],minf(bounds[field][2],player_max_hp) if field=="hp" else bounds[field][2])
	if field=="sigils":
		rift_progress.sigils=int(next)
		if not save_hideout_economy():rift_progress.sigils=int(previous);return "Could not save test Sigils. Unchanged."
		refresh_hideout();return "Rift Sigils saved: %d" % rift_progress.sigils
	if field=="xp":
		xp=clampf(next,0,maxf(0,xp_needed-.01));return "XP this level: %.1f / %.1f (no reward granted)" % [xp,xp_needed]
	if field=="wave":
		debug_jump_to_wave(int(next));return "Test wave: %d (session only)" % wave
	if field=="gold":return debug_wallet_change(int(next)-gold,0)
	if field=="diamonds":return debug_wallet_change(0,int(next)-meta_shards)
	if field=="scrap":
		inventory.scrap=int(next)
		if inventory.save(INVENTORY_SAVE_PATH)!=OK:inventory.scrap=int(previous);return "Could not save test Scrap. Unchanged."
		refresh_hideout()
	else:
		var property:String={"hp":"player_hp","max_hp":"player_max_hp","damage":"base_damage","crit":"crit_chance","armor":"armor","ward":"player_ward","attack_interval":"attack_interval"}[field]
		set(property,next)
		if field=="max_hp":player_hp=minf(player_hp,player_max_hp)
	return "%s: %s" % [bounds[field][0],str(debug_value(field))]

func debug_action(action: String, payload) -> String:
	if not debug_enabled:
		return "Debug tools are disabled."
	if not preload("res://save_scope.gd").active and OS.get_environment("LOOTLINGS_QA")!="1":return "Enter the isolated test profile first."
	match action:
		"exact_value":
			return debug_adjust_value(payload)
		"perk_offers":
			debug_ensure_run();pending_levels=maxi(1,pending_levels);debug_perk_rarity=str(payload);show_upgrade_choices();debug_perk_rarity="";return "Test perk offers prepared. Close this menu to choose."
		"synergy_poison":
			debug_ensure_run()
			for up in UPGRADES:
				if up.id in ["venom","plague","vamp"]:apply_upgrade_effect(up)
			return "Applied existing Venom Coat, Plague Siphon and Toxic Fang to the test build."
		"shh_reset":
			if is_instance_valid(owner_test_access):owner_test_access.reset_position();return "SHH position reset."
			return "Owner build only."
		"shh_hide":
			if is_instance_valid(owner_test_access):owner_test_access.hide_shortcut();return "SHH hidden. Reopen from owner Settings > Support."
			return "Owner build only."
		"relock":
			if is_instance_valid(owner_test_access):owner_test_access.relock();return "SHH hidden. Repeat the title gesture to unlock."
			return "SHH is available only in the owner build."
		"sigils":
			return debug_adjust_value({"field":"sigils", "operation":"add", "amount":maxi(0,int(payload))})
		"ward":
			player_ward+=maxf(0,float(payload));return "Added test Ward."
		"item_id":
			if not str(payload) in ItemCatalog.ITEMS.map(func(item):return item.id):return "Unknown item."
			if inventory.stash.size()>=inventory.stash_capacity:return "Test stash full; make room first."
			var rng_before := rng.state
			var stash_before: Array = inventory.stash.duplicate(true)
			var item:Dictionary=ItemCatalog.create_item(str(payload),"MYTHICAL SHINY" if str(payload) in preload("res://mythical_collection.gd").IDS else "LEGENDARY",rng.randi())
			inventory.stash.append(item)
			if inventory.save(INVENTORY_SAVE_PATH) != OK:
				inventory.stash = stash_before; rng.state = rng_before
				return "Could not save test gear. Unchanged."
			refresh_hideout();return "Granted %s to test stash." % item.name
		"save_test":
			return "Saved isolated test progress." if app_lifecycle.persist() == OK else "Could not save test progress. Retry after checking storage."
		"load_test":
			preload("res://save_scope.gd").switch_profile(get_tree(),true);return "Reloading isolated test profile."
		"modes":
			show_hideout();retention.show_modes("dungeons");return "Close this menu to select an existing mode."
		"spinner":
			show_hideout();retention.progress.data.free_spins=3;retention.progress.save();retention.show_spinner();return "Three test spins. Close menu to use existing Spinner."
		"wave":
			debug_jump_to_wave(int(payload))
			return "Jumped to wave %d." % int(payload)
		"kill":
			if enemy_alive: kill_enemy()
			return "Current enemy defeated."
		"god":
			debug_god_mode = not debug_god_mode
			return "God mode %s." % ("enabled" if debug_god_mode else "disabled")
		"hp":
			player_hp = player_max_hp if payload == "full" else 1.0
			return "Player HP set to %.0f." % player_hp
		"victory", "defeat":
			debug_show_result(action == "victory")
			return "Previewing %s without rewards or saves." % action
		"gold":
			return debug_wallet_change(int(payload),0)
		"scrap":
			return debug_adjust_value({"field":"scrap", "operation":"add", "amount":int(payload)})
		"shards":
			return debug_wallet_change(0,int(payload))
		"wallet_reset":
			return debug_wallet_change(0,0,true)
		"earned_spin":
			var before: int=int(retention.progress.data.get("free_spins",0))
			retention.progress.data.free_spins=mini(retention.progress.FREE_BANK_CAP,before+1)
			if retention.progress.save()!=OK:
				retention.progress.data.free_spins=before
				return "Could not save test spin."
			return "Added one saved test spin."
		"xp":
			debug_ensure_run(); add_xp(maxf(1.0, xp_needed - xp + 1.0))
			return "Forced one run level-up."
		"drop":
			debug_force_drop(str(payload))
			return "Spawned %s equipment." % str(payload)
		"hoard":
			debug_ensure_run(); enemy_alive = false; pending_victory = false; item_review_due = true; prepare_hoard_chest()
			return "Spawned live Hoard Chest."
		"weapon":
			debug_weapon_family_override = str(payload)
			return "Weapon presentation set to %s (session only)." % str(payload)
		"core":
			debug_set_core(str(payload))
			return "Core presentation set to %s (run only)." % str(payload)
		"variant":
			debug_force_variant(str(payload))
			return "Enemy variant set to %s." % str(payload)
		"signature":
			debug_force_signature(str(payload))
			return "Equipped Signature %s for this test." % str(payload)
		"achievement":
			if str(payload) == "reset": achievements.reset()
			else: award_achievement(str(payload))
			return "Achievement action applied: %s." % str(payload)
		"upgrade":
			debug_ensure_run(); apply_upgrade_effect(UPGRADES[rng.randi_range(0, UPGRADES.size() - 1)])
			return "Added one random run upgrade."
		"speed":
			Engine.time_scale = float(payload)
			return "Test speed set to %d×." % int(payload)
		"reset":
			debug_reset_lootlings_saves()
			return "Lootlings test saves reset."
	return "No action."

func debug_ensure_run() -> void:
	if state not in ["playing", "upgrade", "item", "merchant", "hoard_chest", "boss_reward"]:
		start_run()

func debug_jump_to_wave(target_wave: int) -> void:
	debug_ensure_run()
	Engine.time_scale = 1.0
	state = "playing"
	wave = clampi(target_wave, 1, RUN_LAST_WAVE)
	wave_kills = 0
	last_spawned_wave = 0
	special_intro_wave = wave
	pending_zone_transition = false
	pending_victory = false
	merchant_due = false
	item_review_due = false
	pending_items.clear()
	loot_drops.clear()
	attack_projectiles.clear()
	projectile_impacts.clear()
	for panel in [upgrade_panel, item_panel, merchant_panel, boss_reward_panel, result_panel]:
		panel.visible = false
	spawn_enemy()

func debug_force_drop(rarity: String) -> void:
	debug_ensure_run()
	var definition: Dictionary = ItemCatalog.ITEMS[rng.randi_range(0, ItemCatalog.ITEMS.size() - 1)]
	var item := ItemCatalog.create_item(definition.id, rarity, rng.randi())
	item = AffixCatalog.apply(item, AffixCatalog.roll_for_item(item, loot_system.rng))
	loot_drops.append({"item":item, "rarity":rarity, "boss_choice":false, "pos":Vector2(350, 470), "vel":Vector2(-70, -225), "pickup":1.0, "bounces":0, "squash":0.0, "color":ItemCatalog.rarity_color(rarity)})
	play_audio_event("equipment_drop")

func debug_set_core(identity: String) -> void:
	debug_ensure_run()
	build.reset()
	if identity != "Neutral":
		for stack in range(5):
			build.add_upgrade({"tags":[identity]})

func debug_force_variant(id: String) -> void:
	debug_ensure_run()
	if not EnemyVariantCatalog.VARIANTS.has(id):
		return
	var base_stats := {"hp":enemy_max_hp, "damage":enemy_damage, "interval":enemy_attack_interval, "hit":enemy_hit_multiplier}
	var variant := EnemyVariantCatalog.definition(id)
	enemy_post_guard_hit_multiplier = enemy_hit_multiplier
	var modified := EnemyVariantCatalog.apply(id, base_stats)
	enemy_variant_id = id
	enemy_variant_name = str(variant.name)
	enemy_variant_color = variant.accent
	enemy_name = "%s %s" % [enemy_variant_name, enemy_name]
	enemy_max_hp = float(modified.hp)
	enemy_hp = enemy_max_hp
	enemy_weapon_opening_used = false
	enemy_damage = float(modified.damage)
	enemy_attack_interval = float(modified.interval)
	enemy_hit_multiplier = float(modified.hit)
	enemy_reward_multiplier = float(modified.coin)
	enemy_xp_multiplier = float(modified.xp)
	enemy_variant_guarded = id == "rootbound"

func debug_force_signature(id: String) -> void:
	debug_ensure_run()
	var source_id := "bonebow" if id in ["crooked_constellation", "frostbell_chime"] else "mossguard_harness"
	var item := ItemCatalog.create_item(source_id, "LEGENDARY", rng.randi())
	item = AffixCatalog.apply(item, [id])
	inventory.equip(item)
	refresh_equipment_health()

func debug_show_result(victory: bool) -> void:
	run_won=victory
	state = "result"
	for panel in [upgrade_panel, item_panel, merchant_panel, boss_reward_panel]:
		panel.visible = false
	result_panel.visible = true
	result_title.text = "HOARD CONQUERED!" if victory else "EXPEDITION ENDED"
	result_crest.texture = LootlingsUI.icon("res://art/ui/results/%s_crest.png" % ("victory" if victory else "defeat"))
	LootlingsUI.apply_material(result_panel, "hoard")
	result_title.add_theme_color_override("font_color", Color("#ffe178") if victory else Color("#ff8995"))
	result_summary.text = style_result_summary("DEVELOPMENT PREVIEW\nNo rewards, stock refresh, or save changes.\n\nWave reached  %d / %d\nEnemies  %d" % [wave, RUN_LAST_WAVE, total_kills])
	help_label.visible = false

func debug_reset_lootlings_saves() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	if not preload("res://save_scope.gd").active:return
	var exact_paths := [SAVE_PATH,INVENTORY_SAVE_PATH,HIDEOUT_SHOP_SAVE_PATH,PROFILE_SAVE_PATH,SETTINGS_SAVE_PATH,ANALYTICS_PATH,achievements.path,"user://campaign.cfg","user://contracts.cfg","user://endgame.cfg","user://expedition_progress.cfg","user://home_economy_transaction.cfg"]
	for path in exact_paths:
		for suffix in ["",".bak",".tmp",".bak.tmp",".stage",".stage.bak"]:DirAccess.remove_absolute(ProjectSettings.globalize_path(preload("res://save_scope.gd").path(path+suffix)))
	get_tree().reload_current_scene()

func build_foundation_services() -> void:
	audio_manager = AudioManager.new()
	add_child(audio_manager)
	audio_manager.apply_settings(audio_settings)
	startup_ui = StartupUI.new()
	add_child(startup_ui)
	startup_ui.enter_hideout.connect(request_enter_hideout)
	startup_ui.profile_completed.connect(request_enter_hideout)
	startup_ui.profile_changed.connect(save_profile_data)
	startup_ui.settings_changed.connect(save_audio_settings)
	startup_ui.ui_event.connect(play_audio_event)
	startup_ui.story_preview_requested.connect(play_story_preview)
	startup_ui.configure(profile, ProfileStore.is_created(profile), audio_settings)

func show_startup() -> void:
	if presentation_director != null: presentation_director.vignette.cancel()
	state = "boot"
	hideout_ui.visible = false
	startup_ui.visible = true
	startup_ui.show_boot()
	help_label.visible = false
	audio_manager.set_music("TITLE")

func enter_hideout_from_title() -> void:
	AnalyticsLogger.log_event(ANALYTICS_PATH, "title_enter")
	show_hideout()

func request_enter_hideout() -> void:
	# Only unowned starter equipment changes with a newly selected identity.
	# Owned/stashed gear and all save/economy decisions remain intact.
	if inventory.stash.is_empty() and int(inventory.equipped_item("Weapon").get("serial",0)) == -1:
		var starting: Dictionary = CharacterTraits.definition(profile)
		inventory.equipped.Weapon = ItemCatalog.create_item(str(starting.starter),"COMMON",-1)
		inventory.save(INVENTORY_SAVE_PATH)
	AnalyticsLogger.log_event(ANALYTICS_PATH, "title_enter")
	if personal_profile_return:
		personal_profile_return=false;show_personal_home();return
	if presentation_director == null:
		show_hideout()
		return
	show_hideout(); discover_story("story/hideout")

func play_story_preview(id: String, preview_profile: Dictionary) -> void:
	if presentation_director.vignette.active: return
	hideout_ui.dismiss_dialogue()
	presentation_director.vignette.play(Vignettes.entry(id, preview_profile), audio_settings, "preview")

func on_story_playback_changed(playing: bool) -> void:
	if hideout_ui == null: return
	if playing:
		story_life_was_processing = hideout_ui.is_processing()
		hideout_ui.dismiss_dialogue()
		hideout_ui.set_process(false)
	else:
		hideout_ui.set_process(story_life_was_processing)

func replay_memory(id: String) -> void:
	if state != "hideout" or presentation_director.vignette.active or not Vignettes.available(id, profile,campaign.completed): return
	hideout_ui.dismiss_dialogue()
	presentation_director.vignette.play(Vignettes.entry(id, profile), audio_settings, "replay")

func discover_story(id: String, callback: Callable = Callable(), repeat_sting: bool = false) -> void:
	var entry := Vignettes.entry(id, profile)
	if entry.is_empty():
		if callback.is_valid(): callback.call()
		return
	if presentation_director.vignette.active: return
	var seen: bool = id in profile.get("memories", [])
	if not seen:
		profile.memories.append(id)
		ProfileStore.save_profile(PROFILE_SAVE_PATH, profile)
		hideout_ui.profile = profile.duplicate(true)
		startup_ui.profile.memories = profile.memories.duplicate()
	if (not seen and not audio_settings.get("cinematic_first_time", true)) or (seen and repeat_sting and not audio_settings.get("cinematic_repeat_boss", true)) or (seen and not repeat_sting and audio_settings.get("cinematic_auto_skip", true)):
		if callback.is_valid(): callback.call()
		return
	hideout_ui.dismiss_dialogue()
	presentation_director.vignette.play(entry, audio_settings, "discovery", callback, seen)

func meet_resident(speaker: String) -> void:
	if state != "hideout": return
	if hideout_ui.speech_panel.visible:
		hideout_ui.request_dialogue("tapped",speaker); return
	var id: String = {"Salvager":"patch", "Relic Keeper":"sera", "Archivist":"ilex"}.get(speaker, "")
	if id.is_empty(): return
	discover_story("resident/" + id, func():
		if state == "hideout": hideout_ui.request_dialogue("tapped", speaker)
	)

func show_profile_from_hideout() -> void:
	hideout_ui.visible = false
	startup_ui.visible = true
	startup_ui.profile = profile.duplicate(true)
	startup_ui.show_profile(false)
	if presentation_director != null:
		presentation_director.present_card(startup_ui, Color("#72c8ff"), 0.22)

func show_title_from_hideout() -> void:
	hideout_ui.visible = false
	startup_ui.visible = true
	startup_ui.profile = profile.duplicate(true)
	startup_ui.show_title()
	state = "boot"
	audio_manager.set_music("TITLE")
	if presentation_director != null:
		presentation_director.present_card(startup_ui, Color("#d1a85a"), 0.22)

func save_profile_data(updated_profile: Dictionary) -> void:
	var was_created := ProfileStore.is_created(profile)
	var old_name := str(profile.get("display_name", ""))
	var known_memories := ProfileStore.sanitize_memories(profile.get("memories", []))
	profile = updated_profile.duplicate(true)
	# A profile form opened before discovery must never erase an earned memory.
	profile.memories = ProfileStore.sanitize_memories(known_memories + ProfileStore.sanitize_memories(profile.get("memories", [])))
	ProfileStore.save_profile(PROFILE_SAVE_PATH, profile)
	AnalyticsLogger.log_event(ANALYTICS_PATH, "display_name_changed" if was_created and old_name != profile.display_name else "profile_created")
	if hideout_ui != null:
		hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)

func save_audio_settings(updated_settings: Dictionary) -> void:
	audio_settings = updated_settings.duplicate(true)
	SettingsStore.save_settings(SETTINGS_SAVE_PATH, audio_settings)
	audio_manager.apply_settings(audio_settings)

func play_character_voice(role: String, player: bool) -> void:
	if audio_manager != null:
		audio_manager.play_voice(VoiceIdentity.player(self) if player else VoiceIdentity.enemy(self),role)

func play_audio_event(event_name: String) -> void:
	if audio_manager != null:
		audio_manager.play_event(event_name)

func award_achievement(id: String, amount: int = 1, set_value: bool = false) -> void:
	var unlocked_now := achievements.set_progress(id, amount) if set_value else achievements.add_progress(id, amount)
	if not unlocked_now:
		return
	var entry := AchievementManager.definition_for(id)
	if hideout_ui != null:
		hideout_ui.queue_dialogue_context("secret_discovered" if bool(entry.get("secret",false)) else "trophy_earned")
	play_audio_event("rare_reveal")
	if presentation_director != null:
		presentation_director.present_toast("TROPHY UNLOCKED  •  %s" % str(entry.get("name", "Achievement")), achievements.display_description(entry), Color("#ffd36a"))
	AnalyticsLogger.log_event(ANALYTICS_PATH, "achievement_unlocked", {"achievement_id":id})

func award_item_discovery(item: Dictionary) -> void:
	var rarity := str(item.get("rarity", "COMMON"))
	if rarity == "EPIC":
		award_achievement("first_epic")
	elif rarity == "LEGENDARY":
		award_achievement("first_legendary")
	if not item.get("signature_hooks", []).is_empty():
		if hideout_ui != null:
			hideout_ui.queue_dialogue_context("signature_find")
		award_achievement("signature_find")
		for hook in item.get("signature_hooks", []):
			award_unique_achievement("signature_set", str(hook))

func award_unique_achievement(id: String, key: String) -> void:
	if not achievements.mark_unique(id, key):
		return
	var entry := AchievementManager.definition_for(id)
	play_audio_event("rare_reveal")
	if presentation_director != null:
		presentation_director.present_toast("TROPHY UNLOCKED  •  %s" % str(entry.get("name", "Achievement")), achievements.display_description(entry), Color("#ffd36a"))
	AnalyticsLogger.log_event(ANALYTICS_PATH, "achievement_unlocked", {"achievement_id":id})

func award_current_weapon_family() -> void:
	var weapon := inventory.equipped_item("Weapon")
	if not weapon.is_empty():
		award_unique_achievement("weapon_families", str(weapon.get("family", "VANGUARD")))

func build_overlay_ui() -> void:
	upgrade_panel = make_panel(Rect2(22, 130, 436, 630), Color("#172042f2"))
	LootlingsUI.apply_material(upgrade_panel, "relic")
	upgrade_panel.visible = false
	upgrade_title = make_label(upgrade_panel, "LEVEL UP!", 30, Rect2(20, 18, 396, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	for i in range(3):
		var button := Button.new()
		button.position = Vector2(25, 86 + i * 115)
		button.size = Vector2(386, 96)
		button.custom_minimum_size = Vector2(386, 96)
		button.add_theme_font_size_override("font_size", 16)
		button.add_theme_color_override("font_color", Color("#f8fbff"))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.clip_text = true
		button.pressed.connect(inspect_upgrade.bind(i))
		upgrade_panel.add_child(button)
		upgrade_buttons.append(button)
		var icon := TextureRect.new()
		icon.position = Vector2(20, 26)
		icon.size = Vector2(44, 44)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		var core_icon := LootlingsUI.add_icon(button, Rect2(80, 8, 16, 16), "core_neutral")
		var rarity_icon := LootlingsUI.add_icon(button, Rect2(338, 29, 28, 28), "rarity_common")
		var kicker := make_label(button, "", 10, Rect2(102, 9, 264, 16), HORIZONTAL_ALIGNMENT_LEFT, Color("#b9a5d5"))
		var name_label := make_label(button, "", 17, Rect2(80, 28, 248, 25), HORIZONTAL_ALIGNMENT_LEFT, Color.WHITE)
		var effect := make_label(button, "", 14, Rect2(80, 54, 286, 40), HORIZONTAL_ALIGNMENT_LEFT, Color("#c9d6e9"))
		effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		for label in [kicker, name_label, effect]:
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.clip_text = true
		upgrade_visuals.append({"kicker":kicker, "name":name_label, "effect":effect, "icon":icon, "core":core_icon, "rarity":rarity_icon})
	upgrade_compare=LootlingsUI.rich_label(upgrade_panel,Rect2(20,418,396,110),14,Color("#e6edff"));upgrade_compare.scroll_active=true
	make_action_button(upgrade_panel,"KEEP CURRENT",Vector2(222,538),Vector2(194,54),Color("#172442"),Color("#7087ae"),skip_upgrade).add_theme_font_size_override("font_size",14)
	upgrade_take_button = make_action_button(upgrade_panel,"SELECT A CARD",Vector2(20,538),Vector2(194,54),Color("#49346b"),Color("#ffe178"),take_selected_upgrade)
	upgrade_take_button.set_meta("ui_intent","primary")
	apply_button_style(upgrade_take_button,Color("#49346b"),Color("#ffe178"))
	upgrade_take_button.disabled = true
	result_panel = make_panel(Rect2(28, 155, 424, 555), Color("#151b39f5"))
	LootlingsUI.apply_material(result_panel, "hoard")
	result_panel.visible = false
	result_title = make_label(result_panel, "RUN COMPLETE!", 22, Rect2(135, 24, 268, 68), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	result_crest = LootlingsUI.add_icon(result_panel, Rect2(182, 103, 174, 30), "res://art/ui/results/victory_crest.png")
	var result_actor := preload("res://result_actor_view.gd").new()
	result_actor.game=self;result_actor.position=Vector2(12,8);result_actor.size=Vector2(118,132)
	result_panel.add_child(result_actor)
	result_summary = RichTextLabel.new()
	result_summary.position = Vector2(35, 160)
	result_summary.size = Vector2(354, 245)
	result_summary.bbcode_enabled = true
	result_summary.scroll_active = true
	result_summary.add_theme_font_size_override("normal_font_size", 14)
	result_summary.add_theme_color_override("default_color", Color("#e9efff"))
	result_panel.add_child(result_summary)
	LootlingsUI.add_divider(result_panel, Rect2(30, 145, 364, 10), "gold")
	restart_button = Button.new()
	restart_button.text = "RETURN TO HIDEOUT"
	restart_button.set_meta("gesture_release_owned",true) # Result returns own touch release like other destination buttons.
	restart_button.position = Vector2(47, 425)
	restart_button.size = Vector2(330, 68)
	restart_button.add_theme_font_size_override("font_size", 20)
	apply_button_style(restart_button, Color("#795523"), Color("#ffd468"))
	restart_button.pressed.connect(show_hideout)
	result_panel.add_child(restart_button)
	for i in range(2):
		var card := Panel.new()
		card.position = Vector2(18+i*197,500)
		card.size = Vector2(191,44)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon := preload("res://item_icon.gd").new()
		icon.position = Vector2(4,2)
		icon.size = Vector2(40,40)
		card.add_child(icon)
		var name_label := make_label(card,"",13,Rect2(48,3,137,38),HORIZONTAL_ALIGNMENT_LEFT,Color.WHITE)
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.set_meta("icon",icon)
		card.set_meta("name_label",name_label)
		result_panel.add_child(card)
		result_loot_cards.append(card)
	refresh_result_loot()
	help_label = make_label(self, "ATTACK for a strike / Auto-attacks continue", 12, Rect2(20, 810, 440, 32), HORIZONTAL_ALIGNMENT_CENTER, Color("#c6d8f4"))
	build_item_ui()
	build_merchant_ui()
	build_boss_reward_ui()
	build_hoard_chest_ui()
	build_route_ui()
	build_expedition_event_ui()
	build_pause_ui()

func build_pause_ui() -> void:
	pause_button = Button.new()
	pause_button.text = "Ⅱ  PAUSE"
	pause_button.position = Vector2(232, 10)
	pause_button.size = Vector2(86, 48)
	pause_button.add_theme_font_size_override("font_size", 12)
	apply_button_style(pause_button, Color("#172442df"), Color("#8fa6cf"))
	pause_button.pressed.connect(pause_run)
	pause_button.visible = false
	add_child(pause_button)
	pause_panel = make_panel(Rect2(55, 194, 370, 466), Color("#101731f8"))
	LootlingsUI.apply_material(pause_panel, "relic")
	pause_panel.visible = false
	make_label(pause_panel, "RUN PAUSED", 31, Rect2(20, 32, 330, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	pause_build_details = RichTextLabel.new()
	pause_build_details.position = Vector2(25,83); pause_build_details.size = Vector2(320,184)
	pause_build_details.bbcode_enabled = true; pause_build_details.scroll_active = true
	pause_build_details.add_theme_font_override("normal_font",body_font)
	pause_build_details.add_theme_font_size_override("normal_font_size",14)
	pause_build_details.add_theme_color_override("default_color",Color("#c9d8f0"))
	pause_panel.add_child(pause_build_details)
	make_action_button(pause_panel, "RESUME", Vector2(35, 282), Vector2(300, 64), Color("#285c4c"), Color("#69e6b0"), resume_run)
	make_action_button(pause_panel, "ABANDON RUN", Vector2(35, 364), Vector2(300, 62), Color("#54302d"), Color("#ff8d88"), request_abandon_run)
	abandon_panel = make_panel(Rect2(44, 225, 392, 374), Color("#12172ffb"))
	LootlingsUI.apply_material(abandon_panel, "danger")
	abandon_panel.visible = false
	make_label(abandon_panel, "RETURN TO HIDEOUT?", 28, Rect2(20, 30, 352, 46), HORIZONTAL_ALIGNMENT_CENTER, Color("#ff9b8f"))
	var warning := make_label(abandon_panel, "Current run progress and unclaimed\nrun rewards will be lost.", 16, Rect2(24, 96, 344, 106), HORIZONTAL_ALIGNMENT_CENTER, Color("#e6edff"))
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	make_action_button(abandon_panel, "STAY", Vector2(28, 246), Vector2(158, 68), Color("#263b58"), Color("#79a9d9"), cancel_abandon_run)
	make_action_button(abandon_panel, "RETURN HOME", Vector2(206, 246), Vector2(158, 68), Color("#5a302c"), Color("#ff8d88"), confirm_abandon_run)

func build_expedition_event_ui() -> void:
	event_panel = make_panel(Rect2(28,170,424,540),Color("#11182ef5"))
	LootlingsUI.apply_material(event_panel,"relic")
	event_panel.visible = false
	event_title = make_label(event_panel,"",23,Rect2(20,22,384,52),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	event_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_line = make_label(event_panel,"",15,Rect2(28,88,368,110),HORIZONTAL_ALIGNMENT_CENTER,Color("#dae5f9"))
	event_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for index in range(3):
		var button := make_action_button(event_panel,"",Vector2(24,214+index*98),Vector2(376,86),Color("#172442"),Color("#d4ad65"),choose_expedition_event.bind(index))
		button.add_theme_font_size_override("font_size",15)
		# Retain semantic button text while rendering the cost and effect wrapped.
		for font_color in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color"]:
			button.add_theme_color_override(font_color,Color.TRANSPARENT)
		var title := make_label(button,"",15,Rect2(12,8,352,24),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
		title.name = "ChoiceTitle"; title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var detail := make_label(button,"",14,Rect2(12,33,352,46),HORIZONTAL_ALIGNMENT_CENTER,Color("#dae5f9"))
		detail.name = "ChoiceDetail"; detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
		event_buttons.append(button)

func show_expedition_event() -> void:
	event_due = false
	event_id = ExpeditionEvents.roll(rng,event_seen)
	var rare_id: String = ["secret_bell","wandering_smith","mimic_parley"][expedition_progress.rng.randi_range(0,2)]
	var misses := int(expedition_progress.data.counts.get("discovery_misses",0))
	if not rare_id in event_seen and (expedition_progress.rng.randf() < .08+.04*expedition_tier or misses >= 5):
		event_id = rare_id; expedition_progress.data.counts.discovery_misses = 0
	else: expedition_progress.data.counts.discovery_misses = mini(5,misses+1)
	if event_id.is_empty(): return
	state = "event"; help_label.visible = false
	pause_button.visible = false
	event_seen.append(event_id)
	var data: Dictionary = ExpeditionEvents.EVENTS[event_id]
	event_title.text = data.title
	event_line.text = "%s\n\nHP %.0f / %.0f / WARD %.0f" % [data.line,player_hp,player_max_hp,player_ward]
	for index in range(2):
		var choice: Dictionary = ExpeditionEvents.choices_for(event_id,wave)[index]
		event_buttons[index].text = "%s\n%s" % [str(choice.name).to_upper(),choice.desc]
		event_buttons[index].disabled = player_hp + float(choice.get("hp",0)) <= 0
	event_buttons[2].text = "KEEP MOVING\nLeave everything as it is."
	event_buttons[2].disabled = false
	for button in event_buttons:
		var lines := button.text.split("\n",true,1)
		button.get_node("ChoiceTitle").text = lines[0]
		button.get_node("ChoiceDetail").text = lines[1]
		button.get_node("ChoiceTitle").modulate.a = .5 if button.disabled else 1.0
		button.get_node("ChoiceDetail").modulate.a = .5 if button.disabled else 1.0
	event_panel.visible = true
	if presentation_director != null: presentation_director.present_card(event_panel,Color("#d4ad65"),.22)

func choose_expedition_event(index: int) -> void:
	if state != "event" or index < 0 or index > 2 or event_id.is_empty(): return
	var choice: Dictionary = {} if index == 2 else ExpeditionEvents.choices_for(event_id,wave)[index]
	var secret_found: bool=index!=2 and event_id=="secret_bell"
	var hp := float(choice.get("hp",0))
	if player_hp+hp <= 0: return
	if index != 2: expedition_progress.record_event(event_id,float(choice.get("risk",1.0)) > 1.0)
	# Leave decision state before rewards; a second tap cannot repeat payment.
	state = "playing"; event_panel.visible = false; event_id = ""
	if secret_found:retention.progress.earn_spin("secret")
	pause_button.visible = true
	player_hp = minf(player_max_hp,player_hp+hp)
	player_ward = minf(15,player_ward+float(choice.get("ward",0)))
	event_risk = float(choice.get("risk",1.0)); event_power = float(choice.get("power",1.0))
	if choice.has("loot"):
		pending_items.append(loot_system.generate_shop_item(str(choice.loot)))
		item_review_due = true
		if inventory.has_signature("mimic_appetite"): cache_hit_primed = true
	if choice.has("upgrade"): pending_levels += 1
	if choice.has("xp"): add_xp(float(choice.xp))
	if pending_levels > 0 and state == "playing": show_upgrade_choices()
	play_audio_event("chest_open" if choice.has("loot") else "upgrade_select")

func build_hideout() -> void:
	hideout_ui = HideoutUI.new()
	add_child(hideout_ui)
	personal_home=preload("res://personal_home.tscn").instantiate();add_child(personal_home);personal_home.configure(self)
	campaign.load_progress("user://campaign.cfg")
	contracts.load_progress("user://contracts.cfg")
	hideout_ui.contracts = contracts
	hideout_ui.expedition_progress = expedition_progress
	hideout_ui.campaign = campaign
	hideout_ui.play_requested.connect(hideout_ui.show_campaign)
	hideout_ui.campaign_requested.connect(start_campaign)
	hideout_ui.tier_requested.connect(func(tier): expedition_tier = tier)
	hideout_ui.blueprint_requested.connect(func(id):
		if state != "hideout": return
		var message: String = expedition_progress.craft(id,inventory,INVENTORY_SAVE_PATH)
		hideout_ui.phase4_message = message; hideout_ui.refresh_phase4()
	)
	hideout_ui.farm_contract_requested.connect(func(region):
		if state == "hideout": expedition_progress.claim_job(region); hideout_ui.refresh_phase4()
	)
	hideout_ui.group_patrols_changed.connect(func(enabled: bool): grouped_patrols = enabled)
	hideout_ui.dungeon_requested.connect(start_dungeon)
	hideout_ui.stash_equip_requested.connect(equip_stash_item)
	hideout_ui.stash_scrap_requested.connect(scrap_stash_item)
	hideout_ui.upgrade_requested.connect(buy_meta_power)
	hideout_ui.shop_offer_requested.connect(buy_hideout_offer)
	hideout_ui.shop_cache_requested.connect(use_mystery_cache)
	hideout_ui.shop_gold_cache_requested.connect(use_gold_cache)
	hideout_ui.shop_expansion_requested.connect(buy_stash_expansion)
	hideout_ui.shop_reroll_requested.connect(reroll_hideout_shop)
	hideout_ui.gold_upgrade_requested.connect(buy_gold_upgrade)
	hideout_ui.forge_requested.connect(evolve_owned_weapon)
	hideout_ui.forge_craft_requested.connect(craft_weapon)
	hideout_ui.contract_claim_requested.connect(claim_contract)
	hideout_ui.home_preferences_requested.connect(save_home_preferences)
	hideout_ui.profile_requested.connect(show_profile_from_hideout)
	hideout_ui.title_requested.connect(show_title_from_hideout)
	hideout_ui.destination_visited.connect(func(destination_id): award_unique_achievement("hideout_social", str(destination_id)))
	hideout_ui.ui_event.connect(play_audio_event)
	hideout_ui.resident_meeting_requested.connect(meet_resident)
	hideout_ui.memory_replay_requested.connect(replay_memory)
	hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)
	hideout_ui.visible = false

func request_start_run() -> void:
	if state != "hideout":
		return
	if presentation_director != null and (presentation_director.travel_active or presentation_director.vignette.active): return
	if not dungeon.active:
		discover_story("region/" + campaign_id, depart_presented_run)
	else:
		depart_presented_run()

func depart_presented_run() -> void:
	if state != "hideout": return
	start_presented_run()

func start_presented_run() -> void:
	start_run()
	story_run_presentations = true

func show_hideout() -> void:
	if personal_home!=null:personal_home.visible=false
	hideout_ui.private_return=false
	retention.progress.recover(self)
	preload("res://rift_progress.gd").recover(self)
	retention.reset()
	if presentation_director != null: presentation_director.vignette.cancel()
	dungeon.active = false
	if route_panel != null: route_panel.visible = false
	enemy_encounter.clear()
	state = "hideout"
	if startup_ui != null:
		startup_ui.visible = false
	if pause_button != null:
		pause_button.visible = false
		pause_panel.visible = false
		abandon_panel.visible = false
	result_panel.visible = false
	upgrade_panel.visible = false
	item_panel.visible = false
	merchant_panel.visible = false
	boss_reward_panel.visible = false
	help_label.visible = false
	hideout_ui.visible = true
	event_panel.visible = false
	if touch_ux!=null: touch_ux.close_dialog()
	hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)
	hideout_ui.show_home()
	play_audio_event("menu_transition")
	if audio_manager != null:
		audio_manager.set_music("HIDEOUT")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "hideout_enter", {"gold":gold, "scrap":inventory.scrap, "shards":meta_shards})
	queue_redraw()

func pause_run() -> void:
	if state != "playing":
		return
	state = "paused"
	var mitigation := minf(.72,armor+inventory.effect_total("armor")+(.04 if current_weapon_family() == "VANGUARD" else 0.0))
	pause_build_details.text = "[center]Base power %.0f • Auto attack %.2fs\nCrit %d%% • Armour %.0f%% • Ward %.0f\nRegen %.1f HP/s • Hit leech %.0f%%\n\n%s\n\n[color=#ffe178]%s[/color]\n%s[/center]" % [base_damage*equipment_damage_multiplier(),current_attack_interval(),int(effective_crit_chance()*100),mitigation*100,player_ward,regen_per_second,life_steal*100,build.short_summary(),str(character_trait.get("name","")),str(character_trait.get("text",""))]
	pause_build_details.scroll_to_line(0)
	pause_button.visible = false
	pause_panel.visible = true
	abandon_panel.visible = false
	help_label.visible = false
	queue_redraw()

func resume_run() -> void:
	if state != "paused":
		return
	state = "playing"
	pause_panel.visible = false
	pause_button.visible = true
	help_label.visible = not tap_tutorial_seen
	queue_redraw()

func request_abandon_run() -> void:
	if state != "paused":
		return
	state = "abandon_confirm"
	pause_panel.visible = false
	abandon_panel.visible = true
	queue_redraw()

func cancel_abandon_run() -> void:
	if state != "abandon_confirm":
		return
	state = "paused"
	abandon_panel.visible = false
	pause_panel.visible = true
	queue_redraw()

func confirm_abandon_run() -> void:
	if state != "abandon_confirm":
		return
	# No result rewards, Shop refresh, or unclaimed loot processing occurs on abandon.
	pending_levels = 0
	pending_items.clear()
	loot_drops.clear()
	boss_reward_options.clear()
	normal_loot_choice = false
	current_item.clear()
	pending_victory = false
	merchant_due = false
	item_review_due = false
	return_to_merchant = false
	coins = 0
	run_coins_earned = 0
	run_coins_spent = 0
	run_shards_earned = 0
	run_gold_earned = 0
	show_hideout()

func equip_stash_item(index: int) -> void:
	if state != "hideout":
		return
	var equipment_before: Dictionary = inventory.equipped.duplicate(true)
	var stash_before: Array = inventory.stash.duplicate(true)
	if inventory.equip_from_stash(index):
		if inventory.save(INVENTORY_SAVE_PATH) != OK:
			inventory.equipped = equipment_before
			inventory.stash = stash_before
			show_stash_save_error()
			return
		award_current_weapon_family()
		contextual_guide.observe_success("equipment")
		hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)
		hideout_ui.play_stash_feedback("equip")
		play_audio_event("equip")
		AnalyticsLogger.log_event(ANALYTICS_PATH, "gear_equip", {"source":"stash"})

func scrap_stash_item(index: int) -> void:
	if state != "hideout":
		return
	var stash_before: Array = inventory.stash.duplicate(true)
	var scrap_before: int = inventory.scrap
	if inventory.scrap_from_stash(index) > 0:
		if inventory.save(INVENTORY_SAVE_PATH) != OK:
			inventory.stash = stash_before
			inventory.scrap = scrap_before
			show_stash_save_error()
			return
		hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)
		hideout_ui.play_stash_feedback("scrap")
		play_audio_event("scrap")
		AnalyticsLogger.log_event(ANALYTICS_PATH, "scrap_earned", {"source":"stash"})

func show_stash_save_error() -> void:
	status_message = "Could not save. Your gear and Scrap are unchanged; try again."
	var notice := "[color=#ff7d88]" + status_message + "[/color]\n"
	hideout_ui.stash_detail.text = notice + hideout_ui.stash_detail.text.trim_prefix(notice)
	hideout_ui.stash_detail.call_deferred("scroll_to_line", 0)

func buy_hideout_offer(index: int) -> void:
	if hideout_shop.requires_review():
		hideout_ui.show_shop_message("Your reserved cache needs review. Its record is retained; no new charge was made.");return
	if state != "hideout" or not hideout_shop.pending_cache_item.is_empty():
		return
	if index < 0 or index >= hideout_shop.stock.size():
		return
	if hideout_shop.stock[index].is_empty():
		return
	if inventory.stash.size() >= inventory.stash_capacity:
		hideout_ui.show_shop_message("STASH FULL\nMake room before buying equipment.", "#ff9b8f")
		return
	var offer: Dictionary = hideout_shop.stock[index]
	var price := int(offer.get("price", 0))
	if gold < price:
		hideout_ui.show_shop_message("Not enough Lootcoins for this offer.", "#ffbd69")
		return
	gold -= price
	var purchased := hideout_shop.take_offer(index)
	if not inventory.keep(purchased):
		hideout_shop.stock[index]=purchased
		gold += price
		hideout_ui.show_shop_message("STASH FULL\nNo Lootcoins was spent.", "#ff9b8f")
		return
	if not save_hideout_economy():return
	contextual_guide.observe_success("shop")
	hideout_ui.show_shop_message("PURCHASED\n%s was sent to your Stash." % purchased.get("name", "Equipment"), "#69e6b0")
	hideout_ui.play_shop_purchase(index, ItemCatalog.rarity_color(purchased.get("rarity", "COMMON")))
	hideout_ui.request_dialogue("shop_purchase", "Salvager")
	play_audio_event("shop_purchase")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "shop_purchase", {"currency":"lootcoins", "price":price, "item_id":purchased.get("id", "")})

func use_mystery_cache() -> void:
	if hideout_shop.requires_review():
		hideout_ui.show_shop_message("Your reserved cache needs review. Its record is retained; no new charge was made.");return
	if state != "hideout":
		return
	if not hideout_shop.pending_cache_item.is_empty():
		if hideout_shop.pending_cache_currency != "scrap":
			return
		if inventory.stash.size() >= inventory.stash_capacity:
			hideout_ui.show_shop_message("STASH FULL\nMake room before claiming the revealed item.", "#ff9b8f")
			return
		var claimed := hideout_shop.claim_cache()
		if inventory.keep(claimed):
			if not save_hideout_economy():return
			hideout_ui.show_shop_message("CLAIMED\n%s is now in your Stash." % claimed.get("name", "Equipment"), "#69e6b0")
			hideout_ui.play_cache_reveal(ItemCatalog.rarity_color(claimed.get("rarity", "COMMON")), RewardRevealCatalog.for_rewards("scavenged_cache", [claimed]), claimed)
			play_rarity_audio(claimed.get("rarity", "COMMON"))
		return
	if hideout_shop.cache_bought_this_cycle:
		hideout_ui.show_shop_message("Mystery Cache already opened.\nComplete a run to refresh it.", "#aebde0")
		return
	if inventory.stash.size() >= inventory.stash_capacity:
		hideout_ui.show_shop_message("STASH FULL\nMake room before opening a cache.", "#ff9b8f")
		return
	if inventory.scrap < hideout_shop.CACHE_COST:
		hideout_ui.show_shop_message("Not enough Scrap for a Mystery Cache.", "#ffbd69")
		return
	inventory.scrap -= hideout_shop.CACHE_COST
	hideout_shop.reveal_cache()
	record_contract_chest(false)
	if not save_hideout_economy():return
	award_achievement("ten_chests")
	award_achievement("chest_50")
	award_item_discovery(hideout_shop.pending_cache_item)
	hideout_ui.refresh_shop()
	hideout_ui.play_cache_reveal(ItemCatalog.rarity_color(hideout_shop.pending_cache_item.get("rarity", "COMMON")), RewardRevealCatalog.for_rewards("scavenged_cache", [hideout_shop.pending_cache_item]))
	hideout_ui.request_dialogue("cache_opened", "Salvager")
	play_audio_event("chest_open")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "chest_open", {"chest_id":"scavenged_cache", "currency":"scrap"})

func use_gold_cache() -> void:
	if hideout_shop.requires_review():
		hideout_ui.show_shop_message("Your reserved cache needs review. Its record is retained; no new charge was made.");return
	if state != "hideout":
		return
	if not hideout_shop.pending_cache_item.is_empty():
		if hideout_shop.pending_cache_currency != "gold":
			return
		if inventory.stash.size() >= inventory.stash_capacity:
			hideout_ui.show_shop_message("STASH FULL\nMake room before claiming the revealed item.", "#ff9b8f")
			return
		var claimed := hideout_shop.claim_cache()
		if inventory.keep(claimed):
			if not save_hideout_economy():return
			hideout_ui.show_shop_message("CLAIMED\n%s is now in your Stash." % claimed.get("name", "Equipment"), "#69e6b0")
			play_rarity_audio(claimed.get("rarity", "COMMON"))
		return
	if hideout_shop.gold_cache_bought_this_cycle:
		hideout_ui.show_shop_message("Scavenged Cache already opened.\nComplete a run to refresh it.", "#aebde0")
		return
	if inventory.stash.size() >= inventory.stash_capacity:
		hideout_ui.show_shop_message("STASH FULL\nMake room before opening a cache.", "#ff9b8f")
		return
	if gold < hideout_shop.GOLD_CACHE_COST:
		hideout_ui.show_shop_message("Not enough Lootcoins for a Scavenged Cache.", "#ffbd69")
		return
	gold -= hideout_shop.GOLD_CACHE_COST
	hideout_shop.reveal_gold_cache()
	record_contract_chest(false)
	if not save_hideout_economy():return
	award_achievement("ten_chests")
	award_achievement("chest_50")
	award_item_discovery(hideout_shop.pending_cache_item)
	hideout_ui.play_cache_reveal(ItemCatalog.rarity_color(hideout_shop.pending_cache_item.get("rarity", "COMMON")), RewardRevealCatalog.for_rewards("scavenged_cache", [hideout_shop.pending_cache_item]))
	hideout_ui.request_dialogue("cache_opened", "Salvager")
	play_audio_event("chest_land")
	play_audio_event("chest_open")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "chest_open", {"chest_id":"scavenged_cache", "currency":"gold", "price":hideout_shop.GOLD_CACHE_COST})

func buy_gold_upgrade(upgrade_id: String) -> void:
	if state != "hideout" or upgrade_id=="pouch" or not upgrade_id in gold_upgrades:
		return
	var costs: Dictionary={}
	for id in preload("res://permanent_upgrade_catalog.gd").DEFINITIONS:costs[id]=preload("res://permanent_upgrade_catalog.gd").DEFINITIONS[id][2]
	var rank := int(gold_upgrades[upgrade_id])
	if rank >= costs[upgrade_id].size():
		return
	var diamond_purchase: bool = preload("res://permanent_upgrade_catalog.gd").diamonds(upgrade_id)
	var price: int = costs[upgrade_id][rank]
	if (meta_shards if diamond_purchase else gold) < price:
		return
	if diamond_purchase:meta_shards -= price
	else:gold -= price
	gold_upgrades[upgrade_id] = rank + 1
	if not save_hideout_economy():return
	contextual_guide.observe_success("upgrades")
	refresh_hideout()
	hideout_ui.show_upgrades()
	hideout_ui.play_shrine_upgrade()
	hideout_ui.request_dialogue("shrine_upgrade", "Relic Keeper")
	play_audio_event("shop_purchase")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "shop_purchase", {"currency":preload("res://permanent_upgrade_catalog.gd").currency(upgrade_id), "price":price, "upgrade_id":upgrade_id, "rank":rank + 1})

func evolve_owned_weapon(stash_index: int) -> void:
	if state != "hideout":
		return
	var result: Dictionary = preload("res://forge_system.gd").purchase(inventory, gold, stash_index)
	if not result.ok:
		return
	gold = result.gold
	if not save_hideout_economy():return
	contextual_guide.observe_success("forge")
	play_audio_event("shop_purchase")

	hideout_ui.queue_dialogue_context("forge_evolved")

func start_campaign(region_id: String) -> void:
	if presentation_director.vignette.active or presentation_director.travel_active: return
	if state != "hideout" or not campaign.available(region_id):
		return
	if expedition_progress.rank() < int(Phase4.TIERS[expedition_tier].rank): return
	dungeon.active = false
	campaign_id = region_id
	request_start_run()

func craft_weapon(weapon_type: String) -> void:
	if state != "hideout":
		return
	var result: Dictionary = preload("res://forge_system.gd").craft(inventory, gold, weapon_type, rng.randi())
	if not result.ok:
		return
	gold = result.gold
	if not save_hideout_economy():return
	play_audio_event("shop_purchase")

	hideout_ui.queue_dialogue_context("new_weapon")

func claim_contract(slot: int) -> void:
	if state != "hideout": return
	var reward := contracts.claim(slot)
	if reward <= 0: return
	gold += reward
	if not save_hideout_economy():return
	refresh_hideout()
	hideout_ui.refresh_contracts()
	play_audio_event("shop_purchase")
	hideout_ui.queue_dialogue_context("contract_complete")

func record_contract_chest(persist: bool=true) -> void:
	contracts.record("chest")
	if hideout_ui != null:
		hideout_ui.queue_dialogue_context("cache_opened")
	if persist:contracts.save("user://contracts.cfg")

func run_zone_for_wave(value: int) -> Dictionary:
	return CampaignSystem.zone_for(campaign_id, value)

func buy_stash_expansion() -> void:
	if hideout_shop.requires_review():
		hideout_ui.show_shop_message("Your reserved cache needs review. Its record is retained; no new charge was made.");return
	if state != "hideout" or not hideout_shop.pending_cache_item.is_empty():
		return
	var price := hideout_shop.expansion_cost(inventory.stash_capacity)
	if price <= 0 or gold < price:
		return
	gold -= price
	if not inventory.expand_stash():
		gold += price
		return
	if not save_hideout_economy():return
	hideout_ui.show_shop_message("STASH EXPANDED\nCapacity increased to %d slots." % inventory.stash_capacity, "#72c8ff")

func reroll_hideout_shop() -> void:
	if hideout_shop.requires_review():
		hideout_ui.show_shop_message("Your reserved cache needs review. Its record is retained; no new charge was made.");return
	if state != "hideout" or hideout_shop.rerolled_this_cycle or not hideout_shop.pending_cache_item.is_empty():
		return
	if gold < hideout_shop.REROLL_COST:
		return
	gold -= hideout_shop.REROLL_COST
	if not hideout_shop.reroll():
		gold += hideout_shop.REROLL_COST
		return
	if not save_hideout_economy():return
	hideout_ui.show_shop_message("Offers replaced. Inspect before buying.", "#ffe178")

func save_hideout_economy() -> bool:
	var error:=preload("res://economy_transaction.gd").commit(self)
	if error!=OK:
		if FileAccess.file_exists(preload("res://economy_transaction.gd").PATH):
			state="save_recovery";hideout_ui.show_shop_message("Purchase reserved. Restart after checking storage; your record is retained.")
		else:
			load_meta();inventory.load(INVENTORY_SAVE_PATH);hideout_shop.load(HIDEOUT_SHOP_SAVE_PATH)
			contracts=ContractSystem.new();contracts.load_progress("user://contracts.cfg");hideout_ui.contracts=contracts
			hideout_ui.configure(inventory,hideout_shop,meta_shards,meta_power,Callable(self,"build_item_comparison"),gold,profile,gold_upgrades,achievements)
			hideout_ui.show_shop_message("Could not save. Your previous equipment and currency are retained.")
		return false
	hideout_ui.configure(inventory,hideout_shop,meta_shards,meta_power,Callable(self,"build_item_comparison"),gold,profile,gold_upgrades,achievements)
	return true

func build_item_ui() -> void:
	item_panel = make_panel(Rect2(24, 122, 432, 630), Color("#0b1229fc"))
	LootlingsUI.apply_material(item_panel, "leather")
	item_panel.visible = false
	item_title = make_label(item_panel, "LOOT FOUND!", 27, Rect2(22, 12, 388, 56), HORIZONTAL_ALIGNMENT_CENTER, Color.WHITE)
	item_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_title.clip_text = true
	item_icon = ItemIcon.new()
	item_icon.position = Vector2(28, 76)
	item_icon.size = Vector2(120, 120)
	item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_panel.add_child(item_icon)
	item_description = make_label(item_panel, "", 14, Rect2(164, 78, 240, 116), HORIZONTAL_ALIGNMENT_LEFT, Color("#e8efff"))
	item_description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_description.clip_text = true
	item_compare = RichTextLabel.new()
	item_compare.position = Vector2(24, 70)
	item_compare.size = Vector2(384, 345)
	item_compare.bbcode_enabled = true
	item_compare.fit_content = false
	item_compare.scroll_active = true
	item_compare.add_theme_font_size_override("normal_font_size", 14)
	item_compare.add_theme_color_override("default_color", Color("#dce6ff"))
	item_panel.add_child(item_compare)
	item_icon.visible=false;item_description.visible=false
	item_equip_button = make_action_button(item_panel, "EQUIP", Vector2(28, 432), Vector2(176, 58), Color("#295d50"), Color("#69e6b0"), inspect_item_equip)
	item_keep_button = make_action_button(item_panel, "KEEP", Vector2(228, 432), Vector2(176, 58), Color("#29486b"), Color("#74caff"), accept_item_keep)
	item_keep_button.add_theme_font_size_override("font_size", 15)
	item_scrap_button = make_action_button(item_panel, "SCRAP", Vector2(28, 500), Vector2(376, 52), Color("#5a3828"), Color("#ffbd69"), func():
		touch_ux.request("Salvage %s?" % current_item.get("name","Item"),"%s becomes %d Scrap. This cannot be undone." % [current_item.get("name","Item"),ItemCatalog.scrap_value(current_item)],accept_item_scrap)
	)

	make_action_button(item_panel,"KEEP CURRENT / LEAVE FIND",Vector2(28,563),Vector2(376,50),Color("#172442"),Color("#7087ae"),skip_item).add_theme_font_size_override("font_size",15)

func build_route_ui() -> void:
	route_panel = make_panel(Rect2(22, 184, 436, 534), Color("#0b1229fc"))
	LootlingsUI.apply_material(route_panel, "relic")
	route_panel.visible = false
	make_label(route_panel, "CHOOSE YOUR PATH", 28, Rect2(18, 14, 400, 40), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	route_subtitle = make_label(route_panel, "", 14, Rect2(24, 65, 242, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#bac9eb"))
	route_reseed_button = make_action_button(route_panel, "NEW SEED", Vector2(278, 57), Vector2(134, 42), Color("#172442"), Color("#78e4ff"), reseed_route)
	route_reseed_button.add_theme_font_size_override("font_size", 13)
	for index in range(2):
		var button := make_action_button(route_panel, "", Vector2(20, 106 + index * 134), Vector2(396, 122), Color("#172442"), Color("#d4ad65"), choose_route_room.bind(index))
		for state_color in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_shadow_color"]:
			button.add_theme_color_override(state_color, Color.TRANSPARENT)
		var icon := LootlingsUI.add_icon(button, Rect2(12, 28, 68, 68), "res://art/ui/icons/upgrades/damage.png")
		var name_label := make_label(button, "", 17, Rect2(92, 12, 286, 30), HORIZONTAL_ALIGNMENT_LEFT, Color("#ffe178"))
		var description := make_label(button, "", 14, Rect2(92, 48, 286, 64), HORIZONTAL_ALIGNMENT_LEFT, Color("#dbe7ff"))
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		route_buttons.append(button)
		route_visuals.append({"icon":icon, "name":name_label, "desc":description})
	make_label(route_panel, "Short-route rewards scale with foes defeated.\nNo campaign unlocks or permanent Shrine stats.", 14, Rect2(24, 379, 388, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#bac9eb"))
	make_action_button(route_panel, "END ROUTE", Vector2(24, 444), Vector2(388, 58), Color("#172442"), Color("#78e4ff"), func(): end_run(false))

func start_dungeon() -> void:
	if presentation_director.vignette.active or presentation_director.travel_active: return
	if state != "hideout" or not "act_i" in campaign.completed: return
	dungeon.setup(dungeon.seed_value, campaign_id if campaign.available(campaign_id) else "act_i")
	request_start_run()

func reseed_route() -> void:
	if state != "route" or dungeon.depth >= 0 or retention.rift_active: return
	dungeon.setup(dungeon.seed_value + 1, dungeon.region_id)
	rng.seed = dungeon.seed_value
	loot_system.rng.seed = dungeon.seed_value ^ 0x6c00
	seed(dungeon.seed_value ^ 0x7100)
	show_route_choices()

func show_route_choices() -> void:
	if not dungeon.active: return
	state = "route"
	enemy_alive = false
	enemy_death_anim = 0.0
	enemy_encounter.clear()
	wave_banner_timer = 0.0
	help_label.visible = false
	if pause_button != null: pause_button.visible = false
	route_panel.visible = true
	route_reseed_button.visible = dungeon.depth < 0 and not retention.rift_active
	route_subtitle.text = "STOP %d / 8 • SEED %d" % [dungeon.depth + 2, dungeon.seed_value]
	var options: Array = dungeon.choices()
	for index in range(route_buttons.size()):
		route_buttons[index].visible = index < options.size()
		if index >= options.size(): continue
		var option: Dictionary = options[index]
		# The visible child labels own wrapping; hidden Button text still expands its minimum size.
		route_buttons[index].text = ""
		route_buttons[index].tooltip_text = "%s\n%s" % [option.title, option.desc]
		route_visuals[index].icon.texture = LootlingsUI.icon(option.icon)
		route_visuals[index].name.text = "%s • %s" % [str(option.kind).to_upper(), option.title]
		fit_label_font(route_visuals[index].name, route_visuals[index].name.text, 286, 17, 14)
		route_visuals[index].desc.text = option.desc
	if presentation_director != null: presentation_director.present_card(route_panel, Color("#d4ad65"), 0.22)

func choose_route_room(index: int) -> void:
	if state != "route" or not dungeon.active: return
	var room: Dictionary = dungeon.choose(index)
	if room.is_empty(): return
	route_panel.visible = false
	state = "route_travel"
	enter_route_room()

func enter_route_room() -> void:
	if not dungeon.active: return
	state = "playing"
	wave = int(dungeon.room.wave)
	wave_kills = 0
	current_zone = run_zone_for_wave(wave)
	current_zone_id = current_zone.id
	merchant_due = false
	pending_zone_transition = false
	item_review_due = false
	enemy_alive = false
	enemy_is_boss = false
	enemy_is_miniboss = false
	enemy_encounter.clear()
	match dungeon.room.kind:
		"Combat", "Elite", "Risk", "Boss":
			if dungeon.room.kind in ["Elite", "Boss"]: play_audio_event("boss_warning")
			spawn_enemy()
			return
		"Rest":
			player_hp = minf(player_max_hp, player_hp + player_max_hp * 0.22)
			play_audio_event("upgrade_select")
		"Treasure":
			if inventory.has_signature("mimic_appetite"): cache_hit_primed = true
			enemy_is_miniboss = true
			spawn_item_drop()
			enemy_is_miniboss = false
			item_review_due = true
			record_contract_chest()
			play_audio_event("chest_open")
		"Merchant":
			shop.stock.clear()
			show_merchant()
		"Shrine":
			pending_levels += 1
			show_upgrade_choices()
			upgrade_title.text = "RELIC SHRINE • PICK ONE"
	dungeon.room_finished = true

func build_merchant_ui() -> void:
	merchant_panel = make_panel(Rect2(28, 112, 424, 540), Color("#11182ee8"))
	LootlingsUI.apply_material(merchant_panel, "salvage")
	merchant_panel.visible = false
	var peddler=preload("res://travelling_merchant_view.gd").new()
	peddler.name="PackPeddlerBody";peddler.game=self;peddler.position=Vector2(20,8);peddler.size=Vector2(116,118);merchant_panel.add_child(peddler)
	merchant_title = make_label(merchant_panel, "PACK PEDDLER", 22, Rect2(146, 12, 258, 40), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	merchant_subtitle = make_label(merchant_panel, "ROADSIDE STOP  •  BETWEEN WAVES", 11, Rect2(146, 50, 258, 22), HORIZONTAL_ALIGNMENT_CENTER, Color("#d3b777"))
	merchant_coin_label = LootlingsUI.rich_label(merchant_panel, Rect2(146, 86, 258, 26), 16, Color("#ffe078"))
	for i in range(3):
		var button := Button.new()
		button.position = Vector2(20, 120 + i * 76)
		button.size = Vector2(384, 74)
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(inspect_merchant_item.bind(i))
		merchant_panel.add_child(button)
		merchant_buttons.append(button)
		var icon := ItemIcon.new()
		icon.name = "OfferIcon%d" % i
		# Keep artwork attached to its offer; row spacing must not drift independently.
		icon.position = Vector2(8, 9)
		icon.size = Vector2(56, 56)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		merchant_icons.append(icon)
		var kicker := make_label(button, "", 11, Rect2(76, 6, 292, 18), HORIZONTAL_ALIGNMENT_LEFT, Color("#c7b18b"))
		var title := make_label(button, "", 14, Rect2(76, 23, 292, 30), HORIZONTAL_ALIGNMENT_LEFT, Color("#edf0f7"))
		var effect := make_label(button, "", 11, Rect2(76, 55, 292, 19), HORIZONTAL_ALIGNMENT_LEFT, Color("#bfcbe0"))
		for label in [kicker, title, effect]:
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.clip_text = true
		merchant_visuals.append({"kicker":kicker, "name":title, "effect":effect})
	merchant_panel.position.y=68;merchant_panel.size.y = 766
	merchant_detail = LootlingsUI.rich_label(merchant_panel,Rect2(24,354,376,270),13,Color("#c9d6e9"));merchant_detail.scroll_active=true
	merchant_buy_button = make_action_button(merchant_panel,"SELECT AN OFFER",Vector2(20,634),Vector2(384,50),Color("#49346b"),Color("#ffe178"),buy_selected_merchant)
	merchant_buy_button.set_meta("ui_intent","primary")
	apply_button_style(merchant_buy_button,Color("#49346b"),Color("#ffe178"))
	merchant_buy_button.disabled = true
	merchant_reroll_button = make_action_button(merchant_panel, "REROLL", Vector2(20, 702), Vector2(180, 48), Color("#3e315c"), Color("#c89bff"), func(): touch_ux.request("Replace these offers?","One free redraw per stop. All three current offers will be replaced.",reroll_merchant))
	merchant_continue_button = make_action_button(merchant_panel, "SKIP", Vector2(224, 702), Vector2(180, 48), Color("#295d50"), Color("#69e6b0"), leave_merchant)

func build_boss_reward_ui() -> void:
	boss_reward_panel = make_panel(Rect2(20, 115, 440, 630), Color("#17142ff8"))
	LootlingsUI.apply_material(boss_reward_panel, "hoard")
	boss_reward_panel.visible = false
	boss_reward_heading = make_label(boss_reward_panel, "BOSS HOARD", 30, Rect2(20, 18, 400, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffd36a"))
	make_label(boss_reward_panel, "Inspect a reward, then confirm one", 16, Rect2(20, 64, 400, 30), HORIZONTAL_ALIGNMENT_CENTER, Color("#d9c9ff"))
	for i in range(3):
		var button := Button.new()
		button.position = Vector2(25, 112 + i * 130)
		button.size = Vector2(390, 108)
		button.add_theme_font_size_override("font_size", 15)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(inspect_boss_reward.bind(i))
		boss_reward_panel.add_child(button)
		boss_reward_buttons.append(button)
		var icon := ItemIcon.new()
		icon.position = Vector2(8, 8)
		icon.size = Vector2(88, 88)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		boss_reward_icons.append(icon)
		var kicker := make_label(button, "", 13, Rect2(112, 6, 266, 23), HORIZONTAL_ALIGNMENT_LEFT, Color("#d9c9ff"))
		var title := make_label(button, "", 16, Rect2(112, 27, 266, 38), HORIZONTAL_ALIGNMENT_LEFT, Color("#fff1cd"))
		var effects := make_label(button, "", 13, Rect2(112, 66, 266, 36), HORIZONTAL_ALIGNMENT_LEFT, Color("#e0e9ff"))
		for label in [kicker, title, effects]:
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.clip_text = true
		boss_reward_visuals.append({"kicker":kicker, "name":title, "effects":effects})
	boss_reward_footer = make_label(boss_reward_panel, "Choose one reward to carry home.", 14, Rect2(24, 510, 392, 28), HORIZONTAL_ALIGNMENT_CENTER, Color("#b9c8e5"))
	boss_reward_leave_button = make_action_button(boss_reward_panel,"KEEP CURRENT / LEAVE FINDS",Vector2(25,552),Vector2(390,54),Color("#172442"),Color("#9aafc5"),skip_boss_rewards)

func build_hoard_chest_ui() -> void:
	hoard_chest_button = make_action_button(self, "OPEN HOARD CHEST", Vector2(HOARD_CHEST_X-115, 411), Vector2(230, 184), Color("#6b431d"), Color("#ffd36a"), open_hoard_chest)
	for font_state in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color"]:
		hoard_chest_button.add_theme_color_override(font_state,Color.TRANSPARENT)
	var chest_hint:=make_label(hoard_chest_button,"Open the chest  ›",16,Rect2(0,158,230,26),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe39a"))
	chest_hint.mouse_filter=Control.MOUSE_FILTER_IGNORE
	hoard_chest_button.tooltip_text="Open this chest and reveal its three finds."
	for state_name in ["normal","hover","pressed","focus","disabled"]:
		hoard_chest_button.add_theme_stylebox_override(state_name,StyleBoxEmpty.new())
	hoard_chest_button.visible = false

func make_action_button(parent: Node, text_value: String, pos: Vector2, button_size: Vector2, fill: Color, border: Color, callback: Callable) -> Button:
	var button := Button.new()
	button.set_meta("gesture_release_owned",true)
	button.text = text_value
	button.position = pos
	button.size = button_size
	button.add_theme_font_size_override("font_size", 18)
	apply_button_style(button, fill, border)
	button.pressed.connect(callback)
	# Weapon release/contact is the attack feedback; avoid a layered menu click.
	if text_value!="ATTACK":button.pressed.connect(play_audio_event.bind("ui_press"))
	parent.add_child(button)
	return button

func apply_button_style(button: Button, fill: Color, border: Color) -> void:
	LootlingsUI.apply_button(button, fill, border)

func make_panel(rect: Rect2, color: Color) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", LootlingsUI.panel_style(color))
	add_child(panel)
	return panel

func make_label(parent: Node, text_value: String, size_value: int, rect: Rect2, alignment: HorizontalAlignment, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", size_value)
	preload("res://lootlings_typography.gd").label(label,size_value)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func fit_label_font(label: Label, text_value: String, max_width: float, preferred_size: int = 27, minimum_size: int = 18) -> int:
	var fitted_size := preferred_size
	while fitted_size > minimum_size and body_font.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, fitted_size).x > max_width:
		fitted_size -= 1
	label.add_theme_font_size_override("font_size", fitted_size)
	return fitted_size

func start_run() -> void:
	if retention.rift_pending and dungeon.active:
		var token: String="entry:%d:%d" % [Time.get_unix_time_from_system(),Time.get_ticks_usec()]
		if not preload("res://rift_progress.gd").enter(self,token):
			retention.rift_pending=false;retention.rift_active=false;dungeon.active=false;show_hideout();return
		retention.rift_pending=false;retention.rift_active=true
	else:retention.rift_active=false;retention.rift_pending=false
	combat_companion.initialized=false
	combat_companion.reaction_timer=0
	forced_facing_test = 0
	enemy_stage_x = ENEMY_X
	run_resolved=false
	retention.begin()
	expedition_progress.begin_run(campaign_id,expedition_tier,int(hash("farm:%s:%d" % [campaign_id,rng.seed])))
	proc_timer = 0.0; proc_texture = null
	character_trait = CharacterTraits.definition(profile)
	player_ward = 0.0; survived_hits = 0
	delayed_hits.clear(); signature_targets.clear()
	cache_hit_primed = false; boss_recovery = 0.0; boss_phase = 1
	event_seen.clear(); event_due = false; event_id = ""
	event_risk = 1.0; event_power = 1.0
	wave_composition_wave = -1; wave_composition.clear()
	loot_system.reset_run(campaign_id)
	if event_panel != null: event_panel.visible = false
	combat_presentation.reset()
	if presentation_director != null: presentation_director.vignette.cancel()
	story_run_presentations = false # Direct deterministic harnesses omit UI stings.
	enemy_encounter.clear()
	loot_system.region_pool = CampaignSystem.LOOT_POOLS.get(campaign_id, []).duplicate()
	loot_system.region_pool.append_array(Phase4.FARMS[campaign_id].items)
	award_achievement("first_steps")
	state = "playing"
	if startup_ui != null:
		startup_ui.visible = false
	if hideout_ui != null:
		hideout_ui.visible = false
	if pause_button != null:
		pause_button.visible = true
		pause_panel.visible = false
		abandon_panel.visible = false
	wave = 1
	wave_kills = 0
	last_spawned_wave = 0
	current_zone = run_zone_for_wave(wave)
	current_zone_id = current_zone.id
	pending_zone_transition = false
	zone_transition_timer = 0.0
	special_intro_timer = 0.0
	special_intro_wave = 0
	total_kills = 0
	last_lantern_spent = false
	coins = 0
	level = 1
	xp = 0.0
	xp_needed = 32.0
	pending_levels = 0
	run_time = 0.0
	player_x = PLAYER_HOME_X
	player_facing = 1
	var meta_bonus := 1.0 + float(meta_power) * 0.05
	equipment_hp_bonus = inventory.effect_total("max_hp")
	player_max_hp = maxf(40.0, 100.0 * meta_bonus + equipment_hp_bonus + int(gold_upgrades.get("bedroll", 0)) * 4.0)
	player_max_hp += int(character_trait.hp) + preload("res://permanent_upgrade_catalog.gd").heart(int(gold_upgrades.get("heartprism",0)))
	player_hp = player_max_hp
	base_damage = 11.0 * meta_bonus + int(gold_upgrades.get("whetstone", 0)) * 0.6
	coins = 0 # No normal expedition wallet.
	attack_interval = 0.85
	attack_clock = 0.3
	crit_chance = 0.08 + preload("res://permanent_upgrade_catalog.gd").keen(int(gold_upgrades.get("keenprism",0)))
	crit_mult = 2.0
	multi_hits = 1
	splash_ratio = 0.0
	life_steal = 0.0
	armor = preload("res://permanent_upgrade_catalog.gd").armour(int(gold_upgrades.get("wardweave",0)))
	player_ward = float(gold_upgrades.get("hearthward",0)) + preload("res://permanent_upgrade_catalog.gd").aegis(int(gold_upgrades.get("aegisprism",0)))
	frenzy = 0.0
	tap_mult = 0.65
	tap_buffer_timer = 0.0
	tap_input_cooldown = 0.0
	tap_buffer_flash = 0.0
	tap_tutorial_seen = false
	execute_ratio = 0.0
	regen_per_second = preload("res://permanent_upgrade_catalog.gd").regeneration(int(gold_upgrades.get("mending",0)))
	coin_reward_mult = 1.0
	xp_reward_mult = 1.0
	carried_shockwave = 0.0
	selected_upgrades.clear()
	upgrade_counts.clear()
	build.reset()
	attack_sequence = 0
	heavy_power = 0
	storm_power = 0
	ignite_power = 0
	wildfire_power = 0
	venom_power = 0
	plague_power = 0
	preload("res://combat_numbers.gd").clear(self)
	particles.clear()
	reward_pickups.clear()
	loot_drops.clear()
	pending_items.clear()
	current_item.clear()
	boss_reward_options.clear()
	normal_loot_choice = false
	hoard_chest_phase = ""
	hoard_chest_timer = 0.0
	if hoard_chest_button != null:
		hoard_chest_button.visible = false
	pending_victory = false
	run_won = false
	merchant_due = false
	item_review_due = false
	return_to_merchant = false
	shop.stock.clear()
	shop.rerolls = 0
	attack_anim = 0.0
	attack_was_tap = false
	player_idle_reaction = 0.0
	player_idle_reaction_clock = visual_rng.randf_range(2.6, 5.2)
	enemy_attack_anim = 0.0
	enemy_recoil = 0.0
	enemy_death_anim = 0.0
	crit_flash = 0.0
	element_flash = 0.0
	death_burst = 0.0
	hit_stop_timer = 0.0
	coin_counter_flash = 0.0
	xp_counter_flash = 0.0
	player_reward_flash = 0.0
	rarity_reveal_flash = 0.0
	wave_banner_text = "WAVE 1"
	wave_banner_color = Color("#8fdcff")
	wave_banner_timer = 1.25
	upgrade_panel.visible = false
	result_panel.visible = false
	item_panel.visible = false
	merchant_panel.visible = false
	boss_reward_panel.visible = false
	help_label.visible = true
	run_shards_earned = 0
	run_gold_earned = 0
	run_coins_earned = 0
	run_coins_spent = 0
	run_damage_taken = 0.0
	run_start_scrap = inventory.scrap
	run_kept_loot.clear()
	run_notable_items.clear()
	status_message = ""
	status_clock = 0.0
	if dungeon.active:
		rng.seed = dungeon.seed_value
		tap_combo = 0
		combo_clock = 0.0
		loot_system.rng.seed = dungeon.seed_value ^ 0x6c00
		seed(dungeon.seed_value ^ 0x7100)
		enemy_alive = false
		show_route_choices()
	else:
		spawn_enemy()
	play_audio_event("menu_close")
	if audio_manager != null:
		audio_manager.set_music("OUTER_RUINS")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "run_start", {"run_version":1, "zone_id":current_zone_id})
	queue_redraw()

func spawn_enemy() -> void:
	if retention.rift_active and dungeon.active and dungeon.room.get("kind","") in ["Elite","Boss"]:
		spawn_single_enemy();return
	enemy_encounter.clear()
	var encounter: Dictionary = ZoneCatalog.encounter_for(run_zone_for_wave(wave), wave, wave_kills, grouped_patrols or dungeon.active)
	if encounter.members.size() > 1:
		enemy_encounter.begin(self, mini(encounter.members.size(), ENEMIES_PER_WAVE))
	else:
		spawn_single_enemy()

func spawn_single_enemy() -> void:
	enemy_weapon_opening_used = false
	enemy_trait_opening_used = false; enemy_trait_crit_used = false
	enemy_status_ward_used = false; enemy_chime_primed = false
	enemy_control_budget = 0.5
	boss_recovery = 0.0; boss_phase = 1
	enemy_serial += 1
	combat_presentation.register_enemy(enemy_serial)
	attack_projectiles.clear()
	projectile_impacts.clear()
	var new_wave := wave != last_spawned_wave
	current_zone = run_zone_for_wave(wave)
	current_zone_id = current_zone.id
	if new_wave:
		AnalyticsLogger.log_event(ANALYTICS_PATH, "zone_enter", {"zone_id":current_zone_id, "wave":wave})
		if audio_manager != null:
			var music_region: String = current_zone.get("future_music", "outer_ruins")
			pass # Select below after actual mode boss flags are established.
	enemy_is_miniboss = wave == 8
	enemy_is_boss = wave == RUN_LAST_WAVE
	if retention.rift_active and dungeon.active:
		enemy_is_miniboss = dungeon.room.get("kind","")=="Elite"
		enemy_is_boss = dungeon.room.get("kind","")=="Boss"
	if retention.siege:
		enemy_is_boss=retention.round_rule.boss; enemy_is_miniboss=retention.round_rule.miniboss
	if audio_manager!=null:
		var music_region: String=current_zone.get("future_music","outer_ruins")
		audio_manager.set_music(preload("res://region_audio.gd").combat_cue(campaign_id,music_region,enemy_is_boss))
	# Steady curve with explicit special-enemy spikes; regular archetypes stay closer together.
	var progress := pow(1.15, (mini(15,wave) if retention.siege else wave) - 1)
	var type_bonus := 1.0
	if enemy_is_boss:
		type_bonus = 4.8
		enemy_name = "THE HOARD DRAGON" if campaign_id == "act_i" else current_zone.boss
	elif enemy_is_miniboss:
		type_bonus = 2.65
		enemy_name = "GRUMP KNIGHT" if campaign_id == "act_i" else current_zone.miniboss
	else:
		if wave_composition_wave != wave:
			wave_composition_wave = wave
			wave_composition = ZoneCatalog.composition_for(current_zone,wave).duplicate()
			# Two weighted patterns retain the local role budget; the third trades
			# a caster for a scrapper. Never stack three casters or tanks.
			var pattern := rng.randf()
			if pattern < 0.65:
				# Sound variation uses the global RNG. Encounter order must use
				# the seeded combat stream, so audio cannot alter the enemies.
				for i in range(wave_composition.size() - 1, 0, -1):
					var other := rng.randi_range(0, i)
					var role = wave_composition[i]
					wave_composition[i] = wave_composition[other]
					wave_composition[other] = role
			elif pattern < 0.82: wave_composition = ["skirmisher","skirmisher","tank"]
		enemy_archetype = str(wave_composition[clampi(wave_kills,0,2)])
		if dungeon.active and not dungeon.room.is_empty():
			enemy_archetype = dungeon.room.members[clampi(wave_kills, 0, dungeon.room.members.size() - 1)]
		var enemy_definition := ZoneCatalog.enemy_for(current_zone, enemy_archetype)
		enemy_name = enemy_definition.name
	enemy_max_hp = (24.0 + (mini(15,wave) if retention.siege else wave) * 7.0) * progress * type_bonus
	enemy_damage = (3.5 + wave * 0.92) * (1.3 if enemy_is_miniboss else 1.0) * (1.55 if enemy_is_boss else 1.0)
	enemy_damage *= event_risk
	enemy_attack_interval = maxf(0.85, 2.25 - wave * 0.045)
	enemy_hit_multiplier = 1.0
	enemy_variant_id = ""
	enemy_variant_name = ""
	enemy_variant_color = Color.TRANSPARENT
	enemy_reward_multiplier = 1.0
	enemy_xp_multiplier = 1.0
	if not enemy_is_boss and not enemy_is_miniboss:
		match enemy_archetype:
			"skirmisher":
				enemy_max_hp *= 0.86
				enemy_attack_interval *= 0.62
				enemy_damage *= 0.72
			"tank":
				enemy_max_hp *= 1.48
				enemy_attack_interval *= 1.28
				enemy_damage *= 0.9
				enemy_hit_multiplier = 0.82
			"hexer":
				enemy_max_hp *= 0.9
				enemy_attack_interval *= 1.08
				enemy_damage *= 0.88
		enemy_post_guard_hit_multiplier = enemy_hit_multiplier
		enemy_variant_id = EnemyVariantCatalog.roll(rng, wave, false, current_zone_id)
		if expedition_tier > 0 and wave >= 3 and wave_kills < expedition_tier:
			enemy_variant_id = CampaignSystem.REGIONAL_VARIANTS.get(campaign_id,"armoured")
		if expedition_tier == 2: enemy_attack_interval *= .92
		# New regions showcase an existing readable mechanic on one patrol every
		# third wave. Bosses/Act I are untouched; no presentation RNG is consumed.
		if CampaignSystem.REGIONAL_VARIANTS.has(campaign_id) and wave % 3 == 0 and wave_kills == 0:
			enemy_variant_id = CampaignSystem.REGIONAL_VARIANTS[campaign_id]
		if retention.siege:
			var selected: String=retention.elite_id()
			if not selected.is_empty(): enemy_variant_id=selected
		if not enemy_variant_id.is_empty():
			var variant := EnemyVariantCatalog.definition(enemy_variant_id)
			var modified := EnemyVariantCatalog.apply(enemy_variant_id, {"hp":enemy_max_hp, "damage":enemy_damage, "interval":enemy_attack_interval, "hit":enemy_hit_multiplier})
			enemy_max_hp = float(modified.hp)
			enemy_damage = float(modified.damage)
			enemy_attack_interval = float(modified.interval)
			enemy_hit_multiplier = float(modified.hit)
			enemy_reward_multiplier = float(modified.coin)
			enemy_xp_multiplier = float(modified.xp)
			enemy_variant_name = str(variant.name)
			enemy_variant_color = variant.accent
			enemy_name = "%s %s" % [enemy_variant_name, enemy_name]
	# Keep temporary power income independent of forced tier pressure.
	if retention.siege:
		enemy_attack_interval=maxf(.65,enemy_attack_interval/(1.0+maxi(0,wave-10)*.025))
		enemy_reward_multiplier=1.0; enemy_xp_multiplier=.50
	elif expedition_tier>0 and wave>=3 and wave_kills<expedition_tier:
		enemy_reward_multiplier=minf(1.0,enemy_reward_multiplier); enemy_xp_multiplier=minf(1.0,enemy_xp_multiplier)
	enemy_max_hp *= float(current_zone.get("hp_scale", 1.0))
	if dungeon.active:
		if enemy_is_boss:
			enemy_max_hp *= 0.25
			enemy_damage *= 0.40
		elif enemy_is_miniboss and dungeon.depth <= 2:
			enemy_max_hp *= 0.65
			enemy_damage *= 0.80
		elif dungeon.room.get("kind", "") == "Risk":
			enemy_damage *= 1.10
	enemy_attack_interval *= float(current_zone.get("interval_scale", 1.0))
	enemy_hp = enemy_max_hp
	enemy_hit_multiplier *= event_power
	event_risk = 1.0; event_power = 1.0
	enemy_attack_clock = enemy_attack_interval
	enemy_attack_count = 0
	enemy_first_crit_used = false
	enemy_frostbell_used = false
	enemy_variant_guarded = enemy_variant_id == "rootbound"
	enemy_burn_dps = 0.0
	enemy_burn_time = 0.0
	enemy_poison_stacks = 0
	enemy_poison_time = 0.0
	dot_tick_clock = 0.35
	enemy_alive = true
	spawn_clock = 0.0
	enemy_entry_anim = 0.55 if enemy_is_boss or enemy_is_miniboss else 0.24
	enemy_attack_anim = 0.0
	enemy_death_anim = 0.0
	if last_spawned_wave == 0 or enemy_is_boss or enemy_is_miniboss:
		player_x = minf(player_x, PLAYER_HOME_X + 30.0)
	elif new_wave:
		player_x = minf(player_x, PLAYER_HOME_X + 48.0)
	else:
		player_x = maxf(PLAYER_HOME_X + 30.0, player_x - 26.0)
	attack_clock = minf(0.34, current_attack_interval() * 0.45)
	last_spawned_wave = wave
	if carried_shockwave > 0.0:
		var opening_damage := minf(carried_shockwave, enemy_hp * 0.55)
		enemy_hp -= opening_damage
		add_float("SHOCKWAVE %.0f" % opening_damage, Vector2(350, 405), Color("#8fe7ff"), 18)
		carried_shockwave = 0.0

func begin_zone_transition() -> void:
	pending_zone_transition = false
	current_zone = run_zone_for_wave(wave)
	current_zone_id = current_zone.id
	zone_transition_title = current_zone.entry
	zone_transition_subtitle = current_zone.name
	zone_transition_timer = 0.85
	state = "zone_transition"
	player_x = PLAYER_HOME_X
	enemy_death_anim = 0.0
	wave_banner_timer = 0.0
	status_clock = 0.0
	help_label.visible = false
	play_audio_event("zone_transition")
	wave_banner_text=zone_transition_subtitle.to_upper();wave_banner_color=current_zone.accent;wave_banner_timer=1.2

func begin_special_intro() -> void:
	state = "special_intro"
	special_intro_timer = 0.80
	current_zone = run_zone_for_wave(wave)
	current_zone_id = current_zone.id
	enemy_alive = false
	enemy_death_anim = 0.0
	player_x = minf(player_x, PLAYER_HOME_X + 34.0)
	wave_banner_text = "FINAL WAVE" if wave == RUN_LAST_WAVE else "MINIBOSS AHEAD"
	wave_banner_color = Color("#ffb154") if wave == RUN_LAST_WAVE else Color("#d49cff")
	wave_banner_timer = 0.80
	status_clock = 0.0
	help_label.visible = false
	if story_run_presentations:
		var story_id := "boss/grump_knight" if campaign_id == "act_i" and wave == 8 else "boss/hoard_dragon" if campaign_id == "act_i" else "boss/verdant_mirror" if campaign_id == "mossglass_wilds" and wave == RUN_LAST_WAVE else "boss/furnace_regent" if campaign_id == "cinder_crown" and wave == RUN_LAST_WAVE else ""
		if not story_id.is_empty():
			discover_story(story_id, finish_story_boss_intro, true)
	# The illustrated sting owns its sound. Do not double the same SFX voice.
	if not presentation_director.vignette.active: play_audio_event("boss_warning")

func finish_story_boss_intro() -> void:
	if state != "special_intro": return
	special_intro_wave = wave
	wave_banner_timer = 0
	state = "playing"
	spawn_enemy()

func _process(delta: float) -> void:
	if state=="playing" and profile.get("companion",{}).get("accompany",false) and not str(profile.get("companion",{}).get("equipped_id","")).is_empty():
		var companion_owner:=Vector2(WeaponFit.world_position(self).x,preload("res://combat_stage.gd").GROUND_Y)
		combat_companion.update(delta,companion_owner,Vector2(-100*combat_facing(),0))
		combat_companion.position.x=clampf(combat_companion.position.x,30,450)
	proc_timer = maxf(0.0,proc_timer-delta)
	if presentation_director != null and presentation_director.vignette.active:
		if pause_button != null: pause_button.visible = false
		queue_redraw()
		return
	if pause_button != null:
		pause_button.visible = state == "playing"
	if state == "paused" or state == "abandon_confirm":
		queue_redraw()
		return
	var visual_delta := delta
	if hit_stop_timer > 0.0:
		hit_stop_timer = maxf(0.0, hit_stop_timer - delta)
		visual_delta *= 0.12
	update_effects(visual_delta)
	if state == "hoard_chest":
		update_hoard_chest(delta)
		queue_redraw()
		return
	if state == "zone_transition":
		zone_transition_timer = maxf(0.0, zone_transition_timer - delta)
		if zone_transition_timer <= 0.0:
			state = "playing"
			spawn_enemy()
		queue_redraw()
		return
	if state == "special_intro":
		special_intro_timer = maxf(0.0, special_intro_timer - delta)
		if special_intro_timer <= 0.0:
			special_intro_wave = wave
			wave_banner_timer = 0.0
			state = "playing"
			spawn_enemy()
		queue_redraw()
		return
	if state != "playing":
		queue_redraw()
		return
	run_time += delta
	boss_recovery = maxf(0.0,boss_recovery-delta)
	enemy_control_budget = minf(0.5,enemy_control_budget+delta*0.25)
	for hit in delayed_hits.duplicate():
		hit.time -= delta
		if hit.time <= 0:
			delayed_hits.erase(hit)
			if enemy_encounter.active: enemy_encounter.resolve_echo(self,int(hit.serial),float(hit.power))
			elif enemy_alive and int(hit.serial) == enemy_serial: deal_elemental_hit(float(hit.power),"Physical")
	tap_input_cooldown = maxf(0.0, tap_input_cooldown - delta)
	tap_buffer_timer = maxf(0.0, tap_buffer_timer - delta)
	status_clock = maxf(0.0, status_clock - delta)
	combo_clock -= delta
	if combo_clock <= 0.0:
		tap_combo = 0
	player_hp = minf(player_max_hp, player_hp + regen_per_second * delta)
	if enemy_alive and enemy_is_boss and boss_phase == 1 and enemy_hp / enemy_max_hp <= .5:
		boss_phase = 2
		add_float("SECOND PHASE",Vector2(270,350),Color("#ffc77a"),18)
	if not enemy_alive:
		# Never replace a defeated foe while its visible loot reveal is still resolving.
		if not loot_drops.is_empty():
			queue_redraw()
			return
		if loot_drops.is_empty() and item_review_due:
			if not boss_reward_options.is_empty():
				show_boss_reward()
				queue_redraw()
				return
			if not pending_items.is_empty():
				if pending_items.size() > 1:
					normal_loot_choice = true
					boss_reward_options = pending_items.duplicate(true)
					if boss_reward_options.size() > 3:
						boss_reward_options.sort_custom(func(a,b): return ItemCatalog.rarity_rank(a.rarity) > ItemCatalog.rarity_rank(b.rarity))
						boss_reward_options = boss_reward_options.slice(0,3)
					pending_items.clear()
					show_boss_reward()
				else: show_next_item()
				queue_redraw()
				return
			item_review_due = false
		if loot_drops.is_empty() and pending_victory:
			end_run(true)
			queue_redraw()
			return
		if loot_drops.is_empty() and merchant_due:
			show_merchant()
			queue_redraw()
			return
		if event_due and not dungeon.active:
			show_expedition_event()
			return
		if dungeon.active and dungeon.room_finished:
			show_route_choices()
			queue_redraw()
			return
		if pending_zone_transition:
			begin_zone_transition()
			queue_redraw()
			return
		spawn_clock -= delta
		if spawn_clock <= 0.0:
			if not retention.siege and wave in [8, RUN_LAST_WAVE] and special_intro_wave != wave:
				begin_special_intro()
			else:
				spawn_enemy()
		queue_redraw()
		return
	var attack_position := target_player_x()
	if enemy_encounter.active:
		enemy_encounter.step(self, delta)
		queue_redraw()
		return
	if player_x < attack_position:
		player_x = minf(attack_position, player_x + 155.0 * float(character_trait.get("move",1.0)) * delta)
		if enemy_archetype == "hexer" and not enemy_is_boss and not enemy_is_miniboss:
			enemy_attack_clock -= delta
			if enemy_attack_clock <= 0.0:
				enemy_attack_clock += enemy_attack_interval
				perform_enemy_attack(0.62)
		if player_x >= attack_position and tap_buffer_timer > 0.0:
			tap_buffer_timer = 0.0
			perform_player_attack(true)
	else:
		attack_clock -= delta
		if attack_clock <= 0.0:
			attack_clock += current_attack_interval()
			perform_player_attack(false)
		enemy_attack_clock -= delta
		if enemy_attack_clock <= 0.0:
			enemy_attack_clock += enemy_attack_interval
			perform_enemy_attack()
	update_elemental_damage(delta)
	queue_redraw()

func comparison_weapon_family(gear) -> String:
	return debug_weapon_family_override if debug_enabled and not debug_weapon_family_override.is_empty() else gear.weapon_family()

func current_attack_interval(gear: Variant=null, health: float=-1, max_health: float=-1) -> float:
	var equipment=inventory if gear==null else gear
	var hp:float=player_hp if health<0 else health
	var hp_max:float=player_max_hp if max_health<0 else max_health
	var result := attack_interval
	match comparison_weapon_family(equipment):
		"RANGER": result *= 0.78
		"MAGE": result *= 0.95
		"ROGUE": result *= 0.68
		_: result *= 1.18
	result *= 1.0 + equipment.effect_total("attack_slow")
	result /= 1.0 + equipment.effect_total("attack_speed")
	if frenzy > 0.0:
		result /= 1.0 + frenzy * (1.0 - hp / hp_max)
	if equipment.has_signature("desperate_rhythm") and hp / maxf(1.0, hp_max) < 0.40:
		result /= 1.12
	return maxf(0.16, result)

func target_player_x() -> float:
	if current_weapon_family() in ["RANGER", "MAGE"]:
		return 162.0
	if enemy_encounter.active:
		return 186.0 if enemy_encounter.actors.size() == 2 else 174.0
	if enemy_is_boss:
		return 184.0
	if enemy_is_miniboss:
		return 198.0
	if enemy_archetype == "tank":
		return 212.0
	return 222.0

func request_tap_attack() -> void:
	if state != "playing" or input_surface()!=null or not enemy_alive or tap_input_cooldown > 0.0:
		return
	tap_input_cooldown = 0.11
	if player_x < target_player_x() - 4.0:
		tap_buffer_timer = 0.45
		tap_buffer_flash = 0.18
		tap_pulse = maxf(tap_pulse, 0.10)
		queue_redraw()
		return
	perform_player_attack(true)

func effective_crit_chance(gear: Variant=null) -> float:
	var equipment=inventory if gear==null else gear
	var family_bonus := 0.10 if comparison_weapon_family(equipment) == "ROGUE" else 0.06 if comparison_weapon_family(equipment) == "RANGER" else 0.0
	return minf(0.85, crit_chance + equipment.effect_total("crit") + family_bonus)

func equipment_damage_multiplier(gear: Variant=null, health: float=-1, max_health: float=-1) -> float:
	var equipment=inventory if gear==null else gear
	var hp:float=player_hp if health<0 else health
	var hp_max:float=player_max_hp if max_health<0 else max_health
	var result: float = 1.0 + equipment.effect_total("damage_mult")
	if hp / hp_max < 0.4:
		result += equipment.effect_total("low_health_damage")
	if enemy_is_boss:
		result += equipment.effect_total("boss_damage")
	match comparison_weapon_family(equipment):
		"VANGUARD": result *= 1.18
		"RANGER": result *= 0.82
		"MAGE": result *= 0.95
		"ROGUE": result *= 0.72
	return result

func perform_player_attack(is_tap: bool) -> void:
	if state != "playing" or not enemy_alive or player_x < target_player_x() - 4.0:
		return
	if is_tap:
		tap_tutorial_seen = true
		help_label.visible = false
	var family := current_weapon_family()
	var sound_weapon: String = str(inventory.equipped_item("Weapon").get("weapon_type","greatsword"))
	play_audio_event("swing_"+sound_weapon)
	if attack_sequence % 5 == 0 and family in ["VANGUARD","ROGUE"]: play_character_voice("attack",true)
	if family in ["RANGER", "MAGE"]:
		var travel_time := 0.12 if family == "RANGER" else 0.17
		var subtype: String = inventory.equipped_item("Weapon").get("weapon_type", "")
		var weapons = preload("res://weapon_catalog.gd")
		if weapons.STARTERS.has(subtype) and not str(weapons.FAMILIES[subtype].projectile).is_empty():
			var projectile_profile: Dictionary = weapons.PROJECTILES[weapons.FAMILIES[subtype].projectile]
			travel_time *= (860.0 if family == "RANGER" else 520.0) / float(projectile_profile.speed)
		if is_tap:
			travel_time *= 0.82
		attack_anim = 0.22
		attack_was_tap = is_tap
		squash = 0.12
		var launch_position := WeaponFit.projectile_origin(self)
		attack_projectiles.append({
			"family": family,
			"weapon_type": subtype,
			"element": ProjectilePresentation.identity(self),
			"is_tap": is_tap,
			"pos": launch_position,
			"start": launch_position,
			"target": target_combat_visual_position()+Vector2(-28*combat_facing(),-29),
			"life": travel_time,
			"max_life": travel_time,
			"enemy_serial": enemy_serial
		})
		return
	resolve_player_attack(is_tap)

func resolve_player_attack(is_tap: bool) -> void:
	if state != "playing" or not enemy_alive:
		return
	var aoe_origin := enemy_serial
	var evolution_opening := not enemy_weapon_opening_used
	var hit_count := 1 if is_tap else multi_hits + int(inventory.effect_total("extra_hits"))
	var damage_scale := tap_mult if is_tap else 1.0
	attack_sequence += 1
	var subtype: String = inventory.equipped_item("Weapon").get("weapon_type", "")
	if subtype == "greataxe" and attack_sequence % 3 == 0:
		damage_scale *= 1.45
	elif subtype == "spear" and not enemy_weapon_opening_used:
		damage_scale *= 1.30
		enemy_weapon_opening_used = true
	elif subtype == "claws":
		hit_count *= 2
		damage_scale *= 0.55
	elif subtype == "crossbow" and attack_sequence % 3 == 0:
		hit_count *= 2
		damage_scale *= 0.64
	elif subtype == "sling" and attack_sequence % 3 == 0:
		delay_enemy(0.18)
	elif subtype == "orb" and attack_sequence % 4 == 0:
		player_hp = minf(player_max_hp, player_hp + 2.0)
		add_particles(Vector2(player_x, 438), Color("#95d8ff"), 4)
	var physical_count: int = build.count("Physical")
	var heavy_interval := maxi(3, 7 - mini(physical_count + heavy_power, 4))
	var is_heavy := physical_count > 0 and attack_sequence % heavy_interval == 0
	if is_heavy:
		damage_scale *= 2.2 + inventory.effect_total("heavy_bonus")
	if is_tap:
		tap_combo += 1
		combo_clock = 0.7
		tap_pulse = 0.18
		damage_scale *= 1.0 + minf(tap_combo, 10) * 0.025
	for hit_index in range(hit_count):
		if not enemy_alive or enemy_serial != aoe_origin:
			break
		var is_crit := rng.randf() < effective_crit_chance()
		var damage := base_damage * damage_scale * equipment_damage_multiplier() * (crit_mult if is_crit else 1.0) * rng.randf_range(0.92, 1.08)
		var perk: String = str(character_trait.get("perk",""))
		if perk == "opening" and not enemy_trait_opening_used: damage *= 1.25
		if perk == "finish" and enemy_hp / enemy_max_hp < .35: damage *= 1.15
		if perk == "aim" and is_crit and not enemy_trait_crit_used:
			damage *= 1.30; enemy_trait_crit_used = true
		if is_tap and boss_recovery > 0: damage *= 1.15
		if cache_hit_primed:
			damage *= 1.40; cache_hit_primed = false
		enemy_trait_opening_used = true
		damage_enemy(damage, is_crit, is_tap, is_heavy and hit_index == 0)
		if enemy_alive and enemy_serial == aoe_origin and is_crit and inventory.effect_total("crit_lightning") > 0.0:
			deal_elemental_hit(base_damage * inventory.effect_total("crit_lightning"), "Lightning", true)
		if enemy_alive and enemy_serial == aoe_origin and is_crit and inventory.has_signature("first_crit_spark") and not enemy_first_crit_used:
			enemy_first_crit_used = true
			deal_elemental_hit(base_damage * 0.42, "Lightning", true)
		if hit_count > 1 and hit_index < hit_count - 1:
			add_particles(Vector2(337, 475), Color("#d6a8ff"), 3)
	var lightning_count: int = build.count("Lightning")
	var chain_interval := maxi(3, 6 - mini(lightning_count + storm_power, 3))
	if enemy_alive and enemy_serial == aoe_origin and lightning_count > 0 and attack_sequence % chain_interval == 0:
		var chain_damage := base_damage * (0.35 + lightning_count * 0.14) * (1.0 + (multi_hits - 1) * 0.18)
		deal_elemental_hit(chain_damage, "Lightning")
	if enemy_alive and enemy_serial == aoe_origin and current_weapon_family() == "MAGE":
		var repeat_every := maxi(3, int(inventory.effect_total("repeat_every"))) if inventory.effect_total("repeat_every") > 0.0 else 4
		if attack_sequence % repeat_every == 0:
			var spell_identity := build.dominant()
			if spell_identity == "Neutral":
				spell_identity = "Lightning"
			deal_elemental_hit(base_damage * 0.62, spell_identity)
	if enemy_alive and enemy_serial == aoe_origin and current_weapon_family() == "RANGER" and inventory.has_signature("crooked_volley") and attack_sequence % 5 == 0:
		deal_elemental_hit(base_damage * 0.34, "Lightning")
		add_float("CROOKED VOLLEY", Vector2(278, 367), Color("#a8dcff"), 16)
	apply_weapon_evolution(subtype, aoe_origin, evolution_opening)
	if enemy_alive and enemy_serial == aoe_origin:
		match str(character_trait.get("perk","")):
			"kindle":
				if attack_sequence % 4 == 0:
					enemy_burn_dps = maxf(enemy_burn_dps,base_damage*.12); enemy_burn_time = 2.0
			"stagger":
				if attack_sequence % 5 == 0: delay_enemy(.25)
			"encore":
				if attack_sequence % 6 == 0: deal_elemental_hit(base_damage*.35,"Lightning")
			"renew":
				if attack_sequence % 5 == 0: player_hp = minf(player_max_hp,player_hp+2)
		if inventory.has_signature("storm_receipt"):
			signature_targets[aoe_origin] = run_time
			for target in signature_targets.keys():
				if run_time-float(signature_targets[target]) > 4: signature_targets.erase(target)
			if signature_targets.size() >= 3:
				signature_targets.clear(); deal_elemental_hit(base_damage*.60,"Lightning")
	squash = 0.16
	if enemy_encounter.active and (current_weapon_family() == "MAGE" or is_heavy or build.count("Fire") >= 3):
		enemy_encounter.splash(self, base_damage * (0.32 if is_heavy else 0.22), "Physical" if is_heavy else build.dominant(), aoe_origin)
	attack_anim = 0.22
	attack_was_tap = is_tap

func apply_weapon_evolution(subtype: String, origin_serial: int, opening: bool) -> void:
	if state != "playing": return
	var item: Dictionary = inventory.equipped_item("Weapon")
	var stage := clampi(int(item.get("evolution_stage", 0)), 0, 2)
	var weapons = preload("res://weapon_catalog.gd")
	if stage == 0 or not weapons.EVOLUTION_TRAITS.has(subtype): return
	var evolution_data: Dictionary = weapons.EVOLUTION_TRAITS[subtype]
	if bool(evolution_data.get("opening", false)):
		if not opening: return
	elif attack_sequence % int(evolution_data.every) != 0: return
	if bool(evolution_data.get("low_hp", false)) and (enemy_serial != origin_serial or enemy_hp / maxf(1.0, enemy_max_hp) >= 0.35): return
	if evolution_data.has("heal"):
		player_hp = minf(player_max_hp, player_hp + float(evolution_data.heal[stage - 1]))
		add_particles(Vector2(player_x, 438), Color("#95d8ff"), 4)
	var identity := str(evolution_data.get("element", "Physical"))
	if identity == "Core":
		identity = build.dominant()
		if identity == "Neutral": identity = "Lightning"
	var extra := base_damage * float(evolution_data.damage[stage - 1]) if evolution_data.has("damage") else 0.0
	# Released attacks never redirect remaining hits/procs when their foe dies.
	if enemy_alive and enemy_serial == origin_serial:
		if evolution_data.has("slow"): delay_enemy(float(evolution_data.slow[stage - 1]))
		if extra > 0: deal_elemental_hit(extra, identity)
	if extra > 0 and bool(evolution_data.get("splash", false)) and enemy_encounter.active:
		enemy_encounter.splash(self, extra, identity, origin_serial)

func damage_enemy(amount: float, is_crit: bool, is_tap: bool, is_heavy: bool = false) -> void:
	combat_presentation.record_contact(self,is_crit,is_heavy)
	var chime_was_primed := enemy_chime_primed
	amount *= enemy_hit_multiplier
	var health_removed := minf(amount,maxf(0.0,enemy_hp))
	enemy_hp -= amount
	if enemy_hp > 0 and attack_sequence % (4 if enemy_is_boss else 3) == 0:
		play_character_voice("hurt",false)
	if (inventory.has_signature("frostbell_chime") or inventory.has_signature("frostbell_shatter")) and not enemy_frostbell_used:
		enemy_frostbell_used = true
		enemy_chime_primed = true
		delay_enemy(0.32)
		add_float("FROSTBELL", Vector2(300, 372), Color("#a8ecff"), 15)
		add_particles(Vector2(346, 442), Color("#a8ecff"), 6)
	if enemy_variant_guarded and enemy_hp / maxf(1.0, enemy_max_hp) <= 0.72:
		enemy_variant_guarded = false
		play_audio_event("ward")
		enemy_hit_multiplier = enemy_post_guard_hit_multiplier
		add_float("ROOT GUARD BROKEN", Vector2(275, 400), enemy_variant_color, 14)
		add_particles(Vector2(350, 468), enemy_variant_color, 7)
	enemy_flash = 0.13 if is_crit else 0.10
	enemy_squash = 0.16
	enemy_recoil = 40.0 if is_crit else 27.0 if is_heavy else 22.0 if is_tap else 15.0
	impact_flash = 0.12 if is_crit else 0.052
	crit_flash = 0.18 if is_crit else crit_flash
	screen_shake = 0.045 if is_heavy and is_crit else 0.0
	if is_crit or is_heavy:
		hit_stop_timer = maxf(hit_stop_timer, 0.038 if is_crit else 0.030)
	elif is_tap:
		hit_stop_timer = maxf(hit_stop_timer, 0.014)
	if audio_manager!=null:
		audio_manager.play_contact(str(inventory.equipped_item("Weapon").get("weapon_type","greatsword")),preload("res://regional_enemy_presentation.gd").material(self),is_crit,is_heavy)
	preload("res://combat_numbers.gd").add(self,health_removed,"critical" if is_crit else "heavy" if is_heavy else "Physical")
	add_particles(Vector2(342, 475), Color("#ffda69") if is_crit else Color("#b8efff"), 14 if is_crit else 7)
	var hp_before_leech := player_hp
	player_hp = minf(player_max_hp, player_hp + health_removed * life_steal)
	preload("res://combat_numbers.gd").add(self,player_hp-hp_before_leech,"heal",true)
	if is_heavy and inventory.has_signature("burden_bell"): delay_enemy(.25)
	if is_heavy and inventory.has_signature("aftershock_receipt") and delayed_hits.size() < 8:
		delayed_hits.append({"time":.18,"serial":enemy_serial,"power":base_damage*.25})
	if is_heavy and chime_was_primed and inventory.has_signature("frostbell_shatter"):
		enemy_chime_primed = false
		enemy_hp -= base_damage*.25*enemy_hit_multiplier
	carried_shockwave += amount * splash_ratio
	var fire_count: int = build.count("Fire")
	if fire_count > 0:
		var fire_bonus := 1.0 + inventory.effect_total("fire_damage")
		enemy_burn_dps = minf(base_damage * (1.5 + fire_count * 0.45) * fire_bonus, enemy_burn_dps + amount * (0.018 * fire_count + ignite_power * 0.025) * fire_bonus)
		enemy_burn_time = 3.2
	var poison_count: int = build.count("Poison")
	if poison_count > 0:
		enemy_poison_stacks = mini(4 + poison_count * 3, enemy_poison_stacks + 1 + venom_power + int(inventory.effect_total("poison_bonus")))
		enemy_poison_time = 5.0 * (1.0 + inventory.effect_total("poison_duration"))
	if not enemy_status_ward_used and (enemy_burn_time > 0 or enemy_poison_time > 0) and inventory.has_signature("bubble_bargain"):
		enemy_status_ward_used = true; player_ward = minf(15,player_ward+3)
	var effective_execute := execute_ratio + inventory.effect_total("execute")
	if effective_execute > 0.0 and enemy_hp > 0.0 and enemy_hp / enemy_max_hp <= effective_execute:
		add_float("RELIC", Vector2(355, 385), Color("#ff8bd8"), 16)
		enemy_hp = 0.0
	if enemy_hp <= 0.0:
		if is_crit and inventory.has_signature("critical_shelter"): player_ward = minf(15,player_ward+4)
		kill_enemy()

func delay_enemy(seconds: float) -> void:
	var accepted := minf(seconds,enemy_control_budget)
	enemy_control_budget -= accepted
	enemy_attack_clock += accepted

func restore_enemy_health(amount: float) -> void:
	# Resolve the original cap first; presentation never reports overhealing.
	var before := enemy_hp
	enemy_hp = minf(enemy_max_hp, enemy_hp + amount)
	preload("res://combat_numbers.gd").add(self, enemy_hp-before, "enemy_heal")

func perform_enemy_attack(damage_scale: float = 1.0) -> void:
	if not enemy_alive:
		return
	enemy_attack_anim = 0.18
	if enemy_is_boss or enemy_is_miniboss:
		var action := BossPatterns.next(self)
		combat_presentation.boss_action=str(action.text); combat_presentation.boss_action_time=.55
		var boss_cue: String=preload("res://boss_audio_identity.gd").event(campaign_id,str(action.text))
		if not boss_cue.is_empty(): play_audio_event(boss_cue)
		if enemy_is_boss or enemy_is_miniboss:
			match campaign_id:
				"mossglass_wilds":
					play_audio_event("verdant_"+{"THORN CAST":"thorn","ROOT SWEEP":"root","MIRROR CHARGE":"mirror","RECOVER":"recover"}.get(str(action.text),"recover"))
					if action.text == "MIRROR CHARGE": restore_enemy_health(minf(40,enemy_max_hp*.02))
				"moonfen":
					if action.text == "FEINT": player_x = maxf(PLAYER_HOME_X,player_x-12)
				"frostbell_hollows":
					if action.text == "CHIME": attack_clock += .20
				"sunken_gearworks":
					if action.text == "PRESSURE RISE": enemy_attack_clock += .20
				"cinder_crown":
					if action.text == "TRIBUTE FLARE":
						var tribute := mini(8,coins)
						coins -= tribute; run_coins_spent += tribute
				"starfall_archive":
					if action.text == "ERASE": tap_combo = 0
				"nullglass_expanse":
					if action.text == "REFRACT": restore_enemy_health(minf(30,enemy_max_hp*.015))
				"skyhook_bastion":
					if action.text == "REEL IN": player_x = maxf(PLAYER_HOME_X,player_x-10)
				"first_hoard":
					if action.text == "CLAIM": player_ward = maxf(0,player_ward-3)
				"act_i":
					if action.text == "TAIL SWEEP": player_x = maxf(PLAYER_HOME_X,player_x-8)
		damage_scale *= float(action.power)
		if action.recovery:
			enemy_attack_count += 1
			boss_recovery = minf(1.0,enemy_attack_interval*.65)
			add_float("RECOVERY • TAP OPENING",Vector2(270,350),Color("#88e7bb"),15)
			return
	enemy_attack_count += 1
	if enemy_variant_id == "regenerating" and enemy_attack_count % 3 == 0:
		restore_enemy_health(minf(12,enemy_max_hp*.025))
		add_float("REKNITTING",Vector2(310,370),enemy_variant_color,14)
	if not enemy_is_boss and not enemy_is_miniboss:
		play_audio_event({"skirmisher":"enemy_skirmisher", "tank":"enemy_tank", "hexer":"enemy_hexer"}.get(enemy_archetype, "enemy_skirmisher"))
	if enemy_archetype == "hexer" and not enemy_is_boss and not enemy_is_miniboss and enemy_attack_count % 3 == 0:
		play_audio_event("ward")
		var ward := enemy_max_hp * 0.07
		restore_enemy_health(ward)
		add_particles(Vector2(365, 465), Color("#b86cff"), 6)
		return
	if debug_enabled and debug_god_mode:
		add_float("BLOCKED", Vector2(135, 430), Color("#8fe7ff"), 15)
		return
	var style_armor := 0.04 if current_weapon_family() == "VANGUARD" else 0.0
	var effective_armor := armor + inventory.effect_total("armor") + style_armor
	var damage := enemy_damage * damage_scale * (1.0 - minf(effective_armor, 0.72))
	if enemy_variant_id == "enraged" and enemy_hp/enemy_max_hp < .35: damage *= 1.18
	damage *= 1.0+inventory.effect_total("incoming_mult")
	var perk: String = str(character_trait.get("perk",""))
	if perk == "veil" and enemy_attack_count == 1: damage *= .70
	if perk == "brace" and damage > 15: damage *= .85
	if enemy_variant_id == "overcharged" and enemy_attack_count % 3 == 0:
		damage *= 1.22
		add_float("SPARK SURGE", Vector2(250, 392), enemy_variant_color, 15)
		add_particles(Vector2(260, 448), enemy_variant_color, 7)
	if enemy_variant_id == "frostbitten" and enemy_attack_count % 3 == 0:
		attack_clock += 0.18
		add_float("FROST DELAY", Vector2(150, 405), enemy_variant_color, 14)
	play_character_voice("attack",false)
	var armour_blocked := damage * minf(effective_armor,0.72) / maxf(.28,1.0-minf(effective_armor,0.72))
	var hp_before_incoming := player_hp
	var absorbed := minf(player_ward,damage)
	player_ward -= absorbed; damage -= absorbed
	combat_presentation.record_incoming(self,absorbed,damage)
	player_hp -= damage
	if enemy_variant_id == "leeching" and damage > 0:
		restore_enemy_health(minf(6,damage*.35))
	if perk == "shelter" and player_hp > 0: player_hp = minf(player_max_hp,player_hp+2)
	survived_hits += 1
	play_character_voice("hurt",true)
	run_damage_taken += damage
	player_flash = 0.13
	screen_shake = 0.02 if damage<=0 else 0.08
	preload("res://combat_numbers.gd").add(self,armour_blocked,"armour",true)
	preload("res://combat_numbers.gd").add(self,absorbed,"ward",true)
	preload("res://combat_numbers.gd").add(self,minf(damage,maxf(0,hp_before_incoming)),"incoming",true)
	add_particles(Vector2(170, 478), Color("#ff768c"), 5)
	if player_hp <= 0.0 and inventory.has_signature("last_lantern") and not last_lantern_spent:
		last_lantern_spent = true
		player_hp = 1.0
		enemy_attack_clock += 1.0
		add_float("LAST LANTERN", Vector2(118, 380), Color("#ffd77a"), 20)
		add_particles(Vector2(170, 458), Color("#ffd77a"), 14)
		play_audio_event("rare_reveal")
		return
	if player_hp <= 0.0:
		player_hp = 0.0
		play_character_voice("death",true)
		end_run(false)
	elif survived_hits % 4 == 0 and inventory.has_signature("rooted_revenge"):
		deal_elemental_hit(base_damage*.30,"Poison")
		# The authored thorn motif distinguishes this specific retaliation.
		# Poison damage/audio/status identity and the four-hit rule stay intact.
		element_flash_identity = "Nature"

func deal_elemental_hit(amount: float, identity: String, critical: bool = false) -> void:
	if not enemy_alive:
		return
	play_audio_event({"Fire":"magic_fire","Lightning":"magic_lightning","Poison":"magic_poison"}.get(identity,"heavy_hit"))
	amount *= enemy_hit_multiplier
	var resolved_damage := minf(amount,maxf(0,enemy_hp))
	enemy_hp -= amount
	var color := build.color(identity)
	enemy_flash = 0.08
	enemy_recoil = 22.0
	impact_flash = 0.06
	element_flash = 0.24
	element_flash_color = color
	element_flash_identity = identity
	preload("res://combat_numbers.gd").add(self,resolved_damage,identity,false,critical)
	add_particles(Vector2(350, 455), color, 9)
	carried_shockwave += amount * 0.18 if build.count("Lightning") >= 5 else 0.0
	if enemy_hp <= 0.0:
		kill_enemy()

func update_elemental_damage(delta: float) -> void:
	if state != "playing" or not enemy_alive:
		return
	enemy_burn_time = maxf(0.0, enemy_burn_time - delta)
	enemy_poison_time = maxf(0.0, enemy_poison_time - delta)
	if enemy_burn_time <= 0.0:
		enemy_burn_dps = move_toward(enemy_burn_dps, 0.0, base_damage * delta)
	if enemy_poison_time <= 0.0:
		enemy_poison_stacks = 0
	dot_tick_clock -= delta
	if dot_tick_clock > 0.0:
		return
	dot_tick_clock += 0.4
	var total_dot := 0.0
	var burn_damage := 0.0
	var poison_damage := 0.0
	var hp_before_dot := enemy_hp
	if enemy_burn_dps > 0.0:
		burn_damage = enemy_burn_dps * 0.4 * enemy_hit_multiplier
		total_dot += burn_damage
		add_particles(Vector2(360, 446), build.color("Fire"), 2)
	if enemy_poison_stacks > 0:
		poison_damage = base_damage * 0.012 * build.count("Poison") * enemy_poison_stacks * enemy_hit_multiplier
		total_dot += poison_damage
		add_particles(Vector2(375, 480), build.color("Poison"), 2)
		if plague_power > 0:
			var siphon_ratio := minf(0.20, 0.10 + plague_power * 0.05)
			# Burn resolves first. Poison cannot leech HP that the tick never
			# removed, including damage beyond the target's remaining health.
			var poison_removed := minf(poison_damage,maxf(0.0,enemy_hp-(total_dot-poison_damage)))
			var hp_before_siphon := player_hp
			player_hp = minf(player_max_hp, player_hp + poison_removed * siphon_ratio)
			preload("res://combat_numbers.gd").add(self,player_hp-hp_before_siphon,"heal",true)
	if total_dot > 0.0:
		var burn_removed := minf(burn_damage,maxf(0,hp_before_dot))
		preload("res://combat_numbers.gd").add(self,burn_removed,"Fire_tick")
		preload("res://combat_numbers.gd").add(self,minf(poison_damage,maxf(0,hp_before_dot-burn_removed)),"Poison_tick")
		enemy_hp -= total_dot
		if enemy_hp <= 0.0:
			kill_enemy()

func kill_enemy() -> void:
	if profile.get("companion",{}).get("accompany",false):combat_companion.react("reward")
	enemy_alive = false
	spawn_clock = 0.90 if enemy_is_boss else 0.72 if enemy_is_miniboss else 0.48
	enemy_death_anim = 0.82 if enemy_is_boss else 0.68 if enemy_is_miniboss else 0.50
	impact_flash = 0.12
	death_burst = 0.90 if enemy_is_boss else 0.56 if enemy_is_miniboss else 0.46
	death_burst_color = Color("#b75cff") if enemy_is_boss else Color("#ffba55") if enemy_is_miniboss else Color("#ffcf72")
	enemy_hp = 0.0
	total_kills += 1
	if enemy_is_boss:retention.progress.earn_spin("boss")
	elif enemy_is_miniboss or not enemy_variant_id.is_empty():retention.progress.earn_spin("elite")
	if total_kills>=30:retention.progress.earn_spin("milestone")
	if str(character_trait.get("perk","")) == "scavenger" and total_kills % 5 == 0:
		add_xp(8)
	if str(character_trait.get("perk","")) == "advance": carried_shockwave += base_damage*.10
	contracts.record("kill")
	expedition_progress.record_kill(CharacterTraits.actor_id(profile),str(inventory.equipped_item("Weapon").get("weapon_type","greatsword")),enemy_name,enemy_variant_id,enemy_is_miniboss,enemy_is_boss)
	award_achievement("hundred_kills")
	award_achievement("thousand_kills")
	if not enemy_variant_id.is_empty():
		award_unique_achievement("variant_hunter", enemy_variant_id)
		if enemy_variant_id == "gilded":
			award_achievement("gilded_first")
		elif enemy_variant_id == "frostbitten":
			award_achievement("first_frostbitten")
	if enemy_is_miniboss:
		contracts.record("miniboss")
		award_achievement("first_miniboss")
	if enemy_is_boss:
		contracts.record("boss")
	if enemy_is_boss and campaign_id == "act_i":
		award_achievement("hoard_dragon")
		award_achievement("dragon_regular")
		award_achievement("dragon_problem")
	play_character_voice("death",false)
	AnalyticsLogger.log_event(ANALYTICS_PATH, "boss_kill" if enemy_is_boss else "enemy_kill", {"enemy_id":enemy_name.to_lower().replace(" ", "_"), "wave":wave, "zone_id":current_zone_id})
	if enemy_is_boss:
		profile.bosses_slain = int(profile.get("bosses_slain", 0)) + 1
		ProfileStore.save_profile(PROFILE_SAVE_PATH, profile)
	wave_kills += 1
	if enemy_variant_id == "volatile" and not (debug_enabled and debug_god_mode):
		var blast_damage := minf(4.0, player_max_hp * 0.03)
		player_hp = maxf(1.0, player_hp - blast_damage)
		add_float("POP -%.0f" % blast_damage, Vector2(180, 423), enemy_variant_color, 16)
		add_particles(Vector2(345, 455), enemy_variant_color, 12)
	var reward := int(round((5.0 + (mini(15,wave) if retention.siege else wave) * 1.8) * coin_reward_mult * (1.0 + inventory.effect_total("coin_mult")) * (4.0 if enemy_is_boss else 2.0 if enemy_is_miniboss else 1.0) * enemy_reward_multiplier))
	if retention.siege:
		coins += reward
		run_coins_earned += reward
	else:reward=0
	var xp_reward := (13.0 + (mini(15,wave) if retention.siege else wave) * 2.2) * xp_reward_mult * (2.6 if enemy_is_boss else 1.8 if enemy_is_miniboss else 1.0) * enemy_xp_multiplier
	if not retention.siege:xp_reward*=1.0+minf(.25,maxf(0.0,inventory.effect_total("coin_mult")*.25))
	var fire_count: int = build.count("Fire")
	if fire_count >= 3 or wildfire_power > 0:
		var explosion := base_damage * (0.45 * fire_count + wildfire_power * 0.5)
		carried_shockwave += explosion
		add_float("WILDFIRE %.0f" % explosion, Vector2(300, 380), build.color("Fire"), 23)
		add_particles(Vector2(365, 455), build.color("Fire"), 12)
	var gear_explosion := base_damage * inventory.effect_total("kill_explosion")
	if inventory.has_signature("banked_impact"):
		gear_explosion += base_damage * 0.38
	if gear_explosion > 0.0:
		carried_shockwave += gear_explosion
		add_float("GEAR BURST %.0f" % gear_explosion, Vector2(290, 405), Color("#ffd17a"), 18)
	if fire_count >= 3 or wildfire_power > 0 or gear_explosion > 0.0:
		play_audio_event("explosion")
	var equipment_dropped := false
	if enemy_is_boss and not retention.siege:
		prepare_hoard_chest()
	else:
		equipment_dropped = spawn_item_drop()
	if equipment_dropped:
		spawn_clock = maxf(spawn_clock, 1.2)
		play_audio_event("equipment_drop")
		AnalyticsLogger.log_event(ANALYTICS_PATH, "gear_drop", {"wave":wave, "boss":enemy_is_boss, "miniboss":enemy_is_miniboss})
	add_xp(xp_reward)
	if retention.siege and not enemy_is_boss:
		add_float("+%d EMBERS" % reward, Vector2(346, 355), Color("#ffd65a"), 18)
	add_particles(Vector2(365, 470), Color("#ffd65a"), 32 if enemy_is_boss else 22 if enemy_is_miniboss else 16)
	add_reward_burst(reward, xp_reward)
	status_message = "MINIBOSS DEFEATED" if enemy_is_miniboss else ""
	status_clock = 0.9 if enemy_is_miniboss else 0.0
	if retention.siege:
		retention.killed(); carried_shockwave=minf(carried_shockwave,base_damage*12.0); return
	if enemy_is_boss:
		pending_victory = true
		item_review_due = true
		return
	if dungeon.active:
		if wave_kills >= ENEMIES_PER_WAVE or enemy_is_miniboss:
			dungeon.room_finished = true
			item_review_due = true
		if enemy_encounter.active: enemy_encounter.on_death(self)
		carried_shockwave = minf(carried_shockwave, base_damage * 12.0)
		return
	if wave_kills >= ENEMIES_PER_WAVE or enemy_is_miniboss:
		wave += 1
		if wave in [4,12]: event_due = true
		wave_kills = 0
		item_review_due = true
		if wave in [6, 11]:
			merchant_due = true
			pending_zone_transition = true
		player_hp = minf(player_max_hp, player_hp + player_max_hp * ([.20,.12,.08][expedition_tier]))
		status_message = ""
		status_clock = 0.0
		if not pending_zone_transition and not wave in [8, RUN_LAST_WAVE]:
			wave_banner_text = "WAVE %d" % wave
			wave_banner_color = Color("#8fdcff")
			wave_banner_timer = 1.35
	carried_shockwave = minf(carried_shockwave, base_damage * 12.0)
	if enemy_encounter.active:
		enemy_encounter.on_death(self)

func spawn_item_drop() -> bool:
	var drop_count := 3 if enemy_is_boss else 1
	var spawned_count := 0
	for drop_index in range(drop_count):
		var item: Dictionary = loot_system.roll_drop(enemy_is_miniboss, enemy_is_boss)
		if item.is_empty():
			continue
		spawned_count += 1
		if enemy_is_boss:
			boss_reward_options.append(item)
		var rarity_color := ItemCatalog.rarity_color(item.rarity)
		award_item_discovery(item)
		var start_pos := Vector2(enemy_stage_x, 488) if enemy_is_boss else Vector2(enemy_stage_x-27 + drop_index * 20, 470)
		var launch_x: float = float([-155.0, -18.0, 128.0][drop_index]) if enemy_is_boss else -75.0 + drop_index * 52.0
		var launch_y: float = float([-310.0, -355.0, -292.0][drop_index]) if enemy_is_boss else visual_rng.randf_range(-250.0, -205.0)
		loot_drops.append({
			"item":item,
			"relic_chest":enemy_is_miniboss and not enemy_is_boss,
			"rarity":item.get("rarity", "COMMON"),
			"boss_choice":enemy_is_boss,
			"visual_slot":drop_index,
			"pos":start_pos,
			"vel":Vector2(launch_x, launch_y),
			"pickup":(0.95 + drop_index * 0.10) if enemy_is_boss else 1.15,
			"bounces":0,
			"squash":0.0,
			"color":rarity_color
		})
	if enemy_is_boss:
		add_float("BOSS HOARD!", Vector2(245, 335), Color("#ffd36a"), 22)
	return spawned_count > 0

func prepare_hoard_chest() -> void:
	normal_loot_choice = false
	boss_reward_options.clear()
	for drop_index in range(3):
		var item: Dictionary = loot_system.roll_drop(false, true)
		if not item.is_empty():
			boss_reward_options.append(item)
			award_item_discovery(item)
	hoard_reveal_profile = RewardRevealCatalog.for_rewards("hoard_chest", boss_reward_options)
	hoard_chest_phase = "fall"
	hoard_chest_timer = 0.62
	hoard_chest_y = 300.0
	state = "hoard_chest"
	help_label.visible = false
	AnalyticsLogger.log_event(ANALYTICS_PATH, "chest_open_ready", {"chest_id":"hoard_chest", "rolls":boss_reward_options.size()})

func update_hoard_chest(delta: float) -> void:
	hoard_chest_timer = maxf(0.0, hoard_chest_timer - delta)
	if hoard_chest_phase == "fall":
		var progress := 1.0 - hoard_chest_timer / 0.62
		hoard_chest_y = lerpf(278.0, 493.0, ease(clampf(progress, 0.0, 1.0), 2.0))
		if hoard_chest_timer <= 0.0:
			hoard_chest_phase = "ready"
			hoard_chest_y = 493.0
			screen_shake = 0.0 if audio_settings.get("cinematic_reduced_motion",false) else 0.10
			play_audio_event("chest_land")
			hoard_chest_button.visible = true
	elif hoard_chest_phase == "windup" and hoard_chest_timer <= 0.0:
		hoard_chest_phase = "silence"
		hoard_chest_timer = float(hoard_reveal_profile.get("silence", 0.10))
		if audio_manager != null:
			audio_manager.duck_music(0.12, -13.0)
	elif hoard_chest_phase == "silence" and hoard_chest_timer <= 0.0:
		eject_hoard_loot()

func open_hoard_chest() -> void:
	if inventory.has_signature("mimic_appetite") and state == "hoard_chest": cache_hit_primed = true
	if state != "hoard_chest" or hoard_chest_phase != "ready":
		return
	hoard_chest_phase = "windup"
	record_contract_chest()
	hoard_chest_timer = float(hoard_reveal_profile.get("anticipation", 0.62))
	hoard_chest_button.visible = false
	play_audio_event("chest_windup")
	award_achievement("ten_chests")
	award_achievement("chest_50")
	add_particles(Vector2(HOARD_CHEST_X, 492), Color("#ffd36a"), 16)
	impact_flash = 0.14

func eject_hoard_loot() -> void:
	if state!="hoard_chest" or hoard_chest_phase!="silence":return
	play_audio_event(str(hoard_reveal_profile.get("audio", "chest_open")))
	add_particles(Vector2(HOARD_CHEST_X, 492), Color(hoard_reveal_profile.get("color", Color("#ffd36a"))), int(hoard_reveal_profile.get("particles", 42)))
	screen_shake = 0.0 if audio_settings.get("cinematic_reduced_motion",false) else float(hoard_reveal_profile.get("shake", 0.11))
	for drop_index in range(boss_reward_options.size()):
		var item: Dictionary = boss_reward_options[drop_index]
		loot_drops.append({
			"item":item, "rarity":item.get("rarity", "EPIC"), "boss_choice":true, "visual_slot":drop_index,
			"pos":Vector2(HOARD_CHEST_X, 474), "vel":Vector2([-155.0, -18.0, 128.0][drop_index], [-310.0, -355.0, -292.0][drop_index]),
			"pickup":0.92 + drop_index * 0.10, "bounces":0, "squash":0.0,
			"color":ItemCatalog.rarity_color(item.get("rarity", "EPIC"))
		})
	hoard_chest_phase = ""
	state = "playing"
	spawn_clock = 1.2
	add_float("THE HOARD OPENS", Vector2(100, 240), Color("#ffd36a"), 21)
	var fanfare: String=preload("res://relic_spin_catalog.gd").sound(RewardRevealCatalog.highest_rarity(boss_reward_options))
	if fanfare!=str(hoard_reveal_profile.get("audio","chest_open")):play_audio_event(fanfare)
	if boss_reward_options.any(func(item): return item.get("rarity", "") == "LEGENDARY"):
		award_achievement("hoard_legendary")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "chest_open", {"chest_id":"hoard_chest", "rolls":boss_reward_options.size()})

func show_boss_reward() -> void:
	state = "boss_reward"
	# A single wave find should not occupy a three-reward wall of empty space.
	var unused_rows := 3 - clampi(boss_reward_options.size(), 1, 3)
	boss_reward_panel.size.y = 630 - unused_rows * 130
	boss_reward_footer.position.y = 510 - unused_rows * 130
	boss_reward_leave_button.position.y = 552 - unused_rows * 130
	pause_button.visible = false
	boss_reward_panel.visible = true
	help_label.visible = false
	boss_reward_heading.text = "WAVE FINDS — PICK ONE" if normal_loot_choice else "BOSS HOARD"
	boss_reward_heading.add_theme_font_size_override("font_size",24 if normal_loot_choice else 30)
	boss_reward_footer.text = "One find from this wave. The rest stay in the ruins." if normal_loot_choice else "Choose one reward to carry home."
	for i in range(boss_reward_buttons.size()):
		var offered := i < boss_reward_options.size()
		boss_reward_buttons[i].visible = offered
		boss_reward_icons[i].visible = offered
		if not offered: continue
		var item: Dictionary = boss_reward_options[i]
		boss_reward_buttons[i].text = boss_reward_card_text(item)
		boss_reward_buttons[i].add_theme_font_size_override("font_size", 13)
		apply_button_style(boss_reward_buttons[i], Color("#24264f"), ItemCatalog.rarity_color(item.rarity))
		LootlingsUI.apply_rarity_card(boss_reward_buttons[i], ItemCatalog.rarity_color(item.rarity))
		var visuals: Dictionary = boss_reward_visuals[i]
		visuals.kicker.text = "%s  •  %s" % [str(item.rarity), ItemCatalog.display_slot(item.get("slot", "Relic")).to_upper()]
		visuals.kicker.add_theme_color_override("font_color", ItemCatalog.rarity_color(item.rarity).lightened(0.25))
		visuals.name.text = str(item.name)
		fit_label_font(visuals.name, str(item.name), 260.0, 16, 12)
		boss_reward_buttons[i].text = "" # Child labels must not inflate the card or hide its name.
		# The catalog limit reserves an extra signature line; this compact card
		# keeps the same two headline effects as the original reward contract.
		visuals.effects.text = "\n".join(ItemCatalog.describe_headline_effects(item, 1).split("\n").slice(0, 2))
		boss_reward_buttons[i].tooltip_text = "%s\n%s" % [item.name, ItemCatalog.describe_headline_effects(item, 4)]
		for state_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_shadow_color"]:
			boss_reward_buttons[i].add_theme_color_override(state_name, Color.TRANSPARENT)
		boss_reward_icons[i].configure(item)
	if presentation_director != null:
		presentation_director.present_card(boss_reward_panel, Color("#ffd36a"), 0.34)

func boss_reward_card_text(item: Dictionary) -> String:
	var name := str(item.get("name", "Unknown Loot"))
	if name.length() > 28:
		name = name.left(27) + "…"
	var headline_lines := ItemCatalog.describe_headline_effects(item, 1).split("\n", false)
	var headline := ""
	for line in headline_lines:
		var clean_line := str(line)
		if clean_line.length() > 38:
			clean_line = clean_line.left(37) + "…"
		headline += ("\n                 " if not headline.is_empty() else "") + clean_line
	return "                 %s  •  %s\n                 %s\n                 %s" % [str(item.get("rarity", "EPIC")), name, ItemCatalog.display_identity(item), headline]

func inspect_boss_reward(index: int) -> void:
	if state != "boss_reward" or index < 0 or index >= boss_reward_options.size(): return
	var item: Dictionary = boss_reward_options[index]
	touch_ux.request(str(item.name),"NEW ITEM: %s\nCOST: FREE\n%s\n\n%s\n\nTake this find to inspect? Equipping stays optional. Other finds stay behind." % [item.name,ItemCatalog.describe_headline_effects(item,4),build_item_comparison(item,inventory.equipped_item(str(item.get("slot","Weapon"))))],choose_boss_reward.bind(index),item)

func inspect_merchant_item(index: int) -> void:
	if state != "merchant" or shop.purchase_taken or index < 0 or index >= shop.stock.size(): return
	var item: Dictionary = shop.stock[index]
	merchant_selection = index; selection_msec = Time.get_ticks_msec()
	merchant_detail.text = "[b]IF EQUIPPED: %s[/b]\n%s" % [item.name,build_item_comparison(item,inventory.equipped_item(str(item.get("slot","Weapon"))))]
	preload("res://quick_comparison.gd").install(merchant_detail,self,item,inventory.equipped_item(str(item.get("slot","Weapon"))))
	merchant_detail.call_deferred("scroll_to_line",0)
	merchant_buy_button.text = "TAKE FREE / ENDS THIS STOP"
	merchant_buy_button.disabled = shop.purchase_taken
	for i in range(merchant_buttons.size()):
		LootlingsUI.apply_selection(merchant_buttons[i],i==index)

func buy_selected_merchant() -> void:
	if Time.get_ticks_msec()-selection_msec < 180 or merchant_selection < 0: return
	var index := merchant_selection
	if state!="merchant" or index>=shop.stock.size():return
	var item:Dictionary=shop.stock[index]
	touch_ux.request("Take %s?" % item.name,"FREE. Choose one item this stop. Equipping remains optional.",func():merchant_selection=-1;buy_merchant_item(index))

func inspect_upgrade(index: int) -> void:
	if state != "upgrade" or index < 0 or index >= selected_upgrades.size(): return
	upgrade_selection = index; selection_msec = Time.get_ticks_msec()
	upgrade_take_button.text = "TAKE PERK / FREE"
	upgrade_take_button.add_theme_font_size_override("font_size",15)
	upgrade_take_button.disabled = false
	var up: Dictionary=selected_upgrades[index]
	upgrade_compare.text="CURRENT: %d stacks / %s\nNEW PERK: %s / stacks %d to %d\nCOST: FREE / %s" % [int(upgrade_counts.get(up.id,0)),build.short_summary(),up.name,int(upgrade_counts.get(up.id,0)),int(upgrade_counts.get(up.id,0))+1,up.desc]
	for i in range(upgrade_buttons.size()):
		LootlingsUI.apply_selection(upgrade_buttons[i],i==index)

func take_selected_upgrade() -> void:
	if Time.get_ticks_msec()-selection_msec < 180 or upgrade_selection < 0: return
	var index := upgrade_selection; upgrade_selection = -1
	choose_upgrade(index)

func choose_boss_reward(index: int) -> void:
	if state != "boss_reward" or index < 0 or index >= boss_reward_options.size():
		return
	var chosen: Dictionary = boss_reward_options[index]
	normal_loot_choice = false
	play_rarity_audio(chosen.get("rarity", "EPIC"))
	boss_reward_options.clear()
	boss_reward_panel.visible = false
	pending_items.push_front(chosen)
	state = "playing"
	show_next_item()

func show_next_item() -> void:
	if pending_items.is_empty():
		finish_item_decision()
		return
	state = "item"
	if touch_ux!=null:touch_ux.renew_surface()
	current_item = pending_items.pop_front()
	expedition_progress.data.seen["item:"+str(current_item.get("id",""))] = true
	expedition_progress.save()
	var rarity: String = current_item.get("rarity", "COMMON")
	var color := ItemCatalog.rarity_color(rarity)
	var title_text := "%s  •  %s" % [rarity, current_item.get("name", "Unknown Loot")]
	item_title.text = title_text
	fit_label_font(item_title, title_text, 376.0)
	item_title.add_theme_color_override("font_color", color)
	item_icon.configure(current_item)
	item_description.text = "%s\n%s\n%s" % [ItemCatalog.display_identity(current_item), current_item.get("desc", ""), ItemCatalog.describe_headline_effects(current_item, 1)]
	var equipped: Dictionary = inventory.equipped_item(current_item.get("slot", ""))
	item_title.text="LOOT COMPARISON"
	item_compare.text = build_item_comparison(current_item, equipped)
	preload("res://quick_comparison.gd").install(item_compare,self,current_item,equipped)
	item_compare.call_deferred("scroll_to_line",0)
	item_keep_button.disabled = inventory.stash.size() >= inventory.stash_capacity
	item_keep_button.text = "KEEP IN STASH\n%d / %d" % [inventory.stash.size(), inventory.stash_capacity]
	item_scrap_button.text = "SCRAP  +%d" % ItemCatalog.scrap_value(current_item)
	apply_button_style(item_equip_button, Color("#295d50"), color)
	item_panel.visible = true
	if presentation_director != null:
		presentation_director.present_card(item_panel, color, 0.27)
	help_label.visible = false
	queue_redraw()

func play_rarity_audio(rarity: String) -> void:
	match rarity:
		"RED": play_audio_event("relic_red")
		"LEGENDARY": play_audio_event("legendary_reveal")
		"EPIC": play_audio_event("epic_reveal")
		"RARE": play_audio_event("rare_reveal")
		_: play_audio_event("rarity_reveal")

func build_item_comparison(found: Dictionary, equipped: Dictionary) -> String:
	return preload("res://equipment_comparison.gd").text(self,found,equipped)

func format_effect_delta(key: String, amount: float) -> String:
	if key=="coin_mult":return "%+.1f%% EXPEDITION XP / %+.0f%% SIEGE EMBERS" % [amount*25.0,amount*100.0]
	var labels := {
		"damage_mult":"DAMAGE", "attack_speed":"ATTACK RATE", "attack_slow":"ATTACK RATE",
		"crit":"CRIT CHANCE", "max_hp":"MAX HP", "armor":"ARMOUR", "coin_mult":"EXPEDITION XP",
		"execute":"EXECUTE", "fire_damage":"BURN POWER", "crit_lightning":"CRIT SPARK",
		"poison_bonus":"POISON STACK", "poison_duration":"POISON TIME", "boss_damage":"BOSS DAMAGE",
		"heavy_bonus":"HEAVY POWER", "kill_explosion":"KILL BURST", "low_health_damage":"LOW-HP POWER"
	}
	var label: String = labels.get(key, key.replace("_", " ").to_upper())
	if key == "max_hp" or key == "poison_bonus":
		return "+%s %s" % [preload("res://combat_numbers.gd").text("",amount).strip_edges(), label]
	return "+%.1f%% %s" % [amount * 100.0, label]

func inspect_item_equip() -> void:
	if state != "item" or current_item.is_empty(): return
	var old: Dictionary = inventory.equipped_item(current_item.get("slot", ""))
	if inventory.stash.size() >= inventory.stash_capacity and not old.is_empty() and old.get("serial", 0) != -1:
		touch_ux.request("EQUIP & SCRAP OLD GEAR?", "Equip %s. Your stash is full: %s will be permanently scrapped for %d Scrap." % [current_item.name, old.name, ItemCatalog.scrap_value(old)], accept_item_equip)
	else: accept_item_equip()

func accept_item_equip() -> void:
	if state != "item" or current_item.is_empty():
		return
	var equipment_before: Dictionary=inventory.equipped.duplicate(true)
	var stash_before: Array=inventory.stash.duplicate(true)
	var scrap_before: int=inventory.scrap
	var result: Dictionary=inventory.equip(current_item)
	if inventory.save(INVENTORY_SAVE_PATH)!=OK:
		inventory.equipped=equipment_before;inventory.stash=stash_before;inventory.scrap=scrap_before
		status_message="Could not save gear. Your equipment is unchanged; try again."
		item_compare.text="[color=#ff7d88]"+status_message+"[/color]\n"+build_item_comparison(current_item,inventory.equipped_item(str(current_item.get("slot",""))))
		item_compare.call_deferred("scroll_to_line",0)
		return
	contextual_guide.observe_success("equipment")
	var item_name: String = current_item.get("name", "Loot")
	if not item_name in run_kept_loot:
		run_kept_loot.append(item_name)
		run_notable_items.append(current_item.duplicate(true))
	award_current_weapon_family()
	refresh_equipment_health()
	var filled_slots := 0
	for slot in InventorySystem.SLOTS:
		if not inventory.equipped_item(slot).is_empty():
			filled_slots += 1
	if filled_slots == InventorySystem.SLOTS.size():
		award_achievement("fully_equipped")
	status_message = "%s equipped!" % item_name
	if int(result.get("scrapped", 0)) > 0:
		status_message += " Old gear auto-scrapped."
	player_reward_flash = 0.55
	player_reward_color = Color("#69e6b0")
	add_particles(Vector2(player_x, 470), player_reward_color, 14)
	play_audio_event("equip")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "gear_equip", {"source":"run", "item_id":current_item.get("id", "")})
	queue_loot_dialogue(current_item)
	finish_item_decision()

func show_loot_save_error() -> void:
	status_message="Could not save this find. It has not been consumed; try again."
	item_compare.text="[color=#ff7d88]"+status_message+"[/color]\n"+build_item_comparison(current_item,inventory.equipped_item(str(current_item.get("slot",""))))
	item_compare.call_deferred("scroll_to_line",0)

func accept_item_keep() -> void:
	if state != "item" or current_item.is_empty():
		return
	var stash_before: Array=inventory.stash.duplicate(true)
	if not inventory.keep(current_item):
		return
	if inventory.save(INVENTORY_SAVE_PATH)!=OK:
		inventory.stash=stash_before
		show_loot_save_error()
		return
	var kept_name: String = current_item.get("name", "Loot")
	if not kept_name in run_kept_loot:
		run_kept_loot.append(kept_name)
		run_notable_items.append(current_item.duplicate(true))
	status_message = "%s sent to stash." % current_item.get("name", "Loot")
	player_reward_flash = 0.55
	player_reward_color = Color("#72c8ff")
	add_particles(Vector2(player_x, 470), player_reward_color, 12)
	queue_loot_dialogue(current_item)
	finish_item_decision()

func accept_item_scrap() -> void:
	if state != "item" or current_item.is_empty():
		return
	var scrap_before: int=inventory.scrap
	var value := inventory.salvage(current_item)
	if inventory.save(INVENTORY_SAVE_PATH)!=OK:
		inventory.scrap=scrap_before
		show_loot_save_error()
		return
	status_message = "Loot scrapped for %d scrap." % value
	player_reward_flash = 0.55
	player_reward_color = Color("#ffbd69")
	add_particles(Vector2(player_x, 470), player_reward_color, 16)
	play_audio_event("scrap")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "scrap_earned", {"source":"run_loot", "amount":value})
	finish_item_decision()

func finish_item_decision() -> void:
	item_panel.visible = false
	current_item.clear()
	status_clock = 2.0
	if not pending_items.is_empty():
		state = "playing"
		show_next_item()
	elif return_to_merchant:
		return_to_merchant = false
		state = "merchant"
		leave_merchant()
	elif pending_victory:
		end_run(true)
	else:
		item_review_due = false
		state = "playing"
		help_label.visible = not tap_tutorial_seen

func queue_loot_dialogue(item: Dictionary) -> void:
	var rarity := str(item.get("rarity", "COMMON"))
	hideout_ui.last_home_facts.rarity=rarity
	if rarity == "RED":
		hideout_ui.queue_dialogue_context("red_find")
	elif rarity == "LEGENDARY":
		hideout_ui.queue_dialogue_context("legendary_find")
	elif rarity == "EPIC":
		hideout_ui.queue_dialogue_context("epic_find")

func refresh_equipment_health() -> void:
	var new_bonus := inventory.effect_total("max_hp")
	var difference := new_bonus - equipment_hp_bonus
	equipment_hp_bonus = new_bonus
	player_max_hp = maxf(40.0, player_max_hp + difference)
	player_hp = clampf(player_hp + maxf(0.0, difference), 1.0, player_max_hp)

func show_merchant() -> void:
	merchant_subtitle.text = "RELIC ROUTE • MERCHANT ROOM" if dungeon.active else "ROADSIDE STOP  •  BETWEEN WAVES"
	state = "merchant"
	merchant_due = false
	if shop.stock.is_empty():
		shop.begin_visit(loot_system, wave,current_weapon_family())
	merchant_panel.visible = true
	help_label.visible = false
	refresh_merchant_ui()
	if presentation_director != null:
		presentation_director.present_card(merchant_panel, Color("#d3a45e"), 0.26)

func refresh_merchant_ui() -> void:
	merchant_selection = -1
	merchant_buy_button.disabled = true
	merchant_buy_button.text = "SELECT AN OFFER"
	preload("res://quick_comparison.gd").reset(merchant_detail)
	merchant_detail.text = "Choose one free supply. You may redraw once before taking it."
	merchant_title.text = "PACK PEDDLER"
	merchant_subtitle.text = shop.stock_style + " • PICK ONE"
	merchant_subtitle.add_theme_font_size_override("font_size",11)
	merchant_coin_label.text = "[center]ONE FREE SUPPLY CHOICE[/center]"
	for i in range(merchant_buttons.size()):
		var button := merchant_buttons[i]
		LootlingsUI.apply_selection(button,false)
		if i >= shop.stock.size():
			button.text = "SOLD • IN GOOD PAWS\nThe peddler is packing the receipts."
			button.disabled = true
			button.icon = null
			merchant_icons[i].visible = false
			merchant_visuals[i].kicker.text = "SOLD • IN GOOD PAWS"
			merchant_visuals[i].name.text = "Nothing left but the receipt."
			merchant_visuals[i].effect.text = ""
			for label in merchant_visuals[i].values():
				label.modulate = Color("#9cacc4")
			apply_button_style(button,Color("#141e32"),Color("#536583"))
			button.add_theme_color_override("font_disabled_color",Color.TRANSPARENT)
			continue
		var item: Dictionary = shop.stock[i]
		var price := int(item.get("price", 0))
		apply_merchant_thumbnail(button, merchant_icons[i], item)
		var indent := "" if item.get("slot", "") == "Weapon" else "             "
		var headline := ItemCatalog.describe_headline_effects(item, 1).replace("\n", "  •  ")
		if headline.length() > 43:
			headline = headline.left(42) + "…"
		button.text = "%s%s / FREE\n%s%s [%s]\n%s%s" % [indent,ItemCatalog.display_slot(item.get("slot","Item")),indent,item.name,item.rarity,indent,headline]
		button.tooltip_text = "%s\n%s" % [item.name, ItemCatalog.describe_headline_effects(item, 2)]
		button.disabled = shop.purchase_taken
		apply_button_style(button, Color("#202d52"), ItemCatalog.rarity_color(item.rarity))
		LootlingsUI.apply_rarity_card(button, ItemCatalog.rarity_color(item.rarity))
		# Keep the semantic button text, but render its information in an icon-safe lane.
		for state_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_shadow_color"]:
			button.add_theme_color_override(state_name, Color.TRANSPARENT)
		merchant_visuals[i].kicker.text = "%s / %s / FREE" % ["PREMIUM" if item.get("premium",false) else ItemCatalog.display_slot(item.get("slot","Item")),item.rarity]
		merchant_visuals[i].name.text = str(item.name)
		fit_label_font(merchant_visuals[i].name,str(item.name),286,14,11)
		button.text = "" # Child labels carry the visible text without inflating the button minimum size.
		merchant_visuals[i].effect.text = headline
		for label in merchant_visuals[i].values():
			label.modulate = Color("#a1a9bb") if button.disabled else Color.WHITE
	merchant_reroll_button.text = "REDRAW / FREE" if shop.can_reroll() else "REDRAW USED"
	merchant_reroll_button.disabled = not shop.can_reroll()

func apply_merchant_thumbnail(button: Button, category_icon: Control, item: Dictionary) -> void:
	category_icon.visible = true
	category_icon.configure(item)
	button.icon = null
	button.expand_icon = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_constant_override("icon_max_width", 62)

func buy_merchant_item(index: int) -> void:
	if state != "merchant" or shop.purchase_taken or index < 0 or index >= shop.stock.size():
		return
	play_audio_event("shop_purchase")
	AnalyticsLogger.log_event(ANALYTICS_PATH,"free_supply_choice",{"source":"pack_peddler"})
	var bought: Dictionary = shop.take(index)
	merchant_panel.visible = false
	return_to_merchant = true
	pending_items.push_front(bought)
	state = "playing"
	show_next_item()

func reroll_merchant() -> void:
	if state != "merchant" or not shop.can_reroll():return
	play_audio_event("ui_press")
	shop.reroll(loot_system,wave)
	refresh_merchant_ui()

func leave_merchant() -> void:
	if state != "merchant":
		return
	merchant_panel.visible = false
	shop.stock.clear()
	state = "playing"
	help_label.visible = not tap_tutorial_seen
	status_message = "Supplies packed. Back to the ruins."
	status_clock = 1.5

func add_xp(amount: float) -> void:
	xp += amount
	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = 32.0 + level * 15.0
		pending_levels += 1
		play_audio_event("level_up")
		AnalyticsLogger.log_event(ANALYTICS_PATH, "level_up", {"level":level, "wave":wave})
	if pending_levels > 0 and state == "playing":
		show_upgrade_choices()

func show_upgrade_choices() -> void:
	if touch_ux!=null:touch_ux.renew_surface()
	upgrade_compare.text="CURRENT: %s\nChoose a new perk to compare. FREE, or keep your current build." % build.short_summary()
	upgrade_selection = -1
	upgrade_take_button.disabled = true
	upgrade_take_button.text = "SELECT A CARD"
	state = "upgrade"
	help_label.visible = false
	selected_upgrades.clear()
	var pool:Array=preload("res://perk_offer_catalog.gd").offers(rng,UPGRADES,{"crit":crit_chance,"life_steal":life_steal,"execute":execute_ratio},debug_perk_rarity)
	for i in range(3):
		selected_upgrades.append(pool[i])
		var up: Dictionary = pool[i]
		var stacks := int(upgrade_counts.get(up.id, 0))
		LootlingsUI.apply_selection(upgrade_buttons[i],false)
		upgrade_buttons[i].text = format_upgrade_card(up, stacks)
		apply_button_style(upgrade_buttons[i], Color("#202d52"), GameCatalog.rarity_color(up.rarity))
		LootlingsUI.apply_rarity_card(upgrade_buttons[i], GameCatalog.rarity_color(up.rarity))
		# Keep the Button's complete semantic text for accessibility/tests; its
		# visible layers give rarity, name and effect distinct hierarchy.
		for state_color in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_shadow_color"]:
			upgrade_buttons[i].add_theme_color_override(state_color, Color.TRANSPARENT)
		var tags: Array = up.get("tags", [])
		upgrade_visuals[i].kicker.text = "%s  /  %s%s" % [str(tags[0]).to_upper() if not tags.is_empty() else "UTILITY", up.rarity, "  /  STACK ×%d" % stacks if stacks > 0 else ""]
		upgrade_visuals[i].kicker.add_theme_color_override("font_color", GameCatalog.rarity_color(up.rarity).lightened(0.20))
		upgrade_visuals[i].name.text = str(up.name).to_upper()
		upgrade_visuals[i].effect.text = str(up.desc)
		if not tags.is_empty():upgrade_visuals[i].kicker.text += "  /  CORE %d > %d" % [build.count(str(tags[0])),build.count(str(tags[0]))+tags.size()]
		upgrade_visuals[i].core.texture = LootlingsUI.icon("core_%s" % (str(tags[0]).to_lower() if not tags.is_empty() else "neutral"))
		upgrade_visuals[i].rarity.texture = LootlingsUI.icon("rarity_%s" % str(up.rarity).to_lower())
		# Only the exact supplied production upgrade texture fills this socket.
		var icon_path := "res://art/ui/icons/upgrades/%s.png" % up.id
		upgrade_visuals[i].icon.texture = load(icon_path) if ResourceLoader.exists(icon_path) else null
	upgrade_title.text = "LEVEL %d - PICK ONE" % level
	upgrade_panel.visible = true
	if presentation_director != null:
		presentation_director.present_card(upgrade_panel, build.color(), 0.27)

func format_upgrade_card(up: Dictionary, stacks: int) -> String:
	var tags: Array = up.get("tags", [])
	var tag: String = str(tags[0]).to_upper() if not tags.is_empty() else "UTILITY"
	var stack_line := "\nSTACK  ×%d" % stacks if stacks > 0 else ""
	return "[%s]   %s   •   %s\n%s  —  %s%s" % [up.get("icon", "UP"), up.get("name", "UPGRADE"), up.get("rarity", "COMMON"), tag, up.get("desc", ""), stack_line]

func choose_upgrade(index: int) -> void:
	if state != "upgrade" or index < 0 or index >= selected_upgrades.size():
		return
	var up: Dictionary = selected_upgrades[index]
	play_audio_event("upgrade_select")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "upgrade_pick", {"upgrade_id":up.get("id", ""), "level":level})
	var previous_dominant: String = build.dominant()
	var previous_tier: int = build.tier(previous_dominant)
	apply_upgrade_effect(up)
	var new_dominant: String = build.dominant()
	var transformed := new_dominant != "Neutral" and (new_dominant != previous_dominant or build.tier(new_dominant) > previous_tier)
	if transformed:
		play_audio_event("core_awaken")
		wave_banner_text = "%s CORE  -  %s" % [new_dominant.to_upper(), build.tier_name(new_dominant)]
		wave_banner_timer = 1.8
		upgrade_flash = 1.1
		add_particles(Vector2(player_x, 470), build.color(), 34)
		status_message = ""
		status_clock = 0.0
	else:
		wave_banner_text = "%s CHOSEN" % up.name
		wave_banner_timer = 1.15
		add_particles(Vector2(player_x, 470), build.color(), 20)
		status_message = ""
		status_clock = 0.0
	wave_banner_color = build.color()
	pending_levels -= 1
	upgrade_panel.visible = false
	if pending_levels > 0:
		show_upgrade_choices()
	else:
		state = "playing"
		help_label.visible = not tap_tutorial_seen
	queue_redraw()

func apply_upgrade_effect(up: Dictionary) -> void:
	var id: String = up.id
	upgrade_counts[id] = int(upgrade_counts.get(id, 0)) + 1
	build.add_upgrade(up)
	match id:
		"damage": base_damage *= 1.35
		"speed": attack_interval *= 0.82
		"crit": crit_chance = minf(0.72, crit_chance + 0.12)
		"multi": multi_hits += 1
		"splash": splash_ratio += 0.25
		"vamp": life_steal = minf(0.08, life_steal + 0.04)
		"armor":
			player_max_hp += 30.0
			player_hp += 30.0
			armor = 1.0 - (1.0 - armor) * 0.92
		"frenzy": frenzy += 1.0
		"tap": tap_mult += 0.8
		"execute": execute_ratio = minf(0.35, execute_ratio + 0.12)
		"regen": regen_per_second += 1.5
		"greed":
			xp_reward_mult += 0.15
		"heavy": heavy_power += 1
		"storm": storm_power += 1
		"ignite": ignite_power += 1
		"wildfire": wildfire_power += 1
		"venom": venom_power += 1
		"plague": plague_power += 1

func end_run(victory: bool) -> void:
	if run_resolved or state in ["result","relic_spinner"]: return
	run_resolved=true
	run_won = victory
	expedition_progress.finish(victory)
	if route_panel != null: route_panel.visible = false
	state = "result"
	if event_panel != null: event_panel.visible = false
	delayed_hits.clear()
	if pause_button != null: pause_button.visible = false
	upgrade_panel.visible = false
	item_panel.visible = false
	merchant_panel.visible = false
	boss_reward_panel.visible = false
	result_panel.visible = true
	help_label.visible = false
	run_shards_earned = (10 + level * 2 + wave) if victory else max(2, int(level + wave * 0.5))
	run_gold_earned = (160 + wave * 6) if victory else maxi(20, wave * 5)
	if dungeon.active:
		var caps: Dictionary = dungeon.reward_caps(total_kills, victory)
		run_gold_earned = mini(run_gold_earned, int(caps.gold))
		run_shards_earned = mini(run_shards_earned, int(caps.shards))
	if retention.siege:
		run_gold_earned=mini(500,total_kills*3); run_shards_earned=mini(40,total_kills/4)
	meta_shards += run_shards_earned
	gold += run_gold_earned
	if victory:
		contracts.record("win")
		if not dungeon.active and not retention.siege:
			campaign.finish(campaign_id)
			campaign.save("user://campaign.cfg")
		award_achievement("first_expedition")
		award_achievement("five_expeditions")
		if player_hp / maxf(1.0, player_max_hp) <= 0.10:
			award_achievement("close_call")
	award_achievement("gold_hoard", gold, true)
	award_achievement("scrap_hoard", inventory.scrap, true)
	save_meta()
	if not dungeon.active or total_kills > 0:
		hideout_shop.refresh_stock()
	contracts.save("user://contracts.cfg")
	hideout_shop.save(HIDEOUT_SHOP_SAVE_PATH)
	result_title.text = "HOARD CONQUERED!" if victory else "EXPEDITION ENDED"
	result_crest.texture = LootlingsUI.icon("res://art/ui/results/%s_crest.png" % ("victory" if victory else "defeat"))
	LootlingsUI.apply_material(result_panel, "hoard")
	result_title.add_theme_color_override("font_color", Color("#ffe178") if victory else Color("#ff8995"))
	var notable_loot := "None"
	if not run_kept_loot.is_empty():
		notable_loot = run_kept_loot[0]
		if run_kept_loot.size() > 1:
			notable_loot += ", " + run_kept_loot[1]
	var scrap_gained := maxi(0, inventory.scrap - run_start_scrap)
	result_summary.text = style_result_summary(format_result_summary(victory, wave, total_kills, run_coins_earned, run_coins_spent, coins, scrap_gained, run_shards_earned, notable_loot, run_gold_earned))
	result_summary.text += "\n\nRELIC RANK %d  •  %s +%d\n%s" % [expedition_progress.rank(),Phase4.FARMS[campaign_id].material,expedition_progress.run_materials,"\n".join(expedition_progress.run_finds)]
	result_summary.scroll_to_line(0)
	hideout_ui.last_home_facts={"mode":"siege" if retention.siege else "dungeon" if retention.targeted else "region","region":campaign_id,"round":wave,"boss":enemy_name,"outcome":"victory" if victory else "defeat","event":"boss_defeated" if victory else "early_defeat" if wave<=5 else "returning","low_health":"yes" if victory and player_hp/player_max_hp<.2 else "no","enemy":enemy_name,"character":Avatar.preset_id(profile) if Avatar.is_wanderer(profile) else str(profile.get("current_lootling_id","relic_beast"))}
	var rift_line: String=preload("res://rift_progress.gd").settle(self,str(retention.progress.data.session),victory,total_kills,retention.rift_active)
	if not rift_line.is_empty():result_summary.text+="\n"+rift_line
	retention.finish(victory)
	var mythical_deliveries: Array=preload("res://rift_progress.gd").recover(self)
	if not mythical_deliveries.is_empty():
		result_summary.text+="\nMYTHICAL SHINY: "+str(mythical_deliveries[0].item.name)
		retention.call_deferred("present_red_drop",mythical_deliveries[0],"Saved to Gear. A prismatic keepsake!")
	if retention.siege:
		result_title.text="SIEGE EXTRACTED" if victory else "SIEGE ENDED"
		result_summary.text=result_summary.text.replace("Wave reached %d / %d" % [wave,RUN_LAST_WAVE],"Round reached %d" % wave)
	refresh_result_loot()
	if dungeon.active:
		result_title.text = ("PRISM RIFT CLEARED!" if retention.rift_active else "ROOTGLASS VAULT CLEARED!" if retention.targeted else "RELIC ROUTE CLEARED!") if victory else "ROUTE ENDED"
		result_summary.text = result_summary.text.replace("Wave reached %d / %d" % [wave, RUN_LAST_WAVE], "Rooms entered  %d / 8 • Seed %d" % [dungeon.depth + 1, dungeon.seed_value])
	if presentation_director != null:
		presentation_director.present_card(result_panel, Color("#ffe178") if victory else Color("#ff8995"), 0.34)
	play_audio_event("victory" if victory else "defeat")
	if audio_manager != null:
		audio_manager.set_music("VICTORY" if victory else "DEFEAT")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "gold_earned", {"amount":run_gold_earned, "source":"run_result", "victory":victory})
	AnalyticsLogger.log_event(ANALYTICS_PATH, "run_end", {"victory":victory, "wave":wave, "kills":total_kills, "gold":run_gold_earned, "siege_embers_earned":run_coins_earned, "siege_embers_spent":run_coins_spent})
	if victory:
		hideout_ui.queue_dialogue_context("boss_defeated")
	elif wave <= 5:
		hideout_ui.queue_dialogue_context("early_defeat")
	else:
		hideout_ui.queue_dialogue_context("returning")
	if victory:
		for burst in range(4):
			add_particles(Vector2(80 + burst * 105, 260 + (burst % 2) * 70), Color("#ffd766") if burst % 2 == 0 else Color("#81e6ff"), 18)

func format_result_summary(victory: bool, reached_wave: int, kills: int, earned: int, spent: int, left: int, scrap_gained: int, shards_gained: int, notable_loot: String, gold_gained: int = 0) -> String:
	var summary: String="%s\nWave reached %d / %d / Enemies %d\n\nRUN REWARDS\nLootcoins +%d / Scrap +%d / Diamonds +%d\n\nNOTABLE LOOT\n%s" % ["VICTORY" if victory else "DEFEAT",reached_wave,RUN_LAST_WAVE,kills,gold_gained,scrap_gained,shards_gained,notable_loot]
	if retention.siege:summary+="\n\nSIEGE EMBERS\nEarned %d / used %d / left %d\nExpedition-only; not permanent Lootcoins." % [earned,spent,left]
	return summary

func style_result_summary(summary: String) -> String:
	var styled := summary
	for resource in ["Lootcoins", "Scrap", "Diamonds"]:
		var icon_name: String = {"Lootcoins":"gold", "Scrap":"scrap", "Diamonds":"star_shard"}[resource]
		styled = styled.replace("%s +" % resource, "%s %s +" % [LootlingsUI.inline_icon("currency_%s" % icon_name), resource])
	for heading in ["SIEGE EMBERS", "RUN REWARDS", "NOTABLE LOOT"]:
		styled = styled.replace(heading, "[font_size=12][color=#dabb79]%s[/color][/font_size]" % heading)
	return "[center]%s[/center]" % styled

func buy_meta_power() -> void:
	if state != "hideout" or meta_power >= 100:
		return
	var cost := 10 + meta_power * 5
	if meta_shards >= cost:
		meta_shards -= cost
		meta_power += 1
		save_meta()
		refresh_hideout()
		hideout_ui.play_shrine_upgrade()
		hideout_ui.request_dialogue("shrine_upgrade", "Relic Keeper")
		play_audio_event("core_awaken")
		award_achievement("relic_student")

func refresh_hideout() -> void:
	if hideout_ui != null:
		if not expedition_progress.data.craft_pending.is_empty():
			hideout_ui.phase4_message = expedition_progress.recover_delivery(inventory,INVENTORY_SAVE_PATH)
		hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)

func refresh_result_loot() -> void:
	var ranked := run_notable_items.duplicate()
	var rarity_order := {"COMMON":0,"UNCOMMON":1,"RARE":2,"EPIC":3,"LEGENDARY":4,"RED":5}
	ranked.sort_custom(func(a,b): return int(rarity_order.get(a.get("rarity","COMMON"),0)) > int(rarity_order.get(b.get("rarity","COMMON"),0)))
	for i in range(result_loot_cards.size()):
		var card: Control = result_loot_cards[i]
		card.visible = i < ranked.size()
		if not card.visible: continue
		var item: Dictionary = ranked[i]
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#172442")
		style.border_color = ItemCatalog.rarity_color(str(item.get("rarity","COMMON")))
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		card.add_theme_stylebox_override("panel",style)
		card.get_meta("icon").configure(item)
		var caption: Label = card.get_meta("name_label")
		caption.text = str(item.get("name","Loot"))
		caption.add_theme_color_override("font_color",ItemCatalog.rarity_color(str(item.get("rarity","COMMON"))))

func load_meta() -> void:
	var progress := MetaStore.load_progress(SAVE_PATH)
	rift_progress = progress.rift.duplicate(true)
	meta_shards = progress.shards
	meta_power = progress.power
	gold = progress.gold
	gold_upgrades = progress.get("gold_upgrades", {"bedroll":0, "whetstone":0, "pouch":0}).duplicate(true)

func navigate_back() -> void:
	if backup_menu!=null and backup_menu.panel.visible and not is_instance_valid(touch_ux.dialog):backup_menu.close();return
	if contextual_guide!=null and contextual_guide.panel.visible:contextual_guide.close();return
	if touch_ux != null and is_instance_valid(touch_ux.dialog):
		touch_ux.close_dialog()
		return
	if presentation_director.vignette.active:
		presentation_director.vignette.finish(); return
	if startup_ui.visible and startup_ui.handle_settings_back(): return
	if state=="personal_home":personal_home.go_back();return
	if personal_profile_return and startup_ui.visible:
		if startup_ui.identity_panel.visible:startup_ui.identity_panel.visible=false
		elif startup_ui.current_screen in ["lootling_select","wanderer_select"]:startup_ui.show_profile(false)
		else:personal_profile_return=false;show_personal_home()
		return
	if presentation_director.vignette.active:
		presentation_director.vignette.finish()
	elif state == "mode_menu": retention.close_modes()
	elif state == "relic_spinner": retention.close_spinner()
	elif state == "merchant": leave_merchant()
	elif state == "upgrade": skip_upgrade()
	elif state == "item": skip_item()
	elif state == "event": choose_expedition_event(2)
	elif state == "result": show_hideout()
	elif state == "abandon_confirm": cancel_abandon_run()
	elif state == "siege_service": retention.choose(3)
	elif state == "boss_reward": skip_boss_rewards()
	elif state in ["route","siege_checkpoint","hoard_chest"]: request_return_home()
	elif state == "playing": pause_run()
	elif state == "paused": resume_run()
	elif state == "hideout":
		if startup_ui.visible and not hideout_ui.visible:
			if startup_ui.identity_panel.visible:startup_ui.identity_panel.hide()
			elif startup_ui.current_screen in ["lootling_select","wanderer_select"]:startup_ui.show_profile(false)
			else:startup_ui.hide();show_hideout()
			return
		if hideout_ui.current_screen=="companion_collection":hideout_ui.show_home_settings();return
		if hideout_ui.speech_panel.visible: hideout_ui.dismiss_dialogue(); return
		if hideout_ui.loadout_panel.is_visible_in_tree():hideout_ui.loadout_panel.visible=false;return
		if hideout_ui.region_sheet.visible: hideout_ui.region_sheet.visible=false; return
		if hideout_ui.stash_detail_panel.visible and hideout_ui.current_screen=="stash": hideout_ui.close_stash_detail(); return
		if hideout_ui.current_screen != "home": hideout_ui.show_home()
		else: show_title_from_hideout()
	elif startup_ui.visible:
		startup_ui.show_title()

func input_surface() -> Control:
	if contextual_guide!=null and contextual_guide.panel.visible:return contextual_guide.panel
	if backup_menu!=null and backup_menu.panel.visible and not is_instance_valid(touch_ux.dialog):return backup_menu.panel
	if touch_ux!=null and is_instance_valid(touch_ux.dialog):return touch_ux.dialog
	if is_instance_valid(debug_panel) and debug_panel.visible:return debug_panel
	# The topmost confirmation owns input, including inside personal Home.
	if touch_ux!=null and is_instance_valid(touch_ux.dialog): return touch_ux.dialog
	if state=="personal_home":return personal_home.input_surface()
	if startup_ui.visible: return startup_ui.input_surface()
	if state in ["mode_menu","relic_spinner","siege_service","siege_checkpoint"]:
		return retention.pool_panel if retention.pool_panel.visible else retention.panel
	if state=="hideout":
		if startup_ui.visible and not hideout_ui.visible:return startup_ui
		if hideout_ui.region_sheet.is_visible_in_tree():return hideout_ui.region_sheet
		if hideout_ui.speech_panel.is_visible_in_tree():return hideout_ui.speech_panel
		if hideout_ui.stash_detail_panel.is_visible_in_tree():return hideout_ui.stash_content
		return hideout_ui
	return {"merchant":merchant_panel,"item":item_panel,"upgrade":upgrade_panel,"event":event_panel,"boss_reward":boss_reward_panel,"result":result_panel,"route":route_panel,"paused":pause_panel,"abandon_confirm":abandon_panel}.get(state,null)

func request_return_home() -> void:
	touch_ux.request("Return to the Hideout?","End this expedition. Owned gear and secured rewards stay yours; unfinished run rewards are lost.",func(): state="abandon_confirm";confirm_abandon_run())

func skip_boss_rewards() -> void:
	if state!="boss_reward":return
	normal_loot_choice=false;boss_reward_options.clear();boss_reward_panel.visible=false
	status_message="Kept current gear. Finds left behind."
	finish_item_decision()

func skip_item() -> void:
	if state!="item":return
	status_message="Kept your current equipment. Find left behind."
	finish_item_decision()

func skip_upgrade() -> void:
	if state!="upgrade":return
	pending_levels=maxi(0,pending_levels-1);upgrade_panel.visible=false
	if pending_levels>0:show_upgrade_choices()
	else:state="playing"

func save_meta() -> void:
	MetaStore.save_progress(SAVE_PATH, meta_shards, meta_power, gold, gold_upgrades, rift_progress)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		navigate_back()
		get_viewport().set_input_as_handled()
		return
	if presentation_director != null and presentation_director.vignette.active: return
	if event is InputEventScreenTouch or event is InputEventScreenDrag: return # gesture owner handles deliberate arena releases
	if event is InputEventMouseButton and event.device == -1: return # synthetic mouse must never duplicate touch combat
	if touch_ux != null and is_instance_valid(touch_ux.dialog): return
	var local_touch := Vector2.ZERO
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		local_touch = get_global_transform_with_canvas().affine_inverse() * event.position
		if not Rect2(Vector2.ZERO, DESIGN_SIZE).has_point(local_touch): return
	if debug_enabled and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		if debug_panel != null and not debug_panel.visible:
			debug_panel.open()
			get_viewport().set_input_as_handled()
		return
	if debug_enabled and debug_panel != null and debug_panel.visible:
		return
	if state == "hoard_chest" and hoard_chest_phase == "ready" and event is InputEventKey and not event.echo and event.is_action_pressed("tap_attack"):
		open_hoard_chest()
		get_viewport().set_input_as_handled()
		return
	if state != "playing":
		return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed and enemy_encounter.card_at(local_touch)>=0:
		enemy_encounter.select(self,enemy_encounter.card_at(local_touch))
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and not Rect2(0,310,480,344).has_point(local_touch): return
	var tapped := false
	if event is InputEventMouseButton:
		tapped = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	elif event is InputEventScreenTouch:
		tapped = event.pressed
	elif event is InputEventKey:
		tapped = event.is_action_pressed("tap_attack") and not event.echo
	if tapped:
		if enemy_encounter.active and (event is InputEventMouseButton or event is InputEventScreenTouch):
			enemy_encounter.select_at(self, local_touch)
		request_tap_attack()
		get_viewport().set_input_as_handled()

func update_effects(delta: float) -> void:
	combat_presentation.step(self, delta)
	enemy_flash = maxf(0.0, enemy_flash - delta)
	player_flash = maxf(0.0, player_flash - delta)
	screen_shake = maxf(0.0, screen_shake - delta)
	squash = maxf(0.0, squash - delta)
	attack_anim = maxf(0.0, attack_anim - delta)
	player_idle_reaction = maxf(0.0, player_idle_reaction - delta)
	if state == "playing" and attack_anim <= 0.0:
		player_idle_reaction_clock -= delta
		if player_idle_reaction_clock <= 0.0:
			player_idle_reaction = 0.34
			player_idle_reaction_clock = visual_rng.randf_range(3.2, 7.0)
			player_idle_reaction_direction = -1.0 if visual_rng.randf() < 0.5 else 1.0
	enemy_attack_anim = maxf(0.0, enemy_attack_anim - delta)
	enemy_squash = maxf(0.0, enemy_squash - delta)
	enemy_death_anim = maxf(0.0, enemy_death_anim - delta)
	enemy_entry_anim = maxf(0.0, enemy_entry_anim - delta)
	impact_flash = maxf(0.0, impact_flash - delta)
	crit_flash = maxf(0.0, crit_flash - delta)
	element_flash = maxf(0.0, element_flash - delta)
	death_burst = maxf(0.0, death_burst - delta)
	coin_counter_flash = maxf(0.0, coin_counter_flash - delta)
	xp_counter_flash = maxf(0.0, xp_counter_flash - delta)
	player_reward_flash = maxf(0.0, player_reward_flash - delta)
	rarity_reveal_flash = maxf(0.0, rarity_reveal_flash - delta)
	tap_buffer_flash = maxf(0.0, tap_buffer_flash - delta)
	tap_pulse = maxf(0.0, tap_pulse - delta)
	upgrade_flash = maxf(0.0, upgrade_flash - delta)
	wave_banner_timer = maxf(0.0, wave_banner_timer - delta)
	enemy_recoil = move_toward(enemy_recoil, 0.0, 115.0 * delta)
	update_attack_projectiles(delta)
	for item in floating_texts:
		item.life -= delta
		if item.has("number_kind"): preload("res://combat_numbers.gd").step(self,item,delta)
		elif not audio_settings.get("cinematic_reduced_motion",false): item.pos.y -= 42.0 * delta
	for i in range(floating_texts.size() - 1, -1, -1):
		if floating_texts[i].life <= 0.0:
			preload("res://combat_numbers.gd").recycle(self,floating_texts[i])
			floating_texts.remove_at(i)
	for particle in particles:
		particle.life -= delta
		particle.pos += particle.vel * delta
		particle.vel.y += 100.0 * delta
	for i in range(particles.size() - 1, -1, -1):
		if particles[i].life <= 0.0:
			particles.remove_at(i)
	for pickup in reward_pickups:
		if pickup.delay > 0.0:
			pickup.delay -= delta
			pickup.vel.y += 420.0 * delta
			pickup.pos += pickup.vel * delta
			if pickup.pos.y > 500.0:
				pickup.pos.y = 500.0
				pickup.vel.y = -absf(pickup.vel.y) * 0.34
			continue
		pickup.life -= delta
		var progress: float = 1.0 - clampf(pickup.life / pickup.max_life, 0.0, 1.0)
		pickup.pos = pickup.start.lerp(pickup.target, progress) + Vector2(0, -sin(progress * PI) * 72.0)
	for i in range(reward_pickups.size() - 1, -1, -1):
		if reward_pickups[i].life <= 0.0:
			if reward_pickups[i].kind == "coin":
				if coin_counter_flash <= 0.0:
					play_audio_event("scrip_pickup")
				coin_counter_flash = 0.24
			else:
				if xp_counter_flash <= 0.0:
					play_audio_event("xp_pickup")
				xp_counter_flash = 0.24
			reward_pickups.remove_at(i)
	for drop in loot_drops:
		drop.pickup -= delta
		drop.squash = maxf(0.0, float(drop.get("squash", 0.0)) - delta)
		var drop_gravity := 760.0 if bool(drop.get("boss_choice", false)) else 340.0
		drop.vel.y += drop_gravity * delta
		drop.pos += drop.vel * delta
		if drop.pos.y >= 580.0 and drop.vel.y > 0.0:
			if int(drop.bounces) == 0 and bool(drop.get("boss_choice", false)):
				play_audio_event("chest_land")
			drop.pos.y = 580.0
			drop.vel.y = -drop.vel.y * (0.44 if int(drop.bounces) == 0 else 0.18)
			drop.vel.x *= 0.68
			drop.bounces += 1
			drop.squash = 0.12
	for i in range(loot_drops.size() - 1, -1, -1):
		if loot_drops[i].pickup <= 0.0:
			var revealed_item: Dictionary = loot_drops[i].item
			if not bool(loot_drops[i].get("boss_choice", false)):
				pending_items.append(revealed_item)
			add_particles(loot_drops[i].pos, loot_drops[i].color, 18)
			play_rarity_audio(revealed_item.get("rarity", "COMMON"))
			if revealed_item.get("rarity", "COMMON") in ["EPIC", "LEGENDARY"]:
				rarity_reveal_flash = 0.34 if revealed_item.get("rarity", "") == "LEGENDARY" else 0.22
				rarity_reveal_color = loot_drops[i].color
			loot_drops.remove_at(i)

func update_attack_projectiles(delta: float) -> void:
	for effect in projectile_impacts: effect.life -= delta
	projectile_impacts = projectile_impacts.filter(func(effect): return effect.life > 0)
	for projectile in attack_projectiles:
		projectile.life -= delta
		var progress: float = 1.0 - clampf(projectile.life / projectile.max_life, 0.0, 1.0)
		projectile.pos = projectile.start.lerp(projectile.target, progress)
		var arc := 38.0 if projectile.get("weapon_type", "") == "sling" else 5.0 if projectile.get("weapon_type", "") == "wand" else 12.0 if projectile.get("weapon_type", "") == "orb" else 18.0 if projectile.family == "MAGE" else 0.0
		projectile.pos.y -= sin(progress * PI) * arc
	for index in range(attack_projectiles.size() - 1, -1, -1):
		var projectile: Dictionary = attack_projectiles[index]
		if projectile.life > 0.0:
			continue
		attack_projectiles.remove_at(index)
		record_projectile_impact(projectile)
		if state == "playing" and enemy_encounter.active:
			enemy_encounter.resolve_projectile(self, int(projectile.enemy_serial), bool(projectile.is_tap))
		elif state == "playing" and enemy_alive and int(projectile.enemy_serial) == enemy_serial:
			resolve_player_attack(bool(projectile.is_tap))

func record_projectile_impact(projectile: Dictionary) -> void:
	if state!="playing": return
	var hit_material:=""
	if enemy_encounter.active:
		# Capture the struck member, not the currently selected pack member. This
		# is a visual snapshot only; encounter selection and damage stay untouched.
		for index in range(enemy_encounter.actors.size()):
			var actor: Dictionary=enemy_encounter.actors[index]
			var alive: bool=enemy_alive if index==enemy_encounter.selected else bool(actor.enemy_alive)
			if alive and int(actor.enemy_serial)==int(projectile.enemy_serial):
				hit_material=preload("res://regional_enemy_presentation.gd").material_for(str(actor.enemy_name),str(actor.enemy_archetype),bool(actor.enemy_is_boss),bool(actor.enemy_is_miniboss),campaign_id)
				break
	elif enemy_alive and int(projectile.enemy_serial)==enemy_serial:
		hit_material=preload("res://regional_enemy_presentation.gd").material(self)
	if hit_material.is_empty(): return
	if projectile_impacts.size()>=16: projectile_impacts.pop_front()
	projectile_impacts.append({"pos":projectile.target,"element":projectile.get("element","Physical"),"life":.24,
		"direction":(Vector2(projectile.target)-Vector2(projectile.start)).normalized(),
		"weapon_type":projectile.get("weapon_type","bow"),"material":hit_material})

func add_float(text_value: String, pos: Vector2, color: Color, size_value: int) -> void:
	pos.y+=40
	var proc_name := text_value.get_slice(" ",0)
	if proc_name in ["ARC","QUAKE","WILDFIRE","GEAR","RELIC"] or (proc_name == "WARD" and not text_value.begins_with("WARD −")) or size_value <= 15:
		var element := "lightning" if proc_name == "ARC" else "fire" if proc_name in ["WILDFIRE","BURN"] else "poison" if proc_name in ["POISON","VENOM"] else "neutral"
		proc_texture = LootlingsUI.icon("core_"+element); proc_timer = .7
		return
	var is_dot := size_value <= 15
	var prefix := text_value.get_slice(" ", 0)
	var lane := "damage"
	if text_value.begins_with("-") or text_value.begins_with("WARD −"):
		lane = "player"
	elif text_value=="THE HOARD OPENS":
		lane="announcement"
	elif text_value.contains("EMBERS") or text_value.contains("LOOT") or text_value.contains("HOARD"):
		lane = "reward"
	elif is_dot or prefix in ["WARD"]:
		lane = "secondary"
	elif prefix in ["ARC", "QUAKE", "WILDFIRE", "GEAR", "RELIC", "SHOCKWAVE", "YEET!"]:
		lane = "proc"
	var lane_count := 0
	for item in floating_texts:
		if item.has("number_kind"): continue
		if is_dot and item.text.get_slice(" ", 0) == prefix and item.life > 0.28:
			return
		if item.get("lane", "damage") == lane:
			lane_count += 1
	if lane_count >= 1:
		return
	match lane:
		"player": pos = Vector2(WeaponFit.world_position(self).x, 414)
		"announcement": pos = Vector2(100, 280)
		"reward": pos = Vector2(392, 590)
		"proc": pos = Vector2(140, 590)
		"secondary": pos = Vector2(350, 595)
		_: pos = Vector2(target_combat_visual_position().x, 414)
	pos.y += min(lane_count, 2) * 26.0
	pos.x += (-9.0 if lane_count % 2 == 0 else 9.0) * min(lane_count, 2)
	var duration := 0.68 if size_value < 25 else 0.82
	floating_texts.append({"text":text_value, "pos":pos, "color":color, "size":size_value, "life":duration, "max_life":duration, "lane":lane})
	var notices: Array = floating_texts.filter(func(item): return not item.has("number_kind"))
	while notices.size() > 3: floating_texts.erase(notices.pop_front())

func add_particles(pos: Vector2, color: Color, count: int) -> void:
	pos.y+=40
	for i in range(mini(count,8)):
		particles.append({"pos":pos, "vel":Vector2(visual_rng.randf_range(-105, 105), visual_rng.randf_range(-155, -25)), "color":color, "life":visual_rng.randf_range(0.25, 0.55), "max_life":0.55})
	while particles.size() > 96: particles.pop_front()

func add_reward_burst(coin_reward: int, xp_reward: float) -> void:
	var coin_cap := 7 if enemy_is_boss else 4 if enemy_is_miniboss else 3
	var coin_count := mini(coin_cap, maxi(3, int(coin_reward / 7) + 3)) if retention.siege else 0
	for i in range(coin_count):
		var start := Vector2(360, 490) + Vector2(visual_rng.randf_range(-24, 24), visual_rng.randf_range(-18, 20))
		reward_pickups.append({"kind":"coin", "start":start, "pos":start, "target":Vector2(420, 35), "vel":Vector2(visual_rng.randf_range(-130.0, 85.0), visual_rng.randf_range(-230.0, -120.0)), "delay":0.16 + i * 0.035, "life":0.72, "max_life":0.72})
	var xp_count := mini(3 if enemy_is_boss else 2, maxi(2, int(xp_reward / 25.0) + 2))
	for i in range(xp_count):
		var start := Vector2(365, 490) + Vector2(visual_rng.randf_range(-28, 28), visual_rng.randf_range(-15, 22))
		reward_pickups.append({"kind":"xp", "start":start, "pos":start, "target":Vector2(250, 92), "vel":Vector2(visual_rng.randf_range(-95.0, 110.0), visual_rng.randf_range(-210.0, -105.0)), "delay":0.20 + i * 0.045, "life":0.78, "max_life":0.78})

func _draw() -> void:
	if startup_ui != null and startup_ui.visible: return
	if hideout_ui != null and hideout_ui.visible: return
	if personal_home != null and personal_home.visible: return
	var sx := size.x / DESIGN_SIZE.x
	var sy := size.y / DESIGN_SIZE.y
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))
	if state=="mode_menu" or (state=="relic_spinner" and retention.spinner_from_home):return
	var shake := Vector2.ZERO
	if screen_shake > 0.0 and not audio_settings.get("cinematic_reduced_motion", false):
		shake = Vector2(visual_rng.randf_range(-4, 4), visual_rng.randf_range(-3, 3))
	draw_background()
	draw_hud()
	draw_arena(shake)
	draw_effects()
	draw_moment_overlay()

func draw_background() -> void:
	draw_rect(Rect2(0, 0, 480, 112), Color("#080d20"))
	var arena_background: Texture2D = current_zone.get("background", ZoneCatalog.OUTER_RUINS_BACKGROUND)
	var texture_size := arena_background.get_size()
	var target := Rect2(0, 112, 480, 664)
	var crop_height: float = texture_size.x * target.size.y / target.size.x
	var source_height := minf(texture_size.y, crop_height)
	var max_source_y := maxf(0.0, texture_size.y - source_height)
	var depth_drift := sin(run_time * 0.20) * minf(2.5, max_source_y * 0.5)
	var source := Rect2(0, clampf(max_source_y * 0.5 + depth_drift, 0.0, max_source_y), texture_size.x, source_height)
	draw_texture_rect_region(arena_background, target, source, current_zone.get("presentation_tint", Color.WHITE))
	if campaign_id != "act_i":
		# Reuse painted masonry to anchor feet; scenery is not the collision plane.
		draw_texture_rect(preload("res://beta_art_catalog.gd").PLATFORM, Rect2(0, 544, 480, 110), false, Color("#ddb99a") if current_zone_id == "cinder_crown" else Color.WHITE)
	# Quiet the combat band slightly while keeping the lanterns and moon visible.
	var plane_tint := Color("#17100c28") if current_zone_id == "emberworks" else Color("#09082230") if current_zone_id == "hoard_depths" else Color("#08122922")
	draw_rect(Rect2(0, 182, 480, 382), plane_tint, true)
	draw_rect(Rect2(0, 558, 480, 156), Color("#07102142"), true)
	# The approved painted floor provides the ground plane; no debug-like guide across actors.
	draw_zone_ambient()

func draw_zone_ambient() -> void:
	match current_zone_id:
		"emberworks":
			for index in range(7):
				var ember_x := fmod(53.0 + index * 83.0 + sin(run_time * 0.9 + index) * 24.0, 500.0) - 10.0
				var ember_y := 565.0 - fmod(run_time * (18.0 + index * 1.7) + index * 61.0, 330.0)
				draw_circle(Vector2(ember_x, ember_y), 1.5 + index % 2, Color(1.0, 0.45, 0.16, 0.34))
		"hoard_depths":
			for index in range(5):
				var glint_pos := Vector2(45 + index * 96, 242 + (index * 73) % 260)
				var glow := 0.18 + maxf(0.0, sin(run_time * 1.5 + index * 1.8)) * 0.30
				draw_line(glint_pos + Vector2(-4, 0), glint_pos + Vector2(4, 0), Color(1.0, 0.77, 0.28, glow), 1.5)
				draw_line(glint_pos + Vector2(0, -4), glint_pos + Vector2(0, 4), Color(0.80, 0.55, 1.0, glow * 0.7), 1.5)
		_:
			for index in range(6):
				var mote_x := fmod(31.0 + index * 91.0 + run_time * (4.0 + index), 520.0) - 20.0
				var mote_y := 230.0 + fmod(index * 67.0 + sin(run_time * 0.7 + index) * 18.0, 310.0)
				draw_circle(Vector2(mote_x, mote_y), 1.4, Color(0.58, 0.82, 1.0, 0.24))

func draw_hud() -> void:
	draw_rect(Rect2(0,0,480,110),Color("#091526f5"))
	draw_line(Vector2(18,109),Vector2(462,109),Color("#ab8b4d99"),1.0)
	var actor_name:=Avatar.display_name(profile).to_upper()
	draw_string(title_font, Vector2(60, 36), actor_name, HORIZONTAL_ALIGNMENT_LEFT, 170, LootlingsUI.fitted_font_size(title_font,actor_name,170,18,12), Color("#ffe178"))
	var hud_region: String = str(current_zone.get("short_name", {"outer_ruins":"TREASURE RUINS", "emberworks":"WARRENS", "hoard_depths":"HOARD DEPTHS"}.get(current_zone.get("id", ""), "RUINS"))).to_upper()
	var location_line := "ROOM %02d / 08 • RELIC ROUTE" % (dungeon.depth + 1) if dungeon.active else "WAVE %02d • %s" % [wave, hud_region]
	if retention.siege: location_line="ROUND %02d • RELIC SIEGE" % wave
	if dungeon.active and dungeon.depth < 0: location_line = "RELIC ROUTE • CHOOSE PATH"
	if retention.targeted: location_line="ROOTGLASS VAULT • %s" % ("CHOOSE PATH" if dungeon.depth<0 else "ROOM %02d" % (dungeon.depth+1))
	draw_string(body_font, Vector2(60, 52), location_line, HORIZONTAL_ALIGNMENT_LEFT, 174, 11, Color("#bac9eb"))
	var coin_pulse := clampf(coin_counter_flash / 0.24, 0.0, 1.0)
	var resource_center := Vector2(353,29)
	var resource_radius := 10.0+coin_pulse*3.0
	LootlingsUI.draw_icon(get_canvas_item(),LootlingsUI.icon("currency_run_scrip" if retention.siege else "currency_gold"),Rect2(resource_center-Vector2.ONE*resource_radius,Vector2.ONE*resource_radius*2))
	var hud_value: int=coins if retention.siege else gold
	draw_string(body_font,Vector2(370,36),preload("res://display_numbers.gd").compact(hud_value),HORIZONTAL_ALIGNMENT_LEFT,80,18,Color("#ffe078"))
	draw_string(body_font,Vector2(334,51),"EMBERS" if retention.siege else "LOOTCOINS",HORIZONTAL_ALIGNMENT_CENTER,132,11,Color("#9fddff"))
	# A readable, named progression track; Ward has its own blue protection lane.
	var xp_width := 294.0 if player_ward > 0 else 444.0
	var xp_caption := "XP %s / %s  ·  NEXT LV %d" % [preload("res://display_numbers.gd").compact(int(xp)), preload("res://display_numbers.gd").compact(int(xp_needed)), level+1]
	draw_string(body_font,Vector2(18,94),xp_caption,HORIZONTAL_ALIGNMENT_LEFT,xp_width,LootlingsUI.fitted_font_size(body_font,xp_caption,xp_width,12,11),Color("#b8dded"))
	draw_bar(Rect2(18,99,xp_width,8),xp/maxf(1,xp_needed),Color.BLACK,Color.WHITE,"",10)
	if xp_counter_flash > 0:
		draw_rect(Rect2(18,99,xp_width,8),Color(.45,.90,1,clampf(xp_counter_flash/.24,0,1)*.22))
	if player_ward > 0:
		draw_string(body_font,Vector2(332,94),"WARD %s" % preload("res://display_numbers.gd").compact(int(ceil(player_ward))),HORIZONTAL_ALIGNMENT_CENTER,130,12,Color("#b6ecff"))
		LootlingsUI.draw_meter(get_canvas_item(),Rect2(332,99,130,8),player_ward/maxf(1,player_max_hp),"xp")
	draw_bar(Rect2(60,57,402,24),player_hp/maxf(1,player_max_hp),Color.BLACK,Color.WHITE,"LV %d · HP %.0f / %.0f" % [level,maxf(0,player_hp),player_max_hp],14,combat_presentation.health_ratio(-1))
	if player_hp > 0 and player_hp/player_max_hp <= .25:
		draw_rect(Rect2(60,57,402,24),Color("#ffa278"),false,1.5)

func draw_arena(shake: Vector2) -> void:
	if state=="playing":preload("res://regional_atmosphere.gd").draw(self,campaign_id,run_time,audio_settings.get("cinematic_reduced_motion",false))
	var show_combat_context := state == "playing"
	var enemy_color := Color("#ff6f87") if enemy_is_boss else Color("#bf80ff") if enemy_is_miniboss else Color("#73d7a2")
	if enemy_flash > 0.0:
		enemy_color = Color.WHITE
	var special_entering := enemy_alive and (enemy_is_boss or enemy_is_miniboss) and enemy_entry_anim > 0.18
	if enemy_alive and show_combat_context and not special_entering and not enemy_encounter.active:
		var name_layout:=combat_presentation.enemy_name_layout(self)
		var enemy_name_size:int=name_layout.font_size
		var enemy_hud_x := 40.0 if enemy_is_boss else (255.0 if enemy_stage_x >= player_x else 30.0)
		var enemy_hud_width := 400.0 if enemy_is_boss else 195.0
		var enemy_hud_y := 243.0 if enemy_is_boss else 294.0
		if not enemy_is_boss: enemy_hud_x=clampf(target_combat_visual_position().x-enemy_hud_width*.5,16,480-enemy_hud_width-16)
		var name_lines:Array=name_layout.lines
		var name_extra:float=name_layout.extra
		draw_style_box(LootlingsUI.skin_style("hud_header_9slice"),Rect2(enemy_hud_x-10,enemy_hud_y-26,enemy_hud_width+20,64+name_extra))
		for line in range(name_lines.size()):draw_string(body_font, Vector2(enemy_hud_x, enemy_hud_y+line*18), name_lines[line], HORIZONTAL_ALIGNMENT_CENTER, enemy_hud_width, enemy_name_size, Color("#f4f7ff"))
		draw_bar(Rect2(100 if enemy_is_boss else enemy_hud_x, enemy_hud_y+12+name_extra, 280 if enemy_is_boss else 195, 16), enemy_hp / enemy_max_hp, Color("#4b263d"), Color("#ffad45") if enemy_is_boss else Color("#ff6279"), "%.0f / %.0f" % [enemy_hp, enemy_max_hp], 12, combat_presentation.health_ratio(enemy_serial))
		var status_x := 165.0 if enemy_is_boss else enemy_hud_x+32
		var status_y := (283.0 if enemy_is_boss else enemy_hud_y+51)+name_extra
		if enemy_burn_dps > 0.0:
			draw_status_chip(Vector2(status_x, status_y), "BURN", build.color("Fire"), "status_burn")
			status_x += 80.0
		if enemy_poison_stacks > 0:
			draw_status_chip(Vector2(status_x, status_y), "TOXIN ×%d" % enemy_poison_stacks, build.color("Poison"), "status_poison")
		if not enemy_variant_id.is_empty() and wave_banner_timer <= 0.0:
			var variant := EnemyVariantCatalog.definition(enemy_variant_id)
			draw_status_chip(Vector2(240 if enemy_is_boss else enemy_hud_x+enemy_hud_width*.5, (310 if enemy_is_boss else enemy_hud_y+76)+name_extra), enemy_variant_name, enemy_variant_color, EnemyVariantCatalog.icon_id(enemy_variant_id))
	var player_pos := WeaponFit.world_position(self) + shake
	combat_companion.draw_world(self,preload("res://companion_catalog.gd").sanitize(profile.get("companion",{})),audio_settings.get("cinematic_reduced_motion",false))
	draw_lootling(player_pos, player_flash > 0.0)
	if enemy_encounter.active:
		enemy_encounter.draw(self, shake)
	elif enemy_alive:
		var entry_offset := ease(enemy_entry_anim / 0.55, 2.0) * 95.0
		var behavior_offset := Vector2.ZERO
		if enemy_is_boss:
			behavior_offset = Vector2(sin(run_time * 1.7) * 2.0, sin(run_time * 2.1) * 2.5)
		elif enemy_is_miniboss:
			behavior_offset = Vector2(0.0, sin(run_time * 2.0) * 1.2)
		else:
			match enemy_archetype:
				"skirmisher": behavior_offset = Vector2(-maxf(0.0, 1.0 - enemy_attack_clock / 0.18) * 18.0, sin(run_time * 8.0) * 3.0)
				"tank": behavior_offset = Vector2(0, sin(run_time * 2.2) * 1.0)
				"hexer": behavior_offset = Vector2(12.0 + sin(run_time * 2.5) * 6.0, sin(run_time * 3.2) * 5.0)
		var enemy_attack_ratio := clampf(enemy_attack_anim / 0.18, 0.0, 1.0)
		var enemy_lunge: float = preload("res://boss_presentation.gd").profile(campaign_id).attack_distance if enemy_is_boss else 10.0 if enemy_is_miniboss or enemy_archetype == "tank" else 15.0
		behavior_offset.x -= enemy_attack_ratio * enemy_lunge
		behavior_offset.y=0 # Grounded bodies breathe about their feet, not by floating.
		behavior_offset.x*=-enemy_facing_at(enemy_stage_x)
		var enemy_pos := preload("res://combat_stage.gd").enemy_position(self,enemy_stage_x) + Vector2((enemy_recoil + entry_offset)*-enemy_facing_at(enemy_stage_x),0) + behavior_offset + shake
		draw_enemy(enemy_pos, enemy_color)
		if show_combat_context: combat_presentation.draw_cue(self, Vector2(target_combat_visual_position().x, preload("res://combat_stage.gd").GROUND_Y+2) + shake)
	elif enemy_death_anim > 0.0:
		var death_duration := 0.82 if enemy_is_boss else 0.70 if enemy_is_miniboss else 0.62
		var death_progress := 1.0 - enemy_death_anim / death_duration
		var death_color := enemy_color
		death_color.a = 1.0 - death_progress
		draw_enemy(preload("res://combat_stage.gd").enemy_position(self,enemy_stage_x)+Vector2(death_progress * 12.0*-enemy_facing_at(enemy_stage_x),0) + shake, death_color, 1.0)
	if status_clock > 0.0 and show_combat_context:
		draw_rect(Rect2(67, 662, 346, 36), Color("#091127d6"), true)
		draw_rect(Rect2(67, 662, 346, 36), Color("#b98b477a"), false, 1)
		draw_string(body_font, Vector2(79, 687), status_message, HORIZONTAL_ALIGNMENT_CENTER, 322, 17, Color("#ffe797"))
	creature_renderer.draw_striking_blade(self,player_pos)
	if show_combat_context:
		if proc_timer > 0.0 and proc_texture != null:
			draw_texture_rect(proc_texture,Rect2(18,678,24,24),false,Color(1,1,1,minf(1,proc_timer*3)))

func draw_lootling(pos: Vector2, hurt: bool) -> void:
	creature_renderer.draw_lootling(self, pos, hurt)

func draw_enemy(pos: Vector2, color: Color, extra_scale: float = 1.0) -> void:
	creature_renderer.draw_enemy(self, pos, color, extra_scale)

func draw_stats_strip() -> void:
	hud_build_surface.draw(get_canvas_item(), Rect2(18, 754, 444, 48))
	var identity := build.dominant()
	var core_title := "DORMANT CORE" if identity == "Neutral" else "%s CORE • %s" % [identity.to_upper(), build.tier_name(identity)]
	LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.icon("core_%s" % identity.to_lower()), Rect2(28, 767, 20, 20))
	draw_string(body_font, Vector2(56, 785), "%s • %s" % [current_weapon_family(),core_title], HORIZONTAL_ALIGNMENT_LEFT, 296, 12, Color("#f1d486"))
	draw_string(body_font, Vector2(362,785),"DETAILS: PAUSE",HORIZONTAL_ALIGNMENT_CENTER,90,10,Color("#b1c7eb"))

func draw_status_chip(pos: Vector2, text_value: String, color: Color, icon_name: String) -> void:
	var width := clampf(body_font.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 26.0, 72.0, 140.0)
	var rect := Rect2(pos.x - width * 0.5, pos.y - 12.0, width, 19.0)
	draw_rect(rect, Color("#080f24df"), true)
	draw_rect(rect, Color(color.r, color.g, color.b, 0.78), false, 1.5)
	LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.icon(icon_name), Rect2(rect.position + Vector2(3, 2), Vector2(15, 15)))
	draw_string(body_font, Vector2(rect.position.x + 22, pos.y + 3), text_value, HORIZONTAL_ALIGNMENT_CENTER, width - 25, 10, Color("#f5f7ff"))

func build_summary() -> String:
	return build.short_summary()

func draw_bar(rect: Rect2, ratio: float, _back: Color, _fill: Color, text_value: String, font_size: int, trail_ratio: float = -1.0) -> void:
	var kind := ("xp" if rect.size.y<=12 else "health") if rect.position.y<140 else "enemy"
	LootlingsUI.draw_meter(get_canvas_item(), rect, ratio, kind, trail_ratio)
	if not text_value.is_empty():
		var baseline := rect.position + Vector2(4,rect.size.y-5)
		draw_string_outline(body_font,baseline,text_value,HORIZONTAL_ALIGNMENT_CENTER,rect.size.x-8,font_size,2,Color("#071225"))
		draw_string(body_font,baseline,text_value,HORIZONTAL_ALIGNMENT_CENTER,rect.size.x-8,font_size,Color.WHITE)

func draw_effects() -> void:
	if state in ["result","relic_spinner"]:return # Keep transient combat/drop receipts out of outcome panels.
	if state == "hoard_chest":
		draw_hoard_chest()
	for drop in loot_drops:
		draw_loot_drop(drop)
	draw_attack_projectiles()
	for pickup in reward_pickups: PickupPresentation.draw_reward(self,pickup)
	for particle in particles:
		var alpha: float = clampf(particle.life / particle.max_life, 0.0, 1.0)
		var color: Color = particle.color
		color.a = alpha
		draw_circle(particle.pos, 3.0 + 3.0 * alpha, color)
	var impact_center := target_combat_visual_position()+Vector2(enemy_recoil*-enemy_facing_at(target_combat_position().x),-29)
	preload("res://impact_presentation.gd").contact(self,impact_center)
	if element_flash > 0.0:
		preload("res://impact_presentation.gd").element(self,impact_center,element_flash_identity,clampf(element_flash/.24,0,1))
	if death_burst > 0.0:
		var burst_duration := 0.90 if enemy_is_boss else 0.56 if enemy_is_miniboss else 0.46
		var death_ratio := clampf(death_burst / burst_duration, 0.0, 1.0)
		var burst_color := death_burst_color
		burst_color.a = death_ratio * 0.75
		var burst_center := Vector2(enemy_stage_x, 462)
		draw_arc(burst_center, 34.0 + (1.0 - death_ratio) * 62.0, 0.0, TAU, 32, burst_color, 5.0 * death_ratio + 1.0)
		var ray_count := 18 if enemy_is_boss else 11 if enemy_is_miniboss else 10
		for ray in range(ray_count):
			var direction := Vector2.RIGHT.rotated(TAU * ray / float(ray_count) + 0.16)
			draw_line(burst_center + direction * 28.0, burst_center + direction * (58.0 + (1.0 - death_ratio) * 30.0), burst_color, 3.0)
	if upgrade_flash > 0.0:
		var core_ratio := clampf(upgrade_flash / 1.1, 0.0, 1.0)
		var core_color := build.color()
		core_color.a = core_ratio * 0.75
		var core_center := Vector2(player_x + 16, 474)
		draw_arc(core_center, 18.0 + (1.0 - core_ratio) * 62.0, 0.0, TAU, 36, core_color, 5.0)
		draw_arc(core_center, 30.0 + (1.0 - core_ratio) * 84.0, -0.5, 4.9, 30, core_color.lightened(0.3), 2.5)
	if player_reward_flash > 0.0:
		var reward_ratio := player_reward_flash / 0.55
		var reward_color := player_reward_color
		reward_color.a = reward_ratio * 0.8
		draw_arc(Vector2(player_x, 470), 35.0 + (1.0 - reward_ratio) * 48.0, 0.0, TAU, 30, reward_color, 4.0)
	if tap_buffer_flash > 0.0:
		var buffer_ratio := tap_buffer_flash / 0.18
		draw_arc(Vector2(player_x + 12, 468), 22.0 + (1.0 - buffer_ratio) * 12.0, -0.6, 4.8, 22, Color(0.55, 0.92, 1.0, buffer_ratio * 0.72), 2.5)
	for item in floating_texts:
		if item.has("number_kind"):
			preload("res://combat_numbers.gd").draw(self,item)
			continue
		var alpha: float = clampf(item.life / minf(.22,item.max_life), 0.0, 1.0)
		var color: Color = item.color
		color.a = alpha
		var text_size: int = item.size
		while text_size > 12 and body_font.get_string_size(item.text,HORIZONTAL_ALIGNMENT_LEFT,-1,text_size).x > 300:
			text_size -= 1
		var text_width := maxf(150,body_font.get_string_size(item.text,HORIZONTAL_ALIGNMENT_LEFT,-1,text_size).x+4)
		var actor_label: bool = item.get("lane", "damage") in ["damage", "player"]
		var text_left: float = item.pos.x - text_width * .5 if actor_label else item.pos.x
		var text_pos: Vector2 = Vector2(clampf(text_left,10,470-text_width),item.pos.y)
		draw_string(body_font, text_pos + Vector2(2, 2), item.text, HORIZONTAL_ALIGNMENT_CENTER, text_width, text_size, Color(0.02, 0.03, 0.08, alpha * 0.80))
		draw_string_outline(body_font, text_pos, item.text, HORIZONTAL_ALIGNMENT_CENTER, text_width, text_size, 2, Color(0.02, 0.03, 0.08, alpha * 0.92))
		draw_string(body_font, text_pos, item.text, HORIZONTAL_ALIGNMENT_CENTER, text_width, text_size, color)

func draw_attack_projectiles() -> void:
	for projectile in attack_projectiles: ProjectilePresentation.draw_projectile(self,projectile)
	for effect in projectile_impacts: ProjectilePresentation.draw_impact(self,effect)

func draw_hoard_chest() -> void:
	var center := Vector2(HOARD_CHEST_X, hoard_chest_y)
	var reduced: bool=audio_settings.get("cinematic_reduced_motion",false)
	var ready_pulse := (0.35 if reduced else (0.5 + 0.5 * sin(run_time * 5.0))) if hoard_chest_phase == "ready" else 0.0
	var anticipation := maxf(0.01, float(hoard_reveal_profile.get("anticipation", 0.62)))
	var windup := 1.0 - clampf(hoard_chest_timer / anticipation, 0.0, 1.0) if hoard_chest_phase == "windup" else 0.0
	var reveal_charge := windup if hoard_chest_phase == "windup" else 1.0 if hoard_chest_phase == "silence" else 0.0
	var shake_amount := 0.0 if reduced else ready_pulse * 0.018 + reveal_charge * reveal_charge * 0.055
	draw_set_transform(center, sin(run_time * (18.0 + reveal_charge * 12.0)) * shake_amount, Vector2(1.0 + ready_pulse * 0.025 + reveal_charge * 0.06, 1.0 - ready_pulse * 0.018 - reveal_charge * 0.04))
	draw_circle(Vector2(0, 37), 66 + ready_pulse * 10, Color(1.0, 0.72, 0.20, 0.08 + ready_pulse * 0.12))
	draw_set_transform(center + Vector2(0, 58), 0.0, Vector2(1.0, 0.25))
	draw_circle(Vector2.ZERO, 70, Color("#03061299"))
	draw_set_transform(center, sin(run_time * (18.0 + reveal_charge * 12.0)) * shake_amount, Vector2(1.0 + ready_pulse * 0.025 + reveal_charge * 0.06, 1.0 - ready_pulse * 0.018 - reveal_charge * 0.04))
	if reveal_charge > 0.0:
		for leak_index in range(3):
			var leak_x := -42.0 + leak_index * 42.0
			draw_colored_polygon(PackedVector2Array([Vector2(leak_x - 7, 7), Vector2(leak_x + 7, 7), Vector2(leak_x + 20, -64 - reveal_charge * 28)]), Color(0.78, 0.52, 1.0, reveal_charge * 0.12))
	draw_texture_rect(HOARD_CHEST_TEXTURE, Rect2(-83, -65, 166, 140), false, Color.WHITE)
	if hoard_chest_phase in ["windup", "silence"]:
		draw_arc(Vector2.ZERO, 79 + reveal_charge * 42, 0, TAU, 32, Color(1.0, 0.87, 0.38, 0.25 + reveal_charge * 0.75), 3.0 + reveal_charge * 3.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_loot_drop(drop: Dictionary) -> void:
	if bool(drop.get("relic_chest", false)):
		var progress := clampf((1.15 - float(drop.pickup)) / 1.15, 0, 1)
		var land := clampf(progress / 0.18, 0, 1)
		var chest_center := Vector2(345, 497 - (1.0 - land * land) * 78)
		var opening := clampf((progress - 0.24) / 0.30, 0, 1)
		PresentationDirector.draw_chest(self, chest_center, "relic", opening, minf(1.0, (1.0 - progress) / 0.22), 0.80, sin(clampf((progress - 0.18) / 0.10, 0, 1) * PI))
		if progress < 0.40: return
	PickupPresentation.draw_item(self,drop)

func draw_moment_overlay() -> void:
	if rarity_reveal_flash > 0.0:
		var rarity_alpha := clampf(rarity_reveal_flash / 0.34, 0.0, 1.0)
		var rarity_edge := rarity_reveal_color
		rarity_edge.a = rarity_alpha * 0.72
		draw_rect(Rect2(5, 151, 470, 545), rarity_edge, false, 5.0)
		draw_circle(Vector2(240, 430), 84.0 + (1.0 - rarity_alpha) * 76.0, Color(rarity_edge.r, rarity_edge.g, rarity_edge.b, rarity_alpha * 0.08))
	if impact_flash > 0.0:
		var flash_alpha := clampf(impact_flash * 1.8, 0.0, 0.08)
		draw_rect(Rect2(0, 146, 480, 555), Color(1.0, 0.94, 0.68, flash_alpha), true)
	if tap_pulse > 0.0 and tap_combo > 1:
		var pulse_alpha := clampf(tap_pulse / 0.18, 0.0, 1.0)
		draw_rect(Rect2(18,712,114,26),Color("#08152acc"))
		draw_string(body_font, Vector2(24,730), "COMBO ×%d" % tap_combo, HORIZONTAL_ALIGNMENT_LEFT, 102, 13, Color(0.72, 0.98, 1.0, pulse_alpha))
	if wave_banner_timer > 0.0:
		var fade := clampf(wave_banner_timer * 2.5, 0.0, 1.0)
		var banner_color := wave_banner_color
		banner_color.a = fade
		var important := wave_banner_text.contains("BOSS") or wave_banner_text.contains("FINAL")
		if important:
			draw_rect(Rect2(72, 276, 336, 50), Color(0.03, 0.06, 0.16, 0.78 * fade), true)
			draw_rect(Rect2(72, 276, 336, 2), banner_color, true)
			draw_rect(Rect2(72, 324, 336, 2), banner_color, true)
			draw_string(title_font, Vector2(84, 310), wave_banner_text, HORIZONTAL_ALIGNMENT_CENTER, 312, 20, banner_color)
		else:
			draw_rect(Rect2(100, 264, 280, 38), Color(0.03, 0.06, 0.16, 0.82 * fade), true)
			draw_rect(Rect2(100, 264, 280, 2), banner_color, true)
			draw_string(title_font, Vector2(110, 291), wave_banner_text, HORIZONTAL_ALIGNMENT_CENTER, 260, 17, banner_color)

func save_home_preferences(home: Dictionary, companion: Dictionary) -> bool:
	if state!="personal_home" or personal_home.view not in ["preferences","companions","decor","decor_preview"]:return false
	var next:=profile.duplicate(true);next.homestead=home;next.companion=companion;next=ProfileStore.sanitize(next)
	if ProfileStore.save_profile(PROFILE_SAVE_PATH,next)!=OK:return false
	profile=next;hideout_ui.profile=profile.duplicate(true);hideout_ui.refresh_home_settings();hideout_ui.refresh_home();hideout_ui.queue_redraw()
	personal_home.queue_redraw()
	return true

func show_personal_home(view: String="room") -> void:
	hideout_ui.private_return=false;personal_home.open(view)

func show_profile_from_personal_home() -> void:
	personal_profile_return=true;personal_home.visible=false
	show_profile_from_hideout()
	state="personal_profile"

func show_personal_stash() -> void:
	personal_home.visible=false;state="hideout";hideout_ui.visible=true;hideout_ui.private_return=true;hideout_ui.show_stash()
