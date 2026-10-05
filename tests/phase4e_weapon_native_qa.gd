extends SceneTree
# Native evidence, not an assertion that missing authored hands are finished art.
const Fit = preload("res://weapon_fit_catalog.gd")
const Matrix = preload("res://tests/weapon_fit_qa.gd")
const Weapons = preload("res://weapon_catalog.gd")
const STATES := ["idle", "windup", "strike", "recovery", "movement", "hurt"]
var output_folder := "res://.godot_test_data/phase4e/polish-weapons"

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("run_qa")

func run_qa() -> void:
	if not OS.get_environment("LOOTLINGS_4E_WEAPON_STAGE").is_empty(): output_folder="res://.godot_test_data/phase4e/"+OS.get_environment("LOOTLINGS_4E_WEAPON_STAGE")
	var helper = Matrix.new()
	helper.game = load("res://main.tscn").instantiate()
	var game = helper.game
	root.add_child(game)
	await process_frame
	game.app_lifecycle.platform_notifications_enabled = false
	game.audio_settings.cinematic_first_time = false
	var actors: Array = preload("res://wanderer_catalog.gd").selectable_ids()
	actors.append_array(preload("res://lootling_catalog.gd").selectable_ids())
	var caption := Label.new()
	caption.position = Vector2(8,615)
	caption.size = Vector2(464,45)
	caption.add_theme_font_size_override("font_size",17)
	root.add_child(caption)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_folder))
	var rows: Array = []
	var weapons: Array=["bow","crossbow","daggers","claws","sling","greatsword","spear","staff","maul","greataxe","wand","orb"]
	if not OS.get_environment("LOOTLINGS_4E_WEAPON_FILTER").is_empty(): weapons=Array(OS.get_environment("LOOTLINGS_4E_WEAPON_FILTER").split(","))
	for actor in actors:
		for facing in [1,-1]:
			var sheet := Image.create(1440,190*weapons.size(),false,Image.FORMAT_RGBA8)
			var row := 0
			for weapon in weapons:
				helper.prepare(actor,weapon)
				assert(game.inventory.equipped_item("Weapon").get("weapon_type","")==weapon,"Capture must equip its labelled weapon: "+weapon)
				game.wave = 15
				game.last_spawned_wave = 0
				game.spawn_enemy()
				game.player_facing = facing; game.forced_facing_test=facing
				game.enemy_entry_anim = 0
				game.special_intro_timer = 0
				game.pause_panel.visible = false
				game.state = "playing"
				game.wave_banner_timer = 0
				var rng_state: int = game.rng.state
				var loot_state: int = game.loot_system.rng.state
				for column in range(STATES.size()):
					var state: String = STATES[column]
					game.attack_anim = {"strike":.22,"impact":.11,"recovery":.06}.get(state,0.0)
					game.attack_clock = .02 if state == "windup" else game.current_attack_interval()
					game.run_time = 1.2 if state == "movement" else 0
					game.player_x = game.target_player_x() - (18 if state == "movement" else 0)
					game.player_flash = .15 if state == "hurt" else 0
					game.player_hp = 0 if state == "defeat" else game.player_max_hp
					game.enemy_attack_anim = .14 if state == "impact" else 0
					game.presentation_director.toast_queue.clear()
					game.presentation_director.active_toast.clear()
					game.presentation_director.toast_panel.visible = false
					# Defeat uses the existing result overlay; there is no separate death sprite.
					caption.text = "%s / %s / %s / %s — FORCED FACING TEST" % [actor,weapon,state,"R" if facing > 0 else "L"]
					game.queue_redraw()
					await create_timer(.045).timeout
					await process_frame
					await RenderingServer.frame_post_draw
					var pose := Fit.sample(game, state == "hurt")
					assert(pose.weapon_type==weapon)
					assert(game.rng.state == rng_state and game.loot_system.rng.state == loot_state)
					var cell := root.get_texture().get_image().get_region(Rect2i(0,280,480,380))
					cell.resize(240,190,Image.INTERPOLATE_LANCZOS)
					sheet.blit_rect(cell,Rect2i(0,0,240,190),Vector2i(column*240,row*190))
					rows.append({"actor":actor,"weapon":weapon,"state":state,"facing":facing,"support_status":pose.support_status,"held_path":pose.geometry.get("held_path","default"),"death_sprite_used":false})
				row += 1
			assert(sheet.save_png(output_folder+"/%s_%s.png" % [actor,"right" if facing > 0 else "left"]) == OK)
	var report := FileAccess.open(output_folder+"/report.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"samples":rows,"total":rows.size(),"columns":STATES,"rows":weapons,"note":"FORCED FACING TEST: isolated pose matrix only. Real target-facing is captured separately. Original articulated fallback rigs and preserved authored poses. Contact assertions are separate from owner art acceptance."},"\t"))
	print("PRESENTATION MATRIX: ", rows.size(), " native state samples, 24 contact sheets")
	helper.free()
	quit(0)
