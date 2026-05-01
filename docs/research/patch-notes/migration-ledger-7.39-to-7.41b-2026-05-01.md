# Migration Ledger: 7.39 To 7.41b

Generated: 2026-05-01

## Scope

This ledger covers the patch path from the old local 7.39-era script context through current official Dota 2 patch `7.41b`. It is useful for understanding why the local fork felt stale, even though the chosen implementation base is now upstream OHA `v0.7.41a-26.4.2`.

For the new OHA base, the direct live gap is only `7.41b`. For project history and code audit, the wider migration path is:

`7.39b`, `7.39c`, `7.39d`, `7.39e`, `7.40`, `7.40b`, `7.40c`, `7.41`, `7.41a`, `7.41b`.

## Patch Sequence

|Patch|Date UTC|General|Items|Neutral Items|Heroes|Neutral Creeps|Bot-Risk Summary|
|-|-|-|-|-|-|-|-|
|7.39b|2025-05-29|1|1|8|39|1|Warding and pathing risk from terrain, tree, and ward-block fixes.|
|7.39c|2025-06-24|2|6|8|49|4|Watcher, Roshan, Tormentor, item, neutral, and broad hero tuning.|
|7.39d|2025-08-05|1|14|10|47|1|Triangle spawnbox changes, ward spot fixes, item and neutral churn.|
|7.39e|2025-10-02|1|6|5|49|3|Stacked camp penalty changed from 15 percent to 20 percent.|
|7.40|2025-12-15|5|49|25|120|2|Large systemic update: talents, map, objectives, runes, couriers, items, neutrals, heroes, Spirit Bear.|
|7.40b|2025-12-23|1|4|1|66|1|Large follow-up tuning pass, including Largo and Spirit Bear.|
|7.40c|2026-01-21|1|2|1|39|1|Follow-up balance, including Largo and Spirit Bear behavior.|
|7.41|2026-03-24|4|71|54|126|12|Major system update: facets removed, objectives and terrain shifted, health and lifesteal mechanics changed.|
|7.41a|2026-03-27|1|1|2|37|1|Immediate 7.41 follow-up balance. This is the OHA release target.|
|7.41b|2026-04-07|1|11|12|61|1|Current live gap after OHA 7.41a: Tormentor, items, neutral items, hero tuning.|

## Major Migration Themes

### Map, Warding, And Camp Geometry

Patches 7.39b, 7.39c, 7.39d, 7.40, and 7.41 all changed terrain, trees, watcher positions, tower/camp relationships, spawn boxes, and wardable spots. This is the main reason old ward tables and stack/pull positions are risky.

Files to audit:

|Concern|Files|
|-|-|
|Ward spot tables|`bots/FunLib/aba_ward_utility.lua`|
|Ward mode selection|`bots/mode_ward_generic.lua`|
|Camp location and farming logic|`bots/FunLib/aba_site.lua`, `typescript/bots/FunLib/aba_site.ts`, `bots/mode_farm_generic.lua`|
|Pull and lane behavior|`bots/mode_laning_generic.lua`, `bots/mode_roam_generic.lua`|

### Stacking Economy

Patch 7.39e increased the neutral gold and XP penalty for stacked camps from 15 percent to 20 percent. This does not make stacking bad, but it changes the risk/reward threshold. Opportunistic support stacks are still valuable when nearby and low-risk, while long detours are harder to justify.

Files to audit:

|Concern|Files|
|-|-|
|Stack desire and distance gates|`bots/mode_roam_generic.lua`, support behavior helpers|
|Camp availability|`bots/mode_farm_generic.lua`, `bots/FunLib/aba_site.lua`|
|Carry farm routing|`bots/mode_farm_generic.lua`, `bots/FunLib/aba_role.lua`|

### Talent And Facet Model

Patch 7.40 changed talent points so talents no longer use normal skill points. Patch 7.41 removed facets entirely. Any script logic that still assumes facet selection, facet-specific ability behavior, or old talent-point competition is stale.

Files to audit:

|Concern|Files|
|-|-|
|Skill build generation|`bots/FunLib/aba_skill.lua`|
|Hero build lists|`bots/BotLib/hero_*.lua`, `typescript/bots/BotLib/hero_*.ts`|
|Hero roles and generated hero data|`typescript/bots/FunLib/aba_hero_roles_map.ts`, `typescript/bots/FunLib/aba_hero_pos_weights.ts`|

### Objectives: Tormentor, Roshan, Wisdom, Lotus

Patch 7.40 changed Tormentor timer/ping behavior and made Tormentor damage start only after it is attacked or damaged. Patch 7.41 switched Tormentor and Roshan pit preference, changed Tormentor durability and reflect behavior, moved Tormentor and Lotus terrain, and changed Wisdom Shrine experience. Patch 7.41b reduced Tormentor reflect scaling again.

Files to audit:

|Concern|Files|
|-|-|
|Roshan and Tormentor desire|`bots/mode_roshan_generic.lua`, `bots/mode_team_roam_generic.lua`|
|Objective location constants|`bots/FunLib/aba_site.lua`, `typescript/bots/FunLib/aba_site.ts`|
|Team assemble behavior|`bots/mode_assemble_generic.lua`, team-roam logic|

### Runes, Couriers, And Laning

Patch 7.40 changed bounty rune activation value, haste rune duration, invisibility rune mitigation, courier respawn time, courier consumable carrying penalties, and secret shop courier behavior. Patch 7.41 adjusted early creep meeting points and offlane/safelane creep speeds until 7:30.

Files to audit:

|Concern|Files|
|-|-|
|Rune desire|`bots/mode_rune_generic.lua`|
|Courier and purchases|`bots/item_purchase_generic.lua`, FretBots courier helpers if used|
|Laning equilibrium|`bots/mode_laning_generic.lua`, `bots/FunLib/jmz_func.lua`|

### Health Restoration, Healing, And Lifesteal

Patch 7.41 changed Health Restoration semantics and lifesteal damage accounting. Patch 7.41b then reduced several Health Restoration item bonuses and changed Holy Locket amplification split. Bot survival estimates and support item scoring can be wrong if they treat older heal amplification rules as current.

Files to audit:

|Concern|Files|
|-|-|
|Generic health heuristics|`bots/FunLib/jmz_func.lua`, `typescript/bots/FunLib/utils.ts`|
|Item desirability|`bots/ability_item_usage_generic.lua`, `bots/FunLib/aba_item.lua`|
|Support sustain items|`typescript/bots/FunLib/advanced_item_strategy.ts`, hero item builds|

### Neutral Items, Artifacts, And Enchantments

Patch 7.41 has the largest neutral item and enchantment footprint in this range. Patch 7.41b specifically changes several artifact and enchantment behaviors and removes True Sight from Book of the Dead's Demonic Warrior. Scripts should not infer deward coverage from that neutral anymore.

Files to audit:

|Concern|Files|
|-|-|
|Neutral item pools|`bots/Buff/NeutralItems.lua`, `bots/FretBots/SettingsNeutralItemTable.lua`|
|Generated neutral names|`typescript/post-process/names.ts`|
|Deward detection assumptions|`bots/mode_ward_generic.lua`, `bots/FunLib/aba_ward_utility.lua`|

### Hero Coverage

The wide migration path touches almost every hero. Patch 7.41 alone touches 126 hero entries, and 7.41b touches 61. OHA latest advertises 7.41a coverage, but still needs targeted verification for Largo, Meepo, Spirit Bear, and any hero whose behavior relies on removed facets or changed innate scaling.

Files to audit:

|Concern|Files|
|-|-|
|New and recently reworked heroes|`bots/BotLib/hero_largo.lua`, `bots/BotLib/hero_kez.lua`, generated TypeScript hero data|
|Spirit Bear special-case behavior|`bots/FretBots/HeroLoneDruid.lua`, Lone Druid helpers, minion logic|
|Hero ability weights|`bots/FunLib/spell_list.lua`, `bots/FunLib/spell_prob_list.lua`|
|Counter item and threat detection|`typescript/bots/FunLib/advanced_item_strategy.ts`, `bots/FunLib/aba_matchups.lua`|

## Special Data Note: `hero_id` 1961

Valve patch data uses `hero_id` 1961 for Spirit Bear entries in 7.40, 7.40b, and 7.40c. It is not returned in the normal hero list as a standard hero. Treat it as Lone Druid Spirit Bear, not as a missing playable hero.

## Migration Checklist

1. Import OHA 7.41a as the clean base.
2. Preserve and replay local bug fixes as small commits, not a bulk merge.
3. Apply the 7.41b bot-impact checks from the current-gap document.
4. Verify Largo role, item, spell, and support behavior end to end.
5. Rebuild ward tables from live map positions before trusting deward or objective ward decisions.
6. Re-evaluate stack timing and detour desire after the 20 percent stacked camp penalty.
7. Re-evaluate Tormentor and Roshan desire after 7.41 and 7.41b.
8. Remove or quarantine any facet-era assumptions.
9. Run gameplay-oriented review after code compiles: laning, support roam, warding, dewarding, stacking, objectives, buybacks, and item usage.

## Sources

|Patch|Valve Datafeed URL|
|-|-|
|7.39b|https://www.dota2.com/datafeed/patchnotes?version=7.39b&language=english|
|7.39c|https://www.dota2.com/datafeed/patchnotes?version=7.39c&language=english|
|7.39d|https://www.dota2.com/datafeed/patchnotes?version=7.39d&language=english|
|7.39e|https://www.dota2.com/datafeed/patchnotes?version=7.39e&language=english|
|7.40|https://www.dota2.com/datafeed/patchnotes?version=7.40&language=english|
|7.40b|https://www.dota2.com/datafeed/patchnotes?version=7.40b&language=english|
|7.40c|https://www.dota2.com/datafeed/patchnotes?version=7.40c&language=english|
|7.41|https://www.dota2.com/datafeed/patchnotes?version=7.41&language=english|
|7.41a|https://www.dota2.com/datafeed/patchnotes?version=7.41a&language=english|
|7.41b|https://www.dota2.com/datafeed/patchnotes?version=7.41b&language=english|
