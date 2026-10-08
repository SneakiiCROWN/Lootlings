extends SceneTree
const Motion=preload("res://enemy_motion.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("review")
func review() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g);await process_frame
	g.app_lifecycle.platform_notifications_enabled=false;g.audio_settings.cinematic_first_time=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=g
	for weapon in preload("res://weapon_catalog.gd").live_ids():
		helper.prepare("relic_beast",weapon);g.enemy_entry_anim=0;g.enemy_hp=10000;g.enemy_max_hp=10000
		var before: Array=[g.player_hp,g.enemy_hp,g.attack_clock,g.enemy_attack_clock,g.rng.state,g.loot_system.rng.state]
		g.combat_presentation.record_contact(g,true,true)
		var event: Dictionary=g.combat_presentation.contacts.back().duplicate(true)
		assert(before==[g.player_hp,g.enemy_hp,g.attack_clock,g.enemy_attack_clock,g.rng.state,g.loot_system.rng.state],"Recording contact is visual only")
		assert(event.origin.distance_to(preload("res://weapon_fit_catalog.gd").projectile_origin(g))<.01)
		g.enemy_encounter.begin(g,3);g.enemy_encounter.select(g,1)
		assert(event.pos==g.combat_presentation.contacts.back().pos and event.serial==g.combat_presentation.contacts.back().serial,"Target changes cannot move a prior contact")
		for n in range(30):g.combat_presentation.record_contact(g,false,false)
		assert(g.combat_presentation.contacts.size()==12)
		g.combat_presentation.step(g,.25);assert(g.combat_presentation.contacts.is_empty())
	g.enemy_encounter.clear();g.enemy_is_boss=false;g.enemy_is_miniboss=false;g.enemy_archetype="skirmisher";g.enemy_alive=true;g.enemy_damage=8;g.enemy_attack_count=0
	g.player_hp=100;g.player_max_hp=100;g.player_ward=100;g.floating_texts.clear();g.perform_enemy_attack()
	assert(g.player_hp==100 and g.player_ward<100)
	assert(not g.floating_texts.any(func(row):return row.text=="-0"))
	assert(g.floating_texts.any(func(row):return row.text.begins_with("WARD") and row.lane=="player"))
	var texture=load("res://art/sprites/enemies/hoard_dragon.png")
	for scale in [Vector2.ONE,Vector2(-1,.98),Vector2(.82,.82),Vector2(.64,.64)]:
		for tilt in [-.15,0,.15]:
			var feet:=Motion.feet_anchor(texture,Rect2(),Rect2(-113,-148,226,214))
			var pos:=Vector2(300,482)
			var transform:=Motion.grounded_transform(pos,tilt,scale,feet,66)
			assert(absf((transform*feet).y-548)<.01,"Opaque feet stay planted during rotation/scale")
	g.enemy_name="FEN SNEAK";g.player_x=420;g.enemy_stage_x=108;g.forced_facing_test=0
	for phase in ["idle","attack","hurt","defeat"]:
		g.enemy_alive=phase!="defeat";g.enemy_flash=.1 if phase=="hurt" else 0;g.enemy_attack_anim=.18 if phase=="attack" else 0
		assert(not preload("res://approved_missing_runtime_art.gd").enemy_neutral(g,108).is_empty(),"Approved identity must survive missing action art")
	helper.free();g.free();print("COMBAT FAMILY PASS: 12 weapon sockets; pinned target contacts; bounded lifetime/pool; Ward absorption; feet pivots; approved identity continuity");quit()
