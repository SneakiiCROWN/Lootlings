"""Run external guarded fixtures against the actual exported PCK, never copied game code."""
from pathlib import Path
import argparse,os,re,subprocess,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser();p.add_argument('pack');p.add_argument('--version',required=True);p.add_argument('--fixtures',nargs='+',required=True);a=p.parse_args()
    assert re.fullmatch(r'[0-9]+',a.version)
    base=ROOT/'.godot_test_data'/('exported-'+a.version);fixtures=ROOT/'.godot_test_data'/('exported-fixtures-'+a.version)
    base.mkdir(parents=True,exist_ok=True);fixtures.mkdir(parents=True,exist_ok=True)
    copied=set()
    def copy(name):
        assert Path(name).name==name and name.endswith('.gd')
        if name in copied:return
        copied.add(name);text=(ROOT/'tests'/name).read_text(encoding='utf-8-sig')
        for dep in re.findall(r'res://tests/([^"\s]+\.gd)',text):copy(dep)
        text=text.replace('res://tests/',fixtures.as_posix()+'/').replace('res://.godot_test_data/',base.as_posix()+'/')
        (fixtures/name).write_text(text,encoding='utf-8')
    results=[]
    for name in a.fixtures:
        copy(name+'.gd');env=os.environ.copy();env['LOOTLINGS_QA']='1';env['LOOTLINGS_PLAYER_BATCH_STAGE']='after';env.pop('LOOTLINGS_PLAYER_BATCH_PREVIEW',None);env.pop('LOOTLINGS_COMBAT_BATCH_PREVIEW',None);env.pop('LOOTLINGS_MOTION_BATCH_PREVIEW',None)
        env['APPDATA']=str(base/'isolated'/name);env['XDG_DATA_HOME']=env['APPDATA'];Path(env['APPDATA']).mkdir(parents=True,exist_ok=True)
        log=fixtures/(name+'.log')
        engine=Path.home()/'Desktop/Godot_v4.7.2-stable_win64_console.exe'
        with log.open('wb') as out:r=subprocess.run([str(engine),'--main-pack',str((ROOT/a.pack).resolve()),'--resolution','1080x2340','--position','0,0','-s',str(fixtures/(name+'.gd'))],env=env,cwd=ROOT,stdout=out,stderr=subprocess.STDOUT,timeout=300)
        output=log.read_text(encoding='utf-8',errors='replace');errors=[line for line in output.splitlines() if 'ERROR:' in line or 'SCRIPT ERROR' in line]
        assert r.returncode==0 and not errors,(name,r.returncode,errors)
        results.append(dict(fixture=name,exit=r.returncode,errors=errors,pack=str((ROOT/a.pack).resolve()),pack_sha256=hashlib.sha256((ROOT/a.pack).read_bytes()).hexdigest(),fixture_sha256=hashlib.sha256((ROOT/'tests'/(name+'.gd')).read_bytes()).hexdigest(),saves='isolated',copied_game_code=False))
        print(name+' compiled PCK native PASS',flush=True)
    (fixtures/'results.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
if __name__=='__main__':main()
