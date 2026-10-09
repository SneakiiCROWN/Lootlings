"""Reject stale coverage and automatic professional acceptance claims."""
import json
from build_production_dashboard import ROOT, OUT, STAGES, build

def validate():
    actual=json.loads((OUT/'PRODUCTION_DASHBOARD.json').read_text(encoding='utf-8'))
    assert actual==build(), 'Dashboard stale; rebuild from current registries and quality evidence'
    c=actual['counts']
    assert sum(r['required'] for r in actual['contract_families'])==c['required_contracts']
    assert sum(r['remaining'] for r in actual['contract_families'])==len(actual['remaining_contracts'])==c['remaining_contracts']
    assert c['required_contracts']==c['installed_contract_closures']+c['remaining_contracts']
    assert c['required_artist_files']==c['installed_artist_files']+c['remaining_artist_files']
    assert len({r['id'] for r in actual['records']})==len(actual['records'])
    for r in actual['records']:
        if r['quality']=='production_ready': assert all(r['stages'][s] for s in STAGES)
        if r['quality']=='missing': assert not r['stages']['production_quality_accepted']
    assert len(actual['domain_coverage'])==14
    print(json.dumps(c))

if __name__=='__main__':validate()
