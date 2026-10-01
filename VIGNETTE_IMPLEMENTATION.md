# Illustrated memories — first playable tranche

## Shipped

`vignette_catalog.gd` describes 33 short scenes using **existing** content/art: 7 canonical Lootling origin fragments, 8 player-selected adult origin flavours, 3 resident meetings (Patch/Sera/Ilex), 10 region arrivals, 4 art-supported boss introductions (Grump Knight/Hoard Dragon/Verdant Mirror/Furnace Regent), and the Hideout's welcome. These are living-painting beta presentations, not full animated cinematics or new gameplay encounters.

One `vignette_player.gd` child of the existing `PresentationDirector` owns playback, title/caption timing, a subtle camera push, actor entrance/bob, six bounded ambient motes, skip/close and sound hooks. It has no inventory, reward, campaign, profile or gameplay-RNG dependencies. Existing painted art and original sound events are reused; no character/weapon/music assets were regenerated or imported in this tranche. Resident busts use deliberate painted portrait frames, not pretend full bodies. Existing Hoard Dragon quality limitations remain; its art was not replaced.

## Player paths

- Lootling selection → **Origin Memory** previews the highlighted character without selecting it, spending currency, unlocking progression or changing saves.
- Wanderer selection → **Origin Memory** previews the chosen origin using the highlighted adult preset, independent of gender/pronouns/weapons; no fixed personal biography is imposed. The two accepted presets are unchanged.
- First normal entry into the Hideout, first manual resident meeting and first campaign-region departure present the appropriate scene. Skip still records discovery. Viewed scenes normally auto-skip.
- Presented player runs use the four supported boss stings at their existing special-intro handoff. First time: 5s; repeats: 1.4s if enabled. Boss spawning happens once on finish/skip; cancelled handoffs cannot spawn later. Regions without matching boss art retain their existing brief encounter introduction rather than showing an unrelated monster.
- **Archive → Field Notes → Memories / Story Replay** exposes available character origins, the current adult origin and discovered world/NPC/boss memories. Locked entries conceal names. Categories: All, Characters, Regions, Bosses. Replay never adds a discovery, currency, items, contracts, achievements or campaign progression.
- **Settings → Story & Motion** controls first-time scenes, repeat boss stings, auto-skip, reduced cinematic motion and captions. Existing audio levels/mutes are preserved. Manual replay/preview remains available even when automatic scenes are disabled.

## Safety / timing

Profile schema 3 gains an additive sanitized `memories` list (unique string IDs, capped 128); old saves default to empty. Inventory/meta/campaign/contracts schemas are unchanged. Unknown future memory IDs are retained within bounds. Profile updates merge existing discoveries, so a stale name/avatar form cannot erase them. Replay/preview explicitly rejects gameplay handoff callbacks. Settings are additive keys in the existing config; no audio defaults were retuned. Native Master-bus sanity capture: 223,232 frames, peak −0.80 dBFS, RMS −20.88 dBFS, limiter present; this is an internal output check, not a new Windows loopback/recording loudness claim.

Full scenes are 5–6.6s, no slow cinematic loading gate. All have a visible 48px Skip/Close target (character-selector preview 44px). Escape/Space/Enter finishes playback. Root simulation and Hideout ambient dialogue pause while the overlay is active, then restore without catch-up damage/regen or leaked speech. Scene changes cancel without invoking stale callbacks. No new timers, particle nodes, shaders, skeletal rigs or per-frame scene creation. Caption text changes only at beat boundaries.

Direct `start_run()` remains the non-presented simulation entry: the normal player path is `request_start_run()` / `start_presented_run()`. This separates presentation waiting from deterministic combat tests without changing combat formulas, seed generation, targeting or cadence. The vignette suite tests actual presented region/boss handoffs as well as replay isolation; the ordinary 96-run suite still audits the same combat rules.

## Deliberately not claimed

No glove-tightening, hair/hood/hand animation, lipsync, companion relationship scenes, relic/Signature discovery cutscenes or secret Echo cinematics yet. No final cinematography/voiceover/new soundtrack. The two adult presets are examples, not a universal coat/body template. Future original adult looks must include the broad approved fashion/diversity lanes from `docs/master_pack_v3/20_ANIME_GOTH_EMO_METALCORE_FASHION_DIRECTION.md`, and only expose modular options with real compatible exports. Existing weapon/socket and stat-neutral identity contracts remain authoritative.

Future scene additions should use this catalog/player and real discovery hooks, never a second cinematic architecture or reward-bearing Archive replay. Registered pose/foreground exports and original licensed/generated audio can replace individual beta layers/hooks without changing memory IDs or saves.
