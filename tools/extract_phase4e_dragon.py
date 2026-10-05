"""Trace an approved reference's complete idle silhouette; never synthesize body art.
Native source pixels retained. Full-tail alpha mask, no cropping to hide defects.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json
ROOT=Path(__file__).resolve().parents[1]
source=ROOT/'art/reference/phase4e_handoff/approved_references/01_Hoard_Dragon_Canonical_Reference.png'
crop=(0,140,224,315)
outline=[(12,108),(24,101),(38,102),(26,114),(15,125),(13,142),(21,155),(37,165),(51,166),(60,159),(77,158),(75,147),(83,143),(89,143),(95,136),(99,122),(88,125),(88,119),(100,109),(107,99),(87,109),(78,105),(58,113),(64,99),(82,82),(48,66),(40,64),(16,73),(28,59),(50,44),(78,39),(99,40),(85,23),(111,33),(129,49),(151,63),(154,71),(146,79),(151,88),(146,97),(157,98),(172,104),(183,108),(181,82),(192,75),(203,87),(210,109),(215,125),(210,131),(210,144),(196,143),(195,136),(183,136),(179,126),(168,138),(162,147),(153,156),(156,165),(146,169),(135,166),(126,164),(121,166),(109,169),(96,166),(95,163),(78,167),(66,174),(50,174),(37,173),(23,168),(14,160),(9,146),(8,128),(11,118)]
hole=[(22,124),(34,121),(43,127),(52,128),(59,127),(72,123),(67,137),(62,146),(52,154),(35,157),(24,150),(21,140)]
image=Image.open(source).convert('RGBA').crop(crop)
mask=Image.new('L',image.size);d=ImageDraw.Draw(mask);d.polygon(outline,fill=255);d.polygon(hole,fill=0)
image.putalpha(mask)
out=ROOT/'art/reference/phase4e_handoff/experiments';out.mkdir(parents=True,exist_ok=True)
image.save(out/'hoard_dragon_idle_right.png')
(out/'hoard_dragon_idle_right.json').write_text(json.dumps({'source':str(source.relative_to(ROOT)),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'crop':crop,'outline':outline,'negative_space':hole,'native_resolution':[224,175],'approval':'REFERENCE_REJECTED_IDENTITY_DRIFT: experimental winged body must not enter runtime','limitations':'Preserved experiment only. Changes established wingless/coiled dragon anatomy; mask is incomplete and native board silhouette is ~200 pixels. Do not promote or upscale into a production export.'},indent=2)+'\n',encoding='utf-8')
