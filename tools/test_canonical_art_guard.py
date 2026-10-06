"""Exercise rejection paths without editing a canonical source or game manifest."""
import copy,json,unittest
from pathlib import Path
from unittest.mock import patch
import validate_canonical_art as guard

class CanonGuard(unittest.TestCase):
    def check_mutation(self,path,mutate):
        original=Path.read_text
        data=json.loads(original(path,encoding='utf-8'))
        mutate(data)
        def read(p,*args,**kwargs):
            return json.dumps(data) if p==path else original(p,*args,**kwargs)
        with patch.object(Path,'read_text',read),self.assertRaises(ValueError): guard.validate()
    def test_current_sources_remain_valid(self):
        self.assertEqual(guard.validate()['approved_boss_frames'],0)
    def test_frozen_source_drift_is_rejected(self):
        self.check_mutation(guard.ROOT/'art/reference/phase4e_handoff/REFERENCE_STATUS.json',lambda d:d['frozen_sources'][0].update(sha256='0'*64))
    def test_reference_board_cannot_be_a_pose(self):
        def mutate(d):
            row=copy.deepcopy(next(r for r in d['entries'] if r['production_status']=='authored_beta'))
            row.update(phase='HURT',asset_path='res://art/reference/phase4e_handoff/approved_references/03_Gloomlet_Combat_Canonical_Reference.png')
            d['entries'].append(row)
        self.check_mutation(guard.ROOT/'art/production_pose_manifest.json',mutate)
    def test_new_pose_requires_source_and_approval(self):
        def mutate(d):
            row=copy.deepcopy(next(r for r in d['entries'] if r['production_status']=='authored_beta'))
            row['phase']='HURT'; d['entries'].append(row)
        self.check_mutation(guard.ROOT/'art/production_pose_manifest.json',mutate)
    def test_existing_pose_cannot_silently_swap_bodies(self):
        def mutate(d):
            row=next(r for r in d['entries'] if r['production_status']=='authored_beta')
            row['asset_path']='res://art/sprites/lootlings/moonkip_idle.png'
        self.check_mutation(guard.ROOT/'art/production_pose_manifest.json',mutate)
    def test_boss_board_cannot_claim_approval(self):
        self.check_mutation(guard.ROOT/'art/production_boss_manifest.json',lambda d:d['entries'].append(dict(region='act_i',state='idle',action='',facing='right',production_status='owner_approved_beta',owner_approval='test-only fake',asset_path='res://art/reference/phase4e_handoff/approved_references/01_Hoard_Dragon_Canonical_Reference.png',source_reference='res://art/reference/phase4e_handoff/approved_references/01_Hoard_Dragon_Canonical_Reference.png')))
    def test_body_extraction_cannot_use_board_identity(self):
        def mutate(d):
            row=next(r for r in d['entries'] if r['kind']=='body')
            row['source']='art/reference/phase4e_handoff/approved_references/03_Gloomlet_Combat_Canonical_Reference.png'
            row['source_sha256']=guard.sha_file(guard.ROOT/row['source'])
        self.check_mutation(guard.ROOT/'art/production/phase4e/extraction_manifest.json',mutate)
    def test_idle_export_cannot_claim_an_attack(self):
        self.check_mutation(guard.ROOT/'art/production/phase4e/runtime_manifest.json',lambda d:d['entries'][0].update(phase='ATTACK'))

if __name__=='__main__': unittest.main()
