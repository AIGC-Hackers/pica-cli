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

### Wait for completion

```bash
pica task wait t1
pica task wait --input "{ taskIds: ['t1', 't2', 't3'], timeout: 300 }"
```

Use direct syntax for the trivial single-task case. Once you need multiple task IDs or timeout control, prefer command-level `--input`.

- non-TTY: block silently, then emit final `toon` on stdout
- TTY: live status on stderr, final `toon` on stdout
- multi-task output preserves input order

## Status semantics

`persisting` means provider work is done and pica is still materializing outputs. It is not "stuck".

## Output refs

Completed tasks expose `blob://` refs. Reuse them in `pica generate` or fetch them with `pica assets`.
