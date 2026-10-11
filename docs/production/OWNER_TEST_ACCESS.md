# Owner testing — SHH, no PIN

Install the separate Lootlings Owner Test app (com.sneakiicrown.lootlings.owner). Regular Android builds omit the owner feature. The owner app and its test sandbox retain separate saves.

On the visible title screen, hold anywhere on the painted LOOTLINGS wordmark for two seconds, then release. Short holds do not unlock. This replaces the physically unreliable seven-tap crystal gesture in 0.4.60; no PIN or networking is involved. Backup: Settings → Support → OWNER TOOLS, shown only in the owner test build.

Unlock opens the existing F1 developer panel in the isolated sandbox. Windows F1 remains available. Close the panel to play. Tap the compact SHH button to reopen; hold it for one second, then drag. Its normalised preferred position is saved and constrained to the fitted safe game area. It avoids active controls and may temporarily relocate/hide where the preferred position would overlap them. Diagnostics offers RESET SHH POSITION, HIDE SHH and RELOCK SHH. The backup route restores a hidden shortcut.

Existing four tabs and commands are retained, including grants, numeric wallets, Mythicals, Ward/Sigils, perks and save/reload. RETURN TO NORMAL PROFILE restores the owner app's normal profile; no test data transfers to the regular app. RESET remains sandbox-only and confirmation-protected.

Three simulated layouts and exact exported Windows pack owner/normal boundaries pass. Hidden/unlocked/position preferences survived separate fresh processes. Actual S23 touch/audio acceptance is pending. These are debug-signed candidates, not store releases or security controls.
