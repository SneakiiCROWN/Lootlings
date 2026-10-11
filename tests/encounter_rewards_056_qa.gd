extends SceneTree
const Cues=preload("res://combat_presentation.gd")
const Pickups=preload("res://pickup_presentation.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(35).timeout.connect(func():push_error("Encounter rewards timeout");quit(1))
 call_deferred("review")
func review() -> void:
 var g=load("res://main.tscn").instantiate();root.add_child(g);await process_frame
 g.start_run();g.set_process(false);g.enemy_encounter.clear();g.enemy_alive=true;g.enemy_entry_anim=0;g.enemy_is_boss=false;g.enemy_is_miniboss=false;g.enemy_archetype="hexer";g.enemy_attack_count=2;g.enemy_attack_clock=.1;g.enemy_max_hp=100;g.enemy_hp=98;g.player_hp=100;g.player_max_hp=100;g.enemy_variant_id="";g.floating_texts.clear()
 var rng_state:int=g.rng.state
 assert(Cues.attack_cue(g).label=="MEND" and Cues.attack_cue(g).intent=="heal")
 g.perform_enemy_attack();assert(g.enemy_hp==100 and g.player_hp==100)
 var mend:Array=g.floating_texts.filter(func(x):return x.get("number_kind","")=="enemy_heal")
 assert(mend.size()==1 and mend[0].amount==2 and g.rng.state==rng_state)
 g.floating_texts.clear();g.restore_enemy_health(10);assert(g.floating_texts.is_empty())
 g.enemy_archetype="skirmisher";g.enemy_attack_count=2
 for variant in ["overcharged","frostbitten","enraged","leeching"]:
  g.enemy_variant_id=variant;g.enemy_hp=30
  assert(Cues.attack_cue(g).label=={"overcharged":"SPARK SURGE","frostbitten":"FROST STRIKE","enraged":"RAGE STRIKE","leeching":"DRAIN STRIKE"}[variant])
 g.enemy_variant_id="";g.enemy_is_boss=true
 var actions:=0
 for campaign in preload("res://campaign_system.gd").ORDER:
  g.campaign_id=campaign
  for phase in [1,2]:
   g.boss_phase=phase
   for index in range(6):
    g.enemy_attack_count=index;g.boss_recovery=0
    var action:Dictionary=g.BossPatterns.next(g);var cue:Dictionary=Cues.attack_cue(g)
    assert(cue.label==action.text and cue.intent==("recovery" if action.recovery else "attack"));actions+=1
 g.boss_recovery=.4;g.enemy_attack_clock=5
 assert(Cues.attack_cue(g).visible and Cues.attack_cue(g).label=="TAP OPENING")
 g.enemy_alive=false;assert(not Cues.attack_cue(g).visible)
 for slot in range(3):
  var rect:Rect2=Pickups.caption_rect({"boss_choice":true,"visual_slot":slot})
  assert(rect.position.x>=0 and rect.end.x<=480 and rect.end.y<724)
  for other in range(slot):assert(not rect.intersects(Pickups.caption_rect({"boss_choice":true,"visual_slot":other})))
 print("ENCOUNTER REWARDS 056 PASS: %d canonical boss/phase tells, elite cues, non-damaging mend, capped health receipts, no RNG mutation and separated hoard labels." % actions);g.free();quit()
