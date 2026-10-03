"""Bounded nonverbal species banks from credited CC0 recordings, offline only.

No model voices, no human pain bank for creatures. Does not rebuild other audio.
"""
from pathlib import Path
import sys, json, hashlib
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.godot_test_data/audio_python'))
import numpy as np
import soundfile as sf
from build_sound_bank import source, noise, mix, RATE
SOURCE=ROOT/'.godot_test_data/audio_sources/beasts'
OUT=ROOT/'art/audio/production'
SOURCES={
'monster-snarls.ogg':('Darsycho','https://opengameart.org/content/monster-snarls'),
'monster-snarls-2.ogg':('Darsycho','https://opengameart.org/content/monster-snarls'),
'monsters-snarls-3.ogg':('Darsycho','https://opengameart.org/content/monster-snarls'),
'monster-snarl-attack.ogg':('Darsycho','https://opengameart.org/content/monster-snarls'),
'cat_mewfood.wav':('Kerzoven','https://opengameart.org/content/cat-purr-meow'),
'cat_mewpurr.wav':('Kerzoven','https://opengameart.org/content/cat-purr-meow'),
'cat_softmew.wav':('Kerzoven','https://opengameart.org/content/cat-purr-meow')}
# Speed reflects size; material accents reflect lore. No bitcrushing/ring modulation.
PROFILES={
'relic':(1.22,'growl','cloth'), 'ember':(1.08,'growl','fire'),
'moss':(.78,'growl','wood'), 'moon':(1.18,'cat','cloth'),
'pebble':(.66,'growl','stone'), 'glimmer':(1.03,'cat','water'),
'gloom':(.96,'cat','soft'), 'imp':(1.48,'growl','cloth'),
'brute':(.73,'growl','wood'), 'hexer':(.95,'breath','soft'),
'dragon':(.53,'growl','fire'), 'forge':(.64,'growl','metal'),
'human_light':(1.0,'breath','cloth'), 'human_heavy':(.92,'human','cloth')}

def recording(name,speed,duration,index,role):
    p=SOURCE/name
    x,rate=sf.read(p,dtype='float32',always_2d=True); x=x.mean(axis=1)
    # Select four energy-bearing windows, avoiding silence and long drawn-out calls.
    n=int(rate*min(duration*speed,.65 if role=='attack' else 1.05))
    candidates=range(0,max(1,len(x)-n),max(1,int(rate*.08)))
    ranked=sorted(candidates,key=lambda start:float(np.mean(x[start:start+n]**2)),reverse=True)
    start=ranked[min(index*3,len(ranked)-1)]
    x=x[start:start+n]
    x=np.interp(np.arange(int(len(x)*RATE/rate/speed))*rate*speed/RATE,np.arange(len(x)),x)
    # Remove room rumble and hiss while preserving organic harmonics.
    spectrum=np.fft.rfft(x); f=np.fft.rfftfreq(len(x),1/RATE)
    spectrum*= (1-np.exp(-(f/95)**2))/(1+(f/4200)**4)
    x=np.fft.irfft(spectrum,len(x))
    return x,dict(file=name,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),speed=speed,window_start=round(start/rate,4),author=SOURCES[name][0],url=SOURCES[name][1],license='CC0-1.0')

def main():
    records=[]
    for profile,(speed,kind,material) in PROFILES.items():
        for role in ['attack','hurt','death']:
            duration={'attack':.30,'hurt':.34,'death':.68}[role]
            if profile=='dragon': duration*=1.5
            for index in range(4):
                credits=[]; parts=[]
                if kind in ['growl','cat']:
                    name=(['monster-snarl-attack.ogg','monster-snarls.ogg','monster-snarls-2.ogg','monsters-snarls-3.ogg'] if kind=='growl' else ['cat_mewpurr.wav','cat_softmew.wav','cat_mewfood.wav','cat_mewpurr.wav'])[index]
                    x,c=recording(name,speed*(1+(index-1.5)*.025),duration,index,role)
                    parts.append((x,.68,0)); credits.append(c)
                elif kind=='human':
                    x,c=source('pain',['Track 2','Track 5','Track 6','Track 1'][index],speed)
                    parts.append((x[:int(RATE*duration)],.48,0)); credits.append(c)
                else:
                    # Quiet nonlexical breath, not the old male ARGH or robot whisper.
                    parts.append((noise(734+index,duration,'air'),.13,0))
                stem={'wood':'impactWood_light_00','stone':'impactSoft_heavy_00','metal':'impactPlate_light_00','water':'impactGlass_light_00'}.get(material)
                if stem:
                    x,c=source('impact',stem+str(index),.8 if material!='water' else 1.35)
                    parts.append((x,.08 if role!='death' else .15,.02)); credits.append(c)
                if material=='fire': parts.append((noise(701+index,duration,'fire'),.08,0))
                if kind in ['breath','human']:
                    x,c=source('rpg','cloth'+str(index+1),1.0)
                    parts.append((x,.06,.01)); credits.append(c)
                # Peaks deliberately lower than weapon impacts, attack lower than hurt.
                result=mix(parts,duration)*(.34 if role=='attack' else .50 if role=='hurt' else .65)
                path=OUT/'sfx'/f'voice_{profile}_{role}_{index+1:02d}.wav'
                sf.write(path,result,RATE,subtype='PCM_16')
                records.append(dict(asset=str(path.relative_to(ROOT)),sources=credits,seconds=round(duration,3),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),design='Selected energy windows; organic pitch/size, room-noise filtering, restrained material layering, edge fades; no human vocal source on creature banks.'))
    manifest=OUT/'sources.json'
    data=json.loads(manifest.read_text(encoding='utf-8'))
    data['assets']=[r for r in data['assets'] if not Path(r['asset']).name.startswith('voice_')]+records
    data['licenses']['snarls']={'author':'Darsycho','license':'CC0-1.0','url':'https://opengameart.org/content/monster-snarls'}
    data['licenses']['cat']={'author':'Kerzoven','license':'CC0-1.0','url':'https://opengameart.org/content/cat-purr-meow'}
    manifest.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
    print('Built',len(records),'bounded species/role variants; other banks preserved.')

if __name__=='__main__': main()
