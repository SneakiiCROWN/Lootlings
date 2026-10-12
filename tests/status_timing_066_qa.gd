extends SceneTree
var game
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(25).timeout.connect(func():push_error("Status timing timeout");quit(1))
 call_deferred("review")
func sample(step:float) -> Dictionary:
 game.state="playing";game.enemy_alive=true;game.enemy_hp=100000;game.enemy_max_hp=100000
 game.base_damage=100;game.enemy_hit_multiplier=1;game.build.tags={"Poison":3}
 game.enemy_burn_dps=30;game.enemy_burn_time=1.2;game.enemy_poison_stacks=5;game.enemy_poison_time=1.2
 game.dot_tick_clock=.35;game.plague_power=1;game.player_hp=20;game.player_max_hp=100
 game.floating_texts.clear()
 var elapsed:=0.0
 while elapsed<3.0-.000001:
  var delta:=minf(step,3.0-elapsed);game.update_elemental_damage(delta);elapsed+=delta
 return {"frame_seconds":step,"damage":100000-game.enemy_hp,"healing":game.player_hp-20,"burn_remaining":game.enemy_burn_dps,"poison_stacks":game.enemy_poison_stacks,"tick_clock":game.dot_tick_clock}
func review() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.start_run();game.set_process(false);game.enemy_encounter.clear()
 var rows:Array=[]
 for step in [1.0/120,1.0/60,1.0/30,.05,.4,1.1,3.0]:rows.append(sample(step))
 var f=FileAccess.open("res://.godot_test_data/status-timing-066.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 for row in rows:
  assert(absf(row.damage-rows[0].damage)<.0001,"DoT frame dependence: "+JSON.stringify(rows))
  assert(absf(row.healing-rows[0].healing)<.0001)
 # Burn resolves before poison; siphon only removes actual surviving HP.
 game.state="playing";game.enemy_alive=true;game.enemy_hp=10;game.enemy_max_hp=10;game.enemy_burn_dps=30;game.enemy_burn_time=1;game.enemy_poison_time=1;game.enemy_poison_stacks=5;game.dot_tick_clock=.35;game.player_hp=20
 var kills:int=game.total_kills;game.update_elemental_damage(3.0)
 assert(game.total_kills==kills+1 and game.player_hp==20 and not game.enemy_alive)
 game.update_elemental_damage(3.0);assert(game.total_kills==kills+1)
 # Group death loads another living actor. Remaining time belongs to the old
 # target; the pack adapter will advance each actor exactly once itself.
 game.state="playing";game.enemy_encounter.begin(game,2)
 for actor in game.enemy_encounter.actors:
  actor.enemy_hp=1000;actor.enemy_max_hp=1000;actor.enemy_burn_dps=30;actor.enemy_burn_time=1;actor.enemy_poison_stacks=0;actor.enemy_poison_time=0;actor.dot_tick_clock=.35
 game.enemy_encounter.actors[0].enemy_hp=1;game.enemy_encounter.load_actor(game,0)
 var first_serial:int=game.enemy_serial;game.update_elemental_damage(1.0)
 assert(game.enemy_serial!=first_serial and game.enemy_hp==1000 and is_equal_approx(game.dot_tick_clock,.35))
 game.free();print("STATUS TIMING 066 PASS: actual burn/poison expiry, fade, stacked ticks and siphon agree at 120/60/30 FPS and 0.4/1.1/3 second stalls; fatal burn cannot leech, award twice or advance a newly loaded pack target.");quit()
