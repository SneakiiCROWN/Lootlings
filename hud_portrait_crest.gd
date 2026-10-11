extends TextureRect
# Canonical portrait, masked in presentation only; source art is untouched.
var game
var last_expression := ""
func _ready() -> void:
	position=Vector2(10,14);size=Vector2(48,48)
	expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	var shader:=Shader.new()
	shader.code="""shader_type canvas_item;
uniform vec2 crest_size=vec2(48.0);
varying vec2 local_uv;
void vertex(){local_uv=VERTEX/crest_size;}
void fragment(){
 float radius=length(local_uv-vec2(.5));
 vec4 portrait=texture(TEXTURE,UV);
 float edge=1.0-smoothstep(.46,.485,radius);
 float rim=smoothstep(.425,.445,radius);
 COLOR=vec4(mix(portrait.rgb,vec3(.78,.64,.36),rim),max(portrait.a,rim)*edge);
}"""
	var mask:=ShaderMaterial.new();mask.shader=shader;material=mask
func _process(_delta:float) -> void:
	visible=not game.startup_ui.visible and not game.hideout_ui.visible and not game.personal_home.visible and game.state!="mode_menu" and not (game.state=="relic_spinner" and game.retention.spinner_from_home)
	if not visible:return
	material.set_shader_parameter("crest_size",size)
	var expression:String="sad" if game.player_flash>0 else "excited" if game.player_reward_flash>0 else "surprised" if game.special_intro_timer>0 else "cheeky" if game.crit_flash>0 else "angry" if game.attack_anim>0 else "determined"
	if expression!=last_expression:
		texture=preload("res://avatar_presentation.gd").portrait(game.profile,expression)
		last_expression=expression
