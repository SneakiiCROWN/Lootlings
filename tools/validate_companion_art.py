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
 print(json.dumps({'approved_companion_identities':6,'original_pixel_UI_previews':12,'body_state_closures':0}))
if __name__=='__main__':validate()
