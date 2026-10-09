"""Install only the four new, individually licensed regional scores.

Never rewrite the owner-approved title or any previously installed score.
"""
from pathlib import Path
import sys,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.godot_test_data/audio_python'))
import numpy as np
import soundfile as sf
SPECS=[
 ('mossglass_wilds','ogg','nene','Beautiful Forest [Orchestra]','beautiful-forest-orchestra','beautiful_forest_16bit_44.1khz_1.ogg'),
 ('frostbell_hollows','flac','Karate Studios','Ice Village','ice-village','Ice%20Village.wav.flac'),
 ('nullglass_expanse','mp3','Vitalezzz','Claimed by the Void','claimed-by-the-void','claimed_by_the_void_loop.mp3'),
 ('sunken_gearworks','mp3','Vitalezzz','Inevitable','inevitable','inevitable_0.mp3')]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    manifest=ROOT/'art/audio/production/score_sources.json'
    old=json.loads(manifest.read_text(encoding='utf8'))
    protected={x['asset']:sha(ROOT/x['asset']) for x in old['assets'] if x['cue'] not in [s[0] for s in SPECS]}
    credits=[]
    for cue,ext,author,title,page,file in SPECS:
        p=ROOT/f'art/source/audio/region_score/{cue}.{ext}'
        x,rate=sf.read(p,dtype='float32',always_2d=True)
        assert x.shape[1]==2 and 16000<=rate<=48000 and np.isfinite(x).all()
        assert 8<len(x)/rate<300
        if cue!='nullglass_expanse':
            # Complete phrases retained; no short music fragments or fabricated melody.
            active=np.where(np.max(np.abs(x),axis=1)>.0005)[0]
            x=x[max(0,active[0]-rate//20):min(len(x),active[-1]+rate//20)]
            n=min(rate//2,len(x)//8);t=np.linspace(0,1,n)[:,None]
            x=np.concatenate([x[n:-n],x[-n:]*(1-t)+x[:n]*t])
        x-=x.mean(axis=0);gain=min(.075/max(float(np.sqrt(np.mean(x*x))),.0001),.34/max(float(np.max(np.abs(x))),.0001));x*=gain
        dest=ROOT/f'art/audio/production/music/{cue}.ogg'
        with sf.SoundFile(dest,mode='w',samplerate=rate,channels=2,format='OGG',subtype='VORBIS') as stream:
            for start in range(0,len(x),4096):stream.write(x[start:start+4096])
        y,sr=sf.read(dest,dtype='float32',always_2d=True)
        assert np.isfinite(y).all() and np.max(np.abs(y))<.4
        record=dict(cue=cue,author=author,title=title,license='CC0-1.0',license_url='https://creativecommons.org/publicdomain/zero/1.0/',source_page='https://opengameart.org/content/'+page,download_url='https://opengameart.org/sites/default/files/'+file,source_file=p.relative_to(ROOT).as_posix(),source_sha256=sha(p),verified_date='2026-10-09',asset=dest.relative_to(ROOT).as_posix(),asset_sha256=sha(dest),seconds=round(len(y)/sr,3),channels=2,mix_rate=sr,peak_dbfs=round(float(20*np.log10(np.max(np.abs(y)))),2),rms_dbfs=round(float(20*np.log10(np.sqrt(np.mean(y*y)))),2),processing='Full composition; authored loop retained for Nullglass; otherwise half-second seam overlap; DC removal; bounded RMS/peak; stereo Vorbis.')
        credits.append(record)
    old['assets']=[x for x in old['assets'] if x['cue'] not in [s[0] for s in SPECS]]+credits
    manifest.write_text(json.dumps(old,indent=2)+'\n',encoding='utf8')
    (ROOT/'art/source/audio/region_score/LICENSE_RECORDS.json').write_text(json.dumps(credits,indent=2)+'\n',encoding='utf8')
    assert all(sha(ROOT/p)==h for p,h in protected.items())
    print([(x['cue'],x['seconds'],x['peak_dbfs']) for x in credits]);print('All seven existing scores preserved byte for byte.')
if __name__=='__main__':
    import threading
    threading.stack_size(16*1024*1024)
    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=1) as pool:pool.submit(main).result()
