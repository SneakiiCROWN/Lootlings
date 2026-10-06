"""Render the accepted checkpoint's unchanged Hideout UI without checking out files.

This is a UI-only baseline: the exact 79fecef Hideout script uses current shared
data/resources. It is not represented as a full historical binary/run.
"""
from pathlib import Path
import os, subprocess
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.godot_test_data/phase4e/full-continuation'
OUT.mkdir(parents=True,exist_ok=True)
source=subprocess.check_output(['git','show','79fecef:hideout_ui.gd'],cwd=ROOT)
(OUT/'baseline_hideout.gd').write_bytes(source)
fixture='''extends "res://tests/phase4b_native_qa.gd"
func _initialize():
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review_baseline")
func review_baseline():
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.show_hideout()
	game.hideout_ui.hide()
	var ui=load("res://.godot_test_data/phase4e/full-continuation/baseline_hideout.gd").new();game.add_child(ui)
	game.hideout_ui=ui
	ui.campaign=game.campaign
	ui.configure(game.inventory,game.hideout_shop,game.meta_shards,game.meta_power,Callable(game,"build_item_comparison"),game.gold,game.profile,game.gold_upgrades,game.achievements)
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/phase4e/full-continuation/before/"+str(layout.x)+"x"+str(layout.y)+"/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		ui.show_lore();await capture("field_notes")
		ui.show_memories();await capture("memory_cards")
		ui.show_shop();ui.select_shop_offer(0);await capture("merchant_comparison")
		ui.show_home();ui.profile.current_lootling_id="gloomlet";ui.queue_redraw();await capture("home_gloomlet")
	game.free();print("UI BASELINE PASS: exact 79fecef Hideout script, current shared data, no checkout or save migration");quit()
'''
path=OUT/'baseline_capture.gd';path.write_text(fixture,encoding='utf-8')
env=os.environ.copy();env.update(APPDATA=str(ROOT/'.godot_test_data/isolated/canon-world-ui-baseline'),XDG_DATA_HOME=str(ROOT/'.godot_test_data/isolated/canon-world-ui-baseline'),LOOTLINGS_QA='1')
with (OUT/'baseline.log').open('wb') as log:
    result=subprocess.run([env.get('GODOT',r'C:\Users\Snkii\Desktop\Godot_v4.7.2-stable_win64.exe'),'--path',str(ROOT),'-s','res://'+path.relative_to(ROOT).as_posix(),'--resolution','1080x2340'],env=env,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,timeout=120)
output=(OUT/'baseline.log').read_text(encoding='utf-8',errors='replace')
if result.returncode or 'ERROR:' in output:raise SystemExit(output)
print(output)
