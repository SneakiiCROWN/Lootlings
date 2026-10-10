from pathlib import Path
from collections import Counter
import json,hashlib,shutil
from PIL import Image
R=Path.cwd();C=R/'docs/production/full-completion/continuous-production';E=R/'docs/production/quality-evidence/0.4.51'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
M=R/'art/production_npc_manifest.json';data=read(M);rows=[x for x in data['entries'] if x['actor']=='pack_peddler'];slots={x['contract_slot_id'] for x in rows};assert len(slots)==10
probes=read(R/'.godot_test_data/peddler-051/PROBES.json');assert len(probes['probes'])==30 and not probes['failures'];assert Counter(x['slot_id'] for x in probes['probes'])==Counter({s:3 for s in slots})
log=R/'.godot_test_data/qa_logs/peddler051-final-b501c71226/peddler_051_native_qa.log';text=log.read_text();assert 'PEDDLER 051 NATIVE PASS' in text and 'ERROR:' not in text
queue=read(C/'EXACT_REMAINING_CONTRACTS.json');contracts={x['slot_id']:x for x in queue};assert slots<=contracts.keys();before=read(C/'CONTINUOUS_PRODUCTION_COUNTS.json');assert len(queue)==before['remaining_contracts']==2767
for row in rows:
 asset=R/row['asset_path'].removeprefix('res://');im=Image.open(asset);assert im.mode=='RGBA' and im.size==tuple(row['canvas']);assert sha(R/row['authored_source'])==row['authored_source_sha256']
 row.update(native_validated=True,production_status='canon_validated_runtime',native_qa='peddler051-final-b501c71226',visual_acceptance='Dedicated approved brown Pack Peddler subset compared; ten actual native state/view frames reviewed on three layouts. True transparent isolated bodies, complete tails/feet/hats/packs, canonical amber face/travel costume. Basic service keyframes and breathing; fluid locomotion/professional acceptance remain open.')
 metadata=asset.with_suffix('.json');write(metadata,row)
 req=contracts[row['contract_slot_id']];source=Image.new('RGBA',(1024,1536));region=row['content_rect'];pixels=im.crop((16,16,16+region[2],16+region[3]));pos=(512-pixels.width//2,1504-pixels.height);assert min(pos)>=16;source.alpha_composite(pixels,pos)
 target=R/req['source_delivery_path'];target.parent.mkdir(parents=True,exist_ok=True);assert not target.exists();source.save(target)
 delivery=row.copy();delivery.update(canvas=[1024,1536],pivot=[512,1504],content_rect=[pos[0],pos[1],pixels.width,pixels.height],asset_sha256=sha(target),runtime_asset_sha256=sha(asset));write(R/req['source_metadata_path'],delivery)
write(M,data)
files=sum(len(contracts[s]['required_files']) for s in slots);assert files==20
after=before.copy();after['installed_contracts']+=10;after['remaining_contracts']-=10;after['installed_artist_files']+=20;after['remaining_artist_files']-=20;after['installed_by_category']['npcs']+=10;after['remaining_by_category']['npcs']-=10;after['latest_npc_revision']='0.4.51: ten Pack Peddler rest/talk/offer/inspect/return keyframes both facings, actual roadside shop activity and passive grounded service presentation. Route/walk, articulated fluid motion and professional acceptance remain open.'
write(C/'CONTINUOUS_PRODUCTION_COUNTS.json',after);write(C/'EXACT_REMAINING_CONTRACTS.json',[x for x in queue if x['slot_id'] not in slots])
receipt=dict(version='0.4.51',verified_contracts_closed=10,slot_ids=sorted(slots),new_runtime_png=10,new_sidecars=10,required_artist_files_fulfilled=20,native_probes=30,complete_fluid_animation_families=0,professional_acceptance=False,default_live_facing='right',left_facing='Registered and native fixture reviewed; not chosen by current roadside header',rejected_cells=10,correction_results='Five wrong-costume right candidates replaced; five wrong-facing correction cells excluded. Approved woodland Pack Peddler and aquatic Merrow kept distinct.')
write(C/'PEDDLER_INSTALLATION_0451.json',receipt);write(E/'PEDDLER_INSTALLATION_RECEIPT.json',receipt);shutil.copyfile(log,E/log.name);write(E/'PEDDLER_PROBES.json',probes)
evidence=read(R/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json');assert not any(x['slot_id'] in slots for x in evidence['entries'])
for row in rows:
 evidence['entries'].append(dict(slot_id=row['contract_slot_id'],asset=row['asset_path'].removeprefix('res://'),asset_sha256=row['asset_sha256'],stages=dict(canon_reference_approved=True,created=True,integrated=True,functionally_tested=True,gameplay_visual_reviewed=True,player_experience_reviewed=True,production_quality_accepted=False),evidence_files=['docs/production/quality-evidence/0.4.51/PEDDLER_PROBES.json','docs/production/quality-evidence/0.4.51/peddler_051_native_qa.log'],limitations='Basic service keyframes and subtle breathing; not a fluid articulated sequence. Full-game and physical device artistic acceptance remain open.',defects=[]))
write(R/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json',evidence)
combined=read(E/'INSTALLATION_RECEIPT.json');combined['verified_contracts_closed']=41;combined['new_runtime_png']=42;combined['new_physical_artist_files']=83;combined['frozen_artist_file_requirements_fulfilled']=113;combined.setdefault('other_installed_features',[]).append('Ten canonical Pack Peddler service keyframes both facings, grounded live roadside-shop activity, restored readable per-offer benefits; purchases/economy/touch guards preserved.');combined['merchant_batch']=receipt;write(E/'INSTALLATION_RECEIPT.json',combined)
for view in ['1080x2340','1600x2560','1920x1080']:
 for name in ['selected_offer_reduced_motion.png','rest_right.png','inspect_left.png']:
  shutil.copyfile(R/f'.godot_test_data/peddler-051/{view}/{name}',E/f'peddler_{view}_{name}')
shutil.copyfile(R/'.godot_test_data/peddler-051/1080x2340_states.jpg',E/'peddler_native_states.jpg')
print('Accepted 10 native merchant contracts / 20 requirements; total new41, remaining',after['remaining_contracts'],after['remaining_artist_files'])
