from pathlib import Path
import argparse, json, statistics, collections
p=argparse.ArgumentParser(); p.add_argument('folder',type=Path); p.add_argument('--label',required=True); args=p.parse_args()
root=Path(__file__).resolve().parents[1]
def rows(name,prefix):
    return [json.loads(l[len(prefix):]) for l in (args.folder/name).read_text().splitlines() if l.startswith(prefix+'{')]
roster=rows('phase3_roster_runs.log','PHASE3_ROSTER ')
assert len(roster)==192 and all('won' in r for r in roster)
out=root/'docs/production/phase3'/args.label; out.mkdir(exist_ok=True,parents=True)
(out/'roster.jsonl').write_text(''.join(json.dumps(r,separators=(',',':'))+'\n' for r in roster))
summary={}
for actor in sorted({r['actor'] for r in roster}):
    for kit in ['shared','identity']:
        group=[r for r in roster if r['actor']==actor and r['kit']==kit]
        summary[actor+'/'+kit]={'wins':sum(r['won'] for r in group),'runs':len(group),'hp_min':min(r['hp'] for r in group),'median_seconds':round(statistics.median(r['seconds'] for r in group),2),'lowest_wave':min(r['wave'] for r in group)}
        print(actor,kit,summary[actor+'/'+kit])
pressure=rows('phase3_pressure_qa.log','PHASE3_PRESSURE ')
marginal=rows('phase3_pressure_qa.log','PHASE3_MARGINAL ')
identity=rows('phase3_pressure_qa.log','PHASE3_IDENTITY_DPS ')
assert len(pressure)==110 and len(marginal)==12 and len(identity)==12
summary['pressure']=pressure; summary['marginal']=marginal; summary['identity_dps']=identity
(out/'values.json').write_text(json.dumps(summary,indent=2))
print('Pressure',min(r['incoming_dps'] for r in pressure),max(r['incoming_dps'] for r in pressure))
