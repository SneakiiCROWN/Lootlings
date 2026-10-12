extends Control
const Compare=preload("res://equipment_comparison.gd")
const UI=preload("res://lootlings_ui.gd")
const KEYS=["Base strike power","Auto-attack delay","Critical chance","Maximum HP","Incoming damage factor"]
var game
var details:RichTextLabel
var found:Dictionary
var equipped:Dictionary
var rows:Array=[]
var verdict:=""
var header_height:=100.0
var old_lines:Array=[]
var new_lines:Array=[]
static func install(label:RichTextLabel,target,new_item:Dictionary,old_item:Dictionary) -> void:
	var view=label.get_meta("quick_comparison") if label.has_meta("quick_comparison") else null
	if not is_instance_valid(view):
		view=load("res://quick_comparison.gd").new();view.mouse_filter=Control.MOUSE_FILTER_IGNORE;view.details=label;label.set_meta("comparison_rect",Rect2(label.position,label.size));label.set_meta("quick_comparison",view);label.get_parent().add_child(view)
	view.game=target;view.found=new_item.duplicate(true);view.equipped=old_item.duplicate(true);view.refresh()
	# Remove only duplicate cards; retain prices, caps, effects and stash warnings.
	var start:int=label.text.find("[table=2]");var end:int=label.text.find("[/table]",start)
	if start>=0 and end>=start:label.text=label.text.substr(0,start)+label.text.substr(end+8)
	var lore:String=str(new_item.get("desc",""))
	# The fixed summary already displays these exact formula values. Details
	# should begin with modifiers and signatures rather than repeat the table.
	var effective:int=label.text.find("[b]EFFECTIVE IF EQUIPPED[/b]")
	var effects:int=label.text.find("[b]ALL ITEM EFFECT CHANGES[/b]",effective)
	if effective>=0 and effects>effective:label.text=label.text.substr(0,effective)+label.text.substr(effects)
	if not lore.is_empty() and not label.text.contains(lore):label.text+="\n\n[b]ITEM LORE[/b]\n"+lore
static func reset(label:RichTextLabel) -> void:
	var view=label.get_meta("quick_comparison") if label.has_meta("quick_comparison") else null
	if is_instance_valid(view):
		view.hide();view.found={};var rect:Rect2=label.get_meta("comparison_rect");label.position=rect.position;label.size=rect.size
func refresh() -> void:
	var before=preload("res://inventory_system.gd").new();before.equipped=game.inventory.equipped.duplicate(true)
	var after=preload("res://inventory_system.gd").new();after.equipped=before.equipped.duplicate(true);after.equipped[str(found.get("slot","Weapon"))]=found.duplicate(true)
	var old_stats:=Compare.stats(game,before);var new_stats:=Compare.stats(game,after)
	var rect:Rect2=details.get_meta("comparison_rect");position=rect.position;size.x=rect.size.x
	var font:Font=preload("res://lootlings_typography.gd").bold()
	old_lines=preload("res://combat_presentation.gd").name_lines(font,str(equipped.get("name","Empty slot")),size.x*.5-52,16)
	new_lines=preload("res://combat_presentation.gd").name_lines(font,str(found.get("name","Item")),size.x*.5-52,16)
	header_height=42+18*maxi(old_lines.size(),new_lines.size())+40
	rows.clear();var gains:=0;var losses:=0
	for key in KEYS:
		var a:float=old_stats[key];var b:float=new_stats[key];var delta:float=b-a
		var changed:bool=absf(delta)>.00001;var gain:bool=delta<0 if key in ["Auto-attack delay","Incoming damage factor"] else delta>0
		if changed:
			if gain:gains+=1
			else:losses+=1
		var unit:String="s" if key=="Auto-attack delay" else "%" if key=="Critical chance" else "×" if key=="Incoming damage factor" else ""
		var change:String="= Same" if not changed else ("▲ " if gain else "▼ ")+"%+.2f%s" % [delta," pp" if unit=="%" else unit]
		if key=="Auto-attack delay" and changed:change+=" Faster" if gain else " Slower"
		rows.append({"key":{"Base strike power":"Strike","Auto-attack delay":"Delay","Critical chance":"Crit","Maximum HP":"Max HP","Incoming damage factor":"Damage in"}[key],"old":number(a)+unit,"new":number(b)+unit,"delta":change,"color":Color("#69e6b0" if gain else "#ff8794") if changed else Color("#b8c7dc"),"value_before":a,"value_after":b,"value_delta":delta})
	var powers_differ:bool=equipped.get("signature_hooks",[])!=found.get("signature_hooks",[])
	verdict="MIXED TRADE-OFF" if gains>0 and losses>0 else "CORE STATS IMPROVE · CHECK EFFECTS" if gains>0 else "CORE STATS LOWER · CHECK EFFECTS" if losses>0 else "SAME CORE STATS · CHECK EFFECTS"
	if powers_differ:verdict="TRADE-OFF · SIGNATURES CHANGE" if not (gains>0 and losses>0) else verdict+" · SIGNATURES CHANGE"
	size.y=header_height+148
	details.position=rect.position+Vector2(0,size.y+6);details.size=Vector2(rect.size.x,maxf(34,rect.size.y-size.y-6));details.scroll_to_line(0);show();queue_redraw()
func _process(_delta:float) -> void:
	visible=not found.is_empty() and is_instance_valid(details) and details.is_visible_in_tree()
static func number(value:float) -> String:
	var text:="%.2f" % value
	return text.trim_suffix(".00")
func _draw() -> void:
	var font:Font=preload("res://lootlings_typography.gd").bold();var body_font:Font=preload("res://lootlings_typography.gd").body()
	draw_rect(Rect2(Vector2.ZERO,size),Color("#101e31"));draw_line(Vector2(size.x*.5,0),Vector2(size.x*.5,header_height-4),Color("#51617c"),1)
	for index in range(2):
		var item:Dictionary=equipped if index==0 else found;var x:float=index*size.x*.5+6;var width:float=size.x*.5-12
		draw_string(font,Vector2(x,16),"EQUIPPED" if index==0 else "INSPECTING",HORIZONTAL_ALIGNMENT_LEFT,width,13,Color("#bcd1e8"))
		var texture:Texture2D=UI.item_texture(item)
		if texture!=null:
			var dimensions:Vector2=texture.get_size();var scaled:Vector2=dimensions*minf(32/dimensions.x,32/dimensions.y)
			draw_texture_rect(texture,Rect2(Vector2(x,27)+(Vector2(32,32)-scaled)*.5,scaled),false)
		var lines:Array=old_lines if index==0 else new_lines
		for line in range(lines.size()):draw_string(font,Vector2(x+38,39+18*line),lines[line],HORIZONTAL_ALIGNMENT_LEFT,width-38,16,Color("#f0f4fc"))
		draw_string(body_font,Vector2(x,header_height-26),str(item.get("rarity","Empty"))+" · "+str(item.get("slot",found.get("slot",""))),HORIZONTAL_ALIGNMENT_LEFT,width,12,preload("res://item_catalog.gd").rarity_color(str(item.get("rarity","COMMON"))))
		var identity:String=preload("res://item_catalog.gd").display_identity(item)
		var identity_size:int=UI.fitted_font_size(body_font,identity,width,12,10)
		draw_string(body_font,Vector2(x,header_height-10),identity,HORIZONTAL_ALIGNMENT_LEFT,width,identity_size,Color("#bcd1e8"))
	for column in [[.21,"Equipped"],[.42,"Candidate"],[.64,"Change"]]:
		draw_string(body_font,Vector2(size.x*column[0],header_height+12),column[1],HORIZONTAL_ALIGNMENT_LEFT,size.x*.20,12,Color("#c5ad7b"))
	for index in range(rows.size()):
		var row:Dictionary=rows[index];var y:float=header_height+index*22+32
		draw_string(body_font,Vector2(5,y),row.key,HORIZONTAL_ALIGNMENT_LEFT,size.x*.2,16,Color("#d4dfef"))
		draw_string(font,Vector2(size.x*.21,y),row.old,HORIZONTAL_ALIGNMENT_CENTER,size.x*.20,16,Color("#d4dfef"))
		draw_string(font,Vector2(size.x*.42,y),row.new,HORIZONTAL_ALIGNMENT_CENTER,size.x*.20,16,row.color)
		var fit:int=UI.fitted_font_size(font,row.delta,size.x*.35,15,14)
		draw_string(font,Vector2(size.x*.64,y),row.delta,HORIZONTAL_ALIGNMENT_LEFT,size.x*.35,fit,row.color)
		draw_line(Vector2(4,y+4),Vector2(size.x-4,y+4),Color("#263950"),1)
	var verdict_size:int=UI.fitted_font_size(font,verdict,size.x-12,14,11)
	draw_string(font,Vector2(6,size.y-7),verdict,HORIZONTAL_ALIGNMENT_CENTER,size.x-12,verdict_size,Color("#e9cd91"))
