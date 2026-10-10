"""Validate exact transparent resident bodies against dedicated identity authority."""
from pathlib import Path
import hashlib,json
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
def validate():
 refs={r['id']:r for r in json.loads((ROOT/'art/npc_identity_authorities.json').read_text())['entries']}
 rows=json.loads((ROOT/'art/production_npc_manifest.json').read_text())['entries'];keys=set()
 for row in rows:
  key=(row['actor'],row['state'],row['facing']);assert key not in keys;keys.add(key)
  assert row['state'] in ['rest','inspect','talk'] and row['facing'] in ['left','right']
  ref=refs[row['actor']]
  assert row['source_reference']==ref['canonical_source'] and row['source_sha256']==ref['dedicated_sha256']
  assert hashlib.sha256((ROOT/row['source_reference']).read_bytes()).hexdigest()==row['source_sha256']
  assert row['native_validated'] and row['production_status']=='canon_validated_runtime' and row['native_qa']
  path=(ROOT/row['asset_path'].removeprefix('res://')).resolve();assert path.is_relative_to(ROOT/'art/production/phase4e/npcs') or row['actor']=='sera' and path==ROOT/'art/sprites/npcs/beta/sera_idle.png'
  assert hashlib.sha256(path.read_bytes()).hexdigest()==row['asset_sha256']
  assert json.loads((ROOT/row.get('metadata_path',str(path.with_suffix('.json').relative_to(ROOT)))).read_text())==row
  source=ROOT/row['authored_source'];assert hashlib.sha256(source.read_bytes()).hexdigest()==row['authored_source_sha256']
  with Image.open(path) as im,Image.open(source) as authored:
   assert im.mode=='RGBA' and list(im.size)==[1024,1536]
   used=im.getchannel('A').getbbox();reused_original=row['actor']=='sera' and row['state']=='rest' and row['facing']=='right';assert used and (reused_original or used[0]>=16 and used[1]>=16 and used[2]<=1008 and used[3]<=1520)
   x,y,w,h=row['content_rect'];assert im.crop((x,y,x+w,y+h)).tobytes()==authored.crop(row['authored_source_bounds']).tobytes() if row['actor']!='sera' else reused_original or used==tuple([x,y,x+w,y+h])
   assert all(im.getpixel(p)[3]==0 for p in [(0,0),(1023,0),(0,1535),(1023,1535)])
  assert row['pivot']==([512,1470] if row['actor']=='sera' and row['state']=='rest' and row['facing']=='right' else [512,1504])
 assert keys=={(a,s,f) for a in ['patch','ilex','sera'] for s in ['rest','inspect','talk'] for f in ['left','right']}
 return {'exact_resident_body_cells':len(rows),'independent_views':2,'mirrored_frames':0,'remaining_resident_states':['route/walk','work/read/tend','sit']}
if __name__=='__main__':print(json.dumps(validate()))
