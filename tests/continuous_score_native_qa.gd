# extends SceneTree through guarded native harness.
extends "res://tests/phase4e_audio_native_qa.gd"
func review() -> void:
	assert(DisplayServer.get_name()!="headless")
	folder="res://.godot_test_data/continuous-score-native/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_manager.apply_settings(preload("res://settings_store.gd").defaults())
	for cue in ["TITLE","HIDEOUT","HOME","OUTER_RUINS","SALVAGE_WARRENS","HOARD_DEPTHS","BOSS"]:
		game.audio_manager.set_music(cue);await create_timer(1.5).timeout
		assert(game.audio_manager.music_player.stream is AudioStreamOggVorbis)
		assert(game.audio_manager.music_player.stream.loop and game.audio_manager.current_music==cue)
		await record(cue.to_lower(),4.0,func():game.audio_manager.play_event("menu_open") if cue in ["HOME","HIDEOUT"] else game.audio_manager.play_contact("greatsword","armour",true,true))
	game.show_hideout();assert(game.audio_manager.current_music=="HIDEOUT")
	game.show_personal_home();assert(game.audio_manager.current_music=="HOME")
	game.navigate_back();assert(game.audio_manager.current_music=="HIDEOUT")
	game.audio_manager.set_music("HOME");game.audio_manager.set_music("BOSS");game.audio_manager.set_music("HIDEOUT")
	await create_timer(1.5).timeout;assert(not game.audio_manager.transition_player.playing)
	game.audio_manager.apply_settings({"music_muted":true});assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")))
	game.free();print("CONTINUOUS SCORE NATIVE PASS: seven licensed stereo streaming scores, audible non-clipped Master captures, rapid travel cleanup, Home/Hub return cues, saved music mute; subjective listening remains unqualified")
	quit()
