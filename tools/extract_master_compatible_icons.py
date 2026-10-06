"""Additional compatible rune glyphs only; preserves completed v25 exports."""
import json
from extract_phase4e_locked import ROOT, OUT, edge_alpha, refine_alpha, fill_holes_and_keep_body, sha
from PIL import Image
SOURCE='art/reference/phase4e_handoff/approved_references/04_Lootlings_Art_Bible_Canonical_Reference.png'
CROPS={'rune_fire':(1338,443,1377,491),'rune_frost':(1377,443,1417,491),'rune_poison':(1417,443,1457,491),'rune_lightning':(1457,443,1492,491),'rune_arcane':(1492,443,1533,491)}
def main():
    source=ROOT/SOURCE; image=Image.open(source).convert('RGBA')
    p=OUT/'extraction_manifest.json'; manifest=json.loads(p.read_text())
    old=[e for e in manifest['entries'] if e['id'] not in CROPS]
    for id,box in CROPS.items():
        result=refine_alpha(fill_holes_and_keep_body(edge_alpha(image.crop(box)),keep_all=True))
        path=OUT/'hud'/(id+'.png');result.save(path)
        old.append(dict(id=id,kind='hud',source=SOURCE,source_sha256=sha(source),crop=list(box),asset_path='res://'+path.relative_to(ROOT).as_posix(),canvas=list(result.size),transparent=True,integrated=True,asset_sha256=sha(path),restrictions='Compatible rune/element inventory glyph only; no spell mechanics, identity or body changes'))
    manifest['entries']=old;p.write_text(json.dumps(manifest,indent=2)+'\n')
    print('Five compatible rune glyphs; completed 73 exports preserved')
if __name__=='__main__':main()
