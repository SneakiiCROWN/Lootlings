"""Append original-pixel non-character exports; preserve all accepted earlier work."""
from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json
from extract_bible_runtime import isolate
ROOT=Path(__file__).resolve().parents[1]
CROPS={
 'azure_ring':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(0,0,249,274)),
 'obsidian_ring':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(951,0,1210,275)),
 'verdant_amulet':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(482,0,736,275)),
 'ward_orbit':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(942,277,1204,549)),
 'gold_hoard':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(281,806,550,1086)),
 'star_shards':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(546,806,743,1086)),
 'trail_map':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(1181,548,1448,800)),
 'quiet_camp':('props','lootlings_chests_shrine_merchant_props_reference.png',(466,731,806,1086)),
 'vault_portal':('props','lootlings_chests_shrine_merchant_props_reference.png',(933,366,1280,720)),
 'brass_torch':('props','lootlings_chests_shrine_merchant_props_reference.png',(1281,362,1448,724)),
 'lightning_contact':('vfx','lootlings_spell_reward_vfx_reference.png',(287,274,600,553)),
 'poison_contact':('vfx','lootlings_spell_reward_vfx_reference.png',(1179,0,1448,271)),
 'frost_projectile':('vfx','lootlings_spell_reward_vfx_reference.png',(903,0,1180,270)),
}
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 manifest=ROOT/'art/production/phase4e/extraction_manifest.json';data=json.loads(manifest.read_text())
 rows=[r for r in data['entries'] if r['id'] not in CROPS]
 review=Image.new('RGB',(1040,1120),'#182136');pen=ImageDraw.Draw(review)
 for i,(name,(kind,filename,box)) in enumerate(CROPS.items()):
  source=ROOT/'art/reference/phase2_master'/filename;original=Image.open(source).crop(box)
  assert original.mode=='RGBA';masked=isolate(original)
  # Retain original RGB even for alpha-only disconnected fragment exclusion.
  exclusions={
   'obsidian_ring':[(0,0,15,275),(237,0,259,275)],
   'verdant_amulet':[(0,0,12,275),(242,0,254,275)],
   'gold_hoard':[(0,0,5,280),(266,0,269,280)],
   'star_shards':[(0,185,18,247),(0,0,197,6)],
   'trail_map':[(0,100,35,210),(0,0,267,5),(0,247,267,252)],
   'quiet_camp':[(0,0,10,355),(326,0,340,355)],
   'lightning_contact':[(0,110,12,279),(290,245,313,279)],
   'frost_projectile':[(244,80,277,270),(0,264,277,270)]
  }.get(name,[])
  alpha=masked.getchannel('A');mask_pen=ImageDraw.Draw(alpha)
  for area in exclusions:mask_pen.rectangle(area,fill=0)
  masked=Image.merge('RGBA',(*original.split()[:3],alpha))
  assert masked.convert('RGB').tobytes()==original.convert('RGB').tobytes()
  padded=Image.new('RGBA',(masked.width+8,masked.height+8));padded.paste(masked,(4,4))
  output=ROOT/f'art/production/phase4e/{kind}/{name}.png';output.parent.mkdir(parents=True,exist_ok=True);padded.save(output)
  rows.append(dict(id=name,kind=kind,source=source.relative_to(ROOT).as_posix(),source_sha256=sha(source),crop=list(box),alpha_exclusions=exclusions,asset_path='res://'+output.relative_to(ROOT).as_posix(),canvas=list(padded.size),transparent=True,integrated=True,asset_sha256=sha(output),restrictions='Original RGB; alpha-only disconnected fragment exclusion; four-pixel transparent gutter; static item/prop/VFX motif, not a character state or new game identity'))
  thumb=padded.copy();thumb.thumbnail((250,240));x=i%4*260;y=i//4*280;review.paste(thumb,(x,y+30),thumb);pen.text((x+5,y+5),name,fill='white')
 data['entries']=rows;manifest.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
 folder=ROOT/'.godot_test_data/canon-content';folder.mkdir(parents=True,exist_ok=True);review.save(folder/'exports.png')
 print('13 approved original-pixel item/prop/elemental exports appended')
if __name__=='__main__':main()
