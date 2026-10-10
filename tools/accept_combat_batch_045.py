from pathlib import Path
import json,hashlib,shutil
from collections import Counter
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];CONT=ROOT/'docs/production/full-completion/continuous-production';EVID=ROOT/'docs/production/quality-evidence/0.4.45';EVID.mkdir(parents=True,exist_ok=True)
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,o):p.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 probes=read(ROOT/'.godot_test_data/combat-batch-045/PROBES.json');assert len(probes['probes'])==138 and len({str(x['viewport']) for x in probes['probes']})==3
 logs=sorted((ROOT/'.godot_test_data/qa_logs').glob('combat045-cache-contact-reviewed*/combat_batch_045_native_qa.log'));assert logs
 log=logs[-1];text=log.read_text(encoding='utf-8-sig');assert 'COMBAT BATCH 045 NATIVE PASS' in text and 'SCRIPT ERROR' not in text
 rows=read(ROOT/'art/production/phase4e/player_combat_045_manifest.json')['entries'];slots={r['contract_slot_id'] for r in rows};assert len(slots)==46 and len(rows)==46
 for row in rows:
  asset=ROOT/row['asset_path'].removeprefix('res://');im=Image.open(asset);assert im.mode=='RGBA' and list(im.size)==row['canvas'];bbox=im.getchannel('A').getbbox();assert bbox and min(bbox[:2])>=10 and bbox[2]<=im.width-10 and bbox[3]<=im.height-10
  assert sha(ROOT/row['source'])==row['source_sha256']
  row.update(native_validated=True,production_status='canon_validated_runtime',visual_review='Dedicated canon and all 46 actual native pose/contact views reviewed. 138 exact source/facing/weapon/phase/geometry probes across phone, tablet and desktop. Basic combat keyframes only; fluid continuity, physical-device and professional family acceptance remain open.')
  write(ROOT/row['metadata_path'],row)
 write(ROOT/'art/production/phase4e/player_combat_045_manifest.json',dict(entries=rows,production_quality_accepted=False))
 queue=read(CONT/'EXACT_REMAINING_CONTRACTS.json');remaining={r['slot_id'] for r in queue};counts=read(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json')
 if slots<=remaining:
  closed=[r for r in queue if r['slot_id'] in slots];by=Counter(r['category'] for r in closed)
  write(CONT/'EXACT_REMAINING_CONTRACTS.json',[r for r in queue if r['slot_id'] not in slots])
  counts['installed_contracts']+=len(slots);counts['remaining_contracts']-=len(slots);counts['installed_artist_files']+=3*len(slots);counts['remaining_artist_files']-=3*len(slots)
  for category,n in by.items():counts['installed_by_category'][category]=counts['installed_by_category'].get(category,0)+n;counts['remaining_by_category'][category]-=n
 else:assert not slots&remaining,'Partial journal mutation; stop rather than double-count'
 counts['latest_player_revision']='0.4.45: Vault Runner, Emberhorn, Mosskin and Glimmerfin Wand/Orb anticipation, attack, recovery and hurt deliveries. 46 missing contracts; 29 independent bodies, 29 co-registered hand masks, 46 sidecars (104 physical files). Optional Orb masks are delivered but not drawn over levitated weapons. No fluid-family acceptance.'
 write(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json',counts)
 findings=['Glimmerfin left anticipation/release cells touch: rejected together; no unsafe slicing. Open-palm Wand releases excluded; existing accepted right Orb release retained.', 'Native review caught shared-body Wand/Orb cache contamination: cache now distinguishes weapon, phase and facing, with exact geometry assertions. Levitated Orbs clear faces; forward Wand contact retains approved weapon assets.', 'Dew Hexer initial and correction sheets have saturated matte/edge contamination: both preserved in one correction queue, zero enemy installations.', 'No two-hand, paired, ranged, follow-through or full fluid animation claims. Professional family acceptance and physical S23 review remain open.']
 receipt=dict(base_checkpoint='c2d9ae9',version='0.4.45',verified_contracts_closed=46,slot_ids=sorted(slots),new_runtime_body_png=29,new_foreground_grip_png=29,new_sidecars=46,new_physical_artist_files=104,frozen_artist_file_requirements_fulfilled=138,by_family=dict(Counter(r.split(':')[1] for r in slots)),quality_findings=findings,native_probes=138,physical_device_validated=False,professional_family_acceptance=False,complete_fluid_animation_families=0)

 write(CONT/'PLAYER_COMBAT_INSTALLATION_0445.json',receipt)
 shutil.copyfile(log,EVID/'combat_batch_045_native_qa.log');shutil.copyfile(ROOT/'.godot_test_data/combat-batch-045/PROBES.json',EVID/'PROBES.json')
 for page in [0,1]:shutil.copyfile(ROOT/f'.godot_test_data/combat-batch-045/REVIEW_PAGE_{page}.png',EVID/f'REVIEW_PAGE_{page}.png')
 evidence=read(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json');evidence['entries']=[r for r in evidence['entries'] if r['slot_id'] not in slots]
 for slot in sorted(slots):
  row=next(r for r in rows if r['contract_slot_id']==slot);asset=row['asset_path'].removeprefix('res://')
  evidence['entries'].append(dict(slot_id=slot,asset=asset,asset_sha256=sha(ROOT/asset),stages=dict(canon_reference_approved=True,created=True,integrated=True,functionally_tested=True,gameplay_visual_reviewed=True,player_experience_reviewed=False,production_quality_accepted=False),evidence_files=[(EVID/'combat_batch_045_native_qa.log').relative_to(ROOT).as_posix(),(EVID/'REVIEW_PAGE_0.png').relative_to(ROOT).as_posix(),(EVID/'REVIEW_PAGE_1.png').relative_to(ROOT).as_posix()],limitations='Combat keyframes only. Full continuity, other weapon families, owner/device/artistic acceptance open.',defects=[],dependencies_sha256={path:sha(ROOT/path) for path in ['weapon_fit_catalog.gd','authored_pose_manifest.gd','art/production/phase4e/player_combat_045_manifest.json']}))
 write(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json',evidence)
 print('VERIFIED combat deliveries:',len(slots),'remaining:',counts['remaining_contracts'],'new distinct physical artist files:104; professional accepted:0')
if __name__=='__main__':main()
