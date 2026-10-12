extends Control
# Individual earned records use the existing isolated expedition save transaction.
var hub
var scroll:ScrollContainer
var list:VBoxContainer
var current_id:=""
func configure(target) -> void:
 hub=target;position=Vector2(16,12);size=Vector2(400,198);mouse_filter=Control.MOUSE_FILTER_IGNORE
 scroll=ScrollContainer.new();scroll.size=size;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
 list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",8);scroll.add_child(list);hide()
func open_shelf() -> void:
 current_id="";show();hub.phase4_detail.hide();hub.phase4_action.hide()
 for node in list.get_children():list.remove_child(node);node.queue_free()
 var records:Array=hub.expedition_progress.discovery_records()
 if records.is_empty():
  var empty:RichTextLabel=preload("res://lootlings_ui.gd").rich_label(list,Rect2(0,0,380,100),15,Color("#e7edff"));empty.custom_minimum_size=Vector2(380,100);empty.text="[b]Your field journal begins here[/b]\n\nExplore expeditions to record creatures, places and hidden encounters."
 for record in records:
  var b:Button=hub.make_button(list,"",Rect2(0,0,380,64),Color("#172442"),Color("#7087ae"),15);b.custom_minimum_size=Vector2(380,64)
  b.text=record.title+"\n"+record.kind+(" · Read" if record.read else " · New")
  b.set_meta("discovery_id",record.id);b.set_meta("ui_sound","archive_page");b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  b.pressed.connect(open_record.bind(record.id))
 scroll.scroll_vertical=0;scroll.set_deferred("scroll_vertical",0)
func open_record(id:String) -> void:
 var records:Array=hub.expedition_progress.discovery_records();var matches:Array=records.filter(func(record):return record.id==id)
 if matches.is_empty():return
 current_id=id;var record:Dictionary=matches[0];var error:Error=hub.expedition_progress.read_discovery(id)
 hide();hub.phase4_detail.show();hub.phase4_detail.scroll_to_line(0)
 hub.phase4_detail.text="[b][color=#ffe6ad]"+record.title+"[/color][/b]\n"+record.kind+" · Discovered\n\n"+{"Region":"A place recorded on your travels. Choose it at the Gate to return.","Creature":"Encountered in the field. Equipment and perk choices can change how you face it.","Guardian":"An encounter worth preparing for. Watch its attack tells and keep room for healing.","Boss":"A major foe recorded in your journey. Its discovery stays with you after a run.","Elite":"A marked enemy encountered on an expedition.","Encounter":"A roadside encounter you discovered during an expedition.","Secret":"A hidden encounter you found along the way."}.get(record.kind,"")+"\n\n"+("Read · saved to your Archive." if error==OK else "Could not save the read mark. This record remains New; reopen it to retry.")
 hub.phase4_action.text="‹ FIELD DISCOVERIES";hub.phase4_action.visible=true;hub.phase4_action.disabled=false;hub.phase4_action.position.x=24;hub.phase4_action.size.x=432
