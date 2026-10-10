extends "res://tests/motion_batch_native_qa.gd"
# Full twelve-actor movement/outcome and return-input regression without duplicate art captures.
func capture(_label: String) -> void:
 await create_timer(.25).timeout
 game.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
func tap(control: Control) -> void:
 assert(control.get_meta("gesture_release_owned",false),"Result return must own touch release")
 await super.tap(control)
 if game.state!="hideout":
  await capture("failed_result_return")
  root.get_texture().get_image().save_png("res://.godot_test_data/motion-batch-044/failed_result_return.png")
