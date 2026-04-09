---
name: pica
description: >-
  The `pica` command. AI media generation CLI — generate images, videos, and audio
  using models from FAL, WaveSpeed, and other providers. Discover models, manage
  generation tasks, search and install content skills, and download output assets.
---

## Execution rules

- `pica` is a **global CLI tool**. Run it directly (`pica status`, `pica generate ...`), never `cd` into the skill directory first.
- **Project context required**: All generation belongs to a project. Set a current project before generating.
- **Auth required**: Most operations need authentication. Run `pica auth login --api-key <key>` first.
- **Session IDs**: pica assigns short IDs to task-like workflows where chaining helps. Published skills use public `owner/slug` references instead.
- **Never guess model IDs**: Always use `pica model search` + `pica model info` to get exact `provider:modelId` strings.
- **Always respect preflight**: `pica generate` now runs preflight before upload/dispatch. Treat preflight failures as input problems to fix, not as something to brute-force past.
- **Use `--schema` for exact command shape**: these docs teach workflow and judgment. When you need the current flags, enums, or input contract, inspect `pica --schema` (for example `pica --schema=.generate`, `pica --schema=.task`, `pica --schema=.skill.publish`).

## Core Workflow: preflight → discover → validate inputs → generate → collect

### 1. Preflight

```bash
pica status
```

Shows auth state, credits, and current project. Fix any issues before proceeding:

- No auth → `pica auth login --api-key <key>`
- No project → `pica project create "Campaign Name"` (auto-sets as current)
- Wrong project → `pica project switch <project-id>`

### 2. Discover content skills (recommended)

```bash
pica skill find "ugc ads"
pica skill install dio/motion-control
```

Skills are domain-specific guides that teach model selection, prompt techniques, and generation workflows for specific content types. After installing, **read the SKILL.md**:

```bash
# The install output tells you the path
cat .agents/skills/<owner>/<slug>/SKILL.md
```

Skills may recommend specific models, prompt patterns, or multi-step generation workflows. Follow their guidance — they encode expert knowledge for the content domain.

### 3. Discover models

```bash
pica model search "flux"
pica model search "text to video"
pica model info fal:fal-ai/flux-pro/v1.1
```

`model info` returns the **discovered model input schema** — use it to construct the `--input` JSON for `generate`.

Important: this schema is guidance, not a perfect contract. Some providers express critical media constraints only in prose or examples. Use it to learn field names and required params, then let preflight validate local media facts before generating.

### 4. Validate inputs before generate

For any `file://` media input, assume the file is untrusted until preflight inspects it.

What preflight checks:

- Required fields, basic types, enum values from the discovered schema
- Local media facts such as MIME type, width, height, duration, and file size
- Curated model/skill overlays where Pica knows more than the provider schema

What to do with the result:

- **Blocking issues**: stop and fix the input assets first
- **Warnings**: continue only if the user accepts the risk or the warning is clearly non-fatal
- **Suggested fixes**: prefer editing the asset over retrying the same generate command

Typical fixes:

- Resize an image to the required range
- Trim a reference video to the supported duration
- Replace the wrong media type in a field (`video_url` must be video, etc.)

### 5. Generate

```bash
pica generate --model fal:fal-ai/flux-pro --kind image_generation --input '{"prompt":"A cat in space"}'
pica generate --model wavespeed:veo3/text-to-video --kind video_generation --input '{"prompt":"..."}'
```

Generate first runs preflight, then creates an async task, waits for completion, and returns output `blob://` references. Pass the task kind explicitly. If you need the exact `--kind` enum or output behavior, inspect `pica --schema=.generate`. Local files in input are auto-uploaded only after preflight passes:

```bash
pica generate --model fal:fal-ai/flux-pro \
  --kind image_generation \
  --input '{"image":"file://photo.png","prompt":"enhance this"}'
```

### 6. Collect outputs

Output `blob://` refs appear in the generate result. Download to disk:

```bash
pica assets download a1 a2 --output-dir ./downloads
```

Or inspect the full task result:

```bash
pica task get t1
```

When you need to recover recent work across states, prefer `pica task list` first.
By default it lists recent tasks from the current project across all statuses. Add
`--status active` only when you explicitly want the live queue.

## Session IDs

pica assigns short IDs to entities within a session. They persist across CLI invocations.

| Prefix     | Entity  | Assigned by                 | Example                                            |
| ---------- | ------- | --------------------------- | -------------------------------------------------- |
| `t1`, `t2` | Tasks   | `generate`, `task get/list` | `pica task get t1`                                 |
| `a1`, `a2` | Assets  | `generate`, `task get`      | `pica assets download a1 --output-dir ./downloads` |
| `r1`, `r2` | Prompts | `prompt find`               | `pica prompt get r1`                               |

Use session IDs where the command output explicitly gives you one. Skills are installed by public reference (`owner/slug`), not by session ID.

## Schema-first habit

Prefer a simple split:

- Use this skill and its references to decide **what flow to run**
- Use `pica --schema` to learn **how the command is shaped today**

Examples:

```bash
pica --schema=.generate
pica --schema=.task
pica --schema=.model
pica --schema=.skill
```

## Choosing the right command

| Situation                                | Command                                    | Reference              |
| ---------------------------------------- | ------------------------------------------ | ---------------------- |
| Find which models exist for a task       | `pica model search`                        | references/models.md   |
| Get model input schema before generating | `pica model info`                          | references/models.md   |
| Generate images, videos, or audio        | `pica generate`                            | references/generate.md |
| Check generation progress or result      | `pica task get` / `pica task wait`         | references/tasks.md    |
| Download or share generated content      | `pica assets download` / `pica assets url` | references/assets.md   |
| Find domain-specific generation guidance | `pica skill find` → `pica skill install`   | references/skills.md   |

Common compositions:

- **Image generation**: `model search` → `model info` → preflight local assets → `generate --kind image_generation` → `assets download`
- **Video from image**: generate image first → use output `blob://` as input → inspect warnings carefully since blob refs may skip local media probing → `generate --kind video_generation`
- **Batch generation**: run multiple `generate` commands → `task list` to recover recent task IDs/results → use `task list --status active` only for in-flight monitoring → collect outputs when done
- **Skill-guided workflow**: `skill find` → `skill install` → read SKILL.md → follow model + prompt guidance → fix preflight issues → `generate`
