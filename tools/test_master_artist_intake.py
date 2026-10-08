"""Adversarial intake tests; existing art bytes only, never runtime fixtures."""
import unittest,tempfile,json,hashlib
from unittest.mock import patch
from pathlib import Path
from PIL import Image
import master_artist_intake as intake

class IntakeTests(unittest.TestCase):
    def test_schema_measurements(self):
        schema=intake.read(intake.DOC/'schemas/companion_state_sidecar.schema.json')
        self.assertTrue(intake.validate_schema({'entity_id':'fake'},schema))
        self.assertTrue(intake.markers({'palms':[intake.__name__,'MEASURE_FROM_DELIVERED_PIXELS']}))
        self.assertTrue(intake.validate_schema(float('nan'),{'type':'number'}))
    def test_unknown_and_empty_apply(self):
        with tempfile.TemporaryDirectory(dir=intake.ROOT/'.godot_test_data') as tmp:
            root=Path(tmp);result=intake.validate(root);self.assertTrue(result['empty_inbox'])
            with self.assertRaises(ValueError):intake.apply(result,root)
            (root/'unapproved_board.png').write_bytes(b'not art')
            result=intake.validate(root);self.assertEqual(result['overall'],'FAIL')
    def test_path_safety(self):
        for path in ['../escape.png','C:/escape.png','art/../../escape.png']:
            with self.assertRaises(ValueError):intake.safe(intake.ROOT,path)
    def test_exact_batch_missing_layers(self):
        batch=intake.read(intake.DOC/'NEXT_ART_BATCH.json')
        with tempfile.TemporaryDirectory(dir=intake.ROOT/'.godot_test_data') as tmp:
            result=intake.validate(Path(tmp),batch)
            self.assertEqual(len(result['results']),27)
            self.assertEqual(result['overall'],'NEEDS_ARTIST_CORRECTION')
            self.assertTrue(all(not x['runtime_apply_ready'] for x in result['results']))
    def test_actual_png_bounds_canvas(self):
        path=intake.ROOT/'art/production/phase4e/lootlings/gloomlet/bow/gloomlet_bow_windup_right.png'
        self.assertEqual(intake.png_errors(path,[512,512],[16,16,496,496]),[])
        self.assertIn('Wrong canvas',intake.png_errors(path,[256,256]))
        self.assertTrue(intake.png_errors(path,[512,512],[200,200,300,300]))
    def test_structural_is_not_visual_acceptance(self):
        row=intake.read(intake.DOC/'NEXT_ART_BATCH.json')['items'][0]
        self.assertFalse(intake.review_ready(row,intake.INBOX,{},[]))
    def test_all_batch_cells_and_files_once(self):
        spec=intake.read(intake.DOC/'LOOTLINGS_MASTER_ART_DELIVERY_SPEC.json')
        paths=[];ids=[]
        for path in sorted((intake.DOC/'batches').glob('artist_*.json')):
            batch=intake.read(path);ids+=batch['slot_ids'];paths += [x['source_delivery_path'] for x in batch['files']]
        self.assertEqual(len(ids),len(set(ids)))
        self.assertEqual(set(ids),{x['slot_id'] for x in spec['outstanding_deliverables']})
        self.assertEqual(len(paths),8495);self.assertEqual(len(set(paths)),8495)
        nextbatch=intake.read(intake.DOC/'NEXT_ART_BATCH.json')
        self.assertEqual(len(set(nextbatch['characters'])),7)

    def test_independent_pass_survives_failed_sibling_and_transaction(self):
        report={'overall':'FAIL','empty_inbox':False,'results':[
            {'slot_id':'missing','runtime_apply_ready':False},
            {'slot_id':'bad_install','runtime_apply_ready':True},
            {'slot_id':'good','runtime_apply_ready':True}]}
        with patch.object(intake,'apply',side_effect=[ValueError('guard failure'),None]) as install:
            result=intake.apply_independent(report,intake.INBOX)
            self.assertEqual(result['installed_slot_ids'],['good'])
            self.assertEqual(result['installation_failures'],[{'slot_id':'bad_install','reason':'guard failure'}])
            self.assertEqual(install.call_count,2)
            self.assertEqual(install.call_args.args[0]['results'][0]['slot_id'],'good')
    def test_full_program_equals_master_scope(self):
        spec=intake.read(intake.DOC/'LOOTLINGS_MASTER_ART_DELIVERY_SPEC.json')
        program=intake.read(intake.ROOT/'docs/production/full-completion/FULL_GAME_COMPLETION_PROGRAM.json')
        self.assertEqual(program['counts']['outstanding_contract_records'],len(spec['outstanding_deliverables']))
        self.assertEqual(program['counts']['total_artist_files'],len(spec['artist_files']))

    def test_registered_unknown_master_identity_is_rejected(self):
        with self.assertRaises(KeyError):
            intake.validate_installed_registrations([{'master_artist_slot_id':'invented_actor:fake_state'}])
    def test_already_installed_is_not_requested_again(self):
        report={'unknown_files':[],'results':[{'slot_id':'accepted','already_installed':True}]}
        q=intake.correction_queue(report,{'installed_slot_ids':[],'installation_failures':[]})
        self.assertEqual(q['remaining_exact_slots'],0)
        self.assertEqual(q['installed_PASS_count'],1)
        self.assertEqual(q['newly_installed_PASS_count'],0)

if __name__=='__main__':unittest.main()
