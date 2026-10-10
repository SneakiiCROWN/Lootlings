extends "res://tests/phase4_native_qa.gd"
const Collection=preload("res://mythical_collection.gd")
func wait_real(ms: int) -> void:
 var until:=Time.get_ticks_msec()+ms
 while Time.get_ticks_msec()<until:await process_frame
func review() -> void:
 var d:=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x");root.size=Vector2i(int(d[0]),int(d[1]))
 game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false)
 game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
 folder="res://.godot_test_data/mythical-050/%sx%s/" % [d[0],d[1]];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 game.inventory.stash.clear()
 for id in Collection.IDS:assert(game.inventory.keep(game.ItemCatalog.create_item(id,"MYTHICAL SHINY",50)))
 assert(game.save_hideout_economy());game.show_hideout();game.hideout_ui.show_stash();await capture("collection_inventory")
 game.profile.current_lootling_id="gloomlet"
 for i in range(4):
  var item:Dictionary=game.ItemCatalog.create_item(Collection.IDS[i],"MYTHICAL SHINY",50)
  game.profile.avatar_mode="lootling" if i==2 else "wanderer"
  game.profile.wanderer.preset_id="vault_runner"
  game.inventory.equipped.Weapon=item;game.inventory.equipped.Relic=game.ItemCatalog.create_item(Collection.IDS[i+4],"MYTHICAL SHINY",50)
  game.start_run();game.set_process(false);game.special_intro_timer=0;game.enemy_entry_anim=0;game.wave_banner_timer=0;game.wave=2;game.spawn_enemy();game.enemy_alive=true
  for facing in [1,-1]:
   game.player_facing=facing;game.forced_facing_test=facing;game.attack_anim=.12;game.player_x=game.PLAYER_HOME_X;game.run_time=1.5
   await capture(item.id+"_strike_"+str(facing))
 game.end_run(false);game.retention.show_spinner();game.retention.spin_reward={"kind":"item","rarity":"MYTHICAL SHINY","item":game.ItemCatalog.create_item("dawnweave","MYTHICAL SHINY",50)};game.retention.spin_message="Saved to Gear. A prismatic keepsake!";game.retention.start_reveal(false)
 await wait_real(230);await tap(game.retention.buttons[2]);assert(not game.retention.spin_busy and game.retention.detail.text.contains("Dawnweave"));await capture("mythical_jackpot")
 var audio=game.audio_manager;var opts:Dictionary=preload("res://settings_store.gd").defaults();opts.reward_announcements=false;audio.apply_settings(opts);assert(not audio.reward_announcements_enabled)
 var played_before: int=int(audio.last_event_msec.get("spinner_announcement",-1));audio.play_event("spinner_announcement");assert(int(audio.last_event_msec.get("spinner_announcement",-1))==played_before)
 opts.reward_announcements=true;audio.apply_settings(opts);audio.play_event("spinner_announcement");assert(int(audio.last_event_msec.get("spinner_announcement",-1))>=0)
 print("MYTHICAL NATIVE PASS: actual eight-item inventory, four weapons/four floating shields, both facings, controlled strikes, truthful skippable jackpot and saved announcement toggle. Artistic/contact and listening acceptance remain separate.")
 game.free();quit()
