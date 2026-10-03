"""Package accepted native captures and measurements, retaining superseded failures."""
from pathlib import Path
import json, shutil, statistics, hashlib
from PIL import Image
ROOT = Path(__file__).resolve().parents[1]
QA = ROOT/'.godot_test_data/qa_logs'
OUT = ROOT/'docs/production/phase3/final'
OUT.mkdir(parents=True, exist_ok=True)
full = QA/'phase3-final-regression-c169c0a1ed'
accepted = {r['name']:{**r,'run':full.name} for r in json.loads((full/'results.json').read_text())}
history = []
for label in ['phase3-isolation-repaired-98f1755076','phase3-native-regression-7fab37f8f6','phase3-native-audio-corrected-eaddad3cc8','phase3-pause-touch-final-b5620ef32b','phase3-final-smoke-62c80a0928','phase3-miniboss-final-ab4063d12c','phase3-idle-breadth-9e44f021b4','phase3-final-phone-details-999d8d670c','phase3-final-tablet-details-cbaf0cc682']:
    results = json.loads((QA/label/'results.json').read_text())
    for r in results:
        if r['exit'] or r['errors']: continue
        if r['name'] in accepted: history.append(accepted[r['name']])
        accepted[r['name']] = {**r,'run':label}
assert all(r['exit'] == 0 and not r['errors'] for r in accepted.values())
(OUT/'qa-results.json').write_text(json.dumps({'accepted':list(accepted.values()),'superseded':history,'qualification':'Headless renderer waits and obsolete assertions are preserved; native/repaired isolated fixtures supersede them. Native synthetic input is not physical-device or manual-play acceptance.'},indent=2))
for name in ['phase3_dps.log','phase3_economy.log','phase3_pressure_qa.log','combat_seed_diagnostics.log']:
    shutil.copyfile(full/name, OUT/name)
shutil.copyfile(ROOT/'builds/android/build-report.json',OUT/'android-build.json')
def records(path,prefix):
    return [json.loads(l[len(prefix):]) for l in path.read_text().splitlines() if l.startswith(prefix+'{')]
base = records(ROOT/'docs/production/phase3/baseline/dps.log','PHASE3_DPS ')
final = records(full/'phase3_dps.log','PHASE3_DPS ')
pairs = []
for b in base:
    if b['core'] != 'Neutral' or b['policy'] != 'tap' or b['upgrades']: continue
    f = next(x for x in final if (x['item'],x['policy'],x['core'],x['upgrades']) == (b['item'],b['policy'],b['core'],b['upgrades']))
    pairs.append({'item':b['item'],'baseline':b,'final':f})
rows = [json.loads(x) for x in (OUT/'runs.jsonl').read_text().splitlines()]
baseline = [json.loads(x) for x in (ROOT/'docs/production/phase3/baseline/runs.jsonl').read_text().splitlines()]
def dist(v):
    v = sorted(v)
    return {'min':round(v[0],3),'p10':round(v[round((len(v)-1)*.1)],3),'median':round(statistics.median(v),3),'p90':round(v[round((len(v)-1)*.9)],3),'max':round(v[-1],3)}
effective = {label:dist([f['hp']/f['ttk'] for r in rs[:384] for f in r['foes'] if f['ttk'] > 0]) for label,rs in [('baseline',baseline),('final',rows)]}
(OUT/'dps-comparison.json').write_text(json.dumps({'stationary_pairs':pairs,'completed_fight_effective_dps':effective},indent=2))
evidence = ROOT/'docs/production/phase3/evidence'; evidence.mkdir(exist_ok=True)
manifest = []
def copy(source,target):
    source = ROOT/source; dest = evidence/target; dest.parent.mkdir(parents=True,exist_ok=True)
    if source.suffix == '.png': Image.open(source).save(dest,format='WEBP',quality=90,method=4)
    else: shutil.copyfile(source,dest)
    manifest.append({'source':str(source.relative_to(ROOT)),'artifact':target,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'artifact_sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'presentation':'Full-resolution quality-90 WebP review copy; original native PNG preserved locally' if source.suffix == '.png' else 'Unmodified copy'})
for path in sorted((ROOT/'.godot_test_data/correction_matrix').glob('*.png')):
    copy(path.relative_to(ROOT),'matrix/'+path.stem+'.webp')
copy(Path('.godot_test_data/correction_matrix/report.json'),'matrix/report.json')
for size in ['1080x2316','1600x2560']:
    for path in sorted((ROOT/f'.godot_test_data/correction_screens/{size}/review').glob('*.jpg')):
        copy(path.relative_to(ROOT),f'screens-{size}/'+path.name)
    for path in sorted((ROOT/f'.godot_test_data/phase3_final_details/{size}').glob('*.png')):
        copy(path.relative_to(ROOT),f'final-{size}/'+path.stem+'.webp')
for path in sorted((ROOT/'.godot_test_data/phase3/480x854/review').glob('*.jpg')):
    copy(path.relative_to(ROOT),'miniboss/'+path.name)
for name in ['event_cursed_coffer','item_frostbell_seal','elite_reknitting','boss_act_i_p2_a3','numbers_large_combat']:
    path = Path('.godot_test_data/phase3/480x854')/(name+'.png')
    if (ROOT/path).exists(): copy(path,'content/'+name+'.webp')
(evidence/'manifest.json').write_text(json.dumps(manifest,indent=2))
print('Accepted checks:',len(accepted),'native artifacts:',len(manifest),'effective DPS:',effective)
print('Stationary neutral pairs:',len(pairs))
lines = ['# Phase 3 measured tables','', 'Godot 4.7.2; raw lab is one fixed 30-second seed. Combat cohorts use eight shared seeds per policy. Percentiles use nearest-index p10/p90 and the median; durations exclude menu dwell. Completed-fight DPS excludes unfinished fights, whose deaths remain in run outcomes.','', '## Raw starter weapon lab','', '| Starter | Sustained DPS baseline → final | 2s burst baseline → final | Attack interval baseline → final |','|---|---:|---:|---:|']
for pair in pairs[:12]:
    b,f = pair['baseline'],pair['final']
    lines.append(f"| {pair['item']} | {b['sustained_dps']:.2f} → {f['sustained_dps']:.2f} | {b['burst_2s_dps']:.2f} → {f['burst_2s_dps']:.2f} | {b['interval']:.3f}s → {f['interval']:.3f}s |")
comparison = json.loads((OUT/'comparison.json').read_text())
for cohort in ['weapons','campaigns','actors']:
    a,b = comparison[cohort]['baseline'],comparison[cohort]['candidate']
    lines += ['',f'## Paired {cohort} cohort', '',f"Completions: {a['wins']}/{a['runs']} → {b['wins']}/{b['runs']}.",'','| Measure | Baseline p10 / median / p90 | Final p10 / median / p90 |','|---|---:|---:|']
    for key in ['seconds','damage_taken','min_hp_ratio','boss_seconds','foe_seconds','scrip_earned','scrip_spent','scrip_left','decisions']:
        a1,b1 = a[key],b[key]
        lines.append(f"| {key} | {a1['p10']} / {a1['p50']} / {a1['p90']} | {b1['p10']} / {b1['p50']} / {b1['p90']} |")
roster = json.loads((OUT.parent/'final-broader/values.json').read_text())
idle = json.loads((OUT.parent/'final-idle/summary.json').read_text())
lines += ['','## Final roster breadth','','Each column has eight fresh seeds per actor. Shared and identity kits use tap/sustain; idle uses identity kit/sustain. This is policy sensitivity, not a player win-rate forecast.','','| Actor | Shared tap wins | Identity tap wins / median seconds | Identity idle wins / median seconds |','|---|---:|---:|---:|']
for actor, val in idle.items():
    s,i = roster[actor+'/shared'],roster[actor+'/identity']
    lines.append(f"| {actor} | {s['wins']}/8 | {i['wins']}/8 / {i['median_seconds']} | {val['wins']}/8 / {val['median_seconds']} |")
lines += ['','## Marginal contribution and incoming pressure','','Core delta is additional 30-second stationary DPS at tag-count 3, not a per-tag multiplier. Range, multi-target splash and per-foe perks cannot be reduced to this stationary number.','','| Family | Crit contribution DPS | Physical / Fire / Lightning / Poison DPS delta |','|---|---:|---:|']
for r in roster['marginal']:
    delta = ' / '.join(f"{r['core_delta'][core]:.2f}" for core in ['Physical','Fire','Lightning','Poison'])
    lines.append(f"| {r['weapon']} | {r['crit_delta']:.2f} | {delta} |")
lines += ['', '110 incoming-pressure samples cover all ten regions, three regular roles at waves 1/7/14, plus every miniboss and final boss. Each 60-second trial uses an untrained Vanguard with inflated HP, no attacks and phase-one bosses. Incoming DPS range: '+f"{min(r['incoming_dps'] for r in roster['pressure']):.3f}–{max(r['incoming_dps'] for r in roster['pressure']):.3f}. This estimates 100-HP pressure TTK, not actual lethal-run TTK. Both boss phases are covered separately by native action contracts.",'','Full per-sample arrays, failed outcomes, item luck ordering and min/max values are retained in JSON/JSONL. Do not conflate lucky loot with high final HP.']
(OUT/'METRICS.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
