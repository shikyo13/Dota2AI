# Patch Notes Research Campaign

Updated: 2026-05-01

## Goal

Research and document Dota 2 patch-note impact for adapting OpenHyperAI into this project without conflicting with the parallel tiered-docs agent.

## Isolation

Work is isolated in `D:\Dev\Projects\Dota2AI-worktrees\patch-notes-20260501` on branch `codex/oha-patch-notes-research-20260501`.

The root checkout `D:\Dev\Projects\Dota2AI` was not edited.

The sibling docs worktree `D:\Dev\Projects\Dota2AI-worktrees\oha-improvements-20260501` was not edited.

## Read And Checked

- Confirmed this branch starts at OHA tag `v0.7.41a-26.4.2`.
- Confirmed `bots/FunLib/version.lua` reports `0.7.41 - 2026/04/02`.
- Checked Valve patch list datafeed on 2026-05-01.
- Checked Valve patch datafeeds for `7.39b`, `7.39c`, `7.39d`, `7.39e`, `7.40`, `7.40b`, `7.40c`, `7.41`, `7.41a`, and `7.41b`.
- Checked Valve hero, item, and ability list datafeeds to map IDs to names where available.
- Checked OpenHyperAI release page for tag, release name, and commit.

## Built

No build was run. This is a documentation-only research branch.

## Written

- `docs/research/patch-notes/_index.md`
- `docs/research/patch-notes/oha-current-gap-7.41a-to-7.41b-2026-05-01.md`
- `docs/research/patch-notes/migration-ledger-7.39-to-7.41b-2026-05-01.md`

## Decisions

- Do not copy full official patch notes into the repo. Use source links, structured counts, summaries, and bot-impact checklists.
- Keep this work out of the active tiered-doc files to avoid conflicting with the other agent.
- Treat `7.41b` as the only direct patch gap after the upstream OHA 7.41a release.
- Keep the wider `7.39` to `7.41b` ledger for historical migration context and stale-local-code audits.

## Verification

- Em dash scan passed for changed docs.
- Padded markdown table separator scan passed for changed docs.
- Non-ASCII scan passed for changed docs.
- Trailing whitespace scan passed for changed docs.
- Source-link sanity check returned HTTP 200 for Valve datafeeds and the OpenHyperAI release page.
- Git status shows only the new `campaign.md` and `docs/research/` files.

## Remaining

- Decide whether to merge this branch into the main OHA improvement worktree after the other agent finishes doc audit.
- Use the 7.41b checklist during implementation of support stacking, warding, dewarding, objective, and item fixes.
