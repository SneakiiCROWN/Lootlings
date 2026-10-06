"""Original RGB crops / safe alpha ownership masks from approved props source."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageChops
from collections import deque
import hashlib,json
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'art/reference/phase2_master/lootlings_chests_shrine_merchant_props_reference.png'
OUT=ROOT/'art/production/phase4e/props'
CROPS={'home_gate':(900,338,1302,721),'home_shrine':(0,344,297,706)}
def isolated_component(image):
 # Preserve original RGB/alpha on the largest separate prop component only.
 # Detached cart crystals/coins above the portal are a different source object.
 alpha=image.getchannel('A');width,height=image.size;pixels=alpha.load();seen=set();largest=[]
 for y in range(height):
  for x in range(width):
   if (x,y) in seen or pixels[x,y]<=16:continue
   todo=deque([(x,y)]);seen.add((x,y));component=[]
   while todo:
    px,py=todo.popleft();component.append((px,py))
    for nx,ny in [(px-1,py),(px+1,py),(px,py-1),(px,py+1)]:
     if 0<=nx<width and 0<=ny<height and (nx,ny) not in seen and pixels[nx,ny]>16:
      seen.add((nx,ny));todo.append((nx,ny))
   if len(component)>len(largest):largest=component
 keep=set(largest);output=image.copy();data=output.load()
 for y in range(height):
  for x in range(width):
   if (x,y) not in keep:data[x,y]=(*data[x,y][:3],0)
 return output
def main():
 OUT.mkdir(parents=True,exist_ok=True);records=[]
 with Image.open(SOURCE) as im:
  assert im.mode=='RGBA'
  for name,rect in CROPS.items():
   crop=im.crop(rect)
   if name=='home_gate':
    # Explicit object boundary: cart crystals/coins above belong to the cart,
    # not this gate. Preserve the gate's three actual architectural pinnacles.
    mask=Image.new('L',crop.size,0)
    ImageDraw.Draw(mask).polygon([(0,50),(45,30),(65,0),(110,25),(140,35),(165,30),(197,10),(230,20),(260,25),(282,10),(335,50),(402,100),(402,383),(0,383)],fill=255)
    crop.putalpha(ImageChops.multiply(crop.getchannel('A'),mask))
   crop=isolated_component(crop)
   path=OUT/(name+'.png');crop.save(path)
   records.append(dict(id=name,source=SOURCE.relative_to(ROOT).as_posix(),source_sha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),crop=list(rect),asset_path='res://'+path.relative_to(ROOT).as_posix(),canvas=list(crop.size),method='original RGBA crop; no resampling/repainting/recolouring/anatomy edits',asset_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),runtime_slot='Home existing gate/shrine hotspot',canon='existing treasure portal and Relic Shrine roles; no new ID or activity'))
 (OUT/'source_manifest.json').write_text(json.dumps(dict(owner_source_root='art/reference',entries=records),indent=2)+'\n')
 print('Two lossless original RGBA prop exports, intended for existing Home slots.')
if __name__=='__main__':main()
