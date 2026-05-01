# OHA Current Gap: 7.41a To 7.41b

Generated: 2026-05-01

## Snapshot

|Field|Value|
|-|-|
|OpenHyperAI release reviewed|`OHA_v0.7.41a_2026.04.02`|
|OpenHyperAI tag|`v0.7.41a-26.4.2`|
|OpenHyperAI commit|`cb814c6c8dc51ed08045d6efd9f4a48147992711`|
|Repo version file|`bots/FunLib/version.lua` says `0.7.41 - 2026/04/02`|
|Valve latest patch at research time|`7.41b`|
|Valve latest patch date|2026-04-07 UTC|
|Actionable OHA gap|Only `7.41b` is after upstream OHA 7.41a|

## Verdict

Starting from upstream OHA latest is reasonable, but it should be treated as a 7.41a base that still needs a 7.41b patch pass. The current gap is not a large map rework, but it touches systems that bots care about: Tormentor math, item behavior, neutral item behavior, health restoration, many hero tuning constants, and a few ability behavior edge cases.

## 7.41b Bot Impact Summary

|Area|Official Change Shape|Bot Impact|
|-|-|-|
|Tormentor|Reflect scaling per minute was reduced.|Recheck Tormentor damage and go/no-go thresholds in group objective logic.|
|Black King Bar|Avatar duration is fixed and no longer buff-duration amplified.|Item timing logic should not infer longer BKB duration from modifiers.|
|Consecrated Wraps|Hallowed moved from buff stacks to item charges and consumes all charges on barrier.|Any charge, cooldown, or movement-speed reasoning around this item needs an item-charge model.|
|Gleipnir|Eternal Chains radius increased.|AoE catch and escape-risk heuristics can be slightly more aggressive.|
|Health Restoration items|Sange family and Abyssal restoration bonuses were reduced.|Survival modeling and item scoring should not overvalue these items.|
|Holy Locket|Incoming and outgoing heal amplification split changed.|Support item scoring should separate incoming sustain from outgoing ally healing.|
|Helm of the Overlord|Dominate cooldown and controlled unit minimum health improved.|Dominated creep value is higher, especially for push and aura planning.|
|Book of the Dead|Demonic Warrior lost True Sight.|Deward and invisibility response logic must not rely on this neutral for detection.|
|Minotaur Horn|Lesser Avatar magic resistance improved.|Escape and dispel value slightly higher for carriers.|
|Conjurer's Catalyst|Spellover received internal cooldown and threshold/damage changes.|Damage estimation should not assume unlimited multi-proc behavior.|
|Largo|Direct tuning changes in 7.41b.|Largo support role wiring, ability usage, and item plan must be verified after import.|
|Meepo|Major 7.41b follow-up nerfs and rules changes.|Clone, item-stat, TP, and cooldown assumptions are high-risk for bot logic.|

## 7.41b Counts From Valve Datafeed

|Category|Count|
|-|-|
|General note groups|1|
|Item entries|11|
|Neutral item and enchantment entries|12|
|Hero entries|61|
|Neutral creep entries|1|

## 7.41b Hero Coverage

Valve 7.41b touches 61 heroes:

Anti-Mage, Bloodseeker, Crystal Maiden, Drow Ranger, Juggernaut, Pudge, Sand King, Tiny, Windranger, Shadow Shaman, Slardar, Tidehunter, Enigma, Tinker, Necrophos, Beastmaster, Death Prophet, Phantom Assassin, Nature's Prophet, Clinkz, Omniknight, Night Stalker, Broodmother, Jakiro, Batrider, Chen, Spectre, Ancient Apparition, Doom, Gyrocopter, Alchemist, Invoker, Silencer, Lycan, Shadow Demon, Chaos Knight, Meepo, Treant Protector, Rubick, Nyx Assassin, Naga Siren, Keeper of the Light, Slark, Magnus, Timbersaw, Tusk, Skywrath Mage, Elder Titan, Techies, Ember Spirit, Terrorblade, Phoenix, Arc Warden, Monkey King, Pangolier, Hoodwink, Void Spirit, Snapfire, Dawnbreaker, Primal Beast, Largo.

## Code Update Targets

|System|Files To Check|
|-|-|
|Version and migration notes|`bots/FunLib/version.lua`, `typescript/bots/FunLib/version.ts`, release docs|
|Hero identity and role data|`typescript/bots/ts_libs/dota/heroes.ts`, `bots/ts_libs/dota/heroes.lua`, `typescript/bots/FunLib/aba_hero_roles_map.ts`, `typescript/bots/FunLib/aba_hero_pos_weights.ts`|
|Largo behavior|`bots/BotLib/hero_largo.lua`, `bots/FunLib/spell_list.lua`, `bots/FunLib/spell_prob_list.lua`, hero role and item strategy tables|
|Meepo behavior|`bots/BotLib/hero_meepo.lua`, shared clone checks, TP/cooldown logic, item stat assumptions|
|Tormentor and Roshan logic|`bots/mode_roshan_generic.lua`, `bots/FunLib/aba_site.lua`, `typescript/bots/FunLib/aba_site.ts`, group objective helpers|
|Item behavior|`bots/ability_item_usage_generic.lua`, `bots/FunLib/aba_item.lua`, `typescript/bots/FunLib/advanced_item_strategy.ts`|
|Neutral item behavior|`bots/Buff/NeutralItems.lua`, `bots/FretBots/SettingsNeutralItemTable.lua`, `typescript/post-process/names.ts`|
|Deward and invis response|`bots/mode_ward_generic.lua`, `bots/FunLib/aba_ward_utility.lua`, item-detection helpers|
|Health and sustain modeling|`bots/FunLib/jmz_func.lua`, `bots/FunLib/aba_buff.lua`, item desirability helpers|

## High Priority Implementation Checks

1. Verify OHA has complete Largo role data, support eligibility, item builds, and ability use after 7.41b.
2. Verify Tormentor desire still models 7.41 spawn preference and the reduced reflect scaling.
3. Verify neutral item tables include 7.41 artifacts, enchantments, and the Book of the Dead True Sight removal.
4. Verify deward logic does not treat neutral summons as reliable True Sight after 7.41b.
5. Verify Meepo-specific logic around clone item stats, TP scroll cooldown sharing, and MegaMeepo timing.
6. Verify health restoration calculations after 7.41 and 7.41b item changes.

## Sources

|Source|URL|
|-|-|
|Valve patch list|https://www.dota2.com/datafeed/patchnoteslist?language=english|
|Valve 7.41b data|https://www.dota2.com/datafeed/patchnotes?version=7.41b&language=english|
|Valve hero list|https://www.dota2.com/datafeed/herolist?language=english|
|Valve item list|https://www.dota2.com/datafeed/itemlist?language=english|
|Valve ability list|https://www.dota2.com/datafeed/abilitylist?language=english|
|OpenHyperAI latest release|https://github.com/forest0xia/dota2bot-OpenHyperAI/releases/tag/v0.7.41a-26.4.2|

