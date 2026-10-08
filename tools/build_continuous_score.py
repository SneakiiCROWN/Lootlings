"""Build long-form mobile scores from individually verified CC0 source recordings."""
from pathlib import Path
import sys,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.godot_test_data/audio_python'))
import soundfile as sf
import numpy as np
SOURCE=ROOT/'art/source/audio/continuous_score'
OUT=ROOT/'art/audio/production/music'
def main():
    licenses=json.loads((SOURCE/'LICENSE_RECORDS.json').read_text(encoding='utf8'));OUT.mkdir(parents=True,exist_ok=True);records=[]
    for record in licenses:
        lock=ROOT/'docs/production/full-completion/continuous-production/TITLE_THEME_OWNER_APPROVAL.json'
        if record['cue']=='title' and lock.exists():
            approved=json.loads(lock.read_text(encoding='utf8'))['track']
            assert hashlib.sha256((ROOT/approved['asset']).read_bytes()).hexdigest()==approved['asset_sha256'],'Owner-approved title theme changed'
            assert hashlib.sha256((ROOT/approved['source_file']).read_bytes()).hexdigest()==approved['source_sha256'],'Owner-approved title source changed'
            records.append(approved);continue # No decoding, rewrite, remix or reprocessing of the locked theme.
        source=ROOT/record['source_file'];assert hashlib.sha256(source.read_bytes()).hexdigest()==record['source_sha256']
        x,rate=sf.read(source,dtype='float32',always_2d=True)
        assert 16000<=rate<=48000 and x.shape[1]==2 and np.isfinite(x).all()
        # Remove only leading/trailing digital silence, preserving complete musical phrases.
        active=np.where(np.max(np.abs(x),axis=1)>.0005)[0];x=x[max(0,active[0]-rate//20):min(len(x),active[-1]+rate//20)]
        n=min(int(rate*1.5),len(x)//8);t=np.linspace(0,1,n)[:,None]
        # End and opening overlap maintains ambience through the repeat without a hard edit.
        seam=x[-n:]*(1-t)+x[:n]*t;x=np.concatenate([x[n:-n],seam])
        x-=np.mean(x,axis=0);rms=float(np.sqrt(np.mean(x*x)));gain=min(.075/max(rms,.0001),.34/max(float(np.max(np.abs(x))),.0001));x*=gain
        dest=OUT/(record['cue']+'.ogg');
        with sf.SoundFile(dest,mode='w',samplerate=rate,channels=2,format='OGG',subtype='VORBIS') as stream:
            for start in range(0,len(x),4096):stream.write(x[start:start+4096])
        decoded,sr=sf.read(dest,dtype='float32',always_2d=True);assert np.isfinite(decoded).all() and np.max(np.abs(decoded))<.40
        records.append(dict(record,asset=str(dest.relative_to(ROOT)),asset_sha256=hashlib.sha256(dest.read_bytes()).hexdigest(),seconds=round(len(decoded)/sr,3),channels=2,mix_rate=sr,peak_dbfs=round(float(20*np.log10(np.max(np.abs(decoded)))),2),rms_dbfs=round(float(20*np.log10(np.sqrt(np.mean(decoded*decoded)))),2),processing='full composition; trim digital silence; 1.5s seam overlap; DC removal; matched RMS and peak ceiling; stereo Vorbis'))
    (OUT.parent/'score_sources.json').write_text(json.dumps(dict(license='CC0-1.0',assets=records),indent=2)+'\n',encoding='utf8')
    print('Installed seven complete licensed stereo scores:',[(x['cue'],x['seconds']) for x in records])
if __name__=='__main__':
    import threading
    threading.stack_size(16*1024*1024)
    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=1) as pool:pool.submit(main).result()
