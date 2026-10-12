# 0.4.73 — canonical device branding and illustrated startup

Runtime **90fac903**; initial source **7a29c95e**, owner Android **code84**. Source pushed; delivery evidence checkpoint follows. The full game is not artistically final. Physical S23 launcher/startup acceptance remains pending.

## Actually installed

- New `launch_presentation.tscn` is the application entry scene. It paints an aspect-appropriate illustrated moonlit scene before loading the unchanged game. No fixed-duration delay, pretend progress percentage, fake button or separate menu. Foreground loading retains the established reliable resource path.
- Three startup layouts derive from the accepted portrait/tall/wide Sera/Gloomlet title paintings. Original logo lettering/colours are copied, not regenerated. The startup-only wordmark removes unrelated side fragments. The original menu source/wordmark/music remain unchanged.
- Launcher icon derives from exact approved `art/sprites/relic_beast_base.png` pixels, checked against `art/reference/canonical/characters/Lootlings_Main_Mascot_RelicBeast_Canonical.png`. Original eyes, face, two dark/gold horns, ears, fur and gold Core retained. Approved blue logo-crystal accent is separate; no replacement blue chest gem.
- Installed Android legacy icon, adaptive foreground/background, monochrome and system splash icon. Complete foreground falls within264px core safe circle on432px canvas; circle, rounded-square and squircle previews inspected. Themed icon negative-space eyes/nose come from the canonical source, not invented features. Windows PE icons verified at16/32/48/64/128/256px.
- Binding paths now point to `art/ui/brand/073/`. Original branding resources and all0.4.72 EXE/PCK/APK files remain unchanged as rollback files.

The two owner attachments are retained under `art/source/branding073/` as **direction only**. Their altered mascot details were not promoted into canon or installed. No new AI-generated face/logo/art candidate was created; this pass extends the existing canonical-pixel branding tools.

## Evidence and limitations

Final exact pack: cold first-rendered scene and real title handoff, plus four responsive layout/handoff checks pass without script errors or shutdown leaks. Earlier0.4.73 pack also passed six-size menu controls/music and72 owner reopen attempts. Those menu/gameplay/SHH GDCs are byte-identical in final0.4.73 and delivered0.4.72. **18 final packaged resources** match between Android and tested Windows, including new loading code/scene/imports and original title/music imports.

The first layout fixture had a wrong screenshot scene handle; fixed. A threaded-loading experiment produced zero-reference shutdown leaks and was removed. A caption encoding/font-weight defect was caught in native images and corrected. Rejected experimental logs remain clearly separated. Final cold/layout/native app startup logs are clean.

Native screenshots inspected at360×640,1080×2340,1600×2560 and1920×1080. Aspect-specific cover rendering avoids stretch and blank bars in the game loading scene. Cold timing includes screenshot capture/encoding overhead and desktop conditions; it is not a phone startup benchmark. Colour/themed icon previews use the **actual exported resources**, not a screenshot of Samsung's launcher.

Android12+ requires a system icon/background splash before the game's illustrated scene. The previous stray-fragment navy Godot picture is no longer bound. The OS's brief solid-colour stage is not represented as a full-screen illustration. [Android splash-screen requirements](https://developer.android.com/develop/ui/views/launch/splash-screen).

Final APK: arm64, signed/zip-aligned, same `com.sneakiicrown.lootlings.owner` identity and same prior certificate. Existing saves/owner isolation untouched. Main Menu/title music/source assets preserved. Real S23 launcher mask/cache, startup timing, performance and final appearance require owner testing; **not passed**. Windows executable startup and embedded icon checks pass.

## Files and remaining work

Runtime: `launch_presentation.gd`, `launch_presentation.tscn`, authorized branding/entry keys in `project.godot`, and `export_presets.cfg`. Assets:8 PNG resources +1 ICO in `art/ui/brand/073/`, with provenance. Tooling: `tools/build_branding_073.py`, preset-aware Android/Windows branding verifiers and two native fixtures. Store manifest records active bindings and pending layout acceptance. Unrelated owner settings/files preserved.

No new frozen pose/art contract closures: **2,753 contracts /7,166 artist requirements remain**. Hub/Home lighting/depth/full-wide composition, fluid NPC/companion activity, approved authored title contact/blink animation, dialogue/UI/HUD and broader canonical animation/content work remain open in the existing dashboard/continuation. This branding milestone does not grant full-game or commercial artistic acceptance.

Build paths/hashes: `DELIVERY.json`. Resource previews: `EXPORTED_ICON_PREVIEWS.png`. Actual first native loading frame: `ACTUAL_COLD_FIRST_SCENE.png`. Phone/tablet/desktop captures under `screenshots/`; final logs under `exported-0732/`.
