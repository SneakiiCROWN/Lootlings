"""Archive focused evidence without rerunning unchanged production matrices."""
from pathlib import Path
import json, shutil, subprocess
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[1]; OUT=ROOT/'docs/production/humanqa'
def archive(label):
    folders=sorted((ROOT/'.godot_test_data/qa_logs').glob(label+'-*'),key=lambda x:x.stat().st_mtime)
    folder=folders[-1]; rows=json.loads((folder/'results.json').read_text())
    assert rows and all(r['exit']==0 and not r['errors'] for r in rows), label
    target=OUT/'acceptance'/label; target.mkdir(parents=True,exist_ok=True)
    for file in folder.iterdir():
        if file.suffix in ['.json','.log']: shutil.copy2(file,target/file.name)
    return rows
accepted=[]
for label in ['humanqa-final','humanqa-transaction-final','humanqa-native-final','humanqa-utility-support-final','humanqa-pressure-final','humanqa-audio-final-complete']:
    accepted.extend(archive(label))
(OUT/'qa-results.json').write_text(json.dumps(accepted,indent=2)+'\n')
audio={}
for name,label in [('baseline','humanqa-audio-baseline-complete'),('final','humanqa-audio-final-complete')]:
    rows=archive(label)
    log=(OUT/'acceptance'/label/'human_audio_qa.log').read_text()
    audio[name]=[json.loads(l.split(' ',1)[1]) for l in log.splitlines() if l.startswith('HUMAN_AUDIO ')]
(OUT/'audio.json').write_text(json.dumps(audio,indent=2)+'\n')
for size in ['1080x2316','1600x2560']:
    names=['hub','combat_final','pick_selected','merchant_selected','stall','archive','profile','support']
    sheet=Image.new('RGB',(4*360,2*680),(12,22,40)); draw=ImageDraw.Draw(sheet)
    for i,name in enumerate(names):
        source=ROOT/'.godot_test_data/humanqa'/size/(name+'.png')
        screenshot=Image.open(source); screenshot.thumbnail((352,642))
        x=(i%4)*360; y=(i//4)*680
        sheet.paste(screenshot,(x+(360-screenshot.width)//2,y+28)); draw.text((x+10,y+8),name,fill='white')
    sheet.save(OUT/(size+'-native.jpg'),quality=92)
shutil.copy2(ROOT/'builds/android/build-report.json',OUT/'android-build.json')
changed=subprocess.check_output(['git','diff','--name-only','fccd15b'],cwd=ROOT,text=True).splitlines()
unchanged=['creature_renderer.gd','weapon_fit_catalog.gd','weapon_catalog.gd','art']
for path in unchanged:
    assert (ROOT/path).exists(),path
    assert not subprocess.check_output(['git','diff','--name-only','fccd15b','--',path],cwd=ROOT,text=True).strip(),path
(OUT/'reuse.json').write_text(json.dumps({'baseline':'fccd15b','changed_tracked_files':changed,'verified_unchanged_paths':unchanged,'prior_evidence':'docs/production/predevice/reuse.json','scope':'Actor/weapon pose geometry and canonical art/assets unchanged. UI/game overlay rendering changed and was reviewed natively. Prior physical coverage is not extended.'},indent=2)+'\n')
costs={'wounded_courier':[0,30],'promise_shrine':[40,0],'sealed_cache':[0,0],'lantern_bargain':[45,0],'ink_witness':[0,0],'cursed_coffer':[0,0],'mirror_pool':[0,0],'patch_warranty':[25,0]}
for label in ['baseline','final']:
    runs=json.loads((OUT/label/'runs.json').read_text()); ledger=[]
    for run in runs:
        for event in run['events']:
            prices=costs[event['id']].copy()
            if label=='final' and event['wave']>=12 and event['id'] in ['sealed_cache','cursed_coffer']:
                prices[1]=220 if event['id']=='sealed_cache' else 280
            ledger.append(dict(event,shopping=run['shopping'],sample=run['sample'],costs=prices,price_wallet=[p/max(1,event['wallet']) for p in prices],paid=prices[event['choice']] if event['choice']<2 else 0))
    (OUT/label/'event-ledger.json').write_text(json.dumps({'qualification':'Observed wallet/choice; costs reconstructed from frozen and final catalog. Zero means free/risk option, not an equivalent outcome.','decisions':ledger},indent=2)+'\n')
print('Focused evidence archived:',OUT)
