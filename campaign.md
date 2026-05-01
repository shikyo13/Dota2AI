# Dota2AI Tiered Docs Campaign

Date: 2026-05-01

Active documentation worktree: `D:\Dev\Projects\Dota2AI-worktrees\oha-improvements-20260501`

Active documentation branch: `codex/oha-improvements-20260501`

Source baseline: upstream tag `v0.7.41a-26.4.2`

## Planned

- Read current checkout state, existing docs, manifests, and key runtime files.
- Line-read the owned source set and build generated source ledgers.
- Create a complete tiered documentation set under `docs/`.
- Include flow diagrams, dependency graph, module inventory, mode map, hero library, and gameplay system map.
- Verify documentation-only formatting and path consistency without running builds.

## Read And Checked

- Initial Git context reported root `D:/Dev/Projects/Dota2AI`, branch `codex/oha-7.41a-base`, clean tracked state before docs, with untracked `.worktrees/`.
- The docs were later copied into the isolated worktree `D:/Dev/Projects/Dota2AI-worktrees/oha-improvements-20260501` on branch `codex/oha-improvements-20260501`.
- Existing docs read: `CLAUDE.md`, `README.md`, `docs/ARCHITECTURE.md`, `docs/PATCH_UPDATE_GUIDE.md`.
- Manifests read: `package.json`, `tsconfig-tstl.json`.
- Runtime source inspected directly: `game/gameinit.lua`, `game/botsinit.lua`, `bots/bot_generic.lua`, `bots/hero_selection.lua`, `bots/item_purchase_generic.lua`, `bots/ability_item_usage_generic.lua`, `bots/mode_assemble_generic.lua`, `bots/mode_roam_generic.lua`, `bots/mode_team_roam_generic.lua`, `bots/mode_ward_generic.lua`, `bots/mode_roshan_generic.lua`, `bots/FunLib/jmz_func.lua`, `bots/FunLib/aba_item.lua`, `bots/FunLib/aba_skill.lua`, `bots/FunLib/aba_ward_utility.lua`.
- Generated line-read source ledger covers tracked repository files outside `.git`, `.worktrees`, `node_modules`, and generated `docs/data`.

## Built

- No build was run for the final documentation pass. The user clarified that documentation-only work does not require builds.

## Tested

- Regenerated the source data library inside the isolated worktree from tracked source: 336 files, 212,499 lines, and 713 literal dependency edges.
- Audited documentation freshness after worktree recovery: corrected branch/base metadata, marked historical docs that are no longer current truth, fixed generated source counts, and normalized markdown separators.
- Independent source recount matched `docs/data/source-coverage.md`: 336 tracked files, 212,499 lines, 7,561,529 bytes.
- Stale current-count scan found no remaining old line totals, old 337-file count, or current-branch text pointing at the old root branch.
- Markdown checks passed: no em dash characters, no non-minimal table separator rows, no missing local links, and `git diff --check` passed.

## Decisions

- `node_modules` is treated as third-party dependency payload and mapped from manifests, not as project source to document line by line.
- The advertised playable hero count is 127, while the repository has 128 `hero_*.lua` files because controlled-unit and support files are included in the file pattern.
- Existing uppercase docs remain available as legacy deep references. New tiered docs route to them instead of duplicating every API detail.

## Issues

- During the previous interrupted pass, the root checkout moved from `main` to `codex/oha-7.41a-base`. The reflog showed a backup commit named `Backup local WIP before OHA rebase` on `codex/pre-oha-local-backup-20260501`, then checkout to `codex/oha-7.41a-base`.
- Work continued against the current Git-reported checkout rather than switching branches.
- The docs were recovered from the root checkout into the isolated `codex/oha-improvements-20260501` worktree. Root cleanup is intentionally left for a separate explicit cleanup step.
- `CLAUDE.md` had an extra blank line at EOF after recovery. Fixed it and reconciled `docs/data/source-coverage.md` plus `docs/data/module-inventory.md`.
- Upstream README docs used padded table separators and em dash characters. Normalized them in the isolated worktree so project markdown rules hold across docs.

## Remaining

- Keep future Dota2AI changes in the isolated worktree, not the root checkout.
- Root checkout still has stranded docs and unrelated package or gitignore changes until separately cleaned.
- No documentation freshness blockers remain from this audit.
