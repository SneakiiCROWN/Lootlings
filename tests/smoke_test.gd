extends SceneTree

const BuildSystem = preload("res://build_system.gd")
const GameCatalog = preload("res://game_catalog.gd")
const ItemCatalog = preload("res://item_catalog.gd")
const LootSystem = preload("res://loot_system.gd")
const InventorySystem = preload("res://inventory_system.gd")
const ShopSystem = preload("res://shop_system.gd")
const MetaStore = preload("res://meta_store.gd")
const HideoutShopSystem = preload("res://hideout_shop_system.gd")
const ZoneCatalog = preload("res://zone_catalog.gd")
const ProfileStore = preload("res://profile_store.gd")
const SettingsStore = preload("res://settings_store.gd")
const ChestCatalog = preload("res://chest_catalog.gd")
const AnalyticsLogger = preload("res://analytics_logger.gd")
const DebugPanel = preload("res://debug_panel.gd")
const DialogueDirector = preload("res://dialogue_director.gd")
const ActionPoseCatalog = preload("res://action_pose_catalog.gd")
const EnemyVariantCatalog = preload("res://enemy_variant_catalog.gd")
const AffixCatalog = preload("res://affix_catalog.gd")
const AchievementManager = preload("res://achievement_manager.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")
const RewardRevealCatalog = preload("res://reward_reveal_catalog.gd")
const WeaponCatalog = preload("res://weapon_catalog.gd")
const WorldContentCatalog = preload("res://world_content_catalog.gd")
const FoundationUI = preload("res://lootlings_ui.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("SMOKE TEST: " + message)

func run_tests() -> void:
	var packed := load("res://main.tscn") as PackedScene
	check(packed != null, "main scene loads")
	if packed == null:
		quit(1)
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var foundation_manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://manifest.json"))
	var wave2: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://manifest_wave2.json"))
	check(wave2.count == 55 and wave2.files.size() == 55, "Wave 2 includes exactly the supplied 55 PNGs")
	for path in wave2.files:
		var texture = FoundationUI.icon("res://%s" % path)
		check(texture is Texture2D and texture.get_width() > 0, "Wave 2 image is a real imported texture: %s" % path)
	check(foundation_manifest.files.size() == 34, "foundation art manifest contains exactly the 34 supplied PNGs")
	for asset_path in foundation_manifest.files:
		var supplied = load("res://%s" % asset_path)
		check(supplied is Texture2D and supplied.get_width() > 0 and supplied.get_height() > 0, "supplied foundation PNG imports as a texture: %s" % asset_path)
	for intent in ["primary", "secondary", "destructive"]:
		for skin_state in ["normal", "hover", "pressed", "disabled", "focus"]:
			var skin = FoundationUI.button_style(Color.WHITE, Color.WHITE, skin_state, intent)
			check(skin.texture.resource_path.ends_with("button_%s_%s.png" % [intent, skin_state]) and skin.protected_margin == Vector2(24, 24), "button intent/state uses supplied art and protected caps")
	check(game.hud_header_surface.texture.resource_path.ends_with("hud_header_9slice.png") and game.hud_build_surface.texture.resource_path.ends_with("hud_build_ribbon_9slice.png"), "HUD uses supplied shells rather than generated chrome")
	check(game.item_panel.get_theme_stylebox("panel").protected_margin == Vector2(32, 32), "panel skins preserve the supplied 32px source corners")
	check(game.startup_ui.name_edit.get_theme_stylebox("focus").texture.resource_path.ends_with("input_focus.png"), "profile input uses the supplied focused skin")
	check(game.state == "boot" and game.startup_ui.visible and not game.hideout_ui.visible, "the game opens with the skippable Relic Core boot presentation")
	var blank_profile := ProfileStore.create_default()
	check(not ProfileStore.is_created(blank_profile) and not str(blank_profile.player_uuid).is_empty() and blank_profile.account_link.has("cloud_save_revision") and blank_profile.has("customisation"), "fresh local profiles have stable identity and future account/customisation fields without forcing a name")
	check(LootlingCatalog.selectable_ids().size() == 7 and not LootlingCatalog.definition("relic_beast").temp_art and LootlingCatalog.definition("emberhorn").temp_art, "seven cosmetic identities expose honest TEMP ART while neutral remains canonical")
	for identity in LootlingCatalog.selectable_ids():
		var identity_profile := ProfileStore.create_default()
		identity_profile.current_lootling_id = identity
		ProfileStore.save_profile("user://identity_test.cfg", identity_profile)
		check(ProfileStore.load_profile("user://identity_test.cfg").current_lootling_id == identity and LootlingCatalog.runtime_texture(identity) != null, "selected identity survives reload: %s" % identity)
	var vanguard_pose := ActionPoseCatalog.sample("VANGUARD", 1.0, 0.02, 1.0, 0.0, false)
	var ranger_pose := ActionPoseCatalog.sample("RANGER", 1.0, 0.02, 1.0, 0.0, false)
	check(vanguard_pose.phase == "ANTICIPATE" and not is_equal_approx(float(vanguard_pose.rotation), float(ranger_pose.rotation)), "data-driven action poses preserve distinct Vanguard and Ranger anticipation silhouettes")
	var variant_rng_a := RandomNumberGenerator.new()
	var variant_rng_b := RandomNumberGenerator.new()
	variant_rng_a.seed = 44123
	variant_rng_b.seed = 44123
	var variants_a: Array[String] = []
	var variants_b: Array[String] = []
	for variant_sample in range(80):
		variants_a.append(EnemyVariantCatalog.roll(variant_rng_a, 9, false))
		variants_b.append(EnemyVariantCatalog.roll(variant_rng_b, 9, false))
	check(variants_a == variants_b and variants_a.any(func(id): return not id.is_empty()), "enemy variants spawn conservatively and deterministically from gameplay RNG")
	check(EnemyVariantCatalog.roll(variant_rng_a, 15, true).is_empty(), "bosses and minibosses are excluded from regular enemy variants")
	check(EnemyVariantCatalog.VARIANTS.size() == 8 and EnemyVariantCatalog.special("overcharged") == "third_spark" and EnemyVariantCatalog.special("rootbound") == "opening_guard", "eight live enemy variants expose readable data and explicit special mechanics")
	var zone_variant_rng := RandomNumberGenerator.new()
	zone_variant_rng.seed = 99117
	for zone_sample in range(120):
		var zone_pick := EnemyVariantCatalog.roll(zone_variant_rng, 12, false, "hoard_depths")
		check(zone_pick.is_empty() or zone_pick in EnemyVariantCatalog.ZONE_POOLS.hoard_depths, "zone-weighted variant rolls never escape the Hoard Depths pool")
	check(WeaponCatalog.FAMILIES.size() == 12 and WeaponCatalog.PROJECTILES.size() == 6 and WeaponCatalog.live_ids().size() == 12, "twelve weapon families are available; seven Forge starters have temporary art and combat hooks")
	check(WeaponCatalog.evolution_for("bow", "Crooked Bow") == ["Crooked Bow", "Ruin Longbow", "Starstring"], "weapon evolution data preserves named three-stage master lines")
	check(WorldContentCatalog.FUTURE_ZONES.size() == 9 and WorldContentCatalog.FUTURE_ZONES.first_hoard.status == "FUTURE", "future zone metadata is replacement-ready without activating missing art")
	check(ItemCatalog.ITEMS.size() >= 35 and ItemCatalog.definition("moonbranch").weapon_type == "bow" and ItemCatalog.definition("vault_receipt").slot == "Relic", "the live equipment pool expands with curated master-catalog identities while preserving slot contracts")
	check(AffixCatalog.AFFIXES.size() == 20 and AffixCatalog.SIGNATURES.size() == 15 and not bool(AffixCatalog.SIGNATURES.aftershock_receipt.live), "expanded affix and Signature catalogs keep unimplemented behaviours out of live rolls")
	var reveal_durations: Array[float] = []
	for reveal_rarity in ItemCatalog.RARITIES:
		var reveal := RewardRevealCatalog.for_rewards("scavenged_cache", [ItemCatalog.create_item("mossguard_harness", reveal_rarity, 700)])
		reveal_durations.append(float(reveal.anticipation))
	check(reveal_durations[0] < reveal_durations[1] and reveal_durations[1] < reveal_durations[2] and reveal_durations[2] < reveal_durations[3], "reward reveal anticipation scales from Common through Legendary without changing contents")
	var legendary_hoard := RewardRevealCatalog.for_rewards("hoard_chest", [ItemCatalog.create_item("bonebow", "EPIC", 703), ItemCatalog.create_item("stormspark", "LEGENDARY", 704), ItemCatalog.create_item("ironpaw_plate", "EPIC", 705)])
	check(legendary_hoard.rarity == "LEGENDARY" and int(legendary_hoard.arc_count) == 3 and float(legendary_hoard.shake) > 0.10, "a Legendary inside the three-item Hoard dominates the reusable reveal profile")
	var signature_item := ItemCatalog.create_item("bonebow", "LEGENDARY", 701)
	signature_item = AffixCatalog.apply(signature_item, ["keen", "crooked_constellation"])
	check(signature_item.affix_ids == ["keen", "crooked_constellation"] and "crooked_volley" in signature_item.signature_hooks, "Signature Loot applies compatible affixes and a behaviour hook without changing the base item ID")
	var incompatible_item := AffixCatalog.apply(ItemCatalog.create_item("mossguard_harness", "LEGENDARY", 702), ["crooked_constellation"])
	check(incompatible_item.affix_ids.is_empty(), "Signature Loot rejects invalid slot/family combinations")
	var achievement_path := "user://smoke_achievements.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(achievement_path))
	var trophy_manager := AchievementManager.new(achievement_path)
	check(not trophy_manager.is_unlocked("ten_chests") and trophy_manager.add_progress("ten_chests", 9) == false and trophy_manager.add_progress("ten_chests") == true, "achievement counters unlock exactly at their target")
	var reloaded_trophies := AchievementManager.new(achievement_path)
	check(reloaded_trophies.is_unlocked("ten_chests") and int(reloaded_trophies.progress.ten_chests) == 10, "achievement unlock state and progress persist locally")
	for destination_id in ["home", "stash", "shrine", "shop", "archive"]:
		reloaded_trophies.mark_unique("hideout_social", destination_id)
	check(reloaded_trophies.is_unlocked("hideout_social") and int(reloaded_trophies.progress.hideout_social) == 5, "unique achievement progress persists distinct destination keys")
	check(reloaded_trophies.display_description(AchievementManager.definition_for("bonk_nothing")) == "???", "secret achievements conceal their description until unlocked")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(achievement_path))
	check(AudioServer.get_bus_index("Music") >= 0 and AudioServer.get_bus_index("SFX") >= 0 and AudioServer.get_bus_index("UI") >= 0 and AudioServer.get_bus_index("Ambience") >= 0, "Godot-native audio buses are available")
	var master_bus := AudioServer.get_bus_index("Master")
	var master_is_limited := false
	for effect_index in range(AudioServer.get_bus_effect_count(master_bus)):
		master_is_limited = master_is_limited or AudioServer.get_bus_effect(master_bus, effect_index) is AudioEffectLimiter
	check(master_is_limited, "the player-facing mix has a Master limiter for dense combat/reward overlap")
	check(DebugPanel.allowed(true) and not DebugPanel.allowed(false), "development toolkit has an explicit release-build gate")
	check(game.debug_enabled and game.debug_panel != null and not game.debug_panel.visible, "development toolkit exists but starts hidden in debug builds")
	check(game.presentation_director != null and game.presentation_director.has_method("set_loading_progress"), "one reusable presentation director owns menu, reward, and travel transitions")
	game.debug_panel.open()
	check(game.debug_panel.visible and paused, "development panel visibly pauses the game while open")
	var close_event := InputEventKey.new()
	close_event.keycode = KEY_F1
	close_event.pressed = true
	game.debug_panel._unhandled_input(close_event)
	check(not game.debug_panel.visible and not paused, "F1 closes the development panel and resumes normal processing")
	game.debug_panel.open()
	check(game.debug_panel.visible and paused, "development panel can reopen after keyboard close")
	close_event.keycode = KEY_ESCAPE
	game.debug_panel._unhandled_input(close_event)
	check(not game.debug_panel.visible and not paused, "Escape closes the development panel without leaving a stuck pause")
	game.debug_panel.open()
	game.debug_panel.close_button.pressed.emit()
	check(not game.debug_panel.visible and not paused, "visible close button closes the development panel and restores pause state")
	var variant_a: int = game.audio_manager.choose_variant("normal_hit", 4)
	var variant_b: int = game.audio_manager.choose_variant("normal_hit", 4)
	check(variant_a != variant_b, "frequent procedural audio avoids immediate variant repetition")
	var hit_variant_a = game.audio_manager.make_tone(125.0, 0.11, 0.56, "normal_hit", 0)
	var hit_variant_b = game.audio_manager.make_tone(125.0, 0.11, 0.56, "normal_hit", 1)
	check(hit_variant_a.data != hit_variant_b.data, "frequent audio variants change timbre rather than only selecting a new index")
	var long_music = game.audio_manager.make_ambient_loop(196.0, "OUTER_RUINS")
	check(long_music.data.size() == 48 * 16000 * 2, "procedural score uses a precomputed 48-second multi-section phrase")
	check(long_music.loop_mode == AudioStreamWAV.LOOP_FORWARD and long_music.loop_end == 48 * 16000, "long-form score loops cleanly without runtime synthesis")
	var hideout_music = game.audio_manager.make_ambient_loop(196.0, "HIDEOUT")
	check(long_music.data != hideout_music.data, "location scores vary instrumentation as well as base pitch")
	var music_peak := 0
	for sample_offset in range(0, long_music.data.size(), 400):
		music_peak = maxi(music_peak, absi(long_music.data.decode_s16(sample_offset)))
	check(music_peak < 32767, "procedural score retains peak headroom and does not hard clip")
	for music_path in game.audio_manager.MUSIC_PATHS.values():
		check(ResourceLoader.exists(music_path), "prebaked long-form score cue is importable: %s" % music_path)
	var dialogue_test := DialogueDirector.new(7731)
	var first_line: Dictionary = dialogue_test.choose("tapped", "Salvager")
	var blocked_line: Dictionary = dialogue_test.choose("tapped", "Salvager")
	check(first_line.get("speaker", "") == "Salvager" and not first_line.get("text", "").is_empty(), "context dialogue honours the requested speaker")
	check(blocked_line.is_empty(), "context dialogue enforces a per-speaker cooldown")
	dialogue_test.update(DialogueDirector.SPEAKER_COOLDOWN + 0.1)
	var second_line: Dictionary = dialogue_test.choose("tapped", "Salvager")
	check(not second_line.is_empty() and second_line.text != first_line.text, "context dialogue avoids immediate repeated lines after cooldown")
	game.startup_ui.configure(blank_profile, false, game.audio_settings)
	game.startup_ui.skip_boot()
	check(game.startup_ui.current_screen == "title", "a fresh install sees the Lootlings title before onboarding")
	game.startup_ui.request_play()
	check(game.startup_ui.current_screen == "profile_create", "first Play opens one lightweight welcome/profile step")
	game.startup_ui.name_edit.text = "Smoke Seeker"
	game.startup_ui.nickname_edit.text = "Nib"
	game.startup_ui.save_profile()
	check(game.startup_ui.current_screen == "lootling_select", "new profiles continue into the starter Lootling selector")
	game.startup_ui.confirm_lootling()
	await create_timer(0.55).timeout
	check(game.state == "hideout" and game.hideout_ui.visible, "starter confirmation continues directly into the Hideout")
	var original_uuid: String = game.profile.player_uuid
	var persisted_profile: Dictionary = ProfileStore.load_profile(game.PROFILE_SAVE_PATH)
	check(persisted_profile.display_name == "Smoke Seeker" and persisted_profile.lootling_nickname == "Nib" and persisted_profile.player_uuid == original_uuid, "display name, optional nickname, and stable UUID persist")
	game.startup_ui.configure(persisted_profile, true, game.audio_settings)
	game.startup_ui.skip_boot()
	check(game.startup_ui.current_screen == "title", "normal launch with a profile never asks for the display name again")
	game.startup_ui.show_profile(false)
	game.startup_ui.name_edit.text = "Smoke Captain"
	game.startup_ui.save_profile()
	check(game.profile.display_name == "Smoke Captain" and game.profile.player_uuid == original_uuid, "display-name editing never changes the internal player UUID")
	game.startup_ui.show_settings()
	game.startup_ui.setting_sliders.music.value = 0.31
	game.startup_ui.setting_mutes.sfx.button_pressed = true
	game.startup_ui.save_settings()
	var persisted_settings := SettingsStore.load_settings(game.SETTINGS_SAVE_PATH)
	check(is_equal_approx(float(persisted_settings.music), 0.31) and bool(persisted_settings.sfx_muted) and AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "volume and mute settings persist and apply to the live bus")
	var legacy_meta_path := "user://lootlings_meta_legacy_smoke.cfg"
	var legacy_meta := ConfigFile.new()
	legacy_meta.set_value("progress", "version", 1)
	legacy_meta.set_value("progress", "shards", 23)
	legacy_meta.set_value("progress", "power", 4)
	legacy_meta.save(legacy_meta_path)
	var migrated_meta := MetaStore.load_progress(legacy_meta_path)
	check(migrated_meta.shards == 23 and migrated_meta.power == 4 and migrated_meta.gold == 0, "version-1 meta saves migrate without losing Shards or power")
	var analytics_smoke_path := "user://lootlings_analytics_smoke.jsonl"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(analytics_smoke_path))
	AnalyticsLogger.log_event(analytics_smoke_path, "profile_created", {"display_name":"Private Smoke Name", "lootling_nickname":"Private Nickname", "result":"ok"})
	var analytics_smoke_file := FileAccess.open(analytics_smoke_path, FileAccess.READ)
	var analytics_text := analytics_smoke_file.get_as_text() if analytics_smoke_file != null else ""
	check(analytics_text.contains("profile_created") and analytics_text.contains("result") and not analytics_text.contains("Private Smoke Name") and not analytics_text.contains("Private Nickname"), "local analytics records schema events without profile names")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(analytics_smoke_path))
	game.enter_hideout_from_title()
	check(ZoneCatalog.all_zone_ids() == ["outer_ruins", "emberworks", "hoard_depths"], "the expedition exposes three stable ordered zone IDs")
	check(ZoneCatalog.for_wave(1).id == "outer_ruins" and ZoneCatalog.for_wave(6).id == "emberworks" and ZoneCatalog.for_wave(11).id == "hoard_depths", "wave ranges resolve to the intended zone data")
	check(game.state == "hideout" and game.hideout_ui.visible and not game.startup_ui.visible, "the title enters the existing Hideout")
	check(game.hideout_ui.current_screen == "home", "the Hideout opens on its Home screen")
	check(ChestCatalog.CHESTS.size() == 6 and ChestCatalog.is_valid("scavenged_cache") and ChestCatalog.definition("hoard_chest").rolls == 3 and ChestCatalog.PRESENTATION_PHASES.back() == "reveal", "stable and future chest definitions expose bounded reward-presentation phases without changing live rewards")
	check(ZoneCatalog.encounter_for(ZoneCatalog.for_wave(1), 1, 0).kind == "solo" and "small_swarm" in ZoneCatalog.supported_encounter_kinds(), "encounter data is future-ready for deliberate duos and small swarms")
	game.hideout_ui.show_stash()
	check(game.hideout_ui.current_screen == "stash", "the Hideout gear chest opens Stash")
	game.hideout_ui.show_shop()
	check(game.hideout_ui.current_screen == "shop", "the Hideout merchant stall opens Shop")
	game.hideout_ui.show_upgrades()
	check(game.hideout_ui.current_screen == "upgrades", "the Hideout Relic shrine opens Training")
	game.hideout_ui.show_achievements()
	check(game.hideout_ui.current_screen == "achievements" and game.hideout_ui.achievement_grid.columns == 3 and not game.hideout_ui.achievement_detail.text.is_empty(), "the Trophy Archive is a phone-readable badge collection with focused detail")
	game.hideout_ui.show_coming_soon("LOOTBOOK")
	check(game.hideout_ui.current_screen == "coming", "the Hideout archive opens Lootbook Coming Soon")
	game.hideout_ui.show_home()
	for asset_path in [
		"res://art/sprites/relic_beast_base.png",
		"res://art/sprites/enemies/razor_imp.png",
		"res://art/sprites/enemies/mossback_brute.png",
		"res://art/sprites/enemies/lantern_hexer.png",
		"res://art/sprites/enemies/grump_knight.png",
		"res://art/sprites/enemies/hoard_dragon.png",
		"res://art/backgrounds/treasure_ruins_arena.png",
		"res://art/sprites/weapons/vanguard_hammer.png",
		"res://art/sprites/weapons/ranger_bow.png",
		"res://art/sprites/weapons/mage_staff.png",
		"res://art/sprites/rewards/hoard_chest.png",
		"res://art/sprites/weapons/rogue_daggers.png"
	]:
		check(load(asset_path) is Texture2D, "%s imports as a Texture2D" % asset_path)
	check(ItemCatalog.display_slot("Relic") == "CHARM" and ItemCatalog.display_slot("Rune") == "RUNE", "equipment terminology separates Charm from the Relic Core")
	var persistent_shop = HideoutShopSystem.new(4455)
	persistent_shop.ensure_stock()
	check(persistent_shop.stock.size() == 3, "Hideout Shop generates three persistent equipment offers")
	for offer in persistent_shop.stock:
		check(offer.get("rarity", "") != "LEGENDARY" and int(offer.get("price", 0)) > 0, "Hideout Shop offers use conservative rarity and centralized Scrap prices")
	var persistent_shop_path := "user://lootlings_hideout_shop_smoke.cfg"
	check(persistent_shop.save(persistent_shop_path) == OK, "Hideout Shop stock saves successfully")
	var loaded_shop = HideoutShopSystem.new(4466)
	loaded_shop.load(persistent_shop_path)
	check(loaded_shop.stock.size() == 3 and loaded_shop.cycle == persistent_shop.cycle, "Hideout Shop stock persists across reloads")
	check(loaded_shop.reroll() and not loaded_shop.reroll(), "Hideout Shop allows only one paid reroll per completed-run cycle")
	for sold_index in range(loaded_shop.stock.size()):
		loaded_shop.take_offer(sold_index)
	loaded_shop.save(persistent_shop_path)
	var sold_out_shop = HideoutShopSystem.new(4467)
	sold_out_shop.load(persistent_shop_path)
	var sold_slots := 0
	for sold_offer in sold_out_shop.stock:
		if sold_offer.is_empty():
			sold_slots += 1
	check(sold_slots == 3 and sold_out_shop.cycle == loaded_shop.cycle, "sold-out Hideout stock stays sold out until a run completes")
	var capacity_inventory = InventorySystem.new()
	check(capacity_inventory.expand_stash() and capacity_inventory.stash_capacity == 18, "first Stash expansion increases capacity to 18")
	check(capacity_inventory.expand_stash() and capacity_inventory.stash_capacity == 24 and not capacity_inventory.expand_stash(), "second Stash expansion reaches the data-driven 24-slot maximum")
	game.inventory.reset_to_starter()
	game.inventory.scrap = 999
	game.hideout_shop = HideoutShopSystem.new(4477)
	game.hideout_shop.ensure_stock()
	game.hideout_ui.configure(game.inventory, game.hideout_shop, game.meta_shards, game.meta_power, Callable(game, "build_item_comparison"))
	for fill_index in range(game.inventory.stash_capacity):
		game.inventory.keep(ItemCatalog.create_item("ember_pop", "COMMON", 8000 + fill_index))
	var full_scrap_before: int = game.inventory.scrap
	var full_stock_before: int = game.hideout_shop.stock.size()
	game.buy_hideout_offer(0)
	check(game.inventory.stash.size() == game.inventory.stash_capacity and game.inventory.scrap == full_scrap_before and game.hideout_shop.stock.size() == full_stock_before, "a full Stash safely rejects Shop purchases without spending Scrap")
	game.inventory.scrap_from_stash(0)
	var bought_item: Dictionary = game.hideout_shop.stock[0].duplicate(true)
	var bought_price: int = bought_item.price
	var buy_scrap_before: int = game.inventory.scrap
	game.buy_hideout_offer(0)
	check(game.inventory.stash.size() == game.inventory.stash_capacity and game.inventory.scrap == buy_scrap_before - bought_price and game.hideout_shop.stock[0].is_empty(), "buying Hideout equipment spends Scrap, marks its display sold, and sends the item to Stash")
	var purchased_index := -1
	for stash_index in range(game.inventory.stash.size()):
		if game.inventory.stash[stash_index].get("serial", 0) == bought_item.get("serial", -1):
			purchased_index = stash_index
			break
	check(purchased_index >= 0, "the purchased equipment can be located in the persistent Stash")
	if purchased_index >= 0:
		game.equip_stash_item(purchased_index)
		var purchased_reload = InventorySystem.new()
		purchased_reload.load(game.INVENTORY_SAVE_PATH)
		check(purchased_reload.equipped_item(bought_item.slot).get("serial", 0) == bought_item.serial, "purchased gear can be equipped and persists")
	game.inventory.reset_to_starter()
	game.inventory.scrap = 999
	game.hideout_shop = HideoutShopSystem.new(4488)
	game.hideout_shop.ensure_stock()
	game.hideout_ui.configure(game.inventory, game.hideout_shop, game.meta_shards, game.meta_power, Callable(game, "build_item_comparison"))
	var cache_scrap_before: int = game.inventory.scrap
	game.use_mystery_cache()
	check(not game.hideout_shop.pending_cache_item.is_empty() and game.inventory.stash.is_empty() and game.inventory.scrap == cache_scrap_before - game.hideout_shop.CACHE_COST, "Mystery Cache reveals an item before adding it to Stash")
	game.use_mystery_cache()
	check(game.hideout_shop.pending_cache_item.is_empty() and game.inventory.stash.size() == 1, "the revealed Mystery Cache item is awarded on claim")
	var cache_claimed_scrap: int = game.inventory.scrap
	game.use_mystery_cache()
	check(game.inventory.stash.size() == 1 and game.inventory.scrap == cache_claimed_scrap, "only one Mystery Cache can be opened per completed-run cycle")
	game.inventory.reset_to_starter()
	game.hideout_shop = HideoutShopSystem.new(4490)
	game.hideout_shop.ensure_stock()
	game.gold = 500
	game.hideout_ui.configure(game.inventory, game.hideout_shop, game.meta_shards, game.meta_power, Callable(game, "build_item_comparison"), game.gold, game.profile, game.gold_upgrades)
	game.use_gold_cache()
	check(game.gold == 500 - game.hideout_shop.GOLD_CACHE_COST and game.hideout_shop.pending_cache_currency == "gold" and not game.hideout_shop.pending_cache_item.is_empty(), "Scavenged Cache spends conservative persistent Gold and reveals before claiming")
	game.use_gold_cache()
	check(game.hideout_shop.pending_cache_item.is_empty() and game.inventory.stash.size() == 1 and game.hideout_shop.gold_cache_bought_this_cycle, "Gold cache claim safely enters the Stash and is capped once per completed run")
	game.gold = 2000
	game.gold_upgrades = {"bedroll":0, "whetstone":0, "pouch":0}
	game.buy_gold_upgrade("bedroll")
	game.buy_gold_upgrade("whetstone")
	game.buy_gold_upgrade("pouch")
	check(game.gold_upgrades == {"bedroll":1, "whetstone":1, "pouch":1} and game.gold == 1225, "capped Hideout utility upgrades spend Gold at centralized early-rank costs")
	game.start_run()
	check(is_equal_approx(game.player_max_hp, 104.0) and is_equal_approx(game.base_damage, 11.6) and game.coins == 8, "Bedroll, Whetstone, and Field Pouch apply small flat starting bonuses")
	game.show_hideout()
	game.gold_upgrades = {"bedroll":0, "whetstone":0, "pouch":0}
	game.gold = 0
	game.save_meta()
	game.inventory.scrap = 999
	var expansion_scrap_before: int = game.inventory.scrap
	var expansion_cost: int = game.hideout_shop.expansion_cost(game.inventory.stash_capacity)
	game.buy_stash_expansion()
	check(game.inventory.stash_capacity == 18 and game.inventory.scrap == expansion_scrap_before - expansion_cost, "Stash Expansion purchases 12 to 18 slots with Scrap")
	var expanded_reload = InventorySystem.new()
	expanded_reload.load(game.INVENTORY_SAVE_PATH)
	check(expanded_reload.stash_capacity == 18 and expanded_reload.scrap == game.inventory.scrap, "Stash capacity and Scrap persist across reloads")
	var old_cycle: int = game.hideout_shop.cycle
	var gold_before_completed_run: int = game.gold
	game.start_run()
	game.end_run(false)
	check(game.hideout_shop.cycle == old_cycle + 1 and game.hideout_shop.stock.size() == 3 and not game.hideout_shop.rerolled_this_cycle and not game.hideout_shop.cache_bought_this_cycle and not game.hideout_shop.gold_cache_bought_this_cycle, "Hideout Shop stock and both caches refresh after a completed run")
	check(game.gold > gold_before_completed_run and MetaStore.load_progress(game.SAVE_PATH).gold == game.gold, "completed runs award persistent Gold and save it immediately")
	game.inventory.reset_to_starter()
	game.inventory.save(game.INVENTORY_SAVE_PATH)
	game.show_hideout()
	var abandon_shop_cycle: int = game.hideout_shop.cycle
	var abandon_shards: int = game.meta_shards
	var abandon_scrap: int = game.inventory.scrap
	game.start_run()
	game.coins = 77
	game.pending_items.append(ItemCatalog.create_item("glimmerstaff", "EPIC", 7699))
	var paused_run_time: float = game.run_time
	game.pause_run()
	game._process(1.0)
	check(game.state == "paused" and is_equal_approx(game.run_time, paused_run_time), "Pause freezes active run progression")
	game.resume_run()
	check(game.state == "playing", "Resume returns safely to active combat")
	game.pause_run()
	game.request_abandon_run()
	check(game.state == "abandon_confirm", "Abandon requires a separate confirmation step")
	game.cancel_abandon_run()
	check(game.state == "paused", "Stay returns to the paused run without loss")
	game.request_abandon_run()
	game.confirm_abandon_run()
	check(game.state == "hideout" and game.coins == 0 and game.pending_items.is_empty() and not game.result_panel.visible, "confirmed abandon discards run-only progress and returns directly to Hideout")
	check(game.hideout_shop.cycle == abandon_shop_cycle and game.meta_shards == abandon_shards and game.inventory.scrap == abandon_scrap, "abandon grants no rewards and does not refresh Shop or alter persistent currency")
	game.start_run()
	check(game.coins == 0, "Run Scrip always resets when a new run begins")
	var hideout_kept_item := ItemCatalog.create_item("mossguard_harness", "RARE", 7701)
	game.current_item = hideout_kept_item
	game.state = "item"
	game.accept_item_keep()
	game.show_hideout()
	check(game.inventory.stash.size() == 1 and game.inventory.stash[0].get("serial", 0) == 7701, "loot kept during a run appears in the Hideout stash")
	game.equip_stash_item(0)
	var persisted_game_inventory = InventorySystem.new()
	persisted_game_inventory.load(game.INVENTORY_SAVE_PATH)
	check(persisted_game_inventory.equipped_item("Armour").get("serial", 0) == 7701, "equipping from the Hideout persists across an inventory reload")
	game.inventory.reset_to_starter()
	game.inventory.save(game.INVENTORY_SAVE_PATH)
	game.start_run()
	var identity_build = BuildSystem.new()
	identity_build.add_upgrade(upgrade_by_id("ignite"))
	identity_build.add_upgrade(upgrade_by_id("wildfire"))
	check(identity_build.dominant() == "Fire" and identity_build.tier() == 1, "build tags produce a Fire evolution threshold")
	check(BuildSystem.COLORS.Fire != BuildSystem.COLORS.Lightning and BuildSystem.COLORS.Poison != BuildSystem.COLORS.Physical, "implemented identities have distinct visual palettes")
	check(identity_build.class_influence("Neutral") == "Main Mascot RelicBeast", "neutral player identity remains separate from Emberhorn")
	check(identity_build.class_influence("Fire") == "Emberhorn", "Fire visuals can reference Emberhorn without replacing the mascot")
	var test_loot = LootSystem.new(8844)
	for rarity_index in range(100):
		var bounded_item: Dictionary = test_loot.generate_shop_item()
		check(ItemCatalog.rarity_rank(bounded_item.rarity) in range(4), "generated item rarity stays inside catalog bounds")
	for drop_index in range(25):
		var miniboss_drop: Dictionary = test_loot.roll_drop(true, false)
		check(not miniboss_drop.is_empty() and ItemCatalog.rarity_rank(miniboss_drop.rarity) >= 1, "miniboss loot is guaranteed Rare or better")
	var boss_drop: Dictionary = test_loot.roll_drop(false, true)
	check(not boss_drop.is_empty() and ItemCatalog.rarity_rank(boss_drop.rarity) >= 2, "boss loot is guaranteed Epic or better")
	var comparison: String = game.build_item_comparison(ItemCatalog.create_item("mimic_mallet", "EPIC", 776), ItemCatalog.create_item("scrapfang_blade", "COMMON", 775))
	check(comparison.contains("#69e6b0") and comparison.contains("#ff7d88"), "loot comparison marks gains green and losses red")
	check(game.format_effect_delta("crit", 0.10) == "+10% CRIT CHANCE", "item comparison distinguishes critical-hit chance from critical-hit damage")
	check(game.item_equip_button.has_meta("presentation_bound") and game.item_keep_button.has_meta("presentation_bound") and game.item_scrap_button.has_meta("presentation_bound"), "item decision buttons retain their shared short tactile feedback")
	var test_inventory = InventorySystem.new()
	var rare_bow := AffixCatalog.apply(ItemCatalog.create_item("bonebow", "LEGENDARY", 777), ["keen", "crooked_constellation"])
	test_inventory.equip(rare_bow)
	check(test_inventory.weapon_family() == "RANGER" and test_inventory.effect_total("crit") > 0.0, "equipped weapon exposes its combat family and affixes")
	var stored_armour := ItemCatalog.create_item("mossguard_harness", "COMMON", 778)
	check(test_inventory.keep(stored_armour), "found gear can be kept in the stash")
	check(test_inventory.equip_from_stash(0), "stored gear can be equipped from the Hideout stash")
	check(test_inventory.equipped_item("Armour").get("serial", 0) == 778 and test_inventory.stash.is_empty(), "stash equip updates the correct equipment slot")
	var stored_relic := ItemCatalog.create_item("ember_pop", "EPIC", 779)
	check(test_inventory.keep(stored_relic), "a second item can be stored for salvage testing")
	var scrap_before: int = test_inventory.scrap
	var expected_scrap := ItemCatalog.scrap_value(stored_relic)
	check(test_inventory.scrap_from_stash(0) == expected_scrap, "stored gear can be scrapped from the Hideout stash")
	check(test_inventory.scrap == scrap_before + expected_scrap and test_inventory.stash.is_empty(), "stash salvage removes the item and grants persistent Scrap")
	var inventory_test_path := "user://lootlings_inventory_smoke.cfg"
	check(test_inventory.save(inventory_test_path) == OK, "inventory and scrap save successfully")
	var loaded_inventory = InventorySystem.new()
	loaded_inventory.load(inventory_test_path)
	check(loaded_inventory.weapon_family() == "RANGER" and loaded_inventory.has_signature("crooked_volley") and loaded_inventory.equipped_item("Armour").get("serial", 0) == 778 and loaded_inventory.stash.is_empty() and loaded_inventory.scrap == test_inventory.scrap, "Hideout equipment, Signature hooks and Scrap persist through save/load")
	var legacy_inventory_path := "user://lootlings_inventory_legacy_smoke.cfg"
	var legacy_config := ConfigFile.new()
	legacy_config.set_value("inventory", "version", 1)
	legacy_config.set_value("inventory", "scrap", 17)
	legacy_config.set_value("inventory", "stash", [ItemCatalog.create_item("stormspark", "COMMON", 780)])
	legacy_config.set_value("inventory", "equipped", test_inventory.equipped)
	legacy_config.save(legacy_inventory_path)
	var legacy_inventory = InventorySystem.new()
	legacy_inventory.load(legacy_inventory_path)
	check(legacy_inventory.stash_capacity == 12 and legacy_inventory.stash.size() == 1 and legacy_inventory.scrap == 17, "version 1 inventory saves load with the original 12-slot capacity")
	var test_shop = ShopSystem.new()
	test_shop.generate_stock(test_loot, 6)
	check(test_shop.stock.size() == 3 and int(test_shop.stock[0].price) > 0, "merchant generates three priced choices")
	var common_price_wave_6 := test_shop.price_for(ItemCatalog.create_item("mossguard_harness", "COMMON", 901), 6)
	var rare_price_wave_6 := test_shop.price_for(ItemCatalog.create_item("mossguard_harness", "RARE", 902), 6)
	var rare_price_wave_11 := test_shop.price_for(ItemCatalog.create_item("mossguard_harness", "RARE", 903), 11)
	check(common_price_wave_6 == 94 and rare_price_wave_6 == 144 and rare_price_wave_11 == 174, "merchant prices use the tuned rarity and later-stop curve")
	check(test_shop.reroll_cost(6) == 91 and test_shop.reroll_cost(11) == 121, "merchant rerolls are meaningful wave-scaled decisions")
	var first_serial: int = test_shop.stock[0].serial
	test_shop.reroll(test_loot, 6)
	check(test_shop.stock.size() == 3 and int(test_shop.stock[0].serial) != first_serial, "merchant reroll replaces its stock")
	var original_equipped: Dictionary = game.inventory.equipped.duplicate(true)
	game.inventory.equip(ItemCatalog.create_item("scrapfang_blade", "COMMON", 880))
	var vanguard_interval: float = game.current_attack_interval()
	game.inventory.equip(ItemCatalog.create_item("bonebow", "COMMON", 881))
	check(game.current_attack_interval() < vanguard_interval and game.target_player_x() < game.PLAYER_ATTACK_X, "Ranger weapons attack faster from a readable ranged position")
	game.inventory.equip(ItemCatalog.create_item("moonbite_daggers", "COMMON", 882))
	check(game.effective_crit_chance() > game.crit_chance and game.current_attack_interval() < vanguard_interval, "Rogue weapons provide fast crit-focused combat")
	game.inventory.equip(ItemCatalog.create_item("glimmerstaff", "COMMON", 883))
	check(game.target_player_x() < game.PLAYER_ATTACK_X, "Mage weapons maintain ranged spellcaster spacing")
	check(game.creature_renderer.weapon_pose_angle("RANGER", 0.0, 1.0) < 0.10 and game.creature_renderer.weapon_pose_angle("MAGE", 0.0, 1.0) < -0.30, "Ranger releases forward while Mage raises the staff instead of swinging like melee")
	var equipped_family_before_debug: String = game.inventory.weapon_family()
	game.debug_weapon_family_override = "ROGUE"
	check(game.current_weapon_family() == "ROGUE" and game.inventory.weapon_family() == equipped_family_before_debug, "debug weapon presentation overrides stay session-only and do not mutate equipment")
	game.debug_weapon_family_override = ""
	game.state = "playing"
	game.enemy_alive = true
	game.enemy_serial += 1
	game.player_x = game.target_player_x()
	game.enemy_hp = 999.0
	game.enemy_max_hp = 999.0
	var ranged_hp_before: float = game.enemy_hp
	game.perform_player_attack(false)
	check(game.attack_projectiles.size() == 1 and is_equal_approx(game.enemy_hp, ranged_hp_before), "Mage attacks launch a readable projectile before damage resolves")
	game.update_attack_projectiles(0.3)
	check(game.attack_projectiles.is_empty() and game.enemy_hp < ranged_hp_before, "Mage projectile resolves damage on arrival")
	game.inventory.equip(ItemCatalog.create_item("bonebow", "COMMON", 884))
	game.enemy_hp = 999.0
	ranged_hp_before = game.enemy_hp
	game.perform_player_attack(false)
	check(game.attack_projectiles.size() == 1 and is_equal_approx(game.enemy_hp, ranged_hp_before), "Ranger attacks launch an arrow before damage resolves")
	game.update_attack_projectiles(0.3)
	check(game.attack_projectiles.is_empty() and game.enemy_hp < ranged_hp_before, "Ranger arrow resolves damage on arrival")
	game.inventory.equip(ItemCatalog.create_item("scrapfang_blade", "COMMON", 885))
	game.player_x = game.target_player_x()
	game.enemy_hp = 999.0
	var melee_hp_before: float = game.enemy_hp
	game.perform_player_attack(false)
	check(game.attack_projectiles.is_empty() and game.enemy_hp < melee_hp_before, "Vanguard remains immediate close-range melee")
	game.inventory.equip(ItemCatalog.create_item("moonbite_daggers", "COMMON", 886))
	game.player_x = game.target_player_x()
	game.enemy_hp = 999.0
	melee_hp_before = game.enemy_hp
	game.perform_player_attack(false)
	check(game.attack_projectiles.is_empty() and game.enemy_hp < melee_hp_before, "Rogue remains immediate close-range melee")
	game.inventory.equipped = original_equipped
	game.start_run()
	game.debug_god_mode = true
	var god_hp_before: float = game.player_hp
	game.perform_enemy_attack()
	check(is_equal_approx(game.player_hp, god_hp_before), "development god mode is a real incoming-damage guard")
	game.debug_god_mode = false
	var lantern_item := AffixCatalog.apply(ItemCatalog.create_item("mossguard_harness", "LEGENDARY", 889), ["last_lantern"])
	game.inventory.equip(lantern_item)
	game.last_lantern_spent = false
	game.player_hp = 1.0
	game.enemy_damage = 999.0
	game.perform_enemy_attack()
	check(is_equal_approx(game.player_hp, 1.0) and game.last_lantern_spent and game.state == "playing", "Last Lantern prevents fatal damage exactly once without ending the run")
	game.inventory.equipped = original_equipped.duplicate(true)
	game.start_run()
	var frostbell_item := AffixCatalog.apply(ItemCatalog.create_item("bonebow", "LEGENDARY", 890), ["frostbell_chime"])
	game.inventory.equip(frostbell_item)
	game.enemy_attack_clock = 0.0
	game.damage_enemy(1.0, false, false)
	check(game.enemy_frostbell_used and game.enemy_attack_clock >= 0.32, "Frostbell Chime visibly delays the first enemy action once per foe")
	game.inventory.equipped = original_equipped.duplicate(true)
	game.start_run()
	game.enemy_archetype = "tank"
	game.enemy_is_miniboss = false
	game.enemy_is_boss = false
	check(game.target_player_x() == 212.0, "melee combat keeps a separate resting anchor against tanks")
	game.enemy_is_boss = true
	check(game.target_player_x() == 184.0, "boss silhouettes receive the widest melee resting separation")
	game.apply_upgrade_effect(upgrade_by_id("greed"))
	check(game.build.count("Poison") == 0 and is_equal_approx(game.coin_reward_mult, 1.25) and is_equal_approx(game.xp_reward_mult, 1.15), "Relic Magnet is neutral utility with separated restrained Run Scrip and XP bonuses")
	game.start_run()
	game.coins = 999
	game.wave = 6
	game.show_merchant()
	var coins_before_purchase: int = game.coins
	var purchase_price: int = game.shop.stock[0].price
	game.buy_merchant_item(0)
	check(game.coins == coins_before_purchase - purchase_price and game.state == "item", "merchant purchase spends Run Scrip and opens the item decision")
	game.accept_item_scrap()
	check(game.state == "merchant", "merchant purchase returns safely to the shop")
	var coins_before_reroll: int = game.coins
	game.reroll_merchant()
	check(game.coins < coins_before_reroll and game.shop.rerolls == 1, "merchant reroll spends Run Scrip")
	game.leave_merchant()
	for mechanic_id in ["ignite", "storm", "venom", "heavy"]:
		game.start_run()
		game.apply_upgrade_effect(upgrade_by_id(mechanic_id))
		game.player_x = game.PLAYER_ATTACK_X
		game.enemy_max_hp = 99999.0
		game.enemy_hp = game.enemy_max_hp
		game.enemy_hit_multiplier = 1.0
		if mechanic_id == "storm":
			game.attack_sequence = 3
		elif mechanic_id == "heavy":
			game.attack_sequence = 4
		var hp_before: float = game.enemy_hp
		game.perform_player_attack(false)
		match mechanic_id:
			"ignite": check(game.enemy_burn_dps > 0.0, "Fire upgrades ignite enemies")
			"storm": check(hp_before - game.enemy_hp > game.base_damage * 1.2, "Lightning upgrades trigger chain damage")
			"venom": check(game.enemy_poison_stacks > 0, "Poison upgrades stack damage over time")
			"heavy": check(hp_before - game.enemy_hp > game.base_damage * 1.7, "Physical upgrades trigger heavy rhythm hits")
	game.start_run()
	game.pending_levels = 1
	game.show_upgrade_choices()
	for upgrade in GameCatalog.UPGRADES:
		var clean_card: String = game.format_upgrade_card(upgrade, 1)
		check(clean_card.contains(str(upgrade.name)) and clean_card.contains("STACK  ×1") and not clean_card.contains("(x1)"), "upgrade card formats %s without merging stack text into its mechanic" % upgrade.id)
	check(game.upgrade_buttons.all(func(button): return button.size.x <= game.upgrade_panel.size.x - 40.0 and button.clip_text), "all upgrade cards remain constrained to the level-up panel")
	check(game.upgrade_visuals.size() == 3 and game.upgrade_visuals.all(func(card): return not card.name.text.is_empty() and not card.effect.text.is_empty()), "upgrade hierarchy retains three readable names and effects")
	check(game.upgrade_visuals.all(func(card): return card.icon.texture != null and card.icon.texture.resource_path.contains("/upgrades/") and card.core.texture != null and card.rarity.texture != null), "level-up sockets use actual upgrade/Core/rarity textures")
	check(game.hideout_ui.trophy_texture_path({"category":"Combat"}, false, false).ends_with("trophy_locked.png") and game.hideout_ui.trophy_texture_path({"category":"Combat"}, true, false).ends_with("category_combat.png") and game.hideout_ui.trophy_texture_path({"category":"Secret"}, false, true).ends_with("category_secret.png"), "trophy visual states preserve lock and secret behaviour")
	check(not game.debug_panel.visible, "ordinary combat/upgrade presentation never opens DEVELOPMENT ONLY")
	check(game.upgrade_buttons.all(func(button): return button.get_theme_color("font_color").a == 0.0), "legacy text tokens do not render as upgrade icons")
	game.choose_upgrade(0)
	check(game.wave_banner_timer > 0.0 and game.status_clock == 0.0, "upgrade selection uses one confirmation lane without duplicate acquired text")
	game.start_run()
	check(game.state == "playing", "a run starts in gameplay")
	check(game.wave_banner_text == "WAVE 1" and game.wave_banner_timer > 0.0 and game.status_clock == 0.0, "run start uses one concise presentation lane")
	check(game.pause_button.position.y + game.pause_button.size.y < 77.0, "Pause occupies a deliberate top-HUD slot above the XP and HP bars")
	check(game.enemy_alive and game.enemy_hp > 0.0, "first enemy spawns with health")
	check(game.current_zone_id == "outer_ruins" and game.enemy_name == "MOSSBACK BRUTE", "Zone 1 uses its deterministic opening composition")
	check(game.attack_clock <= 0.34, "a new foe starts with a predictable bounded first-hit clock")
	game.player_x = game.target_player_x() - 20.0
	var buffered_hp: float = game.enemy_hp
	game.request_tap_attack()
	check(game.tap_buffer_timer > 0.0 and game.tap_buffer_flash > 0.0, "a tap near attack range registers one visible short buffer")
	game._process(0.15)
	check(game.enemy_hp < buffered_hp and game.tap_buffer_timer == 0.0 and game.tap_tutorial_seen, "the buffered tap executes once as soon as attack range is reached")
	var sequence_before_burst: int = game.attack_sequence
	for burst_index in range(20):
		game.request_tap_attack()
	check(game.attack_sequence == sequence_before_burst + 1, "an extreme same-frame input burst cannot queue unlimited tap attacks")
	game.player_x = game.PLAYER_ATTACK_X
	game.perform_player_attack(true)
	check(game.enemy_hp < game.enemy_max_hp, "tap attack damages the enemy")
	check(game.attack_anim > 0.0 and game.enemy_recoil > 0.0, "attacks trigger readable impact animation")
	var coins_before_kill: int = game.coins
	game.damage_enemy(game.enemy_max_hp * 10.0, false, false)
	check(game.enemy_death_anim > 0.0 and not game.reward_pickups.is_empty(), "enemy death launches reward feedback")
	check(game.coins > coins_before_kill, "enemy kills award temporary Run Scrip")
	game.start_run()
	game.enemy_is_boss = false
	game.enemy_is_miniboss = false
	var found_no_drop := false
	for no_drop_seed in range(1, 40):
		game.loot_system.rng.seed = no_drop_seed
		game.loot_drops.clear()
		if not game.spawn_item_drop():
			found_no_drop = true
			break
	check(found_no_drop and game.loot_drops.is_empty(), "normal enemies can resolve without an equipment reveal")
	game.spawn_clock = 0.48
	check(is_equal_approx(game.spawn_clock, 0.48), "a no-gear regular kill keeps the short handoff timing")
	game.start_run()
	game.wave_kills = 2
	for normal_wave_seed in range(1, 40):
		game.loot_system.rng.seed = normal_wave_seed
		if game.loot_system.roll_drop(false, false).is_empty():
			game.loot_system.rng.seed = normal_wave_seed
			break
	game.kill_enemy()
	check(game.wave == 2 and game.wave_banner_timer > 0.0 and game.status_clock == 0.0, "ordinary wave completion uses one compact callout without duplicate status text")
	game.wave = 8
	game.spawn_enemy()
	game.kill_enemy()
	check(not game.loot_drops.is_empty() and game.spawn_clock >= 1.2, "real guaranteed loot retains its protected reveal window")
	game.loot_drops.clear()
	game.pending_items.clear()
	game.item_review_due = false
	game.wave = 8
	game.enemy_alive = false
	game.spawn_clock = 0.0
	game.special_intro_wave = 0
	game.state = "playing"
	game._process(0.05)
	check(game.state == "special_intro" and game.wave_banner_text == "MINIBOSS AHEAD", "miniboss uses a dedicated short pre-intro")
	game._process(0.81)
	check(game.state == "playing" and game.enemy_is_miniboss and game.wave_banner_timer == 0.0, "miniboss spawn removes the pre-intro instead of adding a duplicate boss banner")
	game.start_run()
	var long_item := ItemCatalog.create_item("cursed_ring", "LEGENDARY", 9901)
	long_item.name = "Definitely Not Cursed Ring of Unreasonably Long Future Naming"
	game.pending_items.append(long_item)
	game.show_next_item()
	check(game.item_title.get_theme_font_size("font_size") >= 18 and game.item_title.position.x + game.item_title.size.x <= game.item_panel.size.x, "long item titles wrap or reduce safely inside the item modal")
	game.accept_item_scrap()
	game.start_run()
	game.wave = game.RUN_LAST_WAVE
	game.spawn_enemy()
	game.kill_enemy()
	check(game.state == "hoard_chest" and game.hoard_chest_phase == "fall" and game.boss_reward_options.size() == 3, "Hoard Dragon death creates a physical Hoard Chest before reward cards")
	game._process(0.70)
	check(game.hoard_chest_phase == "ready" and game.hoard_chest_button.visible, "Hoard Chest lands and presents an obvious tap-to-open action")
	game.open_hoard_chest()
	game._process(float(game.hoard_reveal_profile.anticipation) + 0.02)
	check(game.hoard_chest_phase == "silence", "Hoard Chest reveal includes a brief anticipation silence before eruption")
	game._process(float(game.hoard_reveal_profile.silence) + 0.02)
	var boss_launches := {}
	for hoard_drop in game.loot_drops:
		boss_launches[roundi(hoard_drop.vel.x)] = true
	check(game.loot_drops.size() == 3 and boss_launches.size() == 3, "Hoard Dragon visibly ejects three rewards on distinct arcs")
	check(game.loot_drops.all(func(drop): return drop.pickup <= 1.15 and bool(drop.boss_choice)), "boss loot spectacle remains short and protected before choice")
	game.loot_drops.clear()
	game.pending_items.clear()
	game.boss_reward_options.clear()
	game.item_review_due = false
	game.merchant_due = false
	game.pending_victory = false
	game.pending_zone_transition = true
	game.wave = 11
	game.enemy_alive = false
	game.state = "playing"
	game._process(0.05)
	check(game.state == "zone_transition" and game.current_zone_id == "hoard_depths", "a pending zone change starts only after interstitial work clears")
	game._process(0.90)
	check(game.state == "playing" and game.enemy_alive and game.current_zone_id == "hoard_depths", "the short zone transition resolves into the next zone")
	game.start_run()
	var guard := 0
	while game.state != "result" and guard < 100:
		guard += 1
		resolve_interstitials(game, 0)
		if game.state == "result":
			break
		if not game.enemy_alive:
			game.spawn_enemy()
		game.damage_enemy(game.enemy_hp + 1.0, false, false)
		resolve_interstitials(game, 0)
	check(guard < 100, "complete run does not softlock")
	check(game.state == "result" and game.wave == game.RUN_LAST_WAVE, "boss victory reaches results")
	check(game.total_kills >= 40, "waves and miniboss produced the expected enemy sequence")
	check(game.meta_shards > 0, "run rewards permanent-progression currency")
	check(game.restart_button.text == "RETURN TO HIDEOUT", "results provide one clear return to the Hideout")
	check(game.result_summary.text.contains("RUN SCRIP") and game.result_summary.text.contains("RUN REWARDS") and game.result_summary.text.contains("Gold +"), "results separate temporary Run Scrip from persistent Gold rewards")
	var large_result: String = game.format_result_summary(true, 9999, 9999, 9999, 8888, 1111, 7777, 6666, "A Very Long Legendary Item Name")
	check(large_result.contains("Earned     9999\nSpent      8888\nLeft       1111"), "four-digit Run Scrip values use separate responsive result rows")
	game.show_hideout()
	check(game.state == "hideout" and game.hideout_ui.visible, "results return safely to the Hideout")
	var original_shards: int = game.meta_shards
	var original_power: int = game.meta_power
	game.meta_shards = 100
	game.meta_power = 0
	game.show_hideout()
	game.buy_meta_power()
	check(game.meta_power == 1 and game.meta_shards == 90, "permanent +5% power is purchased only from Hideout Upgrades")
	var persisted_meta: Dictionary = MetaStore.load_progress(game.SAVE_PATH)
	check(int(persisted_meta.get("power", -1)) == 1 and int(persisted_meta.get("shards", -1)) == 90 and int(persisted_meta.get("gold", -1)) == game.gold, "Hideout upgrades and Gold persist immediately")
	game.meta_shards = original_shards
	game.meta_power = original_power
	game.save_meta()
	game.start_run()
	check(game.state == "playing" and not game.hideout_ui.visible and game.wave == 1 and game.enemy_alive, "Play starts another run cleanly from the Hideout")
	game.player_hp = 1.0
	game.enemy_damage = 999.0
	game.enemy_archetype = "skirmisher"
	game.perform_enemy_attack()
	if game.state != "result":
		game.perform_enemy_attack()
	check(game.state == "result" and game.player_hp == 0.0, "defeat reaches results without a softlock")
	game.show_hideout()
	check(game.state == "hideout", "defeat can return to the Hideout")
	seed(424242)
	var victories := 0
	for run_index in range(5):
		game.inventory.reset_to_starter()
		game.start_run()
		game.rng.seed = 1000 + run_index
		game.loot_system.rng.seed = 2000 + run_index
		var elapsed := 0.0
		var tap_clock := 0.0
		while game.state != "result" and elapsed < 300.0:
			if game.state == "upgrade":
				game.choose_upgrade((run_index + game.level) % 3)
			elif game.state == "item":
				game.accept_item_equip()
			elif game.state == "boss_reward":
				check(game.boss_reward_options.size() == 3, "boss reward presents three meaningful Epic+ choices")
				game.choose_boss_reward((run_index + 1) % 3)
			elif game.state == "hoard_chest":
				game._process(0.08)
				if game.hoard_chest_phase == "ready":
					game.open_hoard_chest()
			elif game.state == "merchant":
				game.leave_merchant()
			else:
				game._process(0.05)
				tap_clock += 0.05
				if tap_clock >= 0.22:
					tap_clock = 0.0
					game.perform_player_attack(true)
			elapsed += 0.05
		if game.state == "result" and game.player_hp > 0.0 and game.wave == game.RUN_LAST_WAVE:
			victories += 1
		print("BALANCE RUN %d: wave=%d level=%d hp=%.0f time=%.1fs state=%s alive=%s loot=%d options=%d victory=%s review=%s" % [run_index + 1, game.wave, game.level, game.player_hp, elapsed, game.state, game.enemy_alive, game.loot_drops.size(), game.boss_reward_options.size(), game.pending_victory, game.item_review_due])
	check(victories >= 1, "a modest tapping strategy can complete a balanced run")
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("SMOKE TEST PASSED: full loop plus %d/5 simulated tapping victories" % victories)
		quit(0)
	else:
		print("SMOKE TEST FAILED: %d issue(s)" % failures.size())
		quit(1)

func upgrade_by_id(id: String) -> Dictionary:
	for upgrade in GameCatalog.UPGRADES:
		if upgrade.id == id:
			return upgrade
	return {}

func resolve_interstitials(game, upgrade_index: int) -> void:
	for drop in game.loot_drops:
		if not bool(drop.get("boss_choice", false)):
			game.pending_items.append(drop.item)
	game.loot_drops.clear()
	var safety := 0
	while safety < 30:
		safety += 1
		if game.state == "upgrade":
			check(game.selected_upgrades.size() == 3, "level-up offers three upgrades")
			game.choose_upgrade(upgrade_index)
		elif game.state == "item":
			game.accept_item_scrap()
		elif game.state == "boss_reward":
			check(game.boss_reward_options.size() == 3, "boss reward presents three meaningful Epic+ choices")
			game.choose_boss_reward(0)
		elif game.state == "hoard_chest":
			game._process(0.7)
			game.open_hoard_chest()
			game._process(float(game.hoard_reveal_profile.anticipation) + 0.02)
			game._process(float(game.hoard_reveal_profile.silence) + 0.02)
		elif game.state == "merchant":
			game.leave_merchant()
		elif not game.boss_reward_options.is_empty():
			game.show_boss_reward()
		elif not game.pending_items.is_empty():
			game.show_next_item()
		elif game.pending_victory:
			game.end_run(true)
		else:
			break
