"""Retain accepted run identities and build proof without overwriting prior tranches."""
from pathlib import Path
import json, shutil, hashlib

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'docs/production/phase2/fidelity'
RUNS = [
    'fidelity-regressions-final-1f61ef6e12',
    'fidelity-sweep-native-ddd68cae0b',
    'fidelity-live-hooks-final-88054aa55c',
    'fidelity-archive-final-1a2b3f69f3',
    'fidelity-audio-archive-native-0f693c5fab',
    'fidelity-s23-final-5836b701ed',
    'fidelity-tablet-final-dd7b06a1a2',
    'fidelity-final-followup-f0bbeca176',
]
accepted = []
for run in RUNS:
    rows = json.loads((ROOT/'.godot_test_data/qa_logs'/run/'results.json').read_text())
    assert all(row['exit'] == 0 and not row['errors'] for row in rows), run
    accepted.append({'run': run, 'results': rows})
    for row in rows:
        if row['name'] in ['fidelity_qa', 'audio_mix_qa', 'smoke_test', 'mobile_layout_qa']:
            shutil.copy2(ROOT/'.godot_test_data/qa_logs'/run/(row['name']+'.log'), OUT/(run+'-'+row['name']+'.log'))
(OUT/'accepted-results.json').write_text(json.dumps(accepted, indent=2)+'\n')
build = json.loads((ROOT/'builds/android/build-report.json').read_text())
apk = ROOT/build['apk']
assert hashlib.sha256(apk.read_bytes()).hexdigest() == build['sha256']
assert build['version_code'] == 4 and build['current_pcm_audio_assets'] == 329
build['implementation_checkpoint'] = 'a1ceabe'
(OUT/'android-build-report.json').write_text(json.dumps(build, indent=2)+'\n')
shutil.copy2(ROOT/'.godot_test_data/android-branding/results.json', OUT/'android-branding-results.json')
shutil.copy2(ROOT/'.godot_test_data/android-branding/actual-apk-branding.png', OUT/'evidence/actual-apk-branding.png')
for name in ['signature.log', 'alignment.log', 'badging.log']:
    shutil.copy2(ROOT/'.godot_test_data/android'/name, OUT/('android-'+name))
print('Accepted fixtures:', sum(len(run['results']) for run in accepted))
print('Final APK SHA256:', build['sha256'])
