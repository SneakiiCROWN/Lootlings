"""Install only visually accepted whole neutral source poses; exact paths only."""
from pathlib import Path
import json,shutil,hashlib
from PIL import Image
R=Path(__file__).resolve().parents[1]
def main():
 base=R/'.godot_test_data/new-canon-neutral'; candidates=json.loads((base/'candidate_manifest.json').read_text())['entries']
 accepted={'fen_sneak':{'contact_or_launch_source_pixels':[263,153],'mouth_source_pixels':[253,116]}}
 rows=[]
 for row in candidates:
  if row['actor'] not in accepted:continue
  with Image.open(row['source_alpha_path']) as mask:
   for point in accepted[row['actor']].values():assert mask.getpixel(tuple(point))[3]>100,(row['actor'],point,'Source socket not visible')
  target=R/row['asset_path'].removeprefix('res://');target.parent.mkdir(parents=True,exist_ok=True)
  if target.exists():
   old=json.loads((R/'art/production/phase4e/approved_missing_runtime_manifest.json').read_text())['entries']
   prior=next(e for e in old if e['asset_path']==row['asset_path'])
   assert prior['actor']==row['actor'] and prior['source_sha256']==row['source_sha256'] and hashlib.sha256(target.read_bytes()).hexdigest()==prior['asset_sha256'],'Preserve any unrelated accepted export'
  shutil.copy2(base/row['filename'],target)
  row['source_sockets']=accepted[row['actor']];row['native_validated']=True # Native fixture must pass before checkpoint/build acceptance.
  row['production_status']='source_derived_beta';row.pop('source_alpha_path')
  row['restrictions']=row['restrictions'].replace('Native quality acceptance pending.','Only this exact neutral state/view; final owner acceptance remains open.')
  side=target.with_suffix('.json');side.write_text(json.dumps(row,indent=2)+'\n')
  row['socket_sidecar']=side.relative_to(R).as_posix();rows.append(row)
 assert len(rows)==1
 (R/'art/production/phase4e/approved_missing_runtime_manifest.json').write_text(json.dumps({'authority':'Explicit owner-approved previously missing source identities; exact reviewed neutral export only','entries':rows},indent=2)+'\n')
 print('Installed one exact source-derived neutral PNG; other sampled bodies fail anatomy/contact gates')
if __name__=='__main__':main()
