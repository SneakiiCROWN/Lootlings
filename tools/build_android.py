"""Build a signed, arm64 debug APK with a workspace-local Android toolchain.

Run --prepare once to download verified official tools. No global SDK, editor
settings, production signing keys, or player saves are touched.
"""
from pathlib import Path
import argparse, hashlib, json, os, re, shutil, subprocess, urllib.request, zipfile

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
    parser.add_argument('--output', default='builds/android/Lootlings-phase2-s23-debug.apk')
    args = parser.parse_args()
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
    assert 'uses-permission:' not in badging, 'Unexpected Android permission in offline test build'
    with zipfile.ZipFile(output) as apk:
        entries = apk.namelist()
        assert 'assets/art/production_pose_manifest.json' in entries
        for script in ['mobile_test_monitor', 'safe_area_layout', 'relic_greatsword_motion', 'touch_ux']:
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
        assert imported_audio == 178
        assert not any(x.startswith(('assets/tests/', 'assets/tools/', 'assets/docs/', 'assets/art/source/', 'assets/art/reference/')) for x in entries)
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
              'audio_license_manifest_exported': True, 'version_code': 2,
              'device_validated': False, 'debug_only': True}
    (output.parent/'build-report.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report, indent=2))

if __name__ == '__main__': main()
