# Dota2AI Documentation Index

Generated for current script state: 2026-05-01.

This documentation set is tiered. Start with Tier 1, then load deeper docs only for the question at hand.

## Tiers

|Tier|Document|Purpose|
|-|-|-|
|0|`AGENTS.md`|Agent startup route and repo rules.|
|1|`docs/tier1-quickref.md`|Fast project model, commands, source map, and risks.|
|2|`docs/tier2-architecture.md`|Runtime architecture, dependency graph, data flow, and TypeScript pipeline.|
|2|`docs/tier2-gameplay-systems.md`|Draft, hero logic, modes, items, warding, Roshan, FretBots, and patch-facing behavior.|
|3|`docs/tier3-current-script-reference.md`|End-to-end current-script reference and flow diagrams.|
|3|`docs/ARCHITECTURE.md`|Existing detailed architecture guide for Patch 7.41a.|
|3|`docs/PATCH_UPDATE_GUIDE.md`|Existing patch update runbook.|
|3|`docs/BOT_API_REFERENCE.md`|Existing Valve bot scripting API reference.|
|3L|`docs/data/_index.md`|Generated source ledgers and dependency data.|

## Best Entry By Question

|Question|Best Entry|
|-|-|
|What runs when Dota loads the script?|`docs/tier3-current-script-reference.md#runtime-load-flow`|
|How are heroes picked and lanes assigned?|`docs/tier2-gameplay-systems.md#hero-selection-and-lanes`|
|Where do items, ability use, courier, buyback, and glyph run?|`docs/tier3-current-script-reference.md#per-hero-runtime-loop`|
|How do modes compete?|`docs/tier2-gameplay-systems.md#mode-arbitration`|
|Where are the generated source ledgers?|`docs/data/_index.md`|
|How do I update for a Dota patch?|`docs/PATCH_UPDATE_GUIDE.md`|
|Where is the full bot API reference?|`docs/BOT_API_REFERENCE.md`|

## Coverage Statement

The generated ledger covers 336 repository files and 212,538 lines outside `.git`, `.worktrees`, `node_modules`, and generated `docs/data`. Dependency extraction found 713 literal `require`, `dofile`, and TypeScript `import` edges.

