"""Mask one existing canonical dagger, preserving its painted design. No new design."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops
import hashlib,json,math
root=Path(__file__).resolve().parents[1]
source=root/'art/sprites/weapons/rogue_daggers.png'
im=Image.open(source).convert('RGBA'); mask=Image.new('L',im.size)
# Hand-traced boundary of the upper/left dagger, excluding the second weapon.
points=[(810,0),(891,72),(950,172),(986,284),(975,407),(945,486),(905,550),(846,604),(782,646),(743,677),(710,655),(653,661),(604,704),(524,697),(443,760),(329,862),(177,986),(63,941),(81,850),(172,776),(285,691),(337,644),(357,608),(335,565),(333,521),(356,478),(470,449),(449,511),(486,540),(559,488),(688,372),(720,295),(756,348),(792,248),(829,211),(830,140)]
ImageDraw.Draw(mask).polygon(points,fill=255)
im.putalpha(ImageChops.multiply(im.getchannel('A'),mask))
# Rotate blade upright. Pivot/grip is mapped by applying the same canvas transform.
angle=36
rot=im.rotate(angle,resample=Image.Resampling.BICUBIC,expand=True)
box=rot.getbbox(); rot=rot.crop(box)
scale=384/rot.height; rot=rot.resize((round(rot.width*scale),384),Image.Resampling.LANCZOS)
out=root/'art/sprites/weapons/paired_dagger_painted.png'; rot.save(out)
# Grip coordinate from source (285,795), corrected for centered expanded canvas.
x,y=285-im.width/2,795-im.height/2; a=math.radians(angle)
expanded=im.rotate(angle,expand=True).size
grip=((x*math.cos(a)+y*math.sin(a)+expanded[0]/2-box[0])*scale,
      (-x*math.sin(a)+y*math.cos(a)+expanded[1]/2-box[1])*scale)
(root/'art/sprites/weapons/paired_dagger_painted.json').write_text(json.dumps({'source':source.relative_to(root).as_posix(),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'method':'hand traced single weapon mask and rotation; canonical design unchanged','size':rot.size,'grip_normalized':[grip[0]/rot.width,grip[1]/rot.height],'status':'integration candidate; native edge and grip QA required'},indent=2),encoding='utf-8')
print(rot.size,grip[0]/rot.width,grip[1]/rot.height)
