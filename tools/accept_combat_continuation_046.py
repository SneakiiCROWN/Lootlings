"""Accept only independently reviewed deliveries; counts are frozen requirements, not PNGs."""
from pathlib import Path
from collections import Counter
import json,hashlib,shutil
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
CONT=ROOT/'docs/production/full-completion/continuous-production'
EVID=ROOT/'docs/production/quality-evidence/0.4.46'
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,o): p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 probes=read(ROOT/'.godot_test_data/combat-continuation-046/PROBES.json')
 assert len(probes['probes'])==108 and not probes['failures']
 assert all(r.get('exact') and r.get('contact') for r in probes['probes'])
 assert len({str(x['viewport']) for x in probes['probes']})==3
 player_path=ROOT/'art/production/phase4e/player_combat_046_manifest.json'
 enemy_path=ROOT/'art/production_enemy_manifest.json'
 candidate_path=ROOT/'art/source/combat_continuation_046/ENEMY_CANDIDATE_MANIFEST.json'
 players=read(player_path)['entries']; enemies=read(candidate_path)['entries']; rows=players+enemies
 slots={r['contract_slot_id'] for r in rows}
 assert len(players)==26 and len(enemies)==10 and len(slots)==36
 assert Counter(x['slot_id'] for x in probes['probes'])==Counter({s:3 for s in slots})
 logs=sorted((ROOT/'.godot_test_data/qa_logs').glob('continuation046-final-*/combat_continuation_046_native_qa.log'))
 assert logs;log=logs[-1];output=log.read_text(encoding='utf-8-sig')
 assert '108 probes; failures {}' in output and 'SCRIPT ERROR' not in output and 'ERROR:' not in output
 assert sha(ROOT/'art/audio/production/music/title.ogg')=='7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7'
 for r in rows:
  asset=ROOT/r['asset_path'].removeprefix('res://')
  im=Image.open(asset);assert im.mode=='RGBA' and list(im.size)==r['canvas']
  bbox=im.getchannel('A').getbbox()
  assert bbox and min(bbox[:2])>=10 and bbox[2]<=im.width-10 and bbox[3]<=im.height-10
  source=r.get('source',r.get('authored_source'))
  assert sha(ROOT/source)==r.get('source_sha256') if 'source' in r else sha(ROOT/source)==r['authored_source_sha256']
  if 'source_reference' in r: assert sha(ROOT/r['source_reference'])==r['source_sha256']
 queue=read(CONT/'EXACT_REMAINING_CONTRACTS.json');remaining={r['slot_id'] for r in queue}
 assert slots<=remaining or not slots&remaining,'Partial closure journal; refuse double counting'
 assert read(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json')['remaining_contracts']==len(queue),'Interrupted queue/count update; recover journal before acceptance'
 production=read(enemy_path);old=[r for r in production['entries'] if r['contract_slot_id'] not in slots]
 assert len(old)==len(production['entries']) or {r['contract_slot_id'] for r in production['entries'] if r['contract_slot_id'] in slots}=={r['contract_slot_id'] for r in enemies}
 EVID.mkdir(parents=True,exist_ok=True)
 for r in rows:
  r.update(native_validated=True,production_status='canon_validated_runtime',asset_sha256=sha(ROOT/r['asset_path'].removeprefix('res://')),visual_review='Canonical source and actual native pose/facing/contact at phone, tablet and desktop reviewed. Basic individual keyframes, not complete fluid animation or professional family acceptance.')
  if r in enemies:r.update(native_qa=log.parent.name,visual_acceptance=r['visual_review'],source_quality='Original RGBA transparent silhouettes, isolated without cutting overlapping cells. Canonical staff and modest leaf-covered cat tail retained.')
  write(ROOT/r['metadata_path'],r)
 write(player_path,dict(entries=players,production_quality_accepted=False))
 production['entries']=old+enemies;write(enemy_path,production)
 write(candidate_path,dict(entries=enemies,disposition='Installed independently after native visual review; professional family acceptance remains open.'))
 counts=read(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json')
 if slots<=remaining:
  by=Counter(r['category'] for r in queue if r['slot_id'] in slots)
  write(CONT/'EXACT_REMAINING_CONTRACTS.json',[r for r in queue if r['slot_id'] not in slots])
  counts['installed_contracts']+=36;counts['remaining_contracts']-=36;counts['installed_artist_files']+=98;counts['remaining_artist_files']-=98
  for cat,n in by.items():counts['installed_by_category'][cat]+=n;counts['remaining_by_category'][cat]-=n
 counts['latest_player_revision']='0.4.46: 26 exact heavy-weapon deliveries, Emberhorn20/Pebblewyrm6. Nine bodies/nine two-palm masks/26 sidecars. Defective strike and hidden-grip contracts remain open. Basic keyframes; no full fluid animation acceptance.'
 counts['latest_enemy_revision']='0.4.46 adds ten Dew Hexer state/facing deliveries (ten bodies/ten sidecars), exact approved green leaf-hatted cat and intrinsic staff. Right windup/hurt remain open.'
 write(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json',counts)
 receipt=dict(version='0.4.46',base_checkpoint='4f80b95',verified_contracts_closed=36,slot_ids=sorted(slots),new_runtime_body_png=19,new_player_body_png=9,new_enemy_body_png=10,new_foreground_grip_png=9,new_sidecars=36,new_physical_artist_files=64,frozen_artist_file_requirements_fulfilled=98,by_family=dict(Counter(s.split(':')[1] for s in slots)),native_probes=108,physical_device_validated=False,professional_family_acceptance=False,complete_fluid_animation_families=0,quality_findings=['Alpha bridges corrected in player sources before extraction.','Second-palm contact calibrated along existing shafts; artwork and weapon stats unchanged.','Native floor/contact review rejected twelve initial strikes; only one independent corrected Emberhorn left pose fits axe/maul. Ten original strike contracts remain open.','Four Pebblewyrm hidden-grip poses and two Dew Hexer right staff-contact poses remain open.','Dew Hexer oversized tail corrected to approved leaf-covered cat tail.','Grouped correction preserves clipped/merged cells in quarantine; no slicing through anatomy.'])
 write(CONT/'COMBAT_CONTINUATION_INSTALLATION_0446.json',receipt)
 shutil.copyfile(log,EVID/'combat_continuation_046_native_qa.log')
 shutil.copyfile(ROOT/'.godot_test_data/combat-continuation-046/PROBES.json',EVID/'PROBES.json')
 for page in [0,1]:shutil.copyfile(ROOT/f'.godot_test_data/combat-continuation-046/REVIEW_PAGE_{page}.png',EVID/f'REVIEW_PAGE_{page}.png')
 for viewport in ['1080x2340','1200x1920','1920x1080']:
  for name in ['empty_armour','all_gear','selected_detail','hub_preserved','home_preserved']:
   p=ROOT/f'.godot_test_data/inventory-guidance-046/{viewport}/{name}.png'
   if p.exists():shutil.copyfile(p,EVID/f'{name}_{viewport}.png')
 evidence=read(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json')
 evidence['entries']=[r for r in evidence['entries'] if r['slot_id'] not in slots]
 for r in rows:
  asset=r['asset_path'].removeprefix('res://')
  deps=['weapon_fit_catalog.gd','authored_pose_manifest.gd',player_path.relative_to(ROOT).as_posix()] if r in players else ['enemy_art_manifest.gd',enemy_path.relative_to(ROOT).as_posix()]
  evidence['entries'].append(dict(slot_id=r['contract_slot_id'],asset=asset,asset_sha256=sha(ROOT/asset),stages=dict(canon_reference_approved=True,created=True,integrated=True,functionally_tested=True,gameplay_visual_reviewed=True,player_experience_reviewed=False,production_quality_accepted=False),evidence_files=[f'docs/production/quality-evidence/0.4.46/{s}' for s in ['combat_continuation_046_native_qa.log','REVIEW_PAGE_0.png','REVIEW_PAGE_1.png']],limitations='Individual keyframes reviewed. Full fluid continuity, remaining actions, other weapons, physical device and professional family acceptance remain open.',defects=[],dependencies_sha256={p:sha(ROOT/p) for p in deps}))
 write(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json',evidence)
 correction=read(ROOT/'art/source/combat_continuation_046/CORRECTION_QUEUE.json')
 for r in correction['cells']:
  if r.get('slot_id') in slots:r['disposition']='Corrected independently in strike_correction_group.png; native axe/maul floor/contact review passed. Original rejected preserved.'
 correction['accepted_independent_corrected_strikes']=[s for s in sorted(slots) if ':strike_or_cast:' in s]
 write(ROOT/'art/source/combat_continuation_046/CORRECTION_QUEUE.json',correction)
 print('Installed 36 exact deliveries / 64 physical artist files / 98 frozen requirements; remaining',counts['remaining_contracts'],'professional families accepted:0')
if __name__=='__main__':main()
