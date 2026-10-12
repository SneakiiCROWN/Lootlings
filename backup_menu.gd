extends Control
const Backup=preload("res://offline_backup.gd")
const Scope=preload("res://save_scope.gd")
var game
var panel:Panel
var picker:OptionButton
var info:RichTextLabel
var file_dialog:FileDialog
var bundle:Dictionary={}
var previous_pause:=false
var operation:=""
var restore_button:Button
func configure(target) -> void:
	game=target;z_index=940;process_mode=Node.PROCESS_MODE_ALWAYS;mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel=Panel.new();panel.size=Vector2(480,854);panel.mouse_filter=Control.MOUSE_FILTER_STOP;panel.hide();add_child(panel)
	preload("res://utility_presentation.gd").decorate(panel,"SAVES & BACKUPS","Your progress, safely kept on this device.","gear_charm")
	picker=OptionButton.new();picker.position=Vector2(28,140);picker.size=Vector2(424,60);picker.add_theme_font_size_override("font_size",15);picker.item_selected.connect(select_backup);panel.add_child(picker)
	preload("res://utility_presentation.gd").inset(panel,Rect2(28,212,424,176))
	info=RichTextLabel.new();info.position=Vector2(42,226);info.size=Vector2(396,148);info.add_theme_font_size_override("normal_font_size",16);info.add_theme_color_override("default_color",Color("#e7edff"));info.scroll_active=true;panel.add_child(info)
	button("CREATE LOCAL BACKUP",402,func():create_backup())
	restore_button=button("RESTORE SELECTED · REVIEW FIRST",468,request_restore)
	button("EXPORT CURRENT SAVE",534,func():choose_file("export"))
	button("IMPORT BACKUP · PREVIEW ONLY",600,func():choose_file("import"))
	button("RETURN",720,close)
	file_dialog=FileDialog.new();file_dialog.access=FileDialog.ACCESS_FILESYSTEM;file_dialog.use_native_dialog=true;file_dialog.filters=PackedStringArray(["*.lootlings-backup ; Lootlings backup"]);file_dialog.file_selected.connect(selected_file);add_child(file_dialog)
func button(caption:String,y:float,action:Callable) -> Button:
	var control:=Button.new();control.text=caption;control.position=Vector2(28,y);control.size=Vector2(424,60);control.add_theme_font_size_override("font_size",16);control.pressed.connect(action);panel.add_child(control)
	preload("res://utility_presentation.gd").button(control,caption.begins_with("CREATE"))
	return control
func open() -> void:
	if panel.visible:return
	previous_pause=get_tree().paused;get_tree().paused=true;panel.show();game.touch_ux.renew_surface();refresh()
func close() -> void:
	if not panel.visible:return
	file_dialog.hide();panel.hide();get_tree().paused=previous_pause;game.touch_ux.renew_surface()
func refresh() -> void:
	picker.clear();DirAccess.make_dir_recursive_absolute(Scope.path("user://backups/"))
	var files:=DirAccess.get_files_at(Scope.path("user://backups/"));files.sort();files.reverse()
	for name in files:
		if name.ends_with(".lootlings-backup"):
			var candidate:Dictionary=Backup.read_bundle("user://backups/"+name)
			var caption:String="Unverified backup · review required" if candidate.is_empty() else "Local backup · "+Time.get_datetime_string_from_unix_time(candidate.created).replace("T"," · ")
			picker.add_item(caption);picker.set_item_metadata(picker.item_count-1,"user://backups/"+name)
	if picker.item_count>0:select_backup(0)
	else:
		bundle={};picker.add_item("No local backups yet");picker.set_item_disabled(0,true);restore_button.disabled=true
		info.text="No backups yet\nCreate a local backup below, or import one to review.\n\nNormal and owner saves stay separate. Export a copy before uninstalling or changing devices."
func create_backup(prefix:String="manual") -> Error:
	var captured:Dictionary=Backup.snapshot(game)
	if captured.is_empty():info.text="Could not capture every save store. No backup or game progress was replaced.";return ERR_CANT_CREATE
	var path:String="user://backups/%s-%d-%d.lootlings-backup" % [prefix,int(Time.get_unix_time_from_system()),Time.get_ticks_msec()]
	var error:=Backup.save_bundle(captured,path)
	if error==OK:refresh();info.text="Local backup saved and verified. Export a copy to protect against uninstall or device loss."
	else:info.text="Backup could not be saved. Your existing saves are retained."
	return error
func select_backup(index:int) -> void:
	bundle=Backup.read_bundle(str(picker.get_item_metadata(index)));preview()
func preview() -> void:
	restore_button.disabled=bundle.is_empty()
	if bundle.is_empty():info.text="This backup is damaged, unsupported or belongs to the other profile. Nothing was imported.";return
	var profile:=ConfigFile.new();profile.parse(bundle.writes["lootlings_profile.cfg"])
	var wallet:=ConfigFile.new();wallet.parse(bundle.writes["lootlings_save.cfg"])
	var balances:Dictionary=preload("res://currency_schema.gd").balances(wallet)
	var display_name:String=str(profile.get_value("profile","display_name","")).strip_edges().left(60)
	if display_name.is_empty():display_name="Unnamed Lootling"
	info.text="%s profile · %s\n%d Lootcoins · %d Loot Diamonds\n\nRestore replaces this profile's progress. Your current save is backed up first; rewards are never duplicated." % [bundle.scope.capitalize(),display_name,balances.gold,balances.shards]
	info.scroll_to_line(0)
func request_restore() -> void:
	if bundle.is_empty():info.text="Select or import a valid backup first.";return
	var selected:Dictionary=bundle.duplicate(true)
	game.touch_ux.request("RESTORE THIS PROFILE?","Replace this profile's progression, collection, settings and guide state with the previewed backup? The current save is backed up first. Normal and owner saves cannot cross.",func():
		if create_backup("before-restore")!=OK:return
		var error:=Backup.restore(selected)
		if error==OK:close();get_tree().paused=false;get_tree().reload_current_scene()
		else:info.text="Restore could not finish. Recovery data is retained. Restart after checking storage.";game.set_process(false))
func choose_file(mode:String) -> void:
	operation=mode;file_dialog.file_mode=FileDialog.FILE_MODE_SAVE_FILE if mode=="export" else FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.title="Export Lootlings backup" if mode=="export" else "Import Lootlings backup for review"
	file_dialog.current_file="Lootlings.lootlings-backup" if mode=="export" else "";file_dialog.popup_centered(Vector2i(600,440))
func selected_file(path:String) -> void:
	if operation=="export":
		var captured:Dictionary=Backup.snapshot(game)
		info.text="Portable backup exported and verified." if not captured.is_empty() and Backup.save_bundle(captured,path)==OK else "Could not export this backup. Existing game saves are retained."
	else:bundle=Backup.read_bundle(path);preview()
