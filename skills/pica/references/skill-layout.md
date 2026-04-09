# Skill layout (`_layout.mdx`)

`_layout.mdx` is optional. When present, it defines the web detail page layout for a published skill and inserts the SKILL.md body using a single `<Skill />` slot.

This is a web-only concern. It does not affect CLI install behavior or agent execution after install.

## When to use it

Use `_layout.mdx` when a skill benefits from a custom hero or media-first presentation on the registry page:

- A visual showcase for image/video workflows
- Before/after examples
- Step cards or structured previews above the markdown body

Skip it when the skill is mostly instructional and plain markdown is enough.

## File placement

```text
my-skill/
├── SKILL.md
├── _layout.mdx
├── references/*.md
└── assets/*
```

If `_layout.mdx` is missing, the web page falls back to rendering only the markdown body.

## Mental model

The layout pipeline is intentionally narrow:

1. Parse `_layout.mdx` as HTML fragment
2. Extract and validate any `<style>` blocks
3. Scope extracted CSS to the skill page wrapper
4. Validate the remaining HAST tree
5. Store layout DOM and scoped CSS separately

The goal is predictable static presentation, not a miniature app platform.

## Allowed markup

Allowed elements are intentionally restricted to static content and media:

- Layout: `div`, `section`, `main`, `aside`, `header`, `footer`, `nav`, `article`
- Text: `p`, `span`, `h1`-`h6`, `strong`, `em`, `br`, `hr`, `blockquote`, `pre`, `code`
- Lists: `ul`, `ol`, `li`
- Media: `img`, `video`, `audio`, `source`, `picture`, `figure`, `figcaption`
- Links: `a`
- Tables: `table`, `thead`, `tbody`, `tr`, `th`, `td`
- Special: `style`, `Skill`

Hard limits:

- Exactly one `<Skill />`
- Max nesting depth: 10
- Max element count: 200

Forbidden:

- `script`, `iframe`, `object`, `embed`, `meta`, `base`, `noscript`, `template`, `slot`
- `form`, `input`, `button`, `textarea`, `select`
- Event handlers like `onclick`
- Dangerous URL protocols such as `javascript:`, `data:`, and `vbscript:`

## Styles

You can use either:

- Inline `style=""` attributes
- Restricted `<style>` blocks

`<style>` support is scoped automatically during publish so CSS does not leak into the host page.

### Supported CSS

- Normal style rules
- `@media`
- `@supports`

### Rejected CSS

- `url()`
- `@import`
- `expression()`
- `-moz-binding`
- `@keyframes`
- `@font-face`
- `@property`
- Other advanced at-rules not explicitly supported

This is deliberate. Layout CSS is for static presentation, not for loading remote resources or building a full styling runtime.

## Asset references

Use relative paths such as:

```html
<img src="assets/cover.webp" alt="Cover" />
<video src="assets/demo.mp4" poster="assets/poster.webp"></video>
```

During publish, local asset URLs are rewritten to CDN URLs.

## Example

```html
<style>
	.hero {
		display: grid;
		grid-template-columns: 1.2fr 1fr;
		gap: 1.5rem;
		padding: 1.5rem;
		border: 1px solid var(--border);
		border-radius: 1rem;
		background: var(--card);
	}

	.hero__media {
		width: 100%;
		border-radius: 0.75rem;
		overflow: hidden;
		aspect-ratio: 16 / 9;
	}
</style>

<section class="hero">
	<div>
		<h1>Motion Control</h1>
		<p>Transfer reference movement to your character image.</p>
	</div>
	<figure class="hero__media">
		<img src="assets/hero.webp" alt="Motion control preview" />
	</figure>
</section>

<Skill />
```

## Workflow

Before publish:

```bash
pica --schema=.skill.inspect
pica skill inspect ./my-skill
```

Then publish:

```bash
pica --schema=.skill.publish
pica skill publish --input "{ folder: './my-skill', category: 'video' }"
```

If inspect fails on `_layout.mdx`, fix the layout first. Do not brute-force publish retries.

## Common mistakes

- Forgetting to include `<Skill />`
- Adding more than one `<Skill />`
- Treating `_layout.mdx` like JSX instead of restricted HTML
- Putting too much page logic into layout instead of keeping it as presentation
- Using unsupported CSS features and expecting browser behavior to sort it out

## Related

- `references/skill-publish.md` for the overall publish workflow
