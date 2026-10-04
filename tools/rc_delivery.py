"""Preserve current RC acceptance history and native review artifacts."""
from pathlib import Path
import argparse, json, hashlib, shutil
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(); p.add_argument('--final', required=True); p.add_argument('--native', required=True); p.add_argument('--layout', required=True); p.add_argument('--tablet', required=True); p.add_argument('--lane', required=True); p.add_argument('--art', required=True); a = p.parse_args()
out = ROOT/'docs/production/predevice'; evidence = out/'evidence'; evidence.mkdir(parents=True,exist_ok=True)
accepted = []; history = []
for label, run in [('broad_final',a.final),('native_final',a.native),('layout_followup',a.layout),('tablet_followup',a.tablet),('lane_followup',a.lane),('art_followup',a.art)]:
    folder = ROOT/'.godot_test_data/qa_logs'/run
    results = json.loads((folder/'results.json').read_text())
    history.append({'label':label,'run':run,'results':results})
    for r in results:
        if (label == 'native_final' and r['name'] == 'mobile_layout_qa') or (label == 'lane_followup' and r['name'] == 'item_art_qa'): continue
        assert r['exit'] == 0 and not r['errors'], (label,r)
        accepted.append(dict(r,run=run))
    for log in folder.glob('*.log'):
        if label == 'broad_final' and log.name.startswith('parse-'): continue
        shutil.copy2(log,evidence/(label+'-'+log.name))
for folder in sorted((ROOT/'.godot_test_data/qa_logs').glob('rc-layout-*')):
    if folder.name == a.layout: continue
    if (folder/'results.json').exists():
        history.append({'label':'layout_investigation','run':folder.name,'results':json.loads((folder/'results.json').read_text())})
    for log in folder.glob('*.log'): shutil.copy2(log,evidence/(folder.name+'-'+log.name))
(out/'qa-results.json').write_text(json.dumps({'accepted':accepted,'history':history,'supersession':'Original layout failures and timing investigations retained; fresh-scene layout followup passes all original gameplay assertions. The native item-art fixture assumed 480x854 despite a requested tablet resolution; actual requested-size assertion supersedes it. The broad final suite is not rerun.'},indent=2))
shutil.copy2(ROOT/'builds/android/build-report.json',out/'android-build.json')
manifest = []; thumbnails = []
for size in ['1080x2316','1600x2560']:
    folder = ROOT/'.godot_test_data/rc'/size
    shutil.copy2(folder/'review.json',evidence/(size+'-review.json'))
    for source in sorted(folder.glob('*.png')):
        target = evidence/(size+'-'+source.stem+'.webp')
        im = Image.open(source).convert('RGB'); im.save(target,quality=90)
        manifest.append({'source':str(source.relative_to(ROOT)),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'review':str(target.relative_to(ROOT)),'pixels':im.size})
        im.thumbnail((240,490)); thumbnails.append((size+'/'+source.stem,im.copy()))
for start in range(0,len(thumbnails),12):
    page = Image.new('RGB',(1000,1584),'#101522'); draw = ImageDraw.Draw(page)
    for index,(label,im) in enumerate(thumbnails[start:start+12]):
        x=(index%4)*250; y=(index//4)*528
        page.paste(im,(x,y+28)); draw.text((x+3,y+5),label,fill='white')
    page.save(evidence/f'contact-{start//12+1}.webp',quality=90)
(evidence/'manifest.json').write_text(json.dumps(manifest,indent=2))
print('Accepted entries',len(accepted),'native captures',len(manifest),'artifact folder',out)
