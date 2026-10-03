"""Arrange native QA captures for inspection; never produces game art."""
from pathlib import Path
from PIL import Image, ImageDraw
import argparse
p = argparse.ArgumentParser()
p.add_argument('folder', type=Path)
p.add_argument('--pattern', default='*.png')
args = p.parse_args()
files = sorted(args.folder.glob(args.pattern))
out = args.folder/'review'
out.mkdir(exist_ok=True)
for page in range(0, len(files), 8):
    sheet = Image.new('RGB', (1200, 1160), '#10172b')
    draw = ImageDraw.Draw(sheet)
    for index, path in enumerate(files[page:page+8]):
        img = Image.open(path).convert('RGB')
        img.thumbnail((292, 540))
        x, y = index % 4 * 300, index // 4 * 580
        sheet.paste(img, (x+(300-img.width)//2, y+30))
        draw.text((x+4, y+5), path.stem[:38], fill='white')
    target = out/f'page-{page//8:02}.jpg'
    sheet.save(target, quality=92)
    print(target.resolve())
