"""Add bounded layered impacts from the existing verified CC0 source cache.

Keeps all prior banks and source records. No downloads, voice replacements or music changes.
"""
import json,sys
from pathlib import Path
from build_sound_bank import ROOT,OUT,RATE,source,mix,save,noise,records
families={
 'greatsword':('impactMetal_heavy',.80,.34), 'greataxe':('impactPlate_heavy',.88,.32),
 'maul':('impactPunch_heavy',.67,.43), 'spear':('impactMetal_light',1.30,.18),
 'daggers':('impactMetal_light',1.52,.13), 'claws':('impactSoft_medium',1.34,.16),
 'bow':('impactWood_light',1.24,.19), 'crossbow':('impactWood_medium',1.12,.23),
 'sling':('impactMining',1.18,.25), 'staff':('impactGlass_medium',.85,.36),
 'wand':('impactGlass_light',1.38,.22), 'orb':('impactGlass_heavy',.74,.42)}
materials={'flesh':('impactPunch_medium',.95,.18),'armour':('impactMetal_medium',1.12,.22),'stone':('impactMining',.86,.27),'wood':('impactWood_medium',1.05,.21),'glass':('impactGlass_light',1.17,.32),'molten':('impactSoft_heavy',.72,.33),'ethereal':('impactGlass_light',.64,.38)}
def pick(stem,index,speed):
 from build_sound_bank import SOURCE
 names=sorted(p.stem for p in (SOURCE/'impact').rglob('*.ogg') if p.stem.startswith(stem))
 if not names: raise ValueError(stem)
 return source('impact',names[index%len(names)],speed)
for group,table in [('weapon',families),('contact',materials)]:
 for key,(stem,speed,duration) in table.items():
  for i in range(4):
   x,c=pick(stem,i,speed*(1+(i-1.5)*.017))
   parts=[(x,.75,0)]
   if group=='weapon':
    weight='fire' if key in ['maul','greataxe','greatsword'] else 'ward' if key in ['staff','wand','orb'] else 'air'
    parts.append((noise(4800+i+sum(map(ord,key)),duration,weight),.18,.006))
   elif key in ['molten','ethereal']:
    parts.append((noise(5700+i,duration,'fire' if key=='molten' else 'ward'),.30,.02))
   save(f'{group}_{key}',i,mix(parts,duration),[c])
for key,(stem,speed,duration) in {'thorn':('impactWood_medium',.9,.36),'root':('impactWood_heavy',.65,.58),'mirror':('impactGlass_heavy',.7,.64),'recover':('impactSoft_medium',.85,.30)}.items():
 for i in range(4):
  x,c=pick(stem,i,speed)
  air=noise(6500+i,duration,'ward' if key=='mirror' else 'fire')
  save('verdant_'+key,i,mix([(x,.65,.04),(air,.35,0)],duration),[c])
for event,stem,speed,duration in [('relic_red','impactBell_heavy',.68,1.15),('draw_bow','impactWood_light',.74,.18),('charge_staff','impactGlass_light',.84,.23)]:
 x,c=pick(stem,0,speed)
 parts=[(x[::-1] if event in ['draw_bow','charge_staff'] else x,.5,0)]
 credits=[c]
 if event=='relic_red':
  y,d=pick('impactGlass_heavy',1,.93); z,e=pick('impactMetal_heavy',2,.66)
  parts.extend([(y,.4,.13),(z,.45,.015),(noise(8092,duration,'ward'),.18,.02)]); credits.extend([d,e])
 save(event,0,mix(parts,duration),credits)
manifest=OUT/'sources.json'
previous=json.loads(manifest.read_text(encoding='utf-8'))
newnames={r['asset'] for r in records}
previous['assets']=[r for r in previous['assets'] if r['asset'] not in newnames]+records
previous['phase4e']='Original layered weapon/material/guardian design using the preserved CC0 Kenney impact source hashes. Four subtle variants each; no human vocal layer.'
manifest.write_text(json.dumps(previous,indent=2)+'\n',encoding='utf-8')
print('Added',len(records),'bounded original layered impacts; preserved prior bank')

