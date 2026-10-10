extends SceneTree
# Native pixel extraction; no alteration of source anatomy, costume or alpha.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 var jobs:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/source/resident_044/EXPORT_JOBS.json"))
 for job in jobs.exports:
  var source:=Image.new();assert(source.load("res://"+job.source)==OK)
  var b:Rect2i=Rect2i(job.bounds[0],job.bounds[1],job.bounds[2]-job.bounds[0],job.bounds[3]-job.bounds[1])
  var pixels:=Image.create(b.size.x,b.size.y,false,Image.FORMAT_RGBA8);pixels.fill(Color.TRANSPARENT)
  for run in job.runs:pixels.blit_rect(source,Rect2i(run[1],run[0],run[2]-run[1],1),Vector2i(run[1]-b.position.x,run[0]-b.position.y))
  var target:=Vector2i(job.scaled_size[0],job.scaled_size[1]);pixels.resize(target.x,target.y,Image.INTERPOLATE_LANCZOS)
  var canvas:=Image.create(1024,1536,false,Image.FORMAT_RGBA8);canvas.fill(Color.TRANSPARENT);canvas.blit_rect(pixels,Rect2i(Vector2i.ZERO,target),Vector2i(job.offset[0],job.offset[1]));assert(canvas.save_png("res://"+job.asset)==OK)
 print("RESIDENT source export PASS: ",jobs.exports.size()," complete independent bodies, original right rest reused")
 quit()
