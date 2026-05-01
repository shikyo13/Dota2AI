# Dota2AI Tier 1 Quick Reference

Generated for current script state: 2026-05-01.

## Project Model

Dota2AI is an OpenHyperAI-derived Dota 2 bot script for custom lobbies. Runtime Lua lives under `bots/`, Valve compatibility glue lives under `game/`, and selected TypeScript sources under `typescript/bots/` compile into Lua under `bots/`.

Current branch observed: `codex/oha-7.41a-base`.

## Source Coverage

|Metric|Value|
|-|-|
|Owned files line-read|336|
|Owned lines line-read|212,538|
|Dependency edges discovered|713|
|Mode Lua files|20|
|Hero Lua files by file pattern|128|
|Playable heroes advertised in README|127|
|FunLib Lua files|64|
|FunLib TypeScript files|16|

Data library:

- `docs/data/source-coverage.md`
- `docs/data/module-inventory.md`
- `docs/data/dependency-edges.md`
- `docs/data/runtime-entrypoints.md`
- `docs/data/mode-entrypoints.md`
- `docs/data/hero-library.md`
- `docs/data/funlib-symbols.md`

## Runtime Flow

```text
Dota runtime
  -> game/gameinit.lua
  -> game/botsinit.lua
  -> bots/hero_selection.lua
  -> bot slots
       -> bots/bot_generic.lua
       -> bots/item_purchase_generic.lua
       -> bots/ability_item_usage_generic.lua
       -> bots/mode_*_generic.lua
            -> bots/FunLib/*.lua
            -> bots/BotLib/hero_*.lua
            -> bots/Customize/*.lua
            -> bots/FretBots/*.lua
```

## Core Files

|File|Role|
|-|-|
|`game/gameinit.lua`|Valve compatibility glue for ability, precache, entity, and modifier APIs.|
|`game/botsinit.lua`|Generic module environment wrapper using `setfenv`.|
|`bots/hero_selection.lua`|Hero picks, bans, weak-hero caps, matchup scoring, lane assignment, chat commands.|
|`bots/bot_generic.lua`|Loads hero module and delegates minion thinking.|
|`bots/item_purchase_generic.lua`|Purchase state machine, ARDM rebuilds, support consumables, courier and inventory handling.|
|`bots/ability_item_usage_generic.lua`|Ability leveling, ability use, item use, courier, buyback, glyph, ARDM and position-swap reloads.|
|`bots/mode_assemble_generic.lua`|Human ping assembly response.|
|`bots/mode_roam_generic.lua`|Hero-specific roaming, general travel reactions, lane gank logic, disabled twin gate scaffold.|
|`bots/mode_team_roam_generic.lua`|Team fight help, target selection, dropped-item operations, special unit attacks.|
|`bots/mode_ward_generic.lua`|Observer and sentry placement, dispenser toggle handling, ward safety checks.|
|`bots/FunLib/jmz_func.lua`|Central `J` helper hub.|

## Commands

|Command|Use|
|-|-|
|`npm run build`|Compile TypeScript bot sources to Lua and run post-process. Not needed for docs-only edits unless requested.|
|`npm run build:lua`|Direct Lua build target.|
|`npm run build:node`|Compile Node-side scripts.|
|`npm run dev`|Watch TypeScript to Lua output.|
|`npm run prettier`|Format `bots` and `typescript`.|
|`npm run release`|Update version, build, and format.|

## Current Risks To Keep Visible

- `typescript` is a semver range `^5.5.4` while `typescript-to-lua` is `^1.26.2`. Build compatibility should be checked before source generation work.
- `mode_roshan_generic.lua` still returns some `BOT_ACTION_DESIRE_*` constants from mode desire paths. That is current source state, not a docs typo.
- `mode_ward_generic.lua` treats `item_ward_dispenser` as either observer or sentry by toggle state, but does not attack visible enemy wards in this branch.
- `aba_ward_utility.lua` contains large literal ward-location tables. Validate map data before broad ward behavior changes.
- `bots/FunLib/jmz_func.lua` is a high-blast-radius helper hub. Changes there can affect most hero and mode behavior.

## Deep Links

- Tier 2 architecture: `docs/tier2-architecture.md`
- Tier 2 gameplay systems: `docs/tier2-gameplay-systems.md`
- Tier 3 current script reference: `docs/tier3-current-script-reference.md`
- Existing architecture guide: `docs/ARCHITECTURE.md`
- Patch guide: `docs/PATCH_UPDATE_GUIDE.md`
- Bot API reference: `docs/BOT_API_REFERENCE.md`

