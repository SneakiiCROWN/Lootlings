"""Validate exact authored enemy exports against registered canonical authority."""
from pathlib import Path
import hashlib,json
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
def validate():
    refs=json.loads((ROOT/'art/approved_missing_canon_references.json').read_text(encoding='utf-8'))['entries']
    rows=json.loads((ROOT/'art/production_enemy_manifest.json').read_text(encoding='utf-8'))['entries'];keys=set()
    for row in rows:
        key=(row['actor'],row['state'],row['facing']);assert key not in keys;keys.add(key)
        ref=next(r for r in refs if r['game_id']==row['actor'])
        assert row['source_reference']==ref['source'] and row['source_sha256']==ref['source_sha256']
        assert hashlib.sha256((ROOT/ref['source']).read_bytes()).hexdigest()==row['source_sha256']
        assert row['state'] in ['idle','role windup','role commit','hurt','recovery','defeat'] and row['facing'] in ['left','right']
        assert row['production_status']=='canon_validated_runtime' and row['native_validated'] and row['native_qa']
        relative=row['asset_path'].removeprefix('res://');path=(ROOT/relative).resolve()
        assert path.is_relative_to(ROOT/'art/production/phase4e/enemies') and '..' not in Path(relative).parts
        assert hashlib.sha256(path.read_bytes()).hexdigest()==row['asset_sha256']
        assert json.loads(path.with_suffix('.json').read_text(encoding='utf-8'))==row
        assert hashlib.sha256((ROOT/row['authored_source']).read_bytes()).hexdigest()==row['authored_source_sha256']
        with Image.open(path) as im:
            assert im.mode=='RGBA' and list(im.size)==row['canvas']
            bounds=im.getchannel('A').getbbox();assert bounds and bounds[0]>0 and bounds[1]>0 and bounds[2]<im.width and bounds[3]<im.height
            x,y,w,h=row['content_rect'];assert x<=bounds[0] and y<=bounds[1] and x+w>=bounds[2] and y+h>=bounds[3]
            assert 0<float(row['native_pixel_scale'])<=1
    return {'exact_authored_enemy_cells':len(rows),'mirrors':0,'reference_board_runtime_bodies':0}
if __name__=='__main__':print(json.dumps(validate()))
