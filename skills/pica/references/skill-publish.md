# pica skill publish

Publish a skill folder to the registry. Re-publishing the same slug updates the existing skill (upsert by owner + slug).

For the exact current command contract, inspect:

```bash
pica --schema=.skill.publish
pica --schema=.skill.inspect
```

## Skill folder structure

```
my-skill/
├── SKILL.md              # Required — frontmatter (name, description) + body
├── references/*.md       # Optional — layered context, indexed from SKILL.md
├── assets/*              # Optional — images, videos, reference files
└── _layout.mdx           # Optional — hero layout for the web detail page
```

If you plan to use `_layout.mdx`, read `references/skill-layout.md`. Layout rules are intentionally stricter than normal markdown authoring and are not covered in full here.

SKILL.md must have YAML frontmatter:

```yaml
---
name: kebab-case-slug
description: >-
  One paragraph describing what the skill does and when it's relevant.
---
```

## Workflow: inspect → fix → publish

### 1. Inspect (dry run)

Always inspect before publishing:

```bash
pica skill inspect ./my-skill
```

This validates the folder and reports:

- Frontmatter validity
- Layout validation (if `_layout.mdx` present)
- Individual file sizes and total package size
- Any violations

Fix all reported issues before proceeding to publish.

### 2. Handle asset issues

**Package limits:**

- Single file: max 50 MB
- Total package: max 500 MB

**Video assets are the most common offender.** Showcase and reference videos often have unnecessarily high bitrate. Before publishing, probe and compress:

```bash
# Check video encoding
ffprobe -v quiet -print_format json -show_format -show_streams assets/video.mp4

# Key numbers to look for:
#   bit_rate > 10000 kbps → excessive for reference material
#   resolution > 1080p → unnecessary for showcase content
```

**Compress oversized videos** — reference/showcase videos don't need source quality. Published videos are processed for web playback after upload, so the source file only needs to be "good enough":

```bash
# Target: 720p, CRF 28, ~2-4 Mbps — visually good, 10x smaller
ffmpeg -y -i assets/video.mp4 \
  -c:v libx264 -crf 28 -preset medium \
  -vf "scale='min(720,iw)':-2" \
  -c:a aac -b:a 128k \
  assets/video-compressed.mp4

# Replace original
mv assets/video-compressed.mp4 assets/video.mp4
```

**Batch compress** all videos over a threshold:

```bash
for f in assets/v*.mp4; do
  size=$(stat -f%z "$f")
  if [ "$size" -gt 10485760 ]; then  # > 10MB
    ffmpeg -y -i "$f" -c:v libx264 -crf 28 -preset medium \
      -vf "scale='min(720,iw)':-2" -c:a aac -b:a 128k "${f%.mp4}-c.mp4"
    mv "${f%.mp4}-c.mp4" "$f"
  fi
done
```

**Image assets** are rarely a problem (typically < 1 MB each), but if needed:

```bash
# Convert to WebP for smaller size
ffmpeg -y -i assets/image.png -quality 80 assets/image.webp
```

### 3. Publish

```bash
pica skill publish --input "{ folder: './my-skill', category: 'video' }"
```

Categories: `image`, `video`, `audio`, `workflow`, `other`.

The publish command:

1. **Registers** the skill (creates or updates by slug)
2. **Packs** markdown files into a tarball
3. **Uploads** the tarball + all individual asset files in parallel
4. **Finalizes** — pica records package metadata and starts post-processing for published assets

After finalize, published assets are processed asynchronously:

- Images → made available through public asset URLs
- Videos → prepared for streaming-friendly playback on the web
- Markdown and reference asset URLs are already normalized before publish completes

### 4. Update metadata only

To change title, description, tags, or category without re-uploading:

```bash
pica skill update --input "{ skill: 'picadabra/motion-control', title: 'New Title', description: 'Updated description' }"
pica skill update --input "{ skill: 'picadabra/motion-control', tags: ['dance', 'motion'], category: 'video' }"
```

### 5. Remove

```bash
pica skill remove picadabra/motion-control
```

Deletes the published skill and cleans up its stored package and published assets.

## Supported asset formats

| Type  | Formats             | Notes                                                            |
| ----- | ------------------- | ---------------------------------------------------------------- |
| Image | jpg, png, gif, webp | WebP preferred for size; publish rewrites to CDN                 |
| Video | mp4, webm, mov      | Processed for web playback after publish; compress before upload |
| Other | md, mdx             | Markdown content files; packed into tarball                      |

## Troubleshooting

**Publish failed with a generic server-side error** — Treat this as a product issue, not as a cue to run unrelated infrastructure commands. Re-check the skill folder with `pica skill inspect`, confirm auth and skill ownership context, and surface the failure clearly to the user.

**Presigned/external URLs in markdown** — External URLs are left as-is by publish. Only local `assets/` references get CDN treatment. If you scraped content with external media URLs, download them to `assets/` first and update references.

**Layout validation errors** — `_layout.mdx` is restricted HTML, not arbitrary JSX. For supported elements, scoped `<style>` rules, and hard limits, read `references/skill-layout.md`.
