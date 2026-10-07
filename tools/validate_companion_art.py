"""Companion-only source/hash and original-pixel preview guards; not sprite approval."""
from pathlib import Path
import json,hashlib
from PIL import Image
R=Path(__file__).resolve().parents[1]
def validate():
 m=json.loads((R/'art/reference/canonical/companions/COMPANION_CANON_MANIFEST.json').read_text())
 assert m['status']=='OWNER_APPROVED_FINAL_COMPANION_REFERENCE'
 assert m['canonical_companions']==['Auricub','Stonekith','Pixrask','Lunarwisp','Puffnest','Breezewyn']
 for ref in m['reference_files']:assert hashlib.sha256((R/ref['path']).read_bytes()).hexdigest()==ref['sha256']
 previews=json.loads((R/'art/production/companions/previews/manifest.json').read_text())
 assert previews['runtime_states_closed']==0 and len(previews['entries'])==12
 for p in previews['entries']:
  assert not p['runtime_body'] and hashlib.sha256((R/p['asset']).read_bytes()).hexdigest()==p['asset_sha256']
  with Image.open(R/p['source']) as im,Image.open(R/p['asset']) as export:
   crop=im.crop(p['crop']).convert('RGBA');assert crop.size==export.size and crop.tobytes()==export.tobytes()
 body_manifest=R/'art/production/companions/runtime_manifest.json'
 accepted=0
 if body_manifest.exists():
  from extract_companion_idle import extract,SOURCE,SPECS
  rows=json.loads(body_manifest.read_text())['entries'];assert len(rows)==2
  assert {r['actor'] for r in rows}==set(SPECS)
  for row in rows:
   assert row['state']=='idle' and row['facing']=='right' and row['mirror_allowed'] is False
   assert row['source']==SOURCE and row['source_sha256']==hashlib.sha256((R/SOURCE).read_bytes()).hexdigest()
   asset=R/row['asset_path'].removeprefix('res://');original,expected=extract(row['actor'])
   with Image.open(asset) as actual,Image.open(R/row['source_export']) as source:
    assert actual.mode=='RGBA' and actual.size==(256,256) and actual.tobytes()==expected.tobytes()
    assert source.tobytes()==original.tobytes() and actual.getbbox()[3]==224
    assert actual.getpixel((0,0))[3]==0 and actual.getbbox()[0]>=32 and actual.getbbox()[2]<=224
   assert hashlib.sha256(asset.read_bytes()).hexdigest()==row['asset_sha256']
   accepted+=int(row['owner_approved'] is True and row['native_validated'] is True)
 print(json.dumps({'approved_companion_identities':6,'original_pixel_UI_previews':12,'body_state_closures':accepted,'remaining_companion_states':36-accepted,'equip_ready_companions':0}))
if __name__=='__main__':validate()
