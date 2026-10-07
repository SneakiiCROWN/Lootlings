# Owner-authorized completion sprint â€” v40 checkpoint

2026-10-07. **GO for an S23 owner test; HOLD for launch/Phase4E acceptance.** This is an implemented, backed-up checkpoint, not a declaration that every launch feature or art state is final. The owner's completion authorization supersedes the old Phase4E-only sequencing; it does not approve substitute art. The existing approved-source integration is preserved.

Implementation checkpoints: `59e7dbb97b43795b3bdaf59516b965aee3c33cbb` (Home/companion shell, semantic validation and transaction recovery), followed by `1fe1fbe4cb857ad72b5634b6742a26436436e753` (canonical title ensemble and companion canvas/pivot). then `8cc29d8738bf60578f08a1da64ae7444de94927c` (six companion previews and separate personal Home scene). QA/report SHA is the separate following commit containing this report. [Native gallery](GALLERY.md), [QA evidence](qa/results-index.json), [owner authorization](OWNER_AUTHORIZATION.md).

## Actual implementation and measured baseline

The previous sequential Home saves could persist purchased item ownership while leaving the same offer available after a process kill. The reproduced unsafe control is retained in `qa/completion-process-death-a45341619f/economy-baseline-restart.log`. The new fixed-path write-ahead journal records currency, inventory, shop and contract target snapshots together, validates all sections and SHA-256 values before writing, then replays the same intended generation after restart. Startup recovers before loading stores. Pause persistence cannot overwrite a pending failed transaction.

Actual OS-kill validation covers eight material/item/mastery/blueprint boundaries plus four journal destination boundaries. Each corrected case passes two cold restarts with no duplicate delivery; the unsafe sequential control remains demonstrably unsafe. This is **12 corrected cases + one baseline, 26 cold restarts**, not 13 newly fixed gameplay scenarios. Pre-journal disk failure restores the live wallet, inventory, offers and unclaimed contract record. Invalid journal contents are retained and block writes instead of overwriting saves.

Malformed paid-cache and spinner reservations are retained for review. They disable subsequent relevant purchases/claims until resolved; no silent replacement or charge. Profile schema 4 adds Home/companion preferences while retaining valid UUID, actor identity, memories, counters and metadata. Typed semantic checks cover profile, audio settings, shop stock and contract progress. Valid prior saves are not wiped. Backup/corrupt fixture diagnostics are expected only in their isolated tests.

Main Hub now opens a separate `personal_home.tscn` personal area, using the accepted painted private-storage interior. Leave/Back returns to Main Hub; private character/style and Stash flows return to the personal area. Established Hub NPCs and public stations stay in the Hub. Native review caught stale combat rendering beneath the private room; the render guard and transition redraw now clear it. Home now has four free, persisted display choices: equipped weapon, recovered plans, trophy stand and clear shelf. The accepted painted Contract banner replaces the flat board drawing. Back returns to the personal Home area; taps remain isolated from combat. A one-slot cosmetic companion shell supports saved ownership/equip, approved-export availability, bounded Home following and idle/move/reaction selection. It has no stats, costs, combat RNG or collision dependency. **The supplied companion manifest now approves Auricub, Stonekith, Pixrask, Lunarwisp, Puffnest and Breezewyn. Twelve original-pixel portrait/unlock-item crops are installed in the collection UI. All body equip gates remain closed because complete authored transparent state/view exports do not exist. No visible following companion is claimed complete.** Expedition accompanying remains optional and absent.

Title branding now represents all seven Lootlings using existing canonical portraits. A native review caught the large Relic Beast atlas expanding its portrait Control; expansion is now configured before texture assignment, with a native 52Ã—52 bound regression. The final phone/tablet captures show the corrected layout. Companion texture dimensions and the authored 128,224 pivot are enforced. No source image was redesigned or replaced.

## Coverage by system

| Area | Current delivered status / exact remaining issue |
|---|---|
| Gameplay / balance / economy / RNG | Existing run, combat, progression, event and reward mechanics preserved. No damage, attack timing, price, odds or difficulty tuning. New work changes persistence and free cosmetic presentation only. Actual offer/cache/contract tests verify one debit/delivery/payout. |
| Regions | Existing Act I three routes and nine later region IDs, departure/arena/dungeon/Archive hooks preserved. No region renamed or merged. Regional action art remains in the exact queue; this pass does not call every regional encounter visually final. |
| Playable roster | Seven Lootlings and five Wanderers remain selectable with dedicated-sheet identities and accepted poses. Title ensemble is newly wired. No new canonical body exports this sprint; absent actions/facings/supports remain TEMP. |
| Enemies / elites / minibosses / bosses | Existing encounter mechanics and 35 approved missing-source references preserved. Fen Sneak right-idle export remains the only runtime closure from the prior approval batch. Hoard Dragon single-tail source repair is still open; no crop/squash concealment. |
| Residents / merchant | Patch, Ilex and Sera identities, dialogue and routes preserved; current Pack Peddler/Merrow role unchanged. Contract banner improved. Required activity bodies still need authored exports. No concept-only NPC promoted. |
| Weapons / gear / relics / runes / spells / loot | All twelve families, accepted weapon/module art, current inventories/Forge/Stash/cards preserved. Known Glimmerfin Staff contact issue and 165 authored support packages remain. No idle art used to pretend an absent attack exists. |
| Chests | Existing implemented families/cache mechanics preserved and transaction safety improved. Optional `cursed_coffer`, `mimic_husk`, `starfall_vault` records remain planned, not claimed live. Owner authorization says these may be implemented if safe; this checkpoint does not alter their economy or add a second reward mechanic. |
| Home / customization | Separate personal Home contains character/style, private Stash, companion collection and saved personal displays. Hub keeps Forge, machine, Notes/Archive, contracts and NPCs. New free display selection and painted public board integrated. Existing cosmetic layer requirements remain separate; no tint substitute presented as canonical outfit art. |
| Companion | Bounded shell, six approved identities, collection previews, exact unlock-item IDs and idempotent saved unlock hooks implemented. Thirty-six body/state exports remain external blockers; no pet stat advantage. Unlock acquisition/drop/crafting schedule is not invented from a concept board. |
| HUD / menus / touch | Native phone/tablet Home, Back, mode navigation, purchase/current-new/Keep flows, scrolling and dedicated ATTACK regressions pass. Existing safe-area/touch safeguards retained. Device cutout, gesture navigation and real performance still need S23. |
| Relic Machine / rewards | Existing machine materials, earned-free-spin entitlements, Later/claim safety and six rarity presentations preserved and recaptured. Forced Common through RED previews are clearly labeled; actual earned spin separately captured. Reward odds unchanged. Final premium feel remains owner acceptance. |
| VFX / SFX / music | Existing material/species/elemental/impact cues and 456 provenanced PCM assets preserved in the APK. This sprint did not create new final music or claim perceptual mastering acceptance from peak/clipping tests. Final listening/mix acceptance remains open. |
| Branding / loading | Accepted launcher resources and branded splash verified inside actual APK; default engine splash differs from output. Seven canonical faces added to title. No new artificial loading delay. |

## Companion reference integration

The two supplied boards and `COMPANION_CANON_MANIFEST.json` are registered only for companions. Identity source: `art/reference/canonical/companions/Lootlings_Companion_Collection_Canonical.png`; UI/unlock guidance: `Lootlings_Companion_Implementation_Pack_Canonical.png` in the same folder. Board hashes and original crop bytes are guarded by `tools/validate_companion_art.py`. Exact PNG destinations: `art/production/companions/previews/{auricub,stonekith,pixrask,lunarwisp,puffnest,breezewyn}_{portrait,unlock}.png`. Their `manifest.json` records source rectangles, hashes and zero state closures. No playable or enemy identity is overridden.

The named unlock items are Sunfeather Relic, Terrastone Core, Shadowflame Ember, Moonlantern Shard, Bloomnest Seed and Skybell Orbit. `ProfileStore.grant_companion_unlock` saves one ownership entry idempotently even while body exports are missing; invalid IDs fail. Missing frames cannot be equipped. These hooks do not award items spontaneously or change chest/drop odds; an exact authored acquisition contract remains to be supplied before putting these unlocks in reward pools. The consolidated supplemental art queue now contains 36 named runtime cells, not an unknown invented pet.

QA also caught an overly strict binary-float equality assertion for a rare affix after ConfigFile decimal serialization. The fixture now compares float values within 1e-12 while all IDs, serials, counts and integer currencies remain exact; no production balance or inventory behavior was changed to pass it.

## Honest art accounting

Twelve companion UI-only crops extracted; no canonical runtime-body/state closure in this sprint. Previous accepted original-pixel exports: **125 â†’ 125**, plus the separately registered Fen Sneak delivery. Existing missing art: **3,050 â†’ 3,050** (**2,313 playable + 737 other**), **106 â†’ 106 body/view bundles**, **165 â†’ 165 support packages**. Approved missing-source subset: **593 â†’ 593** high-resolution cells. Zero LIVE_FINAL; TEMP support/body states were not relabeled to reduce debt.

Existing assets newly reused by this code checkpoint: seven canonical title portraits, painted private-storage interior, Contract banner, recipe scroll and trophy dais. These are new runtime routes to accepted assets, not new authored images. The generated index has 7,028 records / 6,223 launch slots / 3,173 launch LIVE_BETA, not a final-quality acceptance count.

Use the existing consolidated [NEEDS_NEW_CANON_EXPORT.json](../NEEDS_NEW_CANON_EXPORT.json) for all exact delivery contracts, and [HIGH_RES_RUNTIME_GENERATION_QUEUE.json](../phase4e/HIGH_RES_RUNTIME_GENERATION_QUEUE.json) for the 593 approved-source state/view requests. Known priorities remain Relic Beast unsupported states/families, Moonkip weaponless paws, Glimmerfin Staff support, original Hoard Dragon continuous-tail repair, opposite/hurt/recovery/support layers, Wanderer actions and distinct regional/boss/NPC activity frames. Identity sources, canvases, baselines, pivots, hand/socket layers and forbidden mirrors remain explicit in those files.

The same consolidated file now carries a supplemental companion requirement: one owner-approved identity, six `idle/move/reaction Ã— right/left` transparent 256Ã—256 PNGs, occupied bounds 32,24â€“224,224, baseline 224, pivot 128,224, uniform 56Ã—56 presentation, separate shadow/FX, no hand/weapon sockets, no implicit mirroring. Source: `art/source/companions/{approved_id}/`; runtime: `art/production/companions/{approved_id}/`; filenames `{approved_id}_{state}_{facing}.png`. These 36 supplemental slots are **not** silently added to the historical 3,050 actor-cell count.

## Validation and limits

Twelve regression fixtures pass: profile/economy, contract, touch gestures, Phase4/4B, reward restart, visible flows, save/lifecycle, backup/corrupt recovery, wardrobe and weapon-fit. Final profile/economy rerun passes after final source changes; injected pre-stage failure passes. Weapon-fit passes 144 combinations / 864 transform checks, while still reporting **82 right + 83 left authored support debts and one unresolved right contact**. A transform pass is not an authored-art pass.

Native desktop review: 1080Ã—2340 phone and 1200Ã—1920 tablet Home/title; final extended portrait flow covers residents, routes, dungeon/Siege, comparisons, real ATTACK, rewards and all six rarity reel/anticipation/reveal/settled previews. All 70 retained native images are full-resolution in the [gallery](GALLERY.md). These do not prove S23 FPS, thermal behavior, memory, touch latency or cutout correctness.

Current Godot documentation confirms mobile processes may be killed while suspended, so shutdown callbacks alone cannot guarantee purchase persistence. The implementation records/replays intent rather than relying on an exit notification. See [Godot mobile quit behavior](https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html). [ConfigFile documentation](https://docs.godotengine.org/en/stable/classes/class_configfile.html) defines Variant serialization and explicit save semantics; application-level semantic checks and cross-store recovery are project requirements, not guarantees claimed from that class.

No Android device is connected. Desktop OS-kill and lifecycle fixtures close the tested repository-side persistence defects; Android process death/power interruption, storage/fsync behavior and upgrade using the actual owner save remain physical-device gates. **Active runs are not snapshotted for cold restart**: killing the app returns to the Hub with permanent progress and durable pending rewards; do not interpret the recovery tests as active-run resume acceptance.

## Android delivery and smallest S23 test

`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-completion-home-debug.apk`

Version code **40**, `0.4.31-completion-home`. Size **148,091,598 bytes (141.23 MiB)**; SHA-256 `84e425b1bf65fa708103cbd041096c08c0cd5ce023562984e12dc57687a697ea`. Signed debug arm64, SDK24/36, 16-KiB alignment, no Android permissions. Imported canonical assets match local imports; production source/reference/test dumps are excluded. [Build receipt](qa/APK_RECEIPT.json), [actual branding verification](qa/ANDROID_BRANDING.json). This is an owner-test debug build, not a store release artifact.

1. Install this APK over the existing app. Keep its data; do not uninstall or clear storage. Confirm your actor, permanent currency, equipment and settings survive the upgrade.
2. Home â†’ YOUR HOME: change the shelf, return, background/resume, then force-stop/reopen. Confirm the choice persists and no menu tap attacks. Browse all six companion/item previews and swipe the collection; no following companion should appear yet.
3. Make one normal affordable merchant/cache purchase; note currency and item/reward, then force-stop/reopen. Confirm one charge and one reward. Play a short run with ATTACK, scrolling, Back and one earned machine reward; check sound weight/readability and resume. Cold restart may return to the Hub. Report clipping, unexpected charges/rewards, touch leaks, stutters/heat or missing saves.

Remaining gates: exact authored art; owner visual/audio acceptance; physical S23 performance/lifecycle/input/save-upgrade checks; release signing/store delivery. Optional planned chest/future content is explicitly not newly delivered. No broad re-audit or new canon reinterpretation is needed to resume.

## Multidisciplinary sign-off

| Discipline | Sign-off |
|---|---|
| DESIGN | Issues: bounded cosmetic/persistence scope works; full visual launch acceptance open. |
| BALANCE | Pass for unchanged values/timing; no new difficulty claim. |
| ECONOMY | Issues: tested one-charge/payout/restart semantics pass; physical storage acceptance open. |
| ROSTER | Issues: authored action/facing/support debt and TEMP bodies. |
| ENEMIES | Issues: remaining distinct authored state art. |
| BOSSES | Issues: state art and Hoard Dragon tail source. |
| RNG | Pass for unchanged odds/seed behavior; no tuning to force wins. |
| UI/UX | Issues: scoped native flows pass; final owner/device acceptance pending. |
| NARRATIVE | Pass for preserved canonical identities, regions and voices; no new dialogue canon invented. |
| AUDIO | Issues: final listening/mastering acceptance and proper final music where absent. |
| MOBILE | Issues: native layouts/export pass, physical S23 tests outstanding. |
| QA | Issues: recorded automation/native scope passes; device/art/full launch acceptance open. |
| PRODUCTION | Issues: backed-up implementation/build/evidence ready; full completion remains HOLD. |

Tracked source/evidence checkpoint is clean after the separate QA commit. With owner authorization, 47 missing registered source files were restored as compatibility copies at their original paths; relocated copies remain intact. Untracked owner reference duplicates and source-pack/archive files are preserved; the repository is not described as globally empty of untracked files. Remote SHA verification is performed after pushing that QA commit.
