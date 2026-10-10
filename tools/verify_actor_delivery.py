"""Compare exported canonical actor manifests and imported textures with live accepted assets."""
from pathlib import Path
import json,re,hashlib,zipfile,argparse
ROOT=Path(__file__).resolve().parents[1]
def main():
 p=argparse.ArgumentParser();p.add_argument('apk');a=p.parse_args();report={'apk':a.apk,'manifests':{},'textures':{},'physical_device_tested':False}
 with zipfile.ZipFile(ROOT/a.apk) as apk:
  for name in ['player_batch_043_manifest','player_motion_044_manifest','player_combat_045_manifest','player_combat_046_manifest','enemy']:
   path='art/production_enemy_manifest.json' if name=='enemy' else 'art/production/phase4e/'+name+'.json';data=json.loads((ROOT/path).read_text(encoding='utf-8-sig'))
   assert apk.read('assets/'+path)==(ROOT/path).read_bytes(),'Stale exported manifest: '+path
   rows=data['entries'];assert all(r.get('native_validated') and r.get('production_status')=='canon_validated_runtime' for r in rows)
   assets=set()
   for row in rows:
    source=row['asset_path'].removeprefix('res://');assets.add(source)
    if row.get('foreground_layer'):assets.add(row['foreground_layer'].removeprefix('res://'))
    optional=Path(source).with_name(Path(source).stem+'_grip_front.png').as_posix()
    if (ROOT/optional).is_file():assets.add(optional)
   for source in assets:
    config=(ROOT/(source+'.import')).read_text(encoding='utf-8-sig');relative=re.search(r'^path="res://([^\"]+)"',config,re.M).group(1)
    actual=apk.read('assets/'+relative);assert actual==(ROOT/relative).read_bytes(),'Stale actor texture: '+source
    report['textures'][source]=hashlib.sha256(actual).hexdigest()
   report['manifests'][name]={'rows':len(rows),'distinct_exported_body_and_layer_textures':len(assets)}
  assert not any(x.startswith(('assets/art/source/','assets/art/reference/','assets/tests/','assets/tools/','assets/docs/')) for x in apk.namelist())
 report['passed']=True;out=ROOT/'.godot_test_data/android/actor-delivery-046.json';out.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps({'passed':True,'manifests':report['manifests'],'textures':len(report['textures']),'device_tested':False},indent=2))
if __name__=='__main__':main()
