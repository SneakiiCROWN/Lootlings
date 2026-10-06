"""Non-generative extraction of locked source pixels; never synthesizes states.

Body candidates require individual alpha/identity review before runtime routing.
Expression portraits intentionally remain opaque: their painted backgrounds are
part of the portrait, not an incorrectly advertised transparent combat body.
"""
from pathlib import Path
from collections import deque
import hashlib, json, sys
from PIL import Image, ImageDraw, ImageFilter
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'.godot_test_data/image-tools'))
import cv2
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'art/production/phase4e'
SOURCES = ROOT / 'art/reference/canonical/characters'
ACTORS = ['emberhorn', 'mosskin', 'moonkip', 'pebblewyrm', 'glimmerfin', 'gloomlet']
EXPRESSIONS = ['happy', 'cheeky', 'angry', 'excited', 'sad', 'curious', 'surprised', 'determined']
# Native-pixel silhouette paths, traced against the locked sheets. These are
# alpha masks only: no missing fingers, tails, clothing or weapons are painted.
OUTLINES = {
 'gloomlet': [(26,2),(35,7),(52,17),(56,20),(61,19),(67,28),(77,39),(81,29),(80,38),(85,47),(93,51),(102,50),(108,46),(118,35),(121,23),(125,19),(128,30),(132,54),(132,63),(136,58),(133,69),(129,76),(131,88),(133,91),(130,95),(130,103),(126,106),(127,108),(123,112),(115,115),(116,119),(119,122),(117,125),(122,129),(120,132),(124,135),(121,138),(119,143),(126,146),(128,151),(132,158),(130,164),(125,167),(121,165),(117,159),(115,157),(114,170),(119,176),(117,178),(111,175),(108,180),(110,183),(116,186),(117,189),(108,190),(99,188),(93,190),(81,188),(81,181),(72,184),(69,191),(65,190),(62,192),(57,191),(54,192),(51,190),(50,185),(52,182),(39,185),(31,187),(37,176),(44,166),(36,171),(26,174),(28,170),(19,172),(16,177),(18,172),(16,168),(7,161),(2,154),(0,141),(1,129),(6,117),(15,107),(25,102),(30,104),(36,103),(43,108),(53,105),(60,106),(52,100),(56,98),(46,95),(43,92),(31,88),(27,85),(38,84),(29,79),(32,77),(23,76),(17,74),(21,73),(20,70),(16,63),(13,58),(18,57),(15,49),(18,38),(20,31),(18,29),(22,30),(25,31)],
 'pebblewyrm': [(46,1),(48,0),(63,11),(67,16),(70,20),(74,23),(75,21),(76,26),(80,28),(84,19),(88,14),(94,17),(103,35),(106,36),(108,43),(110,33),(113,31),(115,44),(118,45),(119,53),(116,59),(115,66),(117,69),(118,69),(122,77),(123,82),(120,88),(116,92),(110,97),(109,102),(114,106),(116,112),(119,115),(121,119),(124,121),(125,127),(128,132),(129,137),(132,139),(132,147),(129,153),(123,155),(120,153),(117,154),(117,161),(113,167),(118,172),(123,177),(124,180),(122,183),(114,183),(108,180),(100,182),(94,181),(86,181),(79,179),(77,174),(69,177),(69,182),(64,185),(59,185),(55,183),(47,185),(43,182),(37,184),(30,182),(29,179),(31,174),(34,170),(38,168),(36,165),(29,165),(24,162),(20,160),(16,160),(10,155),(12,153),(7,149),(3,142),(1,134),(0,124),(0,115),(3,105),(8,98),(13,93),(18,91),(20,93),(21,98),(25,98),(29,96),(33,96),(35,92),(33,90),(21,88),(19,87),(24,85),(18,83),(23,78),(19,76),(15,73),(13,70),(18,69),(14,66),(18,65),(30,63),(33,60),(27,60),(20,57),(17,52),(18,50),(21,49),(16,47),(17,45),(26,43),(28,36),(27,30),(30,28),(31,26),(31,21),(36,23),(43,25),(44,13)]
}

def traced(image, outline):
    mask = Image.new('L',(image.width*4,image.height*4))
    ImageDraw.Draw(mask).polygon([(x*4,y*4) for x,y in outline],fill=255)
    image.putalpha(mask.resize(image.size,Image.Resampling.LANCZOS))
    return image

def refine_alpha(image):
    """Seeded graph cut adjusts alpha only; foreground RGB is untouched."""
    rgb=np.array(image)[:,:,:3].copy();alpha=np.array(image.getchannel('A'))
    sure=cv2.erode((alpha>128).astype('uint8'),np.ones((7,7),np.uint8))
    possible=cv2.dilate((alpha>128).astype('uint8'),np.ones((7,7),np.uint8))
    mask=np.full(alpha.shape,cv2.GC_BGD,dtype=np.uint8)
    mask[possible>0]=cv2.GC_PR_BGD;mask[alpha>128]=cv2.GC_PR_FGD;mask[sure>0]=cv2.GC_FGD
    mask[0,:]=mask[-1,:]=mask[:,0]=mask[:,-1]=cv2.GC_BGD
    bg=np.zeros((1,65),np.float64);fg=np.zeros((1,65),np.float64)
    cv2.setRNGSeed(4)
    cv2.grabCut(rgb,mask,None,bg,fg,5,cv2.GC_INIT_WITH_MASK)
    selected=np.isin(mask,[cv2.GC_FGD,cv2.GC_PR_FGD]).astype(np.uint8)*255
    # A half-pixel alpha transition, without recolouring any source pixel.
    image.putalpha(Image.fromarray(selected).filter(ImageFilter.GaussianBlur(.35)))
    return image

def fill_holes_and_keep_body(image, keep_all=False):
    w,h=image.size; pix=image.load(); outside=set(); queue=deque([(x,y) for x in range(w) for y in (0,h-1)]+[(x,y) for y in range(h) for x in (0,w-1)])
    while queue:
        x,y=queue.popleft()
        if not (0<=x<w and 0<=y<h) or (x,y) in outside or pix[x,y][3]>0: continue
        outside.add((x,y)); queue.extend([(x-1,y),(x+1,y),(x,y-1),(x,y+1)])
    for y in range(h):
        for x in range(w):
            if pix[x,y][3]==0 and (x,y) not in outside: pix[x,y]=(*pix[x,y][:3],255)
    if keep_all:return image
    seen=set(); largest=[]; components=[]
    for y in range(h):
        for x in range(w):
            if (x,y) in seen or pix[x,y][3]==0: continue
            component=[]; queue=deque([(x,y)])
            while queue:
                a,b=queue.popleft()
                if not(0<=a<w and 0<=b<h) or (a,b) in seen or pix[a,b][3]==0:continue
                seen.add((a,b));component.append((a,b));queue.extend([(a-1,b),(a+1,b),(a,b-1),(a,b+1)])
            if len(component)>len(largest):largest=component
            components.append(component)
    keep=set(largest)
    xs=[p[0] for p in largest];ys=[p[1] for p in largest]
    for component in components:
        # Preserve detached toe/fin pixels within the actor footprint. Never
        # erase a dark ankle simply because the sheet background touches it.
        if all(min(xs)-4<=x<=max(xs)+4 and min(ys)<=y<=max(ys)+18 for x,y in component):keep.update(component)
    for y in range(h):
        for x in range(w):
            if (x,y) not in keep:pix[x,y]=(*pix[x,y][:3],0)
    return image

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def edge_alpha(image):
    """Remove edge-connected neutral sheet background only; preserve source RGB."""
    image = image.convert('RGBA')
    w, h = image.size
    pixels = image.load()
    queue = deque([(x, y) for x in range(w) for y in (0, h-1)] + [(x, y) for y in range(h) for x in (0, w-1)])
    seen = set()
    while queue:
        x, y = queue.popleft()
        if not (0 <= x < w and 0 <= y < h) or (x, y) in seen:
            continue
        seen.add((x, y))
        r, g, b, a = pixels[x, y]
        if max(r, g, b) < 76 and max(r, g, b)-min(r, g, b) < 32:
            pixels[x, y] = (r, g, b, 0)
            queue.extend([(x-1, y), (x+1, y), (x, y-1), (x, y+1)])
    return image

def main():
    entries = []
    runtime=[]
    candidate_dir = ROOT / '.godot_test_data/phase4e/extraction-candidates'
    candidate_dir.mkdir(parents=True, exist_ok=True)
    for actor in ACTORS:
        source = SOURCES / (actor.capitalize()+'_CharacterSheet_Canonical.png')
        image = Image.open(source).convert('RGBA')
        for i, expression in enumerate(EXPRESSIONS):
            x = 641 + (i % 4)*96
            y = 762 + (i // 4)*110
            box = (x, y, x+88, y+86)
            path = OUT / 'ui/expressions' / (actor+'_'+expression+'.png')
            path.parent.mkdir(parents=True, exist_ok=True)
            image.crop(box).save(path)
            entries.append(dict(id=actor+'_'+expression, actor=actor, kind='expression_portrait', source=source.relative_to(ROOT).as_posix(), source_sha256=sha(source), crop=list(box), asset_path='res://'+path.relative_to(ROOT).as_posix(), canvas=[88,86], transparent=False, integrated=True, restrictions='Contextual UI portrait only; not a body, outfit unlock, or combat state'))
        for view, box in [('front',(0,765,166,954)), ('three_quarter_right',(166,765,318,954)), ('side',(318,765,462,954)), ('back',(462,765,615,954))]:
            edge_alpha(image.crop(box)).save(candidate_dir/(actor+'_'+view+'.png'))
        box=(150,760,322,957) if actor=='gloomlet' else (160,765,316,956) if actor in ['glimmerfin','moonkip'] else (166,765,318,956)
        body=image.crop(box)
        if actor in OUTLINES:
            outline=OUTLINES[actor]
            if actor=='gloomlet':
                outline=[(x+16-(10 if x<=7 and 117<=y<=161 else 5 if x>120 and 76<=y<=112 else 4 if x>124 and 146<=y<=167 else 0),y+5) for x,y in outline]
            body=traced(body,outline)
        else:body=fill_holes_and_keep_body(edge_alpha(body))
        body=refine_alpha(body)
        body.save(candidate_dir/(actor+'_reviewed_idle_right.png'))
        bounds=body.getbbox();body=body.crop(bounds)
        factor=480/max(body.size);size=(round(body.width*factor),round(body.height*factor))
        resized=body.resize(size,Image.Resampling.LANCZOS)
        canvas=Image.new('RGBA',(512,512));offset=((512-size[0])//2,496-size[1]);canvas.alpha_composite(resized,offset)
        path=OUT/'lootlings'/actor/(actor+'_idle_right.png');path.parent.mkdir(parents=True,exist_ok=True);canvas.save(path)
        palms={'emberhorn':[(106,144),(54,146)],'mosskin':[(64,139),(119,131)],'moonkip':[(119,142),(58,134)],'pebblewyrm':[(122,139),(51,141)],'glimmerfin':[(131,138),(73,132)],'gloomlet':[(140,158),(59,148)]}[actor]
        anchors=[[(offset[0]+(x-bounds[0])*factor)/512,(offset[1]+(y-bounds[1])*factor)/512] for x,y in palms]
        # Existing weapons/shield remain baked. Never claim a weaponless Moonkip.
        weapons=['daggers'] if actor=='moonkip' else ['wand','orb'] if actor=='mosskin' else ['wand','orb','daggers','claws']
        entry=dict(id=actor+'_idle_right',actor=actor,kind='body',source=source.relative_to(ROOT).as_posix(),source_sha256=sha(source),crop=list(box),asset_path='res://'+path.relative_to(ROOT).as_posix(),canvas=[512,512],transparent=True,integrated=True,restrictions='IDLE right only; no move/attack/hurt/opposite-view manufacture',baked_weapon='daggers' if actor=='moonkip' else 'shield' if actor=='mosskin' else '',uniform_scale=factor,primary_anchor=anchors[0],secondary_anchor=anchors[1],feet_baseline=64)
        entries.append(entry)
        runtime.append(dict(actor=actor,phase='IDLE',facing='right_only',weapon_types=weapons,asset_path=entry['asset_path'],body_rect=[-96,-128,192,192],primary_anchor=anchors[0],secondary_anchor=anchors[1],core_anchor=[.55,.63],feet_baseline=58,supports_two_hand=False,foreground_layer='',draw_depth='front',weapon_overrides={},wardrobe_requires={},baked_weapon=entry['baked_weapon']))
        if actor in ['emberhorn','mosskin']:
            box=(312,765,462,956)
            body=refine_alpha(fill_holes_and_keep_body(edge_alpha(image.crop(box))))
            bounds=body.getbbox();body=body.crop(bounds);factor=480/max(body.size);size=(round(body.width*factor),round(body.height*factor));offset=((512-size[0])//2,496-size[1])
            canvas=Image.new('RGBA',(512,512));canvas.alpha_composite(body.resize(size,Image.Resampling.LANCZOS),offset)
            path=OUT/'lootlings'/actor/(actor+'_idle_left.png');canvas.save(path)
            palms=[(48,133),(48,133)] if actor=='emberhorn' else [(43,140),(43,140)]
            anchors=[[(offset[0]+(x-bounds[0])*factor)/512,(offset[1]+(y-bounds[1])*factor)/512] for x,y in palms]
            entry=dict(id=actor+'_idle_left',actor=actor,kind='body',source=source.relative_to(ROOT).as_posix(),source_sha256=sha(source),crop=list(box),asset_path='res://'+path.relative_to(ROOT).as_posix(),canvas=[512,512],transparent=True,integrated=True,restrictions='Actual left side illustration; IDLE wand/orb only; hidden support hand remains unavailable',uniform_scale=factor,primary_anchor=anchors[0],secondary_anchor=anchors[1],feet_baseline=58)
            entries.append(entry)
            runtime.append(dict(actor=actor,phase='IDLE',facing='left_only',weapon_types=['wand','orb'],asset_path=entry['asset_path'],body_rect=[-96,-128,192,192],primary_anchor=anchors[0],secondary_anchor=anchors[1],core_anchor=[.45,.63],feet_baseline=58,supports_two_hand=False,foreground_layer='',draw_depth='front',weapon_overrides={},wardrobe_requires={},baked_weapon=''))
    source=SOURCES/'Lootlings_Main_Mascot_RelicBeast_Canonical.png'
    image=Image.open(source).convert('RGBA');mask=Image.open(ROOT/'art/sprites/relic_beast_base.png').getchannel('A')
    assert image.size==mask.size
    image.putalpha(mask)
    image=image.resize((512,512),Image.Resampling.LANCZOS)
    path=OUT/'lootlings/relic_beast/relic_beast_idle_right.png';path.parent.mkdir(parents=True,exist_ok=True);image.save(path)
    entries.append(dict(id='relic_beast_idle_right',actor='relic_beast',kind='body',source=source.relative_to(ROOT).as_posix(),source_sha256=sha(source),asset_path='res://'+path.relative_to(ROOT).as_posix(),canvas=[512,512],transparent=True,integrated=True,restrictions='IDLE right only; established alpha guide; canonical RGB; uniform downsample',alpha_guide='art/sprites/relic_beast_base.png'))
    runtime.append(dict(actor='relic_beast',phase='IDLE',facing='right_only',weapon_types=['wand','orb','daggers','claws'],asset_path=entries[-1]['asset_path'],body_rect=[-96,-128,192,192],primary_anchor=[.797,.749],secondary_anchor=[.52,.707],core_anchor=[.63,.594],feet_baseline=52,supports_two_hand=False,foreground_layer='',draw_depth='front',weapon_overrides={},wardrobe_requires={},baked_weapon=''))
    source=SOURCES/'Gloomlet_CharacterSheet_Canonical.png';box=(563,536,747,697)
    body=Image.open(source).convert('RGBA').crop(box)
    outline=[(12,110),(6,91),(11,77),(17,70),(24,63),(41,59),(59,62),(72,73),(83,78),(89,73),(89,58),(91,42),(90,27),(103,30),(116,38),(129,51),(131,44),(138,53),(145,49),(149,47),(148,34),(147,22),(156,39),(168,61),(174,77),(174,85),(166,93),(170,99),(164,109),(157,112),(150,116),(150,121),(156,128),(169,136),(170,141),(165,144),(155,143),(147,139),(140,135),(138,128),(135,128),(128,132),(128,141),(118,142),(112,146),(104,146),(99,144),(91,146),(86,143),(86,132),(84,130),(77,135),(79,139),(78,143),(72,143),(65,142),(65,129),(56,130),(52,134),(47,141),(41,142),(35,140),(32,141),(26,139),(28,129),(31,122),(26,122),(21,122),(17,118)]
    body=refine_alpha(traced(body,outline));bounds=body.getbbox();body=body.crop(bounds);factor=480/max(body.size);size=(round(body.width*factor),round(body.height*factor));offset=((512-size[0])//2,496-size[1]);canvas=Image.new('RGBA',(512,512));canvas.alpha_composite(body.resize(size,Image.Resampling.LANCZOS),offset)
    path=OUT/'lootlings/gloomlet/gloomlet_windup_right.png';canvas.save(path)
    anchors=[[(offset[0]+(x-bounds[0])*factor)/512,(offset[1]+(y-bounds[1])*factor)/512] for x,y in [(154,137),(99,140)]]
    entries.append(dict(id='gloomlet_windup_right',actor='gloomlet',kind='body',source=source.relative_to(ROOT).as_posix(),source_sha256=sha(source),crop=list(box),asset_path='res://'+path.relative_to(ROOT).as_posix(),canvas=[512,512],transparent=True,integrated=True,restrictions='Existing crouched unarmed attack-sequence illustration; claws anticipation only, no fake release or opposite view',primary_anchor=anchors[0],secondary_anchor=anchors[1],uniform_scale=factor))
    runtime.append(dict(actor='gloomlet',phase='ANTICIPATE',facing='right_only',weapon_types=['claws'],asset_path=entries[-1]['asset_path'],body_rect=[-96,-128,192,192],primary_anchor=anchors[0],secondary_anchor=anchors[1],core_anchor=[.64,.64],feet_baseline=58,supports_two_hand=False,foreground_layer='',draw_depth='front',weapon_overrides={},wardrobe_requires={},baked_weapon=''))
    bible=ROOT/'art/reference/phase4e_handoff/approved_references/04_Lootlings_Art_Bible_Canonical_Reference.png'
    original=Image.open(bible).convert('RGBA')
    icon_crops={'bow':(599,299,664,374),'claws':(666,299,730,374),'crossbow':(733,300,800,374),'daggers':(800,298,860,374),'greatsword':(861,298,927,375),'greataxe':(928,298,1000,375),'maul':(599,418,663,481),'orb':(665,418,730,481),'sling':(733,418,796,481),'spear':(797,418,860,481),'staff':(861,418,930,481),'wand':(930,417,1000,482)}
    icon_crops.update({'core_fire':(1318,449,1358,491),'core_lightning':(1440,449,1480,491),'gear_rune':(1485,448,1527,491)})
    for icon,box in icon_crops.items():
        asset=refine_alpha(fill_holes_and_keep_body(edge_alpha(original.crop(box)),keep_all=True))
        kind='weapons' if icon in icon_crops and icon not in ['core_fire','core_lightning','gear_rune'] else 'hud'
        path=OUT/kind/(icon+'_inventory.png' if kind=='weapons' else icon+'.png');path.parent.mkdir(parents=True,exist_ok=True);asset.save(path)
        entries.append(dict(id=icon,kind=kind,source=bible.relative_to(ROOT).as_posix(),source_sha256=sha(bible),crop=list(box),asset_path='res://'+path.relative_to(ROOT).as_posix(),canvas=list(asset.size),transparent=True,integrated=True,restrictions='Owner-authorized compatible element only; inventory/HUD icon at32-64px, never a held/combat sprite or new game ID'))
    manifest = dict(authority='Existing locked repository character sheets; compatible weapon/HUD elements specifically allowed by owner extraction directive; latest external sheet ignored', method='Original source RGB; alpha-only masking; body exports uniformly resampled, portraits/icons native size; no repaint, synthesis or mirroring', entries=entries)
    (OUT/'extraction_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    for entry in entries:entry['asset_sha256']=sha(ROOT/entry['asset_path'].removeprefix('res://'))
    (OUT/'extraction_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    (OUT/'runtime_manifest.json').write_text(json.dumps(dict(entries=runtime,authority='Owner extraction directive, locked sheet identity; idle-only integration, no final art acceptance'),indent=2)+'\n',encoding='utf-8')
    previews = Image.new('RGB',(6*320,4*410),'#647480')
    draw = ImageDraw.Draw(previews)
    for col, actor in enumerate(ACTORS):
        for row, view in enumerate(['front','three_quarter_right','side','back']):
            body = Image.open(candidate_dir/(actor+'_'+view+'.png'))
            body = body.resize((body.width*2,body.height*2), Image.Resampling.NEAREST)
            previews.paste(body,(col*320,row*410+24),body)
            draw.text((col*320+4,row*410+4),actor+' '+view,fill='white')
    previews.save(candidate_dir/'review.png')
    print('Extracted',len(entries),'locked-source exports;',len(runtime),'phase-restricted body views')

if __name__ == '__main__':
    main()
