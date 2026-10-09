"""Lean studio handoff; reference existing authorities instead of copying queues."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/production/coordination'
CONT=ROOT/'docs/production/full-completion/continuous-production'

def write(name,text): (OUT/name).write_text(text.rstrip()+'\n',encoding='utf-8')
def dump(name,data):write(name,json.dumps(data,indent=2))

def main():
    OUT.mkdir(exist_ok=True)
    counts=json.loads((CONT/'CONTINUOUS_PRODUCTION_COUNTS.json').read_text(encoding='utf-8'))
    write('MASTER_STUDIO_STATE.md',f'''# Lootlings shared production state

Active writer: Codex, live `C:\\Users\\Snkii\\Documents\\lootlings`, branch `codex/phase4e-gamefeel`.
Verified base: pushed 0.4.41 `741ff4a`. Current candidate: 0.4.42 cohesive item cards. Resolve the saved milestone with `git log`; an exported candidate is not a public release or final acceptance.

{counts['installed_contracts']} installed exact delivery closures; {counts['remaining_contracts']} remaining. {counts['installed_artist_files']} installed artist files; {counts['remaining_artist_files']} remaining. These are frozen delivery denominators, not whole-game quality percentages.

The sole coverage dashboard is [PRODUCTION_DASHBOARD.html](../PRODUCTION_DASHBOARD.html), with [machine-readable data](../PRODUCTION_DASHBOARD.json) and [seven-stage evidence](../QUALITY_ACCEPTANCE_EVIDENCE.json). Regenerate with the established tools; do not manually edit generated inventories.

48 newly integrated keyframes cover three creatures and two residents. Locomotion, full multi-frame continuity, missing player grips/poses and broad artistic acceptance remain open. Approved title music, original branding, six companion authorities and winged four-legged Hoard Dragon remain preserved.

Owner's pre-existing `project.godot` edits and supplied untracked references are retained; do not reset or clean them. No parallel writers have been launched in this run.
''')
    families=[('playable_lootlings','P0','Complete frequently seen modular body/action families; source-authored grips, both views; remove live reference-card fallbacks.'),
              ('wanderers','P1','Canonical bodies, clothing fitting and action states for all five existing Wanderers.'),
              ('enemies','P1','Continue existing registered regional families; real windup/commit/hurt/recovery/defeat in gameplay.'),
              ('bosses','P1','Complete attack-specific families, continuity and effects; winged Hoard Dragon authority remains locked.'),
              ('npcs','P1','Finish resident route/work/sit and Sera/Merrow bodies; preserve accepted Patch/Ilex exports.'),
              ('support','P0','Measured foreground grips, support hands, nocks/sockets and equipment layering; no invented palms.')]
    tasks=[dict(id='regional-residents-041',owner='Codex',status='VERIFIED_BETA',priority='P1',dependencies=['1887f7a'],
                acceptance='48 exact cells integrated and native-reviewed; professional animation-family/device acceptance remains open.',
                evidence='../full-completion/continuous-production/REGIONAL_RESIDENT_INSTALLATION_0441.json')]
    tasks += [dict(id='remaining-'+f,owner='unassigned',status='SOURCE_REQUIRED',priority=p,
                   remaining_contracts=counts['remaining_by_category'][f],dependencies=['exact dedicated canon','runtime integration owner'],
                   acceptance=a+' All seven quality stages must be evidenced.',
                   authoritative_queue='../full-completion/continuous-production/EXACT_REMAINING_CONTRACTS.json') for f,p,a in families]
    tasks += [dict(id='cohesive-item-cards-042',owner='Codex',status='VERIFIED_BETA',priority='P1',dependencies=['741ff4a'],acceptance='Shared approved item frames, one-selection tick, independent keyboard focus and contained merchant icons; source and compiled three-viewport tests. No new art closures or final quality acceptance.',evidence='../quality-evidence/0.4.42/REPORT.md'),dict(id='world-ui-professional-quality',owner='Codex',status='NEEDS_ART_CORRECTION',priority='P1',
                   dependencies=['existing working navigation/save systems'],acceptance='Home/Hub props, service cues, item/reward frames and text assessed through actual routes; preserve functions.',
                   evidence='../QUALITY_ACCEPTANCE_EVIDENCE.json'),
              dict(id='audio-perceptual-review',owner='unassigned',status='QA_PENDING',priority='P1',
                   dependencies=['licensed current soundtrack/SFX','approved title lock'],acceptance='Actual listening and transition/mix review; no mastering claim from waveform/tests.'),
              dict(id='physical-android-acceptance',owner='owner/device tester',status='QA_PENDING',priority='P1',
                   dependencies=['native tested candidate'],acceptance='S23 Ultra physical controls, frame pacing, heat, sound, saves, launcher/splash and normal player route.')]
    dump('MASTER_TASK_QUEUE.json',dict(authority='Coordination only; existing exact contracts and dashboard remain authoritative inventories.',tasks=tasks))
    dump('ASSET_BATCH_MANIFEST.json',dict(batch='regional-residents-041',writer='Codex',status='VERIFIED_BETA',
         authoritative_receipt='../full-completion/continuous-production/REGIONAL_RESIDENT_INSTALLATION_0441.json',
         runtime_manifests=['../../../art/production_enemy_manifest.json','../../../art/production_npc_manifest.json'],
         evidence='../QUALITY_ACCEPTANCE_EVIDENCE.json',closed_delivery_contracts=48,runtime_png_cells=48,sidecars=48,
         completed_multiframe_animation_families=0,production_quality_accepted=False))
    write('VISUAL_QA.md','''# Current visual QA

Current source and native gameplay evidence: [seven-stage ledger](../QUALITY_ACCEPTANCE_EVIDENCE.json), [captures/logs](../quality-evidence/0.4.41/).

Latest 0.4.42 [item-card captures/logs](../quality-evidence/0.4.42/) show approved cool/warm shared framing, one persistent selection mark, independent focus and corrected merchant icon containment. Source and compiled PCK tested at all three viewports; no new art closure or full artistic acceptance.

- Corrected and rejected before integration: mixed-sheet clipped bat ears and inherited pup bells; overlapping bounds; left resident crop contamination; wrong-facing Coal left commit.
- Native-reviewed accepted cells: canonical faces/palettes/silhouettes, independent views, alpha, scale, feet anchors and exact state changes. This is keyframe review, not full multi-frame family approval.
- Existing Home/Hub and Shop/Stash/reward screens have fresh representative review; subjective prop cohesion, repeated interaction labels and uneven menu framing remain open.
- Shop comparison padding and bold size were corrected after native inspection; comparison text scrolls and buying/selection mechanics are preserved.
- Player opposite-facing weapon reference fallbacks, missing grips and locomotion remain prominent production gaps.

Automation and packaged-resource checks do not grant final artistic approval. Physical Android listening/performance and independent owner acceptance remain pending.
''')
    write('INTEGRATION_LOG.md','''# Integration log

0.4.42 follows pushed 741ff4a: shared item frames and selection feedback in `lootlings_ui.gd`, offer-relative icons in `lootling.gd`, candidate version 51 in `export_presets.cfg`. Source and actual exported PCK native tests pass; APK asset/branding comparison passes. [Current pass report](../quality-evidence/0.4.42/REPORT.md). No audio or progression changes.

0.4.41 continues pushed 1887f7a without reset. Exact added runtime files and hashes are in the [installation receipt](../full-completion/continuous-production/REGIONAL_RESIDENT_INSTALLATION_0441.json) and both referenced manifests.

Runtime writers: `resident_art_catalog.gd`, `hideout_ui.gd`, `hub_navigation.gd`; manifest include/version update in `export_presets.cfg`. Canonical NPC portrait authority and old accepted enemy frames preserved.

Native fixtures cover 1080×2340, 1200×1920 and 1920×1080; compiled PCK tested for resident dialogue/services and Coal attacks. APK receipt verifies 48 current imported textures and both exact manifests. Windows/Android branding resource comparison passes. Candidate export is not physical-device acceptance.

Dashboard generation records all registered families, exact debt, stages and unregistered/dynamic dependency gaps. No previous LIVE_BETA/complete label is automatically production-ready.

Git milestone: commit titled “Integrate canonical regional creatures and Hub residents with quality gates”; use branch history for its actual hash. Unknown owner work remains outside this scoped checkpoint.
''')
    write('BLOCKERS.md','''# Genuine dependencies

- Thousands of exact authored body/state/view/grip contracts remain missing; approved boards and portraits do not close them.
- Physical S23 Ultra hardware review is unavailable to this run. Candidate APK integrity and desktop native dimensions are tested separately.
- Full animation continuity, subjective artistic polish, sound listening and player-experience acceptance remain open, including historical content.
- See dashboard dependency gaps for dynamic resource patterns and unregistered literals. These are coverage/registration gaps, not an assertion that all those files are missing.

No additional canon decision is requested. Dedicated sources, approved companion collection/implementation pack, original branding/title music and explicit winged Dragon correction continue to govern production. Public release remains gated.
''')
    write('NEXT_HANDOFF.md','''# Next production handoff

Read MASTER_STUDIO_STATE and the single dashboard. Confirm branch/working tree without resetting. Do not regenerate the accepted 48 cells or rerun unchanged broad service passes.

1. Keep pushed 0.4.41 `741ff4a` and the scoped 0.4.42 item-card checkpoint recoverable; preserve owner config/references. The exact 0.4.42 hash is in branch history.
2. Claim complete compatible player body/action/grip families that remove the normal route's reference-card fallbacks, alongside independent enemy/boss/NPC work.
3. Use the current frozen contract queue and dedicated canon. Integrate each independent valid family, quarantine failures, native-test real contact/transition states.
4. Continue Home/Hub prop cohesion and shared reward/Shop/Stash framing; current functionality stays intact. Audio review must include actual listening and licence records; title track is locked.
5. Record evidence for all seven gates, regenerate dashboard, export internal candidates and checkpoint substantial results. Never infer professional acceptance from counts or export success.
''')
    print('Seven lean coordination records written; canonical registries and exact queues referenced, not duplicated')

if __name__=='__main__':main()
