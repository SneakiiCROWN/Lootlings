"""Terminate only owned isolated Godot test processes at durable reward boundaries."""
from pathlib import Path
import json, os, subprocess, time, uuid
ROOT=Path(__file__).resolve().parents[1]
GODOT=Path.home()/'Desktop'/'Godot_v4.7.2-stable_win64.exe'
folder=ROOT/'.godot_test_data'/'qa_logs'/('phase4e-reward-restart-'+uuid.uuid4().hex[:10])
folder.mkdir(parents=True)
results=[]
for kind in ['material','mastery','blueprint','item']:
    for cut in ['reserve','recipient']:
        appdata=ROOT/'.godot_test_data'/'isolated'/folder.name/(kind+'-'+cut)
        appdata.mkdir(parents=True)
        env=os.environ.copy(); env.update(APPDATA=str(appdata), XDG_DATA_HOME=str(appdata), LOOTLINGS_QA='1', LOOTLINGS_RESTART_KIND=kind)
        command=[str(GODOT),'--headless','--path',str(ROOT),'-s','res://tests/phase4e_reward_restart_qa.gd']
        env['LOOTLINGS_RESTART_STAGE']=cut
        log=folder/(kind+'-'+cut+'-cut.log')
        with log.open('wb') as stream:
            child=subprocess.Popen(command,env=env,stdout=stream,stderr=subprocess.STDOUT)
            deadline=time.monotonic()+30
            try:
                while not list(appdata.rglob('restart_cut_ready.txt')):
                    if child.poll() is not None: raise RuntimeError('Cut process exited before marker: '+str(log))
                    if time.monotonic()>deadline: raise RuntimeError('Cut timeout: '+str(log))
                    time.sleep(.05)
                child.terminate(); child.wait(timeout=10)
            finally:
                if child.poll() is None: child.kill(); child.wait(timeout=10)
        assert 'SCRIPT ERROR' not in log.read_text(encoding='utf-8',errors='replace'),log
        env['LOOTLINGS_RESTART_STAGE']='verify'
        for launch in [1,2]:
            check=folder/(kind+'-'+cut+f'-verify{launch}.log')
            with check.open('wb') as stream:
                run=subprocess.run(command,env=env,stdout=stream,stderr=subprocess.STDOUT,timeout=45)
            output=check.read_text(encoding='utf-8',errors='replace')
            assert run.returncode==0 and 'RESTART VERIFIED '+kind in output and 'SCRIPT ERROR' not in output and 'ERROR:' not in output,check
        results.append(dict(kind=kind,cut=cut,fresh_verifications=2,pass_status=True))
        print(kind,cut,'PASS',flush=True)
(folder/'results.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
print('Process-boundary QA:',folder)
