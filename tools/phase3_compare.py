"""Compare disjoint frozen cohorts and preserve distribution evidence."""
from pathlib import Path
import json, statistics, collections, argparse
ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(); p.add_argument('candidate', type=Path); args = p.parse_args()
base = [json.loads(x) for x in (ROOT/'docs/production/phase3/baseline/runs.jsonl').read_text().splitlines()]
final = [json.loads(x) for x in args.candidate.read_text().splitlines()]
assert len(base) == len(final) == 512
def dist(values):
    v = sorted(values)
    return {'p10':round(v[round((len(v)-1)*.1)],2),'p50':round(statistics.median(v),2),'p90':round(v[round((len(v)-1)*.9)],2),'min':round(v[0],2),'max':round(v[-1],2)} if v else None
def summary(rows):
    return {'runs':len(rows),'wins':sum(r['won'] for r in rows), **{k:dist([r[k] for r in rows]) for k in ['seconds','damage_taken','min_hp_ratio','scrip_earned','scrip_spent','scrip_left','decisions']},'boss_seconds':dist([f['ttk'] for r in rows for f in r['foes'] if f['wave']==15]),'foe_seconds':dist([f['ttk'] for r in rows for f in r['foes']]),'rarities':dict(collections.Counter(i['rarity'] for r in rows for i in r['loot']))}
report = {}
for name, a, b in [('weapons',base[:384],final[:384]),('campaigns',base[384:464],final[384:464]),('actors',base[464:],final[464:])]:
    report[name] = {'baseline':summary(a),'candidate':summary(b)}
    print(name,json.dumps(report[name]))
report['weapon_core'] = {}
for weapon, core in sorted({(r['weapon'],r['core']) for r in base[:384]}):
    key = weapon+'/'+core
    report['weapon_core'][key] = {label:summary([r for r in rows[:384] if (r['weapon'],r['core'])==(weapon,core)]) for label,rows in [('baseline',base),('candidate',final)]}
report['campaign'] = {c:{label:summary([r for r in rows[384:464] if r['campaign']==c]) for label,rows in [('baseline',base),('candidate',final)]} for c in sorted({r['campaign'] for r in base})}
target = args.candidate.parent/'comparison.json'; target.write_text(json.dumps(report,indent=2))
print(target)
