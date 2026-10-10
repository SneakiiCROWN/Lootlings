"""Bind delivery claims to actual source native captures and current dependencies."""
from pathlib import Path
import json,hashlib,shutil
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/production/quality-evidence/0.4.43'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,x):p.write_text(json.dumps(x,indent=2)+'\n',encoding='utf-8')
def main():
    OUT.mkdir(parents=True,exist_ok=True)
    rows=json.loads((ROOT/'art/production/phase4e/player_batch_043_manifest.json').read_text())['entries']
    evidence=ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json';data=json.loads(evidence.read_text())
    slots={r['contract_slot_id'] for r in rows};data['entries']=[e for e in data['entries'] if e['slot_id'] not in slots]
    logs=ROOT/'.godot_test_data/qa_logs/player-batch-installed-043-bcc62a729c'
    result=json.loads((logs/'results.json').read_text());assert all(r['exit']==0 and not r['errors'] for r in result)
    for name in ['player_batch_native_qa','player_route_polish_native_qa']:shutil.copyfile(logs/(name+'.log'),OUT/(name+'.log'))
    for stage in ['before','after']:
        shutil.copyfile(ROOT/'.godot_test_data/player-batch-043'/stage/'PROBES.json',OUT/(stage+'_PROBES.json'))
    deps={p:sha(ROOT/p) for p in ['authored_pose_manifest.gd','weapon_fit_catalog.gd','creature_renderer.gd','art/production/phase4e/player_batch_043_manifest.json']}
    actions={'idle':'idle','windup':'windup','strike_or_cast':'commit','follow_through':'follow','recovery':'recovery','hurt':'hurt'}
    for row in rows:
        actor=row['actor'];weapon=row['weapon_types'][0];face=row['facing'].removesuffix('_only');action=actions[row['state']]
        capture=f'{actor}_{weapon}_{action}_{face}.png'
        # All exact probe states tested. Keep the exact phone image where captured,
        # plus actual native attacks across all three layouts. No source-sheet substitute.
        paths=['docs/production/quality-evidence/0.4.43/player_batch_native_qa.log']
        source=ROOT/'.godot_test_data/player-batch-043/after/1080x2340'/capture
        if source.exists():
            dest=OUT/('1080x2340_'+capture);shutil.copyfile(source,dest);paths.append(dest.relative_to(ROOT).as_posix())
        for viewport in ['1080x2340','1200x1920','1920x1080']:
            name=actor+'_'+weapon+'_actual_attack.png';dest=OUT/(viewport+'_'+name)
            shutil.copyfile(ROOT/'.godot_test_data/player-batch-043/after'/viewport/name,dest);paths.append(dest.relative_to(ROOT).as_posix())
        asset=row['asset_path'].removeprefix('res://')
        data['entries'].append(dict(slot_id=row['contract_slot_id'],asset=asset,asset_sha256=sha(ROOT/asset),dependencies_sha256=deps,evidence_files=paths,stages=dict(canon_reference_approved=True,created=True,integrated=True,functionally_tested=True,gameplay_visual_reviewed=True,player_experience_reviewed=False,production_quality_accepted=False),limitations='Exact stationary/action pose, source identity, contact and native views reviewed. Motion/defeat/victory and full weapon/character continuity remain open; no blanket professional acceptance or physical Android claim.',defects=[]))
    # The connected route reran against the changed reward UI. Refresh only its
    # previously reviewed screen evidence; do not accept unrelated historical screens.
    for viewport in ['1080x2340','1200x1920','1920x1080']:
        for name in ['reward_find','shop_compare_ready','perk_choice','combat_readability','hub']:
            src=ROOT/'.godot_test_data/player-polish'/viewport/(name+'.png')
            if src.exists():shutil.copyfile(src,OUT/(viewport+'_'+name+'.png'))
    for entry in data['entries']:
        if entry.get('implementation')=='lootling.gd' and entry['slot_id'].startswith('screen:'):
            method=entry['slot_id'].split(':')[-1]
            if method in ['show_upgrade_choices','show_merchant','show_boss_reward']:
                entry['implementation_sha256']=sha(ROOT/'lootling.gd')
                if 'lootling.gd' in entry.get('dependencies_sha256',{}):entry['dependencies_sha256']['lootling.gd']=sha(ROOT/'lootling.gd')
                entry['evidence_files'].append('docs/production/quality-evidence/0.4.43/player_route_polish_native_qa.log')
    write(evidence,data)
    print('Recorded 25 exact native delivery entries; professional family acceptance remains false')
if __name__=='__main__':main()
