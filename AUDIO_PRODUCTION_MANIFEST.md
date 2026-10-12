# Active production bank —0.4.75

Production audio is installed, not merely proposed. See AUDIO_LICENSES.md's current section, `art/audio/production/LICENSES.txt`, `sources.json`, `score_sources.json` and announcement provenance. Runtime prefers production OGG scores, then production WAV, then fallback. Approved title.ogg is unchanged; no mixing/settings changes in this reconciliation.11scores/11retained sources and461bank outputs match their recorded hashes. Human listening and device/mastering acceptance remain pending.

## Historical delivery brief — keep for requirements, not current installed status

CURRENT PHASE 4E — Twelve-subtype weapon/material dispatch and seven material contacts are now active, with 95 newly source-documented CC0-derived variants/cues. Verdant has four action families; RED has a dedicated stinger. Native capture covers all six spinner tiers. Earlier proposed-routing tables below are historical where superseded; final mastering/perceptual and S23 approval remain open. See [Phase 4E report](docs/production/phase4e/REPORT.md) and retained `art/audio/production/sources.json` / `LICENSES.txt`.

> **2026-10-02 audit authority:** [AUDIT_REPORT.md](AUDIT_REPORT.md). The eight actual WAV files are mono PCM16, 16 kHz, 48 seconds each (about 1.536 MB each), procedural placeholders. The stereo 44.1/48 kHz production requirements below are the future delivery contract, not the current file format. Hooks/buses/limiter/voice caps are live; final-mastered music/SFX are MISSING.

# Original Lootlings audio replacement contract

All final assets below are **PENDING**. This tranche supplies safe import hooks, not finished music or replacement filler. Keep all eight existing original 48-second WAVs and procedural feedback until a complete approved replacement is delivered. Direction: original dark-fantasy melodic identity, warm treasure-home contrast, eerie relic textures, industrial/infernal boss percussion and selected metalcore energy; no copied riffs/melodies, bands, commercial tracks or unlicensed samples.

## Live drop-in contract

`audio_manager.gd` accepts imported WAVs under `art/audio/production/`. `music_source_path(cue)` selects a delivered score or the exact existing cue. `production_event_streams(event)` accepts a complete authored short-cue bank or retains the exact procedural bank. Existing Master/Music/SFX/UI/Ambience buses, six SFX/two other voice bounds, settings/mutes, pickup cooldowns, non-repeat selection, ducking and limiter remain authoritative. No runtime synthesis of long scores, new mixer or combat timing change.

Music: stereo PCM WAV, 44.1/48 kHz, 16 bit preferred, 8–120s, clean full-file loop (no loop click), preferably 48–90s. SFX: PCM16 WAV, 44.1/48 kHz, mono unless meaningful stereo, 0.025–2s. Frequent events require **all four** `<event>_01.wav` through `_04.wav`; singular important/UI stings require `_01.wav`. Partial/malformed packs retain procedural feedback; invalid imported assets produce a diagnostic, not a silent suppression. No production files are included yet.

Keep cue envelopes/cadence comfortable for auto-combat; impacts must not obscure ranged release or reward sound. Deliver conservative source headroom for current player gains (+1dB music, existing event voice gains) and post-Master -0.8dB limiter. Do not normalize every asset to maximum loudness. Every delivered file requires an AUDIO_LICENSES row with creator/source, exact commercial licence, acquisition date, modifications, attribution and final/beta status. Original recording/composition is preferred; no licence inferred from a search thumbnail or asset filename.

## Scores — exact immediately supported destination filenames

| Destination under `art/audio/production/music/` | Live cue / location | Production brief |
| --- | --- | --- |
| `title.wav` | TITLE / title/profile | Memorable original treasure motif, dark invitation, restrained heroic lift. |
| `hideout.wav` | HIDEOUT / home destinations | Warm plucked/soft melodic body, subtle workshop texture, unhurried sanctuary. |
| `outer_ruins.wav` | OUTER_RUINS | Discovery pulse, distant ruined bells, clear original motif. |
| `salvage_warrens.wav` | SALVAGE_WARRENS | Brass/industrial rhythm, playful danger, no piercing repeated loop. |
| `hoard_depths.wav` | HOARD_DEPTHS | Deep ancient drone, sparse gold chimes, threatening scale. |
| `boss.wav` | BOSS | Infernal percussion/low guitar-like original textures, strong accents with room for hits. |
| `victory.wav` | VICTORY / Results | Brief opening resolution then gentle loop, loot prestige without endless fanfare. |
| `defeat.wav` | DEFEAT / Results | Dignified mysterious resolve, not punitive/grating. |

## Event replacements — exact live IDs and filename convention

Destination: `art/audio/production/sfx/<event>_01.wav`; rows marked ×4 also require `_02`, `_03`, `_04`. All rows pending production.

| Exact event IDs | Bank | Bus / purpose / brief |
| --- | --- | --- |
| `ui_press`, `menu_open`, `menu_close`, `menu_transition` | ×1 each | UI / tactile select, open/back and gentle travel/preview entry. 45–140ms; not shrill. |
| `upgrade_select`, `equip`, `shop_purchase` | ×1 each | UI / rewarding material latch with small melodic accent. |
| `tap_attack`, `normal_hit`, `heavy_hit`, `crit`, `boss_hit` | ×4 each | SFX / distinct transient/body/tail, stronger critical weight without duplicate explosive noise. |
| `vanguard_swing`, `rogue_slash`, `ranger_release`, `mage_cast` | ×4 each | SFX / heavy whoosh, fast leather/steel sweep, string release, original arcane charge/release. |
| `enemy_skirmisher`, `enemy_tank`, `enemy_hexer` | ×4 each | SFX / cute-dangerous scrape, heavy armour weight, eerie magical articulation. |
| `enemy_hurt`, `player_hurt`, `enemy_death` | ×4 each | SFX / original creature reaction/cloth-impact, restrained voices; no repeated human shriek. |
| `gold_pickup`, `scrip_pickup`, `resource_pickup`, `xp_pickup` | ×4 each | SFX / physically distinct coin/energy ticks; comfortable at frequent pickup cadence. |
| `equipment_drop` | ×4 | SFX / material landing + treasure accent, visibly dropped item priority. |
| `rarity_reveal`, `rare_reveal`, `epic_reveal`, `legendary_reveal` | ×1 each | SFX / rising prestige, clear tier contrast, 0.2–0.8s not a full cinematic. |
| `chest_land`, `chest_windup`, `chest_open` | ×1 each | SFX / wood/metal thump, latch tension, rich open/burst; align with existing Director sequence. |
| `level_up`, `core_awaken`, `scrap` | ×1 each | SFX / uplifting growth, distinctive Core response, readable salvage crunch. |
| `boss_warning`, `boss_death` | ×1 each | SFX / ominous punctuation and heavy release; preserve single intro cue/handoff. |
| `zone_transition` | ×1 | Ambience / short original airy/stone threshold. Not a continuous ambience bed. |
| `victory`, `defeat` | ×1 each | Music event pool / short result stings, separate from same-named looping score files. |

## Detailed production requests with honest current hook limits

These assets need a later small routing extension, **not automatically active** if merely copied into the repository. Do not fake completion by assigning an unrelated sound.

| Proposed filename / directory | Desired identity | Existing routing / needed integration |
| --- | --- | --- |
| `music/region_<campaign_id>.wav` for act_i, mossglass_wilds, moonfen, frostbell_hollows, sunken_gearworks, cinder_crown, starfall_archive, nullglass_expanse, skyhook_bastion, first_hoard | Ruins, reflective nature, marsh whispers, ice bells, drowned machinery, infernal foundry, erased stars, glass unease, sky chains, primordial treasure. | Current location grouping reuses eight cues; dedicated region-ID dispatch pending. Keep current grouping until assets exist. |
| `ambience/hideout_workshop.wav`, `ambience/region_<campaign_id>.wav`, `ambience/archive_memory.wav` | Quiet bounded workshop, appropriate environmental beds, memory-room hush. | Current Ambience handles short zone cue. Dedicated one-voice bed/fade integration pending; never load these as ≤2s event clips. |
| `sfx/ui_hover_01.wav` | Very soft desktop hover; no mobile hover spam. | No current hover event; explicit hover hook pending. Select/back already supported. |
| `sfx/weapon_<family>_impact_01..04.wav` for greatsword, greataxe, maul, spear, daggers, claws, bow, crossbow, sling, staff, wand, orb | Steel weight, axe bite, blunt thud, thrust, paired slices, claws, arrows/bolts/stone, arcane stave/wand/orb. | Existing four-family release plus normal/heavy/crit feedback. Twelve-subtype material dispatch pending; do not relabel shared hooks as twelve distinct sounds. No firearms live. |
| `sfx/element_<fire,lightning,poison,physical>_proc_01..04.wav` | Distinct short flare, crack, toxic hiss, relic strike. | Current generic hit/cast/Core hooks remain; element-specific routing pending. No extra element. |
| `sfx/creature_<lootling_id>_idle_01..04.wav`, `sfx/demon_<supported_enemy_id>_01..04.wav` | Seven original cute creature identities; genuinely menacing supported monster vocals. | Current family hurt/death hooks; identity-specific voice dispatch pending. No copyrighted recordings or monster roar clones. |
| `music/vignette_memory.wav` | Restrained original relic-memory motif, optional resident stings. | Current vignette uses retained context score and menu/boss event. Separate background-cue override/restore pending; replay remains read-only. |

## Repeatable output QA

Before enabling replacements: import/parser, `tests/audio_production_qa.gd`, native `tests/audio_mix_qa.gd`, all mute/volume settings and location changes. Capture post-Master samples, then follow AUDIO_LICENSES.md's **real player-path** Windows recording procedure on the human benchmark device/app-mixer/recorder. Internal capture is not Windows loopback or integrated LUFS. Check quiet combat fatigue versus boss/chest/Legendary audibility, phone speakers/headphones, loop clicks, peak clipping, entry stalls and long-session voice/texture memory. Never amplify blindly to compensate for recording attenuation. Current native fallback capture after these hooks: 221,184 frames, -0.80dBFS peak, -20.71dBFS RMS, limiter active; final mastering/real recorded-output QA remains pending.
