"""Cheap current-identity, rejected-source and authority-boundary checks.

Use alongside validate_canonical_art.py (frozen hashes/approval) and
validate_master_integration.py (source freshness/matrix parity).
"""
import json,re
from build_canon_registry import ROOT,OUT,build
def main():
    actual=json.loads((OUT/'CANON_REGISTRY.json').read_text(encoding='utf-8'))
    assert actual==build(),'Stale/edited registry: regenerate from existing catalogs and contracts'
    keys=[(e['category'],e['stable_id']) for e in actual['entries']]
    assert len(keys)==len(set(keys)),'Conflicting stable identity'
    master=json.loads((OUT/'MASTER_INTEGRATION_MANIFEST.json').read_text(encoding='utf-8'))
    pose_ids={r['game_id'] for r in master['records'] if r['slot_id'].startswith('pose:')}
    assert pose_ids <= {e['stable_id'] for e in actual['entries']},'Current pose identity absent from canon registry'
    for entry in actual['entries']:
        assert isinstance(entry['authoritative_source'],str) and entry['authoritative_source']
        for source in entry['accepted_runtime_sources']:
            assert source.removeprefix('res://') not in actual['rejected_runtime_paths'],'Rejected source promoted to canon'
            assert (ROOT/source.removeprefix('res://')).is_file(),source
    for script in ROOT.glob('*.gd'):
        for path in re.findall(r'(?:preload|load)\("(res://[^"\n]+)"\)',script.read_text(encoding='utf-8-sig')):
            assert path.removeprefix('res://') not in actual['rejected_runtime_paths'],'Rejected runtime board: '+str(script)
    for doc in ['PRODUCTION_PHASE4E.md','CONTENT_IMPLEMENTATION_STATUS.md']:
        text=(ROOT/doc).read_text(encoding='utf-8')
        assert text.count('## CURRENT —')==1
        _,history=text.split('## HISTORICAL / SUPERSEDED — DO NOT USE FOR CURRENT DECISIONS',1)
        assert not re.search(r'(?im)^(?:#+\s*)?current\b',history),'Ambiguous historical current heading: '+doc
        assert 'START_HERE_CURRENT.md' in text.split('## HISTORICAL')[0]
    assert sum(e['category']=='lootling' for e in actual['entries'])==7
    assert sum(e['category']=='wanderer' for e in actual['entries'])==5
    assert sum(e['category']=='weapon' for e in actual['entries'])==12
    print(json.dumps({'identities':len(keys),'catalog_screen_routes':len(actual['runtime_slot_coverage']),'rejected_board_paths':len(actual['rejected_runtime_paths']),'authority_boundaries':2,'frozen_hash_guard':'validate_canonical_art.py','matrix_guard':'validate_master_integration.py'}))
if __name__=='__main__': main()
