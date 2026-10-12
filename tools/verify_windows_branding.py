"""Verify the actual exported PE launcher icons against approved Lootlings icon art."""
import argparse,struct,io,json,re
from pathlib import Path
from PIL import Image,ImageChops,ImageStat
ROOT=Path(__file__).resolve().parents[1]
def verify(path):
 data=Path(path).read_bytes();u16=lambda o:struct.unpack_from('<H',data,o)[0];u32=lambda o:struct.unpack_from('<I',data,o)[0]
 pe=u32(0x3c);assert data[pe:pe+4]==b'PE\0\0';optional=pe+24;directory=optional+(112 if u16(optional)==0x20b else 96);rsrc=u32(directory+16);sections=[]
 for i in range(u16(pe+6)):
  start=optional+u16(pe+20)+i*40;sections.append((u32(start+12),max(u32(start+8),u32(start+16)),u32(start+20)))
 def offset(rva):
  for address,size,raw in sections:
   if address<=rva<address+size:return raw+rva-address
  raise ValueError('Resource address outside PE sections')
 base=offset(rsrc)
 def walk(relative,depth=0):
  assert depth<5;start=base+relative;result={}
  for i in range(u16(start+12)+u16(start+14)):
   key=u32(start+16+i*8);value=u32(start+20+i*8)
   if value&0x80000000:result[key]=walk(value&0x7fffffff,depth+1)
   else:
    descriptor=base+value;address=offset(u32(descriptor));result[key]=data[address:address+u32(descriptor+4)]
  return result
 tree=walk(0)
 def leaf(value):
  while isinstance(value,dict):value=next(iter(value.values()))
  return value
 groups=tree[14];group_id=next(k for k in groups if k==1) if 1 in groups else next(iter(groups));group=leaf(groups[group_id]);count=struct.unpack_from('<H',group,4)[0];payload=[];entries=[];cursor=6+count*16
 for i in range(count):
  width,height,colors,reserved,planes,bpp,size,id=struct.unpack_from('<BBBBHHIH',group,6+i*14);raw=leaf(tree[3][id]);assert len(raw)==size;entries.append(struct.pack('<BBBBHHII',width,height,colors,reserved,planes,bpp,size,cursor));payload.append(raw);cursor+=size
 ico=struct.pack('<HHH',0,1,count)+b''.join(entries)+b''.join(payload);out=ROOT/'.godot_test_data/windows';out.mkdir(exist_ok=True);(out/'exported_icon.ico').write_bytes(ico);actual=Image.open(io.BytesIO(ico));sizes=sorted(actual.ico.sizes());assert set(sizes)=={(s,s) for s in [16,32,48,64,128,256]};icon=re.search(r'config/icon="res://([^"]+)"',(ROOT/'project.godot').read_text())[1];source=Image.open(ROOT/icon).convert('RGBA');report=[]
 for size in sizes:
  a=actual.ico.getimage(size).convert('RGBA');e=source.resize(size,Image.Resampling.LANCZOS);bg=Image.new('RGBA',size,'#0d182d');error=sum(ImageStat.Stat(ImageChops.difference(Image.alpha_composite(bg,a).convert('RGB'),Image.alpha_composite(bg,e).convert('RGB'))).mean)/3;assert error<8,(size,error);report.append({'size':list(size),'mean_rgb_error':round(error,3)})
 result={'exe':str(Path(path).resolve()),'approved_source':icon,'actual_pe_group':group_id,'checks':report,'passed':True};(out/'icon-verification.json').write_text(json.dumps(result,indent=2),encoding='utf-8');return result
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('exe');print(json.dumps(verify(p.parse_args().exe),indent=2))
