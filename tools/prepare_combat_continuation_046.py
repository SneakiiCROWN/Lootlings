from pathlib import Path
import json,hashlib,importlib.util
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'art/source/combat_continuation_046'
MANIFEST=ROOT/'art/production/phase4e/player_combat_046_manifest.json'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,o):p.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
if MANIFEST.exists() and any(r.get('native_validated') for r in read(MANIFEST)['entries']):raise SystemExit('Accepted assets protected; stage corrections separately.')
spec=importlib.util.spec_from_file_location('components',ROOT/'tools/sheet_alpha_components.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
def cells(file,columns):
 w,h=Image.open(file).size
 return sorted(mod.components(file,min_alpha=0),key=lambda c:(int((c['bounds'][1]+c['bounds'][3])/2>=h/2),int((c['bounds'][0]+c['bounds'][2])/2/w*columns)))
# Exact source contact pixels in the visibly closed palms. Not inferred board sockets.
contacts={
 'emberhorn':[
 [[283,321],[324,318]],[[513,164],[548,141]],[[1084,388],[1121,390]],[[1451,282],[1480,276]],
 [[129,789],[88,788]],[[640,608],[609,586]],[[879,847],[839,852]],[[1280,748],[1248,742]]],
 'pebblewyrm':[
 None,None,[[1048,390],[1096,401]],[[1445,301],[1480,301]],
 None,None,[[872,864],[829,863]],[[1303,775],[1265,775]]]}
queue=read(ROOT/'docs/production/full-completion/continuous-production/EXACT_REMAINING_CONTRACTS.json')
remaining={r['slot_id'] for r in queue};jobs=[];entries=[];rejected=[]
canons={'emberhorn':'Emberhorn_CharacterSheet_Canonical.png','pebblewyrm':'Pebblewyrm_CharacterSheet_Canonical.png'}
for actor in contacts:
 source=SOURCE/(actor+'_gutter_corrected.png');cs=cells(source,4);assert len(cs)==8,(actor,len(cs))
 scale=min(472/max(c['bounds'][3]-c['bounds'][1] for c in cs),472/max(c['bounds'][2]-c['bounds'][0] for c in cs))
 for i,c in enumerate(cs):
  if contacts[actor][i] is None:
   rejected.append(dict(actor=actor,cell=i,reason='Second grip hidden or paws not co-linear; cannot accept modular two-hand contact.'));continue
  b=c['bounds'];size=[round((b[2]-b[0])*scale),round((b[3]-b[1])*scale)];offset=[round((512-size[0])/2),496-size[1]]
  palms=contacts[actor][i]
  mapped=[[offset[0]+(x-b[0])*size[0]/(b[2]-b[0]),offset[1]+(y-b[1])*size[1]/(b[3]-b[1])] for x,y in palms]
  face='right' if i<4 else 'left';state=['idle','windup','strike_or_cast','hurt'][i%4];phase={'idle':'IDLE','windup':'ANTICIPATE','strike_or_cast':'ATTACK','hurt':'HURT'}[state]
  dest=f'art/production/phase4e/lootlings/{actor}/combat_046/{actor}_{state}_{face}.png';grip=dest.replace('.png','_grip_front.png');(ROOT/dest).parent.mkdir(parents=True,exist_ok=True)
  jobs.append(dict(source=source.relative_to(ROOT).as_posix(),bounds=b,runs=c['runs'],source_primary=palms[0],source_secondary=palms[1],grip_radius=15,scaled_size=size,offset=offset,canvas=[512,512],asset=dest,foreground=grip))
  for weapon in ['greatsword','greataxe','maul']:
   slot=f'pose:{actor}:{state}:{face}:{weapon}'
   if slot not in remaining:continue
   e=dict(actor=actor,asset_path='res://'+dest,foreground_layer='res://'+grip,metadata_path=dest.replace('.png','_'+weapon+'.json'),baked_weapon='',baseline_y=496,body_rect=[-96,-128,192,192],canvas=[512,512],contract_slot_id=slot,core_anchor=[.5,.55],draw_depth='front',facing=face+'_only',feet_baseline=58,frame_count=1,frame_index=0,fps=0,identity_authority=['art/reference/canonical/characters/'+canons[actor]],mirroring_allowed=False,native_validated=False,phase=phase,primary_anchor=[v/512 for v in mapped[0]],secondary_anchor=[v/512 for v in mapped[1]],source=source.relative_to(ROOT).as_posix(),source_bounds=b,source_primary=palms[0],source_secondary=palms[1],source_sha256=sha(source),state=state,supports_two_hand=True,wardrobe_requires={},weapon_types=[weapon],weapon_overrides={},production_status='awaiting_native_visual_review')
   entries.append(e)
enemy_entries=[];authority='art/reference/phase4e_handoff/chatgpt_generated_candidates/regional_candidates/batch01_verdant_marshes.png'
for face,filename in [('right','dew_hexer_candidate.png'),('left','dew_hexer_left_corrected.png')]:
 source=SOURCE/filename;cs=cells(source,3);assert len(cs)==6
 for i,c in enumerate(cs):
  state=['idle','role windup','role commit','hurt','recovery','defeat'][i]
  if face=='right' and i in [1,3]:
   rejected.append(dict(actor='dew_hexer',cell=i,facing=face,reason='Staff grip not visible/continuous; retain open for correction.'));continue
  b=c['bounds'];dest=f'art/production/phase4e/enemies/dew_hexer/combat_046/dew_hexer_{state.replace(' ','_')}_{face}.png';(ROOT/dest).parent.mkdir(parents=True,exist_ok=True)
  size=[b[2]-b[0],b[3]-b[1]];offset=[(1024-size[0])//2,992-size[1]]
  jobs.append(dict(source=source.relative_to(ROOT).as_posix(),bounds=b,runs=c['runs'],source_primary=[0,0],grip_radius=0,scaled_size=size,offset=offset,canvas=[1024,1024],asset=dest,foreground=''))
  e=dict(actor='dew_hexer',state=state,facing=face,asset_path='res://'+dest,canvas=[1024,1024],content_rect=offset+size,native_pixel_scale=.26,source_reference=authority,source_sha256=sha(ROOT/authority),authored_source=source.relative_to(ROOT).as_posix(),authored_source_sha256=sha(source),authored_source_bounds=b,production_status='awaiting_native_visual_review',native_validated=False,contract_slot_id=f'pose:dew_hexer:{state}:{face}:None',fixed_enemy_blade='Canonical intrinsic wood staff and dew lantern, not modular player weapon.',feet_baseline_normalized=.96875,anchor=[.5,.96875],metadata_path=dest.replace('.png','.json'))
  enemy_entries.append(e)
write(MANIFEST,dict(entries=entries,production_quality_accepted=False))
write(SOURCE/'ENEMY_CANDIDATE_MANIFEST.json',dict(entries=enemy_entries))
write(SOURCE/'EXPORT_JOBS.json',dict(exports=jobs))
rejected.append(dict(actor='dew_hexer',source='dew_hexer_left_rejected_tail.png',cells=6,reason='Oversized fluffy tail drift; replaced by canon-tail correction, original retained.'))
write(SOURCE/'CORRECTION_QUEUE.json',dict(cells=rejected))
print('STAGED',len(entries),'player contracts',len(enemy_entries),'enemy cells',len(jobs),'bodies. No closures yet.')
