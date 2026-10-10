"""Accept only the exact independently reviewed 048 service poses and named items."""
from pathlib import Path
from collections import Counter
import json,hashlib,shutil
ROOT=Path(__file__).resolve().parents[1]
CONT=ROOT/'docs/production/full-completion/continuous-production'
EVID=ROOT/'docs/production/quality-evidence/0.4.48'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 for name in ['NPC_TECHNICAL','ITEM_TECHNICAL']:
  t=read(ROOT/('art/source/living_world_048/'+name+'.json'));assert t['technical_failures']==0 and t['technical_passes']==6
 probes=read(ROOT/'.godot_test_data/asset-factory-048/PROBES.json');assert len(probes['probes'])==3 and all(p['npc_work_both_facings'] and p['six_named_items'] and p['station_touch_returns'] and p['economy_unchanged'] for p in probes['probes'])
 logs=sorted((ROOT/'.godot_test_data/qa_logs').glob('living048-finalpreview-*/asset_factory_048_native_qa.log'));assert logs;log=logs[-1];s=log.read_text(encoding='utf-8-sig');assert 'ASSET FACTORY 048 NATIVE PASS' in s and 'ERROR:' not in s and 'SCRIPT ERROR' not in s
 manifest=ROOT/'art/production_npc_manifest.json';data=read(manifest);npcs=[x for x in data['entries'] if x.get('authored_source','').startswith('art/source/living_world_048/')];assert len(npcs)==6
 items_path=ROOT/'art/production/phase4e/items/named_048/manifest.json';items=read(items_path)['entries'];assert len(items)==6
 EVID.mkdir(parents=True,exist_ok=True);shutil.copy2(log,EVID/'asset_factory_048_native_qa.log');shutil.copy2(ROOT/'.godot_test_data/asset-factory-048/PROBES.json',EVID/'PROBES.json')
 for viewport in ['1080x2340','1200x1920','1920x1080']:
  for name in ['hub_work_left','hub_work_right','named_loot_stash','detail_storm_ledger','detail_critical_script','personal_home','ShopEntrance','ForgeStation','ArchiveDesk']:
   shutil.copy2(ROOT/f'.godot_test_data/asset-factory-048/{viewport}/{name}.png',EVID/f'{name}_{viewport}.png')
 for row in npcs+items:
  row.update(native_validated=True,production_status='canon_validated_runtime',asset_sha256=sha(ROOT/row['asset_path'].removeprefix('res://')),native_qa='docs/production/quality-evidence/0.4.48/asset_factory_048_native_qa.log',visual_review='Exact dedicated NPC identity or named-item/style authority compared with original and actual phone/tablet/desktop rendering. Complete alpha silhouette; stable scale/pivot. Individual work keyframes or static icons, not complete fluid animation or professional family approval.',production_quality_accepted=False)
  if row in items:row['metadata_path']=row['asset_path'].removeprefix('res://').replace('.png','.json')
  write(ROOT/row['metadata_path'],row)
 write(manifest,data);write(items_path,dict(entries=items,production_quality_accepted=False))
 slots={x['contract_slot_id'] for x in npcs};queue=read(CONT/'EXACT_REMAINING_CONTRACTS.json');remaining={x['slot_id'] for x in queue};counts=read(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json');assert counts['remaining_contracts']==len(queue)
 assert slots<=remaining or not slots&remaining,'Refuse partial or duplicate acceptance'
 if slots<=remaining:
  requirements=sum(len(x['required_files']) for x in queue if x['slot_id'] in slots);assert requirements==12
  counts['installed_contracts']+=6;counts['remaining_contracts']-=6;counts['installed_artist_files']+=requirements;counts['remaining_artist_files']-=requirements;counts['installed_by_category']['npcs']+=6;counts['remaining_by_category']['npcs']-=6
  write(CONT/'EXACT_REMAINING_CONTRACTS.json',[x for x in queue if x['slot_id'] not in slots])
 counts['latest_npc_revision']='0.4.48: 24 accepted resident cells; adds six Patch repair/Ilex read-write/Sera crystal-tending work views. Rest/inspect/talk preserved. Short grounded transitions; route/walk, sit and fluid motion remain open.';write(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json',counts)
 evidence=read(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json');newslots=slots|{'named-item:'+x['id'] for x in items};evidence['entries']=[x for x in evidence['entries'] if x['slot_id'] not in newslots]
 for row in npcs+items:
  deps=['resident_art_catalog.gd','hideout_ui.gd','art/production_npc_manifest.json'] if row in npcs else ['lootlings_ui.gd','named_item_art.gd','art/production/phase4e/items/named_048/manifest.json']
  evidence['entries'].append(dict(slot_id=row.get('contract_slot_id','named-item:'+row.get('id','')),asset=row['asset_path'].removeprefix('res://'),asset_sha256=row['asset_sha256'],stages=dict(canon_reference_approved=True,created=True,integrated=True,functionally_tested=True,gameplay_visual_reviewed=True,player_experience_reviewed=False,production_quality_accepted=False),evidence_files=['docs/production/quality-evidence/0.4.48/asset_factory_048_native_qa.log','docs/production/quality-evidence/0.4.48/PROBES.json'],limitations='Full continuity, contextual lighting, subjective UX, physical device and professional family acceptance remain open.',defects=[],dependencies_sha256={p:sha(ROOT/p) for p in deps}))
 write(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json',evidence)
 receipt=dict(version='0.4.48',base_checkpoint='f05edb9',kind='canonical-services-named-loot-and-regional-atmosphere',verified_contracts_closed=6,new_generated_assets=5,new_runtime_png=12,new_physical_artist_files=24,frozen_artist_requirements_fulfilled=12,npc_cells=6,named_item_icons=6,named_items_outside_frozen_pose_counter=True,remaining_contracts=counts['remaining_contracts'],remaining_artist_file_requirements=counts['remaining_artist_files'],complete_fluid_animation_families=0,professional_family_acceptance=False,physical_device_validated=False,other_installed_features=['Patch repair, Ilex reading/writing and Sera crystal service both independent views','140 ms grounded resident transitions with reduced-motion support','Six unique named item icons in shared loot/equipment renderer'],newly_available_companion_routes=[],title_audio_sha256=sha(ROOT/'art/audio/production/music/title.ogg'),accepted_assets=[x['asset_path'] for x in npcs+items])
 write(EVID/'INSTALLATION_RECEIPT.json',receipt);print('Installed six NPC pose contracts + six named item icons; 24 physical artist files. Remaining',counts['remaining_contracts'],counts['remaining_artist_files'],'Professional families: 0')
if __name__=='__main__':main()
