"""Read-only per-cell technical QA for existing native sheet extraction jobs.
Human canon/anatomy/animation/grip review remains mandatory; this never accepts art.
"""
import argparse,json,hashlib
from pathlib import Path
from PIL import Image,ImageChops,ImageFilter
ROOT=Path(__file__).resolve().parents[1]
def local(path):
 p=(ROOT/path.removeprefix('res://')).resolve()
 assert p.is_relative_to(ROOT),'Asset outside live project'
 return p
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('jobs');p.add_argument('--output',required=True);a=p.parse_args()
 jobs=json.loads(local(a.jobs).read_text(encoding='utf-8-sig'))['exports'];results=[];owned={};sources={}
 for j in jobs:
  defects=[];source=local(j['source']);im=sources.setdefault(str(source),Image.open(source).convert('RGBA'));w,h=im.size
  x0,y0,x1,y1=j['bounds']
  if not (0<x0<x1<w and 0<y0<y1<h):defects.append('source silhouette touches sheet edge or bounds invalid')
  intervals=owned.setdefault(str(source),{})
  for y,start,end in j['runs']:
   if not (y0<=y<y1 and x0<=start<end<=x1):defects.append('owned alpha run outside cell bounds');break
   if any(start<other_end and other_start<end for other_start,other_end in intervals.get(y,[])):defects.append('cell shares transparent-silhouette ownership with another job');break
   intervals.setdefault(y,[]).append((start,end))
  runtime=local(j['asset'])
  if not runtime.exists():defects.append('runtime body missing')
  else:
   body=Image.open(runtime);bbox=body.getchannel('A').getbbox() if body.mode=='RGBA' else None
   if body.mode!='RGBA' or list(body.size)!=j['canvas']:defects.append('invalid runtime canvas or alpha')
   elif not bbox or min(bbox[:2])<10 or bbox[2]>body.width-10 or bbox[3]>body.height-10:defects.append('runtime clipping or empty silhouette')
   if j.get('foreground'):
    mask_path=local(j['foreground'])
    if not mask_path.exists():defects.append('foreground grip layer missing')
    else:
     mask=Image.open(mask_path).convert('RGBA')
     if mask.size!=body.size:defects.append('foreground layer not co-registered')
     else:
      # Grip interior must preserve body pixels; independently resampled feather edges differ.
      active=mask.getchannel('A').point(lambda x:255 if x>=250 else 0).filter(ImageFilter.MinFilter(7))
      diff=ImageChops.difference(body.convert('RGBA'),mask).convert('RGB')
      if not active.getbbox():defects.append('foreground mask has no visible grip interior')
      elif max(v[1] for v in ImageChops.multiply(diff,Image.merge('RGB',[active]*3)).getextrema())>2:defects.append('foreground mask changes body interior pixels')
  results.append(dict(asset=j['asset'],source=j['source'],source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),technical_pass=not defects,defects=defects,canon_anatomy_pose_contact_acceptance='Requires exact canon comparison and native gameplay visual evidence; not inferred'))
 out=dict(cells=results,technical_passes=sum(r['technical_pass'] for r in results),technical_failures=sum(not r['technical_pass'] for r in results),installs_performed=0,production_acceptance_granted=False)
 dest=local(a.output);dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8')
 print('Independent cell checks:',out['technical_passes'],'pass;',out['technical_failures'],'quarantine; no automatic art approval')
 for r in results:
  if r['defects']:print(r['asset'],r['defects'])
 return 1 if out['technical_failures'] else 0
if __name__=='__main__':raise SystemExit(main())
