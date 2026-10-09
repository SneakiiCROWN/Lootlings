"""Five bounded original organic beds, never replacing accepted ambience."""
from pathlib import Path
import sys,json,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.godot_test_data/audio_python'))
import numpy as np
import soundfile as sf
RATE=48000
def main():
    records=[];n=RATE*20;t=np.arange(n)/RATE
    for seed,(name,centre,width) in enumerate([('home_hearth',450,650),('mossglass_water',1700,1500),('frostbell_wind',600,900),('gearworks_water',1300,1300),('nullglass_air',250,450)]):
        rng=np.random.default_rng(10401+seed);freq=np.fft.rfftfreq(n,1/RATE)
        spectrum=np.fft.rfft(rng.normal(0,1,n))*np.exp(-((freq-centre)/width)**2)
        # Smooth cyclic movement; no pitched pings or short repeated hit clips.
        x=np.fft.irfft(spectrum,n);x/=max(.001,np.max(np.abs(x)))
        x*=.10*(.75+.15*np.sin(2*np.pi*t/20)+.10*np.sin(2*np.pi*t/5))
        if name=='home_hearth':
            for _ in range(38):
                start=int(rng.uniform(.3,19.7)*RATE);length=int(rng.uniform(.01,.055)*RATE)
                crack=rng.normal(0,.025,length)*np.exp(-np.linspace(0,8,length));x[start:start+length]+=crack
        if name=='gearworks_water':
            x+=.005*np.sin(2*np.pi*80*t)*(.5+.5*np.sin(2*np.pi*t/4))
        # Periodic noise and modulation are exactly continuous; match endpoints
        # after PCM quantisation to prevent a click on the loop boundary.
        x-=x.mean();fade=480;x[:fade]*=np.linspace(0,1,fade);x[-fade:]*=np.linspace(1,0,fade)
        p=ROOT/f'art/audio/production/ambience/{name}.wav';sf.write(p,x,RATE,subtype='PCM_16')
        sidecar=p.with_suffix('.wav.import')
        if sidecar.exists():sidecar.write_text(re.sub(r'compress/mode=\d+','compress/mode=0',sidecar.read_text(encoding='utf8')),encoding='utf8')
        records.append(dict(asset=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),license='Original Lootlings project audio',sources='Deterministic original frequency-shaped noise, cyclic movement and original hearth/crackle/mechanical design; no third-party samples.',seconds=20,mix_rate=RATE,channels=1,peak_dbfs=round(float(20*np.log10(np.max(np.abs(x)))),2)))
    (ROOT/'art/audio/production/world_ambience_sources.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf8');print('Installed five distinct 20-second world ambience beds.')
if __name__=='__main__':main()
