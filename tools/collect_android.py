"""Collect test telemetry, Android process memory and logs from one USB device.

Read-only: never installs, launches, stops, clears data/logs, or changes the phone.
Enable USB debugging, approve the connected PC, then run this after testing.
"""
from pathlib import Path
import argparse, json, subprocess, time, os

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = 'com.sneakiicrown.lootlings'

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--serial', help='Select a specific adb serial when multiple phones are attached')
    args = parser.parse_args()
    adb = ROOT/'.godot_test_data/android/sdk/platform-tools/adb.exe'
    if not adb.exists(): raise SystemExit('Run tools/build_android.py --prepare first.')
    env = os.environ.copy()
    env['ANDROID_USER_HOME'] = str(ROOT/'.godot_test_data/android/adb-user')
    env['ANDROID_SDK_HOME'] = env['ANDROID_USER_HOME']
    def run(arguments):
        return subprocess.run([str(adb), *arguments], capture_output=True, env=env)
    devices = run(['devices']).stdout.decode('utf-8', 'replace')
    available = [line.split()[0] for line in devices.splitlines()[1:] if line.endswith('\tdevice')]
    serial = args.serial or (available[0] if len(available) == 1 else None)
    if serial not in available: raise SystemExit('Connect/unlock phone and approve USB debugging.\n'+devices)
    output = ROOT/'builds/android'/('device-report-'+time.strftime('%Y%m%d-%H%M%S'))
    output.mkdir(parents=True)
    commands = {
        'device.txt': ['shell', 'getprop'],
        'display.txt': ['shell', 'wm', 'size'],
        'memory.txt': ['shell', 'dumpsys', 'meminfo', PACKAGE],
        'frame-stats.txt': ['shell', 'dumpsys', 'gfxinfo', PACKAGE, 'framestats'],
        'logcat.txt': ['logcat', '-d', '-v', 'threadtime', '-t', '1500'],
        'device_test_report.json': ['shell', 'run-as', PACKAGE, 'cat', 'files/device_test_report.json'],
    }
    failures = []
    for name, command in commands.items():
        result = run(['-s', serial, *command])
        content = result.stdout
        if result.returncode:
            failures.append(name)
            content += b'\n'+result.stderr
        (output/name).write_bytes(content)
    report_path = output/'device_test_report.json'
    try:
        report = json.loads(report_path.read_text(encoding='utf-8'))
        print(json.dumps({key: report.get(key) for key in ['model', 'samples', 'combat_samples', 'average_fps', 'frame_p95_ms', 'combat_frame_p95_ms', 'texture_memory_bytes', 'lifecycle']}, indent=2))
    except (ValueError, UnicodeError):
        failures.append('Telemetry unavailable: open Pause > Test report in the test APK first.')
    print('Saved:', output)
    if failures: print('Unverified:', ', '.join(failures))
    print('Godot GL frames may not appear in Android gfxinfo; use game telemetry and Perfetto for frame pacing.')

if __name__ == '__main__': main()
