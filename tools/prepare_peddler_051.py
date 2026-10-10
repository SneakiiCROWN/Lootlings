from pathlib import Path
import json,hashlib,importlib.util,shutil
from PIL import Image,ImageDraw,ImageFilter,ImageChops
R=Path.cwd();S=R/'art/source/peddler_051';S.mkdir(exist_ok=True)
G=Path(r'C:/Users/Snkii/.codex/generated_images/01a119ec-aee5-7460-8419-3c1df0c7363f')
for name,file in [('wrong_facing_correction.png','exec-540a1539-c48a-4ebe-bb6e-0af4c77ce6e4.png'),('right_corrected.png','exec-8f8d4c72-88aa-4f25-8ba8-e9e71dd17919.png')]:
 if not (S/name).exists():shutil.copyfile(G/file,S/name)
spec=importlib.util.spec_from_file_location('components',R/'tools/sheet_alpha_components.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
M=R/'art/production_npc_manifest.json';data=read(M);assert not any(x['actor']=='pack_peddler' for x in data['entries'])
ref='art/reference/phase4e_handoff/chatgpt_generated_candidates/merchant_candidates/pack_peddler_merrow_canonical_candidate.png'
assert sha(R/ref)=='49247db3314ede12d2f757a63851700adb115520148074dcd200eb2d6c8d94dc'
rows=[]
for face,name in [('left','left_candidate.png'),('right','right_corrected.png')]:
 p=S/name;im=Image.open(p).convert('RGBA');assert im.getchannel('A').getextrema()[0]==0
 cs=sorted(mod.components(p),key=lambda c:(int(c['bounds'][1]>im.height*.45),c['bounds'][0]));assert len(cs)==5
 print(face,'alpha',im.getchannel('A').getextrema(),'bounds',[c['bounds'] for c in cs])
 for state,c in zip(['rest','talk','offer','inspect','return'],cs):
  b=c['bounds'];assert b[0]>0 and b[1]>0 and b[2]<im.width and b[3]<im.height
  mask=Image.new('L',im.size);draw=ImageDraw.Draw(mask)
  for y,a,z in c['runs']:draw.line((a,y,z-1,y),fill=255)
  mask=mask.filter(ImageFilter.MaxFilter(5));pixels=im.copy();pixels.putalpha(ImageChops.multiply(im.getchannel('A'),mask));pixels=pixels.crop(b)
  w,h=pixels.size;canvas=Image.new('RGBA',(w+32,h+32));canvas.alpha_composite(pixels,(16,16))
  dest=f'art/production/phase4e/npcs/pack_peddler/pack_peddler_{state}_{face}.png';(R/dest).parent.mkdir(parents=True,exist_ok=True);canvas.save(R/dest)
  row=dict(actor='pack_peddler',state=state,facing=face,asset_path='res://'+dest,canvas=list(canvas.size),content_rect=[16,16,w,h],pivot=[16+w/2,16+h],source_reference=ref,source_sha256=sha(R/ref),authored_source=p.relative_to(R).as_posix(),authored_source_sha256=sha(p),authored_source_bounds=b,contract_slot_id=f'pose:pack_peddler:{state}:{face}:None',production_status='awaiting_native_visual_review',native_validated=False,asset_sha256=sha(R/dest),source_delivery_canvas=[1024,1536],source_quality='Connected actual alpha silhouette; original pixels, 16px compact transparent gutter, no mirror or painted anatomy.',identity_subset='LEFT brown woodland Pack Peddler on approved dual-role board. Aquatic Merrow is a distinct identity, not merged.',prop_ownership='Intrinsic service potion/compass contact; no interchangeable weapon.')
  rows.append(row);write(R/dest.replace('.png','.json'),row)
data['entries']+=rows;write(M,data)
write(S/'EXTRACTION_RECEIPT.json',dict(staged_rows=rows,rejected=[dict(source='right_candidate.png',reason='Pale robe deviates from approved leafy traveller outfit',cells=5),dict(source='wrong_facing_correction.png',reason='All five corrections face left; invalid for right slots',cells=5)],accepted_contracts=0,fluid_animation_completed=False))
print('Staged ten independent service keyframes; no closures yet')
