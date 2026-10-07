"""Append real later strike/release frames from frozen sheets, alpha edits only."""
from pathlib import Path
import json, hashlib
from PIL import Image, ImageDraw
from extract_phase4e_locked import traced, refine_alpha
ROOT=Path(__file__).resolve().parents[1]
SPECS={
 'emberhorn_impact_right':('emberhorn',(950,540,1155,705),[(144,119),(95,51)],['claws'],[(31,117),(43,107),(48,88),(51,70),(61,61),(74,65),(87,57),(89,45),(99,38),(114,49),(116,31),(125,11),(133,8),(142,20),(149,43),(154,57),(157,31),(158,23),(168,39),(172,59),(183,27),(188,18),(196,35),(196,51),(195,65),(199,78),(192,97),(183,103),(180,113),(171,121),(153,128),(141,129),(133,137),(122,142),(115,140),(118,130),(125,120),(98,112),(76,123),(63,130),(53,133),(56,124),(38,129)]),
 'gloomlet_impact_right':('gloomlet',(953,535,1154,705),[(157,120),(77,103)],['claws'],[(21,101),(32,83),(49,72),(53,57),(37,46),(32,24),(42,16),(55,15),(71,25),(92,19),(109,25),(112,9),(120,2),(132,14),(141,34),(152,39),(160,15),(164,6),(174,17),(181,39),(183,62),(194,76),(187,91),(183,96),(167,100),(168,106),(171,118),(164,128),(147,129),(138,123),(136,113),(125,108),(105,112),(95,109),(87,106),(79,113),(67,114),(63,110),(60,99),(43,115),(32,119),(33,111),(25,113)]),
 'glimmerfin_impact_right':('glimmerfin',(929,538,1070,705),[(113,100),(102,107)],['wand','orb'],[(17,105),(28,104),(43,113),(43,105),(33,96),(19,90),(13,87),(18,82),(10,77),(18,73),(17,65),(7,51),(11,40),(20,46),(19,35),(27,21),(31,20),(34,34),(40,41),(52,46),(60,42),(68,47),(77,43),(75,30),(76,18),(69,4),(82,8),(94,13),(104,29),(108,47),(117,62),(119,74),(109,86),(115,85),(124,88),(125,93),(130,96),(125,101),(130,104),(125,107),(117,111),(111,110),(110,122),(115,139),(121,148),(114,153),(105,151),(92,152),(88,144),(90,138),(78,140),(69,139),(65,149),(62,153),(45,155),(43,151),(48,146),(49,139),(36,141),(28,135),(26,123),(22,118),(7,127),(3,120),(11,111)])
}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 out=ROOT/'art/production/phase4e';mp=out/'extraction_manifest.json';rp=out/'runtime_manifest.json'
 m=json.loads(mp.read_text());r=json.loads(rp.read_text());m['entries']=[e for e in m['entries'] if e['id'] not in SPECS]
 r['entries']=[e for e in r['entries'] if Path(e['asset_path']).stem not in SPECS]
 preview=Image.new('RGB',(1536,550),'#536576');pen=ImageDraw.Draw(preview)
 for i,(name,(actor,box,palms,weapons,outline)) in enumerate(SPECS.items()):
  source=ROOT/f'art/reference/canonical/characters/{actor.capitalize()}_CharacterSheet_Canonical.png'
  original=Image.open(source).convert('RGBA').crop(box);image=refine_alpha(traced(original.copy(),outline))
  assert original.convert('RGB').tobytes()==image.convert('RGB').tobytes()
  bounds=image.getbbox();image=image.crop(bounds);factor=480/max(image.size)
  size=tuple(round(v*factor) for v in image.size);offset=((512-size[0])//2,496-size[1]);canvas=Image.new('RGBA',(512,512))
  canvas.alpha_composite(image.resize(size,Image.Resampling.LANCZOS),offset)
  anchors=[[(offset[0]+(x-bounds[0])*factor)/512,(offset[1]+(y-bounds[1])*factor)/512] for x,y in palms]
  for x,y in anchors:assert canvas.getpixel((int(x*512),int(y*512)))[3]>100,(name,'missing source palm')
  target=out/f'lootlings/{actor}/{name}.png';canvas.save(target);path='res://'+target.relative_to(ROOT).as_posix()
  restriction='Actual right-facing source strike/release IMPACT only; no mirror or recovery/hurt substitution. Original hands and source markings retained. Alpha masking only, uniform resample, no invented anatomy.'
  m['entries'].append(dict(id=name,actor=actor,kind='body',runtime_phase='IMPACT',source=source.relative_to(ROOT).as_posix(),source_sha256=sha(source),crop=list(box),alpha_outline=outline,asset_path=path,canvas=[512,512],transparent=True,integrated=True,restrictions=restriction,primary_anchor=anchors[0],secondary_anchor=anchors[1],uniform_scale=factor,asset_sha256=sha(target)))
  r['entries'].append(dict(actor=actor,phase='IMPACT',facing='right_only',weapon_types=weapons,asset_path=path,body_rect=[-96,-128,192,192],primary_anchor=anchors[0],secondary_anchor=anchors[1],core_anchor=[.55,.63],feet_baseline=58,supports_two_hand=False,foreground_layer='',draw_depth='front',weapon_overrides={},wardrobe_requires={},baked_weapon='',restrictions=restriction))
  preview.paste(canvas,(i*512,30),canvas);pen.text((i*512+6,6),name,fill='white')
 mp.write_text(json.dumps(m,indent=2)+'\n');rp.write_text(json.dumps(r,indent=2)+'\n')
 folder=ROOT/'.godot_test_data/source-impact';folder.mkdir(exist_ok=True);preview.save(folder/'alpha-review.png')
 print('Three actual canonical impact exports; four exact state/family cells.')
if __name__=='__main__':main()
