# Pre-device correction record — 2026-10-04

Started clean on `codex/phase2-vertical-slice` at `d073dd6`. Prior gameplay checkpoints `68162a1` and `af69ed4`, frozen pre-Phase-3 baseline `bca361c`, approved art, mobile/save protections and licensing remain intact. Exact owner instructions are in BRIEF.md; the multidisciplinary standard remains in ../TEAM_WORKFLOW.md.

## Reproduced problems and decisions

| Problem | Baseline evidence | Implemented correction | Keep criteria |
|---|---|---|---|
| Normal reward acquisition lacks an opportunity cost | Ordinary wave finds queued every item; a bounded isolated merchant fixture purchased six items in one visit because stock regenerated | Multiple wave finds offer one selection, remainder forfeited; merchant permits one purchase and closes after disposition | No second acquisition, charge or restock; fresh visit resets; genuine boss hoard retains three Epic+ options; native consequence readable |
| Reroll competes poorly with buying | Phase 3 first-stop median held 181 Scrip, cheapest 94; old first reroll 91, so reroll plus cheapest purchase requires 185 | First reroll 36 at wave 6 / 51 at wave 11; subsequent rerolls rise by 18; family preference survives reroll | Preserve gear prices, income, rarity and difficulty; expose spending/remaining-money distributions; reroll can consume scarce funds without yielding a guaranteed improvement |
| Parseable malformed saves can enter rendering/effect paths | Disposable mixed stash retained three entries including a string and invalid effects; invalid equipped data could reach UI | Validate record type/slot/effect shape and finite values; safe integer parsing for affected meta/inventory fields | Invalid records ignored in memory, original source untouched on load; valid rolled/evolved stats survive exactly; fallback starter; backup recovery still works |
| Unbounded local diagnostics / stale prototype renderers | Diagnostic JSONL had no cap; procedural renderer entry points had no callers; merchant texture wrapper unused in production | 256 KiB current log plus one previous file, discard oversize entry; remove proven uncalled renderer blocks/helper | Privacy filter unchanged, two rotations safe, active rendering functions unchanged, scene cleanup bounded |
| Important confirmation terms below fold / small Pause target | Settled native tablet capture of long signature item put purchase restriction below fold; Pause 86×42 design units | Cost/consequence precede scrollable effects; Pause 86×64; device-neutral report title | Native phone/tablet confirmation visible, actual touch has no attack leak, existing swipe handling preserved |

The reroll values are project-specific decisions derived from observed affordability, not borrowed game values or an invented industry rule. Android recommends roughly 48dp touch targets; design units are not physical dp until handset density/layout is checked. [Android guidance](https://developer.android.com/guide/topics/ui/accessibility/views/apps-views). Godot resource cache reuse and rename-overwrite semantics were checked in [ResourceLoader](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html) and [DirAccess](https://docs.godotengine.org/en/stable/classes/class_diraccess.html); no speculative cache rewrite was needed.

## Reward-beat scope and deliberate exceptions

An earned level grants one of three upgrades. A normal wave offers at most one gear acquisition (single find needs no extra choice screen; multiple finds use the existing inspect/confirm panel). A merchant stop permits one purchase, with optional paid rerolls before selecting. A boss hoard is one of three Epic+ rewards. Equip/stash/scrap is disposition of the selected item, not another acquisition. An event is one consequence-bearing choice. XP-level rewards and a wave find can both occur because they are separate explicitly labelled earned beats. Paid persistent Hideout services/shop/cache transactions remain independent purchases, not run-wave reward bundles. No blanket confirmation was added to every wave.

## Evidence reuse and measurement boundary

`reuse.json` verifies unchanged catalogs, assets and retained renderer functions against `d073dd6`; existing stationary DPS/pressure labs, 2,592 native actor/weapon/state samples, species audio/provenance and unchanged world/dialogue evidence are retained. Parser/package/reference checks are fresh. Whole-run 512-row paired measurements plus six reproducibility replays, 192 active roster and 96 idle samples are rerun because equipment/reward choices changed. Idle is diagnostic breadth, not a balance target. The original 2/5 combat smoke used an invalid harness; corrected isolated tests and per-run policies supersede it. No damage/HP/cadence nerf was made to force wins.

Focused fixes passed reward/save/recovery/smoke, runtime cleanup, actual merchant thumbnail and weapon-fit contracts before the one broad final acceptance run. Native fixtures use real Godot rendering, real-clock scripted combat and synthetic touch; they cannot establish human fun, subjective listening or physical-phone acceptance.

## Open gates preserved

Missing authored support-hand/paired poses (82 right / 83 left combinations), weaponless Moonkip, unique regional boss/miniboss bodies/animations, eight provisional music tracks. Physical S23/S24 touch, safe areas, speaker feel, heat/frame pacing, Android lifecycle and human play judgment remain gates. Committed saves have recovery coverage, but live runs are not resumable after process death and eight stores are not a cross-store atomic transaction. Limited bot policies do not establish long-term veteran progression or a dominant strategy across all human choices.
