"""Focused paired-policy report; raw per-run evidence stays alongside summaries."""
from pathlib import Path
import json, statistics, shutil, argparse
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser(); p.add_argument('label'); p.add_argument('log'); args=p.parse_args()
rows=[json.loads(line.split(' ',1)[1]) for line in Path(args.log).read_text(encoding='utf-8').splitlines() if line.startswith('HUMAN_SCRIP ')]
assert len(rows)==36
out=ROOT/'docs/production/humanqa'/args.label; out.mkdir(parents=True,exist_ok=True)
(out/'runs.json').write_text(json.dumps(rows,indent=2)+'\n')
def distribution(values):
    values=sorted(values)
    return {'min':values[0],'median':statistics.median(values),'p90':values[int((len(values)-1)*.9)],'max':values[-1]}
summary={}
for policy in ['cheap','save','search']:
    cohort=[r for r in rows if r['shopping']==policy]
    summary[policy]={'runs':len(cohort),'wins':sum(r['won'] for r in cohort)}
    for field in ['scrip_earned','scrip_spent','scrip_left','seconds','damage_taken','min_hp_ratio']:
        summary[policy][field]=distribution([r[field] for r in cohort])
    summary[policy]['spent_percent']=distribution([100*r['scrip_spent']/max(1,r['scrip_earned']) for r in cohort])
    summary[policy]['rerolls']=sum(s['action']=='reroll' for r in cohort for s in r['stops'])
    for wave in [6,11]:
        stops=[s for r in cohort for s in r['stops'] if s['wave']==wave and s['rerolls']==0]
        summary[policy][f'merchant_{wave}']={'wallet':distribution([s['wallet'] for s in stops]),'cheapest_wallet_ratio':distribution([min(s['price_wallet']) for s in stops]),'premium_wallet_ratio':distribution([max(s['price_wallet']) for s in stops])}
(out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
shutil.copy2(args.log,out/'human_scrip_runs.log')
print(json.dumps(summary,indent=2))
