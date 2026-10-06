"""Preserve native evidence as full-size JPEGs plus browsable review sheets."""
from pathlib import Path
from PIL import Image, ImageDraw
import hashlib, json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/production/phase4e/extraction'
def main():
    entries=[]; groups={}
    for kind in ['extracted-art','extracted-icons']:
        for source in sorted((ROOT/'.godot_test_data/phase4e'/kind).rglob('*.png')):
            if source.stem in [a+'_'+w+'_left_TEMP_preserved' for a in ['emberhorn','mosskin'] for w in ['wand','orb']]:
                continue # Earlier candidate capture superseded by the real authored left view.
            rel=Path('native')/kind/source.parent.name/(source.stem+'.jpg')
            target=OUT/rel;target.parent.mkdir(parents=True,exist_ok=True)
            with Image.open(source) as image:
                image.convert('RGB').save(target,quality=94,subsampling=0)
                size=list(image.size)
            entries.append(dict(path=rel.as_posix(),source=source.relative_to(ROOT).as_posix(),source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),sha256=hashlib.sha256(target.read_bytes()).hexdigest(),canvas=size,label=source.stem))
            groups.setdefault((kind,source.parent.name),[]).append(target)
    pages=[]
    for (kind,layout),files in groups.items():
        selected=[p for p in files if '_source_' in p.stem or kind=='extracted-icons']
        for start in range(0,len(selected),4):
            subset=selected[start:start+4]; sheet=Image.new('RGB',(1600,950),(18,24,35));draw=ImageDraw.Draw(sheet)
            for index,path in enumerate(subset):
                with Image.open(path) as im:
                    im.thumbnail((390,885));sheet.paste(im,(index*400+(400-im.width)//2,55))
                draw.text((index*400+5,12),path.stem,fill='white')
                draw.text((index*400+5,30),layout,fill='white')
            rel=Path('review-sheets')/(kind+'-'+layout+'-%02d.jpg'%(start//4+1));target=OUT/rel;target.parent.mkdir(parents=True,exist_ok=True);sheet.save(target,quality=94,subsampling=0);pages.append(rel.as_posix())
    (OUT/'evidence-manifest.json').write_text(json.dumps(dict(native_count=len(entries),native=entries,review_sheets=pages,notes='Native originals at full resolution; JPEG94, no crop. Small sheets are navigation previews, use full image links for acceptance.'),indent=2)+'\n')
    lines=['# Phase4E extracted canonical art — native gallery','','Full-size phone/tablet evidence. Source idles and one actual Gloomlet wind-up are authored; filenames explicitly mark missing-phase TEMP fallbacks. Target relationship is staged in an isolated native fixture, not a physical-device or organic-run acceptance.','','## Review sheets','']
    for page in pages: lines.extend(['['+Path(page).stem+']('+page+')','', '!['+Path(page).stem+']('+page+')',''])
    lines.extend(['## Full resolution',''])
    for entry in entries:lines.append('- ['+entry['source'].split('/')[-2]+' / '+entry['label']+']('+entry['path']+')')
    (OUT/'GALLERY.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({'native':len(entries),'review_sheets':len(pages),'bytes':sum(p.stat().st_size for p in OUT.rglob('*.jpg'))}))
if __name__=='__main__': main()
