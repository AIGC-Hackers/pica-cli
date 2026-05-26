# pica assets

Use `pica assets` when you need to upload local assets, create share URLs, or download task outputs.

For the exact current command contract, inspect:

```bash
pica --schema=.assets
```

Treat the schema as authoritative. List-like inputs such as `files`, `ids`, and
`assets` are comma-separated strings in the CLI contract, not arrays or
space-separated varargs.

## Asset refs

Pica accepts three common asset reference shapes:

- session alias like `a1`
- `blob://abc123`
- raw blob ID like `abc123`

Important:

- `a1` is a session-local alias. It is convenient inside the current CLI conversation, but it is not a durable cross-session identifier.
- `blob://...` and raw blob IDs refer to the underlying asset and are the safer choice when you need to carry a reference across steps or quote it back to the user.

## Common jobs

### 1. Upload a local asset and get a URL

```bash
pica assets upload ./hero.png --purpose brand-asset --visibility public
```

Use this when the user or an operator needs to put an asset into Pica and get a stable URL for a page, prompt, handoff, or external reference.

By default uploads are app-scoped, not project-scoped, so page assets do not accidentally inherit whatever generation project is currently selected. Add `project` only when the asset should belong to a specific project history:

```bash
pica assets upload ./reference.png --project <project-id> --purpose reference
```

Use `visibility: 'public'` for durable page or async-message links. Use `visibility: 'signed'` when the caller only needs a short-lived authenticated storage URL.

For video uploads, set `syncVideoStream: true` after the backend supports asset stream sync:

```bash
pica assets upload ./demo.mp4 --purpose brand-asset --visibility public --sync-video-stream
```

That returns the normal asset URL plus the Bunny Stream HLS URL when encoding registration succeeds.

### 2. Get a shareable URL for an existing asset

```bash
pica assets url --ids a1 --visibility public
```

Use this when the user needs a direct link for embedding, review, or handoff and the request involves a single asset.

For multiple assets, use the same pattern:

```bash
pica assets url --ids a1,blob://abc123 --visibility public
```

These are the two canonical `assets url` shapes to teach and reuse:

- single asset: `pica assets url --ids a1 --visibility public`
- multiple assets: `pica assets url --ids a1,blob://abc123 --visibility public`

Do not guess alternate syntax in automation when one of these two forms fits. Ask `pica --schema=.assets.url` if you need the current exact payload shape.

If the agent is sending the result through an asynchronous delivery surface, for example IM, chat, email, or notifications, and the receiver may not share the current auth context, default to these `public` URL forms so the preview link still works when opened later.

This returns TOON with `assets` entries containing media directives. For public URLs, the directive URL is a durable public share URL owned by Pica. The outer URL stays stable; the server may still redirect internally to short-lived storage URLs.

### 3. Download assets locally

```bash
pica assets download a1,a2 --output-dir ./downloads
```

Use this when the user needs files on disk for further editing, upload elsewhere, or local inspection. Successful downloads emit TOON with `files` media directives using `file://` URLs.

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

- when to use `assets upload`, `assets url`, or `assets download`
- how to think about asset refs
- when to keep chaining with `blob://` instead of downloading

Use `--schema` when you need:

- exact payload shape
- exact layout field shape
- exact defaults
