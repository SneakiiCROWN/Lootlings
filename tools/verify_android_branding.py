"""Inspect actual Android resources, not just export preset paths. Requires Pillow."""
from pathlib import Path
from PIL import Image, ImageChops, ImageStat, ImageDraw
import io, json, zipfile, argparse
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('apk');args=p.parse_args()
report=[];tiles=[]
with zipfile.ZipFile(args.apk) as apk:
    for entry,source in [
        ('res/mipmap/icon.webp','lootlings_icon.png'),
        ('res/mipmap/icon_foreground.webp','android_foreground.png'),
        ('res/mipmap/icon_background.webp','android_background.png'),
        ('res/mipmap/icon_monochrome.webp','android_monochrome.png'),
        ('res/drawable/splash_icon.webp','android_foreground.png')]:
        actual=Image.open(io.BytesIO(apk.read(entry))).convert('RGBA')
        expected=Image.open(ROOT/'art/ui/brand'/source).convert('RGBA').resize(actual.size,Image.Resampling.LANCZOS)
        # Composite on the same navy so invisible RGB is irrelevant.
        bg=Image.new('RGBA',actual.size,'#0d182d')
        a=Image.alpha_composite(bg,actual).convert('RGB');e=Image.alpha_composite(bg,expected).convert('RGB')
        error=sum(ImageStat.Stat(ImageChops.difference(a,e)).mean)/3
        assert error < 8, f'Android resource differs from canonical branding: {entry}: {error}'
        report.append(dict(resource=entry,source=source,size=list(actual.size),mean_rgb_error=round(error,3)))
        tile=Image.new('RGB',(240,280),'#0d182d');a.thumbnail((210,210));tile.paste(a,((240-a.width)//2,8))
        ImageDraw.Draw(tile).text((8,230),entry.split('/')[-1],fill='white');tiles.append(tile)
    template=zipfile.ZipFile(ROOT/'.godot_test_data/android/android_debug.apk')
    assert apk.read('res/drawable/splash_icon.webp') != template.read('res/drawable/splash_icon.webp'), 'Default engine splash icon survived'
out=ROOT/'.godot_test_data/android-branding';out.mkdir(exist_ok=True)
sheet=Image.new('RGB',(240*len(tiles),280),'#0d182d')
for i,tile in enumerate(tiles):sheet.paste(tile,(i*240,0))
sheet.save(out/'actual-apk-branding.png')
(out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
