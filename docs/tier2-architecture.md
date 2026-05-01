# Dota2AI Tier 2 Architecture

Generated for current script state: 2026-05-01.

## Purpose

This doc explains how the current 7.41a checkout is wired together. It is source-backed by `docs/data/` and by direct review of runtime entrypoints.

## Architecture Layers

|Layer|Files|Responsibility|
|-|-|-|
|Game glue|`game/gameinit.lua`, `game/botsinit.lua`, `game/dkjson.lua`|Compatibility wrappers and generic module environment setup.|
|Runtime entrypoints|`bots/hero_selection.lua`, `bots/bot_generic.lua`, `bots/item_purchase_generic.lua`, `bots/ability_item_usage_generic.lua`|Dota callback surface for draft, minions, shopping, skills, items, courier, buyback, and glyph.|
|Mode entrypoints|`bots/mode_*_generic.lua`|Desire-scored behavior modes for laning, farm, push, defend, retreat, roam, team roam, warding, Roshan, shops, runes, outposts, and assemble pings.|
|Hero modules|`bots/BotLib/hero_*.lua`|Per-hero builds, ability lists, talents, item lists, skill logic, and optional minion logic.|
|FunLib|`bots/FunLib/*.lua` and generated Lua|Shared helper systems for roles, sites, items, skills, push, defend, warding, localization, cache, and utilities.|
|FretBots|`bots/FretBots.lua`, `bots/FretBots/*`|Enhanced difficulty, timers, neutral items, hero sounds, matchups, role detection, and event hooks.|
|Buff mode|`bots/Buff/*`|Difficulty bonuses and neutral item distribution support.|
|Customization|`bots/Customize/*`, `game/Customize/*`|User customization, picks, bans, language, difficulty, and per-hero overrides.|
|TypeScript|`typescript/bots/**`, `typescript/post-process/**`|Sources for selected generated Lua and scripts for version, matchup, and neutral data generation.|

## Runtime Load Flow

```text
game/gameinit.lua
  -> requires game/dkjson
  -> wraps engine APIs for compatibility

game/botsinit.lua
  -> exposes BotsInit.CreateGeneric()
  -> forwards unknown names through the global environment

bots/hero_selection.lua
  -> loads global overrides, roles, matchups, captain mode, localization, customization
  -> selects heroes
  -> assigns lanes
  -> handles pick, ban, position, and speech chat commands

For each bot hero:
  -> bots/bot_generic.lua
       -> dofile BotLib hero file
       -> MinionThink throttle
  -> bots/item_purchase_generic.lua
       -> require BotLib hero file
       -> item purchase state machine
  -> bots/ability_item_usage_generic.lua
       -> dofile BotLib hero file
       -> ability, item, courier, buyback, glyph callbacks
  -> bots/mode_*_generic.lua
       -> GetDesire
       -> active Think
```

## Dependency Graph

```text
Dota runtime
  -> game glue
  -> runtime entrypoints
       -> BotLib hero modules
       -> FunLib helper modules
       -> Customize config
       -> FretBots data and systems

BotLib hero modules
  -> jmz_func central helper table
  -> aba_minion for controlled units
  -> optional hero utilities
       -> morphling_utility
       -> rubick_utility and rubick_hero/*
       -> techies_utility

Mode modules
  -> jmz_func
  -> focused helpers
       -> aba_push
       -> aba_defend
       -> aba_ward_utility
       -> aba_item
       -> aba_role
       -> aba_special_units
       -> enemy_role_estimation

TypeScript source
  -> typescript-to-lua
  -> bots generated Lua
  -> post-process require path rewrites
```

Full generated edge list: `docs/data/dependency-edges.md`.

## Central Helper Hub

`bots/FunLib/jmz_func.lua` exposes the `J` table used by most high-level behavior.

It attaches:

- `J.Site`
- `J.Item`
- `J.Buff`
- `J.Role`
- `J.Skill`
- `J.Chat`
- `J.Utils`
- `J.Customize`

It also implements large sets of world queries, target filters, damage forecasts, movement helpers, item helpers, mode-state helpers, Roshan and Tormentor helpers, ping handling, and safety gates.

## TypeScript Pipeline

|File|Role|
|-|-|
|`tsconfig-tstl.json`|TSTL config, Lua 5.1 target, root `typescript`, outDir repo root.|
|`typescript/post-process/post-process-lua.js`|Rewrites generated require paths into Dota-friendly `GetScriptDirectory()` paths.|
|`typescript/post-process/update-version.js`|Version update helper.|
|`typescript/post-process/neutrals.js`|Neutral item generation helper.|
|`typescript/post-process/matchups.js`|Matchup data generation helper.|

Generated Lua exists in `bots/FunLib`, `bots/BotLib/hero_wisp.lua`, and `bots/ts_libs`. Edit TypeScript first when a Lua file is generated.

## Data Flow

```text
Draft data
  -> Customize, role maps, matchup tables
  -> hero_selection.lua
  -> selected heroes and lane assignment

Hero build data
  -> BotLib hero file
  -> item_purchase_generic.lua
  -> ability_item_usage_generic.lua

World query data
  -> Dota bot API
  -> jmz_func and focused FunLib helpers
  -> modes and hero skills

Mode desire data
  -> mode GetDesire functions
  -> engine mode arbitration
  -> active mode Think

Action data
  -> Action_MoveToLocation, Action_AttackUnit, Action_UseAbility, purchase APIs, courier APIs
  -> Dota runtime
```

## High Blast Radius Files

|File|Reason|
|-|-|
|`bots/FunLib/jmz_func.lua`|Central helper hub used by most modes and heroes.|
|`bots/ability_item_usage_generic.lua`|All heroes share ability, item, courier, buyback, glyph, ARDM, and position-swap logic.|
|`bots/item_purchase_generic.lua`|All hero item builds flow through this purchase state machine.|
|`bots/hero_selection.lua`|Draft and lane assignment affect all match setup.|
|`bots/FunLib/aba_item.lua`|Item names, recipes, ward item recognition, sell rules, and inventory helpers.|
|`bots/FunLib/aba_skill.lua`|Ability and talent list construction. Patch changes can break every hero build.|

