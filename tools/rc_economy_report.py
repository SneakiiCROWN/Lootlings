"""Describe measured affordability and finite progression; never retune values."""
from pathlib import Path
import json, statistics, argparse
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser(); p.add_argument('folder',type=Path); a=p.parse_args()
rows=[json.loads(x) for x in (ROOT/'docs/production/phase3/rc-final/runs.jsonl').read_text().splitlines()][:384]
economy=next(json.loads(l.split(' ',1)[1]) for l in (a.folder/'phase3_economy.log').read_text().splitlines() if l.startswith('PHASE3_ECONOMY '))
def dist(v):
    v=sorted(v); return {k:round(statistics.median(v) if k=='p50' else v[round((len(v)-1)*q)],2) for k,q in [('min',0),('p10',.1),('p50',.5),('p90',.9),('max',1)]}
stops={}
for wave in [6,11]:
    held=[s['held'] for r in rows for s in r['segments'] if s['wave']==wave]
    stock=[b for b in economy['budgets'] if b['wave']==wave]
    median=statistics.median(held); ladder=[]; spent=0
    for count in range(1,5):
        spent+=18+wave*3+(count-1)*18
        ladder.append({'rerolls':count,'total_cost':spent,'remaining_at_median_arrival':median-spent,'fraction_of_sampled_new_inventories_with_any_affordable_offer':sum(median-spent>=b['cheapest'] for b in stock)/len(stock)})
    stops[str(wave)]={'arrival_scrip':dist(held),'cheapest':dist([b['cheapest'] for b in stock]),'all_stock_total':dist([b['total'] for b in stock]),'reroll_ladder':ladder,'qualification':'Affordability example at measured median wealth over 2000 seeded inventories; not a combat reroll policy, desirability score or guarantee of better gear.'}
progression=[]
for rank in [0,5,20,100]:
    progression.append({'training_rank':rank,'cumulative_shards':sum(10+i*5 for i in range(rank)),'base_hp_before_gear_trait_home':100*(1+rank*.05),'base_damage_before_gear_trait_home':11*(1+rank*.05)})
report={'run_policy':'Four taps/sec, sustain/core priorities, preserves starting weapon, cheapest affordable nonweapon shopping, no rerolls. Does not model all human choices.','stops':stops,'progression_formula_table':progression,'home_upgrade_total_gold':11700,'regular_drop_trials':economy['trials'],'regular_drops':economy['regular_drops'],'rarities':economy['regular_rarities'],'longest_drought':economy['longest_drought'],'successive_duplicate':economy['successive_duplicate'],'permanent_prices':economy['persistent_prices'],'cache_cost':economy['cache_cost'],'cache_expected_salvage':economy['cache_expected_salvage'],'finite_progression_limit':'Shard training stops at rank100; all three home ladders stop at5 and Forge at2 stages/item. Shards can accumulate after training is complete. Gold/Scrap retain item/cache/service uses, but usefulness diminishes after an ideal loaded collection. This is a known finite-content/long-term economy limit, not proven endless replay depth.'}
out=ROOT/'docs/production/predevice/economy.json'; out.write_text(json.dumps(report,indent=2)); print(json.dumps(report,indent=2))
