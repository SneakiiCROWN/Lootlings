"""Original vector sprite candidates, labelled BETA; no external art or raster generation."""
from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]/'art/sprites/enemies/beta'
root.mkdir(parents=True,exist_ok=True)
shapes={
'hound':'''<path fill="#456475" d="M36 132 52 97 82 76 118 88 144 104 160 140 150 173 126 173 119 148 79 144 66 174 43 174Z"/><path fill="#91b5bc" d="M31 86 48 45 62 75 93 65 122 43 117 88 131 110 113 141 63 140 34 119Z"/><path fill="#3d546c" d="m37 91 42-9-12 36-30-5Zm75-10-21 6 14 29 19-12Z"/><path fill="#e5c180" d="m23 100 22-9 12 19-13 14-16-8Z"/><path fill="#eff0d4" d="m42 114 13 6-4 14-7-10 0 9-7-13Z"/><path fill="#b6d7cf" d="m126 108 46-29-7 33-26 30Z"/><path fill="#e7be65" d="m69 130 25 9 22-11-7 23-20 7-21-13Z"/>''',
'bat':'''<path fill="#516780" d="m84 87-36-43-30 17 5 33-15 43 37-17 8 23 31-24Zm32 0 36-43 30 17-5 33 15 43-37-17-8 23-31-24Z"/><path fill="#85d1d9" d="m78 89-31-28-20 9 20 38 8 16 25-20Zm44 0 31-28 20 9-20 38-8 16-25-20Z"/><path fill="#628b97" d="m72 98 9-45 15 22 12-1 17-21 6 46-10 57-20 19-23-20Z"/><path fill="#c8eef1" d="m81 111 39 0-6 24-15 13-14-12Z"/><path fill="#ebc16b" d="m88 143 12 9 15-11-6 23-12 8-11-18Z"/><path fill="#3c4e6c" d="m35 69 21 28-10 12Zm129 0-21 28 10 12Z"/>''',
'toad':'''<path fill="#3d6469" d="m29 144 22-49 26-10 49 0 29 19 18 42-28 23-30-14-26 2-39 16Z"/><path fill="#92b992" d="m44 124 4-45 27-17 21 13 15 0 22-13 29 20-3 44-24 26-63-1Z"/><path fill="#d9c98d" d="m58 135 86 0-14 21-57 2Z"/><path fill="#526f56" d="m54 76 23-2 13 23-36 3Zm58 17 13-18 25 3 5 23Z"/><path fill="#f5cd6c" d="m92 111 15-5 10 14-7 13-20-1-4-13Z"/><path fill="#dbedbb" d="m37 145 23 6-4 11-23 2Zm105 7 23-6 9 19-28-3Z"/>''',
'crab':'''<path fill="none" stroke="#556d7d" stroke-width="13" d="m55 134-34 8-6 25m43-13-25 19-3 13m111-52 33 7 6 25m-44-12 27 19 3 13"/><path fill="#8ab4b6" d="m46 106 33-29 42 0 32 30-11 52-45 16-42-20Z"/><path fill="#3c6276" d="m81 83 18 7 18-8 6 43-24 25-26-24Z"/><path fill="#e8c37f" d="m76 110 24-8 24 9-8 34-17 14-17-15Z"/><path fill="#86b1b0" d="m52 120-26-19-16-41 27-7-3 24 13-23 22 21-16 22 18 21Zm97 0 27-19 16-41-27-7 3 24-13-23-22 21 16 22-18 21Z"/><path fill="#d2eff0" d="m73 80-4-26 12-1 5 28m29 0 4-28 13 1-7 26Z"/>''',
'beetle':'''<path fill="none" stroke="#6a6979" stroke-width="10" d="m61 96-30-13m29 37-32 6m35 13-22 24m98-67 30-13m-29 37 32 6m-35 13 22 24"/><path fill="#8a8494" d="m55 80 24-20 46 0 24 20 5 46-20 37-33 17-34-17-17-37Z"/><path fill="#b6cbbc" d="m79 69-21 22 1 42 36 28 1-79Zm44 0 21 22-1 42-36 28-1-79Z"/><path fill="#586779" d="m98 72 7 0 2 99-10 0Z"/><path fill="#edb66c" d="m76 48 7-22 18 17 20-17 6 24-14 25-22 0Z"/><path fill="#f3ddb0" d="m71 116 15 4-4 15-11-5Zm60 0-15 4 4 15 11-5Z"/>''',
'wyrm':'''<path fill="#64788c" d="m143 116 28-15 9 14-7 26-23 23-37 12-43-8-28-24-2-37 18-35 28-18 27 10 6 23-12 13-17-6-8 18 7 25 32 11 27-14Z"/><path fill="#bbd9d2" d="m55 110 12-17 10 7-8 20 8 22 25 12 34-1-25 14-31-10-25-24Z"/><path fill="#e7bd7b" d="m72 54 1-25 22 19 25-9-8 26-19 13Z"/><path fill="#536582" d="m94 80 26 11-8 21-18-4-8-14Z"/><path fill="#d4e5df" d="m63 77 18-1 0 13-19 7Z"/><path fill="#eac68c" d="m140 124 11-13 8 15-13 11Z"/>''',
'shard':'''<path fill="#47647e" d="m99 25 36 55-7 61-28 33-30-33-5-61Z"/><path fill="#a6dfe4" d="m98 37-24 46 26 41-3-70Zm10 21 20 26-18 40-5-13Z"/><path fill="#6389a9" d="m77 94-1 38 20 28 4-25Z"/><path fill="#d8f7ed" d="m105 132 15-29-2 32-11 17Z"/><path fill="#e9be76" d="m82 84 20-10 19 12-10 23-22-2Z"/><path fill="#86c5ca" d="m40 71 15 22-9 22-11-21Zm113 8 16 17-8 20-11-20Z"/><path fill="#f1d18a" d="m78 38-8-14 20 9 10-15 10 15 20-9-8 14Z"/>'''}
for name,body in shapes.items():
 # Deliberate dark ink outline, three-value shading, warm relic fittings, eyes.
 eyes={'hound':(64,105,102,101),'bat':(86,106,113,106),'toad':(72,90,134,92),'crab':(75,62,123,62),'beetle':(87,52,115,52),'wyrm':(70,83,97,88),'shard':(90,90,111,91)}[name]
 eye=''.join(f'<ellipse cx="{x}" cy="{y}" rx="7" ry="9" fill="#d6eae4" stroke="#18243d" stroke-width="2"/><ellipse cx="{x-1}" cy="{y+1}" rx="4" ry="6" fill="#2c324d" stroke="none"/><circle cx="{x-2}" cy="{y-2}" r="2" fill="#fff1c5" stroke="none"/>' for x,y in [eyes[:2],eyes[2:]])
 # Three-value material shading, kept inside the strong ink silhouette.
 defs=[]
 for i,color in enumerate(sorted(set(re.findall(r'fill="(#[0-9a-fA-F]{6})"',body)))):
  rgb=[int(color[k:k+2],16) for k in (1,3,5)]
  lighter='#'+''.join(f'{min(255,int(v*.75+64)):02x}' for v in rgb)
  darker='#'+''.join(f'{int(v*.66):02x}' for v in rgb)
  defs.append(f'<linearGradient id="shade{i}" x1="0" y1="0" x2=".7" y2="1"><stop stop-color="{lighter}"/><stop offset=".45" stop-color="{color}"/><stop offset="1" stop-color="{darker}"/></linearGradient>')
  body=body.replace(f'fill="{color}"',f'fill="url(#shade{i})"')
 text=f'<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 200 200"><defs>{"".join(defs)}</defs><g stroke="#18243d" stroke-width="3" stroke-linejoin="round" stroke-linecap="round">{body}{eye}</g></svg>'
 (root/f'regional_{name}.svg').write_text(text,encoding='utf-8')
print('Seven original BETA silhouette sprites written')
