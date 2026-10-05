extends SceneTree
const Fit=preload("res://weapon_fit_catalog.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	var helper=preload("res://tests/weapon_fit_qa.gd").new()
	helper.game=load("res://main.tscn").instantiate(); root.add_child(helper.game); await process_frame
	var game=helper.game
	var actors: Array=preload("res://wanderer_catalog.gd").selectable_ids()
	actors.append_array(preload("res://lootling_catalog.gd").selectable_ids())
	var samples:=0; var rig_samples:=0
	for actor in actors:
		for weapon in preload("res://weapon_catalog.gd").live_ids():
			helper.prepare(actor,weapon)
			var rng: int=game.rng.state; var loot_rng: int=game.loot_system.rng.state
			for facing in [-1,1]:
				game.forced_facing_test=facing
				for phase in [0.0,.06,.14,.22]:
					game.attack_anim=phase; game.attack_clock=.01 if phase==0 else game.current_attack_interval()
					var pose:=Fit.sample(game,phase==.06)
					assert(pose.support_status!="authored_pose_required")
					if pose.sprite_rig:
						rig_samples+=1
						assert(pose.texture.resource_path=="res://art/sprites/combat_rigs/%s.svg" % actor)
						assert(Vector2(13,-36).distance_to(pose.primary_hand)<95)
						if Vector2(-18,-34).distance_to(pose.secondary_hand)>82.01:
							push_error("Unreachable support hand: %s %s %s %s distance=%s" % [actor,weapon,facing,phase,Vector2(-18,-34).distance_to(pose.secondary_hand)]); quit(1); return
						if pose.handling=="paired": assert(pose.primary_hand.distance_to(pose.secondary_hand)>10)
						if pose.handling=="two_hand" and weapon!="bow": assert(pose.secondary_hand.distance_to(pose.secondary_grip)<.001)
						if weapon=="bow":
							var upper: Vector2=pose.weapon_rect.position+pose.weapon_rect.size*Vector2(.888,.258)
							var lower: Vector2=pose.weapon_rect.position+pose.weapon_rect.size*Vector2(.411,.887)
							var forward: Vector2=Vector2.RIGHT.rotated(-pose.weapon_rotation)*pose.weapon_scale
							var nock: Vector2=(upper+lower)*.5-forward*pose.action.anticipate*14
							if phase>.16: nock+=forward*sin((.22-phase)*80)*2
							var contact: Vector2=pose.primary_hand+(nock*pose.weapon_scale).rotated(pose.weapon_rotation)
							assert(contact.distance_to(pose.secondary_hand)<.001)
					assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng)
					samples+=1
	for region in preload("res://boss_patterns.gd").PATTERNS:
		for action in preload("res://boss_patterns.gd").PATTERNS[region].calls:
			var event: String=preload("res://boss_audio_identity.gd").event(region,action)
			if not event.is_empty(): assert(preload("res://audio_manager.gd").production_event_streams(event).size()==4)
	var rig=preload("res://combat_sprite_rig.gd")
	assert(rig.boot_box(Color.RED)==rig.boot_box(Color.RED))
	print("POLISH CONTRACTS: %d contact/facing/state samples, %d original rig samples, bounded reaches, distinct paired hands, exact string support, RNG isolation, documented regional cues" % [samples,rig_samples])
	helper.free(); game.queue_free(); await process_frame; quit()
