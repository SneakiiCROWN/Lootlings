"""Package native review captures; does not create or modify game art."""
from pathlib import Path
from PIL import Image, ImageDraw
import hashlib, json, re, shutil, subprocess, zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/production/relic-spinner'
OUT.mkdir(parents=True, exist_ok=True)
tiers = ['common', 'uncommon', 'rare', 'epic', 'legendary', 'red']
for size in ['1080x2316', '1600x2560']:
    source = ROOT / '.godot_test_data/spinner' / size
    for state in ['result', 'burst']:
        sheet = Image.new('RGB', (1260, 2850), '#071027')
        draw = ImageDraw.Draw(sheet)
        for i, tier in enumerate(tiers):
            frame = Image.open(source / f'{tier}_{state}.png').convert('RGB')
            frame.thumbnail((610, 900))
            x, y = (i % 2) * 630, (i // 2) * 950
            draw.text((x + 15, y + 10), f'{size} / {tier.upper()} / {state}', fill='white')
            sheet.paste(frame, (x + (630-frame.width)//2, y + 40))
        sheet.save(OUT / f'{size}-{state}-review.webp', quality=88)
    for name in ['pool', 'rolling', 'fast_skip', 'red_anticipation', 'red_result', 'reduced_red', 'red_ready_paid_result']:
        frame = Image.open(source / f'{name}.png').convert('RGB')
        frame.save(OUT / f'{size}-{name}.webp', quality=88)
print('Native six-tier, anticipation, pool, skip and reduced-motion evidence packaged.')

logs = OUT / 'logs'
logs.mkdir(exist_ok=True)
results = []
for prefix in ['spinner-before-', 'spinner-regression-', 'spinner-release-contract-',
               'spinner-final-seed-', 'spinner-phone-delivery-', 'spinner-tablet-delivery-',
               'spinner-phone-card-', 'spinner-tablet-card-']:
    runs = sorted((ROOT/'.godot_test_data/qa_logs').glob(prefix+'*'), key=lambda p: p.stat().st_mtime)
    if not runs: raise RuntimeError('Missing accepted QA run: '+prefix)
    run = runs[-1]
    for result in json.loads((run/'results.json').read_text()):
        assert result['exit'] == 0 and not result['errors'], result
        result['run'] = run.name
        results.append(result)
    for path in run.glob('*.log'):
        shutil.copy2(path, logs/(prefix+path.name))
(OUT/'qa-results.json').write_text(json.dumps(results, indent=2)+'\n', encoding='utf-8')
economy = (logs/'spinner-release-contract-relic_spinner_qa.log').read_text(encoding='utf-8')
record = next(line.removeprefix('SPINNER DISTRIBUTIONS ') for line in economy.splitlines() if line.startswith('SPINNER DISTRIBUTIONS '))
(OUT/'distributions.json').write_text(json.dumps(json.loads(record), indent=2)+'\n', encoding='utf-8')
build = json.loads((ROOT/'builds/android/build-report.json').read_text())
apk_path = ROOT/build['apk']
assert hashlib.sha256(apk_path.read_bytes()).hexdigest() == build['sha256']
with zipfile.ZipFile(apk_path) as apk:
    assert all('assets/'+name+'.gdc' in apk.namelist() for name in ['relic_machine','relic_spin_catalog','retention_runtime','endgame_progress'])
    assert not any(name.startswith('assets/tests/') for name in apk.namelist())
build['spinner_modules_verified'] = True
(OUT/'android-build.json').write_text(json.dumps(build, indent=2)+'\n', encoding='utf-8')
sources = {name: hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in ['relic_machine.gd','relic_spin_catalog.gd','retention_runtime.gd','endgame_progress.gd','phase4b_catalog.gd','lootling.gd','export_presets.cfg']}
(OUT/'source-checkpoint.json').write_text(json.dumps({'implementation': subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip(), 'sources': sources},indent=2)+'\n', encoding='utf-8')
print('Accepted QA, distributions, source hashes and actual APK modules verified.')
