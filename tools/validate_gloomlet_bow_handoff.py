"""Guard only the two reviewed bow windups; candidates cannot close other states."""
import json, hashlib
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
DEST=ROOT/'art/production/phase4e/lootlings/gloomlet/bow'
def validate():
    rows=json.loads((DEST/'bow_slice_manifest.json').read_text())['entries']
    assert len(rows)==2
    allowed={'right_only':('R03','7b3b4a367c29a1d3c5c36c20ce8d96b3374f98138689be5cc8bd303928c17936'),
             'left_only':('L02','8ac217ac698910a2ca18a796955185b6e9ffade85d2e58da478fb3776a6c9c2a')}
    seen=set()
    for r in rows:
        assert r['actor']=='gloomlet' and r['phase']=='ANTICIPATE' and r['weapon_types']==['bow']
        assert r['native_validated'] and r['production_status']=='validated_beta_windup_only'
        facing=r['facing']; assert facing not in seen; seen.add(facing)
        candidate,sha=allowed[facing]
        asset=ROOT/r['asset_path'].removeprefix('res://')
        side=json.loads(asset.with_suffix('.sockets.json').read_text())
        assert side['state']=='windup' and side['mirroring_allowed'] is False
        assert side['source'].endswith('Gloomlet_BowCandidate_'+candidate+'.png')
        assert side['measured_source_palms']==([[1182,691],[630,620]] if facing=='right_only' else [[96,655],[673,627]])
        source=ROOT/side['source']; assert hashlib.sha256(source.read_bytes()).hexdigest()==sha==side['source_sha256']
        original=Image.open(source).convert('RGBA')
        original.putalpha(original.getchannel('A').point(lambda a:a if a>8 else 0))
        box=original.getbbox();width=box[2]-box[0];height=box[3]-box[1];scale=480/max(width,height)
        offset=[(512-width*scale)/2,496-height*scale]
        assert side['source_crop']==list(box) and side['crop_canvas_offset']==offset and side['uniform_scale']==scale
        from PIL import ImageDraw,ImageChops
        matrix=(1/scale,0,box[0]-offset[0]/scale,0,1/scale,box[1]-offset[1]/scale)
        def fit(image):
            result=image.transform((512,512),Image.Transform.AFFINE,matrix,Image.Resampling.BICUBIC)
            inset=Image.new('L',(512,512));ImageDraw.Draw(inset).rectangle((16,16,495,495),fill=255)
            result.putalpha(ImageChops.multiply(result.getchannel('A'),inset));return result
        expected=fit(original)
        im=Image.open(asset); assert im.mode=='RGBA' and im.size==(512,512) and im.tobytes()==expected.tobytes()
        bounds=im.getbbox(); assert bounds[0]>=16 and bounds[1]>=16 and bounds[2]<=496 and bounds[3]<=496
        assert side['baseline']==496 and side['pivot']==[256,341.3333333333333]
        assert r['baked_weapon']=='' and r['bow_draw_contact'] and r['supports_two_hand']
        for index,key in enumerate(['primary_anchor','secondary_anchor']):
            x,y=side['measured_source_palms'][index];measured=[offset[0]+(x-box[0])*scale,offset[1]+(y-box[1])*scale]
            assert all(abs(a-b)<1e-8 for a,b in zip(measured,side['canvas_palms'][index]))
            assert all(abs(a-b*512)<1e-8 for a,b in zip(measured,r[key]))
        layer=Image.open(ROOT/r['foreground_layer'].removeprefix('res://'))
        assert layer.mode=='RGBA' and layer.size==(512,512) and layer.getbbox() is not None
        from PIL import ImageDraw,ImageChops
        polygon=([(1120,615),(1190,606),(1240,656),(1240,755),(1148,772),(1110,700)] if facing=='right_only' else [(45,615),(90,570),(153,568),(176,653),(150,729),(52,725)])
        mask=Image.new('L',original.size);ImageDraw.Draw(mask).polygon(polygon,fill=255)
        draw_polygon=([(556,583),(657,556),(702,604),(700,646),(648,699),(569,679)] if facing=='right_only' else [(618,589),(670,573),(737,599),(741,650),(698,691),(627,665)])
        ImageDraw.Draw(mask).polygon(draw_polygon,fill=255)
        grip=original.copy();grip.putalpha(ImageChops.multiply(original.getchannel('A'),mask))
        expected_layer=fit(grip)
        assert layer.tobytes()==expected_layer.tobytes()
    return {'validated_exact_bow_windups':2,'other_states_accepted':0,'apk_gate':'HOLD'}
if __name__=='__main__': print(json.dumps(validate()))
