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
const StartupUI = preload("res://startup_ui.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")
const Avatar = preload("res://avatar_presentation.gd")
const WandererPose = preload("res://wanderer_pose_catalog.gd")
const ItemIcon = preload("res://item_icon.gd")
const DebugPanel = preload("res://debug_panel.gd")
const PresentationDirector = preload("res://presentation_director.gd")
const LootlingsUI = preload("res://lootlings_ui.gd")
const AffixCatalog = preload("res://affix_catalog.gd")
const EnemyVariantCatalog = preload("res://enemy_variant_catalog.gd")
const AchievementManager = preload("res://achievement_manager.gd")
const RewardRevealCatalog = preload("res://reward_reveal_catalog.gd")
const VANGUARD_WEAPON_TEXTURE = preload("res://art/sprites/weapons/vanguard_hammer.png")
const RANGER_WEAPON_TEXTURE = preload("res://art/sprites/weapons/ranger_bow.png")
const MAGE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/mage_staff.png")
const ROGUE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/rogue_daggers.png")
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
var status_message := "Tap anywhere to help!"
var status_clock := 4.0
var tap_combo := 0
var combo_clock := 0.0
var tap_buffer_timer := 0.0
var tap_input_cooldown := 0.0
var tap_buffer_flash := 0.0
var tap_tutorial_seen := false
var meta_shards := 0
var meta_power := 0
var gold := 0
var gold_upgrades := {"bedroll":0, "whetstone":0, "pouch":0}
var run_gold_earned := 0
var run_shards_earned := 0
var run_coins_earned := 0
var run_coins_spent := 0
var run_damage_taken := 0.0
var run_start_scrap := 0
var run_kept_loot: Array[String] = []
var upgrade_panel: Panel
var upgrade_title: Label
var upgrade_buttons: Array[Button] = []
var result_panel: Panel
var result_title: Label
var result_crest: TextureRect
var result_summary: RichTextLabel
var upgrade_visuals: Array[Dictionary] = []
var hud_header_surface := LootlingsUI.skin_style("hud_header_9slice", 32)
var hud_build_surface := LootlingsUI.skin_style("hud_build_ribbon_9slice", 32)
var restart_button: Button
var help_label: Label
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
var boss_reward_buttons: Array[Button] = []
var boss_reward_icons: Array = []
var hoard_chest_button: Button
var pause_button: Button
var pause_panel: Panel
var abandon_panel: Panel
var hideout_ui
var startup_ui
var audio_manager
var presentation_director
var debug_panel
var debug_enabled := false
var debug_god_mode := false
var debug_weapon_family_override := ""
var attack_projectiles: Array = []
var enemy_serial := 0
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
	rng.randomize()
	visual_rng.randomize()
	title_font = ThemeDB.fallback_font
	body_font = ThemeDB.fallback_font
	build_overlay_ui()
	load_meta()
	profile = ProfileStore.load_profile(PROFILE_SAVE_PATH)
	audio_settings = SettingsStore.load_settings(SETTINGS_SAVE_PATH)
	inventory.load(INVENTORY_SAVE_PATH)
	hideout_shop.load(HIDEOUT_SHOP_SAVE_PATH)
	hideout_shop.save(HIDEOUT_SHOP_SAVE_PATH)
	build_hideout()
	build_foundation_services()
	build_presentation_director()
	build_debug_tools()
	show_startup()
	AnalyticsLogger.log_event(ANALYTICS_PATH, "app_start", {"profile_exists":ProfileStore.is_created(profile)})
	queue_redraw()

func build_presentation_director() -> void:
	presentation_director = PresentationDirector.new()
	add_child(presentation_director)
	presentation_director.bind_buttons(self)

func build_debug_tools() -> void:
	debug_enabled = DebugPanel.allowed(OS.is_debug_build())
	if not debug_enabled:
		return
	debug_panel = DebugPanel.new()
	add_child(debug_panel)
	debug_panel.configure(self)

func current_weapon_family() -> String:
	if debug_enabled and not debug_weapon_family_override.is_empty():
		return debug_weapon_family_override
	return inventory.weapon_family()

func debug_snapshot() -> String:
	return "STATE %s  •  WAVE %d  •  SEED %d\nHP %.0f/%.0f  •  %s  •  %s\nBUILD %s" % [state.to_upper(), wave, rng.seed, player_hp, player_max_hp, current_weapon_family(), "GOD ON" if debug_god_mode else "GOD OFF", build.short_summary()]

func debug_action(action: String, payload) -> String:
	if not debug_enabled:
		return "Debug tools are disabled."
	match action:
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
			gold += int(payload); save_meta(); refresh_hideout()
			return "Added %d Gold and saved." % int(payload)
		"scrap":
			inventory.scrap += int(payload); inventory.save(INVENTORY_SAVE_PATH); refresh_hideout()
			return "Added %d Scrap and saved." % int(payload)
		"shards":
			meta_shards += int(payload); save_meta(); refresh_hideout()
			return "Added %d Star Shards and saved." % int(payload)
		"scrip":
			debug_ensure_run(); coins += int(payload)
			return "Added %d run-only Scrip." % int(payload)
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
	for panel in [upgrade_panel, item_panel, merchant_panel, boss_reward_panel, result_panel]:
		panel.visible = false
	spawn_enemy()

func debug_force_drop(rarity: String) -> void:
	debug_ensure_run()
	var definition: Dictionary = ItemCatalog.ITEMS[rng.randi_range(0, ItemCatalog.ITEMS.size() - 1)]
	var item := ItemCatalog.create_item(definition.id, rarity, rng.randi())
	item = AffixCatalog.apply(item, AffixCatalog.roll_for_item(item, loot_system.rng))
	loot_drops.append({"item":item, "rarity":rarity, "boss_choice":false, "pos":Vector2(350, 430), "vel":Vector2(-70, -225), "pickup":1.0, "bounces":0, "squash":0.0, "color":ItemCatalog.rarity_color(rarity)})
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
	state = "result"
	for panel in [upgrade_panel, item_panel, merchant_panel, boss_reward_panel]:
		panel.visible = false
	result_panel.visible = true
	result_title.text = "HOARD CONQUERED!" if victory else "BONKED OUT!"
	result_crest.texture = LootlingsUI.icon("res://art/ui/results/%s_crest.png" % ("victory" if victory else "defeat"))
	LootlingsUI.apply_material(result_panel, "hoard" if victory else "danger")
	result_title.add_theme_color_override("font_color", Color("#ffe178") if victory else Color("#ff8995"))
	result_summary.text = style_result_summary("DEVELOPMENT PREVIEW\nNo rewards, stock refresh, or save changes.\n\nWave reached  %d / %d\nEnemies  %d" % [wave, RUN_LAST_WAVE, total_kills])
	help_label.visible = false

func debug_reset_lootlings_saves() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	var exact_paths := [SAVE_PATH, INVENTORY_SAVE_PATH, HIDEOUT_SHOP_SAVE_PATH, PROFILE_SAVE_PATH, SETTINGS_SAVE_PATH, ANALYTICS_PATH, achievements.path]
	for path in exact_paths:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
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
	startup_ui.configure(profile, ProfileStore.is_created(profile), audio_settings)

func show_startup() -> void:
	state = "boot"
	hideout_ui.visible = false
	startup_ui.visible = true
	startup_ui.show_boot()
	audio_manager.set_music("TITLE")

func enter_hideout_from_title() -> void:
	AnalyticsLogger.log_event(ANALYTICS_PATH, "title_enter")
	show_hideout()

func request_enter_hideout() -> void:
	AnalyticsLogger.log_event(ANALYTICS_PATH, "title_enter")
	if presentation_director == null:
		show_hideout()
		return
	presentation_director.play_travel("THE HIDEOUT", "Warm lanterns, stranger treasure, and one suspiciously empty snack barrel.", Color("#ffd468"), Callable(self, "show_hideout"), 0.48)

func show_profile_from_hideout() -> void:
	hideout_ui.visible = false
	startup_ui.visible = true
	startup_ui.show_profile(false)
	if presentation_director != null:
		presentation_director.present_card(startup_ui, Color("#72c8ff"), 0.22)

func show_title_from_hideout() -> void:
	hideout_ui.visible = false
	startup_ui.visible = true
	startup_ui.show_title()
	state = "boot"
	audio_manager.set_music("TITLE")
	if presentation_director != null:
		presentation_director.present_card(startup_ui, Color("#d1a85a"), 0.22)

func save_profile_data(updated_profile: Dictionary) -> void:
	var was_created := ProfileStore.is_created(profile)
	var old_name := str(profile.get("display_name", ""))
	profile = updated_profile.duplicate(true)
	ProfileStore.save_profile(PROFILE_SAVE_PATH, profile)
	AnalyticsLogger.log_event(ANALYTICS_PATH, "display_name_changed" if was_created and old_name != profile.display_name else "profile_created")
	if hideout_ui != null:
		hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)

func save_audio_settings(updated_settings: Dictionary) -> void:
	audio_settings = updated_settings.duplicate(true)
	SettingsStore.save_settings(SETTINGS_SAVE_PATH, audio_settings)
	audio_manager.apply_settings(audio_settings)

func play_audio_event(event_name: String) -> void:
	if audio_manager != null:
		audio_manager.play_event(event_name)

func award_achievement(id: String, amount: int = 1, set_value: bool = false) -> void:
	var unlocked_now := achievements.set_progress(id, amount) if set_value else achievements.add_progress(id, amount)
	if not unlocked_now:
		return
	var entry := AchievementManager.definition_for(id)
	if hideout_ui != null:
		hideout_ui.queue_dialogue_context("trophy_earned")
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
	upgrade_panel = make_panel(Rect2(22, 205, 436, 470), Color("#172042f2"))
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
		button.pressed.connect(choose_upgrade.bind(i))
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
		var effect := make_label(button, "", 14, Rect2(80, 57, 286, 32), HORIZONTAL_ALIGNMENT_LEFT, Color("#c9d6e9"))
		effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		for label in [kicker, name_label, effect]:
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.clip_text = true
		upgrade_visuals.append({"kicker":kicker, "name":name_label, "effect":effect, "icon":icon, "core":core_icon, "rarity":rarity_icon})
	make_label(upgrade_panel, "Every pick stacks. Make something silly.", 15, Rect2(20, 438, 396, 24), HORIZONTAL_ALIGNMENT_CENTER, Color("#aebee8"))
	result_panel = make_panel(Rect2(28, 155, 424, 555), Color("#151b39f5"))
	LootlingsUI.apply_material(result_panel, "hoard")
	result_panel.visible = false
	result_title = make_label(result_panel, "RUN COMPLETE!", 27, Rect2(96, 25, 308, 55), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	result_crest = LootlingsUI.add_icon(result_panel, Rect2(16, 30, 78, 34), "res://art/ui/results/victory_crest.png")
	result_summary = RichTextLabel.new()
	result_summary.position = Vector2(35, 91)
	result_summary.size = Vector2(354, 318)
	result_summary.bbcode_enabled = true
	result_summary.scroll_active = false
	result_summary.add_theme_font_size_override("normal_font_size", 14)
	result_summary.add_theme_color_override("default_color", Color("#e9efff"))
	result_panel.add_child(result_summary)
	LootlingsUI.add_divider(result_panel, Rect2(50, 80, 324, 10), "gold")
	restart_button = Button.new()
	restart_button.text = "RETURN TO HIDEOUT"
	restart_button.position = Vector2(47, 425)
	restart_button.size = Vector2(330, 68)
	restart_button.add_theme_font_size_override("font_size", 20)
	apply_button_style(restart_button, Color("#795523"), Color("#ffd468"))
	restart_button.pressed.connect(show_hideout)
	result_panel.add_child(restart_button)
	help_label = make_label(self, "TAP TO STRIKE • Auto-combat stays active", 16, Rect2(20, 812, 440, 32), HORIZONTAL_ALIGNMENT_CENTER, Color("#c6d8f4"))
	build_item_ui()
	build_merchant_ui()
	build_boss_reward_ui()
	build_hoard_chest_ui()
	build_route_ui()
	build_pause_ui()

func build_pause_ui() -> void:
	pause_button = Button.new()
	pause_button.text = "Ⅱ  PAUSE"
	pause_button.position = Vector2(232, 17)
	pause_button.size = Vector2(86, 42)
	pause_button.add_theme_font_size_override("font_size", 12)
	apply_button_style(pause_button, Color("#172442df"), Color("#8fa6cf"))
	pause_button.pressed.connect(pause_run)
	pause_button.visible = false
	add_child(pause_button)
	pause_panel = make_panel(Rect2(55, 244, 370, 326), Color("#101731f8"))
	LootlingsUI.apply_material(pause_panel, "relic")
	pause_panel.visible = false
	make_label(pause_panel, "RUN PAUSED", 31, Rect2(20, 32, 330, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	make_label(pause_panel, "The treasure ruins will wait.", 15, Rect2(25, 86, 320, 30), HORIZONTAL_ALIGNMENT_CENTER, Color("#aebde0"))
	make_action_button(pause_panel, "RESUME", Vector2(35, 140), Vector2(300, 64), Color("#285c4c"), Color("#69e6b0"), resume_run)
	make_action_button(pause_panel, "ABANDON RUN", Vector2(35, 226), Vector2(300, 62), Color("#54302d"), Color("#ff8d88"), request_abandon_run)
	abandon_panel = make_panel(Rect2(44, 225, 392, 374), Color("#12172ffb"))
	LootlingsUI.apply_material(abandon_panel, "danger")
	abandon_panel.visible = false
	make_label(abandon_panel, "RETURN TO HIDEOUT?", 28, Rect2(20, 30, 352, 46), HORIZONTAL_ALIGNMENT_CENTER, Color("#ff9b8f"))
	var warning := make_label(abandon_panel, "Current run progress and unclaimed\nrun rewards will be lost.", 16, Rect2(24, 96, 344, 106), HORIZONTAL_ALIGNMENT_CENTER, Color("#e6edff"))
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	make_action_button(abandon_panel, "STAY", Vector2(28, 246), Vector2(158, 68), Color("#263b58"), Color("#79a9d9"), cancel_abandon_run)
	make_action_button(abandon_panel, "RETURN HOME", Vector2(206, 246), Vector2(158, 68), Color("#5a302c"), Color("#ff8d88"), confirm_abandon_run)

func build_hideout() -> void:
	hideout_ui = HideoutUI.new()
	add_child(hideout_ui)
	campaign.load_progress("user://campaign.cfg")
	contracts.load_progress("user://contracts.cfg")
	hideout_ui.contracts = contracts
	hideout_ui.campaign = campaign
	hideout_ui.play_requested.connect(hideout_ui.show_campaign)
	hideout_ui.campaign_requested.connect(start_campaign)
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
	hideout_ui.profile_requested.connect(show_profile_from_hideout)
	hideout_ui.title_requested.connect(show_title_from_hideout)
	hideout_ui.destination_visited.connect(func(destination_id): award_unique_achievement("hideout_social", str(destination_id)))
	hideout_ui.ui_event.connect(play_audio_event)
	hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)
	hideout_ui.visible = false

func request_start_run() -> void:
	if state != "hideout":
		return
	if presentation_director == null:
		start_run()
		return
	presentation_director.play_travel("RELIC ROUTE DEPARTING" if dungeon.active else "EXPEDITION DEPARTING", "Choose a path through the sealed vaults." if dungeon.active else "The Relic Gate wakes. Outer Ruins ahead.", Color("#72c8ff"), Callable(self, "start_run"), 0.68)

func show_hideout() -> void:
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
	if inventory.equip_from_stash(index):
		award_current_weapon_family()
		inventory.save(INVENTORY_SAVE_PATH)
		hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)
		hideout_ui.play_stash_feedback("equip")
		play_audio_event("equip")
		AnalyticsLogger.log_event(ANALYTICS_PATH, "gear_equip", {"source":"stash"})

func scrap_stash_item(index: int) -> void:
	if state != "hideout":
		return
	if inventory.scrap_from_stash(index) > 0:
		inventory.save(INVENTORY_SAVE_PATH)
		hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)
		hideout_ui.play_stash_feedback("scrap")
		play_audio_event("scrap")
		AnalyticsLogger.log_event(ANALYTICS_PATH, "scrap_earned", {"source":"stash"})

func buy_hideout_offer(index: int) -> void:
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
	if inventory.scrap < price:
		hideout_ui.show_shop_message("Not enough Scrap for this offer.", "#ffbd69")
		return
	inventory.scrap -= price
	var purchased := hideout_shop.take_offer(index)
	if not inventory.keep(purchased):
		inventory.scrap += price
		hideout_ui.show_shop_message("STASH FULL\nNo Scrap was spent.", "#ff9b8f")
		return
	save_hideout_economy()
	hideout_ui.show_shop_message("PURCHASED\n%s was sent to your Stash." % purchased.get("name", "Equipment"), "#69e6b0")
	hideout_ui.play_shop_purchase(index, ItemCatalog.rarity_color(purchased.get("rarity", "COMMON")))
	hideout_ui.request_dialogue("shop_purchase", "Salvager")
	play_audio_event("shop_purchase")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "shop_purchase", {"currency":"scrap", "price":price, "item_id":purchased.get("id", "")})

func use_mystery_cache() -> void:
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
			save_hideout_economy()
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
	record_contract_chest()
	award_achievement("ten_chests")
	award_achievement("chest_50")
	award_item_discovery(hideout_shop.pending_cache_item)
	save_hideout_economy()
	hideout_ui.refresh_shop()
	hideout_ui.play_cache_reveal(ItemCatalog.rarity_color(hideout_shop.pending_cache_item.get("rarity", "COMMON")), RewardRevealCatalog.for_rewards("scavenged_cache", [hideout_shop.pending_cache_item]))
	hideout_ui.request_dialogue("cache_opened", "Salvager")
	play_audio_event("chest_open")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "chest_open", {"chest_id":"scavenged_cache", "currency":"scrap"})

func use_gold_cache() -> void:
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
			save_hideout_economy()
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
		hideout_ui.show_shop_message("Not enough Gold for a Scavenged Cache.", "#ffbd69")
		return
	gold -= hideout_shop.GOLD_CACHE_COST
	hideout_shop.reveal_gold_cache()
	record_contract_chest()
	award_achievement("ten_chests")
	award_achievement("chest_50")
	award_item_discovery(hideout_shop.pending_cache_item)
	save_meta()
	save_hideout_economy()
	hideout_ui.play_cache_reveal(ItemCatalog.rarity_color(hideout_shop.pending_cache_item.get("rarity", "COMMON")), RewardRevealCatalog.for_rewards("scavenged_cache", [hideout_shop.pending_cache_item]))
	hideout_ui.request_dialogue("cache_opened", "Salvager")
	play_audio_event("chest_land")
	play_audio_event("chest_open")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "chest_open", {"chest_id":"scavenged_cache", "currency":"gold", "price":hideout_shop.GOLD_CACHE_COST})

func buy_gold_upgrade(upgrade_id: String) -> void:
	if state != "hideout" or not upgrade_id in gold_upgrades:
		return
	var costs := {
		"bedroll":[250,450,700,1000,1400],
		"whetstone":[300,525,800,1150,1600],
		"pouch":[225,400,650,950,1300]
	}
	var rank := int(gold_upgrades[upgrade_id])
	if rank >= 5:
		return
	var price: int = costs[upgrade_id][rank]
	if gold < price:
		return
	gold -= price
	gold_upgrades[upgrade_id] = rank + 1
	save_meta()
	refresh_hideout()
	hideout_ui.show_upgrades()
	hideout_ui.play_shrine_upgrade()
	hideout_ui.request_dialogue("shrine_upgrade", "Relic Keeper")
	play_audio_event("shop_purchase")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "shop_purchase", {"currency":"gold", "price":price, "upgrade_id":upgrade_id, "rank":rank + 1})

func evolve_owned_weapon(stash_index: int) -> void:
	if state != "hideout":
		return
	var result: Dictionary = preload("res://forge_system.gd").purchase(inventory, gold, stash_index)
	if not result.ok:
		return
	gold = result.gold
	save_meta()
	save_hideout_economy()
	play_audio_event("shop_purchase")

	hideout_ui.queue_dialogue_context("forge_evolved")

func start_campaign(region_id: String) -> void:
	if state != "hideout" or not campaign.available(region_id):
		return
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
	save_meta()
	save_hideout_economy()
	play_audio_event("shop_purchase")

	hideout_ui.queue_dialogue_context("new_weapon")

func claim_contract(slot: int) -> void:
	if state != "hideout": return
	var reward := contracts.claim(slot)
	if reward <= 0: return
	contracts.save("user://contracts.cfg")
	gold += reward
	save_meta()
	refresh_hideout()
	hideout_ui.refresh_contracts()
	play_audio_event("shop_purchase")
	hideout_ui.queue_dialogue_context("contract_complete")

func record_contract_chest() -> void:
	contracts.record("chest")
	if hideout_ui != null:
		hideout_ui.queue_dialogue_context("cache_opened")
	contracts.save("user://contracts.cfg")

func run_zone_for_wave(value: int) -> Dictionary:
	return CampaignSystem.zone_for(campaign_id, value)

func buy_stash_expansion() -> void:
	if state != "hideout" or not hideout_shop.pending_cache_item.is_empty():
		return
	var price := hideout_shop.expansion_cost(inventory.stash_capacity)
	if price <= 0 or inventory.scrap < price:
		return
	inventory.scrap -= price
	if not inventory.expand_stash():
		inventory.scrap += price
		return
	save_hideout_economy()
	hideout_ui.show_shop_message("STASH EXPANDED\nCapacity increased to %d slots." % inventory.stash_capacity, "#72c8ff")

func reroll_hideout_shop() -> void:
	if state != "hideout" or hideout_shop.rerolled_this_cycle or not hideout_shop.pending_cache_item.is_empty():
		return
	if inventory.scrap < hideout_shop.REROLL_COST:
		return
	inventory.scrap -= hideout_shop.REROLL_COST
	if not hideout_shop.reroll():
		inventory.scrap += hideout_shop.REROLL_COST
		return
	save_hideout_economy()
	hideout_ui.show_shop_message("Fresh salvage has arrived.", "#ffe178")

func save_hideout_economy() -> void:
	inventory.save(INVENTORY_SAVE_PATH)
	hideout_shop.save(HIDEOUT_SHOP_SAVE_PATH)
	hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)

func build_item_ui() -> void:
	item_panel = make_panel(Rect2(24, 166, 432, 536), Color("#0b1229fc"))
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
	item_compare.position = Vector2(34, 210)
	item_compare.size = Vector2(364, 126)
	item_compare.bbcode_enabled = true
	item_compare.fit_content = false
	item_compare.scroll_active = false
	item_compare.add_theme_font_size_override("normal_font_size", 14)
	item_compare.add_theme_color_override("default_color", Color("#dce6ff"))
	item_panel.add_child(item_compare)
	LootlingsUI.add_divider(item_panel, Rect2(34, 197, 364, 9), "gold")
	item_equip_button = make_action_button(item_panel, "EQUIP", Vector2(28, 357), Vector2(176, 64), Color("#295d50"), Color("#69e6b0"), accept_item_equip)
	item_keep_button = make_action_button(item_panel, "KEEP", Vector2(228, 357), Vector2(176, 64), Color("#29486b"), Color("#74caff"), accept_item_keep)
	item_keep_button.add_theme_font_size_override("font_size", 15)
	item_scrap_button = make_action_button(item_panel, "SCRAP", Vector2(28, 442), Vector2(376, 58), Color("#5a3828"), Color("#ffbd69"), accept_item_scrap)

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
	if state != "hideout" or not "act_i" in campaign.completed: return
	dungeon.setup(dungeon.seed_value, campaign_id if campaign.available(campaign_id) else "act_i")
	request_start_run()

func reseed_route() -> void:
	if state != "route" or dungeon.depth >= 0: return
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
	route_reseed_button.visible = dungeon.depth < 0
	route_subtitle.text = "STOP %d / 8 • SEED %d" % [dungeon.depth + 2, dungeon.seed_value]
	var options: Array = dungeon.choices()
	for index in range(route_buttons.size()):
		route_buttons[index].visible = index < options.size()
		if index >= options.size(): continue
		var option: Dictionary = options[index]
		route_buttons[index].text = "%s\n%s" % [option.title, option.desc]
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
	if presentation_director == null:
		enter_route_room()
	else:
		presentation_director.play_travel(str(room.title), str(room.desc), Color("#78e4ff"), enter_route_room, 0.42)

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
	merchant_panel = make_panel(Rect2(28, 170, 424, 540), Color("#11182ee8"))
	LootlingsUI.apply_material(merchant_panel, "salvage")
	merchant_panel.visible = false
	merchant_title = make_label(merchant_panel, "PACK PEDDLER", 29, Rect2(20, 12, 384, 40), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	merchant_subtitle = make_label(merchant_panel, "ROADSIDE STOP  •  BETWEEN WAVES", 13, Rect2(26, 50, 372, 22), HORIZONTAL_ALIGNMENT_CENTER, Color("#d3b777"))
	merchant_coin_label = LootlingsUI.rich_label(merchant_panel, Rect2(54, 74, 316, 26), 16, Color("#ffe078"))
	for i in range(3):
		var button := Button.new()
		button.position = Vector2(20, 106 + i * 108)
		button.size = Vector2(384, 90)
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(buy_merchant_item.bind(i))
		merchant_panel.add_child(button)
		merchant_buttons.append(button)
		var icon := ItemIcon.new()
		icon.name = "OfferIcon%d" % i
		icon.position = Vector2(28, 119 + i * 108)
		icon.size = Vector2(64, 64)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		merchant_panel.add_child(icon)
		merchant_icons.append(icon)
		var kicker := make_label(button, "", 11, Rect2(84, 10, 284, 18), HORIZONTAL_ALIGNMENT_LEFT, Color("#c7b18b"))
		var title := make_label(button, "", 14, Rect2(84, 30, 284, 22), HORIZONTAL_ALIGNMENT_LEFT, Color("#edf0f7"))
		var effect := make_label(button, "", 12, Rect2(84, 56, 284, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#bfcbe0"))
		for label in [kicker, title, effect]:
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.clip_text = true
		merchant_visuals.append({"kicker":kicker, "name":title, "effect":effect})
	merchant_reroll_button = make_action_button(merchant_panel, "REROLL", Vector2(20, 452), Vector2(180, 62), Color("#3e315c"), Color("#c89bff"), reroll_merchant)
	merchant_continue_button = make_action_button(merchant_panel, "CONTINUE", Vector2(224, 452), Vector2(180, 62), Color("#295d50"), Color("#69e6b0"), leave_merchant)

func build_boss_reward_ui() -> void:
	boss_reward_panel = make_panel(Rect2(20, 155, 440, 570), Color("#17142ff8"))
	LootlingsUI.apply_material(boss_reward_panel, "hoard")
	boss_reward_panel.visible = false
	make_label(boss_reward_panel, "BOSS HOARD", 30, Rect2(20, 18, 400, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffd36a"))
	make_label(boss_reward_panel, "Choose one relic-grade reward", 16, Rect2(20, 64, 400, 30), HORIZONTAL_ALIGNMENT_CENTER, Color("#d9c9ff"))
	for i in range(3):
		var button := Button.new()
		button.position = Vector2(25, 112 + i * 130)
		button.size = Vector2(390, 108)
		button.add_theme_font_size_override("font_size", 15)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(choose_boss_reward.bind(i))
		boss_reward_panel.add_child(button)
		boss_reward_buttons.append(button)
		var icon := ItemIcon.new()
		icon.position = Vector2(33, 120 + i * 130)
		icon.size = Vector2(88, 88)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		boss_reward_panel.add_child(icon)
		boss_reward_icons.append(icon)

func build_hoard_chest_ui() -> void:
	hoard_chest_button = make_action_button(self, "TAP TO OPEN\nHOARD CHEST", Vector2(125, 577), Vector2(230, 72), Color("#6b431d"), Color("#ffd36a"), open_hoard_chest)
	hoard_chest_button.visible = false

func make_action_button(parent: Node, text_value: String, pos: Vector2, button_size: Vector2, fill: Color, border: Color, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = pos
	button.size = button_size
	button.add_theme_font_size_override("font_size", 18)
	apply_button_style(button, fill, border)
	button.pressed.connect(callback)
	button.pressed.connect(play_audio_event.bind("ui_press"))
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
	enemy_encounter.clear()
	loot_system.region_pool = CampaignSystem.LOOT_POOLS.get(campaign_id, []).duplicate()
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
	player_hp = player_max_hp
	base_damage = 11.0 * meta_bonus + int(gold_upgrades.get("whetstone", 0)) * 0.6
	coins = int(gold_upgrades.get("pouch", 0)) * 8
	attack_interval = 0.85
	attack_clock = 0.3
	crit_chance = 0.08
	crit_mult = 2.0
	multi_hits = 1
	splash_ratio = 0.0
	life_steal = 0.0
	armor = 0.0
	frenzy = 0.0
	tap_mult = 0.65
	tap_buffer_timer = 0.0
	tap_input_cooldown = 0.0
	tap_buffer_flash = 0.0
	tap_tutorial_seen = false
	execute_ratio = 0.0
	regen_per_second = 0.0
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
	floating_texts.clear()
	particles.clear()
	reward_pickups.clear()
	loot_drops.clear()
	pending_items.clear()
	current_item.clear()
	boss_reward_options.clear()
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
	enemy_encounter.clear()
	var encounter: Dictionary = ZoneCatalog.encounter_for(run_zone_for_wave(wave), wave, wave_kills, grouped_patrols or dungeon.active)
	if encounter.members.size() > 1:
		enemy_encounter.begin(self, mini(encounter.members.size(), ENEMIES_PER_WAVE))
	else:
		spawn_single_enemy()

func spawn_single_enemy() -> void:
	enemy_serial += 1
	attack_projectiles.clear()
	var new_wave := wave != last_spawned_wave
	current_zone = run_zone_for_wave(wave)
	current_zone_id = current_zone.id
	if new_wave:
		AnalyticsLogger.log_event(ANALYTICS_PATH, "zone_enter", {"zone_id":current_zone_id, "wave":wave})
		if audio_manager != null:
			var music_region: String = current_zone.get("future_music", "outer_ruins")
			audio_manager.set_music("BOSS" if wave == RUN_LAST_WAVE else "SALVAGE_WARRENS" if music_region == "emberworks" else "HOARD_DEPTHS" if music_region == "hoard_depths" else "OUTER_RUINS")
	enemy_is_miniboss = wave == 8
	enemy_is_boss = wave == RUN_LAST_WAVE
	# Steady curve with explicit special-enemy spikes; regular archetypes stay closer together.
	var progress := pow(1.15, wave - 1)
	var type_bonus := 1.0
	if enemy_is_boss:
		type_bonus = 4.8
		enemy_name = "THE HOARD DRAGON" if campaign_id == "act_i" else current_zone.boss
	elif enemy_is_miniboss:
		type_bonus = 2.65
		enemy_name = "GRUMP KNIGHT" if campaign_id == "act_i" else current_zone.miniboss
	else:
		enemy_archetype = ZoneCatalog.archetype_for(current_zone, wave, wave_kills)
		if dungeon.active and not dungeon.room.is_empty():
			enemy_archetype = dungeon.room.members[clampi(wave_kills, 0, dungeon.room.members.size() - 1)]
		var enemy_definition := ZoneCatalog.enemy_for(current_zone, enemy_archetype)
		enemy_name = enemy_definition.name
	enemy_max_hp = (24.0 + wave * 7.0) * progress * type_bonus
	enemy_damage = (3.5 + wave * 0.92) * (1.3 if enemy_is_miniboss else 1.0) * (1.55 if enemy_is_boss else 1.0)
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
		# New regions showcase an existing readable mechanic on one patrol every
		# third wave. Bosses/Act I are untouched; no presentation RNG is consumed.
		if CampaignSystem.REGIONAL_VARIANTS.has(campaign_id) and wave % 3 == 0 and wave_kills == 0:
			enemy_variant_id = CampaignSystem.REGIONAL_VARIANTS[campaign_id]
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
	if presentation_director != null:
		var flavor := "Deeper ruins. Stranger treasure."
		if current_zone_id == "emberworks":
			flavor = "Warm gears turn beneath the rubble. Mind the sparks."
		elif current_zone_id == "hoard_depths":
			flavor = "Ancient locks stir. Something enormous counts its coins."
		flavor = str(current_zone.get("story_line", flavor))
		presentation_director.play_travel(zone_transition_title, "%s\n%s" % [zone_transition_subtitle, flavor], current_zone.accent, Callable(), 0.78)

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
	play_audio_event("boss_warning")

func _process(delta: float) -> void:
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
	tap_input_cooldown = maxf(0.0, tap_input_cooldown - delta)
	tap_buffer_timer = maxf(0.0, tap_buffer_timer - delta)
	status_clock = maxf(0.0, status_clock - delta)
	combo_clock -= delta
	if combo_clock <= 0.0:
		tap_combo = 0
	player_hp = minf(player_max_hp, player_hp + regen_per_second * delta)
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
				show_next_item()
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
			if wave in [8, RUN_LAST_WAVE] and special_intro_wave != wave:
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
		player_x = minf(attack_position, player_x + 155.0 * delta)
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

func current_attack_interval() -> float:
	var result := attack_interval
	match current_weapon_family():
		"RANGER": result *= 0.78
		"MAGE": result *= 0.95
		"ROGUE": result *= 0.68
		_: result *= 1.18
	result *= 1.0 + inventory.effect_total("attack_slow")
	result /= 1.0 + inventory.effect_total("attack_speed")
	if frenzy > 0.0:
		result /= 1.0 + frenzy * (1.0 - player_hp / player_max_hp)
	if inventory.has_signature("desperate_rhythm") and player_hp / maxf(1.0, player_max_hp) < 0.40:
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
	if state != "playing" or not enemy_alive or tap_input_cooldown > 0.0:
		return
	tap_input_cooldown = 0.11
	if player_x < target_player_x() - 4.0:
		tap_buffer_timer = 0.45
		tap_buffer_flash = 0.18
		tap_pulse = maxf(tap_pulse, 0.10)
		queue_redraw()
		return
	perform_player_attack(true)

func effective_crit_chance() -> float:
	var family_bonus := 0.10 if current_weapon_family() == "ROGUE" else 0.06 if current_weapon_family() == "RANGER" else 0.0
	return minf(0.85, crit_chance + inventory.effect_total("crit") + family_bonus)

func equipment_damage_multiplier() -> float:
	var result := 1.0 + inventory.effect_total("damage_mult")
	if player_hp / player_max_hp < 0.4:
		result += inventory.effect_total("low_health_damage")
	if enemy_is_boss:
		result += inventory.effect_total("boss_damage")
	match current_weapon_family():
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
	play_audio_event({"VANGUARD":"vanguard_swing", "RANGER":"ranger_release", "MAGE":"mage_cast", "ROGUE":"rogue_slash"}.get(family, "tap_attack"))
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
		var launch_position := Vector2(player_x + 58.0, 427.0) if family == "RANGER" else Vector2(player_x + 46.0, 407.0)
		if subtype == "orb":
			launch_position = Vector2(player_x + 42.0, 480.0)
		elif subtype == "crossbow":
			launch_position = Vector2(player_x + 127.0, 447.0)
		elif subtype == "wand":
			launch_position = Vector2(player_x + 91.0, 393.0)
		if Avatar.is_wanderer(profile):
			launch_position = WandererPose.projectile_origin(self)
		attack_projectiles.append({
			"family": family,
			"weapon_type": subtype,
			"is_tap": is_tap,
			"pos": launch_position,
			"start": launch_position,
			"target": enemy_encounter.target_position() + Vector2(-18, -28) if enemy_encounter.active else Vector2(ENEMY_X - 28.0, 438.0),
			"life": travel_time,
			"max_life": travel_time,
			"enemy_serial": enemy_serial
		})
		squash = 0.12
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
		enemy_attack_clock += 0.18
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
		damage_enemy(damage, is_crit, is_tap, is_heavy and hit_index == 0)
		if enemy_alive and enemy_serial == aoe_origin and is_crit and inventory.effect_total("crit_lightning") > 0.0:
			deal_elemental_hit(base_damage * inventory.effect_total("crit_lightning"), "Lightning")
		if enemy_alive and enemy_serial == aoe_origin and is_crit and inventory.has_signature("first_crit_spark") and not enemy_first_crit_used:
			enemy_first_crit_used = true
			deal_elemental_hit(base_damage * 0.42, "Lightning")
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
		if evolution_data.has("slow"): enemy_attack_clock += float(evolution_data.slow[stage - 1])
		if extra > 0: deal_elemental_hit(extra, identity)
	if extra > 0 and bool(evolution_data.get("splash", false)) and enemy_encounter.active:
		enemy_encounter.splash(self, extra, identity, origin_serial)

func damage_enemy(amount: float, is_crit: bool, is_tap: bool, is_heavy: bool = false) -> void:
	amount *= enemy_hit_multiplier
	enemy_hp -= amount
	if inventory.has_signature("frostbell_chime") and not enemy_frostbell_used:
		enemy_frostbell_used = true
		enemy_attack_clock += 0.32
		add_float("FROSTBELL", Vector2(300, 372), Color("#a8ecff"), 15)
		add_particles(Vector2(346, 442), Color("#a8ecff"), 6)
	if enemy_variant_guarded and enemy_hp / maxf(1.0, enemy_max_hp) <= 0.72:
		enemy_variant_guarded = false
		enemy_hit_multiplier = enemy_post_guard_hit_multiplier
		add_float("ROOT GUARD BROKEN", Vector2(275, 400), enemy_variant_color, 14)
		add_particles(Vector2(350, 468), enemy_variant_color, 7)
	enemy_flash = 0.13 if is_crit else 0.10
	enemy_squash = 0.16
	enemy_recoil = 40.0 if is_crit else 27.0 if is_heavy else 22.0 if is_tap else 15.0
	impact_flash = 0.12 if is_crit else 0.052
	crit_flash = 0.18 if is_crit else crit_flash
	screen_shake = 0.075 if is_crit else 0.035
	if is_crit or is_heavy:
		hit_stop_timer = maxf(hit_stop_timer, 0.038 if is_crit else 0.030)
	elif is_tap:
		hit_stop_timer = maxf(hit_stop_timer, 0.014)
	play_audio_event("crit" if is_crit else "boss_hit" if enemy_is_boss else "heavy_hit" if is_heavy else "normal_hit")
	var text := ("CRIT! %.0f" if is_crit else "%.0f") % amount
	var text_size := 29 if is_crit else 20
	var text_color := Color("#fff178") if is_crit else Color.WHITE
	if is_heavy:
		text = ("QUAKE CRIT %.0f" if is_crit else "QUAKE %.0f") % amount
		text_size = 26 if is_crit else 22
		text_color = build.color("Physical").lightened(0.25)
	elif is_tap and not is_crit:
		text = "%.0f" % amount
	add_float(text, Vector2(300 + visual_rng.randf_range(-10, 10), 408), text_color, text_size)
	add_particles(Vector2(342, 475), Color("#ffda69") if is_crit else Color("#b8efff"), 14 if is_crit else 7)
	player_hp = minf(player_max_hp, player_hp + amount * life_steal)
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
	var effective_execute := execute_ratio + inventory.effect_total("execute")
	if effective_execute > 0.0 and enemy_hp > 0.0 and enemy_hp / enemy_max_hp <= effective_execute:
		add_float("YEET!", Vector2(355, 385), Color("#ff8bd8"), 28)
		enemy_hp = 0.0
	if enemy_hp <= 0.0:
		kill_enemy()

func perform_enemy_attack(damage_scale: float = 1.0) -> void:
	if not enemy_alive:
		return
	enemy_attack_anim = 0.18
	enemy_attack_count += 1
	play_audio_event({"skirmisher":"enemy_skirmisher", "tank":"enemy_tank", "hexer":"enemy_hexer"}.get(enemy_archetype, "enemy_skirmisher"))
	if enemy_archetype == "hexer" and not enemy_is_boss and not enemy_is_miniboss and enemy_attack_count % 3 == 0:
		var ward := enemy_max_hp * 0.07
		enemy_hp = minf(enemy_max_hp, enemy_hp + ward)
		add_float("WARD +%.0f" % ward, Vector2(325, 410), Color("#d194ff"), 17)
		add_particles(Vector2(365, 465), Color("#b86cff"), 6)
		return
	if debug_enabled and debug_god_mode:
		add_float("BLOCKED", Vector2(135, 430), Color("#8fe7ff"), 15)
		return
	var style_armor := 0.04 if current_weapon_family() == "VANGUARD" else 0.0
	var effective_armor := armor + inventory.effect_total("armor") + style_armor
	var damage := enemy_damage * damage_scale * (1.0 - minf(effective_armor, 0.72))
	if enemy_variant_id == "overcharged" and enemy_attack_count % 3 == 0:
		damage *= 1.22
		add_float("SPARK SURGE", Vector2(250, 392), enemy_variant_color, 15)
		add_particles(Vector2(260, 448), enemy_variant_color, 7)
	if enemy_variant_id == "frostbitten" and enemy_attack_count % 3 == 0:
		attack_clock += 0.18
		add_float("FROST DELAY", Vector2(150, 405), enemy_variant_color, 14)
	player_hp -= damage
	play_audio_event("player_hurt")
	run_damage_taken += damage
	player_flash = 0.13
	screen_shake = 0.08
	add_float("-%.0f" % damage, Vector2(150, 432), Color("#ff7a84"), 19)
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
		end_run(false)

func deal_elemental_hit(amount: float, identity: String) -> void:
	if not enemy_alive:
		return
	amount *= enemy_hit_multiplier
	enemy_hp -= amount
	var color := build.color(identity)
	enemy_flash = 0.08
	enemy_recoil = 22.0
	impact_flash = 0.06
	element_flash = 0.24
	element_flash_color = color
	element_flash_identity = identity
	add_float("%.0f" % amount, Vector2(324, 390), color, 19)
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
	if enemy_burn_dps > 0.0:
		var burn_damage := enemy_burn_dps * 0.4 * enemy_hit_multiplier
		total_dot += burn_damage
		add_particles(Vector2(360, 446), build.color("Fire"), 2)
	if enemy_poison_stacks > 0:
		var poison_damage := base_damage * 0.012 * build.count("Poison") * enemy_poison_stacks * enemy_hit_multiplier
		total_dot += poison_damage
		add_particles(Vector2(375, 480), build.color("Poison"), 2)
		if plague_power > 0:
			var siphon_ratio := minf(0.20, 0.10 + plague_power * 0.05)
			player_hp = minf(player_max_hp, player_hp + poison_damage * siphon_ratio)
	if total_dot > 0.0:
		enemy_hp -= total_dot
		if enemy_hp <= 0.0:
			kill_enemy()

func kill_enemy() -> void:
	enemy_alive = false
	spawn_clock = 0.90 if enemy_is_boss else 0.72 if enemy_is_miniboss else 0.48
	enemy_death_anim = 0.82 if enemy_is_boss else 0.68 if enemy_is_miniboss else 0.50
	impact_flash = 0.12
	death_burst = 0.90 if enemy_is_boss else 0.56 if enemy_is_miniboss else 0.46
	death_burst_color = Color("#b75cff") if enemy_is_boss else Color("#ffba55") if enemy_is_miniboss else Color("#ffcf72")
	enemy_hp = 0.0
	total_kills += 1
	contracts.record("kill")
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
	play_audio_event("boss_death" if enemy_is_boss else "enemy_death")
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
	var reward := int(round((5.0 + wave * 1.8) * coin_reward_mult * (1.0 + inventory.effect_total("coin_mult")) * (4.0 if enemy_is_boss else 2.0 if enemy_is_miniboss else 1.0) * enemy_reward_multiplier))
	coins += reward
	run_coins_earned += reward
	var xp_reward := (13.0 + wave * 2.2) * xp_reward_mult * (2.6 if enemy_is_boss else 1.8 if enemy_is_miniboss else 1.0) * enemy_xp_multiplier
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
	var equipment_dropped := false
	if enemy_is_boss:
		prepare_hoard_chest()
	else:
		equipment_dropped = spawn_item_drop()
	if equipment_dropped:
		spawn_clock = maxf(spawn_clock, 1.2)
		play_audio_event("equipment_drop")
		AnalyticsLogger.log_event(ANALYTICS_PATH, "gear_drop", {"wave":wave, "boss":enemy_is_boss, "miniboss":enemy_is_miniboss})
	add_xp(xp_reward)
	if not enemy_is_boss:
		add_float("+%d SCRIP" % reward, Vector2(346, 355), Color("#ffd65a"), 18)
	add_particles(Vector2(365, 470), Color("#ffd65a"), 32 if enemy_is_boss else 22 if enemy_is_miniboss else 16)
	add_reward_burst(reward, xp_reward)
	status_message = "MINIBOSS DEFEATED" if enemy_is_miniboss else ""
	status_clock = 0.9 if enemy_is_miniboss else 0.0
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
		wave_kills = 0
		item_review_due = true
		if wave in [6, 11]:
			merchant_due = true
			pending_zone_transition = true
		player_hp = minf(player_max_hp, player_hp + player_max_hp * 0.20)
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
		var start_pos := Vector2(ENEMY_X, 448) if enemy_is_boss else Vector2(345 + drop_index * 20, 430)
		var launch_x: float = float([-155.0, -18.0, 128.0][drop_index]) if enemy_is_boss else -75.0 + drop_index * 52.0
		var launch_y: float = float([-310.0, -355.0, -292.0][drop_index]) if enemy_is_boss else visual_rng.randf_range(-250.0, -205.0)
		loot_drops.append({
			"item":item,
			"relic_chest":enemy_is_miniboss and not enemy_is_boss,
			"rarity":item.get("rarity", "COMMON"),
			"boss_choice":enemy_is_boss,
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
			screen_shake = 0.10
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
	if state != "hoard_chest" or hoard_chest_phase != "ready":
		return
	hoard_chest_phase = "windup"
	record_contract_chest()
	hoard_chest_timer = float(hoard_reveal_profile.get("anticipation", 0.62))
	hoard_chest_button.visible = false
	play_audio_event("chest_windup")
	award_achievement("ten_chests")
	award_achievement("chest_50")
	add_particles(Vector2(240, 492), Color("#ffd36a"), 16)
	impact_flash = 0.14

func eject_hoard_loot() -> void:
	play_audio_event(str(hoard_reveal_profile.get("audio", "chest_open")))
	add_particles(Vector2(240, 492), Color(hoard_reveal_profile.get("color", Color("#ffd36a"))), int(hoard_reveal_profile.get("particles", 42)))
	screen_shake = float(hoard_reveal_profile.get("shake", 0.11))
	for drop_index in range(boss_reward_options.size()):
		var item: Dictionary = boss_reward_options[drop_index]
		loot_drops.append({
			"item":item, "rarity":item.get("rarity", "EPIC"), "boss_choice":true,
			"pos":Vector2(240, 474), "vel":Vector2([-155.0, -18.0, 128.0][drop_index], [-310.0, -355.0, -292.0][drop_index]),
			"pickup":0.92 + drop_index * 0.10, "bounces":0, "squash":0.0,
			"color":ItemCatalog.rarity_color(item.get("rarity", "EPIC"))
		})
	hoard_chest_phase = ""
	state = "playing"
	spawn_clock = 1.2
	add_float("HOARD ERUPTS!", Vector2(165, 350), Color("#ffd36a"), 21)
	play_audio_event("legendary_reveal" if boss_reward_options.any(func(item): return item.get("rarity", "") == "LEGENDARY") else "epic_reveal")
	if boss_reward_options.any(func(item): return item.get("rarity", "") == "LEGENDARY"):
		award_achievement("hoard_legendary")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "chest_open", {"chest_id":"hoard_chest", "rolls":boss_reward_options.size()})

func show_boss_reward() -> void:
	state = "boss_reward"
	boss_reward_panel.visible = true
	help_label.visible = false
	for i in range(boss_reward_buttons.size()):
		var item: Dictionary = boss_reward_options[i]
		boss_reward_buttons[i].text = boss_reward_card_text(item)
		boss_reward_buttons[i].add_theme_font_size_override("font_size", 13)
		apply_button_style(boss_reward_buttons[i], Color("#24264f"), ItemCatalog.rarity_color(item.rarity))
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

func choose_boss_reward(index: int) -> void:
	if state != "boss_reward" or index < 0 or index >= boss_reward_options.size():
		return
	var chosen: Dictionary = boss_reward_options[index]
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
	current_item = pending_items.pop_front()
	var rarity: String = current_item.get("rarity", "COMMON")
	var color := ItemCatalog.rarity_color(rarity)
	var title_text := "%s  •  %s" % [rarity, current_item.get("name", "Unknown Loot")]
	item_title.text = title_text
	fit_label_font(item_title, title_text, 376.0)
	item_title.add_theme_color_override("font_color", color)
	item_icon.configure(current_item)
	item_description.text = "%s\n%s\n%s" % [ItemCatalog.display_identity(current_item), current_item.get("desc", ""), ItemCatalog.describe_headline_effects(current_item, 1)]
	var equipped: Dictionary = inventory.equipped_item(current_item.get("slot", ""))
	item_compare.text = build_item_comparison(current_item, equipped)
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
		"LEGENDARY": play_audio_event("legendary_reveal")
		"EPIC": play_audio_event("epic_reveal")
		"RARE": play_audio_event("rare_reveal")
		_: play_audio_event("rarity_reveal")

func build_item_comparison(found: Dictionary, equipped: Dictionary) -> String:
	if equipped.is_empty():
		return "[color=#8fa4ce]EQUIPPED[/color]  Empty slot\n[color=#69e6b0]▲ EVERYTHING IS A GAIN[/color]"
	var equipped_summary := ItemCatalog.describe_headline_effects(equipped, 1).replace("\n", "  •  ")
	var result := "[color=#8fa4ce]EQUIPPED[/color]  %s  [%s]\n%s\n[color=#ffd36a]CHANGE IF EQUIPPED[/color]\n" % [equipped.get("name", "Item"), equipped.get("rarity", "COMMON"), equipped_summary]
	var found_effects: Dictionary = found.get("effects", {})
	var equipped_effects: Dictionary = equipped.get("effects", {})
	var keys: Array = found_effects.keys()
	for key in equipped_effects.keys():
		if not key in keys:
			keys.append(key)
	var changes: Array[String] = []
	for key in keys:
		if key == "repeat_every":
			if found_effects.has(key) and not equipped_effects.has(key):
				changes.append("[color=#69e6b0]▲ GAINS SPELL REPEAT[/color]")
			elif equipped_effects.has(key) and not found_effects.has(key):
				changes.append("[color=#ff7d88]▼ LOSES SPELL REPEAT[/color]")
			continue
		var found_value := float(found_effects.get(key, 0.0))
		var equipped_value := float(equipped_effects.get(key, 0.0))
		var delta := found_value - equipped_value
		if key == "attack_slow":
			delta = -delta
		if absf(delta) < 0.001:
			continue
		var gain := delta > 0.0
		var arrow := "▲" if gain else "▼"
		var change_color := "#69e6b0" if gain else "#ff7d88"
		changes.append("[color=%s]%s %s[/color]" % [change_color, arrow, format_effect_delta(key, absf(delta))])
		if changes.size() >= 3:
			break
	if changes.is_empty():
		changes.append("[color=#c7d4ee]• SIDEGRADE — DIFFERENT EFFECT PROFILE[/color]")
	return result + "\n".join(changes)

func format_effect_delta(key: String, amount: float) -> String:
	var labels := {
		"damage_mult":"DAMAGE", "attack_speed":"ATTACK RATE", "attack_slow":"ATTACK RATE",
		"crit":"CRIT CHANCE", "max_hp":"MAX HP", "armor":"ARMOUR", "coin_mult":"RUN SCRIP",
		"execute":"EXECUTE", "fire_damage":"BURN POWER", "crit_lightning":"CRIT SPARK",
		"poison_bonus":"POISON STACK", "poison_duration":"POISON TIME", "boss_damage":"BOSS DAMAGE",
		"heavy_bonus":"HEAVY POWER", "kill_explosion":"KILL BURST", "low_health_damage":"LOW-HP POWER"
	}
	var label: String = labels.get(key, key.replace("_", " ").to_upper())
	if key == "max_hp" or key == "poison_bonus":
		return "+%.0f %s" % [amount, label]
	return "+%.0f%% %s" % [amount * 100.0, label]

func accept_item_equip() -> void:
	if state != "item" or current_item.is_empty():
		return
	var item_name: String = current_item.get("name", "Loot")
	if not item_name in run_kept_loot:
		run_kept_loot.append(item_name)
	var result: Dictionary = inventory.equip(current_item)
	award_current_weapon_family()
	refresh_equipment_health()
	inventory.save(INVENTORY_SAVE_PATH)
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

func accept_item_keep() -> void:
	if state != "item" or current_item.is_empty():
		return
	if not inventory.keep(current_item):
		return
	var kept_name: String = current_item.get("name", "Loot")
	if not kept_name in run_kept_loot:
		run_kept_loot.append(kept_name)
	inventory.save(INVENTORY_SAVE_PATH)
	status_message = "%s sent to stash." % current_item.get("name", "Loot")
	player_reward_flash = 0.55
	player_reward_color = Color("#72c8ff")
	add_particles(Vector2(player_x, 470), player_reward_color, 12)
	queue_loot_dialogue(current_item)
	finish_item_decision()

func accept_item_scrap() -> void:
	if state != "item" or current_item.is_empty():
		return
	var value := inventory.salvage(current_item)
	inventory.save(INVENTORY_SAVE_PATH)
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
		show_merchant()
	elif pending_victory:
		end_run(true)
	else:
		item_review_due = false
		state = "playing"
		help_label.visible = not tap_tutorial_seen

func queue_loot_dialogue(item: Dictionary) -> void:
	var rarity := str(item.get("rarity", "COMMON"))
	if rarity == "LEGENDARY":
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
		shop.generate_stock(loot_system, wave)
	merchant_panel.visible = true
	help_label.visible = false
	refresh_merchant_ui()
	if presentation_director != null:
		presentation_director.present_card(merchant_panel, Color("#d3a45e"), 0.26)

func refresh_merchant_ui() -> void:
	merchant_title.text = "PACK PEDDLER"
	merchant_coin_label.text = "[center]%s  %d RUN SCRIP[/center]" % [LootlingsUI.inline_icon("currency_run_scrip", 20), coins]
	for i in range(merchant_buttons.size()):
		var button := merchant_buttons[i]
		if i >= shop.stock.size():
			button.text = "SOLD"
			button.disabled = true
			button.icon = null
			merchant_icons[i].visible = false
			for label in merchant_visuals[i].values():
				label.text = ""
			button.add_theme_color_override("font_disabled_color", Color("#77819a"))
			continue
		var item: Dictionary = shop.stock[i]
		var price := int(item.get("price", 0))
		apply_merchant_thumbnail(button, merchant_icons[i], item)
		var indent := "" if item.get("slot", "") == "Weapon" else "             "
		var headline := ItemCatalog.describe_headline_effects(item, 1).replace("\n", "  •  ")
		if headline.length() > 43:
			headline = headline.left(42) + "…"
		button.text = "%s%s  •  %d SCRIP\n%s%s  [%s]\n%s%s" % [indent, ItemCatalog.display_slot(item.get("slot", "Item")), price, indent, item.name, item.rarity, indent, headline]
		button.tooltip_text = "%s\n%s" % [item.name, ItemCatalog.describe_headline_effects(item, 2)]
		button.disabled = coins < price
		apply_button_style(button, Color("#202d52"), ItemCatalog.rarity_color(item.rarity))
		# Keep the semantic button text, but render its information in an icon-safe lane.
		for state_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_shadow_color"]:
			button.add_theme_color_override(state_name, Color.TRANSPARENT)
		merchant_visuals[i].kicker.text = "%s  •  %s  •  %d SCRIP" % [ItemCatalog.display_slot(item.get("slot", "Item")), item.rarity, price]
		merchant_visuals[i].name.text = str(item.name)
		merchant_visuals[i].effect.text = headline
		for label in merchant_visuals[i].values():
			label.modulate = Color("#a1a9bb") if button.disabled else Color.WHITE
	var reroll_price := shop.reroll_cost(wave)
	merchant_reroll_button.text = "REROLL  %d" % reroll_price
	merchant_reroll_button.disabled = coins < reroll_price

func apply_merchant_thumbnail(button: Button, category_icon: Control, item: Dictionary) -> void:
	category_icon.visible = true
	category_icon.configure(item)
	button.icon = null
	button.expand_icon = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_constant_override("icon_max_width", 62)

func merchant_weapon_texture(item: Dictionary) -> Texture2D:
	if item.get("slot", "") != "Weapon":
		return null
	return LootlingsUI.item_texture(item)

func buy_merchant_item(index: int) -> void:
	if state != "merchant" or index < 0 or index >= shop.stock.size():
		return
	var price := int(shop.stock[index].get("price", 0))
	if coins < price:
		return
	coins -= price
	run_coins_spent += price
	play_audio_event("shop_purchase")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "scrip_spent", {"amount":price, "source":"pack_peddler"})
	var bought: Dictionary = shop.take(index)
	merchant_panel.visible = false
	return_to_merchant = true
	pending_items.push_front(bought)
	state = "playing"
	show_next_item()

func reroll_merchant() -> void:
	if state != "merchant":
		return
	var price := shop.reroll_cost(wave)
	if coins < price:
		return
	coins -= price
	run_coins_spent += price
	play_audio_event("ui_press")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "scrip_spent", {"amount":price, "source":"pack_peddler_reroll"})
	shop.reroll(loot_system, wave)
	refresh_merchant_ui()

func leave_merchant() -> void:
	if state != "merchant":
		return
	merchant_panel.visible = false
	shop.stock.clear()
	state = "playing"
	help_label.visible = not tap_tutorial_seen
	status_message = "Back to the hunt!"
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
	state = "upgrade"
	help_label.visible = false
	selected_upgrades.clear()
	var pool := UPGRADES.duplicate(true)
	pool.shuffle()
	for i in range(3):
		selected_upgrades.append(pool[i])
		var up: Dictionary = pool[i]
		var stacks := int(upgrade_counts.get(up.id, 0))
		upgrade_buttons[i].text = format_upgrade_card(up, stacks)
		apply_button_style(upgrade_buttons[i], Color("#202d52"), GameCatalog.rarity_color(up.rarity))
		# Keep the Button's complete semantic text for accessibility/tests; its
		# visible layers give rarity, name and effect distinct hierarchy.
		for state_color in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_shadow_color"]:
			upgrade_buttons[i].add_theme_color_override(state_color, Color.TRANSPARENT)
		var tags: Array = up.get("tags", [])
		upgrade_visuals[i].kicker.text = "%s  /  %s%s" % [str(tags[0]).to_upper() if not tags.is_empty() else "UTILITY", up.rarity, "  /  STACK ×%d" % stacks if stacks > 0 else ""]
		upgrade_visuals[i].kicker.add_theme_color_override("font_color", GameCatalog.rarity_color(up.rarity).lightened(0.20))
		upgrade_visuals[i].name.text = str(up.name).to_upper()
		upgrade_visuals[i].effect.text = str(up.desc)
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
		wave_banner_text = "%s EQUIPPED" % up.name
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
			coin_reward_mult += 0.25
			xp_reward_mult += 0.15
		"heavy": heavy_power += 1
		"storm": storm_power += 1
		"ignite": ignite_power += 1
		"wildfire": wildfire_power += 1
		"venom": venom_power += 1
		"plague": plague_power += 1

func end_run(victory: bool) -> void:
	if state == "result": return
	run_won = victory
	if route_panel != null: route_panel.visible = false
	state = "result"
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
	meta_shards += run_shards_earned
	gold += run_gold_earned
	if victory:
		contracts.record("win")
		if not dungeon.active:
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
	result_title.text = "HOARD CONQUERED!" if victory else "BONKED OUT!"
	result_crest.texture = LootlingsUI.icon("res://art/ui/results/%s_crest.png" % ("victory" if victory else "defeat"))
	LootlingsUI.apply_material(result_panel, "hoard" if victory else "danger")
	result_title.add_theme_color_override("font_color", Color("#ffe178") if victory else Color("#ff8995"))
	var notable_loot := "None"
	if not run_kept_loot.is_empty():
		notable_loot = run_kept_loot[0]
		if run_kept_loot.size() > 1:
			notable_loot += ", " + run_kept_loot[1]
	var scrap_gained := maxi(0, inventory.scrap - run_start_scrap)
	result_summary.text = style_result_summary(format_result_summary(victory, wave, total_kills, run_coins_earned, run_coins_spent, coins, scrap_gained, run_shards_earned, notable_loot, run_gold_earned))
	if dungeon.active:
		result_title.text = "RELIC ROUTE CLEARED!" if victory else "ROUTE ENDED"
		result_summary.text = result_summary.text.replace("Wave reached  %d / %d" % [wave, RUN_LAST_WAVE], "Rooms entered  %d / 8 • Seed %d" % [dungeon.depth + 1, dungeon.seed_value])
	if presentation_director != null:
		presentation_director.present_card(result_panel, Color("#ffe178") if victory else Color("#ff8995"), 0.34)
	play_audio_event("victory" if victory else "defeat")
	if audio_manager != null:
		audio_manager.set_music("VICTORY" if victory else "DEFEAT")
	AnalyticsLogger.log_event(ANALYTICS_PATH, "gold_earned", {"amount":run_gold_earned, "source":"run_result", "victory":victory})
	AnalyticsLogger.log_event(ANALYTICS_PATH, "run_end", {"victory":victory, "wave":wave, "kills":total_kills, "gold":run_gold_earned, "scrip_earned":run_coins_earned, "scrip_spent":run_coins_spent})
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
	return "%s\nWave reached  %d / %d  •  Enemies  %d\n\nRUN SCRIP\nEarned     %d\nSpent      %d\nLeft       %d\n\nRUN REWARDS\nGold +%d  •  Scrap +%d  •  Shards +%d\n\nNOTABLE LOOT\n%s" % ["VICTORY" if victory else "DEFEAT", reached_wave, RUN_LAST_WAVE, kills, earned, spent, left, gold_gained, scrap_gained, shards_gained, notable_loot]

func style_result_summary(summary: String) -> String:
	var styled := summary
	for resource in ["Gold", "Scrap", "Shards"]:
		var icon_name: String = {"Gold":"gold", "Scrap":"scrap", "Shards":"star_shard"}[resource]
		styled = styled.replace("%s +" % resource, "%s %s +" % [LootlingsUI.inline_icon("currency_%s" % icon_name), resource])
	for heading in ["RUN SCRIP", "RUN REWARDS", "NOTABLE LOOT"]:
		styled = styled.replace(heading, "[font_size=12][color=#dabb79]%s[/color][/font_size]" % heading)
	styled = styled.replace("[font_size=12][color=#dabb79]RUN SCRIP", "[font_size=12][color=#dabb79]%s RUN SCRIP" % LootlingsUI.inline_icon("currency_run_scrip"))
	return "[center]%s[/center]" % styled

func buy_meta_power() -> void:
	if state != "hideout":
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
		hideout_ui.configure(inventory, hideout_shop, meta_shards, meta_power, Callable(self, "build_item_comparison"), gold, profile, gold_upgrades, achievements)

func load_meta() -> void:
	var progress := MetaStore.load_progress(SAVE_PATH)
	meta_shards = progress.shards
	meta_power = progress.power
	gold = progress.gold
	gold_upgrades = progress.get("gold_upgrades", {"bedroll":0, "whetstone":0, "pouch":0}).duplicate(true)

func save_meta() -> void:
	MetaStore.save_progress(SAVE_PATH, meta_shards, meta_power, gold, gold_upgrades)

func _unhandled_input(event: InputEvent) -> void:
	if debug_enabled and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		if debug_panel != null and not debug_panel.visible:
			debug_panel.open()
			get_viewport().set_input_as_handled()
		return
	if debug_enabled and debug_panel != null and debug_panel.visible:
		return
	if state == "hoard_chest" and hoard_chest_phase == "ready" and ((event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed) or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE)):
		open_hoard_chest()
		get_viewport().set_input_as_handled()
		return
	if state != "playing":
		return
	var tapped := false
	if event is InputEventMouseButton:
		tapped = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	elif event is InputEventScreenTouch:
		tapped = event.pressed
	elif event is InputEventKey:
		tapped = event.pressed and not event.echo and event.keycode == KEY_SPACE
	if tapped:
		if enemy_encounter.active and (event is InputEventMouseButton or event is InputEventScreenTouch):
			enemy_encounter.select_at(self, event.position * DESIGN_SIZE / size)
		request_tap_attack()
		get_viewport().set_input_as_handled()

func update_effects(delta: float) -> void:
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
		item.pos.y -= 42.0 * delta
	for i in range(floating_texts.size() - 1, -1, -1):
		if floating_texts[i].life <= 0.0:
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
		if drop.pos.y >= 540.0 and drop.vel.y > 0.0:
			if int(drop.bounces) == 0 and bool(drop.get("boss_choice", false)):
				play_audio_event("chest_land")
			drop.pos.y = 540.0
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
		if state == "playing" and enemy_encounter.active:
			enemy_encounter.resolve_projectile(self, int(projectile.enemy_serial), bool(projectile.is_tap))
		elif state == "playing" and enemy_alive and int(projectile.enemy_serial) == enemy_serial:
			resolve_player_attack(bool(projectile.is_tap))

func add_float(text_value: String, pos: Vector2, color: Color, size_value: int) -> void:
	if enemy_encounter.active and pos.x >= 275.0 and pos.x <= 380.0 and not text_value.contains("SCRIP"):
		pos.x += enemy_encounter.target_position().x - ENEMY_X
	var is_dot := size_value <= 15
	var prefix := text_value.get_slice(" ", 0)
	var lane := "damage"
	if text_value.begins_with("-"):
		lane = "player"
	elif text_value.contains("SCRIP") or text_value.contains("LOOT") or text_value.contains("HOARD"):
		lane = "reward"
	elif is_dot or prefix in ["WARD"]:
		lane = "secondary"
	elif prefix in ["ARC", "WILDFIRE", "GEAR", "RELIC", "SHOCKWAVE", "YEET!"]:
		lane = "proc"
	var lane_count := 0
	for item in floating_texts:
		if is_dot and item.text.get_slice(" ", 0) == prefix and item.life > 0.28:
			return
		if item.get("lane", "damage") == lane:
			lane_count += 1
	if lane_count >= 3 and size_value < 22:
		return
	match lane:
		"player": pos = Vector2(70, 414)
		"reward": pos = Vector2(290, 628)
		"proc": pos = Vector2(260, 365)
		"secondary": pos = Vector2(270, 397)
		_: pos = Vector2(270, 334)
	pos.y -= min(lane_count, 2) * 17.0
	pos.x += (-9.0 if lane_count % 2 == 0 else 9.0) * min(lane_count, 2)
	var duration := 0.68 if size_value < 25 else 0.82
	floating_texts.append({"text":text_value, "pos":pos, "color":color, "size":size_value, "life":duration, "max_life":duration, "lane":lane})
	while floating_texts.size() > 5:
		floating_texts.pop_front()

func add_particles(pos: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		particles.append({"pos":pos, "vel":Vector2(visual_rng.randf_range(-105, 105), visual_rng.randf_range(-155, -25)), "color":color, "life":visual_rng.randf_range(0.25, 0.55), "max_life":0.55})

func add_reward_burst(coin_reward: int, xp_reward: float) -> void:
	var coin_cap := 14 if enemy_is_boss else 9 if enemy_is_miniboss else 7
	var coin_count := mini(coin_cap, maxi(3, int(coin_reward / 7) + 3))
	for i in range(coin_count):
		var start := Vector2(360, 450) + Vector2(visual_rng.randf_range(-24, 24), visual_rng.randf_range(-18, 20))
		reward_pickups.append({"kind":"coin", "start":start, "pos":start, "target":Vector2(420, 35), "vel":Vector2(visual_rng.randf_range(-130.0, 85.0), visual_rng.randf_range(-230.0, -120.0)), "delay":0.16 + i * 0.035, "life":0.72, "max_life":0.72})
	var xp_count := mini(7 if enemy_is_boss else 5, maxi(2, int(xp_reward / 25.0) + 2))
	for i in range(xp_count):
		var start := Vector2(365, 450) + Vector2(visual_rng.randf_range(-28, 28), visual_rng.randf_range(-15, 22))
		reward_pickups.append({"kind":"xp", "start":start, "pos":start, "target":Vector2(250, 92), "vel":Vector2(visual_rng.randf_range(-95.0, 110.0), visual_rng.randf_range(-210.0, -105.0)), "delay":0.20 + i * 0.045, "life":0.78, "max_life":0.78})

func _draw() -> void:
	var sx := size.x / DESIGN_SIZE.x
	var sy := size.y / DESIGN_SIZE.y
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))
	var shake := Vector2.ZERO
	if screen_shake > 0.0:
		shake = Vector2(visual_rng.randf_range(-4, 4), visual_rng.randf_range(-3, 3))
	draw_background()
	draw_hud()
	draw_arena(shake)
	draw_effects()
	draw_moment_overlay()

func draw_background() -> void:
	draw_rect(Rect2(0, 0, 480, 854), Color("#080d20"))
	var arena_background: Texture2D = current_zone.get("background", ZoneCatalog.OUTER_RUINS_BACKGROUND)
	var texture_size := arena_background.get_size()
	var target := Rect2(0, 146, 480, 568)
	var crop_height: float = texture_size.x * target.size.y / target.size.x
	var source_height := minf(texture_size.y, crop_height)
	var max_source_y := maxf(0.0, texture_size.y - source_height)
	var depth_drift := sin(run_time * 0.20) * minf(2.5, max_source_y * 0.5)
	var source := Rect2(0, clampf(max_source_y * 0.5 + depth_drift, 0.0, max_source_y), texture_size.x, source_height)
	draw_texture_rect_region(arena_background, target, source, current_zone.get("presentation_tint", Color.WHITE))
	if campaign_id != "act_i":
		# Reuse painted masonry to anchor feet; scenery is not the collision plane.
		draw_texture_rect(preload("res://beta_art_catalog.gd").PLATFORM, Rect2(0, 504, 480, 110), false, Color("#ddb99a") if current_zone_id == "cinder_crown" else Color.WHITE)
	# Quiet the combat band slightly while keeping the lanterns and moon visible.
	var plane_tint := Color("#17100c28") if current_zone_id == "emberworks" else Color("#09082230") if current_zone_id == "hoard_depths" else Color("#08122922")
	draw_rect(Rect2(0, 182, 480, 382), plane_tint, true)
	draw_rect(Rect2(0, 558, 480, 156), Color("#07102142"), true)
	draw_line(Vector2(0, 514), Vector2(480, 514), Color(current_zone.accent, 0.38), 2)
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
	hud_header_surface.draw(get_canvas_item(), Rect2(0, 0, 480, 146))
	LootlingsUI.draw_icon(get_canvas_item(), Avatar.portrait(profile), Rect2(12, 17, 42, 42))
	draw_string(title_font, Vector2(60, 36), Avatar.display_name(profile).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 170, 18, Color("#ffe178"))
	var location_line := "ROOM %02d / 08 • RELIC ROUTE" % (dungeon.depth + 1) if dungeon.active else "WAVE %02d • %s" % [wave, str(current_zone.get("short_name", current_zone.get("name", "RUINS"))).to_upper()]
	if dungeon.active and dungeon.depth < 0: location_line = "RELIC ROUTE • CHOOSE PATH"
	draw_string(body_font, Vector2(60, 59), location_line, HORIZONTAL_ALIGNMENT_LEFT, 174, 12, Color("#bac9eb"))
	var coin_pulse := clampf(coin_counter_flash / 0.24, 0.0, 1.0)
	var scrip_center := Vector2(353, 29)
	var scrip_radius := 10.0 + coin_pulse * 3.0
	LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.icon("currency_run_scrip"), Rect2(scrip_center - Vector2.ONE * scrip_radius, Vector2.ONE * scrip_radius * 2))
	draw_string(body_font, Vector2(370, 36), "%d" % coins, HORIZONTAL_ALIGNMENT_LEFT, 80, 18 + int(coin_pulse * 3.0), Color("#fff2a0") if coin_pulse > 0.0 else Color("#ffe078"))
	draw_string(body_font, Vector2(334, 61), "RUN SCRIP  •  LV %d" % level, HORIZONTAL_ALIGNMENT_CENTER, 132, 11, Color("#9fddff"))
	draw_bar(Rect2(18, 77, 444, 18), xp / xp_needed, Color("#1d2948"), Color("#55caef"), "XP  %.0f / %.0f" % [xp, xp_needed], 12)
	if xp_counter_flash > 0.0:
		var xp_pulse := xp_counter_flash / 0.24
		draw_rect(Rect2(18, 77, 444, 18), Color(0.45, 0.90, 1.0, xp_pulse * 0.22), true)
	draw_bar(Rect2(18, 106, 444, 25), player_hp / player_max_hp, Color("#38263d"), Color("#5ed78a"), "HP  %.0f / %.0f" % [player_hp, player_max_hp], 14)
	if state == "playing":
		var wave_target := 1 if wave == 8 or wave == RUN_LAST_WAVE else ENEMIES_PER_WAVE
		var foe_number := clampi(wave_kills + (1 if enemy_alive else 0), 1, wave_target)
		var encounter_text := "%s     %d / %d" % ["BOSS" if enemy_is_boss else "MINIBOSS" if enemy_is_miniboss else "FOE", foe_number, wave_target]
		if enemy_encounter.active:
			encounter_text = "%s • TAP A FOE TO TARGET" % ("DUO" if enemy_encounter.actors.size() == 2 else "SMALL PACK")
		if enemy_alive and (enemy_is_boss or enemy_is_miniboss) and enemy_entry_anim > 0.18:
			encounter_text = "INCOMING"
		draw_rect(Rect2(91, 151, 298, 25), Color("#0a1129d9"), true)
		draw_line(Vector2(110, 176), Vector2(370, 176), Color("#bd904a99"), 2)
		draw_string(body_font, Vector2(60, 169), encounter_text, HORIZONTAL_ALIGNMENT_CENTER, 360, 14, Color("#d8e3ff"))

func draw_arena(shake: Vector2) -> void:
	var show_combat_context := state == "playing"
	var enemy_color := Color("#ff6f87") if enemy_is_boss else Color("#bf80ff") if enemy_is_miniboss else Color("#73d7a2")
	if enemy_flash > 0.0:
		enemy_color = Color.WHITE
	var special_entering := enemy_alive and (enemy_is_boss or enemy_is_miniboss) and enemy_entry_anim > 0.18
	if enemy_alive and show_combat_context and not special_entering and not enemy_encounter.active:
		var enemy_name_size := 19
		while enemy_name_size > 11 and body_font.get_string_size(enemy_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, enemy_name_size).x > 398.0:
			enemy_name_size -= 1
		draw_string(body_font, Vector2(40, 210), enemy_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 400, enemy_name_size, Color("#f4f7ff"))
		draw_bar(Rect2(75, 232, 330, 22), enemy_hp / enemy_max_hp, Color("#4b263d"), Color("#ffad45") if enemy_is_boss else Color("#ff6279"), "%.0f / %.0f" % [enemy_hp, enemy_max_hp], 13)
		var status_x := 165.0
		if enemy_burn_dps > 0.0:
			draw_status_chip(Vector2(status_x, 261), "BURN", build.color("Fire"), "status_burn")
			status_x += 80.0
		if enemy_poison_stacks > 0:
			draw_status_chip(Vector2(status_x, 261), "TOXIN ×%d" % enemy_poison_stacks, build.color("Poison"), "status_poison")
		if not enemy_variant_id.is_empty() and wave_banner_timer <= 0.0:
			var variant := EnemyVariantCatalog.definition(enemy_variant_id)
			draw_status_chip(Vector2(240, 287), enemy_variant_name, enemy_variant_color, "variant_%s" % enemy_variant_id)
	var idle_bob := sin(run_time * 4.3) * 3.0
	var attack_ratio := clampf(attack_anim / 0.22, 0.0, 1.0)
	var family := current_weapon_family()
	var lunge_distance := 20.0 if family == "ROGUE" else 17.0 if family == "VANGUARD" else 3.0
	if attack_was_tap:
		lunge_distance += 3.0 if family in ["VANGUARD", "ROGUE"] else 1.0
	var lunge := attack_ratio * lunge_distance
	var player_pos := Vector2(player_x + lunge, 472 + idle_bob) + shake
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
		var enemy_lunge := 12.0 if enemy_is_boss else 10.0 if enemy_is_miniboss or enemy_archetype == "tank" else 15.0
		behavior_offset.x -= enemy_attack_ratio * enemy_lunge
		var enemy_pos := Vector2(ENEMY_X + enemy_recoil + entry_offset, 467) + behavior_offset + shake
		draw_enemy(enemy_pos, enemy_color)
	elif enemy_death_anim > 0.0:
		var death_duration := 0.82 if enemy_is_boss else 0.70 if enemy_is_miniboss else 0.62
		var death_progress := 1.0 - enemy_death_anim / death_duration
		var death_color := enemy_color
		death_color.a = 1.0 - death_progress
		draw_enemy(Vector2(ENEMY_X + death_progress * 35.0, 467 - death_progress * 38.0) + shake, death_color, 1.0 + death_progress * 0.28)
	if status_clock > 0.0 and show_combat_context:
		draw_rect(Rect2(67, 662, 346, 36), Color("#091127d6"), true)
		draw_rect(Rect2(67, 662, 346, 36), Color("#b98b477a"), false, 1)
		draw_string(body_font, Vector2(79, 687), status_message, HORIZONTAL_ALIGNMENT_CENTER, 322, 17, Color("#ffe797"))
	if show_combat_context:
		draw_stats_strip()

func draw_lootling(pos: Vector2, hurt: bool) -> void:
	creature_renderer.draw_lootling(self, pos, hurt)

func draw_enemy(pos: Vector2, color: Color, extra_scale: float = 1.0) -> void:
	creature_renderer.draw_enemy(self, pos, color, extra_scale)

func draw_stats_strip() -> void:
	hud_build_surface.draw(get_canvas_item(), Rect2(18, 714, 444, 88))
	var identity := build.dominant()
	var core_title := "DORMANT CORE" if identity == "Neutral" else "%s CORE • %s" % [identity.to_upper(), build.tier_name(identity)]
	LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.icon("core_%s" % identity.to_lower()), Rect2(24, 720, 18, 18))
	draw_string(body_font, Vector2(44, 735), "%s  •  %s" % [current_weapon_family(), core_title], HORIZONTAL_ALIGNMENT_LEFT, 292, 12, Color("#f1d486"))
	var scrap_text := str(inventory.scrap)
	var scrap_width := body_font.get_string_size(scrap_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.icon("currency_scrap"), Rect2(442 - scrap_width - 23, 721, 18, 18))
	draw_string(body_font, Vector2(344, 735), scrap_text, HORIZONTAL_ALIGNMENT_RIGHT, 98, 13, Color("#9fddff"))
	var labels := ["DAMAGE", "ATTACK", "CRIT", "HITS"]
	var values := ["%.0f" % (base_damage * equipment_damage_multiplier()), "%.2fs" % current_attack_interval(), "%d%%" % int(effective_crit_chance() * 100.0), "x%d" % multi_hits]
	for i in range(4):
		var x := 32.0 + i * 105.0
		if i > 0:
			draw_line(Vector2(x - 5, 747), Vector2(x - 5, 788), Color("#41527499"), 1)
		draw_string(body_font, Vector2(x, 758), labels[i], HORIZONTAL_ALIGNMENT_CENTER, 92, 12, Color("#b1c7eb"))
		draw_string(title_font, Vector2(x, 785), values[i], HORIZONTAL_ALIGNMENT_CENTER, 92, 18, Color("#f4f7ff"))

func draw_status_chip(pos: Vector2, text_value: String, color: Color, icon_name: String) -> void:
	var width := clampf(body_font.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 26.0, 72.0, 140.0)
	var rect := Rect2(pos.x - width * 0.5, pos.y - 12.0, width, 19.0)
	draw_rect(rect, Color("#080f24df"), true)
	draw_rect(rect, Color(color.r, color.g, color.b, 0.78), false, 1.5)
	LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.icon(icon_name), Rect2(rect.position + Vector2(3, 2), Vector2(15, 15)))
	draw_string(body_font, Vector2(rect.position.x + 22, pos.y + 3), text_value, HORIZONTAL_ALIGNMENT_CENTER, width - 25, 10, Color("#f5f7ff"))

func build_summary() -> String:
	return build.short_summary()

func draw_bar(rect: Rect2, ratio: float, _back: Color, _fill: Color, text_value: String, font_size: int) -> void:
	var kind := "xp" if rect.size.y == 18 else "health" if rect.size.y == 25 else "enemy"
	LootlingsUI.draw_meter(get_canvas_item(), rect, ratio, kind)
	draw_string(body_font, Vector2(rect.position.x + 4, rect.position.y + rect.size.y - 5), text_value, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 8, font_size, Color.WHITE)

func draw_effects() -> void:
	if state == "hoard_chest":
		draw_hoard_chest()
	for drop in loot_drops:
		draw_loot_drop(drop)
	draw_attack_projectiles()
	for pickup in reward_pickups:
		var pop := clampf(pickup.life / pickup.max_life * 2.0, 0.0, 1.0)
		# Avoid submitting a four-point polygon collapsed to one position on its
		# final frame; Godot correctly reports that as invalid triangulation.
		if pop <= 0.01:
			continue
		if pickup.kind == "coin":
			var radius := 8.0 * pop
			draw_colored_polygon(PackedVector2Array([
				pickup.pos + Vector2(0, -radius),
				pickup.pos + Vector2(radius * 0.70, 0),
				pickup.pos + Vector2(0, radius),
				pickup.pos + Vector2(-radius * 0.70, 0)
			]), Color("#f4bd3e"))
			draw_line(pickup.pos + Vector2(0, -4) * pop, pickup.pos + Vector2(0, 4) * pop, Color("#fff8c8"), 1.5)
		else:
			var radius := 7.0 * pop
			draw_colored_polygon(PackedVector2Array([pickup.pos + Vector2(0,-radius),pickup.pos + Vector2(radius,0),pickup.pos + Vector2(0,radius),pickup.pos + Vector2(-radius,0)]), Color("#70e5ff"))
	for particle in particles:
		var alpha: float = clampf(particle.life / particle.max_life, 0.0, 1.0)
		var color: Color = particle.color
		color.a = alpha
		draw_circle(particle.pos, 3.0 + 3.0 * alpha, color)
	var impact_center := Vector2(ENEMY_X + enemy_recoil, 455)
	if crit_flash > 0.0:
		var crit_ratio := clampf(crit_flash / 0.18, 0.0, 1.0)
		for ray in range(8):
			var direction := Vector2.RIGHT.rotated(TAU * ray / 8.0)
			draw_line(impact_center + direction * (32.0 - crit_ratio * 8.0), impact_center + direction * (54.0 + (1.0 - crit_ratio) * 16.0), Color(1.0, 0.88, 0.32, crit_ratio), 3.0)
		draw_arc(impact_center, 28.0 + (1.0 - crit_ratio) * 24.0, 0.0, TAU, 24, Color(1.0, 0.95, 0.64, crit_ratio), 3.0)
	if element_flash > 0.0:
		var element_ratio := clampf(element_flash / 0.24, 0.0, 1.0)
		var ring_color := element_flash_color
		ring_color.a = element_ratio * 0.82
		draw_arc(impact_center, 30.0 + (1.0 - element_ratio) * 34.0, -0.4, 5.2, 28, ring_color, 4.0)
		draw_arc(impact_center, 39.0 + (1.0 - element_ratio) * 20.0, 2.7, 6.0, 18, ring_color.lightened(0.25), 2.0)
		match element_flash_identity:
			"Fire":
				for ember in range(5):
					draw_circle(impact_center + Vector2(-16 + ember * 8, -18 - ember % 2 * 9) * (1.0 - element_ratio * 0.25), 3.0 + element_ratio * 2.0, Color(1.0, 0.38, 0.12, element_ratio))
			"Lightning":
				for arc in range(3):
					var offset := Vector2(-24 + arc * 18, -22 + arc * 5)
					draw_polyline(PackedVector2Array([impact_center + offset, impact_center + offset + Vector2(8,-9), impact_center + offset + Vector2(3,7), impact_center + offset + Vector2(16,1)]), Color(0.65, 0.92, 1.0, element_ratio), 3.0)
			"Poison":
				for drip in range(4):
					draw_circle(impact_center + Vector2(-18 + drip * 12, 10 + (1.0 - element_ratio) * 20), 4.0, Color(0.55, 1.0, 0.38, element_ratio * 0.85))
			"Physical":
				for debris in range(5):
					var direction := Vector2.RIGHT.rotated(-2.7 + debris * 0.35)
					draw_rect(Rect2(impact_center + direction * (28 + (1.0 - element_ratio) * 20), Vector2(5, 4)), Color(0.86, 0.67, 0.34, element_ratio), true)
	if death_burst > 0.0:
		var burst_duration := 0.90 if enemy_is_boss else 0.56 if enemy_is_miniboss else 0.46
		var death_ratio := clampf(death_burst / burst_duration, 0.0, 1.0)
		var burst_color := death_burst_color
		burst_color.a = death_ratio * 0.75
		var burst_center := Vector2(ENEMY_X, 462)
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
		var alpha: float = clampf(item.life / item.max_life, 0.0, 1.0)
		var color: Color = item.color
		color.a = alpha
		draw_string(body_font, item.pos + Vector2(2, 2), item.text, HORIZONTAL_ALIGNMENT_CENTER, 150, item.size, Color(0.02, 0.03, 0.08, alpha * 0.80))
		draw_string_outline(body_font, item.pos, item.text, HORIZONTAL_ALIGNMENT_CENTER, 150, item.size, 2, Color(0.02, 0.03, 0.08, alpha * 0.92))
		draw_string(body_font, item.pos, item.text, HORIZONTAL_ALIGNMENT_CENTER, 150, item.size, color)

func draw_attack_projectiles() -> void:
	for projectile in attack_projectiles:
		var pos: Vector2 = projectile.pos
		var progress: float = 1.0 - clampf(projectile.life / projectile.max_life, 0.0, 1.0)
		if projectile.get("weapon_type", "") == "sling":
			draw_line(pos - Vector2(22, 4), pos, Color("#d5c0aa99"), 3.0)
			draw_circle(pos, 8.0, Color("#242238"))
			draw_circle(pos, 5.5, Color("#d3c3ab"))
		elif projectile.family == "RANGER":
			var direction := Vector2(1.0, 0.04).normalized()
			var normal := direction.orthogonal()
			for trail_index in range(3):
				var trail_alpha := 0.52 - trail_index * 0.10
				var trail_start := pos - direction * (17.0 + trail_index * 9.0)
				draw_line(trail_start, trail_start - direction * (10.0 + trail_index * 4.0), Color(0.48, 0.88, 1.0, trail_alpha), 3.0 - trail_index * 0.45)
			draw_line(pos - direction * 19.0, pos + direction * 11.0, Color("#10182cbb"), 6.0)
			draw_line(pos - direction * 17.0, pos + direction * 10.0, Color("#fff0aa"), 3.5)
			draw_colored_polygon(PackedVector2Array([pos + direction * 15.0, pos + direction * 7.0 + normal * 5.0, pos + direction * 7.0 - normal * 5.0]), Color("#e8f4ff"))
			draw_line(pos - direction * 15.0, pos - direction * 22.0 + normal * 6.0, Color("#b2dcff"), 2.0)
			draw_line(pos - direction * 15.0, pos - direction * 22.0 - normal * 6.0, Color("#b2dcff"), 2.0)
		else:
			var pulse := 1.0 + sin(progress * PI * 4.0) * 0.12
			if projectile.get("weapon_type", "") == "wand": pulse *= 0.55
			var trail := Color(0.60, 0.44, 1.0, 0.34)
			draw_circle(pos - Vector2(24, 0), 6.0 * pulse, Color(0.38, 0.80, 1.0, 0.16))
			draw_circle(pos - Vector2(13, 0), 8.0 * pulse, trail)
			draw_circle(pos, 11.0 * pulse, Color("#8ee8ff"))
			draw_circle(pos, 6.0 * pulse, Color("#f2e9ff"))
			draw_arc(pos, 15.0, progress * TAU * 2.0, progress * TAU * 2.0 + 4.4, 14, Color("#c9a4ff"), 2.0)

func draw_hoard_chest() -> void:
	var center := Vector2(240, hoard_chest_y)
	var ready_pulse := (0.5 + 0.5 * sin(run_time * 5.0)) if hoard_chest_phase == "ready" else 0.0
	var anticipation := maxf(0.01, float(hoard_reveal_profile.get("anticipation", 0.62)))
	var windup := 1.0 - clampf(hoard_chest_timer / anticipation, 0.0, 1.0) if hoard_chest_phase == "windup" else 0.0
	var reveal_charge := windup if hoard_chest_phase == "windup" else 1.0 if hoard_chest_phase == "silence" else 0.0
	var shake_amount := ready_pulse * 0.018 + reveal_charge * reveal_charge * 0.055
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
	var color: Color = drop.color
	var rarity: String = drop.get("rarity", drop.item.get("rarity", "COMMON"))
	var rarity_rank := 3 if rarity == "LEGENDARY" else 2 if rarity == "EPIC" else 1 if rarity == "RARE" else 0
	if rarity_rank > 0:
		var beam := color
		beam.a = (0.08 if rarity_rank == 1 else 0.17 if rarity_rank == 2 else 0.24) + sin(run_time * 9.0 + drop.pos.x) * 0.035
		var beam_width := 11.0 + rarity_rank * 4.0
		var beam_height := 62.0 + rarity_rank * 22.0
		draw_colored_polygon(PackedVector2Array([drop.pos + Vector2(-beam_width, 8), drop.pos + Vector2(-5, -beam_height), drop.pos + Vector2(5, -beam_height), drop.pos + Vector2(beam_width, 8)]), beam)
	var squash_ratio := clampf(float(drop.get("squash", 0.0)) / 0.12, 0.0, 1.0)
	var pulse := 1.0 + sin(run_time * 7.0 + drop.pos.x) * (0.04 + rarity_rank * 0.02) + squash_ratio * 0.12
	var halo := color
	halo.a = 0.12 + rarity_rank * 0.07
	draw_circle(drop.pos, (19.0 + rarity_rank * 2.5) * pulse, halo)
	draw_circle(drop.pos, 16.0 * pulse, Color("#10182cea"))
	draw_arc(drop.pos, (18.0 + rarity_rank) * pulse, run_time * 2.2, run_time * 2.2 + 4.0 + rarity_rank * 0.32, 22, color.lightened(0.28), 2.0 + rarity_rank * 0.65)
	if rarity_rank >= 2:
		for glint in range(4 if rarity_rank == 2 else 6):
			var direction := Vector2.RIGHT.rotated(run_time * 0.8 + TAU * glint / float(4 if rarity_rank == 2 else 6))
			draw_line(drop.pos + direction * 22.0, drop.pos + direction * (28.0 + rarity_rank * 4.0), color.lightened(0.5), 2.0)
	var slot: String = drop.item.get("slot", "Relic")
	var loot_texture := LootlingsUI.item_texture(drop.item)
	LootlingsUI.draw_icon(get_canvas_item(), loot_texture, Rect2(drop.pos - Vector2(18, 18), Vector2(36, 36)))
	var category := ItemCatalog.display_slot(slot).to_upper()
	draw_string(body_font, drop.pos + Vector2(-40, 34), category, HORIZONTAL_ALIGNMENT_CENTER, 80, 10, Color("#f5f7ff"))
	if int(drop.get("bounces", 0)) > 0 or float(drop.get("pickup", 1.0)) < 0.58:
		var item_name := str(drop.item.get("name", "MYSTERY LOOT")).to_upper()
		draw_rect(Rect2(drop.pos.x - 70, drop.pos.y + 39, 140, 20), Color("#071027dc"), true)
		draw_string(body_font, drop.pos + Vector2(-66, 54), item_name, HORIZONTAL_ALIGNMENT_CENTER, 132, 11, color.lightened(0.34))

func draw_moment_overlay() -> void:
	if rarity_reveal_flash > 0.0:
		var rarity_alpha := clampf(rarity_reveal_flash / 0.34, 0.0, 1.0)
		var rarity_edge := rarity_reveal_color
		rarity_edge.a = rarity_alpha * 0.72
		draw_rect(Rect2(5, 151, 470, 545), rarity_edge, false, 5.0)
		draw_circle(Vector2(240, 430), 84.0 + (1.0 - rarity_alpha) * 76.0, Color(rarity_edge.r, rarity_edge.g, rarity_edge.b, rarity_alpha * 0.08))
	if impact_flash > 0.0:
		var flash_alpha := clampf(impact_flash * 1.8, 0.0, 0.16)
		draw_rect(Rect2(0, 146, 480, 555), Color(1.0, 0.94, 0.68, flash_alpha), true)
	if tap_pulse > 0.0 and tap_combo > 1:
		var pulse_alpha := clampf(tap_pulse / 0.18, 0.0, 1.0)
		draw_string(title_font, Vector2(285, 660), "TAP COMBO  x%d" % tap_combo, HORIZONTAL_ALIGNMENT_CENTER, 170, 17 + mini(tap_combo, 6), Color(0.55, 0.92, 1.0, pulse_alpha))
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
	if state == "zone_transition" and (presentation_director == null or not presentation_director.travel_active):
		var transition_ratio := clampf(zone_transition_timer / 0.85, 0.0, 1.0)
		draw_rect(Rect2(0, 146, 480, 568), Color(0.02, 0.03, 0.09, 0.72 * transition_ratio), true)
		var title_color: Color = current_zone.accent
		title_color.a = minf(1.0, transition_ratio * 2.0)
		draw_string(title_font, Vector2(40, 368), zone_transition_title, HORIZONTAL_ALIGNMENT_CENTER, 400, 17, title_color)
		draw_string(title_font, Vector2(30, 414), zone_transition_subtitle, HORIZONTAL_ALIGNMENT_CENTER, 420, 29, Color(1.0, 0.91, 0.64, title_color.a))
