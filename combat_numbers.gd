extends RefCounted
# Typed, bounded presentation receipts. Amounts come from resolved gameplay only.
const COLORS={"Physical":"#eef3ff","Fire":"#ffb46b","Ice":"#91e7ff","Lightning":"#dfbcff","Poison":"#a6ec80","Nature":"#b5e99b","enemy_heal":"#91e7ba","heal":"#80e7b6","ward":"#91ddff","armour":"#c1c9df","incoming":"#ff9aa5"}
static func text(kind: String, amount: float, hits: int=1) -> String:
 var value := "<0.01" if amount<.01 else ("%.2f" if amount<1 else "%.1f" if amount<10 else "%.0f") % amount
 var label: String={"Physical":"HIT","critical":"CRIT!","heavy":"HEAVY","enemy_heal":"MEND +","heal":"HP +","ward":"WARD BLOCK","armour":"ARMOUR BLOCK","incoming":"HP −","Fire_tick":"BURN","Poison_tick":"POISON"}.get(kind,kind.to_upper())
 return "%s %s%s" % [label,value," ×%d" % hits if hits>1 else ""]
static func add(g, amount: float, kind: String, player: bool=false) -> void:
 if amount<=0.0001:return
 var serial: int=-1 if player else g.enemy_serial
 for item in g.floating_texts:
  if item.get("number_kind","")==kind and item.get("serial",-2)==serial and float(item.get("age",1))<.26:
   item.amount+=amount;item.hits+=1;item.text=text(kind,item.amount,item.hits);item.life=minf(.94,float(item.life)+.08);return
 var local:Array=g.floating_texts.filter(func(x):return x.has("number_kind") and x.serial==serial)
 while local.size()>=3:g.floating_texts.erase(local.pop_front())
 var count:int=0
 while local.any(func(x):return int(x.get("slot",-1))==count):count+=1
 var pos:Vector2=preload("res://weapon_fit_catalog.gd").world_position(g) if player else g.target_combat_visual_position()
 # Below faces/nameplates and above controls. Separate both actors' columns.
 pos=Vector2(clampf(pos.x,85,395),538+(count%3)*23)
 var color:Color=Color(COLORS.get(kind.trim_suffix("_tick"),"#ffe593"))
 if kind=="critical":color=Color("#ffe593")
 var receipt={"number_kind":kind,"slot":count,"serial":serial,"amount":amount,"hits":1,"age":0.0,"text":text(kind,amount),"pos":pos,"color":color,"size":19 if kind=="critical" else 14,"life":.86,"max_life":.86,"lane":"player" if player else "damage"}
 g.floating_texts.append(receipt)
 var typed:Array=g.floating_texts.filter(func(x):return x.has("number_kind"))
 while typed.size()>8:g.floating_texts.erase(typed.pop_front())
