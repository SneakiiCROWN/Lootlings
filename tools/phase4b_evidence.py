"""Summarize existing isolated Phase 4B evidence; never launches tests or touches saves."""
import hashlib, json, math, re, statistics
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/production/phase4b'
LOGS = ROOT / '.godot_test_data/qa_logs'

def records(folder, file, prefix):
    path = next(LOGS.glob(folder + '/' + file))
    return [json.loads(line[len(prefix):]) for line in path.read_text(encoding='utf-8').splitlines() if line.startswith(prefix)]

def distribution(values):
    values = sorted(values)
    return {'min': values[0], 'p50': statistics.median(values), 'p90': values[min(len(values)-1, math.ceil(len(values)*.9)-1)], 'max': values[-1]}

def cohort(rows, fields):
    return {'runs': len(rows), 'wins': sum(x['won'] for x in rows), **{field: distribution([x[field] for x in rows]) for field in fields}}

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    baseline = json.loads((ROOT/'docs/production/phase4a/runs.json').read_text(encoding='utf-8'))['tiers']
    tiers = records('phase4b-live-balance-*', 'phase4b_tier_runs.log', 'PHASE4B_TIER ')
    runs = records('phase4b-final-functional-*', 'phase4b_runs.log', 'PHASE4B_RUN ')
    metrics = {'baseline_commit': '05d32f3', 'engine': '4.7.2.stable', 'combat_policy': 'fresh saves; owned starter; no meta power; Sustain policy; deliberate extra taps; buy Prism if affordable; no victory quota', 'tiers': {}}
    for tier in range(3):
        metrics['tiers'][tier] = {label: cohort([x for x in rows if x['tier']==tier], ['seconds','damage_taken','scrip_earned','scrip_spent','level','min_hp_ratio']) for label, rows in [('before', baseline), ('after', tiers)]}
    metrics['modes'] = {}
    for mode, target in [('siege',10),('siege',20),('siege',40),('dungeon',0)]:
        rows = [x for x in runs if x['mode']==mode and x['extract_at']==target]
        result = cohort(rows, ['seconds','damage','earned','spent','left','lowest_hp','materials','elites','gold'])
        result['ttk_seconds'] = distribution([t for x in rows for t in x['ttk']])
        metrics['modes'][f'{mode}:{target}'] = result
    economy = records('phase4b-accepted-state-*','phase4b_qa.log','PHASE4B ECONOMY ')[0]
    seconds = metrics['modes']['dungeon:0']['seconds']['p50']
    economy.update({'measured_dungeon_p50_seconds': seconds, 'p50_minutes_combat_only': 24*seconds/60, 'p90_minutes_combat_only':24*seconds/60, 'guaranteed_24_clear_minutes_with_1_to_3_minute_human_clears': [24,72], 'spinner_expected_per_run': {'regional_material_units':3.0,'mastery_each_actor_and_weapon':6.3,'recipe_fragments':.45}, 'spinner_costs':[140,230,360], 'time_excludes_human_reading_travel_and_failed_attempts':True})
    metrics['economy']=economy
    # Conservative RGBA8 all-assets upper bound, not actual residency or Android PSS.
    textures=[]; duplicates={}
    for path in (ROOT/'art').rglob('*.png'):
        if any(part in ['reference','source'] for part in path.parts) or not path.with_suffix('.png.import').exists(): continue
        config=path.with_suffix('.png.import').read_text(encoding='utf-8')
        with Image.open(path) as image: width,height=image.size
        match=re.search(r'process/size_limit=(\d+)',config); limit=int(match.group(1)) if match else 0
        if limit and max(width,height)>limit:
            factor=limit/max(width,height); width=round(width*factor);height=round(height*factor)
        memory=width*height*4*(4/3 if 'mipmaps/generate=true' in config else 1)
        textures.append({'path':path.relative_to(ROOT).as_posix(),'width':width,'height':height,'rgba8_bytes':round(memory)})
        digest=hashlib.sha256(path.read_bytes()).hexdigest();duplicates.setdefault(digest,[]).append(path.relative_to(ROOT).as_posix())
    metrics['texture_audit']={'assets':len(textures),'all_assets_rgba8_upper_bound_mib':sum(x['rgba8_bytes'] for x in textures)/1048576,'exact_duplicate_groups':[v for v in duplicates.values() if len(v)>1], 'largest':sorted(textures,key=lambda x:x['rgba8_bytes'],reverse=True)[:15], 'not_actual_residency':True}
    (OUT/'metrics.json').write_text(json.dumps(metrics,indent=2),encoding='utf-8')
    (OUT/'runs.json').write_text(json.dumps({'frozen_baseline_tiers':baseline,'corrected_tiers':tiers,'current_modes':runs},indent=2),encoding='utf-8')
    print(json.dumps({'modes':{k:{'runs':v['runs'],'wins':v['wins'],'seconds':v['seconds']['p50']} for k,v in metrics['modes'].items()},'red_minutes_combat_only':economy['p50_minutes_combat_only'],'texture_bound_mib':metrics['texture_audit']['all_assets_rgba8_upper_bound_mib']},indent=2))

if __name__=='__main__': main()
