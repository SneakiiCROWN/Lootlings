extends RefCounted
# Deterministic, presentation-only background detail. No nodes, RNG or hitboxes.
const PALETTES={
 "act_i":Color(.65,.91,.72,.16),"mossglass_wilds":Color(.55,.85,.52,.24),
 "moonfen":Color(.6,.9,.87,.3),"frostbell_hollows":Color(.8,.94,1,.28),
 "sunken_gearworks":Color(.65,.8,.86,.07),"cinder_crown":Color(1,.55,.19,.3),
 "starfall_archive":Color(.75,.74,1,.24),"nullglass_expanse":Color(.5,.85,1,.18),
 "skyhook_bastion":Color(.86,.96,1,.12),"first_hoard":Color(1,.83,.35,.22)}
static func points(region: String, time: float, reduced: bool=false) -> Array[Vector2]:
 var result:Array[Vector2]=[]
 if reduced or not PALETTES.has(region):return result
 for i in range(6):
  var x:float=28+i*82+sin(time*.35+i*1.7)*9
  # Keep ambience above the combat silhouettes and below the HUD.
  var y:float=322+fmod(time*(5+i*.35)+i*19,98.0)
  if region in ["cinder_crown","first_hoard","moonfen"]:y=420-fmod(time*(5+i*.35)+i*19,98.0)
  result.append(Vector2(clampf(x,18,462),y))
 return result
static func draw(canvas, region: String, time: float, reduced: bool=false) -> void:
 var motes:=points(region,time,reduced)
 if motes.is_empty():return
 var color:Color=PALETTES[region]
 for i in range(motes.size()):
  var point:Vector2=motes[i]
  var tint:=color;tint.a*=.45+.55*absf(sin(time*.6+i))
  match region:
   "sunken_gearworks":canvas.draw_circle(point,6+i%2,tint)
   "skyhook_bastion":canvas.draw_line(point,point+Vector2(10,0),tint,1,true)
   "mossglass_wilds","act_i":
    canvas.draw_line(point,point+Vector2(3,sin(time*.8+i)*2),tint,2,true)
   "starfall_archive","nullglass_expanse":
    canvas.draw_line(point-Vector2(2,0),point+Vector2(2,0),tint,1,true)
    canvas.draw_line(point-Vector2(0,2),point+Vector2(0,2),tint,1,true)
   _:canvas.draw_circle(point,1.2 if region=="frostbell_hollows" else 1.5,tint)
