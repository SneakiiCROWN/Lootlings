"""Final evidence/report after exported native fixtures have really completed."""
from pathlib import Path
import json,hashlib,shutil
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/production/quality-evidence/0.4.43'
CONT=ROOT/'docs/production/full-completion/continuous-production'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,x):p.write_text(json.dumps(x,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    results=read(ROOT/'.godot_test_data/exported-fixtures-043/results.json')
    assert {r['fixture'] for r in results}=={'player_batch_native_qa','player_route_polish_native_qa','compiled_candidate_native_qa','cohesive_cards_native_qa'}
    assert all(r['exit']==0 and not r['errors'] and not r['copied_game_code'] for r in results)
    for r in results:shutil.copyfile(ROOT/'.godot_test_data/exported-fixtures-043'/(r['fixture']+'.log'),OUT/('compiled_'+r['fixture']+'.log'))
    data=read(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json')
    rows=read(ROOT/'art/production/phase4e/player_batch_043_manifest.json')['entries']
    by_slot={r['contract_slot_id']:r for r in rows}
    names={'idle':'idle','windup':'windup','strike_or_cast':'commit','follow_through':'follow','recovery':'recovery','hurt':'hurt'}
    for entry in data['entries']:
        row=by_slot.get(entry['slot_id'])
        if row:
            name=f"{row['actor']}_{row['weapon_types'][0]}_{names[row['state']]}_{row['facing'].removesuffix('_only')}.png"
            src=ROOT/'.godot_test_data/exported-043/player-batch-043/after/1080x2340'/name
            dest=OUT/('compiled_1080x2340_'+name);shutil.copyfile(src,dest)
            entry['evidence_files'] += [dest.relative_to(ROOT).as_posix(),'docs/production/quality-evidence/0.4.43/compiled_player_batch_native_qa.log']
        elif entry['slot_id']=='screen:lootling.gd:show_boss_reward':
            entry['limitations']='Single-find panel now fits one card; artwork belongs to its item button. Connected source and compiled routes tested at three layouts. Broader reward audio/motion/device and professional acceptance remain open.'
            entry['evidence_files']=['docs/production/quality-evidence/0.4.43/compiled_player_route_polish_native_qa.log']+['docs/production/quality-evidence/0.4.43/'+v+'_reward_find.png' for v in ['1080x2340','1200x1920','1920x1080']]
        elif entry['slot_id']=='screen:lootling.gd:show_merchant':
            entry['evidence_files'].append('docs/production/quality-evidence/0.4.43/compiled_cohesive_cards_native_qa.log')
    write(ROOT/'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json',data)
    for stage in ['before','after']:
        source=ROOT/'.godot_test_data/player-batch-043'/stage/'1080x2340/gloomlet_bow_idle_right.png'
        shutil.copyfile(source,OUT/(stage+'_gloomlet_bow_idle_right.png'))
    counts=read(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json')
    receipt=read(CONT/'PLAYER_COMBAT_INSTALLATION_0443.json')
    receipt['exported_native_fixtures']=results
    receipt['registry_reconciliation']='Derived launch missing cells 2953 to 2893: 25 new exact contracts, 35 already-installed casting states now reflected. An ATTACK frame does not close separate follow-through. Historical reconciliation is not credited as new contract production.'
    receipt['builds']=[dict(path=p,sha256=sha(ROOT/p),bytes=(ROOT/p).stat().st_size) for p in ['builds/android/Lootlings-0.4.43-player-combat-debug.apk','builds/windows/Lootlings-0.4.43-player-combat.exe','builds/windows/Lootlings-0.4.43-player-combat.pck']]
    write(CONT/'PLAYER_COMBAT_INSTALLATION_0443.json',receipt)
    shutil.copyfile(ROOT/'builds/android/build-report.json',OUT/'ANDROID_BUILD.json')
    shutil.copyfile(ROOT/'.godot_test_data/windows/icon-verification.json',OUT/'WINDOWS_BRANDING.json')
    report='''# 0.4.43 — real player combat bodies and connected rewards

Live production root: `C:\\Users\\Snkii\\Documents\\lootlings`; branch `codex/phase4e-gamefeel`. Base pushed 0.4.42 `6a15b57`. GitHub Issue #3 executed as a scoped delivery milestone; full-game professional completion remains open.

Gloomlet Bow gains real idle, release, follow-through, recovery and hurt bodies in both independently authored views. Accepted prior windups remain. Moonkip Wand gains idle/hurt both views and a true left windup. Moonkip Orb gains ten exact state/view deliveries using compatible weaponless bodies, including prior approved casting exports. Original dedicated Gloomlet and hooded cream Moonkip sheets govern identity; conflicting alternate Moonkip reference is preserved and excluded.

Modular weapon assets remain separate. Source-measured palms and foreground fingers keep the Bow/Wand at the hand; the released rear Bow paw stays released. Native review corrected resting weapon angles that obscured faces. Hurt now takes priority over recovery when choosing a body. Gameplay stats, attack timing, random state, economy and save formats are unchanged.

**25 new verified delivery contracts**: Gloomlet Bow 10; Moonkip Wand 5; Moonkip Orb 10. **15 new body PNGs +15 foreground-grip PNGs +25 sidecars =55 new physical artist files.** These fulfil 75 frozen artist-file requirements, including 20 compatible reused body/grip references. Raw source sheets and import cache files are not counted as finished artist deliveries. No new enemy/NPC animation closures are claimed in this milestone; prior 48 creature/resident keyframes are preserved and packaged-tested.

Single-find rewards now shrink from 630 to 370 local units; item artwork is contained within its card. Source and compiled touch routes verify Home, Hub/cart Shop, purchase once, Stash, Shrine, earned Spinner and empty-bank explanation, combat, perk selection, reward keep, results and natural return. Existing selection/merchant controls and title theme remain intact.

Native source and actual exported Windows PCK ran at 1080×2340, 1200×1920 and 1920×1080. Selected stationary/action probes: **108 before /108 after; reference fallback incidents 81→0**. Real attacks/projectile creation, unchanged timings/damage/random states and explicit movement fallback are checked. Save recovery and weapon-fit regressions pass. This is scoped probe coverage, not a claim of zero fallbacks gamewide or complete smooth multi-frame animation.

Rejected/corrected together: wrong-facing Moonkip left windup/cast; three-foot Moonkip recovery; source-edge Gloomlet follow-through; clipped-ear standalone windup. Valid earlier Gloomlet follow-through retained, padded true-left Moonkip windup corrected. Source records remain recoverable. No bad candidate closes a contract.

**Remaining frozen debt: 3,058 contracts /8,001 artist-file requirements.** Playable Lootlings 1,396; Wanderers 855; enemies 252; bosses 356; NPCs 34; support 165. Derived registry is a different denominator: 2,893 missing launch cells, after 25 new closures and reconciliation of 35 already installed casting states. ATTACK fallback never closes a distinct follow-through requirement. Dashboard retains 43 registration/dependency gaps and zero blanket professionally accepted records.

Movement, Moonkip separate follow-through, defeat/victory, remaining weapon families, Wanderer fitting, resident route/work/sit and complete animation continuity remain open. Regional/boss art, world grounding, Home/Hub cohesion, broad menu quality, perceptual audio listening and physical S23 review also remain. Next production pass should cover coordinated missing melee/player and enemy/resident families that directly remove live fallback states, preserving this milestone.

Candidates: `builds/android/Lootlings-0.4.43-player-combat-debug.apk` (version code 52; signed/aligned arm64 debug candidate), `builds/windows/Lootlings-0.4.43-player-combat.exe` plus adjacent PCK. Current manifests/body/grip textures verified in APK; approved launcher/adaptive/monochrome/splash resources and Windows 16–256px icons checked. Physical Android launch, listening and performance are pending. These are candidate builds, not final commercial acceptance.

Runtime changes: `authored_pose_manifest.gd`, `weapon_fit_catalog.gd`, `lootling.gd`, `export_presets.cfg`, `art/production/phase4e/player_batch_043_manifest.json` and its exact bodies/grip layers/sidecars. Deterministic export jobs, original sources/provenance, guarded QA, registry/dashboard builders and receipts are included. Owner's pre-existing `project.godot` edits and supplied untracked reference packages remain outside this checkpoint.

![Before: canonical reference fallback](before_gloomlet_bow_idle_right.png)

![After: real grounded Gloomlet Bow body](after_gloomlet_bow_idle_right.png)
'''
    (OUT/'REPORT.md').write_text(report,encoding='utf-8')
    coord=ROOT/'docs/production/coordination'
    (coord/'MASTER_STUDIO_STATE.md').write_text('''# Lootlings shared production state

Single active writer: Codex; live `C:\\Users\\Snkii\\Documents\\lootlings`, branch `codex/phase4e-gamefeel`. Base pushed 0.4.42 `6a15b57`; current tested candidate 0.4.43. Resolve latest saved/pushed SHA through Git, never infer a checkpoint from an export.

216 installed exact contracts /3058 remaining. 494 fulfilled frozen artist-file requirements /8001 remaining, including verified reuse; new physical files are separately counted per receipt. Current pass closes25 contracts with15 new bodies,15 grip layers,25 sidecars. No whole animation family or professional acceptance is asserted.

Sole dashboard: [coverage and quality](../PRODUCTION_DASHBOARD.html). Current [report](../quality-evidence/0.4.43/REPORT.md) and [receipt](../full-completion/continuous-production/PLAYER_COMBAT_INSTALLATION_0443.json). Original canon, title music, branding, winged quadruped Dragon, companions and save/gameplay compatibility remain preserved. Owner's pre-existing project configuration and references remain untouched. No parallel writers launched.
''',encoding='utf-8')
    write(coord/'ASSET_BATCH_MANIFEST.json',dict(batch='player-combat-043',writer='Codex',status='VERIFIED_BETA',authoritative_receipt='../full-completion/continuous-production/PLAYER_COMBAT_INSTALLATION_0443.json',runtime_manifests=['../../../art/production/phase4e/player_batch_043_manifest.json'],evidence='../QUALITY_ACCEPTANCE_EVIDENCE.json',closed_delivery_contracts=25,new_body_png=15,new_grip_png=15,new_sidecars=25,new_physical_artist_files=55,fulfilled_artist_file_requirements=75,completed_multiframe_animation_families=0,production_quality_accepted=False))
    queue=read(coord/'MASTER_TASK_QUEUE.json')
    for task in queue['tasks']:
        cat=task['id'].removeprefix('remaining-')
        if cat in counts['remaining_by_category']:task['remaining_contracts']=counts['remaining_by_category'][cat]
    if not any(t['id']=='player-combat-043' for t in queue['tasks']):queue['tasks'].insert(0,dict(id='player-combat-043',owner='Codex',status='VERIFIED_BETA',priority='P0',dependencies=['6a15b57'],acceptance='25 exact deliveries; selected native fallback incidents81→0; complete motion/family/device professional acceptance open.',evidence='../full-completion/continuous-production/PLAYER_COMBAT_INSTALLATION_0443.json'))
    write(coord/'MASTER_TASK_QUEUE.json',queue)
    (coord/'NEXT_HANDOFF.md').write_text('''# Continue current live production

Preserve all newer owner work. 0.4.43 tested candidate is checkpointed separately; read Git for exact saved/pushed SHA. No restart, reset or cleanup.

Read the sole dashboard, Issue #3 and current receipt. Next coordinated pass: missing high-frequency melee/player and enemy/resident actions, both views and actual modular contacts. Existing new Bow/Wand/Orb stationary/action exports must not be regenerated. Movement remains a visible fallback and cannot be satisfied by bobbing neutral. Moonkip separate follow-through remains outstanding; ATTACK is not a contract substitute. Resident rest/talk/inspect is installed; route/work/sit remains missing.

Keep25 new closures separate from historical registry reconciliation. Only native source/exported-game-tested exact slots close debt. Preserve title theme, original branding, approved six companions, winged quadruped Dragon, all stats/economy/saves. Native screenshots and tests are linked in0.4.43 report; physical S23 and complete artistic/audio/UX acceptance remain pending.
''',encoding='utf-8')
    with (coord/'INTEGRATION_LOG.md').open('a',encoding='utf-8') as f:f.write('\n0.4.43:25 exact player deliveries,15 new bodies/15 grip layers/25 sidecars;108 selected probe fallback incidents81→0; compact single-find rewards; source and compiled three-layout route checks. See receipt.\n')
    with (coord/'VISUAL_QA.md').open('a',encoding='utf-8') as f:f.write('\n0.4.43 native source/exported review: dedicated Gloomlet and hooded Moonkip, both views, complete silhouettes, source-pixel palms/foreground layers, resting face clearance and compact reward cards. Rejected wrong-facing/malformed/clipped source cells are logged. Full continuity, movement and physical-device professional acceptance remain open.\n')
    current=ROOT/'docs/production/START_HERE_CURRENT.md';text=current.read_text(encoding='utf-8')
    text=text.replace('Current continuation: [0.4.36 winged-canon combat family pass](full-completion/continuous-production/COMBAT_FAMILY_PASS.md). Twelve native-reviewed boss cells are installed; exact remaining counts stay explicit.','Current continuation: [0.4.43 real player combat bodies and rewards](quality-evidence/0.4.43/REPORT.md).25 new exact delivery closures; full motion/family/device professional acceptance remains open.')
    text=text.replace('## CURRENT — 0.4.42 cohesive item-card continuation','## CURRENT — 0.4.43 player combat bodies and connected rewards\n\nGloomlet Bow, Moonkip Wand/Orb:25 new native-reviewed contracts;108 selected stationary/action probes81→0 reference fallback incidents.15 new bodies,15 grip layers,25 sidecars;55 new physical artist files fulfil75 requested file requirements with20 verified reuse references. Compact single-find rewards and unchanged connected purchase/Spinner/combat/return routes verified in source and actual exported Windows PCK.3,058 contracts /8,001 file requirements remain. [Current report](quality-evidence/0.4.43/REPORT.md). Full animation continuity and physical Android/perceptual audio/professional acceptance remain open.\n\n## Previous — 0.4.42 cohesive item-card continuation')
    current.write_text(text,encoding='utf-8')
    print('Final report, current dashboard evidence, handoff and build hashes recorded')
if __name__=='__main__':main()
