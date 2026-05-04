#!/usr/bin/env python3
"""Generate non-Claude adapter formats from skills/*/SKILL.md sources.

Source of truth: skills/<name>/SKILL.md
Outputs:
  adapters/cursor/.cursor/rules/<name>.mdc
  adapters/aider/CONVENTIONS.md
  adapters/openai-gpt/<name>.md
  adapters/gemini-gem/<name>.md
  adapters/raw/<name>.md
"""
from __future__ import annotations

import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
SKILLS_DIR = ROOT / "skills"
ADAPTERS_DIR = ROOT / "adapters"


def parse_skill(path: pathlib.Path) -> dict:
    text = path.read_text(encoding="utf-8")
    fm_match = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.DOTALL)
    if not fm_match:
        raise ValueError(f"no frontmatter in {path}")
    fm, body = fm_match.groups()
    name = re.search(r"^name:\s*(.+)$", fm, re.M).group(1).strip()
    desc = re.search(r"^description:\s*(.+)$", fm, re.M).group(1).strip()
    return {"name": name, "description": desc, "body": body.strip(), "path": path}


def write(path: pathlib.Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def build_cursor(skills: list[dict]) -> None:
    base = ADAPTERS_DIR / "cursor" / ".cursor" / "rules"
    for s in skills:
        content = (
            f"---\n"
            f"description: {s['description']}\n"
            f"alwaysApply: false\n"
            f"---\n\n"
            f"{s['body']}\n"
        )
        write(base / f"{s['name']}.mdc", content)


def build_aider(skills: list[dict]) -> None:
    base = ADAPTERS_DIR / "aider"
    parts = [
        "# sevaai-sdlc Conventions for Aider\n",
        "\n",
        "Run aider with `aider --read CONVENTIONS.md` so these rules are loaded into every session.\n",
        "Each section corresponds to one SDLC stage skill. Mention the stage name (or its trigger\n",
        "phrases) in your prompt to invoke that section's behavior.\n",
    ]
    for s in skills:
        parts.append(
            f"\n---\n\n"
            f"# {s['name']}\n\n"
            f"**Triggers when:** {s['description']}\n\n"
            f"{s['body']}\n"
        )
    write(base / "CONVENTIONS.md", "".join(parts))


def build_openai_gpt(skills: list[dict]) -> None:
    base = ADAPTERS_DIR / "openai-gpt"
    for s in skills:
        content = (
            f"# System prompt for the {s['name']} GPT\n\n"
            f"Paste the block below as **Instructions** when you create a custom GPT in ChatGPT.\n"
            f"Optionally upload your project's README, ADRs, and prior dossier artifacts as Knowledge.\n\n"
            f"---\n\n"
            f"You are the **{s['name']}** agent in the sevaai-sdlc pipeline.\n\n"
            f"**You should activate when:** {s['description']}\n\n"
            f"{s['body']}\n"
        )
        write(base / f"{s['name']}.md", content)


def build_gemini_gem(skills: list[dict]) -> None:
    base = ADAPTERS_DIR / "gemini-gem"
    for s in skills:
        content = (
            f"# Custom instructions for the {s['name']} Gemini Gem\n\n"
            f"Paste the block below as the Gem's instructions in Gemini.\n\n"
            f"---\n\n"
            f"You are the **{s['name']}** agent in the sevaai-sdlc pipeline.\n\n"
            f"**You should activate when:** {s['description']}\n\n"
            f"{s['body']}\n"
        )
        write(base / f"{s['name']}.md", content)


def build_raw(skills: list[dict]) -> None:
    base = ADAPTERS_DIR / "raw"
    for s in skills:
        content = (
            f"# {s['name']}\n\n"
            f"**Triggers when:** {s['description']}\n\n"
            f"{s['body']}\n"
        )
        write(base / f"{s['name']}.md", content)


def main() -> None:
    skills = [parse_skill(p) for p in sorted(SKILLS_DIR.glob("*/SKILL.md"))]
    build_cursor(skills)
    build_aider(skills)
    build_openai_gpt(skills)
    build_gemini_gem(skills)
    build_raw(skills)
    print(f"Built adapters for {len(skills)} skills under {ADAPTERS_DIR}/:")
    for s in skills:
        print(f"  - {s['name']}")


if __name__ == "__main__":
    main()
