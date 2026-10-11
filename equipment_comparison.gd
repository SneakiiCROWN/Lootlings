extends RefCounted
# Read-only preview; cloned gear, real combat formula helpers, no RNG or equip.
const Items=preload("res://item_catalog.gd")
const Inventory=preload("res://inventory_system.gd")
static func stats(game,gear) -> Dictionary:
 var hp_max:float=maxf(40,game.player_max_hp+gear.effect_total("max_hp")-game.equipment_hp_bonus)
 var hp:float=clampf(game.player_hp+maxf(0,gear.effect_total("max_hp")-game.equipment_hp_bonus),1,hp_max)
 var family:String=game.comparison_weapon_family(gear)
 var mitigation:float=minf(.72,game.armor+gear.effect_total("armor")+(.04 if family=="VANGUARD" else 0))
 return {"Base strike power":game.base_damage*game.equipment_damage_multiplier(gear,hp,hp_max),"Auto-attack delay":game.current_attack_interval(gear,hp,hp_max),"Critical chance":game.effective_crit_chance(gear)*100,"Maximum HP":hp_max,"Armour mitigation":mitigation*100,"Incoming damage factor":(1-mitigation)*(1+gear.effect_total("incoming_mult"))}
static func card(item:Dictionary,heading:String) -> String:
 if item.is_empty():return "[b]%s[/b]\nEmpty slot" % heading
 var picture:Texture2D=preload("res://lootlings_ui.gd").raw_item_texture(item)
 var icon:String="[img=28x28]%s[/img] " % picture.resource_path if picture!=null and picture.resource_path.begins_with("res://") else ""
 var result:String="[b]%s[/b]\n%s%s\n%s · %s" % [heading,icon,item.get("name","Item"),item.get("rarity","COMMON"),Items.display_identity(item)]
 # Full signature text is listed with gained/lost effects below.
 return result
static func text(game,found:Dictionary,equipped:Dictionary) -> String:
 var before=Inventory.new();before.equipped=game.inventory.equipped.duplicate(true)
 var after=Inventory.new();after.equipped=before.equipped.duplicate(true);after.equipped[str(found.get("slot","Weapon"))]=found.duplicate(true)
 var old_stats:=stats(game,before);var new_stats:=stats(game,after)
 var current:=card(equipped,"CURRENTLY EQUIPPED");var inspected:=card(found,"INSPECTING")
 var result:String="[table=2][cell]%s[/cell][cell]%s[/cell][/table]" % [current,inspected] if game.get_window().size.x>game.get_window().size.y else current+"\n\n"+inspected
 result+="\n\n[b]EFFECTIVE IF EQUIPPED[/b]\nCurrent encounter and health conditions; excludes untriggered procs.\n"
 for key in old_stats:
  var a:float=old_stats[key];var b:float=new_stats[key];var delta:float=b-a
  var lower_is_better:bool=key in ["Auto-attack delay","Incoming damage factor"]
  var gain:bool=delta<0 if lower_is_better else delta>0
  var color:String="#c7d4ee" if absf(delta)<.00001 else "#69e6b0" if gain else "#ff7d88"
  var unit:String="s" if key=="Auto-attack delay" else "%" if key in ["Critical chance","Armour mitigation"] else "×" if key=="Incoming damage factor" else ""
  var delta_unit:String=" pp" if unit=="%" else unit
  result+="[color=%s]%s: %.2f%s → %.2f%s | %+.2f%s %s[/color]\n" % [color,key,a,unit,b,unit,delta,delta_unit,"SAME" if absf(delta)<.00001 else "▲ BETTER" if gain else "▼ WORSE"]
 result+="Caps: attack delay ≥ 0.16s · critical chance ≤ 85% · armour ≤ 72% · HP ≥ 40.\n\n[b]ALL ITEM EFFECT CHANGES[/b]\n"
 var keys:Array=found.get("effects",{}).keys()
 for key in equipped.get("effects",{}):
  if key not in keys:keys.append(key)
 keys.sort()
 for key in keys:
  var a:float=float(equipped.get("effects",{}).get(key,0));var b:float=float(found.get("effects",{}).get(key,0))
  if key=="coin_mult":
   result+="Expedition XP: %.2f%% → %.2f%% | %+.2f pp\nSiege Embers: %.2f%% → %.2f%% | %+.2f pp\n" % [a*25,b*25,(b-a)*25,a*100,b*100,(b-a)*100]
   continue
  var unit:String=" HP" if key=="max_hp" else " stacks" if key=="poison_bonus" else " attacks" if key=="repeat_every" else "%"
  var factor:float=1 if unit!="%" else 100
  result+="%s: %.2f%s → %.2f%s | %+.2f%s %s\n" % [str(key).replace("_"," ").capitalize(),a*factor,unit,b*factor,unit,(b-a)*factor," pp" if unit=="%" else unit,"REMOVED" if b==0 and a!=0 else "ADDED" if a==0 and b!=0 else ""]
  if key=="attack_slow" and b!=a:result+="%s attack delay from this item bonus.\n" % ("more" if b>a else "less")
  if key=="incoming_mult" and b!=a:result+="%s damage taken from this item bonus.\n" % ("more" if b>a else "less")
 result+="Item bonuses above are additive; effective totals include their limits.\n"
 var old_hooks:Array=equipped.get("signature_hooks",[]);var new_hooks:Array=found.get("signature_hooks",[])
 if not old_hooks.is_empty():
  result+="\n[b]CURRENT SIGNATURES[/b]\n"
  for hook in old_hooks:result+=signature_description(str(hook))+"\n"
 if not new_hooks.is_empty():
  result+="\n[b]INSPECTING SIGNATURES[/b]\n"
  for hook in new_hooks:result+=signature_description(str(hook))+"\n"
 for hook in old_hooks:
  if hook not in new_hooks:result+="[color=#ff7d88]▼ LOSES: %s[/color]\n" % signature_description(str(hook))
 for hook in new_hooks:
  if hook not in old_hooks:result+="[color=#69e6b0]▲ GAINS: %s[/color]\n" % signature_description(str(hook))
 result+="\nStash %d / %d. " % [game.inventory.stash.size(),game.inventory.stash_capacity]
 if equipped.is_empty() or int(equipped.get("serial",0))==-1:result+="No owned item will be displaced."
 elif game.inventory.stash.size()<game.inventory.stash_capacity or game.inventory.stash.any(func(item):return int(item.get("serial",-9))==int(found.get("serial",-8))):result+="Replaced gear returns to your stash."
 else:result+="[color=#ff7d88]FULL STASH: equipping new loot can scrap current gear. Review the confirmation or make space first.[/color]"
 return result

static func signature_description(hook:String) -> String:
 for id in preload("res://affix_catalog.gd").SIGNATURES:
  var entry:Dictionary=preload("res://affix_catalog.gd").SIGNATURES[id]
  if str(entry.hook)==hook:return str(entry.name)+" — "+str(entry.text)
 return hook.replace("_"," ").capitalize()
