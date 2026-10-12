extends SceneTree
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 var progress=preload("res://expedition_progress.gd").new()
 if OS.get_environment("LOOTLINGS_ARCHIVE_RESTART_CHILD")=="1":
  progress.load_progress()
  assert(progress.data.archive_read.get("event:secret_bell",false))
  assert(progress.data.counts.get("clear:act_i",0)==3 and progress.data.claims.get("act_i",0)==2)
  assert(not progress.data.seen.has("secret:never_found"))
  print("ARCHIVE071 FRESH PROCESS PASS earned/read/progression retained; unearned absent");quit();return
 progress.data.seen["event:secret_bell"]=true;progress.data.counts["clear:act_i"]=3;progress.data.claims["act_i"]=2
 assert(progress.read_discovery("event:secret_bell")==OK)
 assert(progress.read_discovery("secret:never_found")==ERR_INVALID_PARAMETER)
 var output:Array=[];var args:PackedStringArray=PackedStringArray(["--headless"]);args.append_array(OS.get_cmdline_args())
 OS.set_environment("LOOTLINGS_ARCHIVE_RESTART_CHILD","1")
 var code:int=OS.execute(OS.get_executable_path(),args,output,true)
 OS.set_environment("LOOTLINGS_ARCHIVE_RESTART_CHILD","")
 assert(code==0 and str(output).contains("ARCHIVE071 FRESH PROCESS PASS"),str(output))
 print("ARCHIVE071 PROCESS RESTART PASS: actual second exported engine process, earned/read and unrelated progression retained; no reward or discovery grants.");quit()
