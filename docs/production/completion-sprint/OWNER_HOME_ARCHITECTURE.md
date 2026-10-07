# Owner Home architecture clarification — 2026-10-07

Home is a separate personal area reached from the main Hub: **MAIN HUB → HOME → Leave/Back → MAIN HUB**. It is not a panel embedded over Hub NPCs/stations.

Preserve Hub cast, stations and navigation. Personal Home hosts character/style selection, companions/perch behavior, private decoration/display slots and compatible personal Stash/loadout access. Persist customization, selected character and companion ownership/selection. Entry, menus and return must consume mobile touch; no combat input leakage.

Implementation: `personal_home.tscn` is a separate PackedScene and sibling of `hideout_ui`. The main Hub uses its existing canonical backdrop/residents. Personal Home reuses the accepted painted storage interior, accepted idle bodies and personal display art. Existing safe preferences/collection menu components are parented inside the Home scene; the Hub is hidden, not active underneath. Shared Stash/profile menus remember the private return destination. Missing companion state art remains unavailable; no placeholder body is promoted.
