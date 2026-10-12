extends SceneTree
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("capture_canvas")
func capture_canvas() -> void:
 root.size=Vector2i(1080,2340)
 var painting:=Control.new();painting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);root.add_child(painting)
 var texture=load("res://art/backgrounds/lootlings_living_title_068.png")
 painting.draw.connect(func():
  var viewport:=root.get_visible_rect();painting.draw_rect(viewport,Color("#08152b"))
  var extent:Vector2=texture.get_size()*viewport.size.x/texture.get_width()
  painting.draw_texture_rect(texture,Rect2(viewport.get_center()-extent*.5,extent),false)
 )
 await create_timer(.3).timeout;painting.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
 assert(root.get_texture().get_image().save_png("res://.godot_test_data/title_tall_canvas_068.png")==OK)
 quit()
