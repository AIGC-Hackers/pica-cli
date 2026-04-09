# pica skill

Use `pica skill` to discover domain-specific guidance before you start guessing prompts, models, or workflows.

For the exact current command contract, inspect:

```bash
pica --schema=.skill
```

## Why this matters

The best skill often saves more time than any amount of random model trial-and-error.

Examples:

- UGC ad production
- product photography
- talking avatars
- motion transfer
- video editing

These skills encode judgment, not just syntax.

## Recommended workflow

1. Search for a domain skill
2. Install the best match
3. Read its `SKILL.md`
4. Follow its workflow before reaching for raw generation

Example:

```bash
pica skill find "ugc ads"
pica skill install picadabra/motion-control
```

Public registry skills install under:

```text
.agents/skills/<owner>/<slug>/
```

Read the installed entry point here:

```text
.agents/skills/<owner>/<slug>/SKILL.md
```

## When to use skills first

- The user asks for a recognizable content domain
- You suspect there is already a known workflow
- The task is multi-step and quality-sensitive
- You want guidance on model choice, prompting, or sequencing

## Search vs install

- `skill find`: discover what guidance exists
- `skill install`: bring the chosen guidance into the local workspace

Install output tells you what was installed and where to read it.

## Publish and management

Publishing, updating, and removing skills are maintainer workflows. If you are doing that, read:

- `references/skill-publish.md`
- `references/skill-layout.md` when `_layout.mdx` is involved

## When to use this reference

Read this when you need help with:

- when to search for a skill before generating
- how installed skills fit into the workflow
- where installed public skills live on disk

Use `--schema` when you need:

- exact `find/install/update/remove` arguments
- exact examples for the current CLI version
