# Dota2AI Campaign

Updated: 2026-05-01

## Current State

Root checkout: `D:\Dev\Projects\Dota2AI`

Active branch: `main`

Current baseline: upstream OpenHyperAI tag `v0.7.41a-26.4.2`, plus local patch-note research and tiered documentation.

Old local main was archived at `codex/archive-pre-oha-main-20260501`.

Dirty root state from the migration was archived at `codex/archive-dirty-root-before-oha-main-20260501`.

The previous remote main was archived at `codex/archive-origin-main-before-oha-main-20260501`.

## Planned

- Use OpenHyperAI `v0.7.41a-26.4.2` as the new project baseline.
- Keep old local work recoverable on archive branches.
- Merge current patch-note research and tiered documentation into the new clean `main`.
- Use the documentation and patch ledger to guide future bot improvements without rediscovering source layout.

## Read And Checked

- Confirmed OHA baseline commit `cb814c6c8dc51ed08045d6efd9f4a48147992711`.
- Confirmed `bots/FunLib/version.lua` reports `0.7.41 - 2026/04/02`.
- Checked Valve patch datafeeds for `7.39b`, `7.39c`, `7.39d`, `7.39e`, `7.40`, `7.40b`, `7.40c`, `7.41`, `7.41a`, and `7.41b`.
- Checked Valve hero, item, and ability list datafeeds for patch-note ID mapping.
- Read and regenerated tiered source ledgers from tracked repository files outside `.git`, `.worktrees`, `node_modules`, and generated `docs/data`.
- Key runtime source inspected for docs: `game/gameinit.lua`, `game/botsinit.lua`, `bots/bot_generic.lua`, `bots/hero_selection.lua`, `bots/item_purchase_generic.lua`, `bots/ability_item_usage_generic.lua`, core mode files, and major FunLib helpers.

## Built

- `npm run build` passed after the new OHA main was checked out and `.worktrees/` was ignored.
- Build still emits existing TSTL truthiness warnings in `typescript/bots/FunLib/advanced_item_strategy.ts`.

## Written

- Tiered documentation router and references: `AGENTS.md`, `CLAUDE.md`, `docs/_index.md`, `docs/tier1-quickref.md`, `docs/tier2-architecture.md`, `docs/tier2-gameplay-systems.md`, `docs/tier3-current-script-reference.md`.
- Generated source ledgers: `docs/data/*`.
- Patch research: `docs/research/patch-notes/*`.
- Historical OHA and script audit research: `docs/research/openhyperai-release-and-patch-gap-2026-05-01.md`, `docs/research/dota-bot-scripting-source-audit-2026-05-01.md`.

## Decisions

- Root `main` is now the clean OHA-based baseline.
- Future active work should use ignored project-local worktrees under `D:\Dev\Projects\Dota2AI\.worktrees\`.
- Do not use the root checkout for feature work unless explicitly requested.
- Do not copy full official patch-note text into the repo. Keep bot-impact summaries, source links, and checklists.
- Treat `7.41b` as the direct live patch gap after OHA `7.41a`.
- Keep the wider `7.39` to `7.41b` patch ledger for stale-code audit context.

## Verification

- Patch-note docs passed em dash, padded table separator, non-ASCII, trailing whitespace, source link, and `git diff --check` scans before merge.
- Tiered docs passed source-count, stale-count, missing-link, em dash, table separator, and `git diff --check` scans before merge in the docs branch.
- The staged clean-main documentation merge passed `git diff --check --cached`, conflict-marker scan, em dash scan, markdown table separator scan, and box-drawing character scan.

## Remaining

- Start future bot improvements from a new `.worktrees/<task>` branch based on clean `main`.
