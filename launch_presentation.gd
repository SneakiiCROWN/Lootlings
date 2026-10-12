extends Control
# First real scene: paints before loading the unchanged game; no timed delay.
const PORTRAIT=preload("res://art/ui/brand/073/boot_portrait.png")
const WIDE=preload("res://art/ui/brand/073/boot_wide.png")
const TALL=preload("res://art/ui/brand/073/boot_tall.png")
var body_font:Font
var load_status:=ResourceLoader.THREAD_LOAD_IN_PROGRESS
var load_error:=""
var presented_frames:=0
func _ready() -> void:
 body_font=preload("res://lootlings_typography.gd").body()
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter=Control.MOUSE_FILTER_STOP
func _process(_delta:float) -> void:
 presented_frames+=1;queue_redraw()
 if not load_error.is_empty() or presented_frames<2:return
 # Present one real frame, then use the established foreground loader. Godot's
 # threaded script loading leaked zero-reference objects in native teardown.
 var scene:PackedScene=load("res://main.tscn")
 if scene==null:load_error="Please reopen Lootlings.";return
 load_status=ResourceLoader.THREAD_LOAD_LOADED
 get_tree().change_scene_to_packed(scene)
func _draw() -> void:
 var bounds:=get_viewport_rect().size;var aspect:float=bounds.x/bounds.y
 var art:Texture2D=WIDE if aspect>1.25 else TALL if aspect<.51 else PORTRAIT
 var extent:=art.get_size()*maxf(bounds.x/art.get_width(),bounds.y/art.get_height())
 draw_texture_rect(art,Rect2((bounds-extent)*.5,extent),false)
 var caption:="Loading Lootlings..." if load_error.is_empty() else load_error
 var font_size:=clampi(roundi(minf(bounds.x,bounds.y)*.027),14,26)
 var text_size:=body_font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
 var point:=Vector2((bounds.x-text_size.x)*.5,bounds.y*.93)
 draw_rect(Rect2(point-Vector2(18,text_size.y),text_size+Vector2(36,18)),Color(.025,.05,.095,.75))
 draw_string(body_font,point,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("#f4e6c7"))
