# OpenHyperAI Release Review And Patch Gap

Date: 2026-05-01

## Current Migration Note

This report was written before the OHA reset. Statements about the local fork being older than upstream describe the pre-migration root checkout and backup branch `codex/pre-oha-local-backup-20260501`.

The active improvement worktree is now `D:\Dev\Projects\Dota2AI-worktrees\oha-improvements-20260501` on branch `codex/oha-improvements-20260501`, based on upstream tag `v0.7.41a-26.4.2`. The report remains useful for source evidence, patch-gap reasoning, and the recommendation to treat OHA as a substrate rather than trusted wholesale.

Scope:
- Local fork at `D:\Dev\Projects\Dota2AI`
- Upstream OpenHyperAI release `v0.7.41a-26.4.2`
- Official Dota 2 gameplay patches from local `7.39` support through current `7.41b`

## Executive Decision

Do not merge upstream OpenHyperAI into the dirty root checkout.

The best path is to create a clean OHA-based branch or worktree from upstream `v0.7.41a-26.4.2`, replay our local fixes as a controlled patch queue, then apply a `7.41b` update and support-AI improvements on top.

Starting completely from scratch is not the best first move. OHA still provides valuable scaffolding: loaded engine modes, 127 hero files, generated TypeScript boundaries, item purchase flow, FretBots data, hero selection, chat, and a mostly current `7.41/7.41a` pass. The problem is that OHA is not clean enough to trust wholesale. Treat it as a newer substrate, not as an authority.

## Baselines

### Local Fork

- Local `bots/FunLib/version.lua`: `0.7.39 - 2025/09/16`
- Local README support claim: Dota 2 Patch `7.39`, `126` heroes
- Current branch: `main`, ahead of `origin/main` by 6 commits before this research pass
- Working tree: dirty with our support, warding, runtime, dependency, and documentation work

Local gap against current Dota: `7.39b`, `7.39c`, `7.39d`, `7.39e`, `7.40`, `7.40b`, `7.40c`, `7.41`, `7.41a`, `7.41b`.

### Upstream OpenHyperAI

- Latest release API result: `OHA_v0.7.41a_2026.04.02`
- Tag: `v0.7.41a-26.4.2`
- Published: `2026-04-05 09:36:17 UTC`
- Commit: `cb814c6`
- Upstream `bots/FunLib/version.lua`: `0.7.41 - 2026/04/02`
- Upstream README claim: `127` heroes supported on Patch `7.41/7.41a`
- Upstream docs say last patch update target is `7.41a`

Upstream gap against current Dota: `7.41b`.

## Official Current Patch List

Valve's official patch list endpoint reports `7.41b` as the newest gameplay patch on 2026-05-01.

Patch sequence after `7.39`:
- `7.39b`, 2025-05-29
- `7.39c`, 2025-06-24
- `7.39d`, 2025-08-05
- `7.39e`, 2025-10-02
- `7.40`, 2025-12-15
- `7.40b`, 2025-12-23
- `7.40c`, 2026-01-21
- `7.41`, 2026-03-24
- `7.41a`, 2026-03-27
- `7.41b`, 2026-04-07

Official patch data counts:
- `7.39b`: 1 general section, 8 neutral item entries, 39 hero entries
- `7.39c`: 2 general sections, 6 item entries, 8 neutral item entries, 49 hero entries, 4 neutral creep entries
- `7.39d`: 1 general section, 14 item entries, 10 neutral item entries, 47 hero entries
- `7.39e`: 1 general section, 6 item entries, 5 neutral item entries, 49 hero entries, 3 neutral creep entries
- `7.40`: 5 general sections, 49 item entries, 25 neutral item entries, 120 hero entries, 2 neutral creep entries
- `7.40b`: 4 item entries, 66 hero entries
- `7.40c`: 2 item entries, 39 hero entries
- `7.41`: 4 general sections, 71 item entries, 54 neutral item entries, 126 hero entries, 12 neutral creep entries
- `7.41a`: 1 item entry, 2 neutral item entries, 37 hero entries
- `7.41b`: 1 general section, 11 item entries, 12 neutral item entries, 61 hero entries, 1 neutral creep entry

## Major Patch Data

### 7.39b

Bot-relevant changes:
- Radiant bottom tier 1 tower and surrounding trees were adjusted.
- A mid Radiant tier 2 juke path was adjusted.
- A top Dire tier 1 tree was removed.
- Some ward-blocked locations were fixed.

Impact:
- Warding spot data and lane path assumptions can drift even before `7.40`.
- Pull, stack, and lane equilibrium helpers that depend on exact tree geometry need in-game validation.

Changed heroes:
Anti-Mage, Axe, Beastmaster, Bloodseeker, Bristleback, Broodmother, Centaur Warrunner, Dark Seer, Dazzle, Disruptor, Doom, Elder Titan, Enchantress, Enigma, Kez, Lich, Lifestealer, Lina, Morphling, Nature's Prophet, Night Stalker, Omniknight, Oracle, Ringmaster, Sand King, Shadow Shaman, Silencer, Skywrath Mage, Slark, Sniper, Techies, Templar Assassin, Terrorblade, Tinker, Troll Warlord, Underlord, Ursa, Visage, Warlock.

### 7.39c

Bot-relevant changes:
- Roshan courier attack behavior changed.
- Tormentor reflection stopped considering creep-heroes for reflected damage.
- Watchers near Wisdom shrines moved slightly.
- Watcher activation range was reduced.
- Orb of Venom, Blade Mail, Hurricane Pike, Harpoon, Phylactery, and Khanda changed.

Impact:
- Tormentor risk estimates involving creep-heroes need adjustment.
- Ward and sentry logic around Wisdom shrines should not assume old watcher positions.
- Item purchase and item-use logic for Phylactery and Khanda builders should be reviewed.

Changed heroes:
Axe, Batrider, Beastmaster, Bristleback, Chaos Knight, Clinkz, Crystal Maiden, Dark Seer, Dark Willow, Death Prophet, Disruptor, Doom, Earth Spirit, Enchantress, Gyrocopter, Hoodwink, Kez, Kunkka, Lich, Lone Druid, Monkey King, Muerta, Naga Siren, Nature's Prophet, Nyx Assassin, Pangolier, Phantom Assassin, Phantom Lancer, Primal Beast, Puck, Pugna, Sand King, Shadow Shaman, Snapfire, Spectre, Sven, Techies, Templar Assassin, Terrorblade, Tiny, Tusk, Underlord, Undying, Vengeful Spirit, Visage, Windranger, Winter Wyvern, Wraith King, Zeus.

### 7.39d

Bot-relevant changes:
- Triangle Ancient camp spawn boxes were increased.
- A Radiant safe lane hard camp ward spot was fixed.
- Trees were removed inside the Dire safe lane small camp.
- Many item and neutral entries changed.

Impact:
- Camp stack and pull logic may have valid old locations that no longer match spawn boxes.
- Deward logic near pull camps needs fresh validation.

Changed heroes:
Abaddon, Axe, Batrider, Bloodseeker, Bounty Hunter, Crystal Maiden, Dark Willow, Dawnbreaker, Dazzle, Doom, Earth Spirit, Ember Spirit, Enchantress, Faceless Void, Grimstroke, Io, Kunkka, Luna, Mirana, Monkey King, Naga Siren, Nature's Prophet, Necrophos, Nyx Assassin, Pangolier, Phantom Assassin, Primal Beast, Puck, Queen of Pain, Sand King, Shadow Demon, Shadow Fiend, Shadow Shaman, Silencer, Skywrath Mage, Snapfire, Spirit Breaker, Techies, Templar Assassin, Tinker, Treant Protector, Undying, Ursa, Vengeful Spirit, Viper, Wraith King, Zeus.

### 7.39e

Bot-relevant changes:
- Scan no longer triggers on creep-heroes, except Lone Druid's Spirit Bear.
- Stacked neutral camp gold and XP penalty increased from 15 percent to 20 percent.

Impact:
- Stacking is still useful, but the reward is slightly lower. Stack decision logic should prefer opportunistic low-cost stacks, high-value carry camps, or stacks done while already rotating.
- Scan-based enemy validation cannot rely on creep-heroes.

Changed heroes:
Abaddon, Bane, Beastmaster, Brewmaster, Centaur Warrunner, Crystal Maiden, Dawnbreaker, Disruptor, Earth Spirit, Earthshaker, Hoodwink, Jakiro, Kez, Leshrac, Lich, Lifestealer, Lina, Magnus, Marci, Mars, Medusa, Monkey King, Naga Siren, Necrophos, Omniknight, Outworld Destroyer, Phantom Assassin, Phoenix, Puck, Pugna, Queen of Pain, Razor, Riki, Ringmaster, Rubick, Sand King, Silencer, Snapfire, Storm Spirit, Sven, Techies, Timbersaw, Treant Protector, Troll Warlord, Tusk, Ursa, Venomancer, Viper, Visage.

### 7.40

Major bot-relevant changes:
- New hero Largo was added as Dota's 127th hero.
- Talents no longer consume normal skill points. They use separate talent points.
- Tier 4 towers gained barracks-based reinforcement.
- Assist gold formula changed.
- Lane creep and flagbearer gold behavior changed.
- Courier respawn and courier shopping behavior changed.
- All illusions now have fixed 800 day vision and 400 night vision.
- Roshan is no longer treated like a hero for lifesteal.
- Tormentor timer UI was added, and Tormentor damage behavior changed.
- Bounty Rune, Haste Rune, and Invisibility Rune behavior changed.
- Major terrain changes affected base gates, streams, Wisdom shrines, Watchers, Lotus pool approaches, jungle camp tiers, and safe lane pull areas.
- Invulnerability targeting rules changed for Nullifier, Satyr Banisher, Dark Seer, Naga Siren, Ogre Magi, Oracle, Shadow Demon, Sniper, Sven, and Vengeful Spirit.

Major hero work:
- New hero: Largo.
- Full or near-full rewrites needed: Lone Druid, Slark, Spectre, Treant Protector, Brewmaster, Clinkz.
- Widespread moderate changes also affect Phoenix, Viper, Void Spirit, Warlock, Windranger, Winter Wyvern, Witch Doctor, Wraith King, Zeus, Ursa, Axe, and many others.

Major item work:
- Ethereal Blade, Guardian Greaves, Khanda, Refresher Orb, Heart of Tarrasque, Holy Locket, Radiance, Veil of Discord, Diffusal Blade, Disperser, Hand of Midas, Ghost Scepter, Heaven's Halberd, Healing Salve, Clarity, Iron Branch, Smoke of Deceit, Bloodstone, Boots of Bearing, Crimson Guard, Helm of Dominator, Glimmer Cape, and Giant's Maul changed.
- Illusion-based Diffusal and Disperser assumptions are especially important for Phantom Lancer, Naga Siren, Terrorblade, and Meepo.
- Hand of Midas became much less attractive for heroes that bought it mainly for XP multiplication.

Neutral item work:
- New or returning neutral artifacts include Ash Legion Shield, Weighted Dice, Flayer's Bota, Idol of Scree'auk, Metamorphic Mandible, Riftshadow Prism, Duelist Gloves, and Defiant Shell.
- Removed or displaced neutral artifacts include Brigand's Blade, Gale Guard, and Helm of the Undying.

Bot system impact:
- `ability_item_usage_generic.lua`: talent leveling must use the new talent point model.
- `bots/BotLib/hero_*.lua`: every hero with reworked abilities needs skill build, nil guard, target type, and item build review.
- `bots/FunLib/aba_item.lua`: removed and added items must match engine item names and recipes.
- `bots/FunLib/aba_site.lua`, `mode_laning_generic.lua`, `mode_farm_generic.lua`, `mode_roam_generic.lua`: camp, pull, gate, watcher, and jungle assumptions need validation.
- `mode_roshan_generic.lua`: Roshan lifesteal and timing assumptions need review.
- `mode_ward_generic.lua`, `aba_ward_utility.lua`: ward spots changed enough that stale coordinates are risky.

### 7.40b

Bot-relevant changes:
- Balance pass across 66 heroes.
- Mask of Madness, Silver Edge, Spirit Vessel, and Urn of Shadows changed.
- Several toggles became usable while silenced, including Muerta Gunslinger, Phantom Lancer Phantom Rush, Troll Battle Stance, Kez Switch Discipline, and Brewmaster Drunken Brawler.
- Largo received early balance changes.

Impact:
- Ability-use logic should not incorrectly suppress affected toggles during silence.
- Support item logic around Urn and Spirit Vessel charge handling needs review.
- Kez and Brewmaster scripts need special care because both have toggle/state behavior.

### 7.40c

Bot-relevant changes:
- Largo was added to Captains Mode.
- Khanda and Phylactery changed.
- 39 heroes changed.

Impact:
- Draft and role maps need Largo fully wired, not only a crash-prevention stub.
- Captains Mode logic must know Largo as a valid hero and role candidate.

### 7.41

Major bot-relevant changes:
- Facets were removed from the game.
- Innates no longer scale from other ability levels.
- Innates that previously scaled from ability levels were converted to fixed or hero-level scaling.
- Some per-level-up scaling became per-level scaling.
- Lane creep meeting points shifted toward offlane.
- Safe lane creeps are temporarily sped up and offlane creeps are temporarily slowed before 7:30.
- Currents movement speed bonus changed.
- Tormentor spawn preference switched.
- Roshan pit preference switched.
- Wisdom Shrine and Lotus Pool contest behavior changed.
- Wisdom Shrine XP changed to a different base plus interval model.
- Terrain around Tormentor, Twin Gates, Lotus Pools, safe lane towers, pull camps, flooded camps, and stream camps changed.
- Ancient neutral camps near stream ends were demoted to medium camps.
- A medium neutral camp near the offlane defender's gate was demoted to small.
- Health restoration, incoming heal amplification, lifesteal, damage manipulation, reflection damage, and free movement uphill attacks changed.

Major item work:
- New basic items: Chasm Stone, Shawl, Splintmail, Wizard Hat.
- Removed items: Cornucopia and Eternal Shroud.
- New upgrade items: Consecrated Wraps, Crella's Crozier, Essence Distiller, Specialist's Array, Hydra's Breath.
- Shiva's Guard and Bloodstone were reworked.
- Refresher Shard and Refresher Orb no longer refresh items.
- Dagon, Heaven's Halberd, Mage Slayer, Bloodthorn, Pipe of Insight, Veil of Discord, Solar Crest, Pavise, Drum of Endurance, Boots of Bearing, Glimmer Cape, Arcane Boots, Gleipnir, Battle Fury, Blade Mail, Orchid, Nullifier, Spirit Vessel, Radiance, and other items changed.

Neutral item work:
- Tier 1 neutral availability moved to game start.
- Madstone crafting cost for Tier 1 items changed.
- Neutral artifact choices increased for tiers 2 through 5.
- New or returning neutral entries include Forager's Kit, Stonefeather Satchel, Partisan's Brand, Spellslinger, Conjurer's Catalyst, Enchanter's Bauble, Prophet's Pendulum, Harmonizer, and other entries.
- Enchantments changed heavily.

Largo data:
- Official hero id: `155`
- Internal hero name: `npc_dota_hero_largo`
- Ability names from Valve data:
  - `largo_catchy_lick`
  - `largo_frogstomp`
  - `largo_croak_of_genius`
  - `largo_amphibian_rhapsody`
  - `largo_song_fight_song`
  - `largo_song_double_time`
  - `largo_encore`

Bot system impact:
- Any facet-conditioned logic should be removed or converted to innate or ability-state logic.
- Any script assuming an innate scales from a learned ability can be wrong.
- Pull and stack spots must be validated after camp movement and tier changes.
- Warding priorities must account for Tormentor, Roshan, Lotus, Wisdom, and stream terrain changes.
- Item build logic must not buy removed items or stale recipes.
- Item active logic needs special handling for Bloodstone, Crella's Crozier, Essence Distiller, Specialist's Array, Hydra's Breath, and reworked Refresher behavior.

### 7.41a

Bot-relevant changes:
- Minor follow-up patch: 1 item entry, 2 neutral item entries, 37 hero entries.
- Upstream OpenHyperAI claims this is included in release `v0.7.41a-26.4.2`.

Impact:
- Treat as already mostly covered by upstream, but still verify structural and target-type changes before trusting hero scripts.

### 7.41b

Bot-relevant changes:
- Tormentor reflection scaling per minute was reduced.
- 11 item entries changed.
- 12 neutral item entries changed.
- 61 hero entries changed.
- Largo received more changes.

Changed items:
Black King Bar, Consecrated Wraps, Gleipnir, Heaven's Halberd, Helm of the Overlord, Holy Locket, Mage Slayer, Sange, Abyssal Blade, Sange and Yasha, Kaya and Sange.

Changed neutral entries:
Jidi Pollen Bag, Conjurer's Catalyst, Enchanter's Bauble, Idol of Scree'auk, Metamorphic Mandible, Rattlecage, Book of the Dead, Minotaur Horn, Riftshadow Prism, and Crude, plus artifact and enchantment section entries.

Changed heroes:
Alchemist, Ancient Apparition, Anti-Mage, Arc Warden, Batrider, Beastmaster, Bloodseeker, Broodmother, Chaos Knight, Chen, Clinkz, Crystal Maiden, Dawnbreaker, Death Prophet, Doom, Drow Ranger, Elder Titan, Ember Spirit, Enigma, Gyrocopter, Hoodwink, Invoker, Jakiro, Juggernaut, Keeper of the Light, Largo, Lycan, Magnus, Meepo, Monkey King, Naga Siren, Nature's Prophet, Necrophos, Night Stalker, Nyx Assassin, Omniknight, Pangolier, Phantom Assassin, Phoenix, Primal Beast, Pudge, Rubick, Sand King, Shadow Demon, Shadow Shaman, Silencer, Skywrath Mage, Slardar, Slark, Snapfire, Spectre, Techies, Terrorblade, Tidehunter, Timbersaw, Tinker, Tiny, Treant Protector, Tusk, Void Spirit, Windranger.

Impact:
- Upstream `v0.7.41a-26.4.2` is not current for 7.41b.
- Most 7.41b hero entries are numeric balance changes, but item active behavior and Tormentor math can affect bot decisions.
- Largo support should be reviewed after 7.41b because it changed after upstream's advertised support window.

## Roshling Note

No official `Roshling` match was found in Valve's patch datafeed for `7.39b` through `7.41b`. If a secondary source claims Roshling was added in this patch range, verify against the live client or another official data source before building bot objective logic around it.

## Upstream Release Review

Review target: `D:\Dev\Projects\Dota2AI\.worktrees\openhyperai-v0.7.41a-review`, detached at `cb814c6`.

Verification:
- `npm ci --legacy-peer-deps` completed, with 5 reported vulnerabilities.
- `npm run build` completed.
- `npx tsc -p tsconfig-node.json --noEmit` completed.
- `npx tsc -p tsconfig-tstl.json --noEmit` completed.
- `npm ls typescript typescript-to-lua` failed because upstream uses `typescript@5.5.4` with `typescript-to-lua@1.26.2`, whose peer expectation is `5.5.2`.
- Build emitted TSTL truthiness warnings in `typescript/bots/FunLib/advanced_item_strategy.ts`.

High-value upstream improvements:
- Brings the baseline from local `7.39` to claimed `7.41/7.41a`.
- Adds Largo support and several 7.40 and 7.41 hero rewrites.
- Adds `7.41` item names and several active-use handlers.
- Adds architecture, API, and patch-update docs.
- Improves rune, attack, laning, push, defend, farming, and hero logic across many commits.

Upstream release risks found during review:
- Largo role wiring is incomplete. Largo exists in some hero and position-weight data but is missing from role maps used by support selection and role-sensitive logic.
- Neutral postprocess data is not fully aligned with official 7.41 neutral data. Some stale or removed neutrals and enchantments remain, and some official entries are missing.
- Buff neutral distribution is stale and can still include removed enhancers.
- Tormentor helper logic is suspicious after the 7.41 spawn preference switch because the helper is static by team while the patch guide discusses a day/night inversion.
- 7.41b is not documented or covered as complete.
- `advanced_item_strategy.ts` uses a bad `GetTeamMember(GetOpposingTeam(), i)` signature and compiles unsafe dot-call style on the result.
- `utils.ts` has a zero-ally divide-by-zero path.
- `aba_push.ts` can raise a stricter push desire cap when enemies are near the allied Ancient.
- `global_cache.ts` stores team-specific state in a singleton not keyed by team or bot.
- `mode_ward_generic.lua` returns `false` for core roles instead of a numeric desire.
- `mode_ward_generic.lua` treats `item_ward_dispenser` as observer or sentry without verifying the selected charge type in the old code path.
- `aba_ward_utility.lua` contains a malformed vector and duplicate numeric keys that overwrite ward spots.
- Deward logic still has stale observer lifespan checks.
- Support roaming is shallow. Proactive gank logic exists but is commented out.
- Stacking data exists in `aba_site.lua`, but upstream has no real support stack or pull executor.

Local fixes worth replaying onto an OHA base:
- TypeScript pin to `5.5.2` for `typescript-to-lua@1.26.2` compatibility.
- `.claude/` ignore and local settings cleanup.
- Ward table malformed vector and duplicate key fixes.
- Ward dispenser charge-type handling.
- Visible enemy ward attack and deward target selection.
- Observer lifespan check fix in sentry logic.
- Ward action numeric desire returns and stale target reset.
- Nil-safe `GetNearbyHeroes` handling.
- `GetTeamMember` player-ID misuse fixes.
- Roshan mode desire scale fixes.
- Post-laning opportunistic support stacking in loaded roam mode.
- Kez nil guard, TP exclusion boolean fix, Arc Warden syntax fix, Clockwerk cog targeting fix, Thunder Clap kill damage fix, Wisp nearby-hero guards.

## Merge Strategy Recommendation

Recommended path:
1. Preserve current dirty root work as a patch queue or commit on a local branch.
2. Create a clean worktree from `upstream/v0.7.41a-26.4.2` or `upstream/main`.
3. Apply the local fixes above in small commits.
4. Apply official `7.41b` update work.
5. Add source-data checks for hero roster, role maps, item names, neutral items, and removed items.
6. Then build support intelligence: warding, dewarding, smoke/objective warding, blocked camp inference, lane pulls, and opportunistic stacking.

Avoid:
- Do not merge upstream directly into the current dirty `main`.
- Do not cherry-pick OHA piecemeal onto current `main`; the missing upstream change set is too broad.
- Do not start from a blank bot project until we have proven the OHA substrate cannot be stabilized. Rebuilding all hero, item, mode, and selection scaffolding from scratch would burn a lot of time before improving support AI.

## Source Links

- Valve patch list API: https://www.dota2.com/datafeed/patchnoteslist?language=english
- Valve 7.39b data: https://www.dota2.com/datafeed/patchnotes?version=7.39b&language=english
- Valve 7.39c data: https://www.dota2.com/datafeed/patchnotes?version=7.39c&language=english
- Valve 7.39d data: https://www.dota2.com/datafeed/patchnotes?version=7.39d&language=english
- Valve 7.39e data: https://www.dota2.com/datafeed/patchnotes?version=7.39e&language=english
- Valve 7.40 data: https://www.dota2.com/datafeed/patchnotes?version=7.40&language=english
- Valve 7.40b data: https://www.dota2.com/datafeed/patchnotes?version=7.40b&language=english
- Valve 7.40c data: https://www.dota2.com/datafeed/patchnotes?version=7.40c&language=english
- Valve 7.41 data: https://www.dota2.com/datafeed/patchnotes?version=7.41&language=english
- Valve 7.41a data: https://www.dota2.com/datafeed/patchnotes?version=7.41a&language=english
- Valve 7.41b data: https://www.dota2.com/datafeed/patchnotes?version=7.41b&language=english
- Valve Largo hero page: https://www.dota2.com/hero/largo
- Valve Largo data: https://www.dota2.com/datafeed/herodata?language=english&hero_id=155
- OpenHyperAI latest release API: https://api.github.com/repos/forest0xia/dota2bot-OpenHyperAI/releases/latest
- OpenHyperAI release page: https://github.com/forest0xia/dota2bot-OpenHyperAI/releases/tag/v0.7.41a-26.4.2
- OpenHyperAI release README: https://raw.githubusercontent.com/forest0xia/dota2bot-OpenHyperAI/v0.7.41a-26.4.2/README.md
- OpenHyperAI release version file: https://raw.githubusercontent.com/forest0xia/dota2bot-OpenHyperAI/v0.7.41a-26.4.2/bots/FunLib/version.lua
- d2vpkr neutral item data: https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/neutral_items.txt
