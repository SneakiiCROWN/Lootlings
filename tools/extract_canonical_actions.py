"""Extract actual locked-sheet attack illustrations; append, never overwrite accepted poses."""
from pathlib import Path
import json, hashlib
from PIL import Image,ImageDraw,ImageChops
from extract_phase4e_locked import traced,refine_alpha
ROOT=Path(__file__).resolve().parents[1]
# Palms are measured in the original crop, not guessed rig target coordinates.
SPECS={
 'emberhorn_windup_right':('emberhorn','ANTICIPATE',(559,541,738,703),[(138,120),(66,118)],['claws'],''),
 'emberhorn_strike_right':('emberhorn','ATTACK',(753,540,944,705),[(134,119),(65,34)],['claws'],''),
 'moonkip_windup_right':('moonkip','ANTICIPATE',(566,538,745,700),[(125,125),(64,80)],['daggers'],'daggers'),
 'moonkip_strike_right':('moonkip','ATTACK',(747,538,939,704),[(140,118),(55,75)],['daggers'],'daggers'),
 'pebblewyrm_windup_right':('pebblewyrm','ANTICIPATE',(720,535,937,711),[(147,139),(95,35)],['claws'],''),
 'glimmerfin_windup_right':('glimmerfin','ANTICIPATE',(558,538,743,704),[(130,96),(117,102)],['staff'],'staff'),
 'glimmerfin_cast_right':('glimmerfin','ATTACK',(747,538,918,704),[(114,87),(110,88)],['wand','orb'],''),
 'gloomlet_strike_right':('gloomlet','ATTACK',(749,533,980,704),[(175,120),(108,115)],['claws'],''),
}
# Source-pixel masks traced around bodies and actual baked weapons, excluding
# neighbouring art, sheet ground and trailing VFX. Never paint missing anatomy.
OUTLINES={
 'emberhorn_windup_right':[(22,118),(19,88),(24,70),(39,61),(56,65),(65,61),(58,39),(66,17),(78,20),(95,34),(102,48),(110,43),(120,52),(151,42),(147,56),(137,77),(136,98),(144,110),(151,117),(145,125),(132,129),(123,124),(113,135),(127,138),(125,142),(115,144),(101,139),(76,138),(72,142),(56,141),(44,142),(44,131),(38,127),(27,125)],
 'emberhorn_strike_right':[(14,82),(17,64),(29,51),(44,54),(57,66),(64,73),(67,60),(54,43),(54,27),(67,17),(76,27),(78,44),(91,55),(89,38),(111,6),(123,10),(129,34),(134,51),(145,32),(151,30),(158,43),(153,61),(159,67),(154,89),(148,101),(136,109),(143,119),(139,130),(128,131),(117,119),(108,114),(100,129),(93,133),(93,139),(87,141),(81,135),(74,122),(60,117),(51,125),(40,122),(39,116),(24,112),(17,98)],
 'moonkip_windup_right':[(12,110),(22,94),(42,86),(64,94),(65,89),(46,78),(34,61),(34,46),(47,28),(58,20),(51,34),(43,48),(45,61),(60,72),(68,63),(74,10),(85,17),(98,35),(108,46),(118,58),(149,42),(170,39),(168,52),(155,75),(149,88),(146,110),(133,114),(139,125),(150,130),(153,139),(142,141),(130,135),(117,143),(105,145),(99,140),(110,131),(108,123),(89,133),(66,132),(56,143),(40,145),(36,140),(47,130),(46,121),(28,129),(17,126)],
 'moonkip_strike_right':[(2,110),(10,95),(24,87),(42,86),(54,89),(68,94),(75,85),(65,78),(46,69),(33,65),(28,60),(26,54),(20,43),(29,24),(30,35),(36,47),(49,55),(57,63),(57,54),(53,30),(53,10),(67,12),(87,28),(103,33),(127,53),(144,63),(154,80),(154,96),(146,106),(142,113),(159,116),(169,109),(179,98),(184,94),(182,106),(175,119),(155,130),(136,135),(121,130),(112,119),(101,132),(91,144),(73,155),(48,155),(45,149),(55,141),(57,132),(46,137),(34,140),(33,133),(41,126),(30,125),(16,124),(5,116)],
 'pebblewyrm_windup_right':[(4,98),(13,82),(16,60),(24,53),(25,70),(34,76),(45,81),(54,67),(67,48),(69,26),(78,15),(90,9),(103,16),(111,26),(108,43),(110,52),(119,33),(130,23),(135,32),(136,46),(151,45),(156,37),(169,46),(173,66),(183,73),(185,91),(178,111),(163,121),(166,132),(168,144),(156,152),(148,150),(139,145),(121,151),(105,149),(85,151),(72,153),(60,153),(50,149),(45,141),(35,135),(24,135),(12,123),(5,112)],
 'glimmerfin_windup_right':[(8,109),(7,91),(16,84),(28,90),(31,94),(42,94),(24,84),(18,66),(6,50),(5,40),(18,42),(26,53),(38,55),(50,53),(58,38),(43,30),(41,23),(51,20),(63,25),(80,44),(86,47),(82,28),(91,19),(98,23),(104,38),(117,51),(122,67),(117,78),(121,89),(131,88),(135,95),(130,101),(133,109),(119,114),(118,139),(117,145),(104,147),(99,142),(89,126),(77,134),(73,145),(61,147),(59,141),(63,136),(50,128),(39,132),(24,131),(12,122)],
 'glimmerfin_cast_right':[(0,113),(14,108),(22,99),(32,95),(19,92),(5,80),(2,69),(1,47),(7,43),(15,53),(26,56),(35,50),(49,41),(41,31),(23,21),(19,16),(32,15),(45,18),(57,31),(69,36),(76,25),(73,15),(72,11),(76,10),(87,20),(94,36),(97,50),(101,61),(99,77),(111,84),(116,78),(121,80),(126,85),(121,94),(113,98),(100,102),(98,113),(103,133),(106,142),(96,146),(85,145),(84,139),(79,131),(69,132),(66,145),(55,148),(51,143),(55,134),(41,136),(28,133),(17,130),(8,125)],
 'gloomlet_strike_right':[(13,105),(7,88),(6,68),(18,65),(29,69),(37,62),(30,50),(39,41),(61,36),(85,39),(99,45),(106,27),(123,21),(130,14),(142,26),(151,42),(169,22),(175,27),(184,51),(184,66),(190,84),(185,101),(176,106),(186,111),(190,123),(183,132),(176,136),(165,131),(154,123),(142,124),(134,128),(122,126),(115,123),(106,114),(93,118),(91,125),(83,126),(77,119),(63,121),(53,121),(54,126),(49,134),(41,135),(35,132),(35,126),(44,114),(32,115),(25,113)]
}
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 out=ROOT/'art/production/phase4e';manifest=out/'extraction_manifest.json';runtime=out/'runtime_manifest.json'
 data=json.loads(manifest.read_text());routes=json.loads(runtime.read_text())
 data['entries']=[e for e in data['entries'] if e['id'] not in SPECS]
 paths={'res://art/production/phase4e/lootlings/'+a+'/'+name+'.png' for name,(a,*_) in SPECS.items()}
 routes['entries']=[r for r in routes['entries'] if r['asset_path'] not in paths]
 preview=Image.new('RGB',(4*512,2*540),'#536576');pen=ImageDraw.Draw(preview)
 for i,(name,(actor,phase,box,palms,weapons,baked)) in enumerate(SPECS.items()):
  source=ROOT/'art/reference/canonical/characters'/(actor.capitalize()+'_CharacterSheet_Canonical.png')
  original=Image.open(source).convert('RGBA').crop(box)
  seed=traced(original.copy(),OUTLINES[name])
  staff_outline=[(128,95),(134,79),(132,65),(138,47),(147,41),(160,40),(165,51),(164,65),(156,75),(144,77),(136,90),(134,99)] if name=='glimmerfin_windup_right' else []
  if staff_outline:seed.putalpha(ImageChops.lighter(seed.getchannel('A'),traced(original.copy(),staff_outline).getchannel('A')))
  image=refine_alpha(seed)
  shaft_patch=[(144,69),(149,72),(136,98),(130,97)] if name=='glimmerfin_windup_right' else []
  if shaft_patch:image.putalpha(ImageChops.lighter(image.getchannel('A'),traced(original.copy(),shaft_patch).getchannel('A')))
  # Graph-cut can confuse the pink glove against the purple blade glow.
  # Retain the visibly authored fingers with a precise source alpha patch.
  if name=='moonkip_strike_right':
   palm=traced(original.copy(),[(50,69),(55,69),(59,74),(60,78),(57,82),(52,80),(50,75)])
   image.putalpha(ImageChops.lighter(image.getchannel('A'),palm.getchannel('A')))
  assert image.convert('RGB').tobytes()==original.convert('RGB').tobytes()
  bounds=image.getbbox();image=image.crop(bounds)
  factor=480/max(image.size);size=tuple(round(v*factor) for v in image.size);offset=((512-size[0])//2,496-size[1])
  canvas=Image.new('RGBA',(512,512));canvas.alpha_composite(image.resize(size,Image.Resampling.LANCZOS),offset)
  anchors=[[(offset[0]+(x-bounds[0])*factor)/512,(offset[1]+(y-bounds[1])*factor)/512] for x,y in palms]
  for x,y in anchors:
   if canvas.getpixel((int(x*512),int(y*512)))[3]<=100:
    debug=ROOT/'.godot_test_data/canonical-actions';debug.mkdir(exist_ok=True);canvas.save(debug/(name+'_anchor_review.png'))
   assert canvas.getpixel((int(x*512),int(y*512)))[3]>100,(name,'palm',x,y)
  path=out/'lootlings'/actor/(name+'.png');path.parent.mkdir(exist_ok=True,parents=True);canvas.save(path)
  restrictions='Actual source attack-sequence '+phase+'; right only, no mirror, no fabricated recovery/hurt. Source VFX retained; no new damage/timing. '+('Source '+baked+' remains baked; no modular weaponless claim.' if baked else 'Original source paws retained.')
  data['entries'].append(dict(id=name,actor=actor,kind='body',runtime_phase=phase,source=source.relative_to(ROOT).as_posix(),source_sha256=digest(source),crop=list(box),alpha_outline=OUTLINES[name],alpha_staff_outline=staff_outline,alpha_shaft_patch=shaft_patch,alpha_palm_patch=[(50,69),(55,69),(59,74),(60,78),(57,82),(52,80),(50,75)] if name=='moonkip_strike_right' else [],asset_path='res://'+path.relative_to(ROOT).as_posix(),canvas=[512,512],transparent=True,integrated=True,restrictions=restrictions,primary_anchor=anchors[0],secondary_anchor=anchors[1],uniform_scale=factor,asset_sha256=digest(path)))
  routes['entries'].append(dict(actor=actor,phase=phase,facing='right_only',weapon_types=weapons,asset_path='res://'+path.relative_to(ROOT).as_posix(),body_rect=[-96,-128,192,192],primary_anchor=anchors[0],secondary_anchor=anchors[1],core_anchor=[.55,.63],feet_baseline=58,supports_two_hand=False,foreground_layer='',draw_depth='front',weapon_overrides={},wardrobe_requires={},baked_weapon=baked,restrictions=restrictions))
  preview.paste(canvas,(i%4*512,i//4*540+28),canvas);pen.text((i%4*512+6,i//4*540+5),name,fill='white')
 manifest.write_text(json.dumps(data,indent=2)+'\n');runtime.write_text(json.dumps(routes,indent=2)+'\n')
 target=ROOT/'.godot_test_data/canonical-actions';target.mkdir(exist_ok=True);preview.save(target/'alpha-review.png')
 print('Eight actual canonical attack illustrations extracted; phase/view/family restrictions explicit.')
if __name__=='__main__':main()
