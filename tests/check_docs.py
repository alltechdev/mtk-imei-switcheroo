#!/usr/bin/env python3
"""Check repository Markdown file links and GitHub-style heading anchors offline."""
import re
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]


def prose(text):
    return re.sub(r'^(`{3,}|~{3,}).*?^\1[^\n]*$', '', text, flags=re.M | re.S)


def anchors(text):
    found, counts = set(), {}
    for heading in re.findall(r'^#{1,6}\s+(.+?)\s*#*$', prose(text), re.M):
        heading = re.sub(r'\[([^]]+)\]\([^)]*\)', r'\1', heading)
        heading = re.sub(r'<[^>]+>', '', heading).lower()
        slug = re.sub(r'[^\w\-\s]', '', heading).replace(' ', '-')
        n = counts.get(slug, 0)
        counts[slug] = n + 1
        found.add(slug + ('-' + str(n) if n else ''))
    found.update(re.findall(r'<a\s+(?:id|name)=[\"\']([^\"\']+)', text))
    return found


def main():
    files = [ROOT/'README.md']
    for directory in ['docs', 'tools', 'firmware', 'research', 'tests']:
        files.extend((ROOT/directory).rglob('*.md'))
    errors, checked = [], 0
    for path in files:
        for link in re.findall(r'\]\(([^\s)]+)\)', prose(path.read_text())):
            if re.match(r'[a-zA-Z][a-zA-Z0-9+.-]*:', link):
                continue
            target, _, fragment = unquote(link).partition('#')
            dest = (path.parent/target).resolve() if target else path
            checked += 1
            if not dest.exists():
                errors.append(f'{path.relative_to(ROOT)}: missing {link}')
            elif fragment and dest.suffix == '.md' and fragment not in anchors(dest.read_text()):
                errors.append(f'{path.relative_to(ROOT)}: missing heading {link}')
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print(f'PASS: {checked} local links across {len(files)} Markdown files')
    return 0


if __name__ == '__main__':
    sys.exit(main())
