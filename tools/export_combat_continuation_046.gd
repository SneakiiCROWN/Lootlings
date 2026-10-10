extends SceneTree
# Deterministic source-pixel component extraction; no anatomy redraw or body mirroring.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 var installed:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/player_combat_046_manifest.json"))
 for row in installed.entries:
  if row.get("native_validated",false):
   push_error("Refusing to overwrite accepted combat assets; use a separate correction manifest")
   quit(1);return
 var jobs:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/source/combat_continuation_046/EXPORT_JOBS.json"))
 for job in jobs.exports:
  var source:=Image.new();assert(source.load("res://"+str(job.source))==OK)
  var bounds:Rect2i=Rect2i(job.bounds[0],job.bounds[1],job.bounds[2]-job.bounds[0],job.bounds[3]-job.bounds[1])
  var pixels:=Image.create(bounds.size.x,bounds.size.y,false,Image.FORMAT_RGBA8);pixels.fill(Color.TRANSPARENT)
  var fingers:=Image.create(bounds.size.x,bounds.size.y,false,Image.FORMAT_RGBA8);fingers.fill(Color.TRANSPARENT)
  var palm:=Vector2(job.source_primary[0],job.source_primary[1]);var second:=Vector2(job.get("source_secondary",[0,0])[0],job.get("source_secondary",[0,0])[1]);var radius:float=job.grip_radius
  for run in job.runs:
   pixels.blit_rect(source,Rect2i(run[1],run[0],run[2]-run[1],1),Vector2i(run[1]-bounds.position.x,run[0]-bounds.position.y))
   for x in range(run[1],run[2]):
    if Vector2(x,run[0]).distance_to(palm)<=radius or (job.has("source_secondary") and Vector2(x,run[0]).distance_to(second)<=radius):fingers.set_pixel(x-bounds.position.x,run[0]-bounds.position.y,source.get_pixel(x,run[0]))
  var target:=Vector2i(job.scaled_size[0],job.scaled_size[1]);pixels.resize(target.x,target.y,Image.INTERPOLATE_LANCZOS);fingers.resize(target.x,target.y,Image.INTERPOLATE_LANCZOS)
  var offset:=Vector2i(job.offset[0],job.offset[1])
  var canvas:=Image.create(job.canvas[0],job.canvas[1],false,Image.FORMAT_RGBA8);canvas.fill(Color.TRANSPARENT);canvas.blit_rect(pixels,Rect2i(Vector2i.ZERO,target),offset)
  assert(canvas.save_png("res://"+str(job.asset))==OK)
  if not str(job.foreground).is_empty():
   canvas.fill(Color.TRANSPARENT);canvas.blit_rect(fingers,Rect2i(Vector2i.ZERO,target),offset);assert(canvas.save_png("res://"+str(job.foreground))==OK)
 var manifest_path:="res://art/production/phase4e/player_combat_046_manifest.json"
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
 for row in manifest.entries:
  if preload("res://wanderer_catalog.gd").PRESETS.has(row.actor):row.wardrobe_requires=preload("res://wanderer_catalog.gd").appearance_manifest(row.actor).components
  var weapon:String=row.weapon_types[0]
  var geometry:Dictionary=preload("res://weapon_fit_catalog.gd").GEOMETRY[weapon]
  var secondary:Vector2={"greatsword":Vector2(.415,.70),"greataxe":Vector2(.45,.54),"maul":Vector2(.46,.56)}[weapon]
  var held:String="res://art/sprites/weapons/"+weapon+"_held.png" if weapon!="maul" else "res://art/sprites/weapons/vanguard_hammer.png"
  row.weapon_overrides[weapon]={"size":[geometry.size.x,geometry.size.y],"grip":[geometry.grip.x,geometry.grip.y],"secondary_grip":[secondary.x,secondary.y],"socket":[geometry.socket.x,geometry.socket.y],"angle":geometry.angle,"held_path":held}
  var sidecar:=FileAccess.open("res://"+row.metadata_path,FileAccess.WRITE);sidecar.store_string(JSON.stringify(row,"\t"));sidecar.close()
 var file:=FileAccess.open(manifest_path,FileAccess.WRITE);file.store_string(JSON.stringify(manifest,"\t"));file.close()
 print("COMBAT 046 source export PASS: ",jobs.exports.size()," independent bodies/fingers, measured source pixels, shared ground baseline; no mirrored anatomy")
 quit()
