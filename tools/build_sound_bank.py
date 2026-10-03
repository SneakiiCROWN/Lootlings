"""Offline sound design from verified CC0 recordings; no runtime synthesis.

Sources live in ignored .godot_test_data/audio_sources. Install soundfile in
.godot_test_data/audio_python or use an environment containing numpy/soundfile.
Exact source filenames, hashes and transformations are saved beside the bank.
"""
from pathlib import Path
import sys, json, hashlib, re, wave
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.godot_test_data/audio_python'))
import numpy as np
import soundfile as sf
SOURCE=ROOT/'.godot_test_data/audio_sources'
OUT=ROOT/'art/audio/production'
RATE=48000
records=[]

def source(pack, stem, speed=1):
    candidates=[p for p in (SOURCE/pack).rglob('*.ogg') if p.stem==stem or stem in p.stem]
    p=sorted(candidates)[0]
    x,rate=sf.read(p,dtype='float32',always_2d=True);x=x.mean(axis=1)
    active=np.where(np.abs(x)>.004)[0]
    if len(active):x=x[max(0,active[0]-int(rate*.012)):min(len(x),active[-1]+int(rate*.035))]
    x=np.interp(np.arange(int(len(x)*RATE/rate/speed))*rate*speed/RATE,np.arange(len(x)),x)
    return x,dict(pack=pack,file=str(p.relative_to(SOURCE/pack)),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),speed=speed)

def mix(parts, duration=.5):
    y=np.zeros(int(RATE*duration))
    for x,gain,delay in parts:
        start=int(delay*RATE);n=min(len(x),len(y)-start)
        if n>0:y[start:start+n]+=x[:n]*gain
    y-=y.mean()
    # Short edge fades, soft transient saturation, peak headroom.
    y=np.tanh(y*1.15)
    n=min(480,len(y)//8);y[:n]*=np.linspace(0,1,n);y[-n:]*=np.linspace(1,0,n)
    peak=max(.001,np.abs(y).max());y*=.68/peak
    return y

def noise(seed,duration,kind):
    rng=np.random.default_rng(seed);n=int(RATE*duration);t=np.arange(n)/RATE
    x=rng.normal(0,1,n)
    # Frequency-shaped air/rumble, not an exposed pitched game beep.
    spectrum=np.fft.rfft(x);freq=np.fft.rfftfreq(n,1/RATE)
    if kind=='air':curve=np.exp(-((freq-1800)/1700)**2)
    elif kind=='fire':curve=1/(1+(freq/1700)**2)
    elif kind=='ward':curve=np.exp(-((freq-700)/650)**2)
    else:curve=np.exp(-((freq-4800)/2600)**2)
    y=np.fft.irfft(spectrum*curve,n);y/=max(.001,np.abs(y).max())
    return y*np.sin(np.pi*np.arange(n)/n)**.7

def save(event,index,x,credits):
    p=OUT/'sfx'/f'{event}_{index+1:02d}.wav';p.parent.mkdir(parents=True,exist_ok=True)
    sf.write(p,x,RATE,subtype='PCM_16')
    # Godot's default QOA import is incompatible with the bounded PCM loader.
    sidecar=p.with_suffix('.wav.import')
    if sidecar.exists():
        sidecar.write_text(re.sub(r'compress/mode=\d+', 'compress/mode=0', sidecar.read_text()),encoding='utf-8')
    records.append(dict(asset=str(p.relative_to(ROOT)),sources=credits,design='trim, mono downmix, speed/resample, layered delays, noise filtering, fade, saturation and peak -3.35 dBFS',seconds=round(len(x)/RATE,3),sha256=hashlib.sha256(p.read_bytes()).hexdigest()))

def main():
    specs=(ROOT/'audio_manager.gd').read_text()
    events=re.findall(r'"([a-z_]+)":\["(?:UI|SFX|Music|Ambience)"',specs)
    variants=set(re.search(r'const VARIANT_EVENTS := \[(.*?)\]',specs,re.S).group(1).replace('"','').replace(' ','').split(','))
    table={
        'normal_hit':('impact','impactPunch_medium'), 'heavy_hit':('impact','impactMetal_heavy'),
        'boss_hit':('impact','impactPlate_heavy'), 'crit':('impact','impactMetal_heavy'),
        'enemy_tank':('impact','impactWood_heavy'), 'enemy_skirmisher':('rpg','knifeSlice'),
        'equipment_drop':('rpg','metalPot'), 'scrap':('impact','impactTin_medium'),
        'gold_pickup':('rpg','handleCoins'), 'scrip_pickup':('rpg','handleCoins'),
        'resource_pickup':('rpg','handleSmallLeather'), 'xp_pickup':('rpg','cloth'),
        'ui_press':('rpg','metalClick'), 'upgrade_select':('rpg','metalLatch'),
        'menu_open':('rpg','bookOpen'), 'menu_close':('rpg','bookClose'),
        'menu_transition':('rpg','bookFlip'), 'equip':('rpg','beltHandle'),
        'shop_purchase':('rpg','handleCoins'), 'chest_land':('impact','impactWood_heavy'),
        'chest_windup':('rpg','creak'), 'chest_open':('rpg','doorOpen'),
    }
    for event in events:
        for i in range(4 if event in variants else 1):
            credits=[];parts=[];duration=.42
            if event in ['player_hurt','enemy_hurt','enemy_death','boss_death','exertion']:
                stem=['Track 2','Track 5','Track 6','Track 1'][i%4]
                speed=.68 if event=='boss_death' else .85 if event.startswith('enemy') else 1.18
                x,c=source('pain',stem,speed);credits.append(c);duration=min(1.8,max(.25,len(x)/RATE+.03));parts.append((x,.8,0))
            elif event in table:
                pack,stem=table[event];matches=sorted([p.stem for p in (SOURCE/pack).rglob('*.ogg') if p.stem.startswith(stem)])
                x,c=source(pack,matches[i%len(matches)],1+(i-1.5)*.025);credits.append(c);parts.append((x,.7,0));duration=min(1.5,max(.08,len(x)/RATE+.035))
                if event in ['crit','heavy_hit','boss_hit']:
                    x,c=source('impact','impactPunch_heavy_00'+str(i),.92);credits.append(c);parts.append((x,.55,.012))
            elif event in ['swing_staff','swing_wand','swing_orb']:
                duration={'swing_staff':.46,'swing_wand':.24,'swing_orb':.62}[event]
                parts.append((noise(200+i+sum(map(ord,event)),duration,'ward' if event=='swing_orb' else 'spark'),.5,0))
                x,c=source('impact','impactGlass_light_00'+str(i),.60 if event=='swing_staff' else 1.4);credits.append(c);parts.append((x[::-1],.3,.025))
            elif event in ['swing_bow','swing_crossbow','swing_sling','ranger_release']:
                duration=.18 if event=='swing_crossbow' else .26
                x,c=source('rpg','metalLatch' if event=='swing_crossbow' else 'cloth'+str(i+1),1.3);credits.append(c);parts.append((x,.65,0))
                parts.append((noise(600+i+sum(map(ord,event)),duration,'air'),.35,.02))
            elif event.startswith('swing_') or event in ['vanguard_swing','rogue_slash','tap_attack']:
                heavy=event in ['swing_maul','swing_greataxe','swing_greatsword','vanguard_swing']
                duration=.28 if heavy else .16
                parts.append((noise(100+i+sum(map(ord,event)),duration,'fire' if event=='swing_maul' else 'air'),.55,0))
                if event in ['swing_maul','swing_greataxe']:
                    x,c=source('rpg','cloth'+str(i+1),.75 if event=='swing_maul' else .95)
                else:x,c=source('rpg','knifeSlice'+('2' if i%2 else ''),.82 if heavy else 1.18)
                credits.append(c);parts.append((x,.26,.02))
            else:
                kind='fire' if event in ['magic_fire','explosion','boss_warning'] else 'ward' if event in ['ward','core_awaken','magic_poison'] else 'spark'
                duration=.7 if event in ['legendary_reveal','victory','defeat','boss_warning'] else .38
                parts.append((noise(320+i+sum(map(ord,event)),duration,kind),.5,0))
                stem='impactGlass_light_00'+str(i) if kind=='spark' else 'impactSoft_heavy_00'+str(i)
                x,c=source('impact',stem,1.15 if kind=='spark' else .72);credits.append(c);parts.append((x,.25,.04))
            save(event,i,mix(parts,duration),credits)
    manifest=OUT/'sources.json'
    previous=json.loads(manifest.read_text(encoding='utf-8')) if manifest.exists() else {}
    voices=[r for r in previous.get('assets',[]) if Path(r['asset']).name.startswith('voice_')]
    licenses=dict(previous.get('licenses',{}))
    licenses.update({'impact':{'author':'Kenney','license':'CC0-1.0','url':'https://kenney.nl/assets/impact-sounds'},'rpg':{'author':'Kenney','license':'CC0-1.0','url':'https://kenney.nl/assets/rpg-audio'},'pain':{'author':'Lasse Buehrmann / EmoPreben','license':'CC0-1.0','url':'https://opengameart.org/content/pain-sounds-by-emopreben'}})
    manifest.write_text(json.dumps(dict(licenses=licenses,original_layers='Deterministic frequency-shaped noise generated by this project; no franchise samples or model services.',assets=records+voices,superseded_reactions=previous.get('superseded_reactions',[])),indent=2)+'\n',encoding='utf-8')
    for cue in ['outer_ruins','salvage_warrens','hoard_depths','hideout']:
        rng=np.random.default_rng(sum(map(ord,cue)));n=RATE*12
        raw=rng.normal(0,1,n);spec=np.fft.rfft(raw);f=np.fft.rfftfreq(n,1/RATE)
        curve=1/(1+(f/(450 if cue=='hoard_depths' else 1100))**2)
        y=np.fft.irfft(spec*curve,n);y/=max(np.abs(y).max(),.001);y*=.065
        edge=RATE//5;y[:edge]*=np.linspace(0,1,edge);y[-edge:]*=np.linspace(1,0,edge)
        p=OUT/'ambience'/f'{cue}.wav';p.parent.mkdir(exist_ok=True);sf.write(p,y,RATE,subtype='PCM_16')
    print(f'Built {len(records)} bounded recorded/designed cues and four original low-noise ambience loops')

if __name__=='__main__':main()
