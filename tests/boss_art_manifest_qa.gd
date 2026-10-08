extends SceneTree
const Art=preload("res://boss_art_manifest.gd")
const Boss=preload("res://boss_presentation.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	assert(Art.rows().size()==12,"Twelve native validated winged frames")
	for row in Art.rows():assert(Art.valid(row) and row.native_validated)
	assert(not Art.valid({"region":"act_i","asset_path":"res://art/reference/phase4e_handoff/approved_references/01_Hoard_Dragon_Canonical_Reference.png"}))
	var helper=preload("res://tests/weapon_fit_qa.gd").new()
	helper.game=load("res://main.tscn").instantiate(); root.add_child(helper.game); await process_frame
	helper.prepare("relic_beast","greatsword")
	var g=helper.game
	g.campaign_id="act_i"; g.wave=15; g.spawn_enemy(); g.forced_facing_test=0; g.enemy_entry_anim=0
	var rng: int=g.rng.state; var loot_rng: int=g.loot_system.rng.state
	for facing in [-1,1]:
		g.player_x=160 if facing<0 else 355; g.enemy_stage_x=365 if facing<0 else 140
		for state in ["idle","windup","commit","hurt","recovery","defeat"]:
			g.enemy_alive=state!="defeat"; g.enemy_flash=.1 if state=="hurt" else 0
			g.boss_recovery=.5 if state=="recovery" else 0
			g.enemy_attack_clock=.05 if state=="windup" else g.enemy_attack_interval
			g.combat_presentation.boss_action_time=.3 if state=="commit" else 0
			g.combat_presentation.boss_action="CLAWS"
			assert(Art.state_for(g).state==state,"Authored frame must follow existing state: "+state)
			assert(not Art.select_frame("act_i",state,"CLAWS" if state in ["windup","commit"] else "",facing).is_empty())
			var profile:=Boss.profile_for(g)
			assert(profile.has("authored_state"))
			assert(Boss.texture_for(profile)!=Boss.DRAGON,"Act I must route the original winged identity")
			assert(g.enemy_facing_at(g.enemy_stage_x)==facing)
	assert(g.rng.state==rng and g.loot_system.rng.state==loot_rng)
	g.free(); helper.free()
	print("BOSS ART MANIFEST QA: twelve native validated winged frames, both real target facings, reference-body guard and unchanged RNG")
	quit()
