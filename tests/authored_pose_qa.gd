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
		var key: String = "%s:%s:%s" % [row.actor,row.stance,row.phase]
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
	assert(keys.size() == 216)
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var native := "--visual" in OS.get_cmdline_user_args()
	var count := 0
	for actor in actors:
		var sheet := Image.create(720,854,false,Image.FORMAT_RGBA8) if native else null
		var cell := 0
		for family in ["greatsword","greataxe","maul"]:
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
			for phase in ["READY","RELEASE"]:
				game.attack_anim = .22 if phase == "RELEASE" else 0.0
				game.attack_clock = .02 if phase == "READY" else game.current_attack_interval()
				game.player_facing = 1
				var pose := Fit.sample(game)
				assert(pose.support_status == "authored_two_hand","Actual authored pair must fit: "+actor+"/"+family+"/"+phase)
				assert(pose.secondary_grip.distance_to(pose.secondary_hand) < .01)
				assert(pose.depth == "back")
				count += 1
				if native:
					game.queue_redraw()
					await create_timer(.15).timeout
					await RenderingServer.frame_post_draw
					var image := root.get_texture().get_image()
					assert(image.get_size() == Vector2i(480,854))
					image.save_png("res://.godot_test_data/authored_%s_%s_%s.png" % [actor,family,phase])
					image.resize(240,427,Image.INTERPOLATE_LANCZOS)
					sheet.blit_rect(image,Rect2i(0,0,240,427),Vector2i((cell/2)*240,(cell%2)*427))
					cell += 1
			game.player_facing = -1
			var opposite := Fit.sample(game)
			assert(opposite.opposite_art_required and opposite.support_status == "authored_pose_required")
		if native: sheet.save_png("res://.godot_test_data/authored_%s_sheet.png" % actor)
	print("AUTHORED POSE QA PASSED: %d actual ready/release hand-contact states; RGBA/canvas/anchor validation, manifest uniqueness, opposite-facing art explicitly incomplete" % count)
	game.queue_free()
	await process_frame
	quit(0)
