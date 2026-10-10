from pathlib import Path
import json,hashlib,importlib.util
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
folder=ROOT/'art/source/player_motion_044'
manifest_path=ROOT/'art/production/phase4e/player_motion_044_manifest.json'
if manifest_path.exists() and any(r.get('native_validated') for r in json.loads(manifest_path.read_text())['entries']):raise SystemExit('Verified motion already installed: preserve; do not restage accepted work')
original=Path(r'C:/Users/Snkii/.codex/generated_images/01a119ec-aee5-7460-8419-3c1df0c7363f/exec-7eccaa15-c11e-48b8-a222-048dad9aa819.png')
target=folder/'moonkip_glimmerfin_walk_corrected.png'
if not target.exists():target.write_bytes(original.read_bytes())
spec=importlib.util.spec_from_file_location('components',ROOT/'tools/sheet_alpha_components.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
def grid(file,columns=4):
 w,h=Image.open(file).size
 items=mod.components(file)
 return sorted(items,key=lambda x:(int((x['bounds'][1]+x['bounds'][3])/2>=h/2),int(((x['bounds'][0]+x['bounds'][2])/2)/w*columns)))
actors=['relic_beast','emberhorn','mosskin','pebblewyrm','glimmerfin','moonkip','gloomlet','vault_runner','ruin_warden','nightstage_drifter','velvet_astrologer','ashtrail_hunter']
# Source-pixel centres of visible palms, reviewed on the recovered transparent sheets.
palms={
'relic_beast':[[305,312],[750,313],[1258,347],[1632,391],[177,726],[638,728],[1005,747],[1475,817]],
'emberhorn':[[354,354],[0,0],[1091,370],[1432,436],[64,835],[0,0],[849,840],[1267,889]],
'mosskin':[[359,380],[0,0],[960,355],[1445,444],[65,845],[0,0],[1087,838],[1269,905]],
'pebblewyrm':[[220,326],[586,328],[911,320],[1359,416],[206,793],[612,793],[1047,797],[1326,888]],
'glimmerfin':[[348,348],[0,0],[997,349],[1303,439],[61,810],[0,0],[982,820],[1272,911]],
'moonkip':[[305,366],[0,0],[974,368],[1415,441],[137,845],[0,0],[978,865],[1287,925]],
'gloomlet':[[222,379],[622,379],[979,380],[1355,448],[228,830],[631,835],[1030,850],[1339,918]],
'vault_runner':[[227,219],[568,219],[1043,198],[1340,399],[199,705],[622,700],[1075,678],[1304,897]],
'ruin_warden':[[209,210],[585,217],[1084,287],[1367,416],[191,725],[605,723],[806,762],[1317,908]],
'nightstage_drifter':[[306,208],[647,204],[849,297],[1351,409],[139,720],[513,722],[1088,765],[1291,901]],
'velvet_astrologer':[[266,211],[615,213],[1076,270],[1390,403],[160,713],[546,714],[1090,769],[1279,913]],
'ashtrail_hunter':[[211,215],[587,212],[875,278],[1347,408],[188,709],[596,705],[1056,735],[1320,910]]}
canons={'relic_beast':'Lootlings_Main_Mascot_RelicBeast_Canonical.png','emberhorn':'Emberhorn_CharacterSheet_Canonical.png','mosskin':'Mosskin_CharacterSheet_Canonical.png','pebblewyrm':'Pebblewyrm_CharacterSheet_Canonical.png','glimmerfin':'Glimmerfin_CharacterSheet_Canonical.png','moonkip':'Moonkip_CharacterSheet_Canonical.png','gloomlet':'Gloomlet_CharacterSheet_Canonical.png'}
correction=grid(folder/'walk_correction_group.png');correction2=grid(target,2)
entries=[];jobs=[];queue=[]
for actor in actors:
 source=folder/(actor+'.png');cells=grid(source);assert len(cells)==8
 human=actor not in canons
 canvas=[768,1024] if human else [512,512];baseline=canvas[1]-16
 # Shared scale across each source sheet preserves changes in pose height.
 normal_scale=min((canvas[1]-40)/max(c['bounds'][3]-c['bounds'][1] for c in cells),(canvas[0]-40)/max(c['bounds'][2]-c['bounds'][0] for c in cells))
 if actor in ["moonkip","glimmerfin"]: normal_scale *= .82
 for i,c in enumerate(cells):
  selected_source=source;palm=palms[actor][i];scale=normal_scale
  if actor in ['emberhorn','mosskin','moonkip','glimmerfin'] and i in [1,5]:
   queue.append(dict(actor=actor,source=source.relative_to(ROOT).as_posix(),cell=i,reason='Repeated planted foot; does not form an alternating gait',disposition='replaced by independently reviewed opposite-step cell'))
   if actor in ['emberhorn','mosskin']:
    selected_source=folder/'walk_correction_group.png';j=(0 if actor=='emberhorn' else 1)+(4 if i==5 else 0);c=correction[j]
    palm=([386,339] if i==1 else [48,814]) if actor=='emberhorn' else ([746,335] if i==1 else [441,825])
   else:
    selected_source=target;j=(0 if actor=='moonkip' else 1)+(2 if i==5 else 0);c=correction2[j]
    palm=([607,367] if i==1 else [289,838]) if actor=='moonkip' else ([1251,338] if i==1 else [886,833])
   # Match the corresponding original walk silhouette height, never stretch anatomy.
   scale=normal_scale*(cells[0 if i==1 else 4]['bounds'][3]-cells[0 if i==1 else 4]['bounds'][1])/(c['bounds'][3]-c['bounds'][1])
  b=c['bounds'];assert b[0]>0 and b[1]>0 and b[2]<Image.open(selected_source).width and b[3]<Image.open(selected_source).height
  size=[round((b[2]-b[0])*scale),round((b[3]-b[1])*scale)];offset=[round((canvas[0]-size[0])/2),baseline-size[1]]
  assert min(offset)>=0 and offset[0]+size[0]<canvas[0], (actor,i,b,size,offset)
  face='right' if i<4 else 'left';state=['movement','movement','victory_return','defeat'][i%4];phase={'movement':'MOVE','victory_return':'VICTORY','defeat':'DEFEAT'}[state];frame=i%4 if state=='movement' else 0
  category='wanderers' if human else 'lootlings';stem=f'{actor}_{state}_{face}'+(f'_{frame}' if state=='movement' else '')
  destination=f'art/production/phase4e/{category}/{actor}/motion_044/{stem}.png';grip=destination.replace('.png','_grip_front.png');(ROOT/destination).parent.mkdir(parents=True,exist_ok=True)
  p=[offset[0]+(palm[0]-b[0])*size[0]/(b[2]-b[0]),offset[1]+(palm[1]-b[1])*size[1]/(b[3]-b[1])]
  body_rect=[-96,-128,192,192] if not human else [-80,-149.6,160,220]
  feet=body_rect[1]+baseline/canvas[1]*body_rect[3]
  jobs.append(dict(source=selected_source.relative_to(ROOT).as_posix(),bounds=b,runs=c['runs'],source_primary=palm,grip_radius=12 if human else 19,scaled_size=size,offset=offset,canvas=canvas,asset=destination,foreground=grip))
  weapons=['orb'] if state=='defeat' or (actor=='velvet_astrologer' and state=='victory_return') else ['wand','orb']
  authority=['art/sprites/wanderers/beta/'+actor+'_idle.png'] if human else ['art/reference/canonical/characters/'+canons[actor]]
  for weapon in weapons:
   entry=dict(actor=actor,phase=phase,state=state,facing=face+'_only',weapon_types=[weapon],asset_path='res://'+destination,body_rect=body_rect,primary_anchor=[p[0]/canvas[0],p[1]/canvas[1]],secondary_anchor=[p[0]/canvas[0],p[1]/canvas[1]],core_anchor=[.5,.55],feet_baseline=feet,supports_two_hand=False,foreground_layer='res://'+grip,draw_depth='front',weapon_overrides={},wardrobe_requires={},baked_weapon='',contract_slot_id=f'pose:{actor}:{state}:{face}:{weapon}',source=selected_source.relative_to(ROOT).as_posix(),source_sha256=hashlib.sha256(selected_source.read_bytes()).hexdigest(),source_bounds=b,source_primary=palm,primary_palm=p,canvas=canvas,baseline_y=baseline,frame_index=frame,frame_count=2 if state=='movement' else 1,fps=6 if state=='movement' else 0,identity_authority=authority,native_validated=False,production_status='awaiting_native_visual_review',mirroring_allowed=False,metadata_path=destination.replace('.png','_'+weapon+'.json'),visual_review='Source identity/anatomy/alternate-step/alpha reviewed; runtime contact and quality review pending. Two motion keyframes are not a complete fluid animation.')
   entries.append(entry)
for i in [2,3,6,7]:queue.append(dict(source='art/source/player_motion_044/walk_correction_group.png',cell=i,reason='Moonkip missing original crescent-ear language or Glimmerfin added head circlet; off-model',disposition='quarantined; replaced by identity-preserving correction'))
(folder/'EXPORT_JOBS.json').write_text(json.dumps(dict(exports=jobs),indent=2)+'\n')
(folder/'CORRECTION_QUEUE.json').write_text(json.dumps(dict(cells=queue),indent=2)+'\n')
(ROOT/'art/production/phase4e/player_motion_044_manifest.json').write_text(json.dumps(dict(entries=entries,production_quality_accepted=False),indent=2)+'\n')
print('STAGED',len(jobs),'distinct body frames;',len({r['contract_slot_id'] for r in entries}),'candidate state/view/weapon slots, not closures')