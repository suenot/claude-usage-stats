# OpenRouter Model Pricing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a separate Models page backed exclusively by the live OpenRouter catalog, with searchable and sortable input, output, cache-read, and cache-write prices.

**Architecture:** A focused backend service owns OpenRouter fetching, normalization, five-minute caching, forced refresh, and stale fallback. A thin Hono route exposes the normalized contract. The frontend Models page consumes that contract and owns only presentation, search, and sorting.

**Tech Stack:** TypeScript, Node.js fetch, Hono, React 19, Tailwind CSS, Node test runner, Vite.

## Global Constraints

- Pricing source is only `https://openrouter.ai/api/v1/models?limit=1000`.
- Display every returned model; do not filter to models already used locally.
- Display prices as USD per one million tokens.
- Treat top-level OpenRouter pricing as base pricing. Mark every model with a
  non-empty `pricing.overrides` array as `hasPricingOverrides: true`.
- Preserve numeric zero; represent missing or invalid prices as `null` and render `—`.
- API contract names are exactly `ModelPrice` and `ModelPricingResponse` from the design.
- Backend cache TTL is exactly `300_000` milliseconds.
- Models pricing must work before local usage collection is ready.
- No new runtime dependency and no OpenRouter API key.
- Existing dashboard, sessions, projects, History chart, source/model palettes, and refresh behavior must remain intact.
- Follow strict TDD: add tests and observe the expected RED failure before production implementation.
- UI copy and navigation labels remain English, matching the existing application.
- Responsive layout, keyboard focus, and semantic table controls are required.

---

### Task 1: OpenRouter pricing service, API, and Models page

**Files:**
- Create: `backend/src/services/model-pricing-service.ts`
- Create: `backend/test/model-pricing.test.mjs`
- Modify: `backend/src/server.ts`
- Create: `frontend/src/components/ModelPricingTable.tsx`
- Create: `frontend/src/lib/model-pricing.ts`
- Modify: `frontend/src/lib/api.ts`
- Modify: `frontend/src/App.tsx`
- Modify: `frontend/src/index.css` only if the existing utility classes cannot express the sticky/tinted table behavior

**Interfaces:**
- Backend produces `getModelPricing(options?: { force?: boolean }): Promise<ModelPricingResponse>`.
- Backend exports pure `normalizeOpenRouterModels(payload: unknown): ModelPrice[]`.
- Frontend consumes `api.getModelPricing(force?: boolean): Promise<ModelPricingResponse>`.
- Frontend pure helpers produce filtered and sorted rows without mutating API data.

- [ ] **Step 1: Write backend failing tests**

Create literal fixtures covering:

```js
{
  data: [{
    id: "openai/gpt-test",
    name: "OpenAI: GPT Test",
    context_length: 128000,
    pricing: {
      prompt: "0.00000125",
      completion: "0.000010",
      input_cache_read: "0.000000125",
      input_cache_write: "0.0000015625"
    }
  }, {
    id: "vendor/free-model",
    name: "Free Model",
    context_length: null,
    pricing: { prompt: "0", completion: "0" }
  }]
}
```

Assert exact normalized prices `1.25`, `10`, `0.125`, `1.5625`; provider
`openai`; preserved zeros; `null` missing cache values; deterministic
provider/name ordering; `hasPricingOverrides` for a non-empty overrides array;
five-minute cache reuse; `force: true` refetch;
stale fallback after a successful snapshot; and initial failure propagation.
Inject `fetcher` and `now` into a service factory so tests exercise real cache
logic without network mocks hidden inside production code.

- [ ] **Step 2: Run backend tests and verify RED**

Run:

```bash
npm test -w backend
```

Expected: failure because `model-pricing-service` and its exports do not exist.

- [ ] **Step 3: Implement the backend service and route**

Implement:

```ts
export const MODEL_PRICING_TTL_MS = 300_000;
export function normalizeOpenRouterModels(payload: unknown): ModelPrice[];
export function createModelPricingService(deps?: {
  fetcher?: typeof fetch;
  now?: () => number;
}): {
  getModelPricing(options?: { force?: boolean }): Promise<ModelPricingResponse>;
};
```

Rules:

- Parse upstream JSON defensively.
- Convert valid non-negative USD-per-token strings with `value * 1_000_000`.
- Keep `0`; use `null` for absent, negative, NaN, or infinite values.
- Use `AbortSignal.timeout(10_000)`.
- Request JSON with a descriptive `User-Agent`.
- Cache one successful normalized snapshot for `300_000` ms.
- Coalesce concurrent refreshes into one request.
- On refresh failure, return the previous snapshot with `stale: true`.
- Expose `GET /api/models/pricing`; query `refresh=1` maps to `force: true`.
- Exempt this route from the local collector readiness middleware.
- Return `{ error: "OpenRouter pricing is unavailable" }` with status 502 only
  when no successful snapshot exists.

- [ ] **Step 4: Verify backend GREEN**

Run:

```bash
npm test -w backend
```

Expected: every existing and new backend test passes.

- [ ] **Step 5: Add frontend pure helpers and API types**

In `frontend/src/lib/model-pricing.ts`, define:

```ts
export type ModelPriceSortKey =
  | "contextLength"
  | "inputPerMillion"
  | "cacheReadPerMillion"
  | "cacheWritePerMillion"
  | "outputPerMillion";

export function filterModelPrices(models: ModelPrice[], query: string): ModelPrice[];
export function sortModelPrices(
  models: ModelPrice[],
  sort: { key: ModelPriceSortKey; direction: "asc" | "desc" } | null,
): ModelPrice[];
export function formatPrice(value: number | null): string;
export function formatContext(value: number | null): string;
```

Filtering is case-insensitive over `name`, `id`, and `provider`. Sorting keeps
null values last in both directions and never mutates the source array.
`formatPrice(0)` returns `$0`; missing returns `—`; nonzero values retain enough
precision to distinguish sub-cent cache prices.

- [ ] **Step 6: Build the Models page**

`ModelPricingTable.tsx` must contain:

- Heading `Model pricing`.
- Copy `Live OpenRouter base prices · USD per 1M tokens`.
- OpenRouter source link and fetched timestamp.
- Search input with accessible label `Search models`.
- Result count.
- `Refresh prices` button that requests `refresh=1`.
- Semantic `<table>` with Model, Context, Input, Cache read, Cache write,
  Output columns.
- Numeric header buttons with `aria-sort`.
- Sticky header, right-aligned monospace numbers, provider/model ID secondary
  labels, and a subtle green background on both cache columns.
- A `Tiered` badge beside models with `hasPricingOverrides: true`, plus a short
  accessible note explaining that larger prompts can use different prices.
- Loading skeleton rows; explicit stale badge; retryable first-load error;
  `No models match this search` empty state.
- Horizontal overflow below desktop widths and visible keyboard focus.

Add the `models` tab after `projects` in `App.tsx`. Render this page without
waiting for `summary`. Hide the global usage `Refresh` button only while the
Models tab is active.

- [ ] **Step 7: Build and manually verify GREEN**

Run:

```bash
npm run build -w frontend
npm run build
git -C backend diff --check
git -C frontend diff --check
```

Then verify in Chrome at `http://localhost:5173`:

- Models navigation opens the page.
- The table contains live OpenRouter rows.
- Search for `claude` filters rows.
- Input and Cache read headers toggle sort direction.
- Refresh makes `/api/models/pricing?refresh=1` return 200.
- No new console errors.
- At a narrow viewport, the page stays usable via horizontal table scroll.

- [ ] **Step 8: Self-review and report**

Compare every requirement in
`docs/superpowers/specs/2026-07-30-openrouter-model-pricing-design.md` against
the implementation. Report RED/GREEN evidence, changed files, upstream
assumptions, and any concerns. Do not commit or push; the coordinator owns
submodule and root commits.
