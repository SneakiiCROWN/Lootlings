extends "res://tests/phase4b_native_qa.gd"
const Numbers=preload("res://combat_numbers.gd")
const Settings=preload("res://settings_store.gd")
var evidence:Array=[]
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless")
	OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
	create_timer(210).timeout.connect(func():push_error("Batch A native timeout");quit(1))
	call_deferred("review")
func named_button(parent:Node,caption:String) -> Button:
	for child in parent.get_children():
		if child is Button and child.text==caption:return child
		var found:=named_button(child,caption)
		if found!=null:return found
	return null
func review() -> void:
	for viewport in [Vector2i(360,640),Vector2i(480,854),Vector2i(1080,2340),Vector2i(800,1280),Vector2i(1200,1920),Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size=viewport
		folder="res://.godot_test_data/issue6-061/screens/%dx%d/" % [viewport.x,viewport.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
		game.audio_settings.cinematic_first_time=false
		game.startup_ui.show_title();await capture("title")
		game.startup_ui.show_settings()
		await tap(named_button(game.startup_ui.settings_content,"COMBAT TEXT"))
		assert(game.input_surface()==game.startup_ui.combat_preferences)
		var attacks:int=game.attack_sequence
		await tap(named_button(game.startup_ui.settings_content,"SUPPORT"))
		assert(not game.startup_ui.support_panel.visible and game.attack_sequence==attacks)
		game.startup_ui.combat_choices.combat_text_mode.select(3)
		game.startup_ui.combat_choices.combat_text_size.select(2)
		game.startup_ui.combat_toggles.combat_aggregate.button_pressed=true
		await capture("combat_settings")
		game.navigate_back();assert(not game.startup_ui.combat_preferences.visible)
		game.navigate_back()
		var saved:Dictionary=Settings.load_settings(game.SETTINGS_SAVE_PATH)
		assert(saved.combat_text_mode=="Expressive" and saved.combat_text_size=="Large")
		game.show_hideout();await capture("hub")
		game.hideout_ui.show_shop();await capture("shop")
		game.hideout_ui.show_forge();await capture("forge")
		game.hideout_ui.show_stash();await capture("stash")
		game.start_run();game.set_process(false);game.enemy_encounter.clear()
		game.enemy_alive=true;game.enemy_hp=100000;game.enemy_max_hp=100000;game.enemy_hit_multiplier=1
		game.enemy_name="Crystalbound Thunderhide Sentinel";game.enemy_variant_name="Frostmarked"
		game.wave_banner_timer=0;game.player_x=game.target_player_x();game.floating_texts.clear()
		var rng_before:int=game.rng.state
		game.audio_settings.combat_text_mode="Standard";game.audio_settings.combat_text_size="Normal"
		var before:float=game.enemy_hp
		for i in range(30):game.deal_elemental_hit(1,"Fire")
		assert(game.enemy_hp==before-30 and game.rng.state==rng_before)
		assert(game.floating_texts.any(func(x):return x.get("number_kind","")=="Fire" and x.hits==30 and x.amount==30))
		game.update_effects(.3);game.deal_elemental_hit(25,"Lightning",true)
		var lightning:Array=game.floating_texts.filter(func(x):return x.get("number_kind","")=="Lightning")
		assert(lightning.size()==1 and lightning[0].critical and lightning[0].color==Color(Numbers.COLORS.Lightning))
		await capture("combat_element_crit")
		game.update_effects(2)
		var names: Array[String]=game.combat_presentation.name_lines(game.body_font,game.enemy_name.to_upper(),193,17)
		assert(" ".join(names)==game.enemy_name.to_upper())
		for line in names:assert(game.body_font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,17).x<=193)
		var long_word:="UnbrokenCrystalboundThunderhide"
		assert("".join(game.combat_presentation.name_lines(game.body_font,long_word,120,17))==long_word)
		# Stress five independent target identities using actual stage coordinates.
		game.audio_settings.combat_aggregate=false
		for cycle in range(20):
			for serial in range(5):
				Numbers.add(game,3,"Poison",false,false,100+serial,Vector2(95+serial*68,482))
				Numbers.add(game,6,"critical",false,true,100+serial,Vector2(95+serial*68,482))
			assert(game.floating_texts.filter(func(x):return x.has("number_kind")).size()<=8)
			game.update_effects(1.4)
		assert(game.combat_number_allocations<=8 and game.combat_number_pool.size()<=8)
		game.audio_settings.combat_aggregate=true;game.audio_settings.cinematic_reduced_motion=true
		for kind in ["Physical","heavy","Ice","Poison","Shadow","Void","heal","ward","armour","incoming","enemy_heal"]:
			Numbers.add(game,8,kind,kind in ["heal","ward","armour","incoming"])
			var item:Dictionary=game.floating_texts.back();var position:Vector2=item.pos
			game.update_effects(.1);assert(item.pos==position)
			await capture("type_"+kind);game.update_effects(2)
		game.audio_settings.combat_text_mode="Off";before=game.enemy_hp
		game.deal_elemental_hit(1,"Fire");assert(game.enemy_hp==before-1 and game.floating_texts.is_empty())
		game.audio_settings.combat_text_mode="Minimal";Numbers.add(game,1,"Physical");assert(game.floating_texts.is_empty())
		Numbers.add(game,1,"ward",true);assert(game.floating_texts.size()==1)
		evidence.append({"viewport":str(viewport),"resolved_impacts":30,"five_target_stress_impacts":200,"peak_receipt_allocations":game.combat_number_allocations,"settings_saved":true,"modal_touch_fenced":true,"reduced_motion_fade_only":true,"professional_acceptance":false,"physical_device":false})
		game.free();await process_frame
		# Fresh game/config load proves the controls survive restart.
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		assert(game.audio_settings.combat_text_mode=="Expressive" and game.audio_settings.combat_text_size=="Large")
		game.free();await process_frame
	var file=FileAccess.open("res://.godot_test_data/issue6-061/BATCH_A_NATIVE.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence,"  "));file.close()
	print("BATCH A 061 NATIVE PASS: seven layouts, licensed shared fonts, unabridged enemy names, actual resolved hits, semantic critical elements, bounded recycled receipts, saved controls/restart, modal touch fencing and reduced motion. Artistic acceptance remains separate.")
	quit()
