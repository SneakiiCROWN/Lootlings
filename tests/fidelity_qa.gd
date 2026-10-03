extends SceneTree
const Matrix = preload("res://tests/weapon_fit_qa.gd")
const Fit = preload("res://weapon_fit_catalog.gd")
const Voice = preload("res://voice_identity.gd")
const Audio = preload("res://audio_manager.gd")
const Projectiles = preload("res://projectile_presentation.gd")
var game
var native := false
var checks := 0

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("run_qa")

func capture(name: String) -> Image:
	game.presentation_director.toast_queue.clear()
	game.presentation_director.active_toast.clear()
	game.presentation_director.toast_panel.visible = false
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	assert(image.save_png("res://.godot_test_data/fidelity/"+name+".png") == OK)
	return image

func run_qa() -> void:
	native = DisplayServer.get_name() != "headless"
	var helper := Matrix.new()
	game = load("res://main.tscn").instantiate()
	helper.game = game
	root.add_child(game)
	await process_frame
	game.app_lifecycle.platform_notifications_enabled = false
	game.audio_settings.cinematic_first_time = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.godot_test_data/fidelity"))
	var actors: Array = preload("res://wanderer_catalog.gd").selectable_ids()
	actors.append_array(preload("res://lootling_catalog.gd").selectable_ids())
	assert(actors.size() == 12 and Voice.PLAYER_PROFILES.size() == 12)
	var caption := Label.new()
	caption.position = Vector2(8,580); caption.size = Vector2(464,40)
	caption.add_theme_font_size_override("font_size",16)
	root.add_child(caption)
	for facing in [1,-1]:
		var sheet: Image
		if native: sheet = Image.create(2400,3720,false,Image.FORMAT_RGBA8)
		for row in range(actors.size()):
			var actor: String = actors[row]
			helper.prepare(actor,"bow")
			game.enemy_entry_anim = 0
			game.player_facing = facing
			game.player_x = game.target_player_x() if facing > 0 else 295.0
			game.enemy_max_hp = 10000; game.enemy_hp = 10000
			game.pause_panel.visible = false
			for column in range(5):
				game.attack_clock = .01 if column == 1 else game.current_attack_interval()
				if column < 2: game.attack_anim = 0
				if column == 2:
					game.perform_player_attack(false)
					assert(game.attack_projectiles.size() == 1)
					if facing < 0:
						# Explicit preview: live Act I target placement remains right-facing.
						game.attack_projectiles[0].target = Vector2(70,438)
				if column == 3:
					game.update_attack_projectiles(.055); game.attack_anim = .15
				if column == 4:
					game.update_attack_projectiles(.2); game.attack_anim = .045
				var pose := Fit.sample(game)
				var t: Transform2D = pose.root*Transform2D(pose.weapon_rotation,pose.weapon_scale,0,pose.hand)
				var string_mid: Vector2 = pose.weapon_rect.position+pose.weapon_rect.size*Vector2(.6495,.5725)
				assert(((pose.root*pose.hand).x-(t*string_mid).x)*facing > 5,"String must sit behind the grip, away from target: "+actor)
				assert((pose.projectile.x-(pose.root*pose.hand).x)*facing > 10,"Arrow must launch forward of the limbs")
				assert(Voice.player(game) == Voice.PLAYER_PROFILES[actor])
				caption.text = actor+" · "+["idle/nocked","draw/windup","fire","flight","recovery/impact"][column]+(" · left preview" if facing < 0 else " · live right")
				checks += 1
				if native:
					var image := await capture("bow_%s_%s_%d" % [actor,"right" if facing > 0 else "left",column])
					var cell := image.get_region(Rect2i(0,310,480,310))
					sheet.blit_rect(cell,Rect2i(0,0,480,310),Vector2i(column*480,row*310))
		if native: assert(sheet.save_png("res://.godot_test_data/fidelity/bows_%s.png" % ("right" if facing > 0 else "left")) == OK)
	helper.prepare("relic_beast","bow")
	game.enemy_entry_anim = 0
	for element in Projectiles.COLORS:
		for weapon in ["bow","crossbow","staff","wand","orb","sling"]:
			helper.prepare("relic_beast",weapon)
			game.enemy_entry_anim = 0
			game.perform_player_attack(false)
			assert(game.attack_projectiles.size() == 1)
			game.attack_projectiles[0].element = element
			game.update_attack_projectiles(.045); game.attack_anim = .15
			caption.text = element+" · "+weapon+" · presentation variant"
			if native: await capture("projectile_"+element.to_lower()+"_"+weapon)
			game.update_attack_projectiles(.2)
			if native: await capture("impact_"+element.to_lower()+"_"+weapon)
			assert(game.projectile_impacts.size() <= 16)
			checks += 1
	# Actual enemy death creates the existing paid rewards; only presentation is new.
	helper.prepare("relic_beast","greatsword")
	game.enemy_entry_anim = 0
	game.kill_enemy()
	assert(not game.reward_pickups.is_empty())
	if native: await capture("combat_death_pickups")
	for rarity in game.ItemCatalog.RARITIES:
		game.debug_force_drop(rarity)
		var drop: Dictionary = game.loot_drops.back()
		drop.pos = Vector2(330,450); drop.bounces = 1; drop.pickup = .8
		caption.text = rarity+" · real item drop renderer"
		if native: await capture("item_drop_"+rarity.to_lower())
		game.loot_drops.clear()
	# All authored banks and licensing: no human pain source in creature profiles.
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/audio/production/sources.json"))
	var pcm_bytes := 0
	for profile in Voice.PROFILES:
		for role in ["attack","hurt","death"]:
			var event: String = "voice_"+profile+"_"+role
			var bank := Audio.production_event_streams(event)
			assert(bank.size() == 4)
			for clip in bank: pcm_bytes += clip.data.size()
			for asset in manifest.assets:
				if str(asset.asset).get_file().begins_with(event+"_") and not profile.begins_with("human_"):
					for source in asset.sources: assert(source.get("pack","") != "pain")
	assert(pcm_bytes < 10*1024*1024,"Species bank residency budget")
	if native and not await validate_combat_voices(helper,actors):
		quit(1)
		return
	print("FIDELITY QA PASSED: ",checks," visual/socket cases; 12 player identities; 14 vocal profiles; species PCM bytes=",pcm_bytes)
	helper.free()
	quit(0)

func validate_combat_voices(helper, actors: Array) -> bool:
	var master := AudioServer.get_bus_index("Master")
	var capture_audio := AudioEffectCapture.new(); capture_audio.buffer_length = 30
	AudioServer.add_bus_effect(master,capture_audio)
	for actor in actors:
		helper.prepare(actor,"greatsword")
		for player in game.audio_manager.players["SFX"]: player.stop()
		game.audio_manager.last_event_msec.clear()
		game.attack_sequence = 0
		game.perform_player_attack(false)
		var profile: String = Voice.player(game)
		assert(game.audio_manager.event_sequence.get("voice_"+profile+"_attack",0) > 0)
		await create_timer(.16).timeout
		for player in game.audio_manager.players["SFX"]: player.stop()
		game.perform_enemy_attack()
		assert(game.audio_manager.event_sequence.get("voice_"+profile+"_hurt",0) > 0)
		await create_timer(.22).timeout
		game.player_hp = .01
		for player in game.audio_manager.players["SFX"]: player.stop()
		game.perform_enemy_attack()
		assert(game.audio_manager.event_sequence.get("voice_"+profile+"_death",0) > 0)
		await create_timer(.3).timeout
	for wave in [1,8,15]:
		for region in ["act_i","mossglass_wilds","cinder_crown"]:
			for archetype in ["skirmisher","tank","hexer"]:
				helper.prepare("relic_beast","greatsword")
				for player in game.audio_manager.players["SFX"]: player.stop()
				game.wave = wave; game.campaign_id = region; game.spawn_enemy()
				game.enemy_archetype = archetype
				game.audio_manager.last_event_msec.clear()
				var profile: String = Voice.enemy(game)
				game.attack_sequence = 4 if game.enemy_is_boss else 3
				game.damage_enemy(.01,false,false)
				assert(game.audio_manager.event_sequence.get("voice_"+profile+"_hurt",0) > 0)
				await create_timer(.1).timeout
				for player in game.audio_manager.players["SFX"]: player.stop()
				game.perform_enemy_attack()
				assert(game.audio_manager.event_sequence.get("voice_"+profile+"_attack",0) > 0)
				await create_timer(.1).timeout
				for player in game.audio_manager.players["SFX"]: player.stop()
				game.kill_enemy()
				assert(game.audio_manager.event_sequence.get("voice_"+profile+"_death",0) > 0)
				await create_timer(.24).timeout
	var samples := capture_audio.get_buffer(capture_audio.get_frames_available())
	assert(samples.size() > 1000)
	var pcm := PackedByteArray(); pcm.resize(samples.size()*4)
	var peak := 0.0
	for i in range(samples.size()):
		peak = maxf(peak,maxf(absf(samples[i].x),absf(samples[i].y)))
		pcm.encode_s16(i*4,int(clampf(samples[i].x,-1,1)*32767)); pcm.encode_s16(i*4+2,int(clampf(samples[i].y,-1,1)*32767))
	assert(peak > .01 and peak <= 1.0)
	var preview := AudioStreamWAV.new(); preview.format = AudioStreamWAV.FORMAT_16_BITS
	preview.mix_rate = AudioServer.get_mix_rate(); preview.stereo = true; preview.data = pcm
	assert(preview.save_to_wav("res://.godot_test_data/fidelity/combat-voices.wav") == OK)
	AudioServer.remove_bus_effect(master,AudioServer.get_bus_effect_count(master)-1)
	print("Native live voice hooks: 12 players, 27 enemy/boss contexts; peak=",linear_to_db(peak)," dBFS")
	return true
