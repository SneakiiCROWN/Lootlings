"""Original-pixel utility motifs from accepted sheets; no invented actor states."""
from pathlib import Path
import hashlib, json
from PIL import Image, ImageDraw
from extract_bible_runtime import isolate
ROOT=Path(__file__).resolve().parents[1]
CROPS={
 'memory_hourglass':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(737,278,943,545)),
 'fault_seal':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(749,804,941,1086)),
 'courier_cache':('props','lootlings_chests_shrine_merchant_props_reference.png',(635,55,1023,355)),
 'trophy_dais':('props','lootlings_chests_shrine_merchant_props_reference.png',(299,358,578,716)),
 'contract_banner':('props','lootlings_chests_shrine_merchant_props_reference.png',(0,716,180,1086)),
 'fire_missile':('vfx','lootlings_spell_reward_vfx_reference.png',(0,0,355,272)),
 'arcane_comet':('vfx','lootlings_spell_reward_vfx_reference.png',(861,813,1150,1086)),
 'healing_wreath':('vfx','lootlings_spell_reward_vfx_reference.png',(885,274,1172,555)),
}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 manifest=ROOT/'art/production/phase4e/extraction_manifest.json';data=json.loads(manifest.read_text())
 rows=[r for r in data['entries'] if r['id'] not in CROPS]
 preview=Image.new('RGB',(1040,600),'#182136');pen=ImageDraw.Draw(preview)
 for i,(name,(kind,filename,box)) in enumerate(CROPS.items()):
  source=ROOT/'art/reference/phase2_master'/filename;original=Image.open(source).crop(box)
  assert original.mode=='RGBA';alpha=isolate(original).getchannel('A')
  exclusions={
   'fault_seal':[(0,0,192,12)],
   'courier_cache':[(100,263,190,300)],
   'contract_banner':[(145,208,180,370)],
   'fire_missile':[(232,166,355,272)],
   'arcane_comet':[(250,75,289,273),(238,140,289,273),(0,238,30,273)],
   'healing_wreath':[(0,225,25,281)],
  }.get(name,[])
  for area in exclusions:ImageDraw.Draw(alpha).rectangle(area,fill=0)
  masked=Image.merge('RGBA',(*original.split()[:3],alpha))
  assert masked.convert('RGB').tobytes()==original.convert('RGB').tobytes()
  padded=Image.new('RGBA',(masked.width+8,masked.height+8));padded.paste(masked,(4,4))
  output=ROOT/f'art/production/phase4e/{kind}/{name}.png';padded.save(output)
  rows.append(dict(id=name,kind=kind,source=source.relative_to(ROOT).as_posix(),source_sha256=sha(source),crop=list(box),alpha_exclusions=exclusions,asset_path='res://'+output.relative_to(ROOT).as_posix(),canvas=list(padded.size),transparent=True,integrated=True,asset_sha256=sha(output),restrictions='Original RGB, alpha-only disconnected-fragment removal, 4px transparent gutter. Static utility/effect motif only; not a new actor, pose, consumable or gameplay system.'))
  thumb=padded.copy();thumb.thumbnail((250,255));x=i%4*260;y=i//4*300;preview.paste(thumb,(x,y+30),thumb);pen.text((x+4,y+4),name,fill='white')
 data['entries']=rows;manifest.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
 folder=ROOT/'.godot_test_data/canon-utilities';folder.mkdir(parents=True,exist_ok=True);preview.save(folder/'exports.png')
 print('8 utility motifs exported; accepted earlier exports preserved')
if __name__=='__main__':main()
