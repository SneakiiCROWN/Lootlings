extends RefCounted
# Reuse native-validated, weaponless runtime bodies. Never crop reference boards.
const Poses=preload("res://authored_pose_manifest.gd")
static var cache: Dictionary={}
static var sources: Dictionary={}
static func texture(actor: String,human: bool=false) -> Texture2D:
 var key: String=("human:" if human else "lootling:")+actor
 if cache.has(key):return cache[key]
 var body: Texture2D
 for family in ["wand","orb"]:
  var pose: Dictionary=Poses.extracted_phase(actor,family,"IDLE",1.0)
  if not pose.is_empty() and str(pose.get("baked_weapon",""))=="":
   body=pose.texture;break
 if body==null:
  body=preload("res://wanderer_catalog.gd").runtime_texture(actor) if human else preload("res://lootling_catalog.gd").runtime_texture(actor)
 if body==null:return null
 sources[key]=body.resource_path
 var pixels: Image=body.get_image()
 if pixels.is_compressed():pixels.decompress()
 var silhouette: Rect2i=pixels.get_used_rect()
 if silhouette.has_area():
  var atlas:=AtlasTexture.new();atlas.atlas=body;atlas.region=Rect2(silhouette.grow(2).intersection(Rect2i(Vector2i.ZERO,pixels.get_size())));atlas.filter_clip=true;cache[key]=atlas
 else:cache[key]=body
 return cache[key]
