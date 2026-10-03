"""Narrow theme patch for the verified 4.7.2 non-Gradle APK template.

Godot writes custom splash theme colors only on its Gradle path. Replace the
two existing background values without changing resource offsets/identities.
Exact binary map signatures and counts deliberately fail on template changes.
Original official template remains unchanged and checksum verified by builder.
"""
import struct, zipfile

NAVY = 0xff0d182d

def branded_template(source, destination):
    with zipfile.ZipFile(source) as original:
        resources = original.read('resources.arsc')
        # Android 12+ Godot override and pre-12 inherited compatibility value.
        signatures = [(0x0101062c, 1, 0x7f0a0001),
                      (0x7f030015, 2, 0x01010031)]
        for key, value_type, data in signatures:
            old = struct.pack('<IHBBI', key, 8, 0, value_type, data)
            new = struct.pack('<IHBBI', key, 8, 0, 0x1c, NAVY)
            assert resources.count(old) == 1, f'Unexpected splash template map: {key:x}'
            resources = resources.replace(old, new)
        with zipfile.ZipFile(destination, 'w') as output:
            for info in original.infolist():
                output.writestr(info, resources if info.filename == 'resources.arsc' else original.read(info.filename))
    return {'color': '#0d182d', 'replaced_background_values': 2,
            'original_verified_template_preserved': True}
