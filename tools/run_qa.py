from pathlib import Path
import subprocess, os, json, time, argparse, uuid, shutil, sys
ROOT=Path(__file__).resolve().parents[1]
GODOT=Path(os.environ.get('GODOT', shutil.which('godot') or str(Path.home()/'Desktop'/'Godot_v4.7.2-stable_win64_console.exe')))
OUT=ROOT/'.godot_test_data'/'qa_logs'
p=argparse.ArgumentParser(description='Run guarded Lootlings fixtures with disposable saves. Set GODOT to the engine executable.'); p.add_argument('--native',action='store_true'); p.add_argument('--only',nargs='*'); p.add_argument('--label',default='baseline'); p.add_argument('--size',default='480x854'); args=p.parse_args()
if args.only:
    unknown=set(args.only)-{x.stem for x in (ROOT/'tests').glob('*.gd')}
    if unknown: p.error('Unknown QA fixtures: '+', '.join(sorted(unknown)))
run_id=args.label+'-'+uuid.uuid4().hex[:10]
folder=OUT/run_id; folder.mkdir(parents=True,exist_ok=True)
results=[]
def run(name,command,timeout=300):
    env=os.environ.copy()
    env['APPDATA']=str(ROOT/'.godot_test_data'/'isolated'/run_id/name)
    env['XDG_DATA_HOME']=env['APPDATA']; env['LOOTLINGS_QA']='1'
    env['LOOTLINGS_CAPTURE_SIZE']=args.size
    Path(env['APPDATA']).mkdir(parents=True,exist_ok=True)
    start=time.time()
    try:
        with (folder/(name+'.log')).open('wb') as log:
            r=subprocess.run([str(GODOT),'--path',str(ROOT),*command],env=env,stdout=log,stderr=subprocess.STDOUT,timeout=timeout)
        output=(folder/(name+'.log')).read_text(encoding='utf-8',errors='replace'); code=r.returncode
    except subprocess.TimeoutExpired as e:
        output=(folder/(name+'.log')).read_text(encoding='utf-8',errors='replace'); code=124
    (folder/(name+'.log')).write_text(output,encoding='utf-8')
    errors=[line for line in output.splitlines() if 'SCRIPT ERROR' in line or 'ERROR:' in line or 'Parse Error' in line]
    expected=[]
    if name=='save_recovery_qa':
        expected=[e for e in errors if e.startswith('ERROR: ConfigFile parse error at user://recovery.cfg:')]
        errors=[e for e in errors if e not in expected]
        if len(expected)!=2: errors.append('Expected exactly two corrupt-fixture parse diagnostics')
    results.append(dict(name=name,exit=code,seconds=round(time.time()-start,2),errors=errors,expected_diagnostics=expected))
    (folder/'results.json').write_text(json.dumps(results,indent=2))
    print(name,'exit',code,'errors',len(errors),'seconds',results[-1]['seconds'],flush=True)
    if errors: print('\n'.join(errors[:4]),flush=True)
if not args.only:
    run('import',['--headless','--editor','--import'],180)
    if not args.native:
        scripts=sorted(ROOT.glob('*.gd'))+sorted((ROOT/'tests').glob('*.gd'))+sorted((ROOT/'tools').glob('*.gd'))
        for script in scripts:
            run('parse-'+script.relative_to(ROOT).as_posix().replace('/','-'), ['--headless','--check-only','--script','res://'+script.relative_to(ROOT).as_posix()],60)
for path in sorted((ROOT/'tests').glob('*.gd')):
    if 'extends SceneTree' not in path.read_text(encoding='utf-8-sig') and path.stem != 'balance_audit': continue
    name=path.stem
    if args.only and name not in args.only: continue
    if name == 'balance_audit' and not args.only: continue # Legacy entry point delegates to the isolated harness.
    if args.native:
        if name.endswith('_runs') or name in ['smoke_test','expansion_test','balance_audit','phase3_balance','phase3_dps','phase3_economy','wardrobe_qa','audio_production_qa','save_recovery_qa']: continue
        cmd=['--resolution',args.size,'--position','0,0','-s','res://tests/'+path.name,'--','--visual','--report']
    else:
        if name in ['audio_mix_qa','visual_qa_capture','mobile_layout_qa','presentation_matrix_qa']: continue
        cmd=['--headless','-s','res://tests/'+path.name,'--','--report']
    run(name,cmd,1200 if name in ['phase3_balance','balance_audit'] else 300)

print('QA results:',folder/'results.json',flush=True)
sys.exit(0 if all(r['exit']==0 and not r['errors'] for r in results) else 1)
