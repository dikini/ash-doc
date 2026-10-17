"""Prepare the test-only observer with the pinned compiler's locked packages."""

import json
from pathlib import Path
import shutil
import subprocess
import sys
import tomllib

checkout, directory, target, source = map(Path, sys.argv[1:])
directory.mkdir()
(directory / 'src').mkdir()
shutil.copyfile(source, directory / 'src/main.rs')
shutil.copyfile(checkout / 'rust-toolchain.toml', directory / 'rust-toolchain.toml')
shutil.copyfile(checkout / 'Cargo.lock', directory / 'Cargo.lock')
(directory / 'Cargo.toml').write_text(
    '[package]\nname = "ash-doc-native-observer"\nversion = "0.0.0"\n'
    'edition = "2024"\n[workspace]\n[dependencies]\n'
    f'ash = {{ path = {json.dumps(str(checkout))} }}\n'
)
# Preserve the seeded versions; only the local root changes. Unused upstream
# workspace/dev packages may disappear from this dependency subset.
subprocess.run(['cargo', 'metadata', '--offline', '--filter-platform',
                'x86_64-unknown-linux-gnu', '--format-version', '1'],
               cwd=directory, stdout=subprocess.DEVNULL, check=True)
fields = ('name', 'version', 'source', 'checksum')
def identity(package):
    return tuple(package.get(field) for field in fields)
baseline = {identity(p) for p in tomllib.loads((checkout / 'Cargo.lock').read_text())['package']}
selected = tomllib.loads((directory / 'Cargo.lock').read_text())['package']
for package in selected:
    if package['name'] == 'ash-doc-native-observer':
        assert identity(package) == ('ash-doc-native-observer', '0.0.0', None, None)
    elif identity(package) not in baseline:
        sys.exit(f"observer dependency differs from pinned lock: {identity(package)}")
subprocess.run(['cargo', 'build', '--offline', '--locked', '--quiet',
                '--target-dir', str(target)], cwd=directory, check=True)
