# 0.4.47 — living companions and shared-world integration

Continued the live project from 386ffef. Implementation checkpoint 2d5a1e7 pushed to codex/phase4e-gamefeel. Owner project.godot and all untracked references preserved.

## Actual playable improvements
All six approved companions now render in Main Hub and combat using their existing exact accepted state/facing assets. The previously unused saved accompany flag now has a 48-point Follow Me / Stay Home control in the collection. Selection and follow preference reload correctly. Cosmetic followers trail the hero, use grounded shadows and approved reward-reaction poses. Home retains its separate floor/wall-perch behavior and Apply/Cancel layout persistence. Gentle idle motion obeys reduced-motion settings.

Hub and Home world-object targets now share a bounded blue tap ripple and subtle gold hover indicator inside their existing hit areas. The portal, object layout, direct destinations and service functionality are preserved; no extra navigation panels.

Original equipment artwork is framed by its actual transparent bounds in shared item/weapon UI widgets. Shop, Forge, Stash and related item presentation reuse the same approved pixels; held weapon geometry, stats and sockets are unchanged. Native review found Forge resource text spilling below its detail frame; removing redundant blank spacing corrected the observed overflow. Combat help/Pause controls could survive direct Home entry; Home now explicitly clears combat overlays, verified in the packaged game.

Accepted companion manifest/readiness checks are cached, avoiding repeated full manifest parsing in rendering. No new companion designs, alternate faces, source-image edits or music changes.

## Exact counts and acceptance
Generated assets: 0. New physical artist files: 0. New frozen art contracts closed: 0. All 60 existing canonical companion bodies preserved and verified in the APK, including both views of follower and perch states. This batch restores runtime routes; it does not claim new artwork or complete fluid animation families.

Frozen total remains 3,274 contracts / 8,495 artist-file requirements. Installed 422 / 1,096. Outstanding 2,852 / 7,399. Remaining: playable Lootlings 1,270; Wanderers 791; enemies 242; bosses 356; NPCs 28; modular support 165. Frozen companion/Home deliveries being closed does not imply complete animation or professional family acceptance.

Professional approvals added: 0. Created, integrated, tested, visual-review and player-experience gates remain separate in the sole dashboard. Unchanged older asset evidence with now-stale code dependencies remains flagged rather than silently re-approved.

## Tests and actual exports
Source-native companion travel/reward, Hub direct destinations and connected services pass 1080×2340, 1200×1920 and 1920×1080. Existing companion perch regression passes phone/tablet; Stash guidance passes all three sizes.
Actual compiled Windows PCK passes final companion probes (18 companion/layout cases), both combat facings, reward reaction, saved follow toggle, clean Home entry, perch Apply/reload/Cancel and connected title/Profile/Shop/Forge/Stash/Contracts/Expeditions/Dungeons/Siege/Relic Engine checks. The PCK runs real exported game code, with only external test fixtures copied. Equipment, economy and combat randomness invariants are checked before cosmetic presentation; title SHA is unchanged. Owner saves are isolated from every test.
Representative actual packaged native screenshots for all six identities and all three layouts retained here. The reviewed Forge overflow and Home overlay defects are corrected. Screens are not declared professionally finished merely because tests pass.
Actual Windows executable startup passes; embedded launcher artwork matches the approved icon at 16–256 pixels. Signed arm64 Android debug APK code56 exported, 16K zip alignment verified. Actual APK branding/adaptive/monochrome/splash resources match approved originals, and 449 canonical actor/layer textures match current imports, including all 60 companion bodies. Audio licence manifests and accepted music imports are retained. Physical S23 performance/playback/launcher testing remains deferred, not claimed.

Windows: builds/windows/Lootlings-0.4.47-living-world.exe and adjacent .pck.
Android: builds/android/Lootlings-0.4.47-living-world-debug.apk.
PCK SHA256: 28b3e63611b4bce3456e679603ca346cd23784333155024a08ca2575a9324c84.
APK SHA256: 551ddc0b7171800ee17884261da55767a89045a5b9954a7d7557b5e3dcc6df5f.

## Still open / next large families
Companion movement is still state keyframes, not fluid walking/hover cycles. Resident walk/work/sit and convincing environment lighting/perspective integration remain unfinished. Static-looking Home/Hub props and some generic item symbols remain quality debt. Remaining playable weapon actions/contact, opposing views, enemies/boss motion, equipment/cosmetics, regional environment animation, audio polish and full-game artistic/UX acceptance remain open. None was closed by this integration pass.
Next production should batch missing continuous movement and resident work/interaction assets against dedicated canon, alongside item-specific artwork and regional effects. Preserve 046 combat assets and new 047 routes; no reset, general audit or regeneration of accepted bodies.

## Changed runtime files
companion_catalog.gd; companion_presentation.gd; hideout_ui.gd; hub_navigation.gd; item_icon.gd; lootling.gd; lootlings_ui.gd; personal_home.gd; new world_interaction_feedback.gd. Version: export_presets.cfg. New asset_factory_047_native_qa.gd; APK verification extended in tools/verify_actor_delivery.py. Existing runtime registry and single quality dashboard refreshed with explicit bounded evidence.
