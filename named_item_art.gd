extends RefCounted
# Per-item art may enter player routes only after native visual acceptance.
static var entries: Dictionary={}
static var loaded:=false
static func texture(id: String) -> Texture2D:
 if not loaded:
  loaded=true
  var data=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/items/named_048/manifest.json"))
  if data is Dictionary:
   for row in data.get("entries",[]):entries[row.id]=row
 if not entries.has(id):return null
 var row: Dictionary=entries[id]
 var preview:bool=OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_QA_ITEM_PREVIEW")=="1"
 if not row.get("native_validated",false) and not preview:return null
 var path:String=row.asset_path
 if not path.begins_with("res://art/production/phase4e/items/named_048/") or ".." in path:return null
 return load(path)
