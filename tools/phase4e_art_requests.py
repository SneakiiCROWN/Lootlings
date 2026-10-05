"""Export per-asset delivery requests from the unchanged active replacement register.
No image creation, extraction, asset import, or canonical approval.
"""
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[1]
base=ROOT/'docs/production/phase4e/polish'
debt=json.loads((base/'support-art-debt.json').read_text(encoding='utf-8'))
poses=json.loads((ROOT/'art/production_pose_manifest.json').read_text(encoding='utf-8'))
actors=['relic_beast','emberhorn','mosskin','moonkip','pebblewyrm','glimmerfin','gloomlet','vault_runner','ruin_warden','nightstage_drifter','velvet_astrologer','ashtrail_hunter']
bosses={}
for line in (ROOT/'boss_patterns.gd').read_text(encoding='utf-8').splitlines():
    match=re.search(r'"([a-z_]+)":\{.*?"calls":\[(.*?)\]',line)
    if match: bosses[match[1]]=list(dict.fromkeys(re.findall(r'"([^"]+)"',match[2])))
requests=[]
for line in (base/'CANONICAL_REPLACEMENTS.md').read_text(encoding='utf-8').splitlines():
    if not line.startswith('| ') or ' / ' not in line and not line.startswith(('| patch |','| sera |','| ilex |')): continue
    cols=[part.strip() for part in line.strip('|').split('|')]
    asset=cols[0].split(' / ')[0]
    if asset in actors:
        category='playable'
        size=[512,512] if asset in actors[:7] else [1024,1536]
        states=['idle/READY','movement','WINDUP','RELEASE/ATTACK','IMPACT/follow-through','RECOVER','HURT','defeat','victory/return']
        sockets=['primary palm','secondary palm','core','feet baseline','foreground fingers','bow nock if applicable','weapon socket/launch point']
    elif asset in bosses:
        category='boss';size=[2048,2048]
        states=['idle','phase transition','hurt','vulnerability/recovery','defeat']+[call+' windup/commit/recovery' for call in bosses[asset]]
        sockets=['body/hip pivot','ground or hover baseline','attack contact/launch point','effect anchor','tail root/tip for dragon']
    elif asset in ['patch','sera','ilex']:
        category='resident';size=[1024,1536];states=['rest','route/walk','work/read/tend','inspect','talk','sit']
        sockets=['primary palm','secondary palm','prop contact','feet baseline','head direction']
    else:
        category='regional enemy';size=[1024,1024];states=['idle','role windup','role commit','hurt','recovery','defeat']
        sockets=['body pivot','ground or hover baseline','attack contact/launch point','effect anchor']
    requests.append(dict(asset_id=asset,name=cols[0],category=category,current_problem=cols[1],canonical_identity=cols[2],
        required_canvas=size,format='PNG RGBA / transparent / uncropped full silhouette; retain good existing export canvases',
        views=['right','left'],required_states=states,rig_reuse=cols[4],socket_metadata=sockets,
        authored_support_cells=[cell for cell in debt['cells'] if cell['actor']==asset],
        preserve_existing_authored_rows=[row for row in poses['entries'] if row['actor']==asset and row['production_status']=='authored_beta'],
        approval_status='EXTERNAL APPROVED PACKAGE REQUIRED; TEMP art is not accepted',contract='ART_EXPORT_CONTRACT.md'))
assert len(requests)==52 and len([r for r in requests if r['category']=='playable'])==12
assert sum(len(r['authored_support_cells']) for r in requests)==165
out={'authority':'CANONICAL_REPLACEMENTS.md; this file is a derivative delivery specification, not a replacement queue',
     'register_rows':52,'authored_support_cells':165,'requests':requests,
     'current_merchant_requirement':{'role':'Pack Peddler / Merrow Vane','not_new_home_resident':True,'canvas':[1024,1536],
         'format':'PNG RGBA transparent full body','views':['right','left'],'states':['rest','talk','offer','inspect','return'],
         'sockets':['primary palm','secondary palm','offer prop','feet baseline'],'canon':'Existing portrait and written merchant identity',
         'status':'EXTERNAL APPROVED PACKAGE REQUIRED'}}
(base/'replacement-export-requests.json').write_text(json.dumps(out,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print('52 exact register entries; 165 existing support cells; current merchant role delivery requirement; no art created/imported')
