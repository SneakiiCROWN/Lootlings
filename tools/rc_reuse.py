"""Prove the scope of retained Phase 3 evidence against the delivered checkpoint."""
from pathlib import Path
import subprocess, hashlib, json, re, argparse
ROOT = Path(__file__).resolve().parents[1]
BASE = 'd073dd6'
p=argparse.ArgumentParser(); p.add_argument('--renderer-only',action='store_true'); args=p.parse_args()
def previous(path):
    return subprocess.check_output(['git','show',f'{BASE}:{path}'],cwd=ROOT)
def functions(data):
    text = data.decode('utf-8-sig').replace('\r\n','\n')
    parts = re.split(r'(?m)^(?=func )',text)
    return {re.match(r'func (\w+)',p)[1]:p.rstrip() for p in parts if p.startswith('func ')}
groups = {
    'stationary_dps_and_incoming_pressure': ['build_system.gd','character_traits.gd','weapon_catalog.gd','item_catalog.gd','phase3_item_catalog.gd','boss_patterns.gd','enemy_encounter.gd','enemy_variant_catalog.gd','tests/phase3_dps.gd','tests/phase3_pressure_qa.gd'],
    'canonical_pose_projectile_pickup_evidence': ['action_pose_catalog.gd','authored_pose_manifest.gd','avatar_presentation.gd','weapon_fit_catalog.gd','combat_presentation.gd','projectile_presentation.gd','pickup_presentation.gd','relic_greatsword_motion.gd'],
    'species_audio_and_licensing': ['audio_manager.gd','voice_identity.gd','AUDIO_LICENSES.md'],
    'unchanged_copy_and_world_content': ['dialogue_director.gd','world_content_catalog.gd','world_story.gd','vignette_catalog.gd','vignette_player.gd','expedition_event_catalog.gd','campaign_system.gd'],
}
tracked = subprocess.check_output(['git','ls-files','-z'],cwd=ROOT).decode().split('\0')
groups['canonical_pose_projectile_pickup_evidence'] += [p for p in tracked if p.startswith('art/') and not p.startswith('art/audio/')]
groups['species_audio_and_licensing'] += [p for p in tracked if p.startswith(('audio/','art/audio/'))]
report = {'baseline_checkpoint':BASE,'groups':{},'limitations':'Unchanged lab/catalog/art evidence is retained, not a new physical or subjective acceptance. Reward changes invalidate whole-run balance/economy/roster evidence; those cohorts are rerun.'}
if args.renderer_only: report=json.loads((ROOT/'docs/production/predevice/reuse.json').read_text())
for group, paths in groups.items():
    if args.renderer_only: continue
    rows = []
    for path in paths:
        before = previous(path); after = (ROOT/path).read_bytes()
        # Git text normalization may differ; compare normalized text where applicable.
        if Path(path).suffix in ['.gd','.md','.txt','.cfg','.json','.import','.gdignore','.csv','.tsv','.svg','.tres','.tscn','.godot'] or Path(path).name == '.gdignore':
            before = before.replace(b'\r\n',b'\n'); after = after.replace(b'\r\n',b'\n')
        assert before == after, f'Reuse invalidated: {path}'
        rows.append({'path':path,'sha256':hashlib.sha256(after).hexdigest()})
    report['groups'][group] = rows
before = functions(previous('creature_renderer.gd')); after = functions((ROOT/'creature_renderer.gd').read_bytes())
report['renderer_retained_functions'] = []
for name, body in after.items():
    # Removed procedural blocks leave their preceding comments with the previous
    # function; compare executable lines rather than those boundary comments.
    clean = lambda s:'\n'.join(l.rstrip() for l in s.splitlines() if l.strip() and not l.lstrip().startswith('#') and (l.startswith('func ') or l[0].isspace()))
    assert clean(body) == clean(before[name]), name
    report['renderer_retained_functions'].append(name)
out = ROOT/'docs/production/predevice/reuse.json'
out.write_text(json.dumps(report,indent=2),encoding='utf-8')
print('Retained evidence proven:', {k:len(v) for k,v in report['groups'].items()})
