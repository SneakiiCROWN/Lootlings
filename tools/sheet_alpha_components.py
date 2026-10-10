from PIL import Image
import numpy as np,json
from pathlib import Path
root=Path(r'C:/Users/Snkii/.codex/generated_images/01a119ec-aee5-7460-8419-3c1df0c7363f')
def components(path):
 alpha=np.array(Image.open(path))[:,:,3]>8
 runs=[];parent=[];previous=[]
 def find(i):
  while parent[i]!=i:parent[i]=parent[parent[i]];i=parent[i]
  return i
 for y,row in enumerate(alpha):
  edges=np.flatnonzero(np.diff(np.r_[False,row,False]));current=[]
  for a,b in zip(edges[::2],edges[1::2]):
   i=len(runs);parent.append(i);runs.append([y,int(a),int(b)]);current.append(i)
   for j in previous:
    if runs[j][1]>b:break
    if runs[j][2]>=a:parent[find(i)]=find(j)
  previous=current
 groups={}
 for i,row in enumerate(runs):groups.setdefault(find(i),[]).append(row)
 large=[]
 for rows in groups.values():
  area=sum(b-a for _,a,b in rows)
  if area<10000:continue
  bounds=[min(a for _,a,_ in rows),min(y for y,_,_ in rows),max(b for _,_,b in rows),max(y for y,_,_ in rows)+1]
  large.append(dict(area=area,bounds=bounds,runs=rows))
 return sorted(large,key=lambda r:((r['bounds'][1]+r['bounds'][3])//512,r['bounds'][0]))
