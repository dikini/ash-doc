"""Exercise ordinary saved-artwork preparation for an isolated local trial."""
import json
from pathlib import Path
import runpy
import sys

ROOT = Path(__file__).resolve().parents[2]
build = runpy.run_path(str(ROOT / 'rendering/build.py'))
source = Path(sys.argv[1])
output = Path(sys.argv[2])
output.mkdir(parents=True, exist_ok=True)
jobs, assets = [], []
prepared, codes = build['prepare_chapter'](
    ROOT / '.build/toolchain/quarto-1.10.19/bin/quarto', source.as_posix(), {},
    '354c76b391fe4af665cf6a03479a9874a57cb3e3', jobs, output=output, assets=assets)
assert not jobs and not codes
assert '.illustration' not in prepared and 'Draw two small trees' not in prepared
assert len(assets) == 1
(output / 'prepared.md').write_text(prepared)
(output / 'assets.json').write_text(json.dumps(assets, indent=2) + '\n')
