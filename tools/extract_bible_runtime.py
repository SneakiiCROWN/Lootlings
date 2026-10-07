"""Lossless RGBA crops from owner-approved established non-character sheets."""
from pathlib import Path
from PIL import Image, ImageDraw
import hashlib, json
import numpy as np
from collections import deque
ROOT=Path(__file__).resolve().parents[1]
BASE='art/reference/phase2_master/'
CROPS={
 'fire_arc':('vfx','lootlings_spell_reward_vfx_reference.png',(355,0,588,272)),
 'frost_burst':('vfx','lootlings_spell_reward_vfx_reference.png',(595,0,904,266)),
 'shadow_seal':('vfx','lootlings_spell_reward_vfx_reference.png',(1172,272,1448,553)),
 'shadow_orb':('vfx','lootlings_spell_reward_vfx_reference.png',(1180,559,1448,802)),
 'crystal_ward':('vfx','lootlings_spell_reward_vfx_reference.png',(904,563,1172,808)),
 'treasure_burst':('vfx','lootlings_spell_reward_vfx_reference.png',(298,558,598,800)),
 'red_pillar':('vfx','lootlings_spell_reward_vfx_reference.png',(1150,808,1448,1086)),
 'nature_vines':('vfx','lootlings_spell_reward_vfx_reference.png',(581,811,858,1086)),
 'recipe_scroll':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(945,548,1180,797)),
 'treasure_key':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(1214,800,1448,1086)),
 'reward_crown':('items','lootlings_jewellery_relic_consumable_loot_reference.png',(1204,0,1448,273)),
 'forge_station':('props','lootlings_chests_shrine_merchant_props_reference.png',(174,730,465,1086)),
 'merchant_cart':('props','lootlings_chests_shrine_merchant_props_reference.png',(1023,0,1448,354)),
}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def isolate(image):
 # Remove disconnected neighbouring artwork and stray sheet pixels only.
 # RGB is untouched; the largest original connected silhouette is retained.
 pixels=np.array(image);mask=pixels[:,:,3]>0;seen=np.zeros(mask.shape,bool);largest=[]
 for y,x in zip(*np.where(mask)):
  if seen[y,x]:continue
  queue=deque([(int(y),int(x))]);seen[y,x]=True;component=[]
  while queue:
   cy,cx=queue.popleft();component.append((cy,cx))
   for ny,nx in [(cy-1,cx),(cy+1,cx),(cy,cx-1),(cy,cx+1)]:
    if 0<=ny<mask.shape[0] and 0<=nx<mask.shape[1] and mask[ny,nx] and not seen[ny,nx]:seen[ny,nx]=True;queue.append((ny,nx))
  if len(component)>len(largest):largest=component
 keep=np.zeros(mask.shape,bool)
 for y,x in largest:keep[y,x]=True
 pixels[~keep,3]=0
 return Image.fromarray(pixels)
def main():
 manifest=ROOT/'art/production/phase4e/extraction_manifest.json'
 data=json.loads(manifest.read_text(encoding='utf-8'))
 retained=[r for r in data['entries'] if r['id'] not in CROPS]
 preview=Image.new('RGB',(1000,1200),'#182136');draw=ImageDraw.Draw(preview)
 for index,(name,(kind,filename,box)) in enumerate(CROPS.items()):
  source=ROOT/(BASE+filename);original=Image.open(source);assert original.mode=='RGBA'
  crop=original.crop(box);image=isolate(crop);output=ROOT/f'art/production/phase4e/{kind}/{name}.png';output.parent.mkdir(parents=True,exist_ok=True);image.save(output)
  # Known tiny foreign sheet fragments: explicit alpha-only exclusion masks.
  exclusions={'frost_burst':[(145,252,177,266)],'shadow_seal':[(200,0,276,18)],'shadow_orb':[(130,237,160,243)],'crystal_ward':[(220,0,268,10),(258,125,268,245)],'forge_station':[(0,0,24,65)]}.get(name,[])
  for area in exclusions:ImageDraw.Draw(image).rectangle(area,fill=(0,0,0,0))
  # Restore untouched RGB even in transparent excluded pixels.
  original_rgb=np.array(crop);masked=np.array(image);masked[:,:,:3]=original_rgb[:,:,:3];image=Image.fromarray(masked);image.save(output)
  assert image.convert('RGB').tobytes()==crop.convert('RGB').tobytes()
  padded=Image.new("RGBA",(image.width+8,image.height+8),(0,0,0,0));padded.paste(image,(4,4));image=padded;image.save(output)
  retained.append(dict(id=name,kind=kind,source=BASE+filename,source_sha256=sha(source),crop=list(box),alpha_exclusions=exclusions,asset_path='res://'+output.relative_to(ROOT).as_posix(),canvas=list(image.size),transparent=True,integrated=True,asset_sha256=sha(output),restrictions='Original RGB crop; alpha-only silhouette isolation and recorded foreign-fragment masks; static presentation motif, never fabricated animation frame'))
  thumb=image.copy();thumb.thumbnail((240,245));x=index%4*250;y=index//4*300;preview.paste(thumb,(x,y+30),thumb);draw.text((x+5,y+8),name,fill='white')
 data['entries']=retained;manifest.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
 folder=ROOT/'.godot_test_data/phase4e/bible-runtime';folder.mkdir(parents=True,exist_ok=True);preview.save(folder/'extraction_review.png')
 print('13 original-pixel exports; established identities unchanged')
if __name__=='__main__':main()
