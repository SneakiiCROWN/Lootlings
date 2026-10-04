# Phase 4C owner-review implementation and acceptance

Date: 2026-10-04. Baseline: `709e35f41ab74bee64bbb26d04b13a4175ccd587`. Branch: `codex/phase4c-presentation`. The owner physically tested Phase 4B on the S23 and rejected its visible presentation. This pass implements the requested rescue; native evidence supports an owner retest, not commercial release.

## VISIBLE CHANGES / HOME / HOMESTEAD

Home uses a 74-unit header, compact currencies and world-attached Gate, Gear, Shop and Jobs hints. Resident nameplates and the large dashboard action wall are removed. The selected actor stays large and its equipped weapon icon/name is visible. Loadout is a secondary, translucent toggle. Patch opens Forge, Sera opens Shrine, Ilex opens Archive; existing functional screens remain reachable.

NPC interaction is immediate: same resident closes, different resident replaces, empty space closes, role/menu transitions close, Back closes dialogue first. A compact bottom card contains portrait, name, short line, role action and close. It has no forced waiting timer. Native phone/tablet contacts verify these flows.

Life remains deliberately small: one resident has an active seven-second work/inspection/reading phase at a time, with slight movement/glint and matching contextual text; others rest. Existing warm lights and bounded micro-events remain. This is ambient staging of existing bodies, not authored tool-use animation. Future pet bed, trophy, weapon display, banner, hearth and shelf slots are a layout contract only; no unavailable decoration buttons or progression were added.

## CHARACTER SELECT

Two obvious 48-unit Lootlings/Wanderers tabs replace the breadcrumb. Both have a large selected preview, compact two-column scrolling portrait roster, personality and actual gameplay trait. Wanderers show weapon affinities and have an optional identity/origin sheet. Creature origin memories remain optional. Profile IDs, preset identity, editable pronouns and existing saves are preserved. Fixed TextureRect initialization that let source-image minimum bounds obscure small roster portraits. Reduced preview height slightly to expose more roster choices without shrinking the important action targets.

## WEAPONS / POSES

Reviewed all 12 actors × 12 live families × two facings × idle/windup/strike/recovery: **1,152 native samples**, 24 source sheets packaged as 12 actor pages. [Machine-readable scope and support status](weapon-review.json). Every actor page was inspected, including Bow, Crossbow, Daggers, Claws and Sling. Existing correct bow limb mirror, tensioned string, nock and forward socket are preserved; crossbow source points left and its existing right-facing mirror is correct. Extra native bow draw/fire/recovery captures check an actual emitted projectile and both facing previews.

Left-facing captures are explicitly previews: current combat places the enemy on the right. They do not promise a new left-side encounter system. The matrix remains visual evidence of current fallbacks, not approval of missing hands. No final art was generated or anatomy fabricated. WeaponFit now stages actors 40 virtual units lower; projectile launch sockets move with them. Enemy/group positions, ranged targets, impact/float origins and pickup landings were aligned to that composition.

Reviewed actor pages: [Relic Beast](relic_beast-weapon-review.webp), [Emberhorn](emberhorn-weapon-review.webp), [Mosskin](mosskin-weapon-review.webp), [Moonkip](moonkip-weapon-review.webp), [Pebblewyrm](pebblewyrm-weapon-review.webp), [Glimmerfin](glimmerfin-weapon-review.webp), [Gloomlet](gloomlet-weapon-review.webp), [Vault Runner](vault_runner-weapon-review.webp), [Ruin Warden](ruin_warden-weapon-review.webp), [Nightstage Drifter](nightstage_drifter-weapon-review.webp), [Velvet Astrologer](velvet_astrologer-weapon-review.webp), [Ashtrail Hunter](ashtrail_hunter-weapon-review.webp).

## BOSSES / VERDANT MIRROR

`boss_presentation.gd` owns texture, optional crop, facing/flip, anchor/baseline, size/offset, shadow, entrance, default rotation, attack distance and recoil bounds with a safe fallback. Active and legacy regional calls share this contract. Boss hit squash is restrained rather than flattening a large image. Ten regional boss identities were captured and inspected in idle and attack/hit staging: [first five](bosses-1.webp), [remaining five](bosses-2.webp).

Verdant's source has transparent outer pixels but contains a rectangular foliage/waterfall composition. Cropping it would discard substantial authored content without creating a convincing animated boss. The source/provenance remains intact, but it is no longer drawn or unnecessarily preloaded. A clean mirrored Mosskin guardian reuse replaces the slab with a 210×230 silhouette and restrained entrance/lunge/recoil. **This is BETA reuse, not the final Verdant Mirror body.** Furnace retains its frontal beta body. Other regions retain a left-facing Hoard Dragon fallback; repeated regional bodies remain art debt. No region's combat statistics changed.

## MENUS / SCROLLING / STASH

Important rebuilt actions use at least 48 virtual units, under the existing responsive transform; actual Android dp/physical comfort still needs owner acceptance. Existing single-touch ownership, scroll deadzone 12, swipe cancellation and synthetic-mouse suppression remain. Topmost foreground buttons now win against owned controls behind them; unowned foreground controls correctly block the underlying Home dismissal surface. The gesture regression caught this and passed after correction.

Stash starts with four compact equipped slots and the inventory list. Tapping an entry opens one detail sheet and Equip/Salvage; closing restores list space. No permanent Forge panel/action. Selection release cannot immediately equip or destroy the item: existing scoped timing protection is retained. Common/Rare salvage proceeds deliberately without a routine confirmation; Epic+, signature hooks, tracked/locked/favourite items remain protected and equipped items remain ineligible. Run pickups use the same risk distinction. No unsupported Undo promise was added.

## EXPEDITIONS / WORKSHOP / ARCHIVE / CONTRACTS

Regions, Relic Siege and Dungeons are top-level navigation. Region cards use existing region images, name, material identity and lock/tracked state; selecting opens one detail sheet with a deliberate Depart action. Patrols remain a secondary setting. Siege and Dungeon panes show their relevant choices and context; Dungeon copy no longer opens with unrelated Siege records.

Forge owns evolution/Blueprints. Contract Board owns local contracts/regional bounties. Archive owns trophies, field notes and Collection. These are contextual navigation over existing systems; recipe costs, unlocks and reward ownership stay intact. No new workshop/retention system was introduced.

## HUD / COMBAT / MERCHANT / REWARDS

Player HUD is 112 rather than 140 virtual units, with portrait/name/context, HP and a small XP bar. Redundant FOE/INCOMING bands are removed. Enemy identity/HP and compact status chips remain. Combat is staged lower, including platform and pickup floor, with intentional boss sizing rather than slab stretching. HP/XP bar semantics were corrected after resizing so health keeps the green health skin.

Merchant offers show type/rarity/price/name; effects appear once in the selected detail. Corrected its detail/offer overlap while retaining large Buy/Reroll/Leave controls and purchase protection. Routine toast height is 68 versus 126 for premium events, with shorter text lanes; dialogue defers routine toasts. Currency/XP keep existing nonmodal feedback. Level-up still requires one meaningful card decision. Existing first-time story and configurable repeat/auto-skip/reduced-motion preferences remain; no new mandatory awakening overlay. Results explicitly label the frozen run wallet **At finish**, avoiding a misleading live balance after spins.

## DIALOGUE / WRITING

Small contextual records match speaker plus actual weapon, queued event, last mode/outcome and resident activity. Highest specificity wins, followed by a six-line history and deterministic rotation among relevant ties. It does not use gameplay RNG. Last-run facts survive mode reset so Siege extraction/Dungeon victory lines remain eligible. All five Wanderers have locked personality defaults instead of unrelated origin quotations. Patch is competent first, Sera warm and grounded, Ilex protective of names/witnesses. Existing creature personalities remain.

Edited selected item, region, boss and character lines toward useful mechanics/world memory rather than repeated paperwork/punchlines; stable item IDs and effects remain unchanged. Contract, Forge, Archive, reward and result copy were reviewed in their native screens. The 40/30/20/10 flavour ratio is an editorial direction, not a fabricated measured percentage or claim that every future lore line is final. Wider narrative/art identity approval remains open where bosses reuse unrelated bodies.

## SPINNER

The relic engine has a framed reward aperture, seals/rivets, a short resource-silhouette cycle, wind-up, snap/reveal and Skip Reveal. Currency/remaining spins are separate at the top. Payment/reservation/recovery happen before animation, with one charge per deliberate action; reveal never supplies another reward. Three spins and costs **140/230/360** are unchanged; no RED or boss seals. Reset stops the presentation tween/process. Skip, rapid duplicate requests and save/reload are tested. Presentation uses original code geometry and existing canonical UI/resource icons, not generated final bitmap art.

## AUDIO

Preserved all licensed/original fallback banks and source/license documentation. Added 0.28-second music transitions with only one transient outgoing stream; release it after the fade. Cue gains compensate modestly for context variance; Home ambience gains body, routine UI/attack repetitions drop 2 dB, important transient families retain priority. Music duck restoration uses the current cue target. Actual Siege boss flags now select Boss music after round rules, including rounds 10/20; round 15 correctly returns to the regional cue.

Equal-default native Master captures, eight seconds per context, retain every captured frame. [Metrics and logs](metrics.json) record RMS, peak and zero discarded frames. RMS is **not LUFS** and does not reconstruct phone microphone volume.

| Context | Before RMS dBFS | After RMS dBFS |
|---|---:|---:|
| Title | -33.37 | -32.41 |
| Home | -33.47 | -31.97 |
| Combat | -27.68 | -28.88 |

The Home/combat gap falls from about 5.8 to 3.1 dB. Combat peaks remain audible without aiming at maximum volume. Source cues/voice timbres were not replaced. Final authored music/SFX, phone speakers/headphones and fatigue acceptance remain open.

## PERFORMANCE / SAVE COMPATIBILITY

Native desktop GL samples use 90 uninterrupted frames, separate from screenshot readback/encoding. Combat/boss medians and p95 stay around 16.7 ms on RTX 4080 SUPER; these are not S23 performance claims. Desktop texture monitors vary with viewport and visited roster/menu assets (~273–320 MiB in this review); static memory ~126–148 MiB. Android PSS/thermals/resume still require physical measurements. The owner's Phase 4B 59.9 FPS and phone memory report remain the physical baseline.

Audited retained resources: hidden controls remain bounded persistent screens; Texture2D resources reuse Godot caching, but visited actor/pose/background caches retain content. Full human pose imports and large background preloads remain measured-device optimization candidates. Removed the rejected Verdant preload; no texture quality/import limits were degraded speculatively. Music keeps one active cached score plus the brief outgoing fade. Resident life adds no particle-node forest; spinner reuses one Control.

No save schema, package ID or signing key change. No loot probability, DPS, HP, pricing or difficulty retune. Save reload/corrupt-backup recovery, existing retention/escrow, Dungeon, Forge evolution, rewards/inventory overflow, RED target/spinner and gesture tests pass. Physical upgrade of the existing S23 app and background/resume still require owner confirmation.

## MISSING FINAL ART

Existing approximately **82 right / 83 left support/paired combinations** remain historical art debt; this pass does not change that inventory. Human ranged/support/left poses, paired dagger/claw hands, weaponless Moonkip, remaining creature poses, final human identity/pose sheets, unique regional bosses and attacks/hurt/death, final Hoard Dragon and RED/relic identity remain. Sling still needs final authored presentation acceptance. Moonkip's baked daggers and Mosskin's shield-side limitations are visible in the review pages. Final music/SFX remain open. No AI-generated final art was used and no beta reuse was relabelled final.

## TESTS / NATIVE EVIDENCE

Focused regression evidence is in [qa-results.json](qa-results.json) and `logs/`: audio assets, Dungeon, evolution, mobile gestures, Phase 4B, Phase 4C, reward safety, save compatibility/recovery and weapon fit. Final follow-ups cover the later presentation refinements. Native fixtures capture phone 1080×2316 and tablet 1600×2560, real touch events, Siege Continue/Extract, spinner animation, roster/menu/dialogue, bosses and bow projectiles. Isolated saves only; no player save was modified.

Before/after review: [phone 1](1080x2316-comparison-1.webp), [2](1080x2316-comparison-2.webp), [3](1080x2316-comparison-3.webp), [4](1080x2316-comparison-4.webp), [5](1080x2316-comparison-5.webp); [tablet 1](1600x2560-comparison-1.webp), [2](1600x2560-comparison-2.webp), [3](1600x2560-comparison-3.webp), [4](1600x2560-comparison-4.webp), [5](1600x2560-comparison-5.webp). Native images were inspected, not just generated. Full-resolution selected details and spinner frames are alongside these sheets.

Comparison qualifications: seeded offers/enemy samples and accumulated disposable progression can differ; the screenshots compare layout/presentation, not balance outcomes. The initial level-up fixture accidentally left Merchant above it; corrected unobstructed baseline frames were recaptured from the immutable Phase 4B source in a disposable copy. Verdant baseline was likewise recaptured after entrance settled. Earlier failed gesture/parse/timing fixtures are not acceptance passes; final logs are identified in the evidence. A Unicode helper truncation of Home was reconstructed from the recorded transformations and revalidated natively before checkpoint. No valid prior work was discarded.

Engine behavior was checked against official [ScrollContainer documentation](https://docs.godotengine.org/en/stable/classes/class_scrollcontainer.html), [TextureRect documentation](https://docs.godotengine.org/en/stable/classes/class_texturerect.html) and [CanvasItem drawing API](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html). Single-child scrolling, deadzone, image sizing and local draw transforms informed the fixes. No borrowed game's values or invented industry standard was used.

## APK EXACT PATH / CHECKPOINTS / REMOTE VERIFICATION

See [delivery](DELIVERY.md) and [verified APK report](android-build.json). Implementation and evidence/docs are separate commits on the new branch; final SHAs and exact remote verification are supplied with delivery. Local APK is an ignored artifact, not distributed by a source push.

## Multidisciplinary sign-off

PASS below means preserved system behavior or implemented scope, not commercial approval.

| Discipline | Status |
|---|---|
| DESIGN | PASS — existing flows clarified; no new system or difficulty change |
| BALANCE | PASS — unchanged values; focused combat/mode regressions |
| ECONOMY | PASS — retained prices, caps, exclusions, reservations and reward protections |
| ROSTER | ISSUES — reviewed all 12; authored anatomy/human art gates remain |
| ENEMIES | ISSUES — existing behavior preserved; final animation/identity debt |
| BOSSES | ISSUES — slab removed and contracts reviewed; unique final bodies/animations missing |
| RNG | PASS — gameplay probabilities unchanged; dialogue/visual cycle isolated |
| UI/UX | ISSUES — native flows/layouts pass; physical finger comfort/readability acceptance pending |
| NARRATIVE | ISSUES — contextual voice improved; broader canon/visual identity owner acceptance pending |
| AUDIO | ISSUES — measured mix improved; final authored audio/device listening outstanding |
| MOBILE | ISSUES — APK and native layouts pass; S23 loading/PSS/thermals/lifecycle unverified |
| QA | ISSUES — scoped automatic/native checks pass; physical acceptance outstanding |
| PRODUCTION | ISSUES — safe delivery/checkpoints; commercial art/audio/device gates remain |

**GO FOR S23 OWNER TEST. HOLD FOR COMMERCIAL RELEASE.** Stop here; do not automatically begin pets, decoration or final-art production.
