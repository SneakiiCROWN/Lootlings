# Combat family pass — original winged Hoard Dragon / 0.4.36

The explicit owner correction restores the original winged, four-legged Hoard Dragon. Its dedicated source is `art/reference/canonical/characters/01_Hoard_Dragon_Canonical_Reference.png` (SHA-256 `a1689ad8254ff269b0afdc7f63a6fe5514893c709918a0e3f741fe70b3091301`). The original obsidian scales, purple membranes/crystal spine, gold accents, face and continuous tail control the implementation. Previous wingless/coiled registry decisions are superseded. The old runtime PNG is retained unchanged for recovery and unrelated existing proxy routes; Act I now uses the restored identity exclusively.

## Installed in the actual game

- **12 boss cells / 24 artist files**: idle, CLAWS windup, CLAWS strike, hurt, recovery and defeat, each with independently authored left and right facings. Twelve PNGs plus twelve JSON sidecars. They use the existing attack clocks, damage and defeat systems.
- Source pixel alpha and proportions retained. Each body has transparent 2048 padding; actual painted detail is recorded separately in `content_rect`. Canvas padding is not higher-resolution art. Exact alpha-component bounds exclude neighbouring sheet pixels. No reference-board crops or flipped bodies are installed.
- All twelve weapon families now create bounded material and critical contact effects at the actor actually struck, including pack target changes. Melee contact runs from the real weapon socket to the hit point. Incoming hits show a restrained direction/contact effect.
- Ward absorption shows Ward loss without a misleading zero-damage number or full hit shake. Feet remain planted during recoil and scaling, with per-frame atlas foot caching. Grounded bodies no longer bob vertically; hover effects remain purpose-specific. Defeat preserves body proportions and settles rather than swelling/flying.
- Fen Sneak retains its exact accepted neutral identity through unsupported action states on its supported facing. This is openly reused idle, not a new attack or opposite-facing closure.

No new playable, Wanderer, normal-enemy, NPC, companion, Home or weapon-body art closures are claimed in this batch. The shared presentation changes apply beyond the twelve new boss cells. Approved title audio, branding, Home/Hub interactions, companions, gameplay, reward amounts and owner saves are preserved.

## Validation

Source regression: `winged-combat-integrated-757a9ebf4d`, six fixtures passed: boss routing, shared combat, staging, actual weapon fit, rewards and save compatibility. Native shared combat/gameplay: `winged-combat-final-native-1c91d51f08`, both fixtures passed. Twelve actual weapon attacks resolve; pinned pack impacts, six boss attack calls, Ward and reduced motion were exercised. Combat, rewards, perk selection, result payout once, stash, merchant, Forge and natural Hub return were checked.

Original identity and all twelve body states were visually compared with the dedicated source, then reviewed in native Godot at 1080×2340, 1200×1920 and 1920×1080. Source frame review `winged-dragon-accepted-pixels-050331b3a7` passed. The compiled 0.4.36 pack was independently reviewed using the external fixture: both facings, six poses, actual CLAWS-to-recovery transition and unchanged unrelated boss route passed. The capture helper explicitly redraws each frozen review state. First stale compiled captures were discarded as evidence; the saved gallery is the corrected rendered capture set.

Compiled full gameplay and world owner routes also passed at all three sizes: title controls, direct Hub stations, separate Home, companion gates, input isolation and existing gameplay/reward/stash/shop/Forge controls. Canon, matrix and source-hash validators passed. APK inspection verifies every boss import and sidecar matches installed reviewed files, and the title imported payload matches the exact approved track. Actual Android launcher/adaptive/monochrome/splash and Windows executable icon resources passed comparison with approved branding.

## Rejected / still outstanding

Six wingless candidate frames are quarantined together and never route. Previously rejected winged frames were reconsidered under the owner's explicit restored canon, not redesigned again. Export separation defects were corrected in one batch. No accepted old art was deleted.

Missing Hoard Dragon named attack art: BRACE, COIN BREATH and TAIL SWEEP, plus phase-transition/vulnerability contracts. These retain exact-facing canonical idle with the existing separate effects, and stay outstanding. Sparse six-state key poses do not represent full high-frame-rate articulation. Normal enemies and other regional bosses still need their contracted body/action families. The opposite-facing Relic Beast wand neutral shown in the right-facing boss QA remains explicitly `POSE ART PENDING`; it is not hidden or counted complete.

Exact master totals are now **108 installed contracts / 253 artist files**, with **3,166 contracts / 8,242 required artist files remaining**: playable 1,421; Wanderers 855; normal enemies 323; bosses 356; NPCs 46; support 165. These exclude existing retained art, menu, soundtrack and the separately installed Armour inventory icons. Exact remaining items are in `EXACT_REMAINING_CONTRACTS.json`.

## Candidate

Version `0.4.36-winged-combat`, Android code 45. Desktop: `builds/windows/Lootlings-0.4.36-winged-combat.exe` with its adjacent `.pck`. Android: `builds/android/Lootlings-0.4.36-winged-combat-debug.apk`. This is a tested desktop/native and inspected debug APK candidate; physical S23 launcher, touch, audio and device performance validation remain pending. No full game or store-ready completion claim.

Next broad family pass: missing normal-enemy/boss action families and remaining real weapon pose/contact coverage, preserving the same exact authority and independent acceptance process.

Authoring used built-in ImageGen. Final prompt set and retained source sheets: `art/source/continuous_combat/hoard_dragon/`; exact changed files: `COMBAT_CHANGED_FILES.txt`.
