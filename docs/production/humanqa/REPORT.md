# S23 human playtest follow-up — 2026-10-04

Focused implementation from clean `fccd15b` on `codex/phase2-vertical-slice`. The owner’s reviewed recordings supplied the baseline player problems; this pass preserves prior work and does not claim a fresh physical playtest. [Exact brief](BRIEF.md). Implementation/checkpoint identity is recorded in DELIVERY.md.

## Changes retained after review

- Physical Hideout art remains intact. Begin Expedition has the gold primary treatment; secondary destinations retain large transparent touch targets. Loadout is collapsed until inspected. Automatic arrival/idle dialogue is suppressed; selected residents still speak. Ambient artwork/animation remains.
- Combat retains readable HP/Ward, XP/level, Scrip, wave and enemy status. A lighter header replaces its ornamental frame. Core/build detail stays in Pause; the permanent lower ribbon is removed. The empty opaque lower block is cleared to expose the existing backdrop. Combo is a small indicator; routine execute “YEET!” is removed. Proc/DOT feedback uses an existing Core icon, with visible elemental/status chips preserved. Floating labels have three total slots and one per lane; particles per emission and impact wash are reduced. Combat formulas, timing, HP and enemy damage remain unchanged.
- Ordinary upgrade cards select/highlight, then a gold TAKE footer applies the choice. Merchant cards select/highlight and show inline effects, then BUY [cost] — ENDS THIS STOP. Neither opens another ordinary confirmation screen. A 180 ms selection debounce rejects immediate repeat taps. New offers clear selection; state/purchase guards still prevent repeated payment. Destructive/equipment-overwrite and paid-reroll confirmations remain. Boss/wave-find confirmation is unchanged; this focused change addresses ordinary upgrade and merchant flow.
- Primary/selected choices use existing gold artwork, secondary navigation uses simpler blue, utility controls use a thin border, scrap/destruction remains red. Stall gear offers keep the prominent upper row; cache/expansion controls are quieter and their previously expanded widths are explicitly restored so they do not overlap.
- Memory Archive says “revisit this echo,” with no exposed duration. Support ID moved from Profile into Settings → Support. Reopening Settings closes the Support overlay.
- Wave-11 third stock lane guarantees Epic+ gear, marked PREMIUM. Early prices/income/rerolls remain intact. The guaranteed premium lane adds 90 Scrip to the normal rarity/wave price: normally Epic 341 or Legendary 476 at Wave 11, with the existing occasional 15% discount. Ordinary randomly rolled Epic gear remains at its ordinary price. Two Wave-12 events offer explicit paid Epic+ alternatives: locksmith 220 without HP loss; debt buyout 280 without a curse. Original risk choices and Skip remain available.
- Music player gain rises from +1 to +4 dB. Weapon families trim 3 dB, impact families 4 dB, other events 2 dB; ambience remains at its existing gain. Saved sliders/mutes and authored species banks are preserved. Music ducking returns to the new gain. Master ceiling is -1.5 dB. No sound/art assets or source/license manifests were replaced.

## Economy: baseline, proposal, comparison, decision

The focused harness extends the existing valid fresh-scene simulator. Twelve fixed seeds × three policies = 36 runs per comparison, Act I starter greatsword/Relic Beast/sustain/tap. Policies: cheapest affordable; skip first shop/save for highest affordable later offer; up to two affordable rerolls with a reserve, buy highest affordable and take paid event opportunities. Gear disposition preserves the starter weapon, equips suitable non-weapon finds and scraps alternatives. This is a bounded policy comparison, not human optimization or roster-wide difficulty acceptance.

Each merchant records wallet, stock/prices, price/wallet, action and rerolls. Each event records wallet, ID and action. [Observed runs](baseline/runs.json), [final runs](final/runs.json), [baseline distributions](baseline/summary.json), [final distributions](final/summary.json) and event ledgers retain per-run variation. Event costs/ratios are reconstructed from the corresponding frozen/final catalog and labeled as such. Existing income formulas and early merchant wallets are unchanged; later earned totals can differ because gear, reward RNG and duration differ.

| Policy | Median spent %, before → after | Median unused Scrip, before → after | Median Wave-11 premium/wallet ratio, before → after |
|---|---:|---:|---:|
| Cheapest | 21.0 → 21.6 | 815.5 → 782.5 | .439 → .821 |
| Save | 17.3 → 30.1 | 834.5 → 726 | .364 → .695 |
| Reroll/events | 40.8 → 39.4 | 606 → 629 | .529 → .933 |

Early median wallets are 180.5 (cheap/save) and 170.5 (paid-event policy); Wave-6 price/wallet distributions match the baseline. Final later wallets are 395.5 / 479 / 334.5. There were 14 rerolls in both search cohorts. All 36 baseline and 36 final runs finished with wins under this sustain/tap policy; wins were not a target and no difficulty parameter was lowered. Cheap-policy median completion 128.125 → 128.425 seconds; save 128.125 → 128.000; search 124.000 → 122.900. Damage/min-HP distributions are retained, not reduced to a pass quota.

First candidate guaranteed a premium lane at ordinary prices. It improved save-policy median spending only to 22.2%; cheap purchases plus rerolls still comfortably covered it. The 90-Scrip premium was then measured separately. Retain it because skipping early purchases now preserves a meaningful premium/reroll reserve, while early cheap options and risk alternatives remain affordable. Search can spend its reserve and miss the premium; its lower final spend percentage is an observed policy consequence, not hidden as an improvement. The premium is guaranteed stock access, not a new effect or invented gear tier.

Unspent end-run Scrip remains substantial, especially after the final scheduled shop. This pass does not invent mandatory spending or drain earned money to eliminate that number. Human decisions, perceived premium value, progression breadth and long-term economy remain acceptance issues. Two late paid event alternatives are narrow additions; their native transaction checks prove cost/rarity/risk, not player preference or deep replayability.

## Audio comparison and fact-checking

The original supplied approximate LUFS values cannot prove equal phone recording volume. Native Master-bus capture at identical saved defaults demonstrated a game-side contribution. Preliminary capture filled its buffer; it is superseded by continuously drained captures with zero discarded frames. The complete baseline reconstruction uses the unchanged banks and only restores old music/event gains and limiter ceiling inside the isolated fixture; it does not reset the project. [Raw comparison](audio.json).

| Context | RMS dBFS, before → after | Peak dBFS, before → after |
|---|---:|---:|
| Title | -35.52 → -33.39 | -6.24 → -8.37 |
| Hideout | -35.74 → -33.46 | -18.37 → -16.15 |
| Scripted combat | -24.93 → -27.72 | -.80 → -2.54 |

Quiet hub/combat RMS separation narrows from 10.81 to 5.74 dB, with more combat peak headroom. Retain the modest family trims and music gain; do not replace timbre to solve level. This is RMS/peak diagnostic evidence, **not LUFS, true-peak certification or subjective listening**. The Windows capture API returned roughly 32 seconds of PCM frames during an eight-second wall-clock interval; both comparisons retain the same backend/collection method and expose frame/rate counts. Treat those files as relative diagnostic streams, not duration-calibrated playback references. Phone recording gain and final creature/music acceptance still need equal-volume human listening.

Checked current official [AudioEffectCapture documentation](https://docs.godotengine.org/en/stable/classes/class_audioeffectcapture.html) for bus sampling, buffering/discard accounting and float PCM. Checked [AudioEffectLimiter documentation](https://docs.godotengine.org/en/stable/classes/class_audioeffectlimiter.html): the existing soft limiter is deprecated in favor of HardLimiter. Preserve the working mixer here; a limiter migration needs its own comparison rather than an unrelated rewrite. No external design convention or copied game values were used to set prices.

## Focused acceptance

[Accepted logs/results](qa-results.json), [phone contact sheet](1080x2316-native.jpg), [tablet contact sheet](1600x2560-native.jpg). Full-resolution images remain in `.godot_test_data/humanqa/{1080x2316,1600x2560}`.

- Native Godot rendering reviewed: quiet hub, selected resident, combat/proc feedback, upgrade selection/footer, merchant inline detail/footer, Stall, Memory Archive, Profile, Settings/Support and both paid late events. Actual Window ScreenTouch events validate selection, immediate repeat-tap blocking and UI attack isolation. These are scripted desktop-native fixtures at handset/tablet render sizes, not manual handset play.
- All 22 size/cutout scenarios pass with fresh scenes, including ordinary reward and new merchant touch paths. Utilities have explicit non-overlap assertions. Support ID is hidden from Profile and visible in Support; Settings reentry closes it.
- Reroll/skip before purchase, next-visit reset, one purchase maximum, repeat calls/rapid taps, no duplicate charge, stop resolution and playing-state resumption pass. Paid events guard repeat selection and produce Epic+ with no unintended curse. Save recovery and full-stash/destruction protections pass with expected corrupt-fixture diagnostics retained. No player save was used.
- Native audio bank/mix QA passes: twelve weapon hooks, thirty sound families, 329 current PCM assets and preserved license manifests. Unchanged actor/weapon/pose/canonical-art coverage is reused with [path proof](reuse.json); no expensive pose/roster matrix was repeated.
- Ten-second native desktop real-clock watch: ~60.1 FPS, combat p95 17 ms, p99 30 ms, four frames >33 ms; at most two floating labels and 38 particles. Window is OS-clamped on the desktop; these numbers do not certify an S23-sized physical surface or compare handset thermals. Supplied earlier S23 timing is preserved as historical human evidence.
- Android: version 7 / `0.2.2-humanqa`, signed arm64 debug, minimum SDK 24, target 36, 16 KiB ZIP alignment, offline/no permissions, current imported pose/bow hashes and audio/license checks. [Final package verification](android-build.json). Update over the existing app to retain persistence; do not uninstall.

## Remaining gates and smallest physical retest

APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-humanqa-debug.apk`.

1. Install as an update. At one fixed device volume, compare title/hub and a combat minute; check music/creature identity and harsh overlap. Check quiet hub, collapsed Loadout, Stall/Archive and Settings → Support.
2. Play one Act I run: select a Pick One card then TAKE; at a merchant select, reroll/skip before purchase if desired, then BUY once. Check no second confirmation, repeat-tap charge or combat attack from UI. Compare buying early versus saving for the Wave-11 premium.
3. Background/resume during combat and a choice, finish/reopen and confirm persistent rewards/settings. Note heat/frame hitches after sustained play. Spot-check a bow and one alternate character not covered by your footage. Repeat physical gates on S24 when available.

Known authored debt is unchanged: 82 right/83 left support-hand or paired combinations, weaponless Moonkip, regional boss/miniboss bodies (nine minibosses reuse Grump Knight), eight provisional music tracks. No atomic cross-store transaction or persisted live-run restoration is newly implemented. Physical listening, thermals/lifecycle, alternate-character/bow coverage, premium utility and long-term human decisions remain open.

## Multidisciplinary sign-off (whole-phase scope)

| Discipline | Status | Remaining acceptance issue |
|---|---|---|
| DESIGN | ISSUES | Focused flow implemented; human premium/decision feel pending. |
| BALANCE | ISSUES | Matched distributions retained; no broad human/roster difficulty claim. |
| ECONOMY | ISSUES | Later choice tension improved; substantial end-wallet and long-term sinks remain. |
| ROSTER | ISSUES | Canonical paired/support-hand/Moonkip art; physical alternate-character review. |
| ENEMIES | ISSUES | Existing authored-body/encounter coverage gates preserved. |
| BOSSES | ISSUES | Regional/miniboss canonical bodies and physical acceptance remain. |
| RNG | ISSUES | Focused seeded policies pass; broader human strategy preference remains. |
| UI/UX | ISSUES | Native changed screens/touch pass; real handset flow acceptance pending. |
| NARRATIVE | ISSUES | Changed echo/support copy reviewed; broader human canon/voice acceptance remains. |
| AUDIO | ISSUES | Technical gain/bank checks pass; provisional music, backend capture qualification and listening gate. |
| MOBILE | ISSUES | Signed/aligned APK ready; S23/S24 listening/thermals/background gates pending. |
| QA | ISSUES | Focused regressions/native evidence pass; physical tests remain. |
| PRODUCTION | ISSUES | Focused candidate delivered; canonical art/music/physical gates prevent full-phase acceptance. |
