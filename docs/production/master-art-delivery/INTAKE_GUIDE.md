# Master artist intake

The frozen master specification remains unchanged. `batches/INDEX.json` partitions every outstanding contract and all8,495artist files; each ordinary batch contains up to6cells from one entity/family/facing. `NEXT_ART_BATCH.json` deliberately spans all seven Lootlings but requests individual PNGs, not a mixed identity board. Its items retain the complete master contracts and each mandatory file.

Place files under `art/source/master_artist_delivery/` followed by their exact `source_delivery_path`. Folder names, case, body names, combined foreground layers and sidecars must remain exact. Do not put ZIPs, boards or helper scripts in the inbox. Nothing is moved from accepted art.

Using the project's existing Python/Pillow runtime:

```
python tools/master_artist_intake.py
python tools/master_artist_intake.py --batch docs/production/master-art-delivery/NEXT_ART_BATCH.json
```

Default operation is read-only except its JSON report. Unknown files, unsafe paths, wrong canvases, absent RGBA transparency, empty layers, out-of-bounds alpha and destination collisions fail. Missing mandatory files/layers, unresolved measurement markers, schema violations, wrong identity/state/view/family metadata or inconsistent measured anchors require artist correction. Hashes, actual alpha bounds, baseline/pivot and canonical reference fingerprints are checked. A combined foreground image is mandatory where specified; unspecified split layers are not silently accepted.

PASS means **structural validation only**. Pixels cannot reliably prove canonical identity, hidden weapons/VFX, anatomy, pose correctness or grip quality through schema checks. Those require a trusted perceptual/native review. `ART_REVIEW_APPROVALS.json` stores one entry per exact slot with reviewer, review_note, the complete file_sha256 map emitted by validation, and all eight true review fields: canonical_identity, anatomy, pose_facing, contact_fit, baked_modular_equipment_absent, temporal_vfx_absent, native_phone, native_tablet. Changing any PNG or sidecar invalidates that approval. Artist declarations never populate this log automatically.

`--apply` is an explicit, guarded action. Every selected cell must pass, have hash-bound review and a supported adapter. It preserves all existing destinations and accepted manifest cells, builds all operations before mutation, adds exact manifest entries, runs the existing canonical guard and rolls back its new files/manifest on failure. It never mirrors, masks, stretches, invents palms, aliases a missing state or grants native acceptance. No apply or art installation occurred while preparing intake.

## Automatic registration boundary

The first adapter uses the existing extracted-playable manifest for non-Bow idle, windup, strike_or_cast, recovery and hurt, with independently measured body/hand/Core anchors and combined foreground layer. Existing accepted frames remain untouched. Runtime phases map to IDLE, ANTICIPATE, ATTACK, RECOVER and HURT.

Other cells validate across the whole game but remain outside active runtime until their exact selector/guard adapters are implemented:

- Bow release/string/nock/arrow states; current approved special importer accepts only two Gloomlet windups.
- Movement, follow-through, defeat and victory-return exact selectors; no implicit state aliases.
- Enemy/elite/NPC/merchant activity registration and authored launch/prop anchors.
- Boss approved-path/source gates, named attack recovery and phase/vulnerability selection.
- Companion guard currently deliberately fixes two original extracted idles; new follower/perch states need guarded expansion.
- Separate Home backdrop, movable props, front rims, save migrations and interaction state machine.
- Family-wide support packets are validation/delivery indexes, not automatically loaded runtime data.

This boundary prevents a valid delivered file being mistaken for an implemented runtime feature. Missing adapter work is reported separately from artist corrections. No APK is produced.
