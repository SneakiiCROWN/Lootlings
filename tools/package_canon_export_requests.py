"""One portable external-art handoff; copies locked source images, never modifies them."""
from pathlib import Path
import json,shutil,hashlib,zipfile
ROOT=Path(__file__).resolve().parents[1];BASE=ROOT/'docs/production';OUT=ROOT/'builds/art/NEEDS_NEW_CANON_EXPORT_PACKAGE'
def main():
    data=json.loads((BASE/'NEEDS_NEW_CANON_EXPORT.json').read_text(encoding='utf-8'));OUT.mkdir(parents=True,exist_ok=True)
    shutil.copy2(BASE/'NEEDS_NEW_CANON_EXPORT.json',OUT/'NEEDS_NEW_CANON_EXPORT.json')
    source_paths=sorted({r['path'] for p in data['packages'] for r in p['locked_source_images']})
    files=[]
    for relative in source_paths:
        source=ROOT/relative;target=OUT/'canonical_sources'/relative;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,target)
        files.append(dict(path=target.relative_to(OUT).as_posix(),original=relative,sha256=hashlib.sha256(source.read_bytes()).hexdigest()))
    for source in [BASE/'phase4e/polish/ART_EXPORT_CONTRACT.md',BASE/'MASTER_INTEGRATION_SUMMARY.md',ROOT/'art/production/phase4e/runtime_manifest.json']:
        shutil.copy2(source,OUT/source.name)
    temp=OUT/'TEMP_EVIDENCE';temp.mkdir(exist_ok=True)
    for actor in ['relic_beast','emberhorn','mosskin','moonkip','pebblewyrm','glimmerfin','gloomlet']:
        candidates=sorted((BASE/'phase4e/extraction/native/extracted-art/1080x2340').glob(actor+'_*_attack_TEMP_preserved.jpg'))
        if candidates:shutil.copy2(candidates[0],temp/(actor+'_TEMP_attack.jpg'))
    (OUT/'README.txt').write_text('Lootlings Phase4E exact established-canon export handoff\n\n106 shared body/view packages cover 3097 delivery cells, NOT 3097 unique paintings. Source images copied byte-for-byte. JSON canonical image paths are original repo paths; matching files are under canonical_sources/.\n\nCanonical images constrain identity. TEMP_EVIDENCE demonstrates rejected presentation; never copy a TEMP rig as the target design. Each package lists states, families, canvas/alpha, ground/pivot, rig socket targets, layering and scale rules. Deliver original anatomy with actual source-pixel sockets in a sidecar; never invent coordinates or missing limbs. Reuse a body/frame across validated modules.\n\nOPEN visual-source gates cannot be solved without owner approval. Regional enemies/bosses whose exact canonical visual does not exist have written lore only; no final identity is authorized by a proxy or board label. Moonkip must be weaponless from the original hooded rogue. Hoard Dragon stays wingless/coiled purple/obsidian/gold, one actually redrawn continuous tail; no crop/squash concealment. No rejected handoff boards are included.\n',encoding='utf-8')
    (OUT/'SOURCE_MANIFEST.json').write_text(json.dumps(files,indent=2)+'\n',encoding='utf-8')
    output=ROOT/'builds/art/Lootlings_NEEDS_NEW_CANON_EXPORT.zip'
    with zipfile.ZipFile(output,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as archive:
        for p in sorted(OUT.rglob('*')):
            if p.is_file():archive.write(p,p.relative_to(OUT).as_posix())
    with zipfile.ZipFile(output) as archive:assert archive.testzip() is None;count=len(archive.namelist())
    receipt=dict(path=str(output),bytes=output.stat().st_size,sha256=hashlib.sha256(output.read_bytes()).hexdigest(),files=count,locked_images=len(files),body_view_packages=data['body_view_packages'],delivery_cells=data['delivery_cells'])
    target=BASE/'master-continuation';target.mkdir(exist_ok=True);(target/'art-package.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8');print(json.dumps(receipt))
if __name__=='__main__':main()
