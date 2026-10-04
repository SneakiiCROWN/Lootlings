# Relic Spinner follow-up — implemented, awaiting S23 acceptance

Started 2026-10-04; completed 2026-10-05. This is a separately checkpointed follow-up on `codex/relic-spinner-followup`, based on the verified Phase 4C QA commit `0664e4eb298d8de33e1d89b003c5a180e71d5e5b`. Implementation checkpoint: `1a372732bc015a68cd60685778e433d696dd0dd2`. Phase 4C's source branch, evidence and APK remain preserved.

See [implementation, measured economy, native evidence and sign-off](docs/production/relic-spinner/REPORT.md). **GO for S23 owner testing; HOLD for commercial release.**

New APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-relic-spinner-debug.apk`, version code 11 / `0.4.2-relic-spinner`. The existing package/signing key and player saves are retained. The original Phase 4C APK remains `builds/android/Lootlings-phase4c-presentation-debug.apk`.

Install the spinner APK over the existing app without clearing data. After an eligible run (10+ kills, at least 140 leftover currency), open Relic Spinner, inspect Pool & Odds, run one full spin and a repeated low-tier Fast Spin/Skip. Check the immediate wallet/progress update, resume once, then reopen the app and confirm rewards/progress persisted. Forge RED only if already holding 24 Crownroot fragments; no grinding or forced unlock is needed for this retest. Report faults with the screen/action and a screenshot or short clip.

Implementation: `relic_spin_catalog.gd` owns disclosed rewards/rarity profiles; `relic_machine.gd` owns animation/sound signals; `endgame_progress.gd` commits debit/reserved rewards/chase atomically; `retention_runtime.gd` owns UI and existing receipt delivery. Native and economy fixtures live in `tests/relic_spinner*`; evidence packaging is `tools/relic_spinner_evidence.py`.
