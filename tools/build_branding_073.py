"""Extend the existing canonical-pixel branding pipeline; no generated faces/logos."""
from pathlib import Path
import hashlib,json,math
import numpy as np
from PIL import Image,ImageDraw,ImageOps,ImageFilter
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'art/ui/brand/073'
OUT.mkdir(parents=True,exist_ok=True)
wordmark=Image.open(ROOT/'art/ui/brand/lootlings_wordmark.png').convert('RGBA')
pixels=np.array(wordmark);mask=pixels[:,:,3]>10;seen=np.zeros(mask.shape,bool);keep=np.zeros(mask.shape,bool);components=[]
for y,x in zip(*np.nonzero(mask)):
 if seen[y,x]:continue
 stack=[(y,x)];seen[y,x]=True;coords=[]
 while stack:
  yy,xx=stack.pop();coords.append((yy,xx))
  for dy,dx in [(0,1),(0,-1),(1,0),(-1,0)]:
   ny,nx=yy+dy,xx+dx
   if 0<=ny<mask.shape[0] and 0<=nx<mask.shape[1] and mask[ny,nx] and not seen[ny,nx]:seen[ny,nx]=True;stack.append((ny,nx))
 colors=pixels[tuple(np.array(coords).T)]
 meaningful=len(coords)>150 and (((colors[:,0]>140)&(colors[:,1]>90)&(colors[:,2]<140)).any() or ((colors[:,2]>180)&(colors[:,1]>140)).any())
 if meaningful:
  keep[tuple(np.array(coords).T)]=True
 components.append({'pixels':len(coords),'retained':bool(meaningful)})
pixels[:,:,3]=np.where(keep,pixels[:,:,3],0)
clean=Image.fromarray(pixels);clean=clean.crop((162,0,931,228));clean.save(OUT/'wordmark_clean.png')
source=Image.open(ROOT/'art/sprites/relic_beast_base.png').convert('RGBA')
portrait=source.crop((350,0,1220,750))
# Preserve every face/horn/ear pixel; soften only the lower torso crop.
clip=Image.new('L',portrait.size);ImageDraw.Draw(clip).polygon([(0,0),(870,0),(870,750),(170,750),(145,650),(60,550),(0,400)],fill=255)
arr=np.array(portrait);arr[:,:,3]=np.minimum(arr[:,:,3],np.array(clip));fade=np.clip((749-np.arange(750))/65,0,1);arr[:,:,3]=(arr[:,:,3]*fade[:,None]).astype('uint8')
# Remove detached tail slivers outside this head portrait, not facial details.
alpha=arr[:,:,3]>10;visited=np.zeros(alpha.shape,bool);groups=[]
for y,x in zip(*np.nonzero(alpha)):
 if visited[y,x]:continue
 stack=[(y,x)];visited[y,x]=True;group=[]
 while stack:
  yy,xx=stack.pop();group.append((yy,xx))
  for dy,dx in [(0,1),(0,-1),(1,0),(-1,0)]:
   ny,nx=yy+dy,xx+dx
   if 0<=ny<750 and 0<=nx<870 and alpha[ny,nx] and not visited[ny,nx]:visited[ny,nx]=True;stack.append((ny,nx))
 groups.append(group)
main=max(groups,key=len);retained=np.zeros(alpha.shape,bool);retained[tuple(np.array(main).T)]=True;arr[:,:,3]=np.where(retained,arr[:,:,3],0);portrait=Image.fromarray(arr)
ay,ax=np.nonzero(arr[:,:,3]>20);radius=np.sqrt((ax-435)**2+(ay-375)**2).max();factor=126/radius
extent=(round(870*factor),round(750*factor));portrait=portrait.resize(extent,Image.Resampling.LANCZOS)
front=Image.new('RGBA',(432,432));front.alpha_composite(portrait,((432-extent[0])//2,(432-extent[1])//2));
# Exact approved blue crystal pixels, outside the mascot's canonical gold Core.
crystal=wordmark.crop((595,0,654,47));ca=np.array(crystal);ca[:,:,3]=np.where(ca[:,:,0]>ca[:,:,2],0,ca[:,:,3]);crystal=Image.fromarray(ca);crystal.thumbnail((57,57),Image.Resampling.LANCZOS)
crystal.thumbnail((30,30),Image.Resampling.LANCZOS);front.alpha_composite(crystal,(272,273));front.save(OUT/'android_foreground.png')
mono=Image.new('RGBA',(432,432),'white');mono_alpha=np.array(front.getchannel('A'));fp=np.array(front)
# Exact dark eye/nose pixels become negative space, preserving the original
# expression rather than inventing a second monochrome face.
origin=((432-extent[0])//2,(432-extent[1])//2)
left=round(origin[0]+(610-350)*factor);right=round(origin[0]+(950-350)*factor)
top=round(origin[1]+385*factor);bottom=round(origin[1]+600*factor)
region=fp[top:bottom,left:right,:3];holes=(region[:,:,0]<100)&(region[:,:,1]<95)&(region[:,:,2]<90)
mono_alpha[top:bottom,left:right]=np.where(holes,0,mono_alpha[top:bottom,left:right])
mono.putalpha(Image.fromarray(mono_alpha));mono.save(OUT/'android_monochrome.png')
# Opaque full-bleed background; the launcher owns its mask, no baked black corners.
sky=Image.open(ROOT/'art/backgrounds/lootlings_living_title_wide_068.png').convert('RGBA');sky=sky.crop((725,0,1035,235));bg=ImageOps.fit(sky,(432,432)).filter(ImageFilter.GaussianBlur(1.5));shade=Image.new('RGBA',(432,432),(5,14,30,100));bg=Image.alpha_composite(bg,shade);bp=bg.load()
plain_bg=bg.copy()
d=ImageDraw.Draw(bg);d.ellipse((49,49,383,383),outline='#aa7d35',width=3);d.ellipse((55,55,377,377),outline='#223e60',width=2)
bg.save(OUT/'android_background.png')
legacy=Image.alpha_composite(plain_bg,front).crop((84,84,348,348)).resize((512,512),Image.Resampling.LANCZOS)
d=ImageDraw.Draw(legacy);d.rounded_rectangle((9,9,503,503),radius=62,outline='#dbb563',width=10);d.rounded_rectangle((20,20,492,492),radius=53,outline='#81602b',width=2)
legacy.save(OUT/'lootlings_icon.png')
legacy.save(OUT/'lootlings_windows.ico',sizes=[(s,s) for s in [16,32,48,64,128,256]])
for name in ['lootlings_living_title_068.png','lootlings_living_title_tall_068.png','lootlings_living_title_wide_068.png']:
 bgim=Image.open(ROOT/'art/backgrounds'/name).convert('RGBA');width=720 if 'wide' not in name else 1280;height=round(width*bgim.height/bgim.width);bgim=bgim.resize((width,height),Image.Resampling.LANCZOS)
 mark=clean.copy();mark.thumbnail((round(width*.72),round(height*.14)),Image.Resampling.LANCZOS);bgim.alpha_composite(mark,((width-mark.width)//2,round(height*.075)));bgim.convert('RGB').save(OUT/('boot_wide.png' if 'wide' in name else 'boot_tall.png' if 'tall' in name else 'boot_portrait.png'))
sources=['art/sprites/relic_beast_base.png','art/reference/canonical/characters/Lootlings_Main_Mascot_RelicBeast_Canonical.png','art/ui/brand/lootlings_wordmark.png','art/backgrounds/lootlings_living_title_068.png','art/backgrounds/lootlings_living_title_wide_068.png','art/backgrounds/lootlings_living_title_tall_068.png']
manifest={'method':'Existing canonical pixels with deterministic framing/scaling; no generated replacement face or logo.','sources':{s:hashlib.sha256((ROOT/s).read_bytes()).hexdigest() for s in sources},'wordmark_components':components,'adaptive_silhouette_radius_limit':126,'foreground_extent':extent,'concepts':'Owner attachments are direction only, not canon. Their different gem/markings are not installed.','mascot_core':'original gold retained; separate approved blue wordmark crystal accent','physical_device_acceptance':False}
(OUT/'PROVENANCE.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print('Canonical branding rendered:',OUT)
