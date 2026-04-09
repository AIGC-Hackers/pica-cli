# Handling Friction

This note is intentionally narrow.

It is not a maintainer runbook and not a repository workflow guide. Its purpose is only to help an agent respond sanely when pica behavior is confusing or fails.

## When something goes wrong

Prefer this order:

1. Identify whether the problem is input, command usage, or product behavior
2. Re-check the current command contract with `pica --schema`
3. Re-run the smallest safe step that can confirm the issue
4. Explain clearly to the user what is known vs unknown

## Good agent behavior

- Do not guess flags or enums from memory
- Do not jump to unrelated infrastructure actions
- Do not hide ambiguous failures behind vague language
- Do separate “your input is invalid” from “pica appears to have failed”

## Useful recovery questions

Ask yourself:

- Did preflight already explain the failure?
- Am I using the current command shape from `--schema`?
- Is this a local input problem (`file://`, media facts, bad JSON)?
- Is this an async task issue that should be checked with `pica task get` or `pica task wait`?

## What to tell the user

If the failure is clear:

- say exactly what failed
- say what the next smallest corrective action is

If the failure is unclear:

- say what you verified
- say what remains uncertain
- avoid pretending the root cause is known

## Examples

- Bad: “Server error, deploy the backend.”
- Good: “The publish request failed after local validation passed. I rechecked the skill folder and command shape; this now looks like a product-side failure rather than an input mistake.”

- Bad: “Maybe the model is flaky, retry.”
- Good: “Preflight says the reference video duration exceeds the allowed limit for this workflow. Trimming the video is the correct next step.”
