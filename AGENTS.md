# Dota2AI Agent Routing

This is Tier 0 for the Dota2AI bot script. Keep it short and route into the tiered docs.

## Required Start

1. Read `campaign.md` if it exists.
2. Read `docs/_index.md`.
3. Read `docs/tier1-quickref.md`.
4. Use the routing table below for deeper context.

## Tier Router

|Need|Read|
|-|-|
|Fast orientation, commands, risks, and current source shape|`docs/tier1-quickref.md`|
|Runtime architecture and dependency graph|`docs/tier2-architecture.md`|
|Gameplay systems and mode behavior|`docs/tier2-gameplay-systems.md`|
|End-to-end current script reference and flow diagrams|`docs/tier3-current-script-reference.md`|
|Valve bot API reference|`docs/BOT_API_REFERENCE.md`|
|Patch update runbook|`docs/PATCH_UPDATE_GUIDE.md`|
|Generated source inventory and dependency ledgers|`docs/data/_index.md`|

## Current Checkout Note

These docs now live in the isolated worktree branch `codex/oha-improvements-20260501`, based on upstream tag `v0.7.41a-26.4.2`. The source coverage ledger covers 336 tracked repository files and 212,499 lines outside `.git`, `.worktrees`, `node_modules`, and generated `docs/data`.

## Rules

- Documentation-only changes do not require builds unless the user asks.
- Keep markdown table separators minimal, for example `|-|-|`.
- Do not use em dash characters.
- Do not add box-drawing tables.
- For TypeScript-owned Lua output, edit TypeScript first and regenerate Lua only when behavior changes require it.
