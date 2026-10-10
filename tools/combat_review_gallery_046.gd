extends SceneTree
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/player_combat_046_manifest.json"))
 var enemy:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/source/combat_continuation_046/ENEMY_CANDIDATE_MANIFEST.json"));data.entries.append_array(enemy.entries)
 var i:=0;var page:=0;var sheet:=Image.create(1600,1800,false,Image.FORMAT_RGBA8);sheet.fill(Color("#0b1427"))
 # Phone safe canvas transform: 2.25 scale, 209.25 top offset in 1080x2340.
 # Crop actual rendered combat including both actors, ground and held weapons.
 for row in data.entries:
  var name:String=row.contract_slot_id.replace(":","_")
  var source:=Image.new();assert(source.load("res://.godot_test_data/combat-continuation-046/1080x2340/"+name+".png")==OK)
  var body:=source.get_region(Rect2i(0,825,1080,620));body.resize(400,230,Image.INTERPOLATE_LANCZOS)
  var x:int=(i%4)*400;var y:int=(i/4)*300;sheet.blit_rect(body,Rect2i(0,0,400,230),Vector2i(x,y))
  i+=1
  if i==24:
   assert(sheet.save_png("res://.godot_test_data/combat-continuation-046/REVIEW_PAGE_%d.png" % page)==OK);page+=1;i=0;sheet.fill(Color("#0b1427"))
 if i>0:assert(sheet.save_png("res://.godot_test_data/combat-continuation-046/REVIEW_PAGE_%d.png" % page)==OK)
 print("COMBAT REVIEW GALLERY: exact manifest-order gameplay body/weapon views; not an acceptance test");quit()
