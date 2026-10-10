from pathlib import Path
import json,importlib.util,hashlib
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];source=ROOT/'art/source/resident_044';source.mkdir(parents=True,exist_ok=True)
p=source/'sera_states.png';original=Path(r'C:/Users/Snkii/.codex/generated_images/01a119ec-aee5-7460-8419-3c1df0c7363f/exec-1754d5c5-b09b-48e4-b425-ae6bd3a2c47c.png')
if not p.exists():p.write_bytes(original.read_bytes())
spec=importlib.util.spec_from_file_location('components',ROOT/'tools/sheet_alpha_components.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
cells=mod.components(p);w,h=Image.open(p).size;assert len(cells)==7
left=source/'sera_rest_left_corrected.png'
if not left.exists():left.write_bytes(Path(r'C:/Users/Snkii/.codex/generated_images/01a119ec-aee5-7460-8419-3c1df0c7363f/exec-5114553f-d2be-4ca6-9c46-6dbf78384344.png').read_bytes())
leftc=mod.components(left);assert len(leftc)==1
selected={1:cells[1],2:cells[2],4:leftc[0],5:cells[4],6:cells[5]}
print('Sera source bounds',[c['bounds'] for c in cells])
old=ROOT/'art/sprites/npcs/beta/sera_idle.png';oldc=max(mod.components(old),key=lambda c:c['area']);print('Existing Sera reuse bounds',oldc['bounds'])
scale=min(960/max(c['bounds'][2]-c['bounds'][0] for c in [cells[1],cells[2],cells[4],cells[5]]),1472/max(c['bounds'][3]-c['bounds'][1] for c in [cells[1],cells[2],cells[4],cells[5]]))
rows=[];jobs=[]
for i in [0,1,2,4,5,6]:
 state=['rest','talk','inspect','sit'][i%4];face='right' if i<4 else 'left';asset=f'art/production/phase4e/npcs/sera/sera_{state}_{face}.png';(ROOT/asset).parent.mkdir(parents=True,exist_ok=True)
 if i==0:
  asset='art/sprites/npcs/beta/sera_idle.png';b=oldc['bounds'];rect=[b[0],b[1],b[2]-b[0],b[3]-b[1]];pivot=[512,b[3]];authored=old
 else:
  c=selected[i];b=c['bounds'];authored=left if i==4 else p;sw,sh=Image.open(authored).size;assert b[0]>0 and b[1]>0 and b[2]<sw and b[3]<sh
  local_scale=min(960/(b[2]-b[0]),1472/(b[3]-b[1])) if i==4 else scale
  size=[round((b[2]-b[0])*local_scale),round((b[3]-b[1])*local_scale)];offset=[(1024-size[0])//2,1504-size[1]];rect=offset+size;pivot=[512,1504]
  jobs.append(dict(source=authored.relative_to(ROOT).as_posix(),bounds=b,runs=c['runs'],scaled_size=size,offset=offset,asset=asset))
 rows.append(dict(actor='sera',state=state,facing=face,asset_path='res://'+asset,canvas=[1024,1536],content_rect=rect,pivot=pivot,source_reference='art/sprites/npcs/beta/sera_idle.png',source_sha256=hashlib.sha256(old.read_bytes()).hexdigest(),authored_source=authored.relative_to(ROOT).as_posix(),authored_source_sha256=hashlib.sha256(authored.read_bytes()).hexdigest(),production_status='awaiting_native_visual_review',native_validated=False,contract_slot_id=f'pose:sera:{state}:{face}:None',metadata_path=f'art/production/phase4e/npcs/sera/sera_{state}_{face}.json',full_animation_family_accepted=False,anatomy_mirroring=False))
manifest=ROOT/'art/production_npc_manifest.json';data=json.loads(manifest.read_text());assert not any(r['actor']=='sera' for r in data['entries']);data['entries']+=rows;manifest.write_text(json.dumps(data,indent=2)+'\n')
for row in rows:(ROOT/row['metadata_path']).write_text(json.dumps(row,indent=2)+'\n')
(source/'EXPORT_JOBS.json').write_text(json.dumps(dict(exports=jobs),indent=2)+'\n')
(source/'CORRECTION_QUEUE.json').write_text(json.dumps(dict(staged_not_installed=[dict(cell=3,reason='Seated pose requires an actual fitted chair/bench interaction context; cannot float in Hub shrine'),dict(cell=7,reason='Seated pose requires an actual fitted chair/bench interaction context; cannot float in Hub shrine')],reuse=[dict(cell=0,reason='Existing approved rest-right source reused; generated duplicate excluded')]),indent=2)+'\n')
print('Sera staged: five new PNG, six exact state/view slots; original rest-right reused, seated/route/work left outstanding.')