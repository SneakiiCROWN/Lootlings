"""Validate the single economy art package without granting artistic acceptance."""
from pathlib import Path
import json,hashlib
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
def validate():
 data=json.loads((ROOT/'art/ui/economy/CURRENCY_ART_MANIFEST.json').read_text(encoding='utf-8'))
 assert len(data['assets'])==2
 for row in data['assets']:
  for key in ['reference','source','runtime']:
   assert hashlib.sha256((ROOT/row[key]).read_bytes()).hexdigest()==row[key+'_sha256']
  im=Image.open(ROOT/row['runtime']);assert im.mode=='RGBA' and list(im.size)==row['canvas']
  alpha=im.getchannel('A');bbox=alpha.getbbox();assert bbox and min(bbox[0],bbox[1],im.width-bbox[2],im.height-bbox[3])>=2
  assert alpha.getextrema()==(0,255)
 assert '"mastery":"core_neutral"' in (ROOT/'relic_spin_catalog.gd').read_text(encoding='utf-8-sig')
 print('CURRENCY ART PASS: two hash-locked sources/runtime sprites, alpha/padding/dimensions; separate mastery identity; artistic acceptance not inferred.')
if __name__=='__main__':validate()
