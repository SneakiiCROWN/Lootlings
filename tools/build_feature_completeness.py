"""Two completion views, no contract removals or inferred art acceptance."""
from pathlib import Path
from collections import Counter,defaultdict
import json,hashlib
R=Path(__file__).resolve().parents[1];C=R/'docs/production/full-completion/continuous-production'
def read(p):return json.loads((R/p).read_text(encoding='utf-8-sig'))
def build(quality=None):
 queue=read(C.relative_to(R).as_posix()+'/EXACT_REMAINING_CONTRACTS.json');counts=read(C.relative_to(R).as_posix()+'/CONTINUOUS_PRODUCTION_COUNTS.json');assert len(queue)==counts['remaining_contracts']
 groups=defaultdict(list);files=Counter();types=Counter();features=defaultdict(list)
 for row in queue:
  key=(row['entity_id'],row.get('state',row['slot_id']),row.get('facing','not-applicable'));groups[key].append(row);features[(row['category'],row['entity_id'])].append(row)
  for path in row['required_files']:
   files[path]+=1;types['metadata' if path.endswith('.json') else 'grip_or_layer' if any(s in path for s in ['grip','foreground','support','socket']) else 'painted_body_or_prop' if path.endswith('.png') else 'other']+=1
 listed_total=sum(files.values())
 discrepancy=listed_total-counts['remaining_artist_files']
 bundles=[dict(identity=k[0],state=k[1],facing=k[2],contracts=len(v),weapons=sorted({str(x.get('weapon_family')) for x in v}),slot_ids=[x['slot_id'] for x in v],canon=sorted({p for x in v for p in x.get('canonical_authority_files',[])}),status='Candidate shared source dependency; compatibility, grips and native selectors must be proven before reuse. Not a closed asset.') for k,v in sorted(groups.items())]
 quality=quality or read('docs/production/PRODUCTION_DASHBOARD.json');sample=read('docs/production/quality-evidence/0.4.51/CONTACT_MATRIX.json');sample=sample if isinstance(sample,list) else sample.get('cases',sample.get('records',[]))
 family_views=[]
 for entry in quality['requirement_families']:
  family_views.append(dict(family=entry['family'],installed_records=entry['installed_records'],missing_records=entry['quality_counts'].get('missing',0),visually_unfinished_or_unreviewed=sum(v for k,v in entry['quality_counts'].items() if k!='production_ready'),production_ready=entry['production_ready'],fluid_animation_families=None,acceptance='Not feature-complete merely because records exist or tests pass.'))
 return dict(schema_version=1,contract_coverage=counts,listed_remaining_file_paths=listed_total,legacy_artist_count_discrepancy=discrepancy,accounting_note="Exact queue lists 7289 unique paths; legacy remaining-file ledger says7178. 111-path discrepancy is open, not a closure or unique illustration estimate. No ledger requirements removed.",remaining_file_requirements_by_dependency=dict(types),unique_named_remaining_paths=len(files),duplicate_named_path_requirements=sum(n-1 for n in files.values()),unique_illustrations_required=None,illustration_note='PNG dependencies include layers; metadata is not illustration. Shared body/state/view groups are opportunities, not automatic compatibility or count reductions.',shared_body_state_view_groups=len(bundles),multi_weapon_candidate_groups=sum(x['contracts']>1 for x in bundles),bundles=bundles,player_facing_features=family_views,actor_features=[dict(category=k[0],actor=k[1],missing_contracts=len(v),missing_states=sorted({x.get('state','support dependency') for x in v}),missing_facings=sorted({x.get('facing','not-applicable') for x in v}),remaining_weapons=sorted({str(x.get('weapon_family')) for x in v}),full_fluid_animation_accepted=False,priority='Existing live actor source/contact gaps first; verify launch scope before treating expansion as release blocker.') for k,v in sorted(features.items())],sampled_player_cases=len(sample),sampled_body_fallbacks=sum(bool(x.get('body_fallback')) for x in sample),release_critical_vs_optional='Unresolved at exact-contract level; master launch scope records retained. No requirements reclassified without evidence.',unregistered_dependencies=quality['unregistered_dependencies'],professionally_accepted_feature_count=0)
if __name__=='__main__':
 d=build();out=R/'docs/production/FEATURE_COMPLETENESS.json';out.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8');print(json.dumps({k:d[k] for k in ['remaining_file_requirements_by_dependency','unique_named_remaining_paths','duplicate_named_path_requirements','shared_body_state_view_groups','multi_weapon_candidate_groups','sampled_player_cases','sampled_body_fallbacks']}))
