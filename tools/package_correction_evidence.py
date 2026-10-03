"""Package native renderer evidence compactly; full PNGs remain in QA storage."""
from pathlib import Path
from PIL import Image, ImageDraw
import json, shutil
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/production/phase2/correction/evidence'
OUT.mkdir(parents=True,exist_ok=True)
for src in (ROOT/'.godot_test_data/correction_matrix').glob('*.png'):
    Image.open(src).convert('RGB').save(OUT/(src.stem+'.webp'),quality=86,method=6)
shutil.copy2(ROOT/'.godot_test_data/correction_matrix/report.json',OUT/'matrix-report.json')
for layout in ['1080x2316','1200x1600']:
    files=sorted((ROOT/'.godot_test_data/correction_screens'/layout).glob('*.png'))
    for page in range((len(files)+11)//12):
        sheet=Image.new('RGB',(1280,1680),'#0d182d')
        draw=ImageDraw.Draw(sheet)
        for i,src in enumerate(files[page*12:page*12+12]):
            tile=Image.open(src).convert('RGB');tile.thumbnail((310,520),Image.Resampling.LANCZOS)
            x=(i%4)*320+(320-tile.width)//2;y=(i//4)*560
            sheet.paste(tile,(x,y));draw.text(((i%4)*320+5,y+525),src.stem,fill='white')
        sheet.save(OUT/f'screens-{layout}-{page+1}.webp',quality=88,method=6)
    print(layout,len(files),'native screens')
for layout in ['480x854','480x960','480x1040','480x1066','1080x2316','800x1280','1200x1600','1200x1920']:
    src=ROOT/'.godot_test_data'/f'mobile_{layout}_notch_hideout.png'
    if src.exists():
        image=Image.open(src).convert('RGB');image.thumbnail((480,1040))
        image.save(OUT/f'aspect-{layout}.webp',quality=86)
print('Packaged evidence:',OUT)
