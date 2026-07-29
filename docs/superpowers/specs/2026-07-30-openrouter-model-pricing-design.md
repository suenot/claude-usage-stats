# OpenRouter Model Pricing Design

## Goal

Add a separate "Models" page that lists the complete live OpenRouter model
catalog and shows text input, cache read, cache write, and output prices in
USD per one million tokens.

## Data source

- Backend fetches `https://openrouter.ai/api/v1/models?limit=1000`.
- The endpoint is currently public and returns prices as USD-per-token strings.
- OpenRouter remains the only pricing source for this page. Project pricing
  constants are not mixed into the response.
- Backend converts prices to USD per one million tokens.
- Missing cache prices stay `null` and render as `—`; zero remains `$0`.
- Successful responses are cached in memory for five minutes. If refresh fails
  after a successful fetch, the last snapshot is returned as stale. With no
  snapshot, the API returns a clear 502 response.

## API

`GET /api/models/pricing`

```ts
interface ModelPrice {
  id: string;
  name: string;
  provider: string;
  contextLength: number | null;
  inputPerMillion: number | null;
  outputPerMillion: number | null;
  cacheReadPerMillion: number | null;
  cacheWritePerMillion: number | null;
}

interface ModelPricingResponse {
  source: "OpenRouter";
  fetchedAt: string;
  stale: boolean;
  models: ModelPrice[];
}
```

The API must not require local Claude/Codex collection to finish.

## Page behavior

- Add `Models` to the primary navigation after `Projects`.
- The page is available independently of the local usage summary.
- Page heading: `Model pricing`.
- Supporting copy: `Live OpenRouter prices · USD per 1M tokens`.
- One search field filters by display name, model ID, or provider.
- Table columns: Model, Context, Input, Cache read, Cache write, Output.
- Clicking a numeric column header sorts ascending/descending. Default ordering
  is provider then model name.
- A local `Refresh prices` action bypasses the browser cache and requests the
  latest backend snapshot.
- Loading, empty, stale, and error states are explicit and actionable.
- The page is keyboard accessible, horizontally scrollable on narrow screens,
  and keeps the table header visible while scrolling.

## Visual direction

The page extends the existing dark dashboard rather than introducing a new
theme.

- Canvas: `#0f172a`
- Table surface: `#1e293b`
- Primary text: `#f8fafc`
- Secondary text: `#94a3b8`
- Source/input accent: `#22d3ee`
- Cache accent: `#34d399`

Inter remains the interface face. JetBrains Mono is used for model IDs,
context sizes, and prices. The signature element is a restrained cache-price
rail: Cache read and Cache write share a subtle green tint so the discount
relationship is visible without adding cards or decoration.

## Failure and freshness

- `stale: true` is shown as `Cached snapshot` with the original fetch time.
- A first-load upstream failure shows `OpenRouter pricing is unavailable` and
  a `Try again` action.
- Search with no matches shows `No models match this search`.
- The global usage `Refresh` action is hidden on the Models page; price refresh
  belongs to the page.

## Verification

- TDD covers price conversion, missing cache fields, zero prices, sorting,
  five-minute cache reuse, forced refresh, and stale fallback.
- Backend tests and the full workspace build pass.
- Browser verification covers navigation, live OpenRouter data, search,
  sorting, refresh, narrow viewport overflow, and console/network errors.

