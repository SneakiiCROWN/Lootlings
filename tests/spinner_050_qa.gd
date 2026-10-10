extends SceneTree
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var machine=preload("res://relic_machine.gd").new();root.add_child(machine);await process_frame;machine.set_process(false)
 var signals:Dictionary={"locked":0,"completed":0,"ticks":0}
 machine.locked.connect(func():signals.locked+=1)
 machine.completed.connect(func():signals.completed+=1)
 machine.cue.connect(func(event):
  if event=="spinner_tick":signals.ticks+=1)
 for tier in preload("res://relic_spin_catalog.gd").TIERS:
  for phase in ["rolling","anticipation"]:
   machine.wind_up("material",tier);machine.set_process(false)
   if phase=="anticipation":machine._process(machine.reel_seconds)
   var before:int=signals.locked
   assert(machine.skip() and signals.locked==before+1)
   assert(not machine.skip());machine.lock_result();assert(signals.locked==before+1)
   machine._process(3);assert(machine.stage=="settled")
 machine.wind_up("material","COMMON");machine.set_process(false)
 var ticks:int=signals.ticks
 machine._process(.00001);assert(signals.ticks==ticks)
 machine._process(.05);assert(signals.ticks==ticks+1)
 ticks=signals.ticks;machine._process(.000001);assert(signals.ticks==ticks)
 machine._process(5);assert(signals.ticks<=ticks+1) # One coalesced cue after a stalled frame.
 assert(signals.locked==12)
 print("SPINNER 050 PASS: all six tiers skip rolling/anticipation once, repeated locks do not emit, clicks share rendered position, stalled frames do not burst queued audio")
 machine.free();quit()
