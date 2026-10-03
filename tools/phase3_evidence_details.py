from pathlib import Path
import json, statistics, argparse
p=argparse.ArgumentParser(); p.add_argument('folder',type=Path); args=p.parse_args()
root=Path(__file__).resolve().parents[1]
def records(path,prefix):
    return [json.loads(l[len(prefix):]) for l in path.read_text().splitlines() if l.startswith(prefix+'{')]
def d(v):
    v=sorted(v)
    return {'min':v[0],'p10':v[round((len(v)-1)*.1)],'median':statistics.median(v),'p90':v[round((len(v)-1)*.9)],'max':v[-1]}
for label, path in [('baseline',root/'docs/production/phase3/baseline/economy.log'),('candidate',args.folder/'phase3_economy.log')]:
    row=records(path,'PHASE3_ECONOMY ')[0]
    print(label,{k:v for k,v in row.items() if k!='budgets'})
    for wave in [6,11]: print(label,'shop',wave,'cheapest',d([r['cheapest'] for r in row['budgets'] if r['wave']==wave]),'total',d([r['total'] for r in row['budgets'] if r['wave']==wave]))
for label,path in [('baseline',root/'docs/production/phase3/baseline/runs.jsonl'),('candidate',args.folder/'phase3_balance.log')]:
    rows=([json.loads(l) for l in path.read_text().splitlines()] if path.suffix=='.jsonl' else records(path,'PHASE3_RUN '))[:384]
    for wave in [6,11]: print(label,'held at shop',wave,d([s['held'] for r in rows for s in r['segments'] if s['wave']==wave]))
base=records(root/'docs/production/phase3/baseline/dps.log','PHASE3_DPS ')
final=records(args.folder/'phase3_dps.log','PHASE3_DPS ')
for r in base[:120]: # Twelve families, two input policies, five Core conditions.
    if r['core']=='Neutral' and r['policy']=='tap' and not r['upgrades']:
        f=next((x for x in final if (x['item'],x['policy'],x['core'],x['upgrades'])==(r['item'],r['policy'],r['core'],r['upgrades'])),None)
        print('DPS',r['item'],round(r['sustained_dps'],2),'->',round(f['sustained_dps'],2))
