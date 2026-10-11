extends SceneTree
const Catalog = preload("res://vignette_catalog.gd")
const Profiles = preload("res://profile_store.gd")
const Settings = preload("res://settings_store.gd")
var game
var player
var native := false
var handoffs := 0

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func snapshot() -> Dictionary:
	return {"profile":game.profile.duplicate(true), "inventory":game.inventory.equipped.duplicate(true), "stash":game.inventory.stash.duplicate(true), "scrap":game.inventory.scrap, "gold":game.gold, "shards":game.meta_shards, "campaign":game.campaign.completed.duplicate(), "contracts":game.contracts.counts.duplicate(true), "jobs":game.contracts.active.duplicate(true), "achievements":game.achievements.progress.duplicate(true), "rng":game.rng.state, "loot_rng":game.loot_system.rng.state}

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	player = game.presentation_director.vignette
	game.profile = Profiles.create_default()
	game.profile.display_name = "Memory QA"
	game.audio_settings = Settings.defaults()
	game.show_hideout()
	var ids:Array=Catalog.ids()
	var unique:Dictionary={}
	for id in ids:unique[id]=true
	assert(ids.size()>=33 and ids.size()==unique.size())
	for required in ["boss/hoard_dragon","character/gloomlet","resident/patch"]:assert(required in ids)
	for id in Catalog.ids():
		var entry := Catalog.entry(id,game.profile)
		assert(not entry.is_empty() and entry.lines.size() >= 2)
		assert(ResourceLoader.exists(str(entry.background)))
		if not str(entry.actor).is_empty(): assert(ResourceLoader.exists(str(entry.actor)))
		player.caption.text = ""
		for line in entry.lines:
			player.caption.text = str(line)
			await process_frame
			assert(player.caption.get_line_count()*player.caption.get_theme_font("font").get_height(player.caption.get_theme_font_size("font_size")) <= player.caption.size.y,"Story caption clipped: "+id)
	assert(Catalog.entry("fake/unknown").is_empty())
	assert(not Catalog.available("resident/patch",game.profile))
	assert(Catalog.available("character/gloomlet",game.profile))
	assert(not Catalog.entry("character/gloomlet").status.contains("TEMP ART"))
	# Preview must not select a different Lootling or unlock its memory.
	var before := snapshot()
	game.play_story_preview("character/emberhorn",game.profile)
	assert(player.active and not game.hideout_ui.is_processing())
	assert(not player.play(Catalog.entry("character/mosskin"),game.audio_settings,"preview"))
	if native: await capture("vignette_emberhorn")
	player.finish()
	player.finish()
	assert(snapshot() == before and game.hideout_ui.is_processing())
	player.play(Catalog.entry("character/relic_beast"),game.audio_settings,"replay",func(): handoffs += 99)
	player.finish()
	assert(handoffs == 0, "Replay cannot carry a gameplay handoff")
	assert(not game.hideout_ui.speech_panel.visible)
	# Discovery unlocks once, skip hands back exactly once; repeats auto-skip.
	var stale_form: Dictionary = game.profile.duplicate(true)
	game.discover_story("resident/patch",func(): handoffs += 1)
	assert(player.active and "resident/patch" in game.profile.memories)
	if native: await capture("vignette_patch")
	player.finish()
	player.finish()
	assert(handoffs == 1)
	game.save_profile_data(stale_form)
	assert("resident/patch" in game.profile.memories, "Stale profile form must retain new discoveries")
	game.discover_story("resident/patch",func(): handoffs += 1)
	assert(not player.active and handoffs == 2)
	assert(Profiles.save_profile("user://memories.cfg",game.profile) == OK)
	assert(Profiles.load_profile("user://memories.cfg").memories == game.profile.memories)
	# Archive replay must not mutate *any* reward/progression/RNG snapshot.
	before = snapshot()
	game.replay_memory("resident/patch")
	assert(player.active and player.mode == "replay")
	player._process(1)
	game._process(1)
	player.finish()
	assert(snapshot() == before)
	game.replay_memory("boss/hoard_dragon")
	assert(not player.active, "Undiscovered boss replay is locked")
	# Changing location cancels without firing stale handoffs.
	game.discover_story("resident/sera",func(): handoffs += 1)
	assert(player.active)
	game.show_hideout()
	assert(not player.active and handoffs == 2 and game.hideout_ui.is_processing())
	player.finish()
	assert(handoffs == 2)
	# Settings migrate additively; all audio volume/mute values survive.
	var audio := Settings.defaults()
	audio.master = 0.37
	audio.music_muted = true
	audio.cinematic_reduced_motion = true
	audio.cinematic_subtitles = false
	assert(Settings.save_settings("user://story_settings.cfg",audio) == OK)
	assert(Settings.load_settings("user://story_settings.cfg") == audio)
	player.play(Catalog.entry("character/relic_beast"),audio,"preview")
	assert(player.reduced_motion and not player.caption.visible)
	player.finish()
	game.audio_settings.cinematic_first_time = false
	game.discover_story("resident/ilex",func(): handoffs += 1)
	assert(not player.active and handoffs == 3 and "resident/ilex" in game.profile.memories)
	game.audio_settings = Settings.defaults()
	# Region arrival handoff follows the existing departure into actual combat.
	game.start_campaign("act_i")
	assert(player.active and game.state == "hideout")
	if native: await capture("vignette_region")
	player.finish()
	await create_timer(0.8).timeout
	assert(game.state == "playing" and game.story_run_presentations)
	game.set_process(false)
	game.wave = 8
	game.wave_kills = 0
	var serial: int = game.enemy_serial
	game.begin_special_intro()
	assert(player.active and game.state == "special_intro")
	if native: await capture("vignette_grump")
	player.finish()
	assert(game.state == "playing" and game.enemy_serial == serial + 1 and game.enemy_is_miniboss)
	# Repeat sting is abbreviated, and does not discover twice.
	game.begin_special_intro()
	assert(player.active and player.duration == 1.4)
	player.finish()
	game.wave = 15
	game.begin_special_intro()
	assert(player.active)
	if native: await capture("vignette_hoard_dragon")
	player.finish()
	assert(game.enemy_is_boss and game.enemy_alive)
	for auto_skip in [false,true]:
		for repeat_boss in [false,true]:
			game.audio_settings.cinematic_auto_skip = auto_skip
			game.audio_settings.cinematic_repeat_boss = repeat_boss
			game.begin_special_intro()
			assert(player.active == repeat_boss)
			if repeat_boss: player.finish()
			assert(game.state == "playing" and game.enemy_alive)
	game.audio_settings = Settings.defaults()
	game.show_hideout()
	game.profile.avatar_mode = "wanderer"
	game.profile.wanderer.preset_id = "ruin_warden"
	game.profile.wanderer.origin = "starfall_witch"
	game.hideout_ui.profile = game.profile.duplicate(true)
	before = snapshot()
	game.play_story_preview("origin/starfall_witch",game.profile)
	assert(player.data.actor.ends_with("ruin_warden_idle.png"))
	if native: await capture("vignette_wanderer")
	player.finish()
	assert(snapshot() == before)
	game.hideout_ui.show_memories()
	assert(not game.hideout_ui.speech_panel.visible)
	if native: await capture("memory_archive")
	game.hideout_ui.show_lore()
	assert(not game.hideout_ui.memory_content.visible)
	game.show_startup()
	game.startup_ui.show_settings()
	game.startup_ui.cinematic_preferences.visible = true
	if native: await capture("story_settings")
	print("VIGNETTE QA PASSED: 33 existing-content memories; preview/replay reward/progression/RNG isolation, locked replay, persistence, skip/repeat/cancel, audio-settings preservation, real region and single boss-spawn handoffs, no speech leaks")
	game.queue_free()
	await process_frame
	quit(0)

func capture(label: String) -> void:
	await create_timer(0.45).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	assert(image.get_size() == Vector2i(480,854))
	assert(image.save_png("res://.godot_test_data/"+label+"_qa.png") == OK)
