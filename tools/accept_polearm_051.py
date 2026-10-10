"""Accept exact proven contacts; do not declare complete fluid/professional families."""
from pathlib import Path
from collections import Counter
import json,hashlib,shutil
from PIL import Image
R=Path(__file__).resolve().parents[1];C=R/'docs/production/full-completion/continuous-production';E=R/'docs/production/quality-evidence/0.4.51'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
M=R/'art/production/phase4e/player_polearm_051_manifest.json';data=read(M);rows=data['entries'];slots={x['contract_slot_id'] for x in rows}
probes=read(R/'.godot_test_data/polearm-051/PROBES.json');assert len(rows)==len(slots)==31 and len(probes['probes'])==186 and not probes['failures']
assert all(x['exact'] and x['contact'] for x in probes['probes'])
assert Counter(x['slot_id'] for x in probes['probes'])==Counter({s:6 for s in slots})
assert sha(R/'art/audio/production/music/title.ogg')=='7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7'
queue=read(C/'EXACT_REMAINING_CONTRACTS.json');before=read(C/'CONTINUOUS_PRODUCTION_COUNTS.json');remaining={x['slot_id'] for x in queue};assert slots<=remaining,'This new batch is already/partially accepted; refuse double counting'
assert len(queue)==before['remaining_contracts']==2798
contract={x['slot_id']:x for x in queue};files=sum(len(contract[s]['required_files']) for s in slots);assert files==93
E.mkdir(parents=True,exist_ok=True);shutil.copyfile(R/'.godot_test_data/polearm-051/PROBES.json',E/'POLEARM_PROBES.json')
log=R/'.godot_test_data/qa_logs/polearm051-verified-8f9ec3e436/polearm_051_native_qa.log';assert '186 probes; failures {}' in log.read_text();shutil.copyfile(log,E/log.name)
for row in rows:
 asset=R/row['asset_path'].removeprefix('res://');im=Image.open(asset);assert im.mode=='RGBA' and im.size==(512,512);b=im.getchannel('A').getbbox();assert min(b[:2])>=16 and b[2]<=496 and b[3]<=496
 assert sha(R/row['source'])==row['source_sha256'] and (R/row['foreground_layer'].removeprefix('res://')).is_file()
 row.update(native_validated=True,production_status='canon_validated_runtime',asset_sha256=sha(asset),visual_review='Dedicated identity, complete source silhouette, native source and actual weapon grips/facings/grounding reviewed. 186 ordinary/Mythical state/view/layout checks. Basic keyframes; movement/hurt/outcomes/full fluid animation and professional family acceptance remain open.')
 write(R/row['metadata_path'],row)
 req=contract[row['contract_slot_id']]
 for path,source in [(req['source_delivery_path'],asset),(req['source_metadata_path'],R/row['metadata_path']),(req['required_files'][2],R/row['foreground_layer'].removeprefix('res://'))]:
  target=R/path;target.parent.mkdir(parents=True,exist_ok=True);assert not target.exists() or sha(target)==sha(source),'Preserve existing nonmatching source delivery';shutil.copyfile(source,target)
write(M,data)
receipt=dict(version='0.4.51',base_checkpoint='d6fef08',verified_contracts_closed=31,slot_ids=sorted(slots),new_runtime_body_png=16,new_foreground_grip_png=16,new_sidecars=31,frozen_artist_file_requirements_fulfilled=93,new_runtime_physical_artist_files=63,new_source_delivery_files=93,by_family=dict(Counter(x['actor'] for x in rows)),native_probes=186,complete_fluid_animation_families=0,physical_device_validated=False,professional_family_acceptance=False,quality_findings=['Two initial Relic Beast release cells hide the second glove; rejected and replaced together.','Canonical faces obscured by ornate weapon heads in initial native review; corrected body/weapon depth with true foreground grip layers.','One prismatic left release exceeded the old uniform fit allowance; source palms preserved, uniform fit bounded by existing held size limit.','Windows backslash metadata prevented the new contact adapter from activating; source paths normalized and all 186 checks rerun.','Four generated source images preserved; one later standalone left correction remains staged/unused, not an installation.'])
write(C/'POLEARM_INSTALLATION_0451.json',receipt);write(E/'INSTALLATION_RECEIPT.json',receipt)
by=Counter(contract[s]['category'] for s in slots);after=before.copy();after['installed_contracts']+=31;after['remaining_contracts']-=31;after['installed_artist_files']+=files;after['remaining_artist_files']-=files
for cat,n in by.items():after['installed_by_category'][cat]+=n;after['remaining_by_category'][cat]-=n
after['latest_player_revision']='0.4.51: 31 exact Relic Beast/Glimmerfin polearm/casting contracts; 16 independent bodies/16 co-registered grip masks. 186 native ordinary/Mythical contacts. Basic keyframes, not fluid animation families.'
write(C/'EXACT_REMAINING_CONTRACTS.json',[x for x in queue if x['slot_id'] not in slots]);write(C/'CONTINUOUS_PRODUCTION_COUNTS.json',after)
evidence=read(R/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json');assert not any(x['slot_id'] in slots for x in evidence['entries'])
for row in rows:
 path=row['asset_path'].removeprefix('res://');deps=['weapon_fit_catalog.gd','authored_pose_manifest.gd',M.relative_to(R).as_posix()]
 evidence['entries'].append(dict(slot_id=row['contract_slot_id'],asset=path,asset_sha256=sha(R/path),stages=dict(canon_reference_approved=True,created=True,integrated=True,functionally_tested=True,gameplay_visual_reviewed=True,player_experience_reviewed=False,production_quality_accepted=False),evidence_files=['docs/production/quality-evidence/0.4.51/POLEARM_PROBES.json','docs/production/quality-evidence/0.4.51/polearm_051_native_qa.log'],limitations='Native keyframe/contact review; complete fluid animation, missing movement/hurt/outcomes, physical device and professional acceptance remain open.',defects=[],dependencies_sha256={p:sha(R/p) for p in deps}))
write(R/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json',evidence)
for view in ['1080x2340','1600x2560','1920x1080']:
 for actor in ['relic_beast','glimmerfin']:
  for face in ['left','right']:
   src=R/f'.godot_test_data/polearm-051/{view}/pose_{actor}_strike_or_cast_{face}_staff.png';shutil.copyfile(src,E/f'{view}_{actor}_strike_{face}.png')
print('Accepted 31 exact contracts / 16 bodies / 16 grips / 93 required files; remaining',after['remaining_contracts'],after['remaining_artist_files'])
