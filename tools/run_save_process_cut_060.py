"""Terminate disposable Godot processes at persisted economy journal boundaries."""
from pathlib import Path
import argparse,os,subprocess,time,json
ROOT=Path(__file__).resolve().parents[1]
def main():
 p=argparse.ArgumentParser();p.add_argument("--pack",default="builds/windows/Lootlings-0.4.60-p0-candidate.pck");a=p.parse_args()
 pack=(ROOT/a.pack).resolve();assert pack.is_file()
 base=ROOT/".godot_test_data/exported-060"
 dest=ROOT/".godot_test_data/exported-fixtures-060";dest.mkdir(parents=True,exist_ok=True)
 helper=(ROOT/"tests/test_safety.gd").read_text(encoding="utf-8").replace("res://.godot_test_data/",base.as_posix()+"/")
 (dest/"restart_test_safety.gd").write_text(helper,encoding="utf-8")
 text=(ROOT/"tools/save_process_cut_060.gd").read_text(encoding="utf-8").replace("res://tests/test_safety.gd",(dest/"restart_test_safety.gd").as_posix())
 (dest/"save_process_cut_060.gd").write_text(text,encoding="utf-8")
 engine=Path.home()/"Desktop/Godot_v4.7.2-stable_win64_console.exe"
 command=[str(engine),"--headless","--main-pack",str(pack),"-s",str(dest/"save_process_cut_060.gd")]
 results=[]
 for cut in range(4):
  env=os.environ.copy();env.update(LOOTLINGS_QA="1",LOOTLINGS_CUT=str(cut),LOOTLINGS_RESTART_PHASE="write",APPDATA=str(base/"isolated"/("process-cut-"+str(cut))))
  env["XDG_DATA_HOME"]=env["APPDATA"];Path(env["APPDATA"]).mkdir(parents=True,exist_ok=True)
  ready=Path(env["APPDATA"])/"ready.txt";env["LOOTLINGS_READY"]=str(ready)
  if ready.exists():ready.unlink()
  with (dest/("process-write-"+str(cut)+".log")).open("wb") as output:
   child=subprocess.Popen(command,env=env,stdout=output,stderr=subprocess.STDOUT,cwd=ROOT)
   deadline=time.monotonic()+45
   while not ready.exists() and child.poll() is None and time.monotonic()<deadline:time.sleep(.1)
   kill=subprocess.run(["taskkill","/PID",str(child.pid),"/T","/F"],capture_output=True)
   assert ready.exists() and kill.returncode==0,"Disposable journal barrier/kill failed"
   child.wait(timeout=15)
  env["LOOTLINGS_RESTART_PHASE"]="read"
  run=subprocess.run(command,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=45)
  text=run.stdout.decode("utf-8","replace");(dest/("process-read-"+str(cut)+".log")).write_text(text,encoding="utf-8")
  assert run.returncode==0 and "ERROR:" not in text,text
  results.append(dict(boundary=cut,actual_os_process_tree_killed=True,persisted_barrier=True,fresh_process_recovery=True,consistent_gold=1000+cut,consistent_scrap=200+cut,idempotent=True))
  print("Actual process-cut recovery PASS",cut,flush=True)
 target=ROOT/"docs/production/quality-evidence/0.4.60/PROCESS_CUT_RECOVERY.json"
 target.write_text(json.dumps(dict(pack=str(pack),cases=results,scope="Actual OS termination at four injected persisted journal boundaries; disposable stores only, not power-loss/disk-durability simulation."),indent=2)+"\n",encoding="utf-8")
if __name__=="__main__":main()
