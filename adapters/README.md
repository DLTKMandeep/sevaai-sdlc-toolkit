# Adapters — use sevaai-sdlc with any AI tool

The skills in `skills/` are markdown files. They work with any AI tool that lets you set custom instructions. These adapters re-package the same skills into the format each tool expects, so you don't have to convert by hand.

| Tool | Folder | How to install |
|---|---|---|
| **Claude Code / Cowork** | `..` (repo root) | already supported via `plugin.json` + `.mcp.json`. See main README. |
| **Cursor** | `cursor/` | copy `cursor/.cursor/` into your project root |
| **Aider** | `aider/` | run `aider --read CONVENTIONS.md` or add to `.aider.conf.yml` |
| **ChatGPT (custom GPT)** | `openai-gpt/` | one custom GPT per stage; paste the body as Instructions |
| **Gemini (custom Gem)** | `gemini-gem/` | one Gem per stage; paste the body as instructions |
| **Anything else** | `raw/` | copy/paste into any LLM's system-prompt slot |

These are generated from `skills/<stage>/SKILL.md` by `scripts/build-adapters.py` — don't edit adapter files directly. Edit the SKILL.md and rerun:

```bash
python3 scripts/build-adapters.py
```

## Cursor

```bash
# from your project root
cp -R /path/to/sevaai-sdlc-toolkit/adapters/cursor/.cursor .
```

Cursor auto-loads any `.cursor/rules/*.mdc` files. Each rule has a `description` that tells Cursor when to apply it. You'll get the same per-stage triggering as Claude Code, just inside Cursor's chat / agent.

## Aider

Aider ships with two ways to load conventions: `--read FILENAME` on the CLI, or `read: [FILENAME]` in `.aider.conf.yml`.

```bash
# one-off
aider --read /path/to/sevaai-sdlc-toolkit/adapters/aider/CONVENTIONS.md

# permanent for this project: in .aider.conf.yml
read:
  - /path/to/sevaai-sdlc-toolkit/adapters/aider/CONVENTIONS.md
```

Then mention the stage by name in your prompt:

```
> Run the requirements stage for "Add OAuth signup."
> Generate the threat model for the OAuth feature.
```

## ChatGPT — custom GPTs

For each `openai-gpt/sdlc-<stage>.md`:

1. ChatGPT -> Explore GPTs -> Create.
2. Configure tab -> Name it (e.g., "SDLC Requirements") and paste the file's body into **Instructions**.
3. (Optional) Knowledge tab -> upload your project's README, ADRs, and prior dossier artifacts so the GPT can ground in them.
4. Save. Repeat for each stage.

To run the full pipeline, you can chain GPTs manually (output of stage N becomes input of stage N+1) or build a single "SDLC Orchestrator" GPT with the orchestrator's instructions.

## Gemini — custom Gems

Same flow as ChatGPT, in Gemini's "Gem manager":

1. Gemini -> Gems -> New Gem.
2. Paste the corresponding `gemini-gem/sdlc-<stage>.md` body into the instructions field.
3. Save. Repeat for each stage.

## Anything else (raw)

`raw/sdlc-<stage>.md` is a clean prompt with no platform-specific framing. Use it with:

- **Cline / Continue.dev / Roo Code** — any agent that lets you set per-tool system instructions.
- **Open-source LLMs via Ollama / LM Studio / vLLM** — paste into the system prompt slot.
- **API users** — POST as the `system` field of a chat-completion request.

## A note on tool calls

The Claude-native skills assume the agent has tools like Glob, Read, Grep, Write. Cursor, Aider, and most other agents have equivalents — they're called different things but the agent figures it out from the prompt. For chat-only LLMs (ChatGPT, Gemini Gems without Code Interpreter, raw API), you'll need to feed the agent project files in the message rather than expect it to read them itself. The skill instructions still apply — they just operate on what you paste.
