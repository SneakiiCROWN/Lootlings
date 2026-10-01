# RESEARCH NOTES — CURRENT PLATFORM / ENGINE ART REQUIREMENTS

Research checked October 2026.

## Google Play
Current Play Console guidance requires:
- Play store icon: 512 x 512 PNG with alpha
- feature graphic: 1024 x 500 JPEG/24-bit PNG, no alpha
- at least two screenshots across device types
- for games, at least three strong 9:16 screenshots at minimum 1080x1920
  (or three 16:9 landscape screenshots) are recommended for recommendation
  surfaces

Store screenshots should represent the actual game experience.

## Apple App Store
App Store Connect currently supports 1–10 screenshots per supported device
family and publishes specific accepted sizes for current iPhone/iPad classes.
Prepare composition-safe high-resolution masters rather than baking one exact
device crop into promotional art.

## Godot 2D Art
Godot documentation recommends lossless compression for most ordinary 2D
textures. Large 2D artwork can use lossy compression when visual inspection
shows the quality remains acceptable. PNG is appropriate when alpha is needed;
JPEG has no transparency.

## Production Consequence
Keep:
- high-resolution masters
- clean alpha assets
- text-free runtime art
- separate UI text
- safe central composition
- runtime-optimized derivatives

Do not use store screenshots as fake mockups; capture the real integrated game.
