"""Original offline procedural Lootlings reel Foley and musical reward motifs.
No third-party recordings, model voices, music samples or franchise material.
Deterministic PCM16 masters; does not touch any existing audio assets.
"""
from pathlib import Path
import math, random, wave, struct, hashlib, json
ROOT=Path(__file__).resolve().parents[1]
RATE=48000
OUT=ROOT/'art/audio/production/sfx'
SPECS={'spinner_tick':(.065,.28),'spinner_catch':(.19,.44),'spinner_stop':(.42,.50),'spinner_activate':(.72,.46),'spinner_fanfare':(1.55,.56)}
def render(name,duration,peak):
 rng=random.Random(500+list(SPECS).index(name)); y=[]; low=0.0
 for i in range(int(duration*RATE)):
  t=i/RATE;low=.91*low+.09*rng.uniform(-1,1)
  if name=='spinner_tick':
   v=(low*.65+math.sin(math.tau*480*t)*.18)*math.exp(-t*95)
  elif name in ('spinner_catch','spinner_stop'):
   v=(low*.8+math.sin(math.tau*(115*t-35*t*t))*.3)*math.exp(-t*22)
   if name=='spinner_stop':v+=sum(math.sin(math.tau*f*t)*math.exp(-t*10) for f in (261.63,392,523.25))*.09
  elif name=='spinner_activate':
   v=(low*.25+math.sin(math.tau*(125*t+180*t*t))*.15)*math.sin(math.pi*t/duration)**2
   for k,f in enumerate((261.63,392,523.25)):
    q=t-k*.10
    if q>=0:v+=math.sin(math.tau*f*q)*math.exp(-q*9)*.12
  else:
   v=0
   # Original rising major-sixth cadence, with gentle brass-like overtones.
   for k,f in enumerate((261.63,329.63,392,523.25,659.25)):
    q=t-k*.11
    if q>=0:v+=(math.sin(math.tau*f*q)+.18*math.sin(math.tau*f*2*q))*min(1,q/.014)*math.exp(-q*3.2)*.16
  edge=min(1,t/.003,(duration-t)/.025);y.append(v*edge)
 mean=sum(y)/len(y);y=[v-mean for v in y];scale=peak/max(abs(v) for v in y);y=[v*scale for v in y]
 path=OUT/(name+'_01.wav');OUT.mkdir(parents=True,exist_ok=True)
 if path.exists():raise SystemExit('Refuse to overwrite accepted audio: '+str(path))
 with wave.open(str(path),'wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE);w.writeframes(b''.join(struct.pack('<h',round(v*32767)) for v in y))
 return {'event':name,'path':path.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'seconds':duration,'peak_dbfs':round(20*math.log10(max(abs(v) for v in y)),2),'rms_dbfs':round(20*math.log10(math.sqrt(sum(v*v for v in y)/len(y))),2),'license':'Original procedurally authored project audio; no third-party samples; commercial project use','voice':False}
if __name__=='__main__':
 records=[render(name,*spec) for name,spec in SPECS.items()]
 receipt=ROOT/'docs/production/quality-evidence/0.4.50/SPINNER_AUDIO_PROVENANCE.json';receipt.parent.mkdir(parents=True,exist_ok=True);receipt.write_text(json.dumps(records,indent=2),encoding='utf-8');print(json.dumps(records,indent=2))
