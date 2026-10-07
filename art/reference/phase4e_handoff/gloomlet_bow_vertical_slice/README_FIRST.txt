LOOTLINGS — GLOOMLET BOW CODEX HANDOFF v1

PURPOSE
This pack is a focused handoff for the Gloomlet + Bow polished combat vertical slice.
It does NOT claim the whole game, all Gloomlet states, or all Phase 4E art is finished.

AUTHORITY
1) canonical_reference/Gloomlet_CharacterSheet_Canonical.png is the identity authority.
2) pose_reference_boards/* are choreography / hand-position / weapon-fit references only.
3) generated_pose_candidates/* are transparent weaponless BODY POSE CANDIDATES only.
   They are NOT automatically approved final runtime frames and must not reduce art debt until validated.

IMPORTANT WEAPON RULE
The actual bow should normally remain the existing runtime weapon module (Moonbranch / Gilded Shortbow / other current bow family asset).
Do NOT bake a candidate reference bow into Gloomlet unless explicitly approved for one exact item/state.
The body/hands must be positioned to accept the runtime bow; foreground grip fingers/support hand may be separate overlays.

TARGET RUNTIME CONTRACT
- Entity: gloomlet
- Weapon family: bow
- Final body frame canvas: 512 x 512 RGBA/transparent
- Full silhouette must remain inside a 16 px inset (max occupied bounds 16,16 -> 496,496)
- Target canvas pivot: (256.0, 341.3333333333333)
- Target ground/baseline y: 496
- Mirroring allowed: NO
- Right and left states must be independently validated/authored
- Temporal trails/charge/impact/status VFX remain separate runtime layers
- Bowstring/nocked arrow/drawing palm and foreground fingers must be separated where needed

REQUIRED BOW DELIVERY CELLS
RIGHT: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return
LEFT:  idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return

KNOWN LIMITATION OF THIS PACK
The generated candidates mostly cover READY/DRAW/RELEASE-style body ideas. They do NOT safely close every required cell.
Hurt, defeat/downed, victory_return, some movement/recovery, and exact opposite-facing contacts may still require new authored art.
Do not relabel a similar pose just to make a slot green.

WINDOWS DESTINATION SUGGESTION
C:\Users\Snkii\Documents\lootlings\art\reference\phase4e_handoff\gloomlet_bow_vertical_slice\

After extracting there, paste CODEX_IMPORT_PROMPT.txt into the same Lootlings Codex chat when usage is available.
