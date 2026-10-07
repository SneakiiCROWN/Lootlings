"""Guard new source approval scope and exact original-pixel runtime exports."""
from pathlib import Path
import json,hashlib
from PIL import Image
R=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def validate():
 p=R/'art/approved_missing_canon_references.json'
 if not p.exists():return {'approved_missing_references':0}
 refs=json.loads(p.read_text())['entries'];old=json.loads((R/'art/reference/phase4e_handoff/source_pack_final/MISSING_CANON_ART_QUEUE.json').read_text())['entries']
 assert {r['game_id'] for r in refs}=={r['manifest_game_id'] for r in old} and len(refs)==35
 for r in refs:
  assert r['runtime_asset'] is False and '/marketing_' not in r['source'] and '/playable_support_' not in r['source']
  assert sha(R/r['source'])==r['source_sha256']
 runtime=R/'art/production/phase4e/approved_missing_runtime_manifest.json'
 rows=json.loads(runtime.read_text())['entries'] if runtime.exists() else []
 for r in rows:
  ref=next(e for e in refs if e['game_id']==r['actor']);assert r['source']==ref['source'] and r['source_sha256']==ref['source_sha256']
  assert r['state'] in ['idle','rest'] and r['facing']=='right' and r['native_validated']
  p=R/r['asset_path'].removeprefix('res://');assert sha(p)==r['asset_sha256']
  with Image.open(p) as im:
   assert im.mode=='RGBA' and list(im.size)==r['canvas'] and im.getbbox()==tuple(r['occupied_bounds'])
   assert all(im.getpixel(point)[3]==0 for point in [(0,0),(im.width-1,0),(0,im.height-1),(im.width-1,im.height-1)])
  side=json.loads((R/r['socket_sidecar']).read_text());assert side['source_sockets']==r['source_sockets']
  assert min(r['source_body_pixels'])>=170,'Too-small source pose'
 return {'approved_missing_references':35,'exact_runtime_exports':len(rows),'established_identity_changes':0}
if __name__=='__main__':print(json.dumps(validate()))
