extends Control
# Outcome artwork is an authored gameplay state, not a stretched portrait.
var game
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(_delta: float) -> void:
 if visible and game!=null and game.state=="result":queue_redraw()
func _draw() -> void:
 if game==null or game.state!="result":return
 var pose:=preload("res://weapon_fit_catalog.gd").sample(game,false)
 if pose.get("motion_phase","") not in ["VICTORY","DEFEAT"]:return
 var rect:Rect2=pose.body_rect
 var scale_value:float=minf(size.x/rect.size.x,size.y/rect.size.y)
 var transform:=Transform2D(0,Vector2.ONE*scale_value,0,Vector2(size.x*.5,size.y-float(pose.feet_baseline)*scale_value))
 draw_set_transform(Vector2(size.x*.5,size.y-4),0,Vector2(1,.2));draw_circle(Vector2.ZERO,size.x*.35,Color("#080e2388"))
 if pose.depth=="back":draw_weapon(transform,pose)
 draw_set_transform_matrix(transform);draw_texture_rect(pose.texture,rect,false,Color.WHITE)
 if pose.depth=="front":draw_weapon(transform,pose)
 if pose.foreground is Texture2D:
  draw_set_transform_matrix(transform);draw_texture_rect(pose.foreground,rect,false,Color.WHITE)
 draw_set_transform(Vector2.ZERO)
func draw_weapon(transform: Transform2D,pose: Dictionary) -> void:
 var texture:Texture2D=preload("res://weapon_catalog.gd").presentation_texture(pose.weapon_type,"held",null,int(game.inventory.equipped_item("Weapon").get("evolution_stage",0)))
 var item:Dictionary=game.inventory.equipped_item("Weapon")
 var mythical:Texture2D=preload("res://mythical_collection.gd").texture(str(item.get("id","")))
 var rect:Rect2=pose.weapon_rect
 if mythical!=null:texture=mythical;rect.position=-preload("res://mythical_collection.gd").GRIPS[item.id]*rect.size
 if texture==null:return
 draw_set_transform_matrix(transform*Transform2D(float(pose.weapon_rotation),Vector2(pose.weapon_scale),0,Vector2(pose.hand)))
 draw_texture_rect(texture,rect,false,Color.WHITE)
