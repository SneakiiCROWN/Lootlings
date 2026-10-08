extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through guarded native helper; all live armour inventory IDs.
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/armour-family/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.show_hideout();game.hideout_ui.hide()
  var board:=ColorRect.new();board.position=Vector2(0,0);board.size=Vector2(480,854);board.color=Color("#081225");board.z_index=1000;game.add_child(board)
  var title:=Label.new();title.text="ARMOUR · LIVE INVENTORY FAMILY";title.position=Vector2(16,18);title.size=Vector2(448,40);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title.add_theme_font_size_override("font_size",20);board.add_child(title)
  var ids:Array=[]
  for definition in game.ItemCatalog.ITEMS:
   if definition.slot=="Armour":ids.append(definition.id)
  assert(ids.size()==12)
  for index in range(ids.size()):
   var item:Dictionary=game.ItemCatalog.create_item(ids[index],"EPIC",9800+index)
   var texture:Texture2D=preload("res://lootlings_ui.gd").item_texture(item)
   assert(texture.resource_path.ends_with("/armour_inventory_v1/"+ids[index]+".png"),"Every live armour needs its specific icon")
   var cell:=Control.new();cell.position=Vector2(14+(index%3)*152,80+(index/3)*178);cell.size=Vector2(144,170);board.add_child(cell)
   var icon:=preload("res://item_icon.gd").new();icon.position=Vector2(18,0);icon.size=Vector2(108,108);cell.add_child(icon);icon.configure(item)
   var small:=preload("res://item_icon.gd").new();small.position=Vector2(52,106);small.size=Vector2(40,40);cell.add_child(small);small.configure(item)
   var caption:=Label.new();caption.text=item.name;caption.position=Vector2(0,145);caption.size=Vector2(144,24);caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;caption.add_theme_font_size_override("font_size",11);cell.add_child(caption)
  await capture("all_twelve_inventory_icons")
  game.queue_free();await process_frame
 print("ARMOUR FAMILY NATIVE PASS: 12 live IDs, full and 40-unit item icons, three viewport sizes; category fallbacks replaced")
 quit()
