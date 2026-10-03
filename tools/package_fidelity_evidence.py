"""Package native captures; originals remain in isolated QA storage."""
from pathlib import Path
from PIL import Image, ImageDraw
import shutil

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'docs/production/phase2/fidelity/evidence'
OUT.mkdir(parents=True, exist_ok=True)
RAW = ROOT/'.godot_test_data/fidelity'

def save(source, name, limit=None):
    image = Image.open(source).convert('RGB')
    if limit:
        image.thumbnail(limit, Image.Resampling.LANCZOS)
    image.save(OUT/(name+'.webp'), quality=86, method=4)

for source in (ROOT/'.godot_test_data/fidelity_matrix').glob('*.png'):
    save(source, source.stem, (1620, 1710))
shutil.copy2(ROOT/'.godot_test_data/fidelity_matrix/report.json', OUT/'matrix-report.json')
for facing in ['right', 'left']:
    image = Image.open(RAW/f'bows_{facing}.png').convert('RGB')
    for page in range(4):
        image.crop((0, page*930, 2400, (page+1)*930)).save(
            OUT/f'bow-{facing}-{page+1}.webp', quality=90, method=4)
for element in ['physical', 'fire', 'frost', 'lightning', 'poison', 'corruption', 'arcane']:
    sheet = Image.new('RGB', (1440, 310), '#0d182d')
    for column, weapon in enumerate(['bow', 'crossbow', 'sling', 'staff', 'wand', 'orb']):
        for row, phase in enumerate(['projectile', 'impact']):
            tile = Image.open(RAW/f'{phase}_{element}_{weapon}.png').convert('RGB').crop((0,310,480,620))
            tile.thumbnail((240, 155), Image.Resampling.LANCZOS)
            sheet.paste(tile, (column*240, row*155))
    sheet.save(OUT/f'projectiles-{element}.webp', quality=90, method=4)
for source in RAW.glob('*drop*.png'):
    save(source, source.stem)
save(RAW/'combat_death_pickups.png', 'combat_death_pickups')
shutil.copy2(RAW/'combat-voices.wav', OUT/'combat-voices.wav')
for layout in ['1080x2316', '1200x1600']:
    files = sorted((ROOT/'.godot_test_data/fidelity_screens'/layout).glob('*.png'))
    assert len(files) == 68, (layout, len(files))
    for page in range((len(files)+11)//12):
        sheet = Image.new('RGB', (1280, 1680), '#0d182d')
        draw = ImageDraw.Draw(sheet)
        for i, source in enumerate(files[page*12:page*12+12]):
            tile = Image.open(source).convert('RGB')
            tile.thumbnail((310, 520), Image.Resampling.LANCZOS)
            x = (i%4)*320+(320-tile.width)//2
            y = (i//4)*560
            sheet.paste(tile, (x, y))
            draw.text(((i%4)*320+5, y+525), source.stem, fill='white')
        sheet.save(OUT/f'screens-{layout}-{page+1}.webp', quality=88, method=4)
    for name in ['fidelity_combat_pickups', 'hoard_ejection_qa', 'hoard_chest_qa', 'signature_loot_qa']:
        save(ROOT/'.godot_test_data/fidelity_screens'/layout/(name+'.png'), name+'-'+layout)
print('Packaged native evidence:', OUT)
