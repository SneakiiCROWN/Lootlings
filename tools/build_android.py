"""Build a signed, arm64 debug APK with a workspace-local Android toolchain.

Run --prepare once to download verified official tools. No global SDK, editor
settings, production signing keys, or player saves are touched.
"""
from pathlib import Path
import argparse, hashlib, json, os, re, shutil, subprocess, urllib.request, zipfile
from android_splash_theme import branded_template
from validate_canonical_art import validate as validate_canonical_art
from validate_master_integration import main as validate_master_integration
from validate_canon_registry import main as validate_canon_registry

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / '.godot_test_data' / 'android'
PACKAGES = {
    'android_debug.apk': ('https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_android_debug.perfetto.apk', 'sha256', '7e480a90a763bbef7af2d9cc2873b094cc278d1ed26c13c0d2e72a36e4c815d0'),
    'jdk.zip': ('https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.20.1%2B1/OpenJDK17U-jdk_x64_windows_hotspot_17.0.20.1_1.zip', 'sha256', 'e53a79c3c3d86865bd7e787903884331068e71321714ffd44f145785affc7cb0'),
    'buildtools36.zip': ('https://dl.google.com/android/repository/build-tools_r36_windows.zip', 'sha1', 'f16ccffd34de8790dede813a6c7d8e2c11a27b50'),
    'platformtools.zip': ('https://dl.google.com/android/repository/platform-tools_r37.0.1-win.zip', 'sha1', 'e03e78b1d80b396f1c3358e31251cb31740e1110'),
}

def invoke(command, env, log=None):
    result = subprocess.run([str(x) for x in command], env=env, cwd=ROOT,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = result.stdout.decode('utf-8', 'replace')
    if log: log.write_text(output, encoding='utf-8')
    if not log or result.returncode: print(output, end='', flush=True)
    elif log: print(log.name + ': OK', flush=True)
    if result.returncode: raise SystemExit(result.returncode)
    return output

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepare', action='store_true')
    parser.add_argument('--output', default='builds/android/Lootlings-predevice-rc-debug.apk')
    args = parser.parse_args()
    print('Canonical freeze preflight:', validate_canonical_art(), flush=True)
    validate_master_integration()
    validate_canon_registry()
    WORK.mkdir(parents=True, exist_ok=True)
    for name, (url, algorithm, expected) in PACKAGES.items():
        path = WORK / name
        if not path.exists() and args.prepare:
            print('Downloading', name, flush=True)
            urllib.request.urlretrieve(url, path)
        if not path.exists(): raise SystemExit(f'Missing {path}; run --prepare.')
        if hashlib.new(algorithm, path.read_bytes()).hexdigest() != expected:
            raise SystemExit(f'Checksum mismatch: {path}')
    for archive, destination in [('jdk.zip', WORK/'jdk'), ('buildtools36.zip', WORK/'sdk'/'build-tools'), ('platformtools.zip', WORK/'sdk')]:
        marker = destination / ('.' + archive + '.extracted')
        if not marker.exists():
            with zipfile.ZipFile(WORK/archive) as package: package.extractall(destination)
            marker.touch()
    sdk = WORK/'sdk'
    splash_patch = branded_template(WORK/'android_debug.apk', WORK/'android_debug_branded.apk')
    buildtools = sdk/'build-tools'/'36.0.0'
    if not buildtools.exists(): shutil.copytree(sdk/'build-tools'/'android-16', buildtools)
    jdk = next((WORK/'jdk').glob('jdk-*'))
    # Copy engine into self-contained mode to make editor settings and keys local.
    original = Path(os.environ.get('GODOT', str(Path.home()/'Desktop'/'Godot_v4.7.2-stable_win64_console.exe')))
    editor = WORK/'editor'
    editor.mkdir(exist_ok=True)
    for engine in [original, original.with_name(original.name.replace('_console', ''))]:
        target = editor/engine.name
        if not target.exists(): shutil.copy2(engine, target)
    (editor/'_sc_').touch()
    data = editor/'editor_data'
    data.mkdir(exist_ok=True)
    settings = data/'editor_settings-4.7.tres'
    settings.write_text('[gd_resource type="EditorSettings" format=3]\n\n[resource]\n' +
                        f'export/android/java_sdk_path = "{jdk.as_posix()}"\n' +
                        f'export/android/android_sdk_path = "{sdk.as_posix()}"\n', encoding='utf-8')
    env = os.environ.copy()
    env['JAVA_HOME'] = str(jdk)
    env['ANDROID_HOME'] = str(sdk)
    env['ANDROID_SDK_ROOT'] = str(sdk)
    env['APPDATA'] = str(WORK/'appdata')
    env['XDG_DATA_HOME'] = env['APPDATA']
    env['PATH'] = str(jdk/'bin') + os.pathsep + env.get('PATH', '')
    key = WORK/'debug.keystore'
    if not key.exists():
        invoke([jdk/'bin'/'keytool.exe', '-genkeypair', '-keystore', key, '-alias', 'androiddebugkey', '-storepass', 'android', '-keypass', 'android', '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10000', '-dname', 'CN=Android Debug,O=Android,C=US'], env)
    env['GODOT_ANDROID_KEYSTORE_DEBUG_PATH'] = str(key)
    env['GODOT_ANDROID_KEYSTORE_DEBUG_USER'] = 'androiddebugkey'
    env['GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD'] = 'android'
    output = (ROOT/args.output).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    version = invoke([editor/original.name, '--version'], env).strip()
    if not version.startswith('4.7.2.stable.'):
        raise SystemExit('Expected Godot 4.7.2 to match the verified template; found ' + version)
    exported = invoke([editor/original.name, '--headless', '--path', ROOT, '--export-debug', 'Android', output], env, WORK/'export.log')
    if any(marker in exported for marker in ['ERROR:', 'SCRIPT ERROR', 'Parse Error']):
        raise SystemExit('Android export emitted errors; inspect ' + str(WORK/'export.log'))
    invoke([jdk/'bin'/'java.exe', '-jar', buildtools/'lib'/'apksigner.jar', 'verify', '--verbose', '--print-certs', output], env, WORK/'signature.log')
    invoke([buildtools/'zipalign.exe', '-c', '-P', '16', '4', output], env, WORK/'alignment.log')
    badging = invoke([buildtools/'aapt.exe', 'dump', 'badging', output], env, WORK/'badging.log')
    assert "native-code: 'arm64-v8a'" in badging
    assert "package: name='com.sneakiicrown.lootlings'" in badging
    exported_version = re.search(r"versionCode='(\d+)' versionName='([^']+)'",badging)
    assert exported_version, 'Missing exported package version'
    assert 'uses-permission:' not in badging, 'Unexpected Android permission in offline test build'
    resource_dump = invoke([buildtools/'aapt.exe','dump','--values','resources',output],env,WORK/'resources-final.txt')
    assert '(Key=0x0101062c): (color) #ff0d182d' in resource_dump, 'Android 12+ splash background is not branded navy'
    assert '(Key=0x7f030015): (color) #ff0d182d' in resource_dump, 'Compatibility splash background is not branded navy'
    with zipfile.ZipFile(output) as apk:
        entries = apk.namelist()
        assert apk.read('assets/art/actor_identity_corrections.json')==(ROOT/'art/actor_identity_corrections.json').read_bytes(), 'Stale owner identity confirmation'
        assert 'assets/actor_identity_corrections.gdc' in entries, 'Missing owner identity boundary'
        extracted_manifest = json.loads((ROOT/'art/production/phase4e/extraction_manifest.json').read_text(encoding='utf-8'))
        extracted_imports = {}
        for record in extracted_manifest['entries']:
            source = ROOT/record['asset_path'].removeprefix('res://')
            config = source.with_suffix('.png.import').read_text(encoding='utf-8')
            relative = re.search(r'^path="res://([^"]+)"', config, re.MULTILINE).group(1)
            payload = apk.read('assets/'+relative)
            assert payload == (ROOT/relative).read_bytes(), 'Stale extracted canonical asset: '+record['id']
            extracted_imports[record['id']] = hashlib.sha256(payload).hexdigest()
        for manifest in ['extraction_manifest.json','runtime_manifest.json','reuse_manifest.json']:
            relative = 'art/production/phase4e/'+manifest
            assert apk.read('assets/'+relative) == (ROOT/relative).read_bytes(), 'Stale extraction manifest'
        reuse_imports={}
        for record in json.loads((ROOT/'art/production/phase4e/reuse_manifest.json').read_text())['entries']:
            source=ROOT/record['asset_path'].removeprefix('res://')
            config=source.with_suffix('.png.import').read_text()
            relative=re.search(r'^path="res://([^"]+)"',config,re.MULTILINE).group(1)
            payload=apk.read('assets/'+relative)
            assert payload==(ROOT/relative).read_bytes(),'Stale canonical reused body: '+record['actor']
            reuse_imports[record['actor']]=hashlib.sha256(payload).hexdigest()
        prop_imports={}
        prop_manifest=ROOT/'art/production/phase4e/props/source_manifest.json'
        assert apk.read('assets/art/production/phase4e/props/source_manifest.json')==prop_manifest.read_bytes()
        for record in json.loads(prop_manifest.read_text())['entries']:
            source=ROOT/record['asset_path'].removeprefix('res://')
            config=source.with_suffix('.png.import').read_text()
            relative=re.search(r'^path="res://([^"]+)"',config,re.MULTILINE).group(1)
            payload=apk.read('assets/'+relative)
            assert payload==(ROOT/relative).read_bytes(),'Stale source-derived Home prop: '+record['id']
            prop_imports[record['id']]=hashlib.sha256(payload).hexdigest()
        for script in ['phase4e_extracted_art','authored_pose_manifest','weapon_fit_catalog','avatar_presentation','field_notes_catalog','vignette_catalog','pickup_presentation','reward_reveal_catalog']:
            assert 'assets/'+script+'.gdc' in entries
        assert 'assets/art/production_pose_manifest.json' in entries
        assert 'assets/art/production_boss_manifest.json' in entries
        assert not any('phase4e_handoff' in entry for entry in entries), 'Reference/rejected art must never be packaged'
        for script in ['resident_art_catalog','combat_controls','combat_tap_meter','combat_sprite_rig','resident_sprite_rig','boss_audio_identity','contextual_dialogue','combat_presentation','regional_enemy_presentation','relic_reveal_fx','impact_presentation','enemy_motion','retention_runtime','endgame_progress','phase4b_catalog','local_save_provider','phase4_catalog','expedition_progress','mobile_test_monitor', 'safe_area_layout', 'relic_greatsword_motion', 'touch_ux', 'responsive_backdrop','voice_identity','projectile_presentation','pickup_presentation','character_traits','boss_patterns','expedition_event_catalog','phase3_item_catalog']:
            assert 'assets/' + script + '.gdc' in entries
        assert 'assets/art/audio/production/sources.json' in entries
        assert 'assets/art/audio/production/LICENSES.txt' in entries
        imported_audio = 0
        for sidecar in (ROOT/'art/audio/production').rglob('*.wav.import'):
            config = sidecar.read_text(encoding='utf-8')
            assert 'compress/mode=0' in config, 'PCM loader requires uncompressed WAV import'
            relative = re.search(r'^path="res://([^"]+)"', config, re.MULTILINE).group(1)
            assert apk.read('assets/' + relative) == (ROOT/relative).read_bytes(), 'Stale exported sound: ' + str(sidecar)
            imported_audio += 1
        sound_manifest=json.loads((ROOT/'art/audio/production/sources.json').read_text(encoding='utf-8'))
        expected_audio={str(record['asset']).replace('\\','/') for record in sound_manifest['assets'] if str(record['asset']).replace('\\','/').startswith('art/audio/production/sfx/')}
        actual_sfx={p.relative_to(ROOT).as_posix().removesuffix('.import') for p in (ROOT/'art/audio/production/sfx').glob('*.wav.import')}
        assert actual_sfx == expected_audio, 'Source documentation must cover exactly the packaged SFX'
        ambience_count=len(list((ROOT/'art/audio/production/ambience').glob('*.wav.import')))
        assert imported_audio == len(expected_audio)+ambience_count, 'Every source-documented SFX and ambient loop must be packaged exactly once'
        bow_source = ROOT/'art/sprites/weapons/bow_held.png'
        bow_config = bow_source.with_suffix('.png.import').read_text(encoding='utf-8')
        bow_relative = re.search(r'^path="res://([^"]+)"', bow_config, re.MULTILINE).group(1)
        assert 'process/size_limit=512' in bow_config
        bow_bytes = apk.read('assets/' + bow_relative)
        assert bow_bytes == (ROOT/bow_relative).read_bytes(), 'APK contains stale bow limbs'
        final_bow = {'source_sha256': hashlib.sha256(bow_source.read_bytes()).hexdigest(),
                     'imported_sha256': hashlib.sha256(bow_bytes).hexdigest(),
                     'runtime_size_limit': 512, 'matches_local_import': True}
        imported_residents = {}
        for resident in ['patch', 'ilex', 'sera']:
            scoped = resident in ['patch','ilex'] and (ROOT/'art/npc_identity_authorities.json').exists()
            source = ROOT/('art/production/phase4e/npcs/'+resident+'_canonical_station_panel.png' if scoped else 'art/sprites/npcs/beta/'+resident+'_idle.png')
            config = source.with_suffix('.png.import').read_text(encoding='utf-8')
            relative = re.search(r'^path="res://([^"]+)"', config, re.MULTILINE).group(1)
            exported_bytes = apk.read('assets/' + relative)
            assert exported_bytes == (ROOT/relative).read_bytes(), 'Stale canonical resident idle: ' + resident
            imported_residents[resident] = {'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                                           'imported_sha256': hashlib.sha256(exported_bytes).hexdigest(),
                                           'matches_local_import': True, 'authored_state': 'canonical_station_panel' if scoped else 'idle'}
        imported_companions = {}
        companion_manifest=ROOT/'art/production/companions/runtime_manifest.json'
        if companion_manifest.exists():
            assert json.loads(apk.read('assets/art/production/companions/runtime_manifest.json'))==json.loads(companion_manifest.read_text())
            for row in json.loads(companion_manifest.read_text())['entries']:
                source=ROOT/row['asset_path'].removeprefix('res://')
                relative=re.search(r'^path="res://([^"]+)"',source.with_suffix('.png.import').read_text(),re.MULTILINE).group(1)
                assert apk.read('assets/'+relative)==(ROOT/relative).read_bytes(), 'Stale neutral companion export'
                imported_companions.setdefault(row['actor'],{'cells':[],'matches_local_import':True})['cells'].append(row['state']+':'+row['facing'])
        for item in imported_companions.values():
            item['equippable']=all(state+':'+facing in item['cells'] for state in ['idle','move','reaction'] for facing in ['right','left'])
            item['perch_ready']=item['equippable'] and all(state+':'+facing in item['cells'] for state in ['perch_rest','perch_interact'] for facing in ['right','left'])
        home_manifest=ROOT/'art/production/phase4e/home_runtime_manifest.json'
        assert apk.read('assets/art/production/phase4e/home_runtime_manifest.json')==home_manifest.read_bytes()
        imported_home={}
        for row in json.loads(home_manifest.read_text(encoding='utf8'))['entries']:
            source=ROOT/row['asset_path'].removeprefix('res://')
            paths=[source]
            if row['master_artist_slot_id'].startswith('home_decor:'):paths.append(source.with_name(source.stem+'_front.png'))
            for asset in paths:
                config=asset.with_suffix('.png.import').read_text(encoding='utf8')
                relative=re.search(r'^path="res://([^"]+)"',config,re.MULTILINE).group(1)
                assert apk.read('assets/'+relative)==(ROOT/relative).read_bytes(),'Stale accepted Home furnishing'
                imported_home[asset.relative_to(ROOT).as_posix()]=hashlib.sha256((ROOT/relative).read_bytes()).hexdigest()
        score_manifest=ROOT/'art/audio/production/score_sources.json'
        assert apk.read('assets/art/audio/production/score_sources.json')==score_manifest.read_bytes()
        imported_scores={}
        for row in json.loads(score_manifest.read_text(encoding='utf8'))['assets']:
            source=ROOT/row['asset'];assert hashlib.sha256(source.read_bytes()).hexdigest()==row['asset_sha256']
            config=source.with_suffix('.ogg.import').read_text(encoding='utf8')
            relative=re.search(r'^path="res://([^"]+)"',config,re.MULTILINE).group(1)
            assert apk.read('assets/'+relative)==(ROOT/relative).read_bytes(),'Stale licensed score'
            imported_scores[row['cue']]={'source_sha256':row['source_sha256'],'imported_sha256':hashlib.sha256((ROOT/relative).read_bytes()).hexdigest(),'license':row['license']}
        assert not any(x.startswith(('assets/tests/', 'assets/tools/', 'assets/docs/', 'assets/art/source/', 'assets/art/reference/')) for x in entries)
        for source in list((ROOT/'art/sprites/combat_rigs').glob('*.svg')) + [ROOT/'art/sprites/enemies/beta'/(name+'.svg') for name in ['mossmaw','glasswing','bell_bat','rime_pup','coal_pup','null_hound','lantern_toad','sluice_crab','brassback','forge_beetle','inkling','pagewyrm','pressure_sprite','crown_shard','hookwing','lantern_jackal','belljaw']]:
            config=source.with_suffix('.svg.import').read_text(encoding='utf-8')
            relative=re.search(r'^path="res://([^"]+)"',config,re.MULTILINE).group(1)
            assert apk.read('assets/'+relative)==(ROOT/relative).read_bytes(), 'Stale combat layer: '+str(source)
        imported_poses = {}
        for pose in ['greatsword_ready', 'greatsword_strike']:
            source = ROOT/'art/sprites/poses/relic_beast'/ (pose + '.png')
            config = source.with_suffix('.png.import').read_text(encoding='utf-8')
            relative = re.search(r'^path="res://([^"]+)"', config, re.MULTILINE).group(1)
            assert 'process/size_limit=768' in config
            exported_bytes = apk.read('assets/' + relative)
            assert exported_bytes == (ROOT/relative).read_bytes(), 'APK has a stale imported pose: ' + pose
            imported_poses[pose] = {'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                                    'imported_sha256': hashlib.sha256(exported_bytes).hexdigest(),
                                    'runtime_size_limit': 768, 'matches_local_import': True}
    report = {'apk': str(output.relative_to(ROOT)), 'bytes': output.stat().st_size,
              'sha256': hashlib.sha256(output.read_bytes()).hexdigest(),
              'engine': '4.7.2.stable', 'template': 'official Android debug Perfetto',
              'architecture': 'arm64-v8a', 'min_sdk': 24, 'target_sdk': 36,
              'signed': True, 'zipalign_16k': True, 'offline_no_permissions': True,
              'contains_manifest_and_test_monitor': True, 'source_test_reference_art_excluded': True,
              'contains_motion_and_safe_area_modules': True, 'final_imported_poses': imported_poses,
              'mobile_gesture_owner_exported': True, 'current_pcm_audio_assets': imported_audio,
              'audio_license_manifest_exported': True, 'version_code': int(exported_version.group(1)), 'version_name': exported_version.group(2), 'splash_theme_patch': splash_patch,
              'final_imported_bow': final_bow,
              'final_imported_residents': imported_residents,
              'final_imported_companion_previews': imported_companions,
              'current_extracted_canonical_assets': extracted_imports,
              'extracted_canonical_count': len(extracted_imports),
              'reused_canonical_bodies': reuse_imports,
              'source_derived_home_props': prop_imports,
              'accepted_home_imports': imported_home, 'licensed_score_imports': imported_scores, 'device_validated': False, 'debug_only': True}
    (output.parent/'build-report.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report, indent=2))

if __name__ == '__main__': main()
