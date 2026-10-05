extends SceneTree
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	create_timer(30).timeout.connect(func(): push_error("Feedback QA timeout"); quit(1))
	call_deferred("review")
func review() -> void:
	var game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.start_run(); game.set_process(false)
	var rng: int=game.rng.state; var loot_rng: int=game.loot_system.rng.state
	game.enemy_encounter.active=true; game.enemy_encounter.selected=0
	game.enemy_encounter.actors.clear()
	game.enemy_encounter.add_actor(game)
	game.enemy_encounter.add_actor(game)
	game.enemy_encounter.actors[1].merge({"enemy_serial":99999,"enemy_name":"MIRROR KNIGHT","enemy_archetype":"tank","enemy_is_boss":false,"enemy_is_miniboss":false},true)
	var original: Array=game.enemy_encounter.actors.duplicate(true)
	var hp: float=game.enemy_hp
	var projectile:={"start":Vector2(350,440),"target":Vector2(140,450),"enemy_serial":99999,"element":"Physical","weapon_type":"crossbow"}
	game.record_projectile_impact(projectile)
	assert(game.projectile_impacts.size()==1)
	assert(game.projectile_impacts[0].material=="glass" and game.projectile_impacts[0].direction.x<0)
	assert(game.projectile_impacts[0].weapon_type=="crossbow")
	assert(game.enemy_encounter.actors==original and game.enemy_encounter.selected==0 and game.enemy_hp==hp)
	game.enemy_encounter.actors[1].enemy_alive=false
	game.record_projectile_impact(projectile); assert(game.projectile_impacts.size()==1)
	game.enemy_alive=false; projectile.enemy_serial=game.enemy_serial
	game.record_projectile_impact(projectile); assert(game.projectile_impacts.size()==1)
	game.enemy_encounter.active=false; game.enemy_alive=true
	for i in range(30): game.record_projectile_impact(projectile)
	assert(game.projectile_impacts.size()==16)
	assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng)
	var machine=game.retention.machine
	assert(machine.plinth_style is StyleBoxFlat)
	assert(ThemeDB.fallback_font.get_string_size("CROWNROOT AWAKENS",HORIZONTAL_ALIGNMENT_LEFT,-1,11).x<168)
	var locks: Array=[0]; var completions: Array=[0]
	machine.locked.connect(func(): locks[0]+=1)
	machine.completed.connect(func(): completions[0]+=1)
	for rarity in preload("res://relic_spin_catalog.gd").TIERS:
		machine.wind_up("item",rarity,false); machine.set_process(false)
		machine._process(9); assert(machine.stage=="anticipation")
		machine._process(.001); assert(machine.stage=="reveal" and machine.burst==1)
		machine._process(.016); assert(machine.burst>.9,"Delayed lock must retain the rarity reveal")
		machine.lock_result()
		machine._process(3); assert(machine.stage=="settled")
	assert(locks[0]==6 and completions[0]==6)
	var manifest=preload("res://authored_pose_manifest.gd")
	var original_rows: Array=manifest.rows().duplicate(true)
	var ready: Dictionary=original_rows.filter(func(row): return row.actor=="vault_runner" and row.stance=="heavy_two_hand" and row.phase=="READY" and row.facing=="right_only")[0]
	for phase in ["WINDUP","HURT","RECOVER","IMPACT"]:
		var row: Dictionary=ready.duplicate(true); row.phase=phase
		manifest.entries.append(row)
	var pack: Dictionary=manifest.facing_pack("vault_runner","heavy_two_hand","right_only")
	for phase in ["ANTICIPATE","HURT","RECOVER","IMPACT"]:
		assert(pack.phase_variants.has(phase) and pack.phase_variants[phase].texture.resource_path==ready.asset_path)
	# These test rows reuse an existing approved export only to prove routing;
	# they never enter the source manifest or close canonical art debt.
	manifest.entries=original_rows
	game.enemy_encounter.clear(); game.free()
	print("FEEDBACK QA: pack selection/dead target isolation, struck material, flight direction, 16-effect cap, RNG unchanged, all six delayed reveals delivered exactly once"); quit()
