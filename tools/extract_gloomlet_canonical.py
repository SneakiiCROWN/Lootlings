"""Deliberate silhouette mask of existing approved board pixels; no repainting."""
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
source=ROOT/'art/reference/canonical/characters/Gloomlet_CharacterSheet_Canonical.png'
body=Image.open(source).convert('RGBA').crop((0,765,166,954))
outline=[(44,6),(48,7),(62,22),(74,35),(76,25),(86,41),(91,41),(99,32),(99,40),(110,42),(120,31),(124,25),(123,34),(137,20),(151,8),(154,7),(156,13),(155,34),(163,32),(159,48),(163,48),(158,63),(151,72),(160,73),(154,81),(143,85),(146,89),(153,94),(150,97),(142,99),(137,104),(150,114),(158,129),(156,152),(148,159),(144,165),(148,175),(143,170),(135,165),(132,174),(139,180),(138,186),(118,188),(111,185),(110,175),(99,180),(88,178),(77,176),(70,181),(65,187),(50,187),(51,182),(59,173),(58,165),(42,175),(39,174),(41,163),(47,158),(32,160),(28,156),(26,150),(27,142),(30,135),(28,133),(24,136),(25,130),(35,122),(43,114),(45,110),(60,104),(52,100),(44,97),(49,96),(39,93),(38,91),(49,88),(40,86),(41,82),(36,78),(39,77),(32,73),(37,72),(35,66),(32,62),(31,56),(33,50),(30,47),(31,40),(35,33),(39,35)]
mask=Image.new('L',(166*4,189*4));ImageDraw.Draw(mask).polygon([(x*4,y*4) for x,y in outline],fill=255)
body.putalpha(mask.resize(body.size,Image.Resampling.LANCZOS))
body=body.crop(body.getbbox());body.thumbnail((480,480),Image.Resampling.LANCZOS)
# Enlarge only to match the existing sprite convention; source stays intact.
scale=480/max(body.size);body=body.resize((round(body.width*scale),round(body.height*scale)),Image.Resampling.LANCZOS)
canvas=Image.new('RGBA',(512,512));canvas.alpha_composite(body,((512-body.width)//2,(512-body.height)//2))
canvas.save(ROOT/'art/sprites/lootlings/gloomlet_idle.png')
