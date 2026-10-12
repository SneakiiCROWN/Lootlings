extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/companions072/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false
  var catalog=preload("res://companion_catalog.gd");game.profile.companion.owned_ids=catalog.known_ids();var h=game.personal_home
  for id in catalog.known_ids():
   game.profile.companion.equipped_id=id;game.profile.homestead.home_layout.companion_mode="follow";game.show_personal_home();h.follower.initialized=false
   for i in range(40):h._process(.05)
   var wallet:int=game.gold;var hp:float=game.player_hp;await tap(h.buttons.nook)
   assert(h.view=="room" and h.follower.reaction_timer>0 and h.home_reaction.text.contains(catalog.ENTRIES[id].name))
   await capture(id+"_greeting");assert(h.follower.last_drawn_asset.contains(id) and game.gold==wallet and game.player_hp==hp)
   await tap(h.buttons.companions);assert(h.view=="companions");h.go_back();assert(h.view=="room")
  game.show_hideout();var hub=game.hideout_ui;hub.last_home_facts.region="act_i";hub.queue_dialogue_context("boss_defeated")
  for speaker in ["Salvager","Relic Keeper","Archivist"]:
   hub.request_dialogue("tapped",speaker)
   if hub.home_dialogue.last_selection.get("event","")=="boss_defeated":assert(hub.resident_context_heard[speaker]=="boss_defeated")
   if speaker=="Archivist":assert(hub.home_dialogue.last_selection.get("event","")=="boss_defeated")
   await capture(speaker.replace(" ","_")+"_return_dialogue");hub.dismiss_dialogue()
  game.hideout_ui.show_phase4("archive");game.hideout_ui.show_home();assert(game.hideout_ui.resident_activity("Archivist")=="inspect");await capture("ilex_return")
  game.free();await process_frame
 print("COMPANION072 NATIVE PASS six exact canonical followers react to actual Home taps; collection still directly accessible; wallets/HP unchanged; Ilex return notice;3 layouts. Sparse keyframes, not fluid animation.");quit()
