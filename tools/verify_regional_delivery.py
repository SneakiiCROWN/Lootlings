"""Verify current accepted regional assets inside the actual APK, byte for byte."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[1]

def verify(apk_path):
    receipt=json.loads((ROOT/'docs/production/full-completion/continuous-production/REGIONAL_RESIDENT_INSTALLATION_0441.json').read_text())
    slots=set(receipt['slot_ids']);accepted=[]
    with zipfile.ZipFile(apk_path) as apk:
        for path in ['art/production_enemy_manifest.json','art/production_npc_manifest.json']:
            local=(ROOT/path).read_bytes();assert apk.read('assets/'+path)==local, 'Stale packaged manifest: '+path
            for row in json.loads(local)['entries']:
                if row.get('contract_slot_id') not in slots:continue
                assert row['native_validated'] and row['production_status']=='canon_validated_runtime'
                source=ROOT/row['asset_path'].removeprefix('res://')
                config=source.with_suffix('.png.import').read_text()
                imported=re.search(r'^path="res://([^"]+)"',config,re.M)[1]
                actual=apk.read('assets/'+imported);assert actual==(ROOT/imported).read_bytes(), 'Stale imported texture: '+str(source)
                accepted.append(dict(slot_id=row['contract_slot_id'],resource=row['asset_path'],imported_sha256=hashlib.sha256(actual).hexdigest()))
        assert {r['slot_id'] for r in accepted}==slots and len(accepted)==48
        assert not any(p.startswith(('assets/art/reference/','assets/art/source/','assets/tests/')) for p in apk.namelist())
    return dict(apk=str(Path(apk_path).resolve()),accepted_packaged_cells=len(accepted),current_imports_match=True,physical_device_tested=False,cells=accepted)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('apk');p.add_argument('--report');args=p.parse_args();result=verify(args.apk)
    if args.report:Path(args.report).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print('APK delivery PASS:',result['accepted_packaged_cells'],'exact current imported textures; both manifest bytes match')
