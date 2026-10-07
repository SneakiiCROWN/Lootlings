"""Validate master index counts, freshness, CSV parity and grouped delivery coverage."""
from pathlib import Path
from collections import Counter
import csv,hashlib,json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'docs/production'
def main():
    data=json.loads((OUT/'MASTER_INTEGRATION_MANIFEST.json').read_text(encoding='utf-8'))
    rows=data['records']; ids=[r['slot_id'] for r in rows];assert len(ids)==len(set(ids))
    assert all(r['status'] in data['statuses'] for r in rows)
    counts=Counter(r['status'] for r in rows);assert data['counts']['all_statuses']=={s:counts[s] for s in data['statuses']}
    assert data['counts']['total_launch_scope_slots']==sum(r['launch_scope'] for r in rows)
    for path,expected in data['source_inputs'].items():assert hashlib.sha256((ROOT/path).read_text(encoding='utf-8-sig').encode('utf-8')).hexdigest()==expected,'Stale source: '+path
    for row in rows:
        if row['status']=='REJECTED_IDENTITY_DRIFT':assert not row['launch_scope']
        if row['current_production_asset']:
            p=ROOT/row['current_production_asset'].removeprefix('res://');assert p.is_file(),str(p)
        if row['status']=='NEEDS_NEW_CANON_EXPORT':assert row['canonical_source'] and row['dimensions'] and row['background']=='transparent RGBA'
    with (OUT/'MASTER_INTEGRATION_MANIFEST.csv').open(encoding='utf-8-sig',newline='') as f:assert [r['slot_id'] for r in csv.DictReader(f)]==ids
    package=json.loads((OUT/'NEEDS_NEW_CANON_EXPORT.json').read_text(encoding='utf-8'))
    requested=[req['slot_id'] for p in package['packages'] for state in p['states'].values() for req in state['requirements']]
    assert len(requested)==len(set(requested))==package['delivery_cells']
    assert set(requested)=={r['slot_id'] for r in rows if r['status']=='NEEDS_NEW_CANON_EXPORT'}
    assert package['body_view_packages']==len(package['packages'])
    filenames=[]
    for p in package['packages']:
        for state in p['states'].values():
            for req in state['requirements']:
                for field in ['entity','state','facing','canvas','transparent_background','baseline','pivot','canonical_reference','source_destination','runtime_destination','socket_sidecar_filename','integration_contract','priority']:
                    assert field in req,(req['slot_id'],field)
                assert req['transparent_background'] and req['canvas']==p['canvas']
                filenames.append(req['runtime_destination'])
    assert len(filenames)==len(set(filenames)), 'Conflicting family delivery filenames'
    assert sum(package['support_packages_recalculated'].values())==data['counts']['support_packages']
    for name,categories in [('CHARACTER_POSE_MATRIX.csv',['playable']),('BOSS_ASSET_MATRIX.csv',['boss']),('ENEMY_ASSET_MATRIX.csv',['regional enemy','enemy','elite'])]:
        with (OUT/name).open(encoding='utf-8-sig',newline='') as f:
            for r in csv.DictReader(f):assert r['slot_id'] in ids and r['category'] in categories
    print(json.dumps({'slots':len(rows),'launch_slots':data['counts']['total_launch_scope_slots'],'missing_delivery_cells':len(requested),'shared_body_view_bundles':len(package['packages']),'support_packages':data['counts']['support_packages'],'fresh_sources':len(data['source_inputs'])}))
if __name__=='__main__':main()
