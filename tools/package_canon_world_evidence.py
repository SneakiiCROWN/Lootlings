"""Package full native captures and provenance for the Phase4E canon/world batch."""
from pathlib import Path
import hashlib,json,re,shutil
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'.godot_test_data/phase4e/full-continuation'
OUT=ROOT/'docs/production/phase4e/canon-world'
OUT.mkdir(parents=True,exist_ok=True)
records=[]
for source in sorted(SOURCE.rglob('*.png')):
    relative=source.relative_to(SOURCE).with_suffix('.jpg')
    target=OUT/'native'/relative;target.parent.mkdir(parents=True,exist_ok=True)
    with Image.open(source) as image:
        image.convert('RGB').save(target,quality=94,subsampling=0)
        size=list(image.size)
    records.append(dict(path=target.relative_to(OUT).as_posix(),size=size,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),sha256=hashlib.sha256(target.read_bytes()).hexdigest()))
(OUT/'native_manifest.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
lines=['# Phase4E canon/world native gallery','',
       'Full-resolution JPEG94 evidence; native Godot Compatibility renderer. Phone 1080×2340 and tablet 1200×1920. No art repainting or changes to screenshots other than high-quality encoding.',
       '', 'Before: exact 79fecef Hideout UI script rendered with current shared data/resources in an isolated fixture. This is a UI comparison, not a complete historical binary. No checkout/reset/overwrite. After: current runtime.',
       '', 'Regional boss-account captures force completed-region discovery in an isolated QA profile; no save migration or encounter timing change. Their real region paintings do not claim missing boss bodies. RED combat capture intentionally retains the known rejected TEMP rig body as blocker evidence.', '']
for record in records:
    lines += ['## '+record['path'],'', '!['+record['path']+']('+record['path']+')','']
(OUT/'GALLERY.md').write_text('\n'.join(lines),encoding='utf-8')
logs=ROOT/'.godot_test_data/qa_logs'
for label in ['canon-world-final','canon-world-delivery-native','canon-world-aspect','canon-world-aspect-native','canon-world-captions','canon-world-captions-native']:
    matches=[p for p in logs.glob(label+'-*') if re.fullmatch(re.escape(label)+r'-[0-9a-f]{10}',p.name)]
    folder=max(matches,key=lambda p:p.stat().st_mtime)
    destination=OUT/'qa'/folder.name;destination.mkdir(parents=True,exist_ok=True)
    for source in folder.glob('*'):shutil.copy2(source,destination/source.name)
shutil.copy2(SOURCE/'baseline.log',OUT/'qa/baseline.log')
print(json.dumps({'captures':len(records),'before':sum('/before/' in '/'+r['path'] for r in records),'output':str(OUT)}))
