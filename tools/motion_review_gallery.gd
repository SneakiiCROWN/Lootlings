extends SceneTree
# Native screenshots only; cropped review evidence never becomes runtime art.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 var actors:=["relic_beast","emberhorn","mosskin","pebblewyrm","glimmerfin","moonkip","gloomlet","vault_runner","ruin_warden","nightstage_drifter","velvet_astrologer","ashtrail_hunter"]
 var states:=["walk_right_0","walk_right_1","walk_left_0","walk_left_1","victory_right","victory_left","defeat_right","defeat_left"]
 for page in range(2):
  var sheet:=Image.create(1440,1440,false,Image.FORMAT_RGBA8);sheet.fill(Color("#111c31"))
  for line in range(6):
   var actor:String=actors[page*6+line]
   for column in range(8):
    var name:String=actor+"_"+("orb" if "defeat" in states[column] or actor=="velvet_astrologer" and "victory" in states[column] else "wand")+"_"+states[column]+".png"
    var source:=Image.new();assert(source.load("res://.godot_test_data/motion-batch-044/1080x2340/"+name)==OK)
    var crop:Rect2i=Rect2i(65 if "right" in states[column] else 450,940,465,530) if "walk" in states[column] else Rect2i(65,590,300,320)
    var image:=source.get_region(crop);image.resize(180,240,Image.INTERPOLATE_LANCZOS);sheet.blit_rect(image,Rect2i(0,0,180,240),Vector2i(column*180,line*240))
  assert(sheet.save_png("res://.godot_test_data/motion-batch-044/REVIEW_PAGE_"+str(page)+".png")==OK)
 print("Native review pages: columns right A/B, left A/B, victory R/L, defeat R/L; six actors each page in stable manifest order")
 quit()