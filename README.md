# pica-cli

Public release repository for the Picadabra CLI.

This repository hosts:

- GitHub Releases for prebuilt `pica` binaries
- Release checksums
- Installation guidance
- Public issue tracking for distribution concerns

The source code lives in a private monorepo. Releases in this repository are
published automatically from the upstream build pipeline.

## Install With Homebrew

```bash
brew tap AIGC-Hackers/pica
brew install pica
```

If you prefer the fully-qualified formula name:

```bash
brew install AIGC-Hackers/pica/pica
```

## Direct Download

Download a platform archive from the
[Releases](https://github.com/AIGC-Hackers/pica-cli/releases) page, extract it,
and place the `pica` binary on your `PATH`.

Current release archives follow this pattern:

- `pica-darwin-arm64.tar.gz`
- `pica-darwin-x64.tar.gz`
- `pica-linux-arm64.tar.gz`
- `pica-linux-x64.tar.gz`

Each release also includes a `checksums.txt` file with SHA-256 digests.

## After Install

After installing `pica`, complete the initial setup before using CLI features
that talk to Picadabra services.

### 1. Sign in and create an API key

1. Visit [https://picadabra.ai/](https://picadabra.ai/) and sign in.
2. Open the dashboard.
3. Go to `API Keys`.
4. Click `Create new key` and copy the generated key to a secure place.

If you cannot load the API key page, make sure you have completed sign-in first.

### 2. Install the Picadabra skill into your agent workspace

Install the official Picadabra skill in the working directory where your agent
runs:

```bash
pica skill install picadabra/pica
```

This installs the Picadabra skill locally so your agent can discover and use
Picadabra capabilities from the current workspace.

### 3. Continue with CLI setup

Use the API key you created above with the relevant `pica` authentication or
configuration flow in your environment, then verify the active setup with:

```bash
pica status
```

## Current Limits

- `ffmpeg` and `ffprobe` are not bundled yet.
- Commands that rely on local media probing may require system tooling until the
  managed toolchain work lands.

## Support

- Release issues: open an issue in this repository
- Product and source work: handled in the private upstream repository
