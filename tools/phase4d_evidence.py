"""Lay out native screenshots for owner review; never modifies game assets."""
from pathlib import Path
from PIL import Image, ImageDraw
import argparse
import shutil

ROOT = Path(__file__).resolve().parents[1]
SCREENS = 'home patch sera ilex lootlings wanderers regions siege dungeon gear forge archive contracts merchant combat boss verdant level_up spinner results'.split()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--review', action='store_true')
    args = parser.parse_args()
    target = ROOT / ('.godot_test_data/phase4d/review' if args.review else 'docs/production/phase4d/evidence')
    target.mkdir(parents=True, exist_ok=True)
    for size in ['1080x2316', '1600x2560']:
        for stage in ['before', 'after']:
            source = ROOT / '.godot_test_data/phase4d' / stage / size
            if not all((source / (screen+'.png')).exists() for screen in SCREENS):
                continue
            for group in range(5):
                images = []
                for screen in SCREENS[group*4:group*4+4]:
                    im = Image.open(source / (screen+'.png')).convert('RGB')
                    im.thumbnail((420, 900))
                    cell = Image.new('RGB', (420, 930), '#07101e')
                    cell.paste(im, ((420-im.width)//2, 30))
                    ImageDraw.Draw(cell).text((10, 7), screen, fill='white')
                    images.append(cell)
                sheet = Image.new('RGB', (840, 1860), '#07101e')
                for i, im in enumerate(images): sheet.paste(im, ((i%2)*420, (i//2)*930))
                sheet.save(target / f'{size}-{stage}-{group+1}.jpg', quality=93)
        before = ROOT / '.godot_test_data/phase4d/before' / size
        after = ROOT / '.godot_test_data/phase4d/after' / size
        if not (after/'results.png').exists(): continue
        for screen in SCREENS:
            sheet = Image.new('RGB', (960, 1080), '#07101e')
            draw = ImageDraw.Draw(sheet)
            for i, folder in enumerate([before, after]):
                im = Image.open(folder/(screen+'.png')).convert('RGB')
                im.thumbnail((480, 1040))
                sheet.paste(im, (i*480+(480-im.width)//2, 40))
                draw.text((i*480+12, 12), f'{screen} / {"before" if i==0 else "after"} / {size}', fill='white')
            sheet.save(target/f'{size}-{screen}.jpg', quality=93)

    # Preserve the reviewed native actor sheets and exact pose/fit records.
    for source in (ROOT/'.godot_test_data/phase4d/review-final').glob('*.jpg'):
        shutil.copy2(source, target/source.name)
    shutil.copy2(ROOT/'.godot_test_data/phase4d/weapons/report.json', target/'weapon-matrix.json')
    bosses = ROOT/'.godot_test_data/phase4d/bosses'
    names = 'act_i mossglass_wilds moonfen frostbell_hollows sunken_gearworks cinder_crown starfall_archive nullglass_expanse skyhook_bastion first_hoard'.split()
    for group in range(2):
        sheet = Image.new('RGB',(1000,1450),'#07101e')
        for row, name in enumerate(names[group*5:group*5+5]):
            for column, state in enumerate(['idle','attack']):
                im=Image.open(bosses/f'{name}_{state}.png').convert('RGB')
                # The original full capture is retained separately; enlarge the arena for review.
                im=im.crop((0,int(im.height*.23),im.width,int(im.height*.72)))
                im.thumbnail((500,260))
                sheet.paste(im,(column*500+(500-im.width)//2,row*290+25))
                ImageDraw.Draw(sheet).text((column*500+8,row*290+5),f'{name} / {state}',fill='white')
        sheet.save(target/f'bosses-{group+1}.jpg',quality=94)
    for source in bosses.glob('*.png'):
        shutil.copy2(source,target/source.name)

if __name__ == '__main__': main()
