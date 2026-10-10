extends SceneTree
# Deterministic source-pixel component extraction; no anatomy redraw or body mirroring.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 var jobs:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/source/player_motion_044/EXPORT_JOBS.json"))
 for job in jobs.exports:
  var source:=Image.new();assert(source.load("res://"+str(job.source))==OK)
  var bounds:Rect2i=Rect2i(job.bounds[0],job.bounds[1],job.bounds[2]-job.bounds[0],job.bounds[3]-job.bounds[1])
  var pixels:=Image.create(bounds.size.x,bounds.size.y,false,Image.FORMAT_RGBA8);pixels.fill(Color.TRANSPARENT)
  var fingers:=Image.create(bounds.size.x,bounds.size.y,false,Image.FORMAT_RGBA8);fingers.fill(Color.TRANSPARENT)
  var palm:=Vector2(job.source_primary[0],job.source_primary[1]);var radius:float=job.grip_radius
  for run in job.runs:
   pixels.blit_rect(source,Rect2i(run[1],run[0],run[2]-run[1],1),Vector2i(run[1]-bounds.position.x,run[0]-bounds.position.y))
   for x in range(run[1],run[2]):
    if Vector2(x,run[0]).distance_to(palm)<=radius:fingers.set_pixel(x-bounds.position.x,run[0]-bounds.position.y,source.get_pixel(x,run[0]))
  var target:=Vector2i(job.scaled_size[0],job.scaled_size[1]);pixels.resize(target.x,target.y,Image.INTERPOLATE_LANCZOS);fingers.resize(target.x,target.y,Image.INTERPOLATE_LANCZOS)
  var offset:=Vector2i(job.offset[0],job.offset[1])
  var canvas:=Image.create(job.canvas[0],job.canvas[1],false,Image.FORMAT_RGBA8);canvas.fill(Color.TRANSPARENT);canvas.blit_rect(pixels,Rect2i(Vector2i.ZERO,target),offset)
  assert(canvas.save_png("res://"+str(job.asset))==OK)
  canvas.fill(Color.TRANSPARENT);canvas.blit_rect(fingers,Rect2i(Vector2i.ZERO,target),offset);assert(canvas.save_png("res://"+str(job.foreground))==OK)
 var manifest_path:="res://art/production/phase4e/player_motion_044_manifest.json"
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
 for row in manifest.entries:
  if preload("res://wanderer_catalog.gd").PRESETS.has(row.actor):row.wardrobe_requires=preload("res://wanderer_catalog.gd").appearance_manifest(row.actor).components
  if "wand" in row.weapon_types:
   var geometry:Dictionary=preload("res://weapon_fit_catalog.gd").GEOMETRY.wand
   row.weapon_overrides.wand={"size":[geometry.size.x,geometry.size.y],"grip":[geometry.grip.x,geometry.grip.y],"secondary_grip":[0,0],"socket":[geometry.socket.x,geometry.socket.y],"angle":.70,"held_path":"res://art/sprites/weapons/wand_held.png"}
  var sidecar:=FileAccess.open("res://"+row.metadata_path,FileAccess.WRITE);sidecar.store_string(JSON.stringify(row,"\t"));sidecar.close()
 var file:=FileAccess.open(manifest_path,FileAccess.WRITE);file.store_string(JSON.stringify(manifest,"\t"));file.close()
 print("MOTION source export PASS: ",jobs.exports.size()," independent bodies/fingers, measured source pixels, shared ground baseline; no mirrored anatomy")
 quit()
