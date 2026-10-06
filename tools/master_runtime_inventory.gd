extends SceneTree
# Read-only Script reflection; no game instances or save access.
func clean(value):
	if value is Resource: return {"resource_path":value.resource_path}
	if value is Dictionary:
		var result := {}
		for key in value: result[str(key)]=clean(value[key])
		return result
	if value is Array:
		var result := []
		for item in value: result.append(clean(item))
		return result
	if value is Color: return {"rgba":value.to_html()}
	if typeof(value) in [TYPE_NIL,TYPE_BOOL,TYPE_INT,TYPE_FLOAT,TYPE_STRING,TYPE_STRING_NAME]: return value
	return str(value)
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	var inventory := {}
	for filename in DirAccess.get_files_at("res://"):
		if not filename.ends_with(".gd"): continue
		var script: Script=load("res://"+filename)
		var methods := []
		for method in script.get_script_method_list(): methods.append(str(method.name))
		inventory[filename]={"constants":clean(script.get_script_constant_map()),"methods":methods}
	DirAccess.make_dir_recursive_absolute("res://.godot_test_data/master-integration")
	var output=FileAccess.open("res://.godot_test_data/master-integration/runtime.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(inventory,"\t")); output.close()
	print("MASTER runtime inventory: ",inventory.size()," implementation scripts; no saves instantiated"); quit()
