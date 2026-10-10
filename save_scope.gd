extends RefCounted
# All normal paths/schema stay unchanged. Test writes have a separate namespace.
static var active: bool=false
static var transitioning: bool=false
static var open_debug: bool=false
static func path(value: String) -> String:
 if not active or not value.begins_with("user://") or value.begins_with("user://owner_sandbox/"):return value
 var target:String="user://owner_sandbox/"+value.trim_prefix("user://")
 DirAccess.make_dir_recursive_absolute(target.get_base_dir())
 return target
static func switch_profile(tree: SceneTree, sandbox: bool) -> void:
 transitioning=true;active=sandbox;open_debug=sandbox
 Engine.time_scale=1.0;tree.paused=false
 tree.reload_current_scene()
