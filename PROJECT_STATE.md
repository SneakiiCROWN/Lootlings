# Lootlings current project state — 2026-10-02

Phase 2 tranche 1 follows the audited baseline on `codex/phase2-vertical-slice`. [PRODUCTION_PHASE2.md](PRODUCTION_PHASE2.md) owns subsequent slice changes and acceptance limits: clearer Act I windups/damage trails, nonblocking queued notices, boss reward hierarchy, and guarded full-flow/native regressions. Implementation checkpoint: `7346b72`. Tranche 2 checkpoint `cc19b29` adds two focused real-paw Relic Beast greatsword bodies and planted-foot motion, native touch/safe-area validation, reproducible signed S23 debug APK and bounded device telemetry. Corrected isolated smoke seeds repeat at 3/5; difficulty is unchanged. Physical device and commercial acceptance remain pending.

The current audit authority is [AUDIT_REPORT.md](AUDIT_REPORT.md), with per-file inspection/status records in [file-status.csv](docs/audit/2026-10-02/file-status.csv). Historical claims are preserved in [the prior snapshot](docs/audit/2026-10-02/historical-PROJECT_STATE.md); chronological counts there are not current totals.

Lootlings is a working Godot 4.7.2 prototype, not a production-complete release. Five adult Wanderers and seven Lootlings are selectable; twelve weapon families are mechanically live. Ten campaign destinations, encounter groups/AoE, inventory/economy, Forge evolutions, residents, lore, wardrobe compatibility contracts and audio hooks are live and tested. No audit balance redesign was performed.

Authored pose manifest: 246 rows, 62 authored entries, twenty-two body textures. Existing 100 adult phase states remain verified; the focused creature fixture checks nine states and actual combat-clock transitions. Full weapon matrix: 144 actor/family combinations and 864 facing/phase checks. **82 right-facing / 83 left-facing support-hand/paired combinations remain incomplete.** Mathematical fit is not anatomical art completion. Missing creature, bow/crossbow/paired poses and Gloomlet's own body remain BETA/MISSING.

Save fixtures now require disposable user storage. Eight persistent stores use validated temporary writes and prior-good backups. Focus/suspend pauses safely; return requires the existing Resume action; close persists committed state. These changes do not provide a resumable run, a cross-store transaction, or recovery from every parseable malformed value.

Windows/Android export presets now exist and exclude development/reference material. Windows PCK boot and exclusions passed. Official Android template/local SDK export and debug signing now pass for the arm64 S23 test APK; physical device testing and release signing remain pending. Mobile texture, frame-rate and safe-area budgets are release blockers. Audio remains eight procedural mono 16 kHz placeholder banks; final masters are missing.

Run `python tools/run_qa.py` and `python tools/run_qa.py --native` with `GODOT` pointing to the engine. See the audit for exact results, qualifications and production order.
