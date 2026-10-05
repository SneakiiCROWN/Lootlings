extends SceneTree
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")

func review() -> void:
	var game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.audio_settings.cinematic_first_time=false
	var run_rng: int=game.rng.state; var loot_rng: int=game.loot_system.rng.state
	var retention_save: Dictionary=game.retention.progress.data.duplicate(true)
	var machine=game.retention.machine
	game.state="playing"; game.enemy_alive=true; game.enemy_encounter.active=false; game.forced_facing_test=0
	for positions in [Vector2(150,365),Vector2(350,105),Vector2(210,250),Vector2(290,250),Vector2(240,330),Vector2(240,150)]:
		game.player_x=positions.x; game.enemy_stage_x=positions.y
		var facing: int=1 if positions.y>positions.x else -1
		game.player_facing=-facing
		for animation in [0.0,.22,.06]:
			game.attack_anim=animation; game.player_flash=.15; game.enemy_recoil=22
			assert(game.combat_facing()==facing and game.enemy_facing_at(positions.y)==-facing)
	game.enemy_stage_x=game.ENEMY_X; game.attack_anim=0; game.player_flash=0; game.enemy_recoil=0
	for rarity in ["COMMON","UNCOMMON","RARE","EPIC","LEGENDARY","RED"]:
		machine.wind_up("material",rarity,true); machine.set_process(false)
		assert(machine.fast==(rarity in ["COMMON","UNCOMMON","RARE"]))
		assert(machine.skip()==(rarity in ["COMMON","UNCOMMON","RARE"]))
		machine.stop()
	assert(machine.aperture_layer.clip_contents)
	assert(machine.aperture_layer.mouse_filter==Control.MOUSE_FILTER_IGNORE)
	assert(game.retention.progress.data==retention_save)
	var boss=preload("res://boss_presentation.gd").profile("mossglass_wilds")
	assert(boss.texture_path==preload("res://vignette_catalog.gd").BOSS_ENTRIES.verdant_mirror.art)
	game.enemy_is_boss=false; game.enemy_name="ROOTBOUND GLASSWING"
	assert(preload("res://enemy_motion.gd").glasswing(game))
	game.enemy_name="MOSSBACK BRUTE"; assert(not preload("res://enemy_motion.gd").glasswing(game))
	for slot in game.hideout_ui.equipped_slot_buttons.values(): assert(slot.disabled)
	assert(game.hideout_ui.filter_buttons.size()==5)
	for speaker in ["Salvager","Archivist","Relic Keeper"]:
		var states: Array=[]
		for clock in [0.0,28.0,56.0,84.0,112.0]:
			game.hideout_ui.scene_time=clock
			var activity: String=game.hideout_ui.resident_activity(speaker)
			if not activity in states: states.append(activity)
		assert(states.size()>=4)
	assert(game.rng.state==run_rng and game.loot_system.rng.state==loot_rng)
	assert(preload("res://phase4b_catalog.gd").SPIN_COSTS==[140,230,360])
	var director=preload("res://contextual_dialogue.gd").new(); director.rng.seed=40205
	var last:=""
	for index in range(100):
		var text: String=director.choose("Salvager",{"event":"returning","weapon":"bow"})
		assert(text!=last); last=text
		assert(director.last_selection.category!="secret")
	var rare_count:=0; director=preload("res://contextual_dialogue.gd").new(); director.rng.seed=17
	for index in range(150):
		director.choose("Archivist",{"event":"archive_discovery"})
		if director.last_selection.category=="secret": rare_count+=1
	assert(rare_count<=1,"Rare lore has a real-time cooldown independent of repeated taps")
	var voices: Array=preload("res://wanderer_catalog.gd").selectable_ids(); voices.append_array(preload("res://lootling_catalog.gd").selectable_ids())
	for voice in voices:
		assert(preload("res://contextual_dialogue.gd").LINES.any(func(entry): return entry.speaker==voice and entry.get("outcome","")=="defeat"))
	for name in preload("res://regional_enemy_presentation.gd").ENTRIES:
		var profile=preload("res://regional_enemy_presentation.gd").profile(name)
		assert(not profile.is_empty() and profile.texture!=null)
	assert(game.rng.state==run_rng and game.loot_system.rng.state==loot_rng)
	game.free(); print("PHASE4E QA PASS: aperture owner, premium skip policy, preview save/RNG isolation, guardian identity, Glasswing assignment, single filter and deterministic resident states"); quit()
