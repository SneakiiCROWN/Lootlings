"""Regional attack identities from the preserved CC0 cache, with source hashes.

No vocal replacement, synthesis service, downloads or changes to older assets.
"""
import json
from build_sound_bank import SOURCE,OUT,source,mix,save,noise,records

FAMILIES={
 'chime':('impactBell_heavy',.88,.62,'spark'),
 'steam':('impactPlate_heavy',.77,.55,'air'),
 'chain':('impactMetal_medium',.93,.48,'air'),
 'ink':('impactSoft_medium',.83,.42,'ward'),
 'furnace':('impactMetal_heavy',.70,.58,'fire'),
 'crown':('impactBell_heavy',.68,.68,'ward'),
 'prowler':('impactSoft_heavy',.84,.32,'air'),
 'reflection':('impactGlass_heavy',.81,.62,'spark'),
}
for family,(stem,speed,duration,layer) in FAMILIES.items():
    names=sorted(p.stem for p in (SOURCE/'impact').rglob('*.ogg') if p.stem.startswith(stem))
    if not names: raise ValueError(stem)
    for index in range(4):
        clip,credit=source('impact',names[index%len(names)],speed*(1+(index-1.5)*.018))
        parts=[(clip,.72,.014),(noise(9400+index+sum(map(ord,family)),duration,layer),.28,0)]
        if family=='chain': parts.append((clip,.24,.11))
        if family=='reflection': parts.append((clip[::-1],.18,.18))
        save('boss_'+family,index,mix(parts,duration),[credit])
manifest=OUT/'sources.json'
data=json.loads(manifest.read_text(encoding='utf-8'))
names={record['asset'] for record in records}
data['assets']=[r for r in data['assets'] if r['asset'] not in names]+records
data['phase4e_polish']='Eight regional boss attack families, four source variants each; original licensed layering, no franchise audio.'
manifest.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
print(f'Added {len(records)} documented regional boss cues')
