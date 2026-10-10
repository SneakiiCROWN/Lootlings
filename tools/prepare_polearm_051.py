"""Stage independent canonical components; never overwrite an accepted batch."""
from pathlib import Path
import json,hashlib,importlib.util,math
from PIL import Image,ImageDraw,ImageFilter,ImageChops
ROOT=Path(__file__).resolve().parents[1];SOURCE=ROOT/'art/source/player_polearm_051';MAN=ROOT/'art/production/phase4e/player_polearm_051_manifest.json'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,o):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
if MAN.exists() and any(x.get('native_validated') for x in read(MAN)['entries']):raise SystemExit('Accepted batch preserved; stage a sibling correction instead')
spec=importlib.util.spec_from_file_location('components',ROOT/'tools/sheet_alpha_components.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
def cells(p):
 im=Image.open(p);cs=mod.components(p)
 return sorted(cs,key=lambda c:(int((c['bounds'][1]+c['bounds'][3])/2>=im.height/2),c['bounds'][0]))
contacts={
 'glimmerfin':[[[264,348],[337,298]],[[684,306],[714,230]],[[1104,347],[1136,318]],[[1445,349],[1485,319]],[[143,832],[70,782]],[[438,775],[426,709]],[[801,829],[785,797]],[[1268,832],[1217,793]]],
 'relic_beast':[[[260,303],[375,281]],[[705,294],[813,299]],[[506,525],[838,477]],[[1634,310],[1718,278]],[[168,735],[70,710]],[[649,746],[524,740]],[[1503,523],[1144,478]],[[1580,748],[1419,714]]]
}
queue={x['slot_id']:x for x in read(ROOT/'docs/production/full-completion/continuous-production/EXACT_REMAINING_CONTRACTS.json')}
entries=[];rejected=[];sources={};unique=[]
for actor,palms in contacts.items():
 source=SOURCE/(actor+'_candidate.png');original=cells(source);assert len(original)==8
 scale=min(456/max(c['bounds'][3]-c['bounds'][1] for c in original),456/max(c['bounds'][2]-c['bounds'][0] for c in original))
 for i,c in enumerate(original):
  selected=source;local_scale=scale
  if actor=='relic_beast' and i in [2,6]:
   rejected.append(dict(actor=actor,cell=i,source=str(source.relative_to(ROOT)),reason='Release hides second glove; no valid modular two-hand grip',disposition='Replaced by grouped two-visible-glove correction'))
   selected=SOURCE/'relic_release_correction.png';cs=cells(selected);c=cs[0 if i==2 else 1]
   local_scale=scale*(original[i]['bounds'][2]-original[i]['bounds'][0])/(c['bounds'][2]-c['bounds'][0])
  im=Image.open(selected);b=c['bounds'];assert b[0]>0 and b[1]>0 and b[2]<im.width and b[3]<im.height
  mask=Image.new('L',im.size);d=ImageDraw.Draw(mask)
  for y,a,z in c['runs']:d.line((a,y,z-1,y),fill=255)
  mask=mask.filter(ImageFilter.MaxFilter(5))
  pixels=im.copy();pixels.putalpha(ImageChops.multiply(im.getchannel('A'),mask));pixels=pixels.crop(b)
  size=[round(pixels.width*local_scale),round(pixels.height*local_scale)];offset=[(512-size[0])//2,496-size[1]];assert min(offset)>=16
  pixels=pixels.resize(size,Image.Resampling.LANCZOS)
  canvas=Image.new('RGBA',(512,512));canvas.alpha_composite(pixels,tuple(offset))
  face='right' if i<4 else 'left';state=['idle','windup','strike_or_cast','recovery'][i%4];phase=['IDLE','ANTICIPATE','ATTACK','RECOVER'][i%4]
  stem=f'{actor}_{state}_{face}';dest=f'art/production/phase4e/lootlings/{actor}/polearm_051/{stem}.png';grip=dest.replace('.png','_grip_front.png');(ROOT/dest).parent.mkdir(parents=True,exist_ok=True)
  canvas.save(ROOT/dest)
  mapped=[[offset[0]+(x-b[0])*size[0]/(b[2]-b[0]),offset[1]+(y-b[1])*size[1]/(b[3]-b[1])] for x,y in palms[i]]
  fingers=Image.new('L',(512,512));draw=ImageDraw.Draw(fingers)
  radius=9 if actor=='relic_beast' else 8
  for x,y in mapped:draw.ellipse((x-radius,y-radius,x+radius,y+radius),fill=255)
  front=canvas.copy();front.putalpha(ImageChops.multiply(canvas.getchannel('A'),fingers));front.save(ROOT/grip)
  unique.append(dict(actor=actor,state=state,facing=face,asset=dest,foreground=grip,source=selected.relative_to(ROOT).as_posix(),source_bounds=b,source_palms=palms[i],mapped_palms=mapped))
  for weapon in ['staff','spear']:
   slot=f'pose:{actor}:{state}:{face}:{weapon}'
   if slot not in queue:continue
   # Place the second contact on the existing narrow shaft, not its decorative head.
   hand_span=math.dist(mapped[0],mapped[1])*192/512
   base_size=[80,142] if weapon=='staff' else [104,162]
   actor_scale=.76 if actor=='glimmerfin' else .82
   primary=[.32,.76] if weapon=='staff' else [.37,.76]
   delta=min(.51,max(.04,hand_span/(base_size[1]*actor_scale)))
   second=[primary[0],primary[1]-delta]
   row=dict(actor=actor,state=state,phase=phase,weapon_types=[weapon],facing=face+'_only',asset_path='res://'+dest,foreground_layer='res://'+grip,metadata_path=dest.replace('.png','_'+weapon+'.json'),body_rect=[-96,-128,192,192],primary_anchor=[v/512 for v in mapped[0]],secondary_anchor=[v/512 for v in mapped[1]],core_anchor=[.5,.55],feet_baseline=58,baseline_y=496,canvas=[512,512],supports_two_hand=True,draw_depth='back',wardrobe_requires={},baked_weapon='',frame_count=1,frame_index=0,fps=0,contract_slot_id=slot,source=selected.relative_to(ROOT).as_posix(),source_sha256=sha(selected),source_bounds=b,source_primary=palms[i][0],source_secondary=palms[i][1],identity_authority=queue[slot]['canonical_authority_files'],mirroring_allowed=False,native_validated=False,production_status='awaiting_native_visual_review',weapon_overrides={weapon:dict(size=base_size,grip=primary,secondary_grip=second,socket=[.8,.2] if weapon=='staff' else [.8,.08],angle=-.12 if weapon=='staff' else .35,held_path='res://art/sprites/weapons/'+weapon+'_held.png')},grip_calibration='Two source palms measured; second contact placed on existing shaft. No shifted body palms or painted limbs.')
   entries.append(row);write(ROOT/row['metadata_path'],row)
write(MAN,dict(entries=entries,production_quality_accepted=False));write(SOURCE/'EXTRACTION_RECEIPT.json',dict(unique_bodies=unique,rejected=rejected,complete_fluid_animation=False));print('Staged',len(unique),'bodies and grip masks;',len(entries),'exact contracts; no closures yet')
