extends SceneTree
const Manifest = preload("res://authored_pose_manifest.gd")
const Fit = preload("res://weapon_fit_catalog.gd")
const Wanderers = preload("res://wanderer_catalog.gd")
const Items = preload("res://item_catalog.gd")
const EvolutionQA = preload("res://tests/evolution_qa.gd")
var game

func _initialize() -> void:
	call_deferred("run_qa")

func run_qa() -> void:
	var keys := {}
	var actors: Array[String] = []
	for row in Manifest.rows():
		var key: String = "%s:%s:%s:%s" % [row.actor,row.stance,row.phase,row.facing]
		assert(not keys.has(key))
		keys[key] = true
		if row.production_status != "authored_beta": continue
		if row.actor not in actors: actors.append(row.actor)
		var image := Image.load_from_file(ProjectSettings.globalize_path(row.asset_path))
		assert(image.get_size() == Vector2i(1024,1536))
		assert(image.get_format() == Image.FORMAT_RGBA8)
		assert(image.get_pixel(10,10).a == 0)
		for anchor in [row.primary_anchor,row.secondary_anchor]:
			var point := Vector2i(Vector2(anchor[0],anchor[1])*Vector2(image.get_size()))
			assert(image.get_pixelv(point).a > .5)
	assert(keys.size() == 236)
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var native := "--visual" in OS.get_cmdline_user_args()
	var count := 0
	for actor in actors:
		var sheet := Image.create(1920,854,false,Image.FORMAT_RGBA8) if native else null
		var cell := 0
		for family in ["greatsword","greataxe","maul","staff"]:
			game.profile.avatar_mode = "wanderer"
			game.profile.wanderer = Wanderers.create_default()
			game.profile.wanderer.preset_id = actor
			game.profile.wanderer = Wanderers.sanitize(game.profile.wanderer)
			game.inventory.reset_to_starter()
			game.inventory.equip(Items.create_item(EvolutionQA.base_id(family),"COMMON",801))
			game.start_run()
			game.set_process(false)
			game.player_x = game.target_player_x()
			game.wave_banner_timer = 0
			game.special_intro_timer = 0
			game.presentation_director.toast_panel.visible = false
			for facing in [1,-1]:
				game.player_facing = facing
				for phase in ["READY","RELEASE"]:
					await check_pose(actor,family,phase,facing,native,sheet,cell)
					count += 1
					cell += 1
				# All supported action transforms remain finite/contact-correct,
				# including recoil, hurt and reward reaction, without new RNG use.
				var rng: int = game.rng.state
				var loot_rng: int = game.loot_system.rng.state
				for time in [.18,.10,.04,0.0]:
					game.attack_anim = time
					for hurt in [false,true]:
						var pose := Fit.sample(game,hurt)
						assert(pose.support_status == "authored_two_hand")
						assert(pose.secondary_grip.distance_to(pose.secondary_hand) < .01)
				assert(game.rng.state == rng and game.loot_system.rng.state == loot_rng)
			if family == "staff":
				# Exercise the real launch and flight path, not a painted orb fixture.
				game.player_facing = 1
				game.attack_anim = 0
				game.perform_player_attack(false)
				assert(game.attack_projectiles.size() == 1)
				assert(Vector2(game.attack_projectiles[0].start).distance_to(Fit.projectile_origin(game)) < .001)
				var hp: float = game.enemy_hp
				var duration: float = game.attack_projectiles[0].max_life
				game.update_attack_projectiles(duration * .35)
				assert(game.enemy_hp == hp and game.attack_projectiles.size() == 1)
				if native:
					game.queue_redraw()
					await create_timer(.05).timeout
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png("res://.godot_test_data/authored_%s_staff_flight.png" % actor)
				game.update_attack_projectiles(duration)
				assert(game.attack_projectiles.is_empty() and game.enemy_hp < hp)
		if native: sheet.save_png("res://.godot_test_data/authored_%s_sheet.png" % actor)
	print("AUTHORED POSE QA PASSED: %d actual two-facing ready/release states; RGBA/canvas/anchor validation, 236 unique manifest keys, unmirrored left anatomy, action contact and RNG isolation" % count)
	game.queue_free()
	await process_frame
	quit(0)

func check_pose(actor: String, family: String, phase: String, facing: int, native: bool, sheet: Image, cell: int) -> void:
	game.attack_anim = .22 if phase == "RELEASE" else 0.0
	game.attack_clock = .02 if phase == "READY" else game.current_attack_interval()
	var pose := Fit.sample(game)
	assert(pose.support_status == "authored_two_hand","Actual authored pair must fit: "+actor+"/"+family+"/"+phase)
	assert(pose.secondary_grip.distance_to(pose.secondary_hand) < .01)
	assert(pose.depth == "back")
	assert(not pose.opposite_art_required)
	assert(pose.authored_facing == ("left_only" if facing < 0 else "right_only"))
	assert(pose.root.determinant() > 0,"Authored anatomy must never be flipped")
	if native:
		game.queue_redraw()
		await create_timer(.15).timeout
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		assert(image.get_size() == Vector2i(480,854))
		image.save_png("res://.godot_test_data/authored_%s_%s_%s_%d.png" % [actor,family,phase,facing])
		image.resize(240,427,Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(image,Rect2i(0,0,240,427),Vector2i((cell/2)*240,(cell%2)*427))
