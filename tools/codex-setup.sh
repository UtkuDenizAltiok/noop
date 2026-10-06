#!/usr/bin/env bash
# Install the NOOP fork's Codex entry files in every code worktree; no global settings changes.
#   bash dist/tools/codex-setup.sh
# The canonical instructions live in the handbook's AGENTS.md. Local overrides also require upstream AGENTS.md.
set -euo pipefail
HB=$(cd "$(dirname "$0")/.." && pwd)
python3 - "$HB" <<'PY'
from pathlib import Path
import subprocess
import sys

hb = Path(sys.argv[1]).resolve()
marker = '<!-- managed by noop-handbook/tools/codex-setup.sh -->'
if not (hb / 'AGENTS.md').is_file():
    raise SystemExit('Missing canonical handbook AGENTS.md')

def git(*args):
    return subprocess.check_output(['git', '-C', str(hb), *args], text=True).strip()

if git('symbolic-ref', '--short', 'HEAD') != 'handbook':
    raise SystemExit('Run this installer from the handbook worktree')

entries = []
for block in git('worktree', 'list', '--porcelain').split('\n\n'):
    fields = dict(line.split(' ', 1) for line in block.splitlines() if ' ' in line)
    if fields.get('branch') == 'refs/heads/handbook' or 'worktree' not in fields:
        continue
    root = Path(fields['worktree'])
    if not (root / 'AGENTS.md').is_file():
        raise SystemExit(f'Missing upstream AGENTS.md in {root}; inspect this worktree')
    target = root / 'AGENTS.override.md'
    tracked = subprocess.run(['git', '-C', str(root), 'ls-files', '--error-unmatch', 'AGENTS.override.md'],
                             capture_output=True).returncode == 0
    if tracked or target.is_symlink() or (target.exists() and marker not in target.read_text()):
        raise SystemExit(f'Existing instructions at {target}; left untouched. Reconcile them before installing.')
    entries.append(target)

exclude = Path(git('rev-parse', '--path-format=absolute', '--git-path', 'info/exclude'))
exclude.parent.mkdir(parents=True, exist_ok=True)
text = exclude.read_text() if exclude.exists() else ''
rule = '/AGENTS.override.md'
if rule not in text.splitlines():
    with exclude.open('a') as f:
        if text and not text.endswith('\n'):
            f.write('\n')
        f.write('# Local NOOP fork instructions, generated from the handbook\n' + rule + '\n')

content = f'''# NOOP — ChatGPT/Codex project entry
{marker}

Read this checkout's `AGENTS.md` first: it contains upstream's scope and engineering rules.
Then read `{hb / 'AGENTS.md'}` and follow its session procedure and delegated project authority.
The durable project memory is the handbook at `{hb}`, on branch `handbook`.
Use that handbook's tools; in a PR worktree set `NOOP_REPO` for branch verification.
Keep this local entry file out of app commits. Re-run the handbook's `tools/codex-setup.sh` after adding worktrees.
'''
for target in entries:
    if not target.exists() or target.read_text() != content:
        target.write_text(content)
    ignored = subprocess.run(['git', '-C', str(target.parent), 'check-ignore', '-q', target.name]).returncode == 0
    if not ignored:
        raise SystemExit(f'Instruction file is not ignored: {target}')
    print(f'ready: {target}')
print(f'{len(entries)} code worktree(s) configured; canonical instructions: {hb / "AGENTS.md"}')
PY
