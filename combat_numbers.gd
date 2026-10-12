extends RefCounted
# Resolved damage receipts only: no combat mutation or RNG draws.
const LIMIT := 8
const COLORS={"Physical":"#eef3ff","Fire":"#ffad61","Ice":"#88e9ff","Frost":"#88e9ff","Lightning":"#8ff0ff","Poison":"#73e2aa","Nature":"#a6e596","Shadow":"#c99cff","Void":"#c99cff","enemy_heal":"#91e7ba","heal":"#80e7b6","ward":"#91ddff","armour":"#c1c9df","incoming":"#ff9aa5","heavy":"#ff927f","critical":"#ffe593"}
static func text(kind: String, amount: float, hits: int=1) -> String:
 var value:String=preload("res://display_numbers.gd").compact(int(round(amount))) if amount>=10000 else "<0.01" if amount<.01 else ("%.2f" if amount<1 else "%.1f" if amount<10 else "%.0f") % amount
 var label: String={"Physical":"HIT","critical":"CRIT!","heavy":"HEAVY","enemy_heal":"MEND +","heal":"HP +","ward":"WARD BLOCK","armour":"ARMOUR BLOCK","incoming":"HP −","Fire_tick":"BURN","Poison_tick":"POISON"}.get(kind,kind.to_upper())
 return "%s %s%s" % [label,value," ×%d" % hits if hits>1 else ""]
static func recycle(g, item: Dictionary) -> void:
 if item.has("number_kind") and g.combat_number_pool.size()<LIMIT:
  item.clear(); g.combat_number_pool.append(item)
static func discard(g, item: Dictionary) -> void:
 g.floating_texts.erase(item); recycle(g,item)
static func clear(g) -> void:
 for item in g.floating_texts:recycle(g,item)
 g.floating_texts.clear()
static func add(g, amount: float, kind: String, player: bool=false, critical: bool=false, target_serial: int=-2147483648, impact: Vector2=Vector2.INF) -> void:
 var mode: String=g.audio_settings.get("combat_text_mode","Standard")
 if amount<=0.0001 or mode=="Off":return
 critical=critical or kind=="critical"
 var priority:int=3 if critical else 2 if kind in ["incoming","ward","heal","heavy"] or g.enemy_is_boss else 1
 if mode=="Minimal" and priority<2:return
 var serial:int=(-1 if player else g.enemy_serial) if target_serial==-2147483648 else target_serial
 if g.audio_settings.get("combat_aggregate",true):
  for item in g.floating_texts:
   if item.get("number_kind","")==kind and item.get("serial",-2)==serial and item.get("critical",false)==critical and float(item.get("age",1))<.26:
    item.amount+=amount;item.hits+=1;item.text=text(kind,item.amount,item.hits)
    item.life=minf(float(item.max_life)-float(item.age),float(item.life)+.08);return
 var local:Array=g.floating_texts.filter(func(x):return x.has("number_kind") and x.serial==serial)
 while local.size()>=3:discard(g,local.pop_front())
 var typed:Array=g.floating_texts.filter(func(x):return x.has("number_kind"))
 var active_limit:int=4 if g.enemy_encounter.active else LIMIT
 if typed.size()>=active_limit:
  typed.sort_custom(func(a,b):return int(a.priority)<int(b.priority) if a.priority!=b.priority else float(a.age)>float(b.age))
  if int(typed[0].priority)>priority:return
  discard(g,typed[0])
 var count:int=0
 while local.any(func(x):return int(x.get("slot",-1))==count):count+=1
 var pack_row:int=0
 var remaining:Array=g.floating_texts.filter(func(x):return x.has("number_kind"))
 while remaining.any(func(x):return int(x.get("pack_row",-1))==pack_row):pack_row+=1
 var origin:Vector2=impact if impact.is_finite() else preload("res://weapon_fit_catalog.gd").world_position(g) if player else g.target_combat_visual_position()
 var pos:=Vector2(clampf(origin.x,85,395),clampf(origin.y+(34 if player else -48)+count*26,412,586 if player else 474))
 # Tight packs get four separated lanes below feet, never a wall over faces.
 if g.enemy_encounter.active:pos.y=clampf(origin.y+70+pack_row*27,548,634)
 var size_delta:int={"Small":-2,"Normal":0,"Large":3}.get(g.audio_settings.get("combat_text_size","Normal"),0)
 var emphasized:bool=critical and g.audio_settings.get("combat_crit_emphasis",true)
 var minimum:float=548 if g.enemy_encounter.active else 412 if player else maxf(412,preload("res://combat_presentation.gd").cue_label_rect(g).end.y+30)
 if not g.enemy_encounter.active:
  # Apply the reserved cue boundary before slot spacing. Clamping every slot
  # afterwards collapsed several damage lines onto the same baseline.
  var base_y:float=clampf(origin.y+(34 if player else -48),minimum,586 if player else 474)
  pos.y=base_y+count*26
 var min_y:float=548 if g.enemy_encounter.active else maxf(minimum,pos.y-12)
 pos.y=maxf(pos.y,min_y)
 var receipt:Dictionary
 if not g.combat_number_pool.is_empty():receipt=g.combat_number_pool.pop_back()
 else:receipt={};g.combat_number_allocations+=1
 var duration:=1.10 if emphasized else .90
 receipt.merge({"min_y":min_y,"number_kind":kind,"slot":count,"pack_row":pack_row,"serial":serial,"amount":amount,"hits":1,"age":0.0,"critical":critical,"emphasized":emphasized,"priority":priority,"text":text(kind,amount),"pos":pos,"origin":pos,"color":Color(COLORS.get(kind.trim_suffix("_tick"),"#eef3ff")),"size":((17 if emphasized else 14) if g.enemy_encounter.active else (20 if emphasized else 16))+size_delta,"life":duration,"max_life":duration,"lane":"player" if player else "damage"})
 g.floating_texts.append(receipt)
static func step(g, item: Dictionary, delta: float) -> void:
 item.age+=delta
 if not g.audio_settings.get("cinematic_reduced_motion",false):
  var speed:=23.0 if g.audio_settings.get("combat_text_mode","Standard")=="Expressive" else 15.0
  item.pos.y=maxf(float(item.get("min_y",402)),float(item.origin.y)-float(item.age)*speed)
static func draw(g, item: Dictionary) -> void:
 var alpha:=clampf(float(item.life)/.24,0,1)
 var font:Font=preload("res://lootlings_typography.gd").bold()
 var font_size:int=item.size
 if g.audio_settings.get("combat_text_mode","Standard")=="Expressive" and not g.audio_settings.get("cinematic_reduced_motion",false):font_size+=roundi(3*maxf(0,1-float(item.age)/.16))
 font_size=preload("res://lootlings_ui.gd").fitted_font_size(font,item.text,390 if item.emphasized and item.number_kind!="critical" else 425,font_size,11)
 var width:=font.get_string_size(item.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
 var badge:bool=item.emphasized and item.number_kind!="critical"
 var total_width:float=width+(35 if badge else 0)
 var pos:=Vector2(clampf(float(item.pos.x)-total_width*.5,10,470-total_width),item.pos.y)
 var color:Color=item.color;color.a=alpha
 g.draw_string_outline(font,pos,item.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,3,Color(.015,.025,.055,alpha))
 g.draw_string(font,pos,item.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)
 # Elemental colour stays intact; gold is a discrete critical accent.
 if badge:
  var accent:=pos+Vector2(width+6,-2)
  g.draw_string_outline(font,accent,"CRIT",HORIZONTAL_ALIGNMENT_LEFT,-1,11,2,Color(.015,.025,.055,alpha))
  g.draw_string(font,accent,"CRIT",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color(1,.86,.48,alpha))
