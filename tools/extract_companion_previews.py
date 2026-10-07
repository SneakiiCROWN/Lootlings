"""Original-pixel UI portrait crops only; never promotes board poses to sprites."""
from pathlib import Path
import json, hashlib
from PIL import Image
R=Path(__file__).resolve().parents[1]
SOURCE='art/reference/canonical/companions/Lootlings_Companion_Implementation_Pack_Canonical.png'
OUT=R/'art/production/companions/previews'
IDS=['auricub','stonekith','pixrask','lunarwisp','puffnest','breezewyn']
CROPS=[[32,219,126,307],[141,219,234,307],[249,219,342,307],[32,329,126,407],[141,329,234,407],[249,329,342,407]]
UNLOCK_CROPS=[[717,198,819,312],[833,198,936,312],[951,198,1054,312],[1070,198,1174,312],[1190,198,1296,312],[1311,198,1427,312]]
def main():
 authority=json.loads((R/'art/reference/canonical/companions/COMPANION_CANON_MANIFEST.json').read_text())
 assert authority['status']=='OWNER_APPROVED_FINAL_COMPANION_REFERENCE'
 for ref in authority['reference_files']:
  assert hashlib.sha256((R/ref['path']).read_bytes()).hexdigest()==ref['sha256']
 OUT.mkdir(parents=True,exist_ok=True);rows=[]
 with Image.open(R/SOURCE) as board:
  for id,crop in zip(IDS,CROPS):
   p=OUT/(id+'_portrait.png');board.crop(crop).convert('RGBA').save(p)
   rows.append({'id':id,'purpose':'UI collection preview only; opaque original board tile, not a body/state export','source':SOURCE,'source_sha256':hashlib.sha256((R/SOURCE).read_bytes()).hexdigest(),'crop':crop,'asset':p.relative_to(R).as_posix(),'asset_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'runtime_body':False})
  for id,crop in zip(IDS,UNLOCK_CROPS):
   p=OUT/(id+'_unlock.png');board.crop(crop).convert('RGBA').save(p)
   rows.append({'id':id+'_unlock','purpose':'UI unlock-item preview only; not an item reward/odds change','source':SOURCE,'source_sha256':hashlib.sha256((R/SOURCE).read_bytes()).hexdigest(),'crop':crop,'asset':p.relative_to(R).as_posix(),'asset_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'runtime_body':False})
 (OUT/'manifest.json').write_text(json.dumps({'entries':rows,'identity_authority':'art/reference/canonical/companions/COMPANION_CANON_MANIFEST.json','runtime_states_closed':0},indent=2)+'\n')
 print('Twelve original-pixel companion portrait/unlock previews; zero body/state closures')
if __name__=='__main__':main()
