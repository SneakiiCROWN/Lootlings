extends SceneTree
const Numbers=preload("res://combat_numbers.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(25).timeout.connect(func():push_error("Readability timeout");quit(1))
 call_deferred("review")
func review() -> void:
 var g=load("res://main.tscn").instantiate();root.add_child(g);await process_frame
 g.start_run();g.set_process(false);g.enemy_encounter.clear();g.enemy_alive=true;g.enemy_hp=1000;g.enemy_max_hp=1000;g.enemy_hit_multiplier=1;g.player_hp=50;g.player_max_hp=100;g.life_steal=.2;g.floating_texts.clear()
 var rng:int=g.rng.state
 g.damage_enemy(10,false,true);g.damage_enemy(10,false,true)
 var hits:Array=g.floating_texts.filter(func(x):return x.get("number_kind","")=="Physical")
 assert(hits.size()==1 and hits[0].amount==20 and hits[0].hits==2 and hits[0].text.contains("×2"))
 assert(g.enemy_hp==980 and g.player_hp==54 and g.rng.state==rng)
 g.deal_elemental_hit(5,"Fire");assert(g.enemy_hp==975)
 assert(g.floating_texts.any(func(x):return x.text=="FIRE 5.0"))
 g.player_hp=99;g.damage_enemy(10,true,true)
 var healed:Array=g.floating_texts.filter(func(x):return x.get("number_kind","")=="heal")
 assert(g.player_hp==100 and healed[0].amount==5)
 g.floating_texts.clear();g.enemy_damage=20;g.armor=.25;g.player_ward=5;g.enemy_is_boss=false;g.enemy_is_miniboss=false;g.enemy_archetype="skirmisher";g.enemy_variant_id="";g.player_hp=100
 g.perform_enemy_attack()
 var ward:Array=g.floating_texts.filter(func(x):return x.get("number_kind","")=="ward")
 var armour:Array=g.floating_texts.filter(func(x):return x.get("number_kind","")=="armour")
 var incoming:Array=g.floating_texts.filter(func(x):return x.get("number_kind","")=="incoming")
 assert(ward.size()==1 and ward[0].amount==5)
 assert(armour.size()==1 and is_equal_approx(armour[0].amount+incoming[0].amount+ward[0].amount,20))
 assert(Numbers.text("heal",.02).contains("0.02") and Numbers.text("heal",.002).contains("<0.01"))
 for i in range(100):Numbers.add(g,1,"Ice")
 assert(g.floating_texts.size()<=6)
 assert(g.build_item_comparison({"name":"A","effects":{"max_hp":.4}},{"name":"B","effects":{}}).contains("0.4"))
 assert(preload("res://item_catalog.gd").describe_effects({"effects":{"max_hp":.4,"crit":.003,"armor":0}}).contains("0.4 max HP"))
 assert(not preload("res://item_catalog.gd").describe_effects({"effects":{"armor":0}}).contains("armour"))
 assert(g.build_item_comparison({"name":"A","effects":{"attack_slow":.1}},{"name":"B","effects":{}}).contains("more attack delay"))
 g.floating_texts.clear();Numbers.add(g,4,"Fire");g.add_float("ROOT GUARD BROKEN",Vector2(300,400),Color.WHITE,17)
 assert(g.floating_texts.any(func(x):return x.text=="ROOT GUARD BROKEN"))
 g.free();print("COMBAT READABILITY 055 PASS: resolved damage, aggregate receipts, capped healing, armour/ward/HP accounting, bounded rendering, no RNG mutation and fractional comparison.");quit()
