from pathlib import Path
import json,hashlib,importlib.util
ROOT=Path(r'C:/Users/Snkii/Documents/lootlings')
SOURCE=Path(r'C:/Users/Snkii/.codex/generated_images/01a119ec-aee5-7460-8419-3c1df0c7363f')
ACTORS={'relic_beast':'658d7a90-bd92-47e9-b926-af5895d16d71','emberhorn':'7fc767f5-19db-42c1-94ee-e205cee1db55','mosskin':'f8d8ced4-b296-498f-a30c-4744c019b41b','pebblewyrm':'5bb38200-3a2f-4117-bb2c-b53b4e0ece0f','glimmerfin':'22b54cbc-9a33-46a9-8de2-eb086356cbb1','moonkip':'1ada7589-0203-4426-b2f1-1fa2a166e884','gloomlet':'be170482-0292-472b-9f08-935623357c1d','vault_runner':'1105565d-538e-4a24-81b1-254e3156fce1','ruin_warden':'3e4ca97b-28df-4f8f-80d1-8311d6838af0','nightstage_drifter':'1d33582a-f60e-4d8b-bc7d-cf872d08ec87','velvet_astrologer':'6924e265-f7ef-4cb5-a476-20ac62171e62','ashtrail_hunter':'8f05b3f4-061d-42c7-becf-d4afbd7ec08c','walk_correction_group':'f2d5bbd5-6ffb-4615-a02e-66805bcc9048'}
folder=ROOT/'art/source/player_motion_044';folder.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('components',ROOT/'tools/sheet_alpha_components.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
rows=[];components={}
for actor,ident in ACTORS.items():
 source=SOURCE/('exec-'+ident+'.png');target=folder/(actor+'.png');data=source.read_bytes()
 if target.exists():assert target.read_bytes()==data,'Never overwrite recoverable work'
 else:target.write_bytes(data)
 c=mod.components(target);components[actor]=c
 from PIL import Image
 image=Image.open(target)
 rows.append(dict(actor=actor,source=target.relative_to(ROOT).as_posix(),original=str(source),sha256=hashlib.sha256(data).hexdigest(),size=image.size,candidate_cells=len(c),integrated=False,production_quality_accepted=False))
 print(actor,image.size,len(c),[x['bounds'] for x in c])
(folder/'RECOVERED_SOURCES.json').write_text(json.dumps(dict(base_checkpoint='e6ee811',tool='built-in image_gen',notes='Recovered interrupted candidates, not runtime accepted. Exact pre-interruption prompt logs unavailable in local repo; do not imply source recovery is contract closure.',sources=rows),indent=2)+'\n')
(ROOT/'.godot_test_data/components_044.json').write_text(json.dumps(components))