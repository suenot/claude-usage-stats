# Model brand palettes

## Goal

Make model families visually recognizable across the dashboard while preserving clear separation between adjacent series on the dark background.

## Palette

- Claude models use distinct terracotta and coral shades derived from Anthropic's warm brand color.
- Codex models use distinct emerald and teal shades derived from OpenAI's green brand color.
- Non-Claude and non-Codex model families retain their current colors.
- Every selected color must remain distinguishable in bars, legends, tooltips, and small swatches.

## Architecture

The frontend will define one shared model-color resolver as the single source of truth. Daily charts, model charts, cache charts, legends, and related model indicators will import that resolver instead of maintaining local color maps.

Claude and Codex aliases will be matched by normalized family names:

- Claude: Opus, Sonnet, Haiku, Fable
- Codex: Codex Sol, Codex Terra, Codex Luna

Unknown models will continue to use the existing neutral fallback.

## Verification

- Build all workspaces successfully.
- Verify every Claude and Codex family resolves to a unique color.
- Confirm daily chart legends and bars use the same color for each family.
- Confirm token mode continues to color the Codex source with OpenAI green.
- Visually inspect the running dashboard on its dark theme.
