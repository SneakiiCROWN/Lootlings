"""Manual public build: stable Android identity, no ephemeral signing key."""
from pathlib import Path
import os,re,subprocess,shutil,hashlib,json,zipfile,argparse
P=Path(__file__).resolve().parents[1]
def run(args,env):
 r=subprocess.run([str(x) for x in args],cwd=P,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
 print(r.stdout.decode('utf-8','replace'),end='',flush=True)
 if r.returncode:raise SystemExit(r.returncode)
 text=r.stdout.decode('utf-8','replace')
 if 'SCRIPT ERROR' in text or 'Parse Error' in text:raise SystemExit('Script errors detected')
 return text
p=argparse.ArgumentParser();p.add_argument('--engine',required=True);p.add_argument('--code',type=int,required=True);p.add_argument('--output',required=True);a=p.parse_args()
O=Path(a.output).resolve();O.mkdir(parents=True,exist_ok=True);env=os.environ.copy();sdk=Path(env['ANDROID_HOME']);java=Path(env['JAVA_HOME']);key=Path(env['ANDROID_SIGNING_KEY'])
assert key.is_file(),'A preserved signing key is required; never generate a replacement silently'
env['GODOT_ANDROID_KEYSTORE_DEBUG_PATH']=str(key);env['GODOT_ANDROID_KEYSTORE_DEBUG_USER']='androiddebugkey';env['GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD']='android'
# Configure this disposable build checkout only.
cfg=P/'export_presets.cfg';text=cfg.read_text(encoding='utf-8-sig');old=max(int(x) for x in re.findall(r'version/code=(\d+)',text));assert a.code>old,(a.code,old)
text=re.sub(r'version/code=\d+','version/code='+str(a.code),text)
text=re.sub(r'custom_template/(?:debug|release)="[^"]*"',lambda m:m.group(0).split('=')[0]+'=""',text)
if True:
 # Branded Android template reuses the existing project's tested splash patcher.
 import sys
 sys.path.insert(0,str(P/'tools'))
 from android_splash_theme import branded_template
 base=Path.home()/'.local/share/godot/export_templates/4.7.2.stable/android_debug.apk'
 branded=P/'.public-build/android_debug_branded.apk';branded.parent.mkdir(exist_ok=True)
 branded_template(base,branded)
 # Android debug templates only; Windows uses its standard release template.
 sections=text.split('[preset.')
 for i,part in enumerate(sections):
  if '.options]' in part and not part.startswith('0.options]'):sections[i]=part.replace('custom_template/debug=""','custom_template/debug="'+branded.as_posix()+'"')
 text='[preset.'.join(sections)
cfg.write_text(text,encoding='utf-8')
settings=Path.home()/'.config/godot/editor_settings-4.7.tres';settings.parent.mkdir(parents=True,exist_ok=True)
settings.write_text('[gd_resource type="EditorSettings" format=3]\n\n[resource]\nexport/android/java_sdk_path = "'+java.as_posix()+'"\nexport/android/android_sdk_path = "'+sdk.as_posix()+'"\n')
env['LOOTLINGS_QA']='1'  # CI runs in a fresh disposable runner
run([a.engine,'--headless','--path',P,'--editor','--import','--quit'],env)
run([a.engine,'--headless','--path',P]+['-s','tests/save_boundary_059_qa.gd'],env)
# Windows export is a cross-build; native launch testing remains a separate gate.
run([a.engine,'--headless','--path',P,'--export-release','Windows Desktop',O/'Lootlings.exe'],env)
run([a.engine,'--headless','--path',P,'--export-debug','Android',O/'Lootlings-Android.apk'],env)
bt=sdk/'build-tools/36.0.0'
signature=run([bt/'apksigner','verify','--print-certs',O/'Lootlings-Android.apk'],env)
assert 'fe1e5f882df56d1615c9941cf6c51ff18712beadeb48aa732b231176bf3453f3' in signature.lower(), 'Signing certificate differs from the preserved identity'
badging=run([bt/'aapt','dump','badging',O/'Lootlings-Android.apk'],env)
assert "package: name='com.sneakiicrown.lootlings'" in badging
assert "versionCode='"+str(a.code)+"'" in badging
run([bt/'zipalign','-c','-P','16','4',O/'Lootlings-Android.apk'],env)
# Package only runtime files, licences and reader instructions.
with zipfile.ZipFile(O/'Lootlings-Windows.zip','w',zipfile.ZIP_DEFLATED,6) as z:
 for path in [O/'Lootlings.exe',O/'Lootlings.pck']:
  if path.exists():z.write(path,path.name)
 for name in ['README.md','LICENSE.txt','THIRD_PARTY_CREDITS.md','AUDIO_LICENSES.md','ASSET_PROVENANCE.md']:
  if (P/name).exists():z.write(P/name,name)
 for path in (P/'ThirdPartyNotices').rglob('*'):
  if path.is_file():z.write(path,'ThirdPartyNotices/'+path.relative_to(P/'ThirdPartyNotices').as_posix())
assets=[O/'Lootlings-Windows.zip',O/'Lootlings-Android.apk']
(O/'SHA256SUMS.txt').write_text(''.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+f.name+'\n' for f in assets))
