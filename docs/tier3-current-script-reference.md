# Dota2AI Tier 3 Current Script Reference

Generated for current script state: 2026-05-01.

## Section Index

- [Coverage](#coverage)
- [Runtime Load Flow](#runtime-load-flow)
- [Draft Flow](#draft-flow)
- [Per-Hero Runtime Loop](#per-hero-runtime-loop)
- [Mode Desire Flow](#mode-desire-flow)
- [Dependency Graph](#dependency-graph)
- [Module Responsibilities](#module-responsibilities)
- [Current Branch Observations](#current-branch-observations)
- [Generated Data Library](#generated-data-library)
- [Operational Notes](#operational-notes)

## Coverage

The source ledger covers all repository files outside `.git`, `.worktrees`, `node_modules`, and generated `docs/data`.

|Coverage Item|Value|
|-|-|
|Files|336|
|Lines|212,538|
|Dependency edges|713|
|Mode Lua files|20|
|Hero Lua files by file pattern|128|
|FunLib Lua files|64|
|FunLib TypeScript files|16|
|FretBots files|39|

## Runtime Load Flow

```text
Dota starts addon Lua environment
  -> game/gameinit.lua
       -> loads dkjson
       -> wraps engine compatibility APIs
       -> patches ability, entity, hero resource, and modifier helper behavior

  -> game/botsinit.lua
       -> creates generic module environment
       -> forwards unknown globals to the caller environment

  -> hero selection phase
       -> bots/hero_selection.lua
       -> role pools, matchup scoring, bans, picks, lane assignment, chat commands

  -> per bot slot
       -> bots/bot_generic.lua
       -> bots/item_purchase_generic.lua
       -> bots/ability_item_usage_generic.lua
       -> bots/mode_*_generic.lua
```

## Draft Flow

```text
Customize and language settings
  -> FunLib/custom_loader

Role and hero data
  -> aba_hero_pos_weights
  -> aba_role
  -> aba_team_names
  -> FretBots/HeroNames
  -> FretBots/matchups_data
  -> optional aba_matchups

hero_selection.lua
  -> construct supported hero list
  -> construct position pools
  -> apply weak-hero cap and penalty
  -> apply bans and repeat policy
  -> score matchup fit
  -> select heroes
  -> assign lanes
  -> expose GetBotNames and UpdateLaneAssignments
```

## Per-Hero Runtime Loop

```text
BotLib hero file
  -> sBuyList
  -> sSellList
  -> sSkillList
  -> SkillsComplement
  -> optional MinionThink

bot_generic.lua
  -> MinionThink every 0.3 seconds for valid minions

item_purchase_generic.lua
  -> detect ARDM hero swaps
  -> rebuild item state when needed
  -> buy components
  -> buy support consumables
  -> move wards between backpack and main slots
  -> handle courier and secret shop purchases

ability_item_usage_generic.lua
  -> detect ARDM hero swaps
  -> detect position swaps
  -> reload BotLib
  -> level abilities
  -> dispatch SkillsComplement
  -> run generic item usage
  -> run courier, buyback, and glyph
```

## Mode Desire Flow

```text
Every loaded mode:
  -> GetDesire
  -> optional local state update
  -> returns numeric desire

Dota mode arbitration:
  -> highest desire wins
  -> active mode Think runs
  -> OnStart and OnEnd run if provided
```

The generated mode ledger is `docs/data/mode-entrypoints.md`.

## Dependency Graph

```text
Runtime entrypoints
  -> hero_selection.lua
       -> global overrides
       -> role and team-name helpers
       -> matchups and hero names
       -> captain mode
       -> localization
       -> custom loader

  -> item_purchase_generic.lua
       -> BotLib hero module
       -> aba_item
       -> aba_role
       -> jmz_func
       -> utils

  -> ability_item_usage_generic.lua
       -> BotLib hero module
       -> jmz_func
       -> utils
       -> localization
       -> Customize/general

  -> modes
       -> jmz_func
       -> focused helpers

jmz_func.lua
  -> aba_site
  -> aba_item
  -> aba_buff
  -> aba_role
  -> aba_skill
  -> aba_chat
  -> utils
  -> custom_loader
```

## Module Responsibilities

|Module|Responsibility|
|-|-|
|`bots/FunLib/jmz_func.lua`|Central helper table, world queries, target filters, damage forecasts, mode checks, item helpers, objective helpers.|
|`bots/FunLib/aba_skill.lua`|Ability and talent list extraction and skill build resolution.|
|`bots/FunLib/aba_item.lua`|Item lists, recipes, classifications, sell rules, ward item recognition, inventory helpers.|
|`bots/FunLib/aba_site.lua`|Map location, lane front, camp, rune, Roshan, Tormentor, and objective helper data.|
|`bots/FunLib/aba_push.lua`|Lane push desire and push behavior.|
|`bots/FunLib/aba_defend.lua`|Lane and tower defense desire and behavior.|
|`bots/FunLib/aba_ward_utility.lua`|Ward location tables, observer spot selection, sentry spot selection, ward proximity checks.|
|`bots/FunLib/aba_role.lua`|Position and role detection.|
|`bots/FunLib/aba_special_units.lua`|Special unit desires and actions.|
|`bots/FunLib/global_cache.lua`|Generated cache helpers used by generated FunLib modules.|
|`bots/FunLib/localization.lua`|Localized bot messages.|

## Current Branch Observations

- The README advertises 127 supported heroes, while the source ledger finds 128 hero Lua files by `hero_*.lua` pattern.
- `mode_assemble_generic.lua` is present and responds to recent human normal pings within range.
- `mode_roam_generic.lua` has gank timing reductions, disabled twin gate scaffold, and many hero-specific movement reactions.
- `mode_ward_generic.lua` places observer and sentry wards and handles ward dispenser toggles, but does not currently execute enemy-ward attacks.
- `mode_roshan_generic.lua` mixes mode desire and action desire constants in its return paths. That is current source behavior.
- ARDM support is significant in both item purchase and ability usage.
- Position-swap support is significant in ability usage and item purchase rebuilds.
- TypeScript source generation exists, but many Lua files are still manual source.

## Generated Data Library

|File|Use|
|-|-|
|`docs/data/source-coverage.md`|Coverage totals and largest files.|
|`docs/data/module-inventory.md`|Full non-third-party file inventory.|
|`docs/data/dependency-edges.md`|Literal module references.|
|`docs/data/runtime-entrypoints.md`|Runtime callbacks and dependencies.|
|`docs/data/mode-entrypoints.md`|Mode callbacks and function samples.|
|`docs/data/hero-library.md`|Hero file inventory.|
|`docs/data/funlib-symbols.md`|FunLib function samples and dependencies.|

## Operational Notes

- Read `campaign.md` before resuming this work.
- Do not run builds for docs-only edits unless requested.
- Use `docs/PATCH_UPDATE_GUIDE.md` for patch update work.
- Use `docs/BOT_API_REFERENCE.md` for Dota bot API questions.
- Use TypeScript source for generated Lua changes.
- Treat broad changes in `jmz_func.lua`, `ability_item_usage_generic.lua`, and `item_purchase_generic.lua` as high risk.

