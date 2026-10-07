"""Load compiled scripts from the delivery APK to verify the shipped canon routes."""
from pathlib import Path
from zipfile import ZipFile
import argparse,hashlib,json,os,subprocess
ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser();parser.add_argument('--report-dir',default='docs/production/phase4e/canon-world/qa');args=parser.parse_args()
report=json.loads((ROOT/'builds/android/build-report.json').read_text(encoding='utf-8'))
apk=ROOT/report['apk'];assert hashlib.sha256(apk.read_bytes()).hexdigest()==report['sha256']
work=ROOT/'.godot_test_data/apk-canon-proof';work.mkdir(parents=True,exist_ok=True)
hashes={}
with ZipFile(apk) as archive:
    for name in ['vignette_catalog','field_notes_catalog','resident_art_catalog']:
        data=archive.read('assets/'+name+'.gdc');(work/(name+'.gdc')).write_bytes(data)
        hashes[name]=hashlib.sha256(data).hexdigest()
fixture='''extends SceneTree
func _initialize():
 if not preload("res://tests/test_safety.gd").require_isolated(self): return
 var catalog=load("res://.godot_test_data/apk-canon-proof/vignette_catalog.gdc")
 assert(catalog.entry("boss/drowned_engine").lines.size()==3)
 assert(catalog.boss_entries().size()==11)
 var notes=load("res://.godot_test_data/apk-canon-proof/field_notes_catalog.gdc")
 var residents=load("res://.godot_test_data/apk-canon-proof/resident_art_catalog.gdc")
 for id in ["patch","ilex"]:
  assert(catalog.entry("resident/"+id).actor.ends_with(id+"_canonical_station_panel.png"))
  var pages=notes.pages({},null,null).filter(func(page):return page.id=="resident/"+id)
  assert(pages.size()==1 and pages[0].art.ends_with(id+"_canonical_station_panel.png"))
  assert(residents.portrait_path(id)==pages[0].art)
 assert(notes.CATEGORIES==["ALL","CAST","TRAILS","BOSSES","GEAR"])
 var faces=0
 for page in notes.pages({},null,null):
  if str(page.id).begins_with("wanderer/"):
   assert(page.texture is AtlasTexture);faces+=1
 assert(faces==5)
 assert(notes.pages({},null,null).filter(func(page): return str(page.id).begins_with("route/")).is_empty())
 assert(notes.pages({"memories":["region/act_i"]},null,null).filter(func(page): return str(page.id).begins_with("route/")).size()==3)
 print("APK COMPILED CODE PASS: scoped Patch/Ilex memory and Field Notes identities, compiled resident portrait resolver, 11 boss accounts, 3 bounded Engine captions, 5 Field Notes categories, 5 accepted Wanderer portrait atlases, 3 discovery-gated Act I routes");quit()
'''
(work/'verify.gd').write_text(fixture,encoding='utf-8')
env=os.environ.copy();env.update(APPDATA=str(ROOT/'.godot_test_data/isolated/apk-canon-proof'),XDG_DATA_HOME=str(ROOT/'.godot_test_data/isolated/apk-canon-proof'),LOOTLINGS_QA='1')
result=subprocess.run([env.get('GODOT',r'C:\Users\Snkii\Desktop\Godot_v4.7.2-stable_win64_console.exe'),'--headless','--path',str(ROOT),'--script','res://.godot_test_data/apk-canon-proof/verify.gd'],cwd=ROOT,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=30)
output=result.stdout+result.stderr
assert result.returncode==0 and 'ERROR:' not in output,output
target=ROOT/args.report_dir;target.mkdir(parents=True,exist_ok=True)
(target/'apk-compiled-code.log').write_text(output,encoding='utf-8')
(target/'apk-compiled-code.json').write_text(json.dumps(dict(apk_sha256=report['sha256'],compiled_scripts=hashes,verified=True,device_validated=False),indent=2)+'\n',encoding='utf-8')
print(output)
