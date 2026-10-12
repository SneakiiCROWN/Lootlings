extends SceneTree
func _initialize() -> void:
 if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-076fresh/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 preload("res://save_scope.gd").active=OS.get_environment("LOOTLINGS_CONVERSATION_OWNER")=="1"
 var g=load("res://main.tscn").instantiate();root.add_child(g);await process_frame;g.set_process(false);g.app_lifecycle.platform_notifications_enabled=false
 var h=g.hideout_ui;var phase:String=OS.get_environment("LOOTLINGS_CONVERSATION_PHASE")
 if phase=="earn":
  g.profile=preload("res://profile_store.gd").create_default();h.last_home_facts={"region":"act_i","outcome":"victory"};h.queue_dialogue_context("boss_defeated")
 elif phase=="hear":
  assert(g.profile.home_conversation.event=="boss_defeated");h.request_dialogue("tapped","Salvager");assert(h.queued_dialogue_context=="boss_defeated");h.dismiss_dialogue();h.request_dialogue("tapped","Archivist");assert(h.home_dialogue.last_selection.event=="boss_defeated")
 else:
  assert(g.profile.home_conversation.heard.Archivist=="boss_defeated");h.request_dialogue("tapped","Archivist");assert(h.home_dialogue.last_selection.get("event","")!="boss_defeated")
 print("HOME CONVERSATION076 "+phase+" PASS: actual fresh process, existing authored dialogue, isolated profile");g.free();quit()
