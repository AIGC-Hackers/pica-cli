# pica generate

Use `pica generate` when you are ready to turn a validated input into a real task.

This reference is about execution flow, not exhaustive flag documentation. For the exact current command contract, inspect:

```bash
pica --schema=.generate
```

## What generate does

`pica generate` is not just a raw dispatch call. It does four things in order:

1. Resolve the current project
2. Run preflight on the input
3. Upload local `file://` assets only if preflight passes
4. Create a task and wait for completion

That means a failed preflight is not “the model being picky”. It usually means your input is wrong and should be fixed before retrying.

## Core workflow

### 1. Pick the exact model

Do not guess model IDs.

```bash
pica model search "your task"
pica model info <provider:modelId>
```

### 2. Pick the task kind

The current task kinds are:

- `image_generation`
- `video_generation`
- `speech_generation`

If you need to confirm the enum at runtime, use `pica --schema=.generate`.

### 3. Build one command payload

Use the model schema as guidance, then let preflight validate what it can.

For agent execution, prefer command-level `--input` so the whole generate request lives in one object:

```bash
pica --schema=.generate
pica generate --input @generate.json5
```

Build `generate.json5` from the current `pica --schema=.generate` output. Do not hardcode flag combinations from memory when the schema can tell you the exact current shape.

### 4. Use local files only when needed

Reference local media with `file://` inside the generate payload described by the schema.

Preflight probes local files before upload. If it blocks, fix the asset first.

### 5. Reuse outputs for chaining

Once an asset exists, reuse its `blob://` ref inside the generate payload instead of uploading again.

This is the normal chaining pattern:

- image → video
- image → variation
- speech → downstream media workflows

## Preflight mindset

Preflight is part of the product, not optional ceremony.

It validates:

- discovered schema fields and enums
- local media facts such as MIME type, dimensions, duration, and file size
- curated overlays for known model-specific constraints

Treat results like this:

- Blocking issues: stop and fix the input
- Warnings: continue only if the user accepts the risk
- Suggested fixes: prefer editing the asset over retrying blindly

## Output handling

Without `--output`, `generate` prints `blob://` refs for chaining.

With `--output`, results download automatically using the provided template path.

If you need the exact template variables supported today, check:

```bash
pica --schema=.generate
```

## Waiting behavior

`generate` waits for task completion automatically using kind-specific polling.

Current defaults:

- `image_generation`: fast polling, short timeout
- `video_generation`: slower polling, much longer timeout
- `speech_generation`: fast polling, medium timeout

If you need precise current numbers, use `pica --schema=.task` and the command output itself instead of relying on stale prose.

## When to use this reference

Read this when you need help with:

- the correct order of model selection → preflight → generate
- when to use `file://` vs `blob://`
- how to think about retries and preflight failures

Use `--schema` when you need:

- exact command payload shape
- exact enums
- exact timeout/output contract
