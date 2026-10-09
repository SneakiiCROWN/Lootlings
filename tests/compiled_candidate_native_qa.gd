extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the existing isolated touch/capture helper.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(90).timeout.connect(func():push_error("Compiled candidate timeout");quit(1))
 call_deferred("review")

func review() -> void:
 var added:int=0
 for manifest in ["res://art/production_enemy_manifest.json","res://art/production_npc_manifest.json"]:
  var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(manifest))
  for row in data.entries:
   if row.get("actor","") not in ["bell_bat","rime_pup","coal_pup","patch","ilex"]:continue
   assert(row.native_validated and row.production_status=="canon_validated_runtime")
   var texture:Texture2D=load(row.asset_path);assert(texture!=null and texture.get_width()>0);added+=1
 assert(added==48)
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/candidate-final/%dx%d/" % [viewport.x,viewport.y]
  DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false)
  game.show_hideout();await process_frame
  var hub=game.hideout_ui;hub.dismiss_dialogue()
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  game.inventory.scrap=300
  game.hideout_shop.refresh_stock() # Independent unsold fixture stock for each viewport; isolated saves only.
  await tap(hub.hub_navigation.world_buttons.ShopEntrance);await tap(hub.shop_offer_buttons[1])
  assert(hub.shop_detail.position==Vector2(22,16) and hub.shop_detail.size==Vector2(268,110))
  assert(hub.shop_detail.get_theme_font_size("bold_font_size")==16)
  await capture("shop_final")
  var before:int=game.inventory.stash.size();var funds:int=game.inventory.scrap;var price:int=game.hideout_shop.stock[1].price
  await tap(hub.shop_buy_button);assert(game.inventory.stash.size()==before+1 and game.inventory.scrap==funds-price)
  game.navigate_back();await process_frame;assert(hub.current_screen=="home")
  assert(ResourceLoader.exists("res://art/audio/production/music/title.ogg"))
  game.free();await process_frame
 print("COMPILED CANDIDATE NATIVE PASS: 48 packaged textures, current comparison padding/type, actual shop purchase and natural Hub return; three viewports; isolated saves")
 quit()
