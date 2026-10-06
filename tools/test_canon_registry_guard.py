"""In-memory mutation checks: never edit production canon or art to test guards."""
from copy import deepcopy
from unittest import TestCase,main
from unittest.mock import patch
import json
import validate_canon_registry as guard
class CanonGuards(TestCase):
    def setUp(self): self.data=json.loads((guard.OUT/'CANON_REGISTRY.json').read_text(encoding='utf-8'))
    def rejected(self,data,expected=None):
        with patch.object(guard,'build',return_value=expected or data):
            with self.assertRaises(AssertionError): guard.main(data)
    def test_stale_generation(self):
        original=deepcopy(self.data); self.data['counts']['total_records']+=1
        self.rejected(self.data,original)
    def test_duplicate_stable_identity(self):
        self.data['entries'].append(self.data['entries'][0]); self.rejected(self.data)
    def test_missing_current_pose_identity(self):
        self.data['entries']=[e for e in self.data['entries'] if e['stable_id']!='gloomlet']; self.rejected(self.data)
    def test_rejected_runtime_source(self):
        self.data['entries'][0]['accepted_runtime_sources']=['res://'+self.data['rejected_runtime_paths'][0]];self.rejected(self.data)
    def test_missing_runtime_source(self):
        self.data['entries'][0]['accepted_runtime_sources']=['res://art/nonexistent_canon.png'];self.rejected(self.data)
    def test_rejected_identity_authority(self):
        self.data['entries'][0]['authoritative_source']=self.data['rejected_runtime_paths'][0];self.rejected(self.data)
    def test_empty_canonical_authority(self):
        self.data['entries'][0]['authoritative_source']='';self.rejected(self.data)
if __name__=='__main__': main()
