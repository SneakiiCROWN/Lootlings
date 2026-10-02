extends Node
# Small lifecycle adapter; no changes to combat, rewards, or run-save semantics.
var game
var suspended := false
var platform_notifications_enabled := true
var previous_pause := false
var presentation_mode := Node.PROCESS_MODE_ALWAYS

func configure(target) -> void:
	game = target
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	get_tree().quit_on_go_back = false

func _notification(what: int) -> void:
	if game == null or not platform_notifications_enabled: return
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			suspend()
		NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED:
			restore_focus()
		NOTIFICATION_WM_CLOSE_REQUEST:
			persist()
			get_tree().quit()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			game.navigate_back()

func suspend() -> void:
	if suspended: return
	previous_pause = get_tree().paused
	if game.state == "playing": game.pause_run()
	persist()
	presentation_mode = game.presentation_director.process_mode
	game.presentation_director.process_mode = Node.PROCESS_MODE_DISABLED
	suspended = true
	get_tree().paused = true

func restore_focus() -> void:
	if not suspended: return
	game.presentation_director.process_mode = presentation_mode
	get_tree().paused = previous_pause
	suspended = false
	# Combat stays on the existing Pause screen until the player resumes.

func persist() -> void:
	game.save_meta()
	game.inventory.save(game.INVENTORY_SAVE_PATH)
	game.hideout_shop.save(game.HIDEOUT_SHOP_SAVE_PATH)
	preload("res://profile_store.gd").save_profile(game.PROFILE_SAVE_PATH, game.profile)
	preload("res://settings_store.gd").save_settings(game.SETTINGS_SAVE_PATH, game.audio_settings)
	game.achievements.save_state()
	game.campaign.save("user://campaign.cfg")
	game.contracts.save("user://contracts.cfg")
