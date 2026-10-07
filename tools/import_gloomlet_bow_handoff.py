"""Scoped, reproducible imports. No mirroring, anatomy edits or invented states."""
from pathlib import Path
import json, hashlib
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'art/reference/phase4e_handoff/gloomlet_bow_vertical_slice'
DEST = ROOT / 'art/production/phase4e/lootlings/gloomlet/bow'
DEST.mkdir(parents=True, exist_ok=True)
rows = []
# Measured palm centres in the delivered 1254px images. Only drawn-bow windup
# is represented; a closed drawing fist is not an authored release/recovery.
for facing, candidate, grip, draw, polygon in [
    ('right', 'R03', (1182, 691), (630, 620), [(1120,615),(1190,606),(1240,656),(1240,755),(1148,772),(1110,700)]),
    ('left', 'L02', (96, 655), (673, 627), [(45,615),(90,570),(153,568),(176,653),(150,729),(52,725)]),
]:
    src = SOURCE / 'generated_pose_candidates' / f'Gloomlet_BowCandidate_{candidate}.png'
    im = Image.open(src).convert('RGBA')
    assert im.size == (1254,1254)
    # Remove only alpha<=8 background speckle, then fit the actual silhouette
    # with a single affine scale. Ground is the delivered lowest real paw.
    im.putalpha(im.getchannel('A').point(lambda a: a if a>8 else 0))
    box=im.getbbox();width=box[2]-box[0];height=box[3]-box[1]
    scale=480/max(width,height);offset=[(512-width*scale)/2,496-height*scale]
    matrix=(1/scale,0,box[0]-offset[0]/scale,0,1/scale,box[1]-offset[1]/scale)
    def fit(image):
        result=image.transform((512,512),Image.Transform.AFFINE,matrix,Image.Resampling.BICUBIC)
        inset=Image.new('L',(512,512));ImageDraw.Draw(inset).rectangle((16,16,495,495),fill=255)
        from PIL import ImageChops
        result.putalpha(ImageChops.multiply(result.getchannel('A'),inset))
        return result
    body=fit(im)
    name = f'gloomlet_bow_windup_{facing}'
    body.save(DEST / (name+'.png'))
    mask = Image.new('L',im.size); ImageDraw.Draw(mask).polygon(polygon,fill=255)
    draw_polygon=([(556,583),(657,556),(702,604),(700,646),(648,699),(569,679)] if facing=='right' else [(618,589),(670,573),(737,599),(741,650),(698,691),(627,665)])
    ImageDraw.Draw(mask).polygon(draw_polygon,fill=255)
    hand = im.copy()
    from PIL import ImageChops
    hand.putalpha(ImageChops.multiply(im.getchannel('A'),mask))
    layer=fit(hand)
    layer.save(DEST / (name+'_grip.png'))
    palms = [[offset[0]+(x-box[0])*scale,offset[1]+(y-box[1])*scale] for x,y in [grip,draw]]
    sidecar = dict(actor='gloomlet',state='windup',facing=facing,weapon_family='bow',
        source=str(src.relative_to(ROOT)).replace('\\','/'), source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),
        identity_authority='art/reference/canonical/characters/Gloomlet_CharacterSheet_Canonical.png',
        canvas=[512,512],pivot=[256,341.3333333333333],baseline=496,
        occupied_bounds=list(body.getbbox()),uniform_scale=scale,source_crop=list(box),crop_canvas_offset=offset,
        alpha_background_cleanup='Only alpha<=8 source background speckle removed; no opaque anatomy edits',
        measured_source_palms=[grip,draw],canvas_palms=palms,mirroring_allowed=False,
        foreground_layer=name+'_grip.png',baked_weapon=False,acceptance='NATIVE_VALIDATED_WINDUP_ONLY',
        evidence='docs/production/phase4e/gloomlet-bow/REPORT.md')
    (DEST/(name+'.sockets.json')).write_text(json.dumps(sidecar,indent=2)+'\n')
    prefix='res://'+str(DEST.relative_to(ROOT)).replace('\\','/')+'/'
    rows.append(dict(actor='gloomlet',phase='ANTICIPATE',facing=facing+'_only',weapon_types=['bow'],
        asset_path=prefix+name+'.png',body_rect=[-96,-128,192,192],
        primary_anchor=[x/512 for x in palms[0]],secondary_anchor=[x/512 for x in palms[1]],
        core_anchor=[.52,.60],feet_baseline=58,supports_two_hand=True,
        foreground_layer=prefix+name+'_grip.png',draw_depth='front',weapon_overrides={},
        wardrobe_requires={},baked_weapon='',bow_draw_contact=True,native_validated=True,
        production_status='validated_beta_windup_only'))
(DEST/'bow_slice_manifest.json').write_text(json.dumps(dict(entries=rows),indent=2)+'\n')
print('Exported two independent windups and two extracted grip layers; no other state closed.')
