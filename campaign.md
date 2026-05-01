# Dota2AI Tiered Docs Campaign

Date: 2026-05-01

Checkout observed during this pass: `codex/oha-7.41a-base`

## Planned

- Read current checkout state, existing docs, manifests, and key runtime files.
- Line-read the owned source set and build generated source ledgers.
- Create a complete tiered documentation set under `docs/`.
- Include flow diagrams, dependency graph, module inventory, mode map, hero library, and gameplay system map.
- Verify documentation-only formatting and path consistency without running builds.

## Read And Checked

- Git context reported root `D:/Dev/Projects/Dota2AI`, branch `codex/oha-7.41a-base`, clean tracked state before docs, with untracked `.worktrees/`.
- Existing docs read: `CLAUDE.md`, `README.md`, `docs/ARCHITECTURE.md`, `docs/PATCH_UPDATE_GUIDE.md`.
- Manifests read: `package.json`, `tsconfig-tstl.json`.
- Runtime source inspected directly: `game/gameinit.lua`, `game/botsinit.lua`, `bots/bot_generic.lua`, `bots/hero_selection.lua`, `bots/item_purchase_generic.lua`, `bots/ability_item_usage_generic.lua`, `bots/mode_assemble_generic.lua`, `bots/mode_roam_generic.lua`, `bots/mode_team_roam_generic.lua`, `bots/mode_ward_generic.lua`, `bots/mode_roshan_generic.lua`, `bots/FunLib/jmz_func.lua`, `bots/FunLib/aba_item.lua`, `bots/FunLib/aba_skill.lua`, `bots/FunLib/aba_ward_utility.lua`.
- Generated line-read source ledger covers all repository files outside `.git`, `.worktrees`, `node_modules`, and generated `docs/data`.

## Built

- No build was run for the final documentation pass. The user clarified that documentation-only work does not require builds.

## Tested

- Generated source data library for 336 files, 212,538 lines, and 713 literal dependency edges.
- Planned verification: banned character scan, markdown table separator scan, doc file inventory, and git status.

## Decisions

- `node_modules` is treated as third-party dependency payload and mapped from manifests, not as project source to document line by line.
- The advertised playable hero count is 127, while the repository has 128 `hero_*.lua` files because controlled-unit and support files are included in the file pattern.
- Existing uppercase docs remain available as legacy deep references. New tiered docs route to them instead of duplicating every API detail.

## Issues

- During the previous interrupted pass, the root checkout moved from `main` to `codex/oha-7.41a-base`. The reflog showed a backup commit named `Backup local WIP before OHA rebase` on `codex/pre-oha-local-backup-20260501`, then checkout to `codex/oha-7.41a-base`.
- Work continued against the current Git-reported checkout rather than switching branches.

## Remaining

- Finish authored docs.
- Run doc-only verification.
- Report final file set and any residual risks.

