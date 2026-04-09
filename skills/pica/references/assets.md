# pica assets

Use `pica assets` after a task has produced outputs and you need to download or share them.

For the exact current command contract, inspect:

```bash
pica --schema=.assets
```

## Asset refs

Pica accepts three common asset reference shapes:

- session alias like `a1`
- `blob://abc123`
- raw blob ID like `abc123`

Important:

- `a1` is a session-local alias. It is convenient inside the current CLI conversation, but it is not a durable cross-session identifier.
- `blob://...` and raw blob IDs refer to the underlying asset and are the safer choice when you need to carry a reference across steps or quote it back to the user.

## Two common jobs

### 1. Get a shareable URL

```bash
pica assets url --input "{ ids: ['a1'], visibility: 'public' }"
```

Use this when the user needs a direct link for embedding, review, or handoff and the request involves a single asset.

For multiple assets, use the same pattern:

```bash
pica assets url --input "{ ids: ['a1', 'blob://abc123'], visibility: 'public' }"
```

These are the two canonical `assets url` shapes to teach and reuse:

- single asset: `pica assets url --input "{ ids: ['a1'], visibility: 'public' }"`
- multiple assets: `pica assets url --input "{ ids: [...], visibility: 'public' }"`

Do not guess alternate syntax in automation when one of these two forms fits. Ask `pica --schema=.assets.url` if you need the current exact payload shape.

If the agent is sending the result through an asynchronous delivery surface, for example IM, chat, email, or notifications, and the receiver may not share the current auth context, default to these `public` URL forms so the preview link still works when opened later.

This returns a durable public share URL owned by Pica. The outer URL stays stable; the server may still redirect internally to short-lived storage URLs.

### 2. Download assets locally

```bash
pica assets download --input "{ assets: ['a1', 'a2'], outputDir: './downloads' }"
```

Use this when the user needs files on disk for further editing, upload elsewhere, or local inspection.

## Layout choice when downloading

Downloads support two broad shapes:

- `preserve`: keep the stored remote folder structure
- `flat`: write all outputs directly into one directory

Use `preserve` when path structure is useful context.  
Use `flat` when the user just wants files quickly in one place.

If you need the exact flag names or current defaults, use `pica --schema=.assets.download`.

## Chaining mindset

You do not always need to download an asset.

Often the better flow is:

1. generate something
2. keep the returned `blob://` ref
3. feed that ref into the next `pica generate`

Download only when the user explicitly needs a local file or external share link.

## When to use this reference

Read this when you need guidance on:

- when to use `assets url` vs `assets download`
- how to think about asset refs
- when to keep chaining with `blob://` instead of downloading

Use `--schema` when you need:

- exact payload shape
- exact layout field shape
- exact defaults
