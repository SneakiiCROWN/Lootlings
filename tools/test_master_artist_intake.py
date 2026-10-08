"""Adversarial intake tests; existing art bytes only, never runtime fixtures."""
import unittest,tempfile,json,hashlib
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

if __name__=='__main__':unittest.main()
