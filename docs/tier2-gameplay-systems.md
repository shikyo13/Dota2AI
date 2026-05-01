# Dota2AI Tier 2 Gameplay Systems

Generated for current script state: 2026-05-01.

## Hero Selection And Lanes

`bots/hero_selection.lua` owns draft flow for most game modes.

Inputs:

- `bots/FunLib/aba_hero_pos_weights.lua`
- `bots/FunLib/aba_role.lua`
- `bots/FunLib/aba_team_names.lua`
- `bots/FunLib/aba_matchups.lua`
- `bots/FretBots/matchups_data.lua`
- `bots/FretBots/HeroNames.lua`
- `bots/Customize/*`

Behavior:

- Builds role pools from position weights.
- Applies weak-hero cap and configurable weak penalty.
- Applies strict ban and repeat policy.
- Scores matchup-aware candidates.
- Supports Captain Mode and 1v1 mid paths.
- Handles chat commands for picks, bans, roles, and language.
- Updates lane assignments after picks and role swaps.

## Ability And Talent Leveling

`bots/ability_item_usage_generic.lua` owns ability leveling.

Current behavior:

- Loads `sSkillList` from the active `BotLib` hero file.
- Reloads the hero build for ARDM hero swaps.
- Reloads the hero build for `!pos` position swaps and tells item purchase to rebuild.
- Rebuilds generic skill lists from `J.Skill.GetTalentList` and `J.Skill.GetAbilityList` if ARDM loads before abilities are ready.
- Contains Kez ability-name swap handling for stance mode.
- Skips nil entries and broken entries rather than hard-crashing.

`bots/FunLib/aba_skill.lua` is the source of ability and talent list construction. It filters hidden and not-learnable abilities, keeps placeholders where needed, and maps talent preferences into skill-up order.

## Items And Economy

`bots/item_purchase_generic.lua` owns shopping.

Behavior:

- Reverses hero purchase list for stack-like processing.
- Tracks current finished item, current basic item, required component counts, and last purchase attempt.
- Avoids buying duplicate components when already owned.
- Handles secret shop and courier-assisted purchase paths.
- Rebuilds purchase state for ARDM hero swaps.
- Rebuilds purchase state after `!pos` role swaps through `bot.needPurchaseRebuild`.
- Avoids rebuying early consumables late in ARDM.
- Reserves money around buyback, Aghanim shard timing, and late-game tower state.
- Buys support consumables: dust, observer wards, sentry wards, smoke, and blood grenade.
- Moves wards between backpack and main inventory depending on whether the bot is in ward mode.

`bots/FunLib/aba_item.lua` contains item classifications, recipe data, sell rules, neutral-like debug items, ward item recognition, and inventory helpers.

## Ability, Item, Courier, Buyback, And Glyph Use

Shared callbacks in `bots/ability_item_usage_generic.lua`:

|Callback|Purpose|
|-|-|
|`AbilityLevelUpThink`|Level abilities and talents through current `sSkillList`.|
|`AbilityUsageThink`|Dispatch hero `SkillsComplement`.|
|`ItemUsageThink`|Run generic active-item logic.|
|`CourierUsageThink`|Run courier safety and delivery behavior.|
|`BuybackUsageThink`|Run buyback logic and glyph checks.|

The file also handles chat reactions, courier rescue, item desires, and defensive glyph use for towers, barracks, and ancient.

## Mode Arbitration

Dota asks each loaded `mode_*_generic.lua` for a desire score. The active mode gets `Think`.

|Mode|Responsibility|
|-|-|
|`mode_assemble_generic.lua`|Responds to recent human normal pings by moving nearby bots to the ping location.|
|`mode_assemble_with_humans_generic.lua`|Disabled low-desire placeholder.|
|`mode_attack_generic.lua`|Delegates to override attack mode only for buggy Valve heroes.|
|`mode_laning_generic.lua`|Last-hit, deny, passive lane desire, and lane fallback logic.|
|`mode_farm_generic.lua`|Lane and neutral farming, camp targeting, farm announcements.|
|`mode_retreat_generic.lua`|Run logic and retreat desire.|
|`mode_roam_generic.lua`|Hero-specific roaming, general reactions, and lane gank routing.|
|`mode_team_roam_generic.lua`|Team fights, ally help, target selection, special unit attacks, dropped item operations.|
|`mode_ward_generic.lua`|Observer and sentry placement.|
|`mode_roshan_generic.lua`|Roshan timing, safety gates, human pings, and DPS checks.|
|`mode_rune_generic.lua`|Rune pickup and closest-bot routing.|
|`mode_outpost_generic.lua`|Outpost capture and safety checks.|
|`mode_secret_shop_generic.lua`|Secret shop travel.|
|`mode_side_shop_generic.lua`|Tormentor and side objective behavior.|
|`mode_push_tower_*_generic.lua`|Lane push wrapper into `aba_push`.|
|`mode_defend_tower_*_generic.lua`|Lane defend wrapper into `aba_defend`.|

## Roaming And Ganking

`bots/mode_roam_generic.lua` combines many travel behaviors:

- Tinker base wait and heal.
- Move outside fountain behavior.
- Tango tree use.
- Hero-specific travel reactions for Spirit Breaker, Batrider, Nyx, Pangolier, Phoenix, Snapfire, Leshrac, Void Spirit, Marci, Muerta, Razor, Lone Druid bear, Pudge, Shadow Fiend, and others.
- General reactions to stacked debuffs, rupture, Trample, Chain Frost, Razor Static Link, tower aggro, and low health.
- Lane gank decision scaffolding with short commitment windows and a disabled twin-gate path.

The current branch does not implement a standalone stack mode in loaded runtime.

## Team Roam And Fights

`bots/mode_team_roam_generic.lua` handles group fight behavior:

- Updates enemy role estimates.
- Helps cores when they are targeted.
- Helps retreating or threatened allies.
- Lets cores and supports pick targets differently.
- Attacks special units through `aba_special_units`.
- Avoids zones from dangerous modifiers.
- Handles tower creep and last-hit opportunities when safe.
- Performs item pickup and swap operations for expensive dropped items and consumables.

## Warding

`bots/mode_ward_generic.lua` and `bots/FunLib/aba_ward_utility.lua` own ward placement.

Current behavior:

- Position 4 and 5 bots are eligible.
- Skips warding during strong retreat, rune travel after game start, defend ally, defense, aggression, recent hero damage, or when enemies are closer to the ward location.
- Chooses observer spots through `W.GetAvailabeObserverWardSpots` and `W.GetClosestObserverWardSpot`.
- Chooses sentry spots through `W.GetPossibleSentryWardSpots` and `W.GetClosestSentryWardSpot`.
- Supports `item_ward_dispenser` by toggling between observer and sentry mode before placing.
- Tracks `plant_time_obs` and `plant_time_sentry` on selected spots.

Current risk:

- The branch does not attack visible enemy wards from ward mode.
- The ward utility table contains duplicate-style keys and at least one suspicious vector row in current source. Treat ward map edits as data validation work.

## Roshan And Side Objectives

`bots/mode_roshan_generic.lua`:

- Locates Roshan from nearby neutral creeps.
- Rejects Roshan while pushing high ground, defending ancient, outnumbered, near team fights, near enemies, or when core inventory space is too low.
- Tracks Roshan alive timing and DPS readiness.
- Reacts to human pings near the current Roshan location.
- Clamps team Roshan desire below full absolute desire.

`bots/mode_side_shop_generic.lua` includes Tormentor checks, ally count checks, right-click damage checks, and human ping support.

## FretBots And Buff Systems

`bots/FretBots.lua` loads:

- data tables
- settings
- timers
- bonus timers
- dynamic difficulty
- neutral items
- hero sounds
- role determination
- event hooks

`bots/Buff/*` contains bonus experience, gold, neutral item, helper, and timer modules. These systems are separate from the generic Dota callback files but affect bot difficulty and resource flow.
