from pathlib import Path
import json,hashlib,shutil
from collections import Counter
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];CONT=ROOT/'docs/production/full-completion/continuous-production';EVID=ROOT/'docs/production/quality-evidence/0.4.44';EVID.mkdir(parents=True,exist_ok=True)
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,o):p.write_text(json.dumps(o,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 probes=read(ROOT/'.godot_test_data/motion-batch-044/PROBES.json');assert probes['total_probes']==498 and probes['actor_count']==12 and probes['three_viewports']
 logs=sorted((ROOT/'.godot_test_data/qa_logs').glob('motion044-reviewed*/motion_batch_native_qa.log'));assert logs
 log=logs[-1];text=log.read_text();assert 'MOTION BATCH NATIVE PASS' in text and 'SCRIPT ERROR' not in text
 rows=read(ROOT/'art/production/phase4e/player_motion_044_manifest.json')['entries'];slots={r['contract_slot_id'] for r in rows};assert len(slots)==118 and len(rows)==166
 for row in rows:
  asset=ROOT/row['asset_path'].removeprefix('res://');im=Image.open(asset);assert im.mode=='RGBA' and list(im.size)==row['canvas'];bbox=im.getchannel('A').getbbox();assert bbox and min(bbox[:2])>=10 and bbox[2]<=im.width-10 and bbox[3]<=im.height-10
  assert sha(ROOT/row['source'])==row['source_sha256']
  row.update(native_validated=True,production_status='canon_validated_runtime',visual_review='Dedicated identity/source anatomy/independent facing/alpha and 96 native pose views reviewed. 498 three-layout probes; carry contact corrected to avoid faces. Two-step keyframes and single outcome poses remain visually unfinished animation families; professional acceptance and physical-device review open.')
  write(ROOT/row['metadata_path'],row)
 write(ROOT/'art/production/phase4e/player_motion_044_manifest.json',dict(entries=rows,production_quality_accepted=False))
 queue=read(CONT/'EXACT_REMAINING_CONTRACTS.json');remaining={r['slot_id'] for r in queue};counts=read(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json')
 if slots<=remaining:
  closed=[r for r in queue if r['slot_id'] in slots];by=Counter(r['category'] for r in closed)
  write(CONT/'EXACT_REMAINING_CONTRACTS.json',[r for r in queue if r['slot_id'] not in slots])
  counts['installed_contracts']+=len(slots);counts['remaining_contracts']-=len(slots);counts['installed_artist_files']+=3*len(slots);counts['remaining_artist_files']-=3*len(slots)
  for category,n in by.items():counts['installed_by_category'][category]=counts['installed_by_category'].get(category,0)+n;counts['remaining_by_category'][category]-=n
 else:assert not slots&remaining,'Partial journal mutation; stop rather than double-count'
 counts['latest_player_revision']='0.4.44: all twelve actors, alternating movement (Wand/Orb), victory (Wand/Orb except Astrologer Wand), defeat (Orb). 118 exact state/view/weapon deliveries; 96 body PNG, 96 grip PNG, 166 sidecars. Basic keyframes, not completed fluid families.'
 write(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json',counts)
 findings=['Eight original walk-B cells repeated the planted foot: rejected and replaced in grouped corrections.','Four first correction cells changed Moonkip crescent ears or added a Glimmerfin circlet: rejected; identity-preserving corrections used.','Raised Wanderer fists checked against original RGBA: all retain source-edge clearance; no clipped victory cells installed.','Native review caught carry gems overlapping faces: outward carry angles corrected, shield-side inherited angle overridden only for new visual motion.','No Wand defeat contracts claimed from open/resting palms; Astrologer victory Wand excluded. No two-hand, paired, bow, crossbow or sling compatibility claimed.','Whole fluid movement/attack continuity, professional UX/artistic acceptance, physical S23 and subjective audio quality remain open.']
 receipt=dict(base_checkpoint='e6ee811',version='0.4.44',verified_contracts_closed=118,slot_ids=sorted(slots),new_runtime_body_png=96,new_foreground_grip_png=96,new_sidecars=166,new_physical_artist_files=358,frozen_artist_file_requirements_fulfilled=354,by_family=dict(Counter(r.split(':')[1] for r in slots)),quality_findings=findings,native_probes=498,physical_device_validated=False,professional_family_acceptance=False,complete_fluid_animation_families=0)
 write(CONT/'PLAYER_MOTION_INSTALLATION_0444.json',receipt)
 shutil.copyfile(log,EVID/'motion_batch_native_qa.log');shutil.copyfile(ROOT/'.godot_test_data/motion-batch-044/PROBES.json',EVID/'PROBES.json')
 for page in [0,1]:shutil.copyfile(ROOT/f'.godot_test_data/motion-batch-044/REVIEW_PAGE_{page}.png',EVID/f'REVIEW_PAGE_{page}.png')
 for size in ['1080x2340','1200x1920','1920x1080']:
  for name in ['relic_beast_wand_walk_right_0','moonkip_wand_walk_left_1','vault_runner_wand_walk_right_1','emberhorn_orb_defeat_right']:
   p=ROOT/f'.godot_test_data/motion-batch-044/{size}/{name}.png'
   if p.exists():shutil.copyfile(p,EVID/f'{size}_{name}.png')
 evidence=read(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json');evidence['entries']=[r for r in evidence['entries'] if r['slot_id'] not in slots]
 for slot in sorted(slots):
  row=next(r for r in rows if r['contract_slot_id']==slot);asset=row['asset_path'].removeprefix('res://')
  evidence['entries'].append(dict(slot_id=slot,asset=asset,asset_sha256=sha(ROOT/asset),stages=dict(canon_reference_approved=True,created=True,integrated=True,functionally_tested=True,gameplay_visual_reviewed=True,player_experience_reviewed=False,production_quality_accepted=False),evidence_files=[(EVID/'motion_batch_native_qa.log').relative_to(ROOT).as_posix(),(EVID/'REVIEW_PAGE_0.png').relative_to(ROOT).as_posix(),(EVID/'REVIEW_PAGE_1.png').relative_to(ROOT).as_posix()],limitations='Two-step locomotion / outcome keyframes only. Full continuity, other weapon families, owner/device/artistic acceptance open.',defects=[],dependency_sha256={path:sha(ROOT/path) for path in ['weapon_fit_catalog.gd','authored_pose_manifest.gd','result_actor_view.gd','art/production/phase4e/player_motion_044_manifest.json']}))
 write(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json',evidence)
 print('VERIFIED motion deliveries:',len(slots),'remaining:',counts['remaining_contracts'],'new distinct physical artist files:358; professional accepted:0')
if __name__=='__main__':main()