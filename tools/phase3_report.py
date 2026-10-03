"""Preserve individual Godot runs and distribution evidence, never set tuning."""
from pathlib import Path
import argparse, json, statistics, collections

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('log', type=Path)
p.add_argument('--label', required=True)
args = p.parse_args()
rows = [json.loads(line.split(' ', 1)[1]) for line in args.log.read_text(encoding='utf-8').splitlines() if line.startswith('PHASE3_RUN ')]
assert len(rows) == 512, f'Incomplete evidence: {len(rows)}'
out = ROOT/'docs/production/phase3'/args.label
out.mkdir(parents=True, exist_ok=True)
(out/'runs.jsonl').write_text(''.join(json.dumps(r, separators=(',', ':'))+'\n' for r in rows), encoding='utf-8')

def distribution(values):
    values = sorted(values)
    if not values: return None
    return {key: round(values[round((len(values)-1)*q)], 3) for key,q in [('min',0),('p10',.1),('p50',.5),('p90',.9),('p99',.99),('max',1)]} | {'mean': round(statistics.mean(values),3)}

def summarize(group):
    foes = [f for r in group for f in r['foes']]
    return {'runs':len(group), 'wins':sum(r['won'] for r in group),
            **{key:distribution([r[key] for r in group]) for key in ['seconds','damage_taken','min_hp_ratio','level','scrip_earned','scrip_spent','scrip_left','scrap','gold','shards','decisions']},
            'foe_ttk':distribution([f['ttk'] for f in foes]),
            'effective_dps':distribution([f['effective_dps'] for f in foes]),
            'boss_seconds':distribution([f['ttk'] for f in foes if f['wave']==15]),
            'rarities':dict(collections.Counter(item['rarity'] for r in group for item in r['loot'])),
            'timeout':sum(r['state']!='result' for r in group),
            'weak_to_strong_samples':[{'sample':r['sample'],'seed':r['seed'],'wave':r['wave'],'hp':round(r['hp'],2),'seconds':round(r['seconds'],2)} for r in sorted(group,key=lambda r:(r['won'],r['wave'],r['min_hp_ratio'],-r['seconds']))],
            'loot_luck_samples':[{'sample':r['sample'],'seed':r['seed'],'won':r['won'],'rarity_score':sum(['COMMON','RARE','EPIC','LEGENDARY'].index(i['rarity']) for i in r['loot']),'loot':r['loot']} for r in sorted(group,key=lambda r:sum(['COMMON','RARE','EPIC','LEGENDARY'].index(i['rarity']) for i in r['loot']))]}

summary = {}
for fields in [('weapon','core'),('campaign',),('actor','policy')]:
    groups = collections.defaultdict(list)
    # The frozen harness order defines three disjoint measurement cohorts.
    # Never mix 80 campaign rows into the small Relic Beast actor sample.
    cohort = rows[:384] if fields==('weapon','core') else rows[384:464] if fields==('campaign',) else rows[464:]
    for r in cohort:
        groups['/'.join(str(r[f]) for f in fields)].append(r)
    summary['+'.join(fields)] = {key:summarize(group) for key,group in groups.items()}
(out/'distributions.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print('Evidence:',out)
for key,group in summary['weapon+core'].items():
    print(key, f"{group['wins']}/{group['runs']}", 'median seconds',group['seconds']['p50'],'boss',group['boss_seconds'])
