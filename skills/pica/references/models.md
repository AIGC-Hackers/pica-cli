# pica model

Use `pica model` to discover what exists and what each model expects.

For the exact current command contract, inspect:

```bash
pica --schema=.model
```

## The two-step pattern

Model work should usually happen in this order:

1. `pica model search` to discover candidates
2. `pica model info` to inspect the exact input contract

Do not guess model IDs from memory.

## Search

Search is for narrowing the space:

```bash
pica model search "flux"
```

Use task-shaped queries, not provider-shaped queries, when the user cares about outcome more than brand:

- `"image upscale"`
- `"talking avatar"`
- `"text to video"`

Do not assume every registry implements every search filter the same way. Use search to gather candidates, then verify the real contract with `model info` before you plan a workflow around a model.

## Info

`model info` is where you verify the real input shape before generating.

```bash
pica model info fal:fal-ai/flux-pro
```

Use it to learn:

- exact `provider:modelId`
- expected fields
- whether the schema looks structured or thin

Important: model schema is guidance, not gospel. Providers often under-specify media limits and conditional rules. Preflight is still the final gate before dispatch.

## Provider format

Models use `provider:modelId`.

Common providers you will see:

- `fal`
- `wavespeed`
- `pica`

Do not invent semantics for a provider prefix from prose docs. If you are unsure whether a model is usable for generation, inspect it and follow the current CLI/schema behavior.

## When to use this reference

Read this when you need help with:

- how to choose search vs info
- how to think about model IDs safely
- how much to trust provider schema

Use `--schema` when you need:

- exact search filters
- exact `info` argument shape
- current command examples
