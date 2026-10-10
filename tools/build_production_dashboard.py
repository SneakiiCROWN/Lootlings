"""One reproducible coverage/quality dashboard. Existence never grants acceptance.

Contract, requirement-record and file denominators deliberately remain separate.
Only evidence entries bound to current asset hashes may grant quality stages.
"""
from pathlib import Path
from collections import Counter, defaultdict
import hashlib, json, re

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/production'
CONT = OUT / 'full-completion/continuous-production'
STAGES = ['canon_reference_approved', 'created', 'integrated', 'functionally_tested',
          'gameplay_visual_reviewed', 'player_experience_reviewed', 'production_quality_accepted']
STATUSES = ['production_ready', 'functionally_working_visually_unfinished',
            'visually_approved_not_integrated', 'installed_awaiting_visual_review',
            'defective_requires_correction', 'missing', 'reference_or_planned']

def read(path):
    return json.loads((ROOT / path).read_text(encoding='utf-8-sig'))

def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

def build():
    master = read('docs/production/MASTER_INTEGRATION_MANIFEST.json')
    canon = read('docs/production/CANON_REGISTRY.json')
    counts = read(str((CONT / 'CONTINUOUS_PRODUCTION_COUNTS.json').relative_to(ROOT)))
    receipt=read(str((CONT/'REGIONAL_RESIDENT_INSTALLATION_0441.json').relative_to(ROOT)))
    player_receipt=CONT/'PLAYER_COMBAT_INSTALLATION_0443.json'
    if player_receipt.exists():receipt=read(str(player_receipt.relative_to(ROOT)))
    motion_receipt=CONT/'PLAYER_MOTION_INSTALLATION_0444.json'
    if motion_receipt.exists():
        receipt=read(str(motion_receipt.relative_to(ROOT)))
        player_receipt=motion_receipt
    combat_receipt=CONT/'PLAYER_COMBAT_INSTALLATION_0445.json'
    if combat_receipt.exists():
        receipt=read(str(combat_receipt.relative_to(ROOT)))
        player_receipt=combat_receipt
    continuation_receipt=CONT/'COMBAT_CONTINUATION_INSTALLATION_0446.json'
    if continuation_receipt.exists():
        receipt=read(str(continuation_receipt.relative_to(ROOT)))
        player_receipt=continuation_receipt
    remaining = read(str((CONT / 'EXACT_REMAINING_CONTRACTS.json').relative_to(ROOT)))
    evidence_path = 'docs/production/QUALITY_ACCEPTANCE_EVIDENCE.json'
    evidence = read(evidence_path)
    approved = {e['slot_id']: e for e in evidence['entries']}
    source_approvals={}
    frozen=read('art/reference/phase4e_handoff/REFERENCE_STATUS.json')
    for ref in frozen['frozen_sources']:
        if '/characters/' in ref['path'] and 'Art_Bible' not in ref['path']:source_approvals[ref['path']]=ref['sha256']
    for ref in read('art/approved_missing_canon_references.json')['entries']:source_approvals[ref['source']]=ref['source_sha256']
    for ref in read('art/npc_identity_authorities.json')['entries']:source_approvals[ref['canonical_source']]=ref['dedicated_sha256']
    for ref in read('art/reference/canonical/companions/COMPANION_CANON_MANIFEST.json')['reference_files']:source_approvals[ref['path']]=ref['sha256']
    dragon=read('art/hoard_dragon_identity_authority.json');source_approvals[dragon['canonical_source']]=dragon['canonical_source_sha256']
    for path,expected in source_approvals.items():assert sha(path)==expected, 'Approved reference changed: '+path
    identities = defaultdict(list)
    for e in canon['entries']:
        identities[e['stable_id']].append(e)
    approved_identities={e['stable_id'] for e in canon['entries']
                         if e['authoritative_source'].removeprefix('res://') in source_approvals}
    manifests = sorted(p for p in (ROOT / 'art').rglob('*manifest.json')
                       if '/reference/' not in p.as_posix() and '/source/' not in p.as_posix())
    manifests += [ROOT / 'art/production_pose_manifest.json'] if ROOT / 'art/production_pose_manifest.json' not in manifests else []
    registered, manifest_rows = set(), []
    canon_runtime_assets={p.removeprefix('res://') for e in canon['entries'] for p in e['accepted_runtime_sources']}
    live_assets={(r.get('current_production_asset') or '').removeprefix('res://') for r in master['records'] if r['status'] in ('LIVE_BETA','LIVE_FINAL')}
    for p in manifests:
        registered.add(p.relative_to(ROOT).as_posix())
        obj = json.loads(p.read_text(encoding='utf-8-sig'))
        for e in obj.get('entries', []) if isinstance(obj, dict) else []:
            if not isinstance(e, dict): continue
            asset = e.get('asset_path') or e.get('asset')
            if not asset: continue
            asset = asset.removeprefix('res://')
            registered.add(asset)
            manifest_rows.append(dict(manifest=p.relative_to(ROOT).as_posix(), asset=asset,
                                      actor=e.get('actor') or e.get('region') or e.get('id'), state=e.get('state'), facing=e.get('facing'),
                                      native_validated=bool(e.get('native_validated')), exists=(ROOT/asset).is_file()))
    for e in canon['entries']:
        registered.update(p.removeprefix('res://') for p in e['accepted_runtime_sources'])
        source=e['authoritative_source'].removeprefix('res://').split('#')[0]
        if (ROOT/source).is_file():registered.add(source)
    for r in master['records']:
        if r.get('current_production_asset'): registered.add(r['current_production_asset'].removeprefix('res://'))
    rows = []; stale_evidence=[]
    for r in master['records']:
        asset = (r.get('current_production_asset') or '').removeprefix('res://')
        live = r['status'] in ('LIVE_FINAL', 'LIVE_BETA')
        stages = {s: False for s in STAGES}
        sources=r.get('canonical_source') or []
        if isinstance(sources,str):sources=[sources]
        stages['canon_reference_approved']=bool(sources) and all(s.removeprefix('res://') in source_approvals for s in sources)
        stages['created'] = bool(asset and (ROOT/asset).is_file())
        stages['integrated'] = live
        ev = approved.get(r['slot_id'])
        if ev:
            if ev.get('asset'):
                fresh=ev['asset']==asset and (ROOT/asset).is_file() and sha(asset)==ev['asset_sha256']
            else:
                fresh=not asset and ev['implementation']==r['implementation_file'] and (ROOT/ev['implementation']).is_file() and sha(ev['implementation'])==ev['implementation_sha256']
            fresh=fresh and all((ROOT/file).is_file() for file in ev['evidence_files'])
            fresh=fresh and all((ROOT/file).is_file() and sha(file)==expected for file,expected in ev.get('dependencies_sha256',{}).items())
            if not fresh:
                stale_evidence.append(r['slot_id']);ev=None
        if ev:
            for s in STAGES: stages[s] = bool(ev['stages'].get(s))
            assert all(stages[s] for s in STAGES[:-1]) or not stages[STAGES[-1]], 'Premature production acceptance'
        if stages['production_quality_accepted']: quality='production_ready'
        elif ev and ev.get('defects'): quality='defective_requires_correction'
        elif stages['functionally_tested'] and stages['gameplay_visual_reviewed']: quality='functionally_working_visually_unfinished'
        elif stages['integrated']: quality='installed_awaiting_visual_review'
        elif stages['gameplay_visual_reviewed']: quality='visually_approved_not_integrated'
        elif r['status']=='REJECTED_IDENTITY_DRIFT': quality='defective_requires_correction'
        elif r['status'].startswith('NEEDS_'): quality='missing'
        else: quality='reference_or_planned'
        rows.append(dict(id=r['slot_id'], family=r['category'], identity=r['game_id'], name=r['subject'],
                         state=r.get('state'), facing=r.get('facing'), weapon=r.get('weapon_family'),
                         scope=r['launch_scope'], priority=r['priority'], quality=quality, stages=stages,
                         asset=asset or None, canon=r.get('canonical_source'), implementation=r.get('implementation_file'),
                         blocker=r.get('blocker'), defects=ev.get('defects',[]) if ev else [],quality_notes=ev.get('limitations') if ev else 'Prior completion labels are not quality evidence; native visual and usability re-review required.'))
    families=[]
    for family in sorted({r['family'] for r in rows}):
        group=[r for r in rows if r['family']==family]
        actor_ids={r['identity'] for r in group if r['identity']}
        group_assets={r['asset'] for r in group if r['asset']}
        art=[r for r in manifest_rows if (r['actor'] and r['actor'] in actor_ids) or r['asset'] in group_assets]
        families.append(dict(family=family, required_records=len(group), launch_records=sum(r['scope'] for r in group),
                             installed_records=sum(r['stages']['integrated'] for r in group),
                             production_ready=sum(r['quality']=='production_ready' for r in group),
                             quality_counts=dict(Counter(r['quality'] for r in group)),
                             stages={s:sum(r['stages'][s] for r in group) for s in STAGES},
                             canonical_source_files=len({json.dumps(r['canon'],sort_keys=True) for r in group if r['canon']}),
                             recorded_canon_approved_identities=len(actor_ids & approved_identities),
                             manifest_runtime_files=len({r['asset'] for r in art if r['native_validated'] and r['exists']}),
                             staged_manifest_files=len({r['asset'] for r in art if not r['native_validated'] and r['exists'] and r['asset'] not in live_assets and r['asset'] not in canon_runtime_assets}),
                             unreviewed_manifest_files=len({r['asset'] for r in art if not r['native_validated'] and r['exists']}),
                             completed_animation_families=None,
                             animation_note='Per-state frames and metadata are listed separately; no complete motion family inferred from file existence.',
                             priority=min(r['priority'] for r in group)))
    contracts=[]
    for family in sorted(set(counts['remaining_by_category']) | set(counts['installed_by_category'])):
        installed=counts['installed_by_category'].get(family,0); debt=counts['remaining_by_category'].get(family,0)
        assert sum(r['category']==family for r in remaining)==debt
        contracts.append(dict(family=family, required=installed+debt, installed_contract_closures=installed,
                              remaining=debt, production_quality_accepted=None,
                              note='Closure verifies exact delivery contract; family-wide artistic/UX acceptance remains separate.'))
    dependencies=[]
    for p in sorted(list(ROOT.glob('*.gd'))+list(ROOT.glob('*.tscn'))):
        text=p.read_text(encoding='utf-8-sig')
        for resource in sorted(set(re.findall(r'res://art/[^\"\n\r\s\)]+',text))):
            rel=resource.removeprefix('res://')
            if '%' in rel or '{' in rel:
                reason='dynamic resource pattern: per-variant resolution/registration required'
            elif (ROOT/rel).is_dir(): reason='directory/prefix lookup: variant coverage needs explicit resolution'
            elif not (ROOT/rel).is_file(): reason='literal resource absent; resolve dependency'
            elif rel not in registered: reason='runtime literal not registered in current accepted manifests'
            else: continue
            dependencies.append(dict(implementation=p.name, resource=rel, reason=reason))
    # Named domains are coverage queries, not fabricated denominators.
    domains={
        'Playable Lootlings / classes / customization': r'playable|lootling|wanderer|appearance|class|skin|outfit',
        'Wanderers':r'wanderer', 'NPCs / merchants / dialogue':r'resident|npc|merchant|dialogue|story',
        'Enemies / elites / minibosses / bosses':r'enemy|elite|boss', 'Six companions / perches':r'companion|perch',
        'Weapons / armour / jewellery / outfits / equipment':r'weapon|equipment|armour|jewellery|outfit|wardrobe',
        'Items / currencies / chests / relics / collectibles':r'item|resource|currency|chest|relic|collect|achievement',
        'Spells / projectiles / VFX / animations':r'spell|projectile|vfx|effect|pose:|animation',
        'Rewards / progression / upgrades':r'reward|progress|upgrade|perk|affix|achievement',
        'Menus / HUD / icons / interactions / shops':r'ui|screen:|hud|icon|shop|interaction',
        'Regions / backgrounds / layers / interiors / environments':r'world|region|environment|background|interior|layer',
        'Home / Hub / furniture / props':r'home|hub|furniture|prop|station',
        'Audio / music / ambience / SFX / voices':r'audio|music|ambient|sound|voice',
        'Branding / splash / store':r'brand|logo|splash|title|store|icon'}
    domain_coverage=[]
    for name, pattern in domains.items():
        matches=[r['id'] for r in rows if re.search(pattern,' '.join(str(r.get(k) or '') for k in ['id','family','identity','name','implementation']),re.I)]
        domain_coverage.append(dict(domain=name, registered_requirement_records=len(matches), records=matches,
                                    completeness='Registered scope only; dynamic/unregistered dependencies and unspecified variants remain coverage gaps.'))
    inputs=['docs/production/MASTER_INTEGRATION_MANIFEST.json','docs/production/CANON_REGISTRY.json', evidence_path,
            'art/reference/phase4e_handoff/REFERENCE_STATUS.json','art/approved_missing_canon_references.json','art/npc_identity_authorities.json',
            'art/reference/canonical/companions/COMPANION_CANON_MANIFEST.json','art/hoard_dragon_identity_authority.json',
            str((CONT/'CONTINUOUS_PRODUCTION_COUNTS.json').relative_to(ROOT)),str((CONT/'EXACT_REMAINING_CONTRACTS.json').relative_to(ROOT))]
    if player_receipt.exists():inputs.append(str(player_receipt.relative_to(ROOT)))
    return dict(schema_version=1, quality_policy='All seven stages required. Tests/export/file existence do not grant artistic or player-experience acceptance. Old LIVE_FINAL/LIVE_BETA labels are reclassified pending evidence.',
                denominators='Frozen delivery contracts, requested artist-file requirements (including verified compatible reuse), distinct newly created physical files, and broad requirement records are separate. Per-batch receipts give physical file counts. No whole-game completion percentage is asserted.',
                counts=dict(required_contracts=counts['installed_contracts']+counts['remaining_contracts'], installed_contract_closures=counts['installed_contracts'], remaining_contracts=counts['remaining_contracts'],
                            required_artist_files=counts['installed_artist_files']+counts['remaining_artist_files'], installed_artist_files=counts['installed_artist_files'], remaining_artist_files=counts['remaining_artist_files'],
                            current_reviewed_runtime_png_cells=len({frame['asset'] for e in evidence['entries'] if e['stages'].get('gameplay_visual_reviewed') for frame in [e]+e.get('additional_runtime_frames',[]) if (frame.get('asset') or '').endswith('.png') and (ROOT/frame['asset']).is_file() and sha(frame['asset'])==frame['asset_sha256']}),
                            registered_requirement_records=len(rows), production_ready_records=sum(r['quality']=='production_ready' for r in rows)),
                contract_families=contracts, requirement_families=families, domain_coverage=domain_coverage,
                stages=STAGES,statuses=STATUSES,records=rows,registered_manifest_files=manifest_rows,
                remaining_contracts=[{k:r.get(k) for k in ['slot_id','category','entity_id','display_name','state','facing','weapon_family','expected_filename']} for r in remaining],
                unregistered_dependencies=dependencies,
                stale_quality_evidence=stale_evidence,
                current_batch_corrections=receipt['quality_findings'],
                coverage_gaps=['No total artist-file denominator for all audio/UI/environment variations is specified by frozen pose contracts.',
                               'A source-sheet approval does not approve every derived pose or runtime use.',
                               'State keyframes do not constitute complete multi-frame animation families.',
                               'Historical accepted art needs fresh native visual, audio and UX evidence; it is not automatically production-ready.',
                               'Physical Android device performance, listening and launcher review remain pending.'],
                input_sha256={p:sha(p) for p in inputs})

HTML='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Lootlings production dashboard</title>
<style>body{background:#101c2e;color:#e9eef4;font:15px system-ui;margin:0;padding:24px}h1{color:#ffd88b}section{background:#18293e;border:1px solid #456077;border-radius:12px;padding:20px;margin:18px 0}p{line-height:1.6}table{border-collapse:collapse;width:100%;font-size:13px}th,td{text-align:left;padding:10px;border-bottom:1px solid #365064;vertical-align:top}th{color:#ffd88b}input,select,button{background:#243d56;color:white;border:1px solid #6c8ca7;padding:12px;border-radius:7px;margin:5px}a{color:#9cdbff}.scroll{overflow:auto;max-height:650px}.stats{display:flex;gap:18px;flex-wrap:wrap}.stat{padding:14px;background:#24364a;border-radius:9px}.note{color:#b8cbd9}</style>
<h1>Lootlings · complete registered scope & quality</h1><p id="policy"></p><div class="stats" id="stats"></div>
<section><h2>Frozen delivery contracts</h2><p class="note">Installed closures are delivery evidence, not automatic professional acceptance. Artist-file totals count requested body/layer/sidecar requirements, including verified reuse. Per-batch receipts separately count new physical files.</p><div id="contracts"></div></section>
<section><h2>Every registered family</h2><div class="scroll" id="families"></div></section>
<section><h2>Runtime quality stages / requirements</h2><p>Stage order: canon approval → created → integrated → functional test → gameplay visual review → player-experience review → production acceptance. A dot means unverified, not necessarily failed.</p><input id="search" aria-label="Search identity, region, state or screen" placeholder="Search identity, region, state or screen"><select id="family" aria-label="Family"></select><select id="status" aria-label="Quality status"></select><p id="matched"></p><div class="scroll" id="records"></div><button id="more">Show next 250</button></section>
<section><h2>Remaining exact contracts</h2><input id="debtsearch" aria-label="Search remaining contracts" placeholder="Search character, family, state, weapon"><p id="debtcount"></p><div class="scroll" id="debt"></div></section>
<section><h2>Current batch rejection / correction queue</h2><ul id="corrections"></ul><p>No rejected source is installed merely to reduce the backlog. Original source sheets and the quarantined Coal candidate remain recoverable.</p></section>
<section><h2>Unregistered dependencies & coverage gaps</h2><ul id="gaps"></ul><div class="scroll" id="dependencies"></div></section>
<script id="data" type="application/json">__DATA__</script><script>
const d=JSON.parse(document.getElementById('data').textContent),el=id=>document.getElementById(id),esc=x=>String(x??'—').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const table=(heads,rows)=>'<table><thead><tr>'+heads.map(x=>'<th>'+esc(x)+'</th>').join('')+'</tr></thead><tbody>'+rows.map(r=>'<tr>'+r.map(x=>'<td>'+esc(x)+'</td>').join('')+'</tr>').join('')+'</tbody></table>';
el('policy').textContent=d.quality_policy+' '+d.denominators;
el('stats').innerHTML=Object.entries(d.counts).map(([k,v])=>'<div class="stat"><b>'+esc(v)+'</b><br>'+esc(k.replaceAll('_',' '))+'</div>').join('');
el('contracts').innerHTML=table(['Family','Required contracts','Installed closures','Remaining'],d.contract_families.map(r=>[r.family,r.required,r.installed_contract_closures,r.remaining]));
el('families').innerHTML=table(['Family','Requirement records','Recorded canon identities','Manifest runtime files','Staged files','Installed records','Ready','Missing','Review pending','Priority'],d.requirement_families.map(r=>[r.family,r.required_records,r.recorded_canon_approved_identities,r.manifest_runtime_files,r.staged_manifest_files,r.installed_records,r.production_ready,r.quality_counts.missing||0,r.quality_counts.installed_awaiting_visual_review||0,r.priority]));
el('family').innerHTML=['All families',...d.requirement_families.map(r=>r.family)].map(x=>'<option>'+esc(x)+'</option>').join('');el('status').innerHTML=['All quality stages',...d.statuses].map(x=>'<option>'+esc(x)+'</option>').join('');let limit=250;
function render(){const q=el('search').value.toLowerCase(),f=el('family').value,s=el('status').value;const rows=d.records.filter(r=>(f==='All families'||r.family===f)&&(s==='All quality stages'||r.quality===s)&&JSON.stringify(r).toLowerCase().includes(q));el('matched').textContent=rows.length+' matches; showing '+Math.min(limit,rows.length);el('records').innerHTML=table(['Identity / requirement','Family','State / facing / weapon','Quality','Seven stages ✓/·','Evidence limitations'],rows.slice(0,limit).map(r=>[r.id,r.family,[r.state,r.facing,r.weapon].filter(Boolean).join(' / '),r.quality,d.stages.map(s=>r.stages[s]?'✓':'·').join(' '),r.quality_notes]));}
['search','family','status'].forEach(id=>el(id).addEventListener('input',()=>{limit=250;render()}));el('more').onclick=()=>{limit+=250;render()};render();
function debt(){const q=el('debtsearch').value.toLowerCase(),rows=d.remaining_contracts.filter(r=>JSON.stringify(r).toLowerCase().includes(q));el('debtcount').textContent=rows.length+' exact remaining contracts; first 250 shown';el('debt').innerHTML=table(['Contract','Category','Identity','State','Facing','Weapon'],rows.slice(0,250).map(r=>[r.slot_id,r.category,r.display_name,r.state,r.facing,r.weapon_family]));}el('debtsearch').oninput=debt;debt();
el('gaps').innerHTML=d.coverage_gaps.map(x=>'<li>'+esc(x)+'</li>').join('');el('dependencies').innerHTML=table(['Implementation','Resource','Registration gap'],d.unregistered_dependencies.map(r=>[r.implementation,r.resource,r.reason]));
el('corrections').innerHTML=d.current_batch_corrections.map(x=>'<li>'+esc(x)+'</li>').join('');
</script></html>'''

if __name__=='__main__':
    data=build(); payload=json.dumps(data,ensure_ascii=False,indent=2)
    (OUT/'PRODUCTION_DASHBOARD.json').write_text(payload+'\n',encoding='utf-8')
    (OUT/'PRODUCTION_DASHBOARD.html').write_text(HTML.replace('__DATA__',payload.replace('<','\\u003c')),encoding='utf-8')
    print(json.dumps(data['counts']));print('Dependency registration gaps:',len(data['unregistered_dependencies']))
