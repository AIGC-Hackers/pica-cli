# pica task

Use `pica task` to inspect or wait on existing tasks.

If command shape matters, inspect:

```bash
pica --schema=.task
```

Use session IDs like `t1` when available.

## Common actions

### Get one task

```bash
pica task get t1
```

Use for one task's current detail.

### List recent tasks

```bash
pica task list
```

Use to recover recent task IDs or scan queue state.
Successful list output is TOON on stdout:

```toon
tasks[1]{id,model,status,created}:
  t1,fal:fal-ai/flux/dev,completed,2026-05-07T00:00:00.000Z
```

Empty lists emit an empty `tasks` result, not a prose "not found" message.

### Wait for completion

```bash
pica task wait t1
pica task wait --input "{ taskIds: ['t1', 't2', 't3'], timeout: 300 }"
```

Use direct syntax for the trivial single-task case. Once you need multiple task IDs or timeout control, prefer command-level `--input`.

- non-TTY: block silently, then emit final TOON on stdout
- TTY: live status on stderr, final TOON on stdout
- multi-task output preserves input order

## Status semantics

`persisting` means provider work is done and pica is still materializing outputs. It is not "stuck".

## Output refs

Completed tasks expose media directives in `outputs`, using `blob://` URLs for chaining. Reuse those blob refs in `pica generate` or fetch them with `pica assets`.
