"""Preserve full-size native before/after evidence and exact reuse provenance."""
from pathlib import Path
from PIL import Image
import hashlib,json,shutil
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'docs/production/phase4e/reuse-canon'
def main():
 OUT.mkdir(parents=True,exist_ok=True);records=[]
 for p in sorted((ROOT/'.godot_test_data/phase4e/reuse-canon').rglob('*.png')):
  rel=p.relative_to(ROOT/'.godot_test_data/phase4e/reuse-canon').with_suffix('.jpg');dest=OUT/'native'/rel;dest.parent.mkdir(parents=True,exist_ok=True)
  with Image.open(p) as im:im.convert('RGB').save(dest,quality=94,subsampling=0);canvas=list(im.size)
  records.append(dict(path='native/'+rel.as_posix(),canvas=canvas,source_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),sha256=hashlib.sha256(dest.read_bytes()).hexdigest()))
 lines=['# Established-canon reuse — native before/after','','Native target-driven right-facing combat and actual authored left sling views. Full-size JPEG94; no body repainting, redesign, mirroring or substituted attack. Mosskin shield-bearing right sling deliberately remains TEMP and appears only in before evidence.','']
 for row in records:lines+=['## '+row['path'],'','!['+row['path']+']('+row['path']+')','']
 (OUT/'GALLERY.md').write_text('\n'.join(lines)+'\n')
 (OUT/'evidence-manifest.json').write_text(json.dumps(dict(native_count=len(records),entries=records),indent=2)+'\n')
 logs=OUT/'qa';logs.mkdir(exist_ok=True)
 for folder in (ROOT/'.godot_test_data/qa_logs').glob('reuse-*'):
  for p in folder.glob('*'):
   if p.suffix in ['.json','.log']:shutil.copy2(p,logs/(folder.name+'-'+p.name))
 print('Packaged native images:',len(records))
 for source in (ROOT/'.godot_test_data/phase4e/master-continuation').rglob('*.png'):
  rel=Path('home-source-sync')/source.parent.name/(source.stem+'.jpg');dest=OUT/rel;dest.parent.mkdir(parents=True,exist_ok=True)
  with Image.open(source) as im:im.convert('RGB').save(dest,quality=94,subsampling=0)
 for folder in (ROOT/'.godot_test_data/qa_logs').glob('source-home-*'):
  for p in folder.glob('*'):
   if p.suffix in ['.json','.log']:shutil.copy2(p,logs/(folder.name+'-'+p.name))
if __name__=='__main__':main()
