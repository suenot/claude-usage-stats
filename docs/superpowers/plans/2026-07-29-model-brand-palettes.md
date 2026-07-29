# Model Brand Palettes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give Claude and Codex model families distinct shades of their respective Anthropic and OpenAI brand colors across the dashboard.

**Architecture:** Add one frontend color module that normalizes model and source names and returns stable colors. Replace component-local palettes with imports from that module so charts and legends cannot drift.

**Tech Stack:** React, TypeScript, Chart.js, Vite

## Global Constraints

- Claude uses distinguishable terracotta and coral shades.
- Codex uses distinguishable emerald and teal shades.
- Existing colors for unrelated model families remain unchanged.
- The dark-theme contrast and USD/Tokens chart modes must remain readable.

---

### Task 1: Centralize model and source colors

**Files:**
- Create: `frontend/src/lib/model-colors.ts`
- Modify: `frontend/src/components/DailyChart.tsx`
- Modify: `frontend/src/components/ModelChart.tsx`
- Modify: `frontend/src/components/CacheChart.tsx`
- Modify: `frontend/src/components/SourceChart.tsx`

**Interfaces:**
- Produces: `colorForModel(name: string): string`, `colorForSource(name: string): string`, and `shade(hex: string, factor: number): string`.
- Consumers: all chart datasets, legend swatches, and cache bars.

- [ ] **Step 1: Add the shared palette**

```ts
export const MODEL_COLORS = {
  Opus: '#D97757',
  Sonnet: '#E89574',
  Haiku: '#B85C43',
  Fable: '#F0B29C',
  'Codex Sol': '#087F68',
  'Codex Terra': '#10A37F',
  'Codex Luna': '#55C6A9',
  'GLM 5.2': '#22d3ee',
} as const;
```

Normalize raw identifiers such as `claude-opus-*` and `gpt-5.6-sol` to the same family entries.

- [ ] **Step 2: Replace local component palettes**

Import the shared resolvers in all four components. Preserve per-version shading in `ModelChart`, but derive each shade from the shared family base.

- [ ] **Step 3: Build and verify**

Run:

```bash
npm run build
```

Expected: all workspaces compile and the frontend production bundle completes.

Verify in the running dashboard:

- Claude families use four distinct warm shades.
- Codex Sol, Terra, and Luna use three distinct green shades.
- USD and Tokens modes retain consistent legend and bar colors.
- Source and model doughnuts match the shared palette.

- [ ] **Step 4: Commit and push**

```bash
git add frontend
git commit -m "feat: apply Anthropic and OpenAI model palettes"
git push
```
