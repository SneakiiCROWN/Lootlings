"""Kill only the disposable award writer; restart against source or the exact PCK."""
from pathlib import Path
import argparse, json, os, subprocess, time, uuid, hashlib
ROOT=Path(__file__).resolve().parents[1]
ENGINE=Path.home()/'Desktop/Godot_v4.7.2-stable_win64_console.exe'
p=argparse.ArgumentParser();p.add_argument('--pack');a=p.parse_args()
base=ROOT/'.godot_test_data'/('award-process-067-'+uuid.uuid4().hex[:10]);base.mkdir(parents=True)
fixture=ROOT/'tests/achievement_process_cut_067.gd'
if a.pack:
    # External guarded fixture only. All production scripts load from the exported PCK.
    safety=base/'test_safety.gd'
    safety.write_text((ROOT/'tests/test_safety.gd').read_text(encoding='utf-8').replace('res://.godot_test_data/isolated/',(base/'isolated').as_posix()+'/'),encoding='utf-8')
    external=base/fixture.name
    external.write_text(fixture.read_text(encoding='utf-8').replace('res://tests/test_safety.gd',safety.as_posix()),encoding='utf-8')
    prefix=[str(ENGINE),'--headless','--main-pack',str((ROOT/a.pack).resolve())];script=str(external)
else:
    prefix=[str(ENGINE),'--headless','--path',str(ROOT)];script='res://tests/'+fixture.name
rows=[]
for cut in [1,2]:
    ready=base/f'ready-{cut}';env=os.environ.copy()
    saves=(base/'isolated'/str(cut)) if a.pack else (ROOT/'.godot_test_data/isolated'/base.name/str(cut))
    env.update(LOOTLINGS_QA='1',LOOTLINGS_CUT=str(cut),LOOTLINGS_READY=str(ready),LOOTLINGS_RESTART_PHASE='write',APPDATA=str(saves),XDG_DATA_HOME=str(saves))
    Path(env['APPDATA']).mkdir(parents=True)
    with (base/f'write-{cut}.log').open('wb') as log:
        writer=subprocess.Popen(prefix+['-s',script],env=env,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
        try:
            deadline=time.monotonic()+35
            while not ready.exists() and writer.poll() is None and time.monotonic()<deadline:time.sleep(.1)
            assert ready.exists(),(cut,'writer never reached persisted boundary')
            writer.kill();writer.wait(timeout=10)
        finally:
            if writer.poll() is None:writer.kill();writer.wait(timeout=10)
    env['LOOTLINGS_RESTART_PHASE']='read'
    result=subprocess.run(prefix+['-s',script],env=env,cwd=ROOT,capture_output=True,timeout=40)
    output=result.stdout.decode('utf-8','replace')+result.stderr.decode('utf-8','replace')
    (base/f'read-{cut}.log').write_text(output,encoding='utf-8')
    assert result.returncode==0 and 'SCRIPT ERROR' not in output and 'ERROR:' not in output and 'ACTUAL PROCESS CUT PASS' in output,output
    rows.append(dict(boundary=cut,actual_writer_terminated=True,recovery_once=True,counter=1,repeat_timestamp_preserved=True,isolated=True,production_code_from_pack=bool(a.pack)))
record=dict(results=rows,pack=a.pack,pack_sha256=hashlib.sha256((ROOT/a.pack).read_bytes()).hexdigest() if a.pack else None,limits='Process termination after persisted boundaries; not power-loss or permanently unwritable storage acceptance.')
(base/'RESULTS.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
print(base/'RESULTS.json')
