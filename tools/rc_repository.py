"""Inventory tracked project files and literal references; never delete inferred orphans."""
from pathlib import Path
import subprocess, json, re, hashlib, collections
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'docs/production/predevice'; OUT.mkdir(parents=True,exist_ok=True)
paths = subprocess.check_output(['git','ls-files','-z'],cwd=ROOT).decode().split('\0')
paths = [p for p in paths if p and (ROOT/p).is_file()]
new = subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z'],cwd=ROOT).decode().split('\0')
paths = sorted(set(paths+[p for p in new if p and (ROOT/p).is_file() and not p.startswith('docs/production/predevice/')]))
inventory = []
references = []; missing = []
runtime = [p for p in paths if '/' not in p and Path(p).suffix in ['.gd','.tscn','.godot']]
source = '\n'.join((ROOT/p).read_text(encoding='utf-8-sig') for p in paths if Path(p).suffix in ['.gd','.tscn','.tres'])
methods = []
for path in paths:
    file = ROOT/path
    inventory.append({'path':path,'bytes':file.stat().st_size,'sha256':hashlib.sha256(file.read_bytes()).hexdigest()})
    if Path(path).suffix not in ['.gd','.tscn','.tres','.godot','.cfg']: continue
    text = file.read_text(encoding='utf-8-sig')
    for match in re.finditer(r'(?P<quote>[\"\x27])(?P<uri>res://[^\"\x27\n]+)(?P=quote)',text):
        uri = match['uri']; relative = uri.removeprefix('res://')
        if '%' in uri or '{' in uri or not Path(relative).suffix: continue
        row = {'source':path,'line':text.count('\n',0,match.start())+1,'resource':uri,'exists':(ROOT/relative).exists()}
        references.append(row)
        if not row['exists']: missing.append(row)
    if path in runtime:
        for name in re.findall(r'^func (\w+)\(',text,re.M):
            if not name.startswith('_') and len(re.findall(r'\b'+re.escape(name)+r'\b',source)) == 1:
                methods.append({'script':path,'method':name,'status':'Candidate only; public/dynamic/authoring APIs need manual proof before removal'})
report = {'tracked_and_current_files':len(paths),'extensions':dict(collections.Counter(Path(p).suffix for p in paths)),'runtime_sources':runtime,'files':inventory,'literal_references':references,'missing_literal_references':missing,'single_reference_methods':methods,'policy':'No assets or source/provenance are deleted from static reachability inference; constructed paths, catalog families, scene signals and engine callbacks are separately validated by native/regression/package checks.'}
(OUT/'repository.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('Inventory',len(paths),'runtime sources',len(runtime),'literal references',len(references),'missing',len(missing),'single-reference candidates',len(methods))
for row in missing: print(row)
