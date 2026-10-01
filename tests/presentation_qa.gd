extends SceneTree

const Roster = preload("res://lootling_catalog.gd")
const Story = preload("res://world_story.gd")
var native := false

func _initialize() -> void:
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func run_qa() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.show_hideout()
	# These are selected-character reactions, not progression-specific trail hints.
	game.campaign.completed.clear()
	for speaker in ["Salvager", "Relic Keeper", "Archivist"]:
		for id in Roster.selectable_ids():
			game.profile.current_lootling_id = id
			game.hideout_ui.profile = game.profile
			game.hideout_ui.dismiss_dialogue()
			game.hideout_ui.dialogue.speaker_ready.clear()
			game.hideout_ui.request_dialogue("tapped", speaker)
			assert(game.hideout_ui.speech_label.text.contains(Story.RESIDENT_REACTIONS[speaker][id]))
			assert(game.hideout_ui.RESIDENT_PORTRAITS[speaker].resource_path.contains("/npcs/beta/"))
			if native and id == "gloomlet": await capture("resident_" + speaker.to_lower().replace(" ", "_"))
	game.hideout_ui.show_achievements()
	for screen in ["shop", "upgrades", "stash"]:
		game.hideout_ui.current_screen = screen
		for speaker in ["Salvager", "Relic Keeper", "Archivist"]:
			assert(game.hideout_ui.dialogue_anchor(speaker).x + game.hideout_ui.speech_panel.size.x <= 480)
	assert(not game.hideout_ui.speech_panel.visible)
	game.hideout_ui.show_lore()
	assert(not game.hideout_ui.speech_panel.visible)
	game.hideout_ui.show_campaign()
	assert(not game.hideout_ui.speech_panel.visible)
	game.hideout_ui.queue_dialogue_context("signature_find")
	game.hideout_ui.queue_dialogue_context("returning")
	assert(game.hideout_ui.queued_dialogue_context == "signature_find")
	game.hideout_ui.dialogue.speaker_ready.clear()
	game.hideout_ui.show_home()
	assert(game.hideout_ui.speech_panel.visible)
	if native: await capture("resident_signature_return")
	game.queue_free()
	await process_frame
	print("PRESENTATION QA PASSED: 21 Lootling/resident reactions, painted portraits, no menu speech leaks, important context priority")
	quit(0)

func capture(label: String) -> void:
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	assert(shot.get_size() == Vector2i(480, 854))
	assert(shot.save_png("res://.godot_test_data/%s_qa.png" % label) == OK)
