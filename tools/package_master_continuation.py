"""Full-size native JPEG evidence for the master continuation only."""
from pathlib import Path
from PIL import Image
import json,hashlib,shutil
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'docs/production/master-continuation'
def main():
    OUT.mkdir(parents=True,exist_ok=True);entries=[]
    for source in sorted((ROOT/'.godot_test_data/phase4e/master-continuation').rglob('*.png')):
        rel=Path('native')/source.parent.name/(source.stem+'.jpg');target=OUT/rel;target.parent.mkdir(parents=True,exist_ok=True)
        with Image.open(source) as im:im.convert('RGB').save(target,quality=94,subsampling=0);canvas=list(im.size)
        entries.append(dict(path=rel.as_posix(),canvas=canvas,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),sha256=hashlib.sha256(target.read_bytes()).hexdigest()))
    (OUT/'evidence-manifest.json').write_text(json.dumps({'native_count':len(entries),'entries':entries},indent=2)+'\n',encoding='utf-8')
    lines=['# Master integration continuation — native gallery','','Original native phone/tablet captures, full-size JPEG94. All v25 canonical body evidence remains in the preserved extraction gallery.','']
    for row in entries:lines+=['## '+row['path'],'','!['+row['path']+']('+row['path']+')','']
    (OUT/'GALLERY.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    dest=OUT/'qa';dest.mkdir(exist_ok=True)
    for label in ['phase4e-master-continuation-ac03a68e8c','phase4e-master-item-accepted-784e517672','phase4e-master-native-final-956116e090']:
        for source in (ROOT/'.godot_test_data/qa_logs'/label).glob('*'):
            if source.suffix in ['.log','.json']:shutil.copy2(source,dest/(label+'-'+source.name))
    print('Packaged '+str(len(entries))+' native full-size images; initial failing item fixture retained with final passing replacement evidence')
if __name__=='__main__':main()
