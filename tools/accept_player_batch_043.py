"""Close only the reviewed exact 0.4.43 deliveries; safe to rerun, never reset debt."""
from pathlib import Path
import hashlib, json, shutil
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
CONT=ROOT/'docs/production/full-completion/continuous-production'
MANIFEST=ROOT/'art/production/phase4e/player_batch_043_manifest.json'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,obj):p.write_text(json.dumps(obj,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    preview=read(ROOT/'.godot_test_data/player-batch-043/preview/PROBES.json')
    before=read(ROOT/'.godot_test_data/player-batch-043/before/PROBES.json')
    assert preview['total_probes']==before['total_probes']==108
    assert preview['reference_fallback_incidents']==0 and before['reference_fallback_incidents']==81
    rows=read(MANIFEST)['entries'];slots={r['contract_slot_id'] for r in rows};assert len(rows)==len(slots)==25
    for row in rows:
        assert row['state'] not in ['movement','defeat','victory_return']
        asset=ROOT/row['asset_path'].removeprefix('res://');im=Image.open(asset)
        assert im.mode=='RGBA' and im.size==(512,512)
        bbox=im.getchannel('A').getbbox();assert bbox and bbox[0]>=15 and bbox[1]>=15 and bbox[2]<=497 and bbox[3]<=497
        assert (ROOT/row['foreground_layer'].removeprefix('res://')).is_file()
        row.update(native_validated=True,production_status='canon_validated_runtime',visual_review='Dedicated identity, source anatomy, alpha, native both views and modular weapon contact reviewed; full motion family / physical device acceptance remain open.')
        write(ROOT/row['metadata_path'],row)
    data=read(MANIFEST);data['entries']=rows;write(MANIFEST,data)
    queue=read(CONT/'EXACT_REMAINING_CONTRACTS.json');remaining={r['slot_id'] for r in queue}
    counts=read(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json')
    if slots<=remaining:
        write(CONT/'EXACT_REMAINING_CONTRACTS.json',[r for r in queue if r['slot_id'] not in slots])
        counts['installed_contracts']+=25;counts['remaining_contracts']-=25
        # Frozen requested file slots: 25 bodies + 25 grip layers + 25 sidecars.
        # Twenty body/grip requirements reuse compatible verified files, not new PNGs.
        counts['installed_artist_files']+=75;counts['remaining_artist_files']-=75
        counts['installed_by_category']['playable_lootlings']+=25;counts['remaining_by_category']['playable_lootlings']-=25
    else:assert not (slots & remaining),'Partial ledger mutation: investigate, do not double-count'
    counts['artist_file_count_unit']='Frozen artist-file requirements fulfilled, including verified reuse. Not unique newly authored physical files. See per-batch receipts.'
    counts['latest_player_revision']='0.4.43: Gloomlet Bow ten new exact cells; Moonkip Wand five; Moonkip Orb ten using compatible verified bodies. 15 new body PNG +15 grip PNG +25 sidecars =55 new physical artist files; 75 frozen file requirements fulfilled, 20 via reuse. No movement/defeat/victory or whole-family completion.'
    write(CONT/'CONTINUOUS_PRODUCTION_COUNTS.json',counts)
    receipt=dict(base_checkpoint='6a15b57',version='0.4.43',verified_contracts_closed=25,slot_ids=sorted(slots),new_runtime_body_png=15,new_foreground_grip_png=15,new_sidecars=25,new_physical_artist_files=55,frozen_artist_file_requirements_fulfilled=75,reused_body_or_grip_requirements=20,by_family={'gloomlet_bow':10,'moonkip_wand':5,'moonkip_orb':10},quality_findings=[
      'Moonkip mixed left windup/cast actually face right: rejected for left slots; accepted padded left windup replaces the missing Wand/Orb anticipation.',
      'Moonkip mixed left recovery has three feet: rejected, no recovery contract closed from that candidate.',
      'Corrected Gloomlet right follow-through touches source edge: rejected; valid earlier independent follow-through retained.',
      'First standalone Moonkip windup ear touches canvas edge: rejected and padded correction used.',
      'Native review caught resting Wand and lowered Bow overlapping faces: runtime angles corrected and retested.',
      'Movement, Moonkip separate follow-through, defeat/victory, additional weapons and full animation continuity remain open.'],selected_probe_fallbacks_before=81,selected_probe_fallbacks_after=0,total_probes_each=108,physical_device_validated=False,professional_family_acceptance=False)
    write(CONT/'PLAYER_COMBAT_INSTALLATION_0443.json',receipt)
    shutil.copyfile(ROOT/'.godot_test_data/player_export_jobs_043.json',ROOT/'art/source/player_combat_043/EXPORT_JOBS.json')
    write(ROOT/'art/source/player_combat_043/PROVENANCE.json',dict(generator='Built-in imagegen; dedicated original character sheets supplied as references',prompt_constraints='Exact dedicated identity; independent right/left weaponless complete bodies; idle, release, follow-through, recovery, hurt; no baked weapons, floor, text or effects; closed primary handle palm / released rear Bow hand; padded complete silhouettes. Follow-up correction required true left windup and padded ear clearance.',sources=[dict(path=p.relative_to(ROOT).as_posix(),sha256=sha(p)) for p in sorted((ROOT/'art/source/player_combat_043').glob('*.png'))],decisions=receipt['quality_findings'],extraction='Native Godot copies exact connected source RGBA pixels and source palm foreground; uniform intended scale, integer target rounding; no anatomy redraw or mirror.'))
    print('Exact closures 25; new physical artist files 55; requested file coverage 75 with 20 verified reused requirements')
if __name__=='__main__':main()
