"""Original-pixel alpha-only extraction of large approved neutral poses.
Small board strips are not promoted; these exact large poses require native review.
"""
from pathlib import Path
import json,hashlib
from PIL import Image,ImageDraw,ImageFilter
from extract_phase4e_locked import traced,cv2,np
R=Path(__file__).resolve().parents[1]
# Explicit whole-body neutral panels, source facing preserved. No attack/hurt relabel.
SPECS={
 'fen_sneak':((738,596,1024,797),[(3,125),(21,108),(24,90),(43,68),(81,57),(101,29),(123,11),(137,17),(156,8),(171,22),(185,41),(213,20),(225,30),(235,48),(230,68),(258,87),(268,105),(257,119),(241,121),(257,138),(271,153),(265,166),(234,174),(212,176),(189,187),(169,188),(154,175),(129,170),(113,184),(87,181),(68,170),(47,175),(22,171),(14,155)]),
 'forge_beetle':((12,155,298,387),[(8,132),(23,105),(30,83),(49,67),(61,30),(91,13),(105,8),(124,17),(145,8),(171,19),(188,45),(199,79),(222,37),(239,16),(241,65),(260,85),(274,120),(272,150),(257,171),(268,193),(270,214),(242,218),(221,211),(199,220),(168,218),(150,208),(125,218),(89,219),(79,207),(53,215),(24,208),(17,183),(10,164)]),
 'mirror_knight':((9,154,300,389),[(5,64),(17,26),(43,41),(65,11),(89,27),(108,47),(123,20),(141,12),(160,33),(175,49),(188,68),(201,80),(230,111),(256,122),(275,145),(272,168),(258,190),(255,218),(233,229),(211,218),(181,219),(159,211),(139,220),(118,220),(99,208),(89,221),(59,220),(48,199),(28,188),(16,173),(19,148),(8,124),(2,92)]),
 'first_guard':((740,155,1028,398),[(9,59),(20,28),(49,13),(67,29),(92,24),(121,40),(145,57),(164,36),(186,26),(202,54),(230,14),(247,5),(259,23),(255,44),(264,59),(253,91),(261,116),(274,154),(269,180),(249,193),(253,222),(235,234),(211,230),(195,218),(173,226),(155,220),(134,233),(107,236),(89,219),(65,219),(54,209),(27,217),(17,196),(22,162),(10,139),(6,112)]),
 'deck_hexer':((12,160,297,397),[(30,115),(47,99),(56,75),(49,62),(68,47),(86,35),(100,16),(115,14),(130,32),(153,29),(185,48),(210,56),(236,43),(261,43),(254,67),(238,87),(217,103),(202,117),(212,140),(238,161),(252,172),(265,180),(260,193),(238,204),(217,211),(186,214),(163,211),(143,225),(119,224),(99,215),(73,221),(59,206),(38,209),(24,193),(21,173),(28,149)]),
 'pack_peddler':((12,160,295,409),[(6,64),(17,29),(36,12),(64,10),(80,27),(91,34),(109,22),(131,25),(152,43),(174,24),(193,29),(206,51),(236,38),(258,50),(272,65),(269,92),(251,116),(241,133),(257,158),(264,181),(253,193),(234,198),(229,224),(211,238),(189,239),(174,225),(152,230),(131,228),(112,235),(95,229),(77,238),(56,230),(44,212),(18,210),(13,190),(5,165),(9,138),(2,111)]),
}
SPECS['fen_sneak']=((731,590,1028,800),[(x+7,y+6) for x,y in SPECS['fen_sneak'][1]])
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 refs={e['game_id']:e for e in json.loads((R/'art/approved_missing_canon_references.json').read_text())['entries']}
 manifest=json.loads((R/'docs/production/NEEDS_NEW_CANON_EXPORT.json').read_text())
 out=R/'.godot_test_data/new-canon-neutral';out.mkdir(parents=True,exist_ok=True)
 preview=Image.new('RGB',(1536,600),'#536576');draw=ImageDraw.Draw(preview);entries=[]
 for i,(actor,(box,outline)) in enumerate(SPECS.items()):
  ref=refs[actor];source=R/ref['source'];original=Image.open(source).convert('RGBA').crop(box)
  cut=traced(original.copy(),outline)
  region=np.array(cut.getchannel('A'))>128
  region=cv2.dilate(region.astype('uint8'),np.ones((15,15),np.uint8))>0
  rgb=np.array(original)[:,:,:3].copy();mask=np.full(region.shape,cv2.GC_BGD,np.uint8)
  mask[region]=cv2.GC_PR_FGD
  inside=cv2.erode(region.astype('uint8'),np.ones((17,17),np.uint8))>0
  mask[inside & (rgb.max(axis=2)>150)]=cv2.GC_FGD
  mask[0,:]=mask[-1,:]=mask[:,0]=mask[:,-1]=cv2.GC_BGD
  cv2.setRNGSeed(4);cv2.grabCut(rgb,mask,None,np.zeros((1,65)),np.zeros((1,65)),7,cv2.GC_INIT_WITH_MASK)
  alpha=np.isin(mask,[cv2.GC_FGD,cv2.GC_PR_FGD]).astype('uint8')*255
  cut.putalpha(Image.fromarray(alpha).filter(ImageFilter.GaussianBlur(.35)))
  assert cut.convert('RGB').tobytes()==original.convert('RGB').tobytes()
  cut.save(out/(actor+'_source_alpha.png'))
  preview.paste(cut,(i%3*512+100,i//3*300+32),cut);draw.text((i%3*512+10,i//3*300+8),actor,fill='white')
  state='rest' if actor=='pack_peddler' else 'idle'
  p=next(p for p in manifest['packages'] if p['game_id']==actor and p['facing']=='right')
  if state in p['states']:req=p['states'][state]['requirements'][0]
  else:
   prior=next(e for e in json.loads((R/'art/production/phase4e/approved_missing_runtime_manifest.json').read_text())['entries'] if e['actor']==actor and e['state']==state and e['facing']=='right')
   req={'expected_filename':prior['filename'],'runtime_destination':prior['asset_path'].removeprefix('res://')}
  canvas=Image.new('RGBA',p['canvas']);bounds=cut.getbbox();body=cut.crop(bounds)
  # Only uniform resample; native rendered body is smaller than this delivery canvas.
  scale=min((p['canvas'][0]-64)/body.width,(p['canvas'][1]-64)/body.height)
  size=tuple(round(v*scale) for v in body.size);offset=((p['canvas'][0]-size[0])//2,p['baseline']['target_canvas_y']-size[1]);canvas.alpha_composite(body.resize(size,Image.Resampling.LANCZOS),offset)
  file=out/req['expected_filename'];canvas.save(file)
  entries.append({'actor':actor,'state':state,'facing':'right','source':ref['source'],'source_sha256':ref['source_sha256'],'crop':list(box),'alpha_outline':outline,'canvas':p['canvas'],'baseline':p['baseline']['target_canvas_y'],'pivot':p['anchor']['target_canvas'],'occupied_bounds':canvas.getbbox(),'source_body_pixels':list(body.size),'uniform_scale':scale,'filename':req['expected_filename'],'asset_path':'res://'+req['runtime_destination'],'asset_sha256':sha(file),'source_alpha_path':str(out/(actor+'_source_alpha.png')),'restrictions':'Large neutral source panel only; no mirror, hurt, motion or attack substitution. Original baked equipment retained; no reconstructed anatomy. Source RGB preserved before uniform resample. Native quality acceptance pending.'})
 (out/'candidate_manifest.json').write_text(json.dumps({'entries':entries},indent=2)+'\n');preview.save(out/'alpha-review.png');print('Six neutral candidates; not installed until visual/native review')
if __name__=='__main__':main()
