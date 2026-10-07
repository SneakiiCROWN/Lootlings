"""Kill isolated fixture processes at real reward persistence boundaries; never owner saves."""
from pathlib import Path
import os,subprocess,time,json,uuid
R=Path(__file__).resolve().parents[1]
G=Path.home()/'Desktop/Godot_v4.7.2-stable_win64_console.exe'
out=R/'.godot_test_data/qa_logs'/('completion-process-death-'+uuid.uuid4().hex[:10]);out.mkdir(parents=True)
results=[]
for kind in ['material','item','mastery','blueprint','economy']:
 for stage in (['baseline','before','mid','after','last'] if kind=='economy' else ['before','after']):
  name=kind+'-'+stage;env=os.environ.copy();env['APPDATA']=str(R/'.godot_test_data/isolated'/out.name/name);env['XDG_DATA_HOME']=env['APPDATA'];env['LOOTLINGS_QA']='1';Path(env['APPDATA']).mkdir(parents=True)
  command=[str(G),'--headless','--path',str(R),'-s','res://tests/completion_process_death.gd','--','--'+kind]+(['--baseline'] if stage=='baseline' else [])
  log=out/(name+'-writer.log')
  with log.open('wb') as stream:
   process=subprocess.Popen(command+['--writer']+(['--after'] if stage=='after' else ['--mid'] if stage=='mid' else ['--last'] if stage=='last' else []),env=env,stdout=stream,stderr=subprocess.STDOUT)
   try:
    deadline=time.monotonic()+30
    while 'PROCESS_DEATH_READY' not in log.read_text(encoding='utf-8',errors='replace'):
     if process.poll() is not None:raise RuntimeError(log.read_text(encoding='utf-8',errors='replace'))
     if time.monotonic()>deadline:raise RuntimeError('Fixture failed to reach kill boundary: '+name)
     time.sleep(.05)
    process.kill();process.wait(timeout=10)
   finally:
    if process.poll() is None:process.kill();process.wait(timeout=10)
  recovered=subprocess.run(command,env=env,capture_output=True,timeout=30);text=recovered.stdout.decode('utf-8',errors='replace')+recovered.stderr.decode('utf-8',errors='replace');(out/(name+'-restart.log')).write_text(text,encoding='utf-8')
  assert recovered.returncode==0 and 'PROCESS_DEATH_RECOVERY_PASS' in text and 'ERROR:' not in text,(name,text)
  again=subprocess.run(command,env=env,capture_output=True,timeout=30);again_text=again.stdout.decode('utf-8',errors='replace')+again.stderr.decode('utf-8',errors='replace');(out/(name+'-second-restart.log')).write_text(again_text,encoding='utf-8');assert again.returncode==0 and 'PROCESS_DEATH_RECOVERY_PASS' in again_text and 'ERROR:' not in again_text,(name,again_text)
  results.append({'second_cold_restart':'PASS','kind':kind,'kill_boundary':stage+'_destination','process_terminated':True,'restart_recovery':'PASS','duplicate_delivery':'BASELINE UNSAFE OFFER REPLAY' if stage=='baseline' else 'NONE','wallet_and_free_spins':'PRESERVED'})
  print(name,'PASS',flush=True)
(out/'results.json').write_text(json.dumps(results,indent=2)+'\n');print(out)
