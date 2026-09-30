# Lootlings Master Roadmap

This roadmap preserves product direction; it is not a promise to build every system at once. Each stage should reuse stable profile, combat, loot, reward, zone, and save contracts rather than create parallel implementations.

## Product Pillars

- Cute first, badass second: tiny relic-beasts, oversized scavenged equipment, readable silhouettes, and visible Relic Cores.
- The reward fantasy is physical: chests land, loot ejects, rarity light appears, and rewards settle before menus summarize them.
- Auto-combat remains watchable; tapping is useful and satisfying without being mandatory.
- Gold, Scrap, Star Shards, and Run Scrip have separate responsibilities.
- Offline/local play remains valid. Future online ownership, trading, clans, and purchases must be server-authoritative.
- Genre inspiration informs pacing and emotion only. Characters, writing, UI, art, audio, names, and systems expression remain original.

## 1. Foundation — Active

- Boot ignition, title-first first-launch/returning flow, offline profile, settings, five-bus anti-fatigue mix with original 48-second prebaked adventure cues, local analytics abstraction, persistent Gold, Run Scrip terminology, schema migrations, stable IDs, and mobile component language.
- Current canonical Relic Beast, Hideout, three-zone expedition, 15-wave loop, merchant, Stash, Shrine, rewards, and saves remain the playable baseline.
- Debug builds include a gated F1 development toolkit for encounter, reward, Core, weapon, economy, speed, result, and exact Lootlings-save QA. Vanguard/Rogue resolve as melee while Ranger/Mage use bounded projectiles whose visible arrival matches damage.
- Current world-life layer includes bounded Hideout residents, contextual weighted dialogue with cooldown/history, randomized room micro-events and mascot micro-reaction, shared screen/travel direction, Profile/Title navigation, and a responsive Relic Shrine interaction. Next foundation work: accessibility controls, input remapping where useful, save backup/recovery, device lifecycle handling, final production audio/mastering, and wider shared-component adoption.

## 2. Loot / Items

- Deepen data-driven affixes, rarity identity, unique effects, Legendary mechanics, boss/zone pools, weapon evolution, restrained sets/synergies, and cosmetic variants.
- Stable chest IDs begin with `scavenged_cache`, `relic_chest`, and `hoard_chest`. Shared presentation phases: drop → land → anticipation → open → burst → eject → settle → reveal.
- Hoard Chest is live at the final boss: physical landing, tap-to-open, three Epic+ arcs, settle, then unchanged choose-one. Scavenged Cache has a conservative once-per-run-cycle 180-Gold Hideout source with protected reveal/claim. Relic Chest remains the next presentation candidate for Grump Knight.
- Weapon thumbnails use painted family art; Armour, Charm, and Rune use shared replacement-ready code-native silhouettes across item review, Boss Hoard, Stash, and Salvager. Future work should replace these with bespoke painted category/item art without changing IDs.
- Future sources: milestones, quests, dungeons, rare world finds, mimics, events, clans, and raids.
- Preserve rarity odds independently from presentation intensity.

## 3. Meta Progression

- The first capped Gold utility board is live: five Bedroll ranks (+4 starting HP each), five Whetstone ranks (+0.6 starting damage each), and five Field Pouch ranks (+8 starting Run Scrip each), costing 11,650 Gold in total. Keep it small; do not turn this into exponential power.
- Evolve the current +5% Damage/Max HP Star Shard training only through a deliberately controlled board: Vitality, Might, chest quality/luck, Stash utility, starting bonuses, and future Forge connections.
- Avoid exponential power creep and keep earlier zones meaningful.
- Gold is broad everyday progression currency; Scrap remains gear/salvage focused; Star Shards remain rare Relic progression.

## 4. Characters / Customisation

- Preserve the canonical neutral Relic Beast. Emberhorn, Mosskin, Moonkip, Pebblewyrm, Glimmerfin, and Gloomlet remain separate canonical identities.
- Profile hooks support current Lootling, optional nickname, profile icon, title, banner, badges, favourite weapon, and cosmetic IDs.
- Starter roster/selection should begin only when clean transparent runtime sprites can represent the canonical identities. Do not use malformed sheet crops or invented substitutes merely to activate the profile hook.
- Future cosmetic slots: horn/ear accessory, head/hood, scarf/cape, armour appearance, satchel, Core effect, weapon skin, aura/trail, emote, victory pose, icon, title, and banner.
- Cosmetics should normally express identity, not raw power.

## 5. Pets / Companions

- Future roles: visual companion, modest combat assist, utility, loot pickup, status support, treasure finding, and social showcase.
- Power must not become mandatory or pay-to-win. Use stable companion IDs and bounded battlefield presence.

## 6. New Zones / Enemies / Bosses

- Extend the zone catalog with stable zone/enemy/boss/music/loot-theme IDs.
- Encounter containers support intentional solo, duo, and three-member small-swarm compositions with frontmost targeting and shared rewards.
- Candidate encounters: Scraprat trio, thief duo, tank + caster, summoner + minion, boss adds, merging slimes, escaping treasure creature.
- Do not turn normal play into a horde game. The first demonstration swarm remains deferred until targeting/AoE UI is deliberately implemented.

## 7. Dungeons

- Short authored or seeded expeditions with shared combat/build/loot contracts, dungeon chest tables, modifiers, and clear completion rewards.

## 8. Dedicated Roguelike Modes

- Deeper run-only drafting, route choices, risk rooms, curses/boons, and seeded versioned runs. Keep persistent advantages controlled.

## 9. Endless / Survival

- Endless scaling, milestones, extraction decisions, bounded leaderboards, and transparent run-version rules.

## 10. Challenge Runs / Boss Rush / World Encounters

- Rotating constraints, boss sequences, rare world encounters, and event battles reuse the same combat, reward, profile, and analytics contracts.

## 11. Quests / Contracts

- Local objectives first, then account-backed daily/weekly/event contracts. Rewards may include Gold, Scrap, Shards, chests, cosmetics, and profile badges.

## 12. Social Foundation

- Stable internal player UUID is separate from public display name and platform identity.
- Future Player Card fields: display name, title, Lootling/nickname, icon, banner, clan tag, Core/build identity, favourite weapon, cosmetics, badges, bosses slain, and Legendary finds.
- Future Google Play Games Services v2 flow: local profile → optional platform link → internal Lootlings account → cloud revision/sync metadata → achievements/leaderboards. Offline play remains supported; deprecated v1 is excluded.
- Inventory items eventually need unique ownership IDs, bound/tradeable state, origin, content version, and server validation.

## 13. Friends

- Friend list, requests, privacy settings, Player Card inspection, lightweight presence, and optional asynchronous assists.

## 14. Clans

- Clan ID/tag/profile, chat, shared objectives, clan quests, representative NPC/space, progression, and clan bosses.

## 15. Parties / Groups / Co-op

- Party IDs, invitations, ready state, versioned combat sessions, seeing friends fight beside the player, and co-op bosses. Networking authority and reconciliation must precede combat implementation.

## 16. Raids

- Multi-stage group encounters, role-readable mechanics, contribution/reward rules, reconnect handling, and server-owned results.

## 17. Trading

- Server-authoritative ownership and atomic trades only. Never trust client inventory, prices, or transfer completion. Add bound states, audit logs, abuse controls, and rollback before launch.

## 18. Player Hub

- A Lootlings world location—not a server browser—with visible Lootlings, Player Cards, friends, clan representatives, group formation, raid board, trading area, events, emotes, and cosmetic showcases.

## 19. Live / Seasonal Events

- Versioned event definitions, world encounters, contracts, cosmetics, chest pools, and catch-up rules. Avoid permanent content invalidation.

## 20. Monetisation — Future Only

- “Paid” means in-game currency unless real money is explicitly stated.
- No real-money systems, advertisements, premium loot boxes, or platform purchasing are in the current checkpoint.
- Any future monetisation must be transparent, age/region compliant, non-exploitative, and avoid mandatory pet/power purchases. Earned-currency randomized chests remain gameplay rewards, not real-money products.

## Technical Guardrails

- Portrait target: 480×854; large hit targets; bounded particles, loot objects, ambient actors, and audio voices.
- Stable save schemas and migrations; never key ownership by display name.
- Local analytics contains no personal information and can later route through a consented provider interface.
- Run seeds/content versions, player IDs, clan/party IDs, item ownership IDs, and cloud revisions remain distinct.
- Track important asset/audio provenance and licences. Never assume an internet asset is commercially safe.

## Foundation shipped at the character-feel checkpoint

- Weapon-specific data-driven key poses and bounded actor-edge readability are live without cadence changes.
- Hasty, Armoured, Volatile, Cursed and Gilded regular-enemy variants are deterministic, visibly disclosed and conservatively weighted.
- Signature Loot V1 has curated compatibility rules, eight additional bases and four behaviour hooks; large item-volume expansion and full weapon evolution remain future work.
- Eighteen local-first trophies persist offline and display in the Hideout Archive. Provider ID fields/live platform submission remain future integration work.
- The seven-identity LootlingCatalog and first-profile selector are live. Only Relic Beast is player-facing until clean standalone runtime art exists for each named character.

## Master Production Handoff v2 content checkpoint

- `CONTENT_IMPLEMENTATION_STATUS.md` is the authoritative project ledger for what is live, data-defined, asset-blocked, future or deferred.
- Eight regular-enemy variants are live and zone weighted. Duo/small-swarm/mimic/treasure-escape contracts are defined but remain gated on simultaneous targeting, AoE, aggregation and dedicated runtime art.
- The curated live equipment pool expands to 35 bases and 20 standard affixes. Six behaviour-changing Signatures are implemented; nine additional Signature contracts cannot roll until their mechanics are complete.
- The complete approved 12-family weapon catalog, six projectile profiles and 36 evolution lines now have stable data. Five art-ready weapon types are live; seven stay asset-gated. Forge/evolution activation remains a later system.
- Six chest identities and nine future zone arcs now have replacement-ready data, while only validated Act I scenes and three chest reward flows remain live.
- The Trophy Archive expands to 28 local achievements. Provider mappings remain preparation only; platform authentication/submission is future work.
