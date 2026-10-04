"""Preserve the no-tap breadth cohort separately from paired baseline results."""
from pathlib import Path
import argparse, json, statistics
p = argparse.ArgumentParser(); p.add_argument('log', type=Path); p.add_argument('--label', default='final-idle'); a = p.parse_args()
rows = [json.loads(line.removeprefix('PHASE3_IDLE ')) for line in a.log.read_text().splitlines() if line.startswith('PHASE3_IDLE {')]
assert len(rows) == 96 and all(r['policy'] == 'idle' for r in rows)
out = Path(__file__).resolve().parents[1]/'docs/production/phase3'/a.label; out.mkdir(parents=True, exist_ok=True)
(out/'runs.jsonl').write_text(''.join(json.dumps(r,separators=(',',':'))+'\n' for r in rows))
summary = {}
for actor in sorted({r['actor'] for r in rows}):
    cohort = [r for r in rows if r['actor'] == actor]
    summary[actor] = {'runs':len(cohort),'wins':sum(r['won'] for r in cohort),'median_seconds':round(statistics.median(r['seconds'] for r in cohort),2),'lowest_wave':min(r['wave'] for r in cohort),'min_hp_ratio':min(r['min_hp_ratio'] for r in cohort)}
(out/'summary.json').write_text(json.dumps(summary,indent=2))
print(json.dumps(summary,indent=2)); print('Total wins',sum(r['won'] for r in rows),'of',len(rows))
