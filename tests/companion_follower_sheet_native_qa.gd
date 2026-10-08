extends "res://tests/full_completion_ui_native_qa.gd"
# extends SceneTree via isolated touch/capture helpers.
class PoseReview extends Control:
	var actor := ""
	func _draw() -> void:
		var catalog=preload("res://companion_catalog.gd")
		draw_rect(Rect2(14,182,452,464),Color("#0c1835f5"))
		for i in range(6):
			var state: String=["idle","move","reaction"][i/2]
			var facing: String="right" if i%2==0 else "left"
			var art: Texture2D=catalog.texture(actor,state,facing)
			assert(art!=null)
			var pos:=Vector2(32+(i%3)*148,204+(i/3)*218)
			draw_texture_rect(art,Rect2(pos,Vector2(136,136)),false)
			draw_texture_rect(art,Rect2(pos+Vector2(40,138),Vector2(56,56)),false)
			draw_string(ThemeDB.fallback_font,pos+Vector2(3,209),state+" "+facing,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color.WHITE)
func review() -> void:
	var catalog=preload("res://companion_catalog.gd")
	var production_ready:=catalog.available_ids()
	for actor in catalog.known_ids():
		for state in ["idle","move","reaction"]:
			for facing in ["right","left"]:
				var path: String="res://art/source/master_artist_delivery/art/source/companions/"+actor+"/"+actor+"_"+state+"_"+facing+".png"
				if FileAccess.file_exists(path):catalog.review_assets[actor+":"+state+":"+facing]=path
	var reviewed_actors:=catalog.available_ids()
	assert("auricub" in reviewed_actors and "stonekith" in reviewed_actors)
	for size in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=size;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
		folder="res://.godot_test_data/companion-followers/%dx%d/" % [size.x,size.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		var gear: String=JSON.stringify(game.inventory.equipped);var gold: int=game.gold;var attacks: int=game.attack_sequence
		game.profile.companion.owned_ids=catalog.known_ids()
		for actor in reviewed_actors:
			game.show_personal_home("companions")
			var selected_button: Button=game.hideout_ui.companion_buttons[actor]
			var scroll: ScrollContainer=selected_button.get_parent().get_parent().get_parent()
			scroll.ensure_control_visible(selected_button);await process_frame;await tap(selected_button)
			assert(game.profile.companion.equipped_id==actor)
			for id in game.hideout_ui.companion_buttons:assert(game.hideout_ui.companion_buttons[id].get_meta("ui_selected",false)==(id==actor))
			game.profile=preload("res://profile_store.gd").load_profile(game.PROFILE_SAVE_PATH);assert(game.profile.companion.equipped_id==actor)
			game.show_personal_home();game.personal_home.set_process(false)
			var poses:=PoseReview.new();poses.actor=actor;poses.mouse_filter=Control.MOUSE_FILTER_IGNORE;game.personal_home.add_child(poses)
			await capture(actor+"_six_frames");poses.queue_free();await process_frame
			game.personal_home.follower.position=Vector2(110,602);game.personal_home.follower.state="idle";game.personal_home.follower.facing="right"
			await capture(actor+"_home_follower")
			await tap(game.personal_home.buttons.nook);assert(game.personal_home.view=="companions")
			assert(game.hideout_ui.companion_buttons[actor].text=="EQUIPPED")
			await capture(actor+"_collection_equipped");game.navigate_back()
		assert(game.gold==gold and game.attack_sequence==attacks and JSON.stringify(game.inventory.equipped)==gear)
		game.free();await process_frame
	catalog.review_assets.clear();assert(catalog.available_ids()==production_ready)
	print("COMPANION FOLLOWER SHEET NATIVE PASS: both facings/all follower states of available canonical companions, actual56px Home scale, collection selection, isolated staged review, perch availability is checked independently, unchanged gear/gold/attacks; phone+tablet")
	quit()
