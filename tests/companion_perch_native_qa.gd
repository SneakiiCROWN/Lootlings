# extends SceneTree through guarded native harness.
extends "res://tests/full_completion_ui_native_qa.gd"
class PerchReview extends Control:
	var actor := ""
	func _draw() -> void:
		var catalog=preload("res://companion_catalog.gd")
		draw_rect(Rect2(14,182,452,420),Color("#0c1835f5"))
		for i in range(4):
			var state: String="perch_rest" if i<2 else "perch_interact"
			var facing: String="right" if i%2==0 else "left"
			var art: Texture2D=catalog.texture(actor,state,facing)
			assert(art!=null)
			var pos:=Vector2(60+(i%2)*210,196+(i/2)*198)
			draw_texture_rect(art,Rect2(pos,Vector2(136,136)),false)
			draw_texture_rect(art,Rect2(pos+Vector2(40,130),Vector2(56,56)),false)
			draw_string(ThemeDB.fallback_font,pos+Vector2(0,190),state+" "+facing,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color.WHITE)
func review() -> void:
	var catalog=preload("res://companion_catalog.gd")
	var production_perches: Array=[]
	for actor in catalog.known_ids():
		if catalog.can_perch(actor):
			production_perches.append(actor)
			continue # Installed production textures take precedence over QA staging.
		for state in ["perch_rest","perch_interact"]:
			for facing in ["right","left"]:
				var path: String="res://art/source/master_artist_delivery/art/source/companions/"+actor+"/"+actor+"_"+state+"_"+facing+".png"
				if FileAccess.file_exists(path):catalog.review_assets[actor+":"+state+":"+facing]=path
	for size in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=size;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
		folder="res://.godot_test_data/companion-perches/%dx%d/" % [size.x,size.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		var gear: String=JSON.stringify(game.inventory.equipped);var gold: int=game.gold;var attacks: int=game.attack_sequence
		game.profile.companion.owned_ids=catalog.known_ids()
		for actor in catalog.available_ids():
			assert(catalog.can_perch(actor))
			game.profile.companion.equipped_id=actor;game.profile.homestead.home_layout=preload("res://home_catalog.gd").defaults()
			game.show_personal_home();var home=game.personal_home;home.set_process(false)
			var poses:=PerchReview.new();poses.actor=actor;poses.mouse_filter=Control.MOUSE_FILTER_IGNORE;home.add_child(poses)
			await capture(actor+"_four_perch_frames");poses.queue_free();await process_frame
			await tap(home.buttons.display);await tap(home.decor_tabs["home.floor_perch"]);assert(not home.companion_mode_buttons.perch.disabled)
			await tap(home.companion_mode_buttons.perch);await tap(home.decor_panel.get_node("ApplyDecor"))
			assert(game.profile.homestead.home_layout.companion_mode=="perch")
			game.profile=preload("res://profile_store.gd").load_profile(game.PROFILE_SAVE_PATH)
			assert(game.profile.companion.equipped_id==actor and game.profile.homestead.home_layout.companion_mode=="perch")
			for i in range(90):home.follower.update_home(.1,game.profile.companion,game.profile.homestead.home_layout)
			assert(home.follower.state=="perch_rest");home.queue_redraw();await capture(actor+"_floor_rest")
			await tap(home.buttons.nook);home.follower.update_home(.1,game.profile.companion,game.profile.homestead.home_layout)
			assert(home.follower.state=="perch_interact" and home.view=="room");home.queue_redraw();await capture(actor+"_floor_greet")
			await tap(home.buttons.display);await tap(home.decor_tabs["home.wall_perch"])
			if actor in ["lunarwisp","breezewyn"]:
				assert(not home.companion_mode_buttons.perch.disabled);await tap(home.companion_mode_buttons.perch);await tap(home.decor_panel.get_node("ApplyDecor"))
				for i in range(90):home.follower.update_home(.1,game.profile.companion,game.profile.homestead.home_layout)
				assert(home.follower.position==Vector2(374,412) and home.follower.facing=="left" and home.follower.state=="perch_rest")
				home.queue_redraw();await capture(actor+"_wall_rest");await tap(home.buttons.ledge);home.follower.update_home(.1,game.profile.companion,game.profile.homestead.home_layout);assert(home.follower.state=="perch_interact");home.queue_redraw();await capture(actor+"_wall_greet")
			else:
				assert(home.companion_mode_buttons.perch.disabled);game.navigate_back()
			var saved: String=JSON.stringify(game.profile.homestead)
			await tap(home.buttons.display);await tap(home.companion_mode_buttons.follow);game.navigate_back();assert(JSON.stringify(game.profile.homestead)==saved)
		assert(game.gold==gold and game.attack_sequence==attacks and JSON.stringify(game.inventory.equipped)==gear)
		game.free();await process_frame
	catalog.review_assets.clear()
	var restored: Array=[]
	for actor in catalog.known_ids():
		if catalog.can_perch(actor):restored.append(actor)
	assert(restored==production_perches)
	print("COMPANION PERCH NATIVE PASS: all six exact identities/four independent perch poses, floor rest/greeting, two compatible wall hovers, Apply/reload and Cancel, unchanged ownership/economy/gear/combat; phone+tablet")
	quit()
