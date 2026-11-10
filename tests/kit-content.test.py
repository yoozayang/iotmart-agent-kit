#!/usr/bin/env python3
"""Check owned instruction references in the source kit or an installed project."""

import re
import sys
import unittest
from pathlib import Path

ROOT = Path(sys.argv.pop(1)).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
SKILL = Path('.agents/skills/evidence-investigation-documentation')


def owned_documents():
    return [
        *(ROOT / name for name in ('AGENTS.md', 'CLAUDE.md', 'GEMINI.md')),
        *(ROOT / '.codex').rglob('*.md'),
        *(ROOT / SKILL).rglob('*.md'),
        ROOT / '.agents/skills/iotmart-code-review/SKILL.md',
    ]


class InstructionReferences(unittest.TestCase):
    def test_project_paths(self):
        for source in owned_documents():
            for target in re.findall(r'`((?:\.codex/|\.agents/)[^`]+)`', source.read_text()):
                if any(marker in target for marker in ('<', '...', ' ')):
                    continue
                with self.subTest(source=source.relative_to(ROOT), target=target):
                    self.assertTrue(list(ROOT.glob(target.rstrip('/'))), 'missing project reference')

    def test_skill_relative_links(self):
        for source in (ROOT / SKILL).rglob('*.md'):
            for target in re.findall(r'\]\(([^)]+\.md)\)', source.read_text()):
                with self.subTest(source=source.relative_to(ROOT), target=target):
                    self.assertTrue((source.parent / target).is_file(), 'missing skill reference')

    def test_standalone_documentation_references(self):
        # Skills-only installs do not contain the project's .codex directory.
        for source in (ROOT / SKILL).rglob('*.md'):
            self.assertNotIn('.codex/', source.read_text(), str(source))


if __name__ == '__main__':
    unittest.main()
