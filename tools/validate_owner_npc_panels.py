"""Enforce exact scoped panel provenance and reject old identities in live routes."""
from pathlib import Path
import json,hashlib
from PIL import Image
R=Path(__file__).resolve().parents[1]
def validate():
 data=json.loads((R/'art/npc_identity_authorities.json').read_text())
 assert {e['id'] for e in data['entries']}=={'patch','ilex'}
 for e in data['entries']:
  source=R/e['source_board'];assert hashlib.sha256(source.read_bytes()).hexdigest()==e['source_sha256']
  with Image.open(source) as board:crop=board.crop(e['source_crop']).convert('RGBA')
  for key,hashkey in [('canonical_source','dedicated_sha256'),('runtime_asset','runtime_sha256')]:
   p=R/e[key];assert hashlib.sha256(p.read_bytes()).hexdigest()==e[hashkey]
   with Image.open(p) as image:assert image.size==crop.size and image.convert('RGBA').tobytes()==crop.tobytes()
  assert e['full_body_states_closed']==0
  for script in ['hideout_ui.gd','resident_art_catalog.gd']:
   text=(R/script).read_text(encoding='utf-8-sig')
   assert 'res://'+e['runtime_asset'] in text
   assert all('res://'+p not in text for p in e['superseded_runtime_assets'])
 print('PASS: two scoped NPC authorities, two pixel-identical station panels, no superseded live portrait/body routes; zero body closures')
if __name__=='__main__':validate()
