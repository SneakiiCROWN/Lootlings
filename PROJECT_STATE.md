# Lootlings current project state — 2026-10-02

The current audit authority is [AUDIT_REPORT.md](AUDIT_REPORT.md), with per-file inspection/status records in [file-status.csv](docs/audit/2026-10-02/file-status.csv). Historical claims are preserved in [the prior snapshot](docs/audit/2026-10-02/historical-PROJECT_STATE.md); chronological counts there are not current totals.

Lootlings is a working Godot 4.7.2 prototype, not a production-complete release. Five adult Wanderers and seven Lootlings are selectable; twelve weapon families are mechanically live. Ten campaign destinations, encounter groups/AoE, inventory/economy, Forge evolutions, residents, lore, wardrobe compatibility contracts and audio hooks are live and tested. No audit balance redesign was performed.

Authored pose manifest: 246 rows, 60 authored entries, twenty body textures, 100 tested phase states. Full weapon matrix: 144 actor/family combinations and 864 facing/phase checks. **83 support-hand/paired combinations remain incomplete in each facing.** Mathematical fit is not anatomical art completion. Missing creature, bow/crossbow/paired poses and Gloomlet's own body remain BETA/MISSING.

Save fixtures now require disposable user storage. Eight persistent stores use validated temporary writes and prior-good backups. Focus/suspend pauses safely; return requires the existing Resume action; close persists committed state. These changes do not provide a resumable run, a cross-store transaction, or recovery from every parseable malformed value.

Windows/Android export presets now exist and exclude development/reference material. Windows PCK boot and exclusions passed. Executable/APK signing, export templates, Android SDK and actual device tests remain unverified. Mobile texture, frame-rate and safe-area budgets are release blockers. Audio remains eight procedural mono 16 kHz placeholder banks; final masters are missing.

Run `python tools/run_qa.py` and `python tools/run_qa.py --native` with `GODOT` pointing to the engine. See the audit for exact results, qualifications and production order.
