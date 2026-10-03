"""Enlarge existing canonical mascot pixels inside Android's 66dp safe circle.
No generated or painted production character art.
"""
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parents[1]
folder = ROOT/'art/ui/brand'
source = Image.open(ROOT/'art/sprites/relic_beast_base.png').convert('RGBA')
mascot = source.crop((350,0,1220,760)).resize((300,262),Image.Resampling.LANCZOS)
# Face/eyes sit inside the 66dp safe circle; ear tips are decorative overscan.
# Fade the lower portrait cut into the branded background instead of a hard edge.
alpha = mascot.getchannel('A')
for y in range(246,262):
    for x in range(300): alpha.putpixel((x,y),round(alpha.getpixel((x,y))*(261-y)/15))
mascot.putalpha(alpha)
foreground = Image.new('RGBA',(432,432))
foreground.alpha_composite(mascot,((432-mascot.width)//2,(432-mascot.height)//2))
foreground.save(folder/'android_foreground.png')
mono = Image.new('RGBA',(432,432),'white');mono.putalpha(foreground.getchannel('A'));mono.save(folder/'android_monochrome.png')
background = Image.open(folder/'android_background.png').convert('RGBA')
legacy = Image.alpha_composite(background,foreground)
legacy.resize((192,192),Image.Resampling.LANCZOS).save(folder/'lootlings_icon.png')
print('Canonical adaptive mascot:', mascot.size, 'critical face inside 264px safe circle')
