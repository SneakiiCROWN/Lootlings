# Phase 4E continued technical presentation checkpoint — 2026-10-05

**HOLD. Phase 4E is not accepted.** All existing work/checkpoints remain on `codex/phase4e-gamefeel`. The owner rejected the procedural combat bodies as canonical art; automated contact passes cannot override that decision. No reset, revert, main merge or Phase 4F.

## Visible and technical changes

Preserved follow-up `871ae53` and header correction `bfd7601`: target-facing rigs, exact two-hand/nock support, bounded polearm reach, paired sockets, resident activity, contextual dialogue, regional grounding, Furnace/Verdant intro continuity and 32 documented boss action cues. These mechanics remain useful. Their improvised body layers are **POSE/SOCKET/RIG PROTOTYPES ONLY**.

Latest implementation `8416727` plus `597486cc52a274a6b3d3ee58fc28465c7244a94a`:

- Original brass/obsidian Relic Engine framing replaces the basic panel with a bevelled aperture, mechanical plinth, gemstone header, engraved medallions and clear inward stop teeth. Existing clipped child reel remains. Rarity text has a dark plaque rather than sharing a bright bevel. Legendary uses larger matching medallions/gold flare; RED has a dominant central medallion, red crackle, hold/punch and crown treatment. All six tiers retained. Presentation is improved; premium subjective acceptance remains open.
- A hand-traced single blade from the existing painted `rogue_daggers.png` replaces the weak code-drawn dagger in each hand. Source hash, mask/rotation method and exact transformed grip are recorded beside the derivative. No whole pair duplicated, no new canonical weapon design. Larger readable blade presence, independent contacts and alternating forward slashes retained.
- Fixed an actual paired-claw bug: mirroring the rear gauntlet pointed its talons away from the target. Both claw axes now follow target-facing; dagger curvature can still mirror locally.
- Staff/wand charge accents attach to their real gem sockets. Orb charge connects palm to orb before release; a short directional release stroke follows the socket. Existing body anticipation/recoil and projectile-origin contracts remain.
- Removed unused body preloads; no texture quality reduction. This avoids needless ownership references and is not claimed as a measured memory saving because Godot caches shared resources.
- Source/QA status explicitly rejects procedural regional and boss bodies as canonical. Gloomlet's foxlike dummy is specifically unsuitable as a design reference. Hoard Dragon's source tail is explicitly marked unresolved; no squash/rotation is represented as a repair.

Stats, hitboxes, attack timing, sources/sinks, odds, prices, RED progress, saves, reward receipts and touch ownership were not retuned.

## Native review and regressions

- Full actor/weapon matrix: 1,728 native states, 24 sheets, all 12 actors/12 families/both facings/6 states. After the claw fix, a focused rerun captures 576 states for daggers/claws/staff/orb across all 12 actors and both facings. Sheets are labelled **FORCED FACING TEST** and do not claim real combat staging.
- Real target resolver/renderer: **60 captures**, 6 weapon families, both staging orders, player/enemy side crossing, wind-up/attack/hit/recovery; forced-facing flag zero. Crossing positions are QA-staged; the current game does not expose free lateral movement. The first log's hardcoded “20” is stale; its JSON and 60 image files are authoritative. Fixture logging is corrected.
- Native machine: all six tiers at rolling/anticipation/reveal, phone 1080×2340 and tablet 1600×2560. Final renders retain clipping and show a distinct larger RED center. Native review found and corrected lower-bevel text readability. No reward is granted by forced-tier preview.
- Native regional sweep: 27 named roles and skirmisher/tank/caster attack phases, Home/Gear/disabled spinner on phone/tablet. Technical grounding/contact improvements do not make prototype species canonical.
- Latest protection run `phase4e-final-connections-protections-785c419d0b`: mobile gestures, 1,152 contact/facing/state contracts (including both talon axes), spinner/Phase4E, one-delivery reward and save recovery all exit 0, no script errors.
- Latest native changed-family run `phase4e-final-connections-native-25d3e84586`: real facing, six-tier machine and changed-family matrix all exit 0, no script errors.
- Wider matrix `phase4e-canonical-connections-697f4bbeda`; regional/performance run `phase4e-connections-real-native-63b1b86191`. Logs and 70 curated full native images are committed separately from implementation. Original raw captures and earlier rejected runs remain preserved locally. The runner initially rejected the nonexistent name `mobile_ux_qa` before running anything; it was corrected to `mobile_gesture_qa`.

The preserved follow-up smoke is 4/5 isolated seeded wins; the failed run remains. It is not a new balance claim. Earlier 2/5 global-RNG/reused-state results were fixture reliability issues documented in Phase2 diagnostics; no difficulty was reduced to produce wins.

## Performance and audio limits

RTX 4080 SUPER / Compatibility, 90-frame samples: phone Home median/p95 16.666/16.687 ms; bow 16.665/16.699 ms. Tablet Home 16.666/16.685 ms; bow 16.666/16.761 ms. Texture counters 266–286 MB reflect the exercised native fixture/cache; they are not S23 resident-memory measurements. No physical-device FPS, thermals, rendering stability or memory certification.

Preserved native Master captures cover 39 weapon/material/Verdant/spinner/boss families and 30 actual boss actions. The 32 new boss cues retain four variants/family, CC0 source hashes and PCM imports. Technical headroom/execution is not perceptual approval; weapon weight, material distinction, species voices, repetition and Legendary/RED impact still need listening on real speakers. No audio quality claim rests only on clipping tests.

## Actual blockers

The [canonical replacement register](CANONICAL_REPLACEMENTS.md) lists all 12 actors, 27 regional roles, 10 boss identities and 3 residents, each with exact problem, identity/reference, required states and reusable contracts. Good existing heavy poses and Verdant/Furnace bodies are preserved. Programmer-generated bodies/attachments remain TEMP and cannot supply approved production anatomy or canonical redesigns.

**Hoard Dragon tail remains malformed in the source image.** Its branch/coil/taper requires a proper visual redraw preserving the gold-bound gemstone vault identity. Neither a transform nor a crude procedural/composite tail is accepted. Source evidence is included as `hoard_dragon_source_tail_UNRESOLVED.png`. Missing unique boss bodies, regional proxy replacements, Gloomlet/cast likeness and resident art are also genuine canonical-art-package dependencies. No full visual sign-off.

## Android and smallest S23 retest

Latest APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-connections-debug.apk`, version 15 / `0.4.6-phase4e-connections`, 137,126,412 bytes. SHA-256: 1eea4dd9d7f2c3580e47e3f09ebd384e9ba9dc953218b046b96b329834fd365a.

Verified export, signature, 16 KB alignment, arm64, minimum SDK24/target36, offline/no permissions, preserved bow/heavy imports and all 456 current source-documented PCM assets. ZIP integrity and exact local bytes of the new dagger/machine imports additionally checked. Previous v13/v14 candidates preserved. ADB sees no attached devices.

1. Install this APK **over the existing app**; do not uninstall/clear data. Confirm roster, gear and currencies survived.
2. Record a short fight using daggers/claws and a staff/orb, then one available Relic Engine spin. Check both held weapons, casting origin, readability, stop/result and sound weight. Do not grind for RED; all six tiers already have native forced-preview evidence.
3. Swipe Gear/menus, test Back/pause, background/resume and relaunch. Confirm no accidental attack/purchase, duplicate/lost reward, clipped HUD or changed inventory/currency. Report stutter/heat and speaker mix; known TEMP art/tail defects are already tracked.

## Multidisciplinary sign-off

| Discipline | Result | Evidence / open issue |
|---|---|---|
| DESIGN | ISSUES | Canonical presentation/feel blockers remain; mechanics retained. |
| BALANCE | PASS — unchanged scope | Prior measured distributions retained; no tuning to manufacture wins. |
| ECONOMY | PASS — unchanged scope | Save/reward/spinner protections; costs/odds/chase unchanged. |
| ROSTER | ISSUES | Contacts/facing pass; prototype bodies and Gloomlet likeness fail final art gate. |
| ENEMIES | ISSUES | Role/grounding reviewed; regional proxies/procedural species require canonical assets. |
| BOSSES | ISSUES | Verdant/Furnace continuity retained; dragon tail and unique body/state packages missing. |
| RNG | PASS — unchanged scope | Preview/presentation/gameplay/loot isolation preserved. |
| UI/UX | ISSUES | Six-tier framing/readability improved; S23 touch/readability acceptance pending. |
| NARRATIVE | PASS — scoped | Existing bank/canon eligibility and distinct Wanderer outcomes retained; no new canonical creature designs. |
| AUDIO | ISSUES | Technical routing/source evidence valid; perceptual/speaker mastering acceptance pending. |
| MOBILE | ISSUES | Version15 package verified; physical S23 tests not performed. |
| QA | ISSUES | Native/automated checks pass within scope; visible art/audio/device gates remain. |
| PRODUCTION | ISSUES | Safe separate checkpoints; full Phase4E acceptance HOLD. |

Drawing/transform semantics were checked against current official [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) and [custom drawing](https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html) documentation, then validated in installed Godot 4.7.2. No invented design standard, outside franchise design or copied balance values.
