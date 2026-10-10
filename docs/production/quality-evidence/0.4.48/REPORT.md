# 0.4.48 — canonical services, named loot and regional creatures

Continued the actual live project from f05edb9. Implementation milestones 6bd2782 and 145bdc1 pushed to codex/phase4e-gamefeel. Owner project.godot, accepted source images, untracked references, gameplay, saves and exact title music preserved.

## What players can see
Patch repairs equipment, Ilex reads/writes and Sera tends her blue crystal using six new independent service poses, both facings. Feet stay anchored; state changes use a restrained 140ms grounded dissolve and existing breathing, with reduced-motion support. Existing rest/talk/inspect art, direct world-object interactions, dialogue personalities and service routes remain available. These are work keyframes, not finished walking cycles or fluid animations.

Six distinct named loot icons replace generic symbols: Quiet Chime, Frostbell Seal, Storm Ledger, Threefold Ink, Shelter Script and Critical Script. Shared item renderer delivers them to equipment, loot, Shop, Stash, rewards and detail views without changing stats, signatures, costs or economy. Actual Stash and details reviewed on all three layouts.

Inkling and Margin Imp now use their approved living-ink and parchment/quill identities instead of generic idle rigs. Twelve authored cells: Inkling idle, windup, recovery and defeat both views; Margin Imp idle and defeat both views. Missing actions reuse the accepted identity explicitly, while their individual contracts remain open. Independent cells extracted using owned alpha silhouettes; original joined rows are quarantined, not sliced through anatomy.

Final combat review also fixed attack warnings covering enemy HP. Labels now align below the selected enemy HUD. Prefixed variants retain their exact canonical body instead of falling back to a generic rig; both identities and facings checked in three layouts. These routing/HUD fixes add no art closures.

Ten original regions gain bounded background atmosphere: six deterministic detail points with palette/presentation matched to forest, marsh, frost, machinery, cinder, archive, nullglass, sky and hoard settings. Original background paintings, enemy hitboxes, attack clocks and combat RNG untouched. Motion disables under reduced motion. This is procedural presentation, not newly completed background artwork.

## Exact production counts
Eight generated source sheets; 24 accepted runtime PNGs and 24 metadata sidecars = 48 new physical artist files. Six NPC contracts + twelve enemy contracts =18 exact frozen closures. These fulfill36 frozen artist-file requirements; six named item icons and their sidecars are additional runtime content outside the frozen pose counter. Installed440/3274 contracts and1132/8495 requested files. Remaining2834 contracts /7363 file requirements.

| Family | New runtime PNGs | Exact frozen closures | Remaining contracts |
|---|---:|---:|---:|
| Playable Lootlings |0|0|1270|
| Wanderers |0|0|791|
| Enemies |12|12|230|
| Bosses |0|0|356|
| NPCs |6|6|22|
| Six companions |0|0|0 frozen deliveries; full motion/quality still open|
| Home |0|0|0 frozen deliveries; world/motion/quality still open|
| Modular support |0|0|165|
| Named loot icons |6|outside frozen pose counter|Other named families remain|

Original merged NPC sheet and clipped Sera sheet retained as rejected sources; corrected independent service exports installed. Sera runtime width clipping fixed through uniform scaling. Regional action sheets provided eight independently usable cells; sixteen intended cells withheld due to joined/clipped alpha. Four idle views independently corrected. Remaining exact Inkling role-commit/hurt and Margin Imp windup/commit/hurt/recovery both views stay in the sole correction queue. No gestures relabelled as complete attacks, no mirrors, no board-crop bodies.

## Runtime testing and builds
Native normal selectors and 36 exact enemy state/view probes pass 1080x2340 phone, 1200x1920 tablet and1920x1080 desktop. Real Shop/Forge/Archive touch and return paths, six named items, Hub/Home and ten region contexts tested with isolated saves. Economy, damage/HP data, RNG, equipment and title bytes preserved. Save recovery test passes.

Exported Windows PCK passes new art, regional atmosphere, connected Forge/Archive/expedition/Stash services and all six companion perch/Apply/reload/Cancel routes. Only external fixtures copied; gameplay code is from the pack. Final refreshed pack tests recorded separately. Actual Windows executable startup exits0; embedded approved mascot icon matches16–256px originals.

Signed arm64 Android debug code57 exported with16K alignment. Actual APK launcher/adaptive/monochrome/splash branding matches approved originals. 491 exported actor/layer/NPC/item textures and their manifests match current local imports byte for byte, including all60 unchanged canonical companion bodies,24 resident cells and six new named items. Approved licensed audio/imports retained; no new audio replacement claimed. Exact title SHA remains7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7. Physical S23 testing deferred.

Windows: builds/windows/Lootlings-0.4.48-living-world.exe and adjacent.pck.
Android: builds/android/Lootlings-0.4.48-living-world-debug.apk.

## Acceptance and remaining work
Source identities, complete alpha, gameplay scale and representative native screenshots reviewed. Created, integrated, functional and visual stages are separate; professional approvals added:0. Full fluid animation, contextual lighting/style cohesion, broader player-experience acceptance, weapon-contact continuity, missing enemy/boss families, NPC walking/sitting, equipment variants and subjective audio/device quality remain unfinished. Existing accepted assets preserved. Do not interpret frozen companion/Home closures or passing exports as full professional acceptance.

One dashboard: PRODUCTION_DASHBOARD.html/json. Exact missing IDs remain in full-completion/continuous-production/EXACT_REMAINING_CONTRACTS.json. Registration gaps and stale quality dependencies remain explicit. Extractors now refuse to overwrite accepted assets.

Final delivery checks: refreshed Windows pack passes regional creature/HUD/variant and NPC/item fixtures (EXPORTED_FINAL_RESULTS.json, exact pack hash bound). Actual refreshed Windows EXE exits0. Android code57 asset and branding checks pass; final build hashes in INSTALLATION_RECEIPT.json. Implementation milestones6bd2782 and145bdc1 pushed; final evidence/combat fix checkpoint follows.
