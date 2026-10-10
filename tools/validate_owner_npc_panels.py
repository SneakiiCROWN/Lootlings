"""Enforce exact scoped panel provenance and reject old identities in live routes."""
from pathlib import Path
import json,hashlib
from PIL import Image
R=Path(__file__).resolve().parents[1]
def validate():
 data=json.loads((R/'art/npc_identity_authorities.json').read_text())
 assert {e['id'] for e in data['entries']}=={'patch','ilex','sera'}
 for e in [r for r in data['entries'] if r['id'] in ['patch','ilex']]:
  source=R/e['source_board'];assert hashlib.sha256(source.read_bytes()).hexdigest()==e['source_sha256']
  with Image.open(source) as board:crop=board.crop(e['source_crop']).convert('RGBA')
  for key,hashkey in [('canonical_source','dedicated_sha256'),('runtime_asset','runtime_sha256')]:
   p=R/e[key];assert hashlib.sha256(p.read_bytes()).hexdigest()==e[hashkey]
   with Image.open(p) as image:assert image.size==crop.size and image.convert('RGBA').tobytes()==crop.tobytes()
  bodies=json.loads((R/e['full_body_manifest']).read_text())['entries']
  accepted=[r for r in bodies if r['actor']==e['id'] and r.get('native_validated') and r.get('production_status')=='canon_validated_runtime']
  assert e['full_body_states_closed']==len(accepted)==6
  assert {(r['state'],r['facing']) for r in accepted}=={(s,f) for s in ['rest','inspect','talk'] for f in ['left','right']}
  for script in ['hideout_ui.gd','resident_art_catalog.gd']:
   text=(R/script).read_text(encoding='utf-8-sig')
   assert 'res://'+e['runtime_asset'] in text
   assert all('res://'+p not in text for p in e['superseded_runtime_assets'])
 print('PASS: two scoped NPC authorities, two pixel-identical station panels; twelve independently facing body keyframes, with remaining animation contracts open')
if __name__=='__main__':validate()
