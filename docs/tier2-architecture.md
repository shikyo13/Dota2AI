# Architecture Reference

Full architecture reference for the Dota 2 bot AI codebase (upstream-only, clean clone of forest0xia/dota2bot-OpenHyperAI).

## 1. Bot Execution Flow

Five-step lifecycle, all driven by Dota 2's bot scripting engine:

1. **Hero Selection** -- `bots/hero_selection.lua` loads at game start. Matchup-aware drafter with role/position weighting, ban lists, and weak-hero caps. Uses `aba_matchups.lua` data and `aba_hero_pos_weights.lua` for drafting intelligence.
2. **Bot Init** -- `bots/bot_generic.lua` runs per hero. Gets hero name via `bot:GetUnitName()`, loads hero config via `dofile(GetScriptDirectory() .. "/BotLib/" .. hero_name)`, delegates `MinionThink` to hero config. Guards against nil/illusion/invulnerable bots.
3. **Item Purchase** -- `bots/item_purchase_generic.lua` reads `sBuyList`/`sSellList` from hero config. Handles courier management, secret shop trips, shard/aghs timing, ward buying for supports.
4. **Ability Usage** -- `bots/ability_item_usage_generic.lua` (~7800 lines). Generic ability/item casting framework. Iterates hero abilities, calls `Consider_*()` functions from hero config, handles item actives (BKB, blink, manta, etc.).
5. **Mode Scripts** -- 19 `bots/mode_*_generic.lua` files. Engine calls `GetDesire()` per mode every frame, runs highest-desire mode's `Think()`. Modes: attack, farm, laning, retreat, roam, team_roam, roshan, ward, secret_shop, side_shop, outpost, rune, assemble_with_humans, push_tower_{top,mid,bot}, defend_tower_{top,mid,bot}.

## 2. The J Table (jmz_func.lua)

Central hub (~6500 lines) -- aggregates all modules into a single `J` table. Load order matters because later modules depend on earlier ones.

| Sub-table    | Source            | Purpose                                              |
|--------------|-------------------|------------------------------------------------------|
| `J.Site`     | `aba_site.lua`    | Map locations, ward spots, rune locations, camps     |
| `J.Item`     | `aba_item.lua`    | Item purchase AI, item usage (BKB, blink, manta...) |
| `J.Buff`     | `aba_buff.lua`    | Buff/debuff detection and response tables            |
| `J.Role`     | `aba_role.lua`    | Role assignment (pos 1-5), lane assignment           |
| `J.Skill`    | `aba_skill.lua`   | Ability leveling and skill build management          |
| `J.Chat`     | `aba_chat.lua`    | Chat/taunt system with localization                  |
| `J.Utils`    | `utils.lua`       | Distance, validation, team queries, HTTP for LLM    |
| `J.Customize`| `custom_loader.lua`| User settings (loads `game/Customize/` then falls back to `bots/Customize/`) |

**Circular dependency rule:** New modules must NOT `require('jmz_func')` at file scope. Use lazy-load pattern (`pcall(require)`) or import specific sub-modules directly (e.g., `require('FunLib/utils')`).

## 3. Full Require Graph

Every FunLib module and its direct dependencies:

| Module                 | Requires                                                              |
|------------------------|-----------------------------------------------------------------------|
| `aba_buff`             | (none -- TS-compiled, pure data tables)                               |
| `aba_chat`             | `localization`, `custom_loader`, `aba_chat_table`                     |
| `aba_chat_table`       | (none)                                                                |
| `aba_defend`           | `jmz_func`, `ts_libs/dota/index`, `ts_libs/utils/native-operators`, `utils`, `Customize/general` |
| `aba_global_overrides` | `utils`                                                               |
| `aba_hero_pos_weights` | `ts_libs/dota/heroes`                                                 |
| `aba_hero_roles_map`   | `ts_libs/dota/heroes`                                                 |
| `aba_hero_skill`       | `jmz_func`                                                           |
| `aba_hero_sub_units`   | `jmz_func`                                                           |
| `aba_item`             | `aba_global_overrides`, `aba_role`                                    |
| `aba_matchups`         | (none -- pure data table)                                             |
| `aba_minion`           | `minion_lib/utils`, `Customize/general`                               |
| `aba_push`             | `jmz_func`, `ts_libs/dota/index`, `Customize/general`                |
| `aba_role`             | `ts_libs/dota/index`, `utils`, `aba_hero_roles_map`, `enemy_role_estimation` |
| `aba_site`             | `ts_libs/dota/index`, `utils`                                        |
| `aba_skill`            | `utils`                                                               |
| `aba_special_units`    | `jmz_func`                                                           |
| `aba_team_names`       | `utils`                                                               |
| `aba_ward_utility`     | `jmz_func`                                                           |
| `captain_mode`         | `ts_libs/dota/index`, `aba_role`                                     |
| `custom_loader`        | (none -- uses `pcall(require)` for optional loads)                    |
| `enemy_role_estimation`| `ts_libs/dota/index`, `utils`                                        |
| `item_strategy_simple` | (none -- pure data)                                                   |
| `localization`         | (none)                                                                |
| `morphling_utility`    | `jmz_func`                                                           |
| `rubick_utility`       | `jmz_func`, `rubick_hero/*` (21 hero-specific modules)               |
| `spell_list`           | (none)                                                                |
| `spell_prob_list`      | (none -- TS-compiled)                                                 |
| `techies_utility`      | `jmz_func`                                                           |
| `utils`                | `ts_libs/dota/index`, `ts_libs/utils/http_req`, `ts_libs/utils/native-operators`, `ts_libs/dota/heroes`, `ts_libs/utils/json` |
| `version`              | (none)                                                                |

## 4. Hero Config Pattern (BotLib/hero_*.lua)

127 files, one per hero. Each imports `J` from `jmz_func` and exports:

- **`sBuyList`** -- Item purchase order per role (`pos_1` through `pos_5`)
- **`sSellList`** -- Items to sell when upgrading
- **`sSkillList`** -- Ability/talent leveling order
- **`bDeafaultAbility` / `bDeafaultItem`** -- Whether to use generic behavior (note: typo is upstream)
- **`MinionThink(hMinionUnit)`** -- Summoned unit AI (familiars, golems, eidolons, etc.)
- **`GetDesire_*()`** -- Hero-specific mode desire overrides
- **`Consider_*()`** -- Hero-specific ability casting logic

Talent trees use `{left_value, right_value}` format: `0` = pick left, `10` = pick right.

## 5. TypeScript to Lua Pipeline

- **Source:** `typescript/bots/` (25 `.ts` source files + 3 `.d.ts` declarations)
- **Build:** `npm run build:lua` (TSTL compiler + post-process require paths)
- **Output:** Compiled Lua placed into `bots/` alongside hand-written Lua

**TS-compiled modules:** `utils`, `aba_buff`, `aba_role`, `aba_defend`, `aba_push`, `aba_site`, `aba_matchups`, `enemy_role_estimation`, `captain_mode`, `aba_hero_pos_weights`, `aba_hero_roles_map`, `spell_prob_list`, `version`

**TS support libraries:** `ts_libs/dota/index` (enums, interfaces, heroes), `ts_libs/utils/http_req`, `ts_libs/utils/native-operators`, `ts_libs/utils/json`

**Hand-written Lua:** `jmz_func`, `aba_item`, `aba_skill`, `aba_chat`, `aba_chat_table`, `aba_global_overrides`, `aba_minion`, `aba_special_units`, `aba_hero_skill`, `aba_hero_sub_units`, `aba_ward_utility`, `aba_team_names`, `custom_loader`, `localization`, `spell_list`, `morphling_utility`, `rubick_utility`, `techies_utility`, `item_strategy_simple`, all `BotLib/hero_*`, all `mode_*_generic`, `hero_selection`, `bot_generic`, `item_purchase_generic`, `ability_item_usage_generic`

## 6. FretBots Difficulty System

Located in `bots/FretBots/`. Enhanced difficulty system layered on top of base bot AI:

- Difficulty 0-10 with configurable bonuses
- Neutral items given at specified timings (ahead of normal drop schedule)
- Gold/XP bonuses scale with difficulty level and hero role
- Voting system for difficulty selection in lobby

## 7. File Layout

```
bots/
  bot_generic.lua                -- Entry point per hero
  hero_selection.lua             -- Draft/pick logic
  item_purchase_generic.lua      -- Item buying
  ability_item_usage_generic.lua -- Ability/item casting (~7800 lines)
  mode_*_generic.lua             -- Mode scripts (19 files)
  BotLib/hero_*.lua              -- Per-hero configs (127 files)
  FunLib/                        -- Core AI library
    jmz_func.lua                 -- Central hub (J table, ~6500 lines)
    aba_item.lua                 -- Item AI
    aba_role.lua                 -- Role assignment (TS-compiled)
    aba_skill.lua                -- Ability leveling
    aba_buff.lua                 -- Buff detection (TS-compiled)
    aba_site.lua                 -- Map awareness (TS-compiled)
    aba_defend.lua               -- Tower defense (TS-compiled)
    aba_push.lua                 -- Push/siege (TS-compiled)
    aba_chat.lua                 -- Chat/taunt system
    aba_global_overrides.lua     -- Print override, globals
    aba_hero_pos_weights.lua     -- Hero position weights (TS-compiled)
    aba_hero_roles_map.lua       -- Hero role mappings (TS-compiled)
    aba_hero_skill.lua           -- Hero-specific skill data
    aba_hero_sub_units.lua       -- Sub-unit (summon) definitions
    aba_matchups.lua             -- Hero matchup data (TS-compiled)
    aba_minion.lua               -- Minion/summon AI
    aba_special_units.lua        -- Special unit handling
    aba_ward_utility.lua         -- Ward placement AI
    aba_team_names.lua           -- Team name generation
    captain_mode.lua             -- Captain's mode logic (TS-compiled)
    custom_loader.lua            -- Customize loader
    enemy_role_estimation.lua    -- Enemy role detection (TS-compiled)
    item_strategy_simple.lua     -- Simple item strategy data
    localization.lua             -- Language strings
    morphling_utility.lua        -- Morphling-specific logic
    rubick_utility.lua           -- Rubick spell-steal logic
    techies_utility.lua          -- Techies mine AI
    spell_list.lua               -- Spell name registry
    spell_prob_list.lua          -- Spell probability data (TS-compiled)
    utils.lua                    -- General utilities (TS-compiled)
    version.lua                  -- Version info (TS-compiled)
    minion_lib/                  -- Minion utility sub-library
    override_generic/            -- Generic override helpers
    rubick_hero/                 -- 21 hero-specific rubick modules
  Customize/                     -- User settings (picks, bans, difficulty)
  FretBots/                      -- Enhanced difficulty system
  Buff/                          -- Buff handling per hero
  ts_libs/                       -- TS-compiled support libraries
typescript/bots/                 -- TypeScript sources (compile to Lua)
game/                            -- Game-level overrides
  Customize/                     -- Persistent user overrides (takes priority)
docs/                            -- Project documentation
```

## 8. Known Weak Heroes

**Weak AI:** Chen, KotL, Winter Wyvern, Ancient Apparition, Phoenix, Tinker, Pangolier, Tusk, Morphling, Visage, Void Spirit, Pudge, Ember Spirit

**Buggy (Valve-side issues):** Muerta, Marci, Lone Druid, Primal Beast, Dark Willow, Elder Titan, Hoodwink, Wisp
