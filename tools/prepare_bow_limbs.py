"""Separate the painted bow limbs from their static string, preserving source art.

The runtime supplies a tensioned string and nocked arrow. No generated pixels.
Source remains unchanged; the mask removes only the thin string between ties.
"""
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parents[1]
source = Image.open(ROOT/'art/sprites/weapons/ranger_bow.png').convert('RGBA')
mask = Image.new('L', source.size, 0)
# Coordinates measured on the 1305x1205 approved export; tie ornaments retained.
assert source.size == (1305, 1205)
ImageDraw.Draw(mask).line([(548,1030),(1135,340)],fill=255,width=64)
source.paste((0,0,0,0),mask=mask)
source.save(ROOT/'art/sprites/weapons/bow_held.png')
print('Prepared canonical bow limbs; original export unchanged.')
