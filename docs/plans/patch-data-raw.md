# Dota 2 Patch 7.40/b/c - Raw Bot-Relevant Data

Scraped 2026-02-25 from Liquipedia, official Dota 2 site, and gaming news sources.
Patches: 7.40 (2025-12-15), 7.40b (2025-12-23), 7.40c (2026-01-21).

**Superseding rule applied:** Where 7.40c changed something from 7.40b which changed 7.40, only the FINAL state is noted (with history in parentheses).

---

## 1. GENERAL / MECHANIC CHANGES

### Talent System Overhaul
- **Talents no longer consume skill points** -- uses dedicated talent points at levels 10, 15, 20, 25, 27, 28, 29, 30
- All +2 All Attributes bonuses skilled by level 22
- Facets with 6 All Attributes bonuses restored to 7
- **Bot impact:** `ability_item_usage_generic.lua`, all `BotLib/hero_*.lua` talent logic, `jmz_func.lua` leveling

### Assist Gold Formula Reworked
- OLD: `60 + ((VictimNetworth * 0.037) / NumHeroes)`
- NEW: `15 + ((50 + (VictimNetworth * 0.037)) / NumHeroes)`
- **Bot impact:** `jmz_func.lua` gold calculations, `aba_strategy.lua` kill priority

### Illusion Vision
- All illusions now have 800 daytime / 400 nighttime vision
- **Bot impact:** `jmz_func.lua` illusion handling

### Courier Changes
- Respawn time: `60 + 6*LVL` -> `45 + 5*LVL`
- No longer slowed 15% when carrying consumables (Clarity, Mango, Faerie Fire, Salve, Tango)
- **Bot impact:** `mode_courier_generic.lua`

### Roshan Changes
- Now treated as creep (not hero) for lifesteal/spell lifesteal
- Roar of Retribution disarm no longer dispelable
- Slam: no longer 2x slow duration vs non-heroes; now 2x damage instead
- **Bot impact:** `mode_roshan_generic.lua`, Roshan fight logic

### Neutral Creep Changes
- Satyr Banisher Purge: can no longer target invulnerable units
- Satyr Mindstealer Mana Burn int multiplier: 2/2.5/3/4 -> 1/1.5/2/2.5
- **Bot impact:** `jmz_func.lua` jungle handling

### Invulnerability Targeting
- Most items/abilities can no longer target invulnerable units
- Affected heroes: Dark Seer (Vacuum), Naga Siren (Ensnare), Ogre Magi (Bloodlust), Oracle (Fortune's End), Shadow Demon (Demonic Purge), Sniper (Assassinate), Sven (Storm Hammer Aghs), Vengeful Spirit (Nether Swap)
- Affected items: Nullifier, Diffusal Blade (Inhibit), Disperser (Suppress)
- Nullifier dispels Cyclone immediately on already-affected units
- **Bot impact:** `BotLib/hero_*.lua` targeting logic for affected heroes, `ability_item_usage_generic.lua`

### Captain's Mode Draft Order
- Restructured (specifics not fully captured)
- **Bot impact:** `hero_selection.lua`

---

## 2. MAP / TERRAIN CHANGES

### Base Changes
- Extended streams into both bases with new defender's gates on opposite lanes
- Removed trees near new safelane defender's gate positions
- Hard camp nearest T3 towers demoted to medium camp
- Safelane medium amphibian camp moved closer to bases
- **Bot impact:** `mode_laning_generic.lua`, `jmz_func.lua` camp locations

### Wisdom Shrine Changes
- Lowered to low ground, filled with water, connected via T1 tower areas
- Moved closer to T1 towers with repositioned Watchers for night vision
- Hard camps nearby moved slightly toward bases
- **Bot impact:** `mode_rune_generic.lua`, `aba_strategy.lua` rune contest

### Other Terrain
- Changed 'bridges' to actual bridges
- Expanded Lotus pool entrance areas
- Hard camp in 'triangle' demoted to medium camp
- Cleared areas around Tormentor locations
- Removed mid-lane and small water camp Watchers
- Repositioned primary jungle Watchers from stairs to bounty rune cliffs
- Added flying movement blocks around map edges (prevents Batrider Firefly access)
- Removed tree between Dire Safelane T1 tower and small pull camp
- Adjusted Radiant Offlane creep pathing and T2 tower position
- Radiant Secret Shop repositioned
- Tormentor minimap icon now shows status and respawn times
- The Shining (Tormentor ability) only activates when attacked, lasting 10 seconds
- **Bot impact:** `mode_laning_generic.lua`, pathing, `mode_farm_generic.lua` camp changes

---

## 3. ITEM CHANGES (Final State after 7.40c)

### Major Reworks

**Ethereal Blade** [REWORKED]
- OLD: Aether Lens + Ghost Scepter + Recipe(1600) = 5375g; 8 all stats, 300 mana, 3 mana regen, 250 cast range
- NEW: Ultimate Orb + Ghost Scepter + Recipe(900) = 5200g; 24 all stats
- Ether Blast: damage from `50 + 150% primary attr` -> `50 + 100% sum of all attributes`
- Magic res reduction: 40% -> 30%
- **Bot impact:** `item_purchase_generic.lua`, hero sBuyList for Ethereal Blade builders (Morphling, etc.)

**Guardian Greaves** [REWORKED]
- No longer requires Buckler
- Recipe cost: 1450 -> 1125; Total: 5050 -> 4300g
- Armor: 4 -> 5; Guardian Aura no longer grants 3 armor
- Low-health boost (below 25%) now only works for wielder, no longer increases mana regen or armor
- **Bot impact:** `item_purchase_generic.lua` pos_5 builds, hero sBuyList

**Khanda** [REWORKED]
- OLD: Phylactery + Tiara of Selemene + Recipe(1200) = 5600g
- NEW: Phylactery + Soul Booster = 5600g (same cost)
- Stats: 8 all stats, 450 HP, 7 HP regen, 450 Mana, 3 Mana regen
- 7.40c: Can now be disassembled
- **Bot impact:** `item_purchase_generic.lua`, hero sBuyList

**Refresher Orb** [REWORKED]
- OLD: Cornucopia + Ring of Tarrasque + Tiara of Selemene + Recipe(200) = 5000g; 18 HP regen, 8 Mana regen, +10 dmg
- NEW: Ring of Tarrasque + Tiara of Selemene + Recipe(1600) = 5000g; 12 HP regen, 6 Mana regen, no dmg
- **Bot impact:** `item_purchase_generic.lua`, hero sBuyList

**Heart of Tarrasque** [REWORKED]
- Ring of Tarrasque: 1800 -> 1700g; Total: 5200 -> 5100g
- Max health as HP regen: 1.4% -> 1%
- NEW passive: Behemoth's Blood (1.5% missing HP as regen, non-stacking)
- **Bot impact:** `item_purchase_generic.lua`

**Holy Locket** [REWORKED]
- Requires Crown(450) instead of Diadem(1000); Recipe: 800 -> 1340; Total remains 2250g
- All attributes: 9 -> 7
- Energy Charge: cast range 500->600, restore time 8->10, max charges 20->25, mana per charge 17->15
- NEW: applies 10% heal amp for 4s
- **Bot impact:** `item_purchase_generic.lua`

**Radiance**
- Evasion: 15% -> 25%
- No longer applies 15% blind on enemies
- No longer deals 1.5x damage to illusions
- Can now toggle while invisible without breaking invis
- **Bot impact:** `item_purchase_generic.lua`, illusion-based hero builds

**Veil of Discord**
- Recipe changed: now Chainmail(550) + Circlet(155) + Ring of Health(700) + Recipe(320) = 1725g (same cost)
- HP regen: 4 -> 4.5
- No longer builds from Helm of Iron Will or Crown
- **Bot impact:** `item_purchase_generic.lua`

### Significant Changes

**Bloodstone**: Spell lifesteal 20% -> 25%; Bloodpact multiplier 4 -> 3; Voodoo Mask 700 -> 650g (total 4400 -> 4350)

**Boots of Bearing**: Now requires Ring of Tarrasque(1700) instead of Recipe(1700); HP regen 15 -> 18; same total cost 4225g

**Clarity**: Initial/max stock 4 -> 5; Cost 50 -> 60g

**Crimson Guard**: Guard debuff no longer dispelable

**Diffusal Blade**: Manabreak NO LONGER works for illusions; Inhibit cannot target invulnerable
- **Bot impact:** MAJOR -- PL, Naga, Meepo illusion builds affected

**Disperser**: Suppress applies basic dispel on enemies, cannot target invulnerable; Manabreak no longer works for illusions

**Ghost Scepter**: Magic res reduction 40% -> 30%

**Giant's Maul**: Crushing Blow crit 150% -> 140%

**Glimmer Cape**: Shadow Amulet 1000 -> 900g; Recipe 350 -> 450g; same total 2150g

**Hand of Midas**: Transmute NO LONGER multiplies XP by 2.1; Charge time 110 -> 90s
- **Bot impact:** MAJOR -- Midas builds significantly weaker

**Healing Salve**: Initial/max stock 4 -> 5; Duration no longer halved on allies; HP regen halved to 15 on allies

**Heaven's Halberd**: Disarm only dispelled by strong dispels (not basic); Duration 3.5/4.5 -> 3; CD 18 -> 20

**Helm of the Dominator**: Dominate now grants 50% of creep XP/gold (was 100%)

**Iron Branch**: Cost 50 -> 55g

**Silver Edge**: Shadow Amulet 1000->900g (total 5800->5700g); Shadow Walk now caps target move speed at 200; 7.40b: debuff duration 6->5s

**Smoke of Deceit**: Can now be used directly from backpack (no 6s penalty)

### 7.40b Item Changes

**Mask of Madness**: Berserk now shows Silenced overhead icon

**Spirit Vessel / Urn of Shadows**: Only one gains charges if player owns multiples; Vessel prevents Urn from gaining charges; allies' separate urns still independent

### 7.40c Item Changes

**Phylactery**: All attributes 7 -> 6; Mana regen 2.5 -> 2.25

---

## 4. NEUTRAL ITEM CHANGES

### New Items (7.40)
- **Ash Legion Shield** (details TBD)
- **Flayer's Bota** (details TBD)
- **Idol of Scree'Auk** (details TBD)

### Removed/Cycled Out (7.40)
- **Brigand's Blade** - cycled out
- **Gale Guard** - cycled out
- **Helm of the Undying** - cycled out

### Tier Changes
- **Defiant Shell**: Re-added as Tier 2; removed 7 all stats and 6 armor; Reciprocity triggers on attack initiation (not landing), 80% return damage (was 100%), no longer works on buildings, now works on wards
- **Duelist Gloves**: Re-added as Tier 1; removed 12 attack damage
- **Dezun Bloodrite**: Moved Tier 4 -> Tier 5; Blood Invocation AoE bonus 12% -> 15%

### Stat Changes
- **Jidi Pollen Bag**: Max HP damage 12% -> 9%; Duration 12 -> 9; CD 45 -> 25

---

## 5. HERO CHANGES (Final State after 7.40c, grouped by impact level)

### MAJOR REWORKS (entirely new ability kits)

**Largo** [NEW HERO - added 7.40, added to CM in 7.40c]
- Melee Strength support hero (frog bard)
- Abilities: Frogstomp (36/48/60/72 dmg after 7.40c), Catchy Lick (235-325 pull after 7.40b), Croak of Genius, Amphibian Rhapsody (ult, rhythm-game mechanic with 3 songs: spell amp, move speed, healing; 800 radius after 7.40c)
- Int gain: 2.6 (after 7.40c)
- Amphibian Rhapsody toggling unaffected by silence (7.40c)
- **Bot impact:** Need NEW `BotLib/hero_largo.lua` file

**Lone Druid** [MAJOR REWORK]
- Spirit Bear is now innate ability (slot 4), available from level 1
- NEW ability: Entangle (slot 1) - 700 range, 20/19/18/17s CD, 60 mana; applies debuff counter, at 5 stacks: 1.2/1.6/2/2.4s root + 90 DPS
- Spirit Link reworked: removed attack speed/shared armor; now grants 10/20/30/40 move speed + lifesteal healing to bear
- Bear Demolish: magic res 33% -> 0%; building damage 10/20/30/40% -> 30%
- True Form: removed Entangling Claws/Demolish grants; +50/90/130 attack dmg; armor 8/10/12 -> 10/15/20; duration 40->25; CD 100->60/55/50; mana 200->80
- Removed facets: Bear with Me, Bear Necessities; Removed innate: Gift Bearer
- Base attack damage 18-22 -> 22-26; Move speed 325 -> 295
- 7.40c: Base agi 20->22; Savage Roar duration 0.8/1.2/1.6/2 -> 1.1/1.4/1.7/2; LVL25 True Form slow resist +60%->+70%
- **Bot impact:** `BotLib/hero_lone_druid.lua` -- FULL REWRITE needed

**Slark** [MAJOR REWORK]
- Removed facets: Dark Reef Renegade, Leeching Leash
- Essence Shift is now innate (was ability); duration `15 + 2.5*(HeroLvl-1)`
- Pounce now applies 1/2/3/4 stacks of Essence Shift
- NEW: Saltwater Shiv (slot 3) - autocast attack modifier; FINAL values (7.40c): steals 2/4/6/8 move speed, 2/4/6/8 HP regen, 2/4/6/8% HP restoration per attack; Duration 12s all levels (7.40b); CD 10/8/6/4
- Shadow Dance merged with Barracuda: 24/36/48% move speed + 60/90/120 HP regen when not visible
- Shard: Depth Shroud duration 3 -> 2s
- **Bot impact:** `BotLib/hero_slark.lua` -- FULL REWRITE needed

**Spectre** [MAJOR REWORK]
- Changed from Universal -> Agility hero
- Base attack: 21-25 -> 23-27; BAT 1.7 -> 1.8; Attack speed 90 -> 110
- Desolate is now innate: `25 + 2*(HeroLVL-1)` (was 25/40/55/70)
- Shadow Step reworked: creates single-target illusion at visible enemy; basic ability (slot 2); Cast range 750/900/1050/1200 (7.40b); Illusion damage 32/38/44/50% (7.40b); CD 30/26/22/18 (7.40b)
- Dispersion min radius 300 -> 350; Damage reflected/reduced: 8/12/16/20% (7.40b)
- Haunt: now ultimate; illusion damage 30/55/80%; duration 5/6/7; CD 180/160/140
- Reality: now Haunt sub-ability; deals 100% current HP damage to targeted illusion; mana 40->25
- Removed: Spectral innate, Forsaken/Twist the Knife facets
- Aghs: reduces Haunt CD by 20 + applies fear
- 7.40b: base agi 25+2.1 -> 26+2.4
- 7.40c: str gain 2.5->2.4; LVL20 HP +350->+325; LVL25 Desolate illusion dmg +20%->+15%
- Talents: LVL10 +12 Desolate dmg (7.40b); LVL15 +1s Shadow Step duration; LVL25 +15% Desolate illusion dmg (7.40c)
- **Bot impact:** `BotLib/hero_spectre.lua` -- FULL REWRITE needed

**Treant Protector** [MAJOR REWORK]
- Removed facets: Primeval Power, Sapling
- Nature's Guise: added active invis with 0s fade delay, 2s linger; CD formula `50 - (3*(HeroLvl-1)/2)` -> simplified to `35 - 1*HeroLvl` (7.40b); 0 mana
- Nature's Grasp: removed 1.5 tree contact dmg factor; DPS 30/40/50/60 -> 35/50/65/80; creep factor 0.5 -> 0.35; slow 20/25/30/35% -> 25/30/35/40%
- Leech Seed REWORKED: now attack modifier; 20/40/60/80 magic dmg + 0.9/1.1/1.3/1.5s root; heals 5 allies within 650 for `15/25/35/45 + 20% atk dmg`; CD 15/12/9/6
- Living Armor REWORKED: removed armor bonus; 120 dmg negation (7.40b, was 100); 35/30/25/20 reduction per instance; heal/s 4/7/10/13; duration 12s; CD 24/21/18/15 (7.40b)
- Aghs REWORKED: Overgrowth CD -25 (7.40b); grants 2x str, phase movement, 300-radius 60% splash, 345 absolute move speed; undispellable
- Shard REWORKED: Eyes In The Forest; range 160->350; mana 100->30; duration indefinite->600s; restore time 40->55; Treant Eyes HP 1->2; attackable with True Sight
- 7.40b: Base armor 0->1
- 7.40c: Eyes gold bounty set to 50g
- **Bot impact:** `BotLib/hero_treant.lua` -- FULL REWRITE needed

**Brewmaster** [SIGNIFICANT REWORK]
- Int gain 1.6 -> 1.9; Str gain 3.7 -> 3.2
- NEW innate: Liquid Courage -- triggers below 50% HP; grants `10.5% + 0.5%*HeroLvl` status resist; alternating 0-25% move speed bonus/0-10% slow per second
- Thunder Clap: cast point 0.35->0.3; radius standardized to 375 (was 325/350/375/400); mana 100 all levels (was 90/100/110/120); 7.40b: radius 375->400
- Cinder Brew: targeting Area -> Area/Point; now rolls barrel toward target direction dealing 40/70/100/130 physical dmg; cast range 700->950
- Drunken Brawler: Void Stance REMOVED; cycle now Earth->Storm->Fire->Earth; Fire AS 10/15/20/25 -> 10/20/30/40; Earth magic resist 5/10/15/20% -> 8/12/16/20%; NOW grants 1.5x stance effects when casting Thunder Clap/Cinder Brew; toggle unaffected by silence (7.40b); buff duration +1 -> +2 (7.40b)
- 7.40b: Earth Stance grants 80% slow resistance
- 7.40c: Earth Stance armor 2/4/6/8 -> 3/5/7/9; Aghs Shard Liquid Courage active HP regen 2% -> 2.5%
- Primal Split: max level 3->4; duration 16/20/24/24; all Brewlings get Drunken Brawler stances; Void Brewling REMOVED
- 7.40b: base str 23->24; Liquid Courage max move speed 25%->30%
- **Bot impact:** `BotLib/hero_brewmaster.lua` -- MAJOR REWRITE needed

**Clinkz** [SIGNIFICANT REWORK]
- Removed facets: Suppressive Fire, Engulfing Step
- NEW: Infernal Shred -- 3% armor piercing per stack (7.40b, was 2%), max 20%
- Skeleton Archers moved from Bone and Arrow to Skeleton Walk; duration 20/25/30
- Removed: Bone and Arrow, Tar Bomb
- NEW Searing Arrows: 20/35/50/65 dmg (7.40b); multishot scaling
- Death Pact no longer creates Skeleton Archers
- Strafe: applies buff to all Skeleton Archers created while active (7.40b); AS 120/160/200/240 (7.40b)
- 7.40b: base str 17->18; LVL15 changed to -10s Death Pact restore time
- 7.40c: Skeleton Archer building damage factor 0.75->0.25; Aghs no longer increases Archer hit count by 1; LVL15 attack range +60->+50; LVL25 Searing Arrows multishot no longer applies to Skeleton Archers
- **Bot impact:** `BotLib/hero_clinkz.lua` -- MAJOR REWRITE needed

### MODERATE CHANGES (significant number adjustments or mechanic tweaks)

**Abaddon**
- 7.40b: LVL10 Aphotic Shield HP regen +10 -> +8
- 7.40c: Curse of Avernus no longer applied by illusions
- **Bot impact:** `BotLib/hero_abaddon.lua`

**Axe**
- 7.40: Battle Hunger now deals pure damage, no longer slows creeps
- 7.40b: LVL15 Battle Hunger DPS +12 -> +10
- 7.40c: Str gain 2.8->2.7; LVL15 Battle Hunger DPS +10->+8
- **Bot impact:** `BotLib/hero_axe.lua`

**Batrider**
- 7.40b: Flamebreak mana 110/115/120/125 -> 110 all levels
- 7.40c: Agi gain 1.8 -> 2
- **Bot impact:** `BotLib/hero_batrider.lua`

**Beastmaster**
- 7.40b: Agi gain 1.9->2.0; Wild Axes amp per stack 6/8/10/12% -> 7/9/11/13%
- **Bot impact:** `BotLib/hero_beastmaster.lua`

**Bloodseeker**
- 7.40c: Bloodrage self dmg 1.4%->1.2% max HP/s; LVL10 HP +175->+200; LVL20 Agi +20->+15; LVL20 Rupture range +425->+400
- **Bot impact:** `BotLib/hero_bloodseeker.lua`

**Bristleback**
- 7.40b: Viscous Nasal Goo base slow 10%->12%
- **Bot impact:** `BotLib/hero_bristleback.lua`

**Broodmother**
- 7.40b: LVL15 Incap Bite dmg +10->+8; LVL20 Incap Bite slow/miss +25%->+20%; LVL25 Spin Web speed +14%->+7%; LVL25 Insatiable Hunger BAT -0.25->-0.2
- 7.40c: Spin Web charges 4/6/8/10->3/5/7/9; Necrotic Webs HP restoration reduction 10/30/50/70%->10/25/40/55%; Incap Bite no longer applied by illusions; LVL15 Incap Bite dmg +8->+6; LVL25 Insatiable Hunger BAT -0.2->-0.15
- **Bot impact:** `BotLib/hero_broodmother.lua`

**Centaur Warrunner**
- 7.40b: Base MS 305->300; Aghs Work Horse duration 7->6s; LVL15 Str +12->+10
- **Bot impact:** `BotLib/hero_centaur.lua`

**Dazzle**
- 7.40b: Poison Touch first slow 16-22%->13-22%; LVL20 Shallow Grave CD -4s->-3s
- **Bot impact:** `BotLib/hero_dazzle.lua`

**Death Prophet**
- 7.40b: Exorcism spirits 10/17/24 -> 10/18/26; LVL20 Spirit Siphon dmg/heal +25->+30
- **Bot impact:** `BotLib/hero_death_prophet.lua`

**Doom**
- 7.40b: Str gain 3.5->3.6
- 7.40c: Infernal Blade mana 40->35
- **Bot impact:** `BotLib/hero_doom_bringer.lua`

**Drow Ranger**
- 7.40b: Agi gain 2.9->2.8; Sidestep facet self slow 25%->35%; Aghs Shard Glacier CD 20->25; LVL10 Frost Arrows mana x0.75->x0.82
- 7.40c: LVL25 Marksmanship proc +10%->+8%
- **Bot impact:** `BotLib/hero_drow_ranger.lua`

**Earthshaker**
- 7.40c: Fissure mana 120/125/130/135 -> 115/120/125/130
- **Bot impact:** `BotLib/hero_earthshaker.lua`

**Ember Spirit**
- 7.40c: Searing Chains dmg 50/70/90/110 -> 100 all levels; duration 1.5/2/2.5/3 -> 1.25/1.75/2.25/2.75
- **Bot impact:** `BotLib/hero_ember_spirit.lua`

**Enigma**
- 7.40b: Aghs Black Hole outer radius 1200->1000
- **Bot impact:** `BotLib/hero_enigma.lua`

**Faceless Void**
- 7.40b: Base agi 21->24; Base attack 37-43 -> 34-40
- **Bot impact:** `BotLib/hero_faceless_void.lua`

**Grimstroke**
- 7.40c: Base attack 21-25 -> 22-26; Ink Swell range 500/600/700/800 -> 650/700/750/800; LVL15 Ink Swell MS +12%->+15%
- **Bot impact:** `BotLib/hero_grimstroke.lua`

**Huskar**
- 7.40b: Berserker's Blood max HP threshold 12%->10%; Cauterize facet max HP heal per debuff 5%->4%; LVL15 Lifesteal +15%->+12%; LVL25 Life Break dmg +25%->+22%
- 7.40c: Cauterize CD 50/40/30/20 -> 60/50/40/30
- **Bot impact:** `BotLib/hero_huskar.lua`

**Invoker**
- 7.40b: Aghs Tornado twister duration 3.2-5.0 -> 2.7-4.5; Aghs Shard EMP mana burn to dmg 90%->80%
- **Bot impact:** `BotLib/hero_invoker.lua`

**Jakiro**
- 7.40b: Liquid Fire base DPS 20-50 -> 15-45; Liquid Frost first dmg 15-30 -> 8-32
- 7.40c: Base int 26->25; Ice Path duration 3/3.5/4/4.5 -> 2.6/3.1/3.6/4.1
- **Bot impact:** `BotLib/hero_jakiro.lua`

**Juggernaut**
- 7.40b: Healing Ward duration 25 -> 18-24 scaled; Omnislash attack rate divisor 1.5->1.4; LVL25 Blade Dance lifesteal +50%->+40%
- **Bot impact:** `BotLib/hero_juggernaut.lua`

**Kez**
- 7.40b: Switch Discipline toggle unaffected by silence; Katana BAT 1.8->1.9; Katana main dmg per agi 1.12->1.16; Falcon Rush instant attack factor 0.35-0.5 -> 0.3-0.45; Buildings no longer valid Falcon Rush targets; LVL20 Falcon Rush AS +60->+40
- **Bot impact:** `BotLib/hero_kez.lua`

**Kunkka**
- 7.40b: LVL25 Tidebringer cleave +120%->+130%
- **Bot impact:** `BotLib/hero_kunkka.lua`

**Legion Commander**
- 7.40b: Press the Attack MS 10-22%->13-22%; mana 100->90; Spoils of War facet duration on victory 2.5->1.25s; Aghs Duel duration bonus 2->1.5
- 7.40c: Aghs Duel duration bonus 1.5->1
- **Bot impact:** `BotLib/hero_legion_commander.lua`

**Lich**
- 7.40b: Agi gain 2.0->1.7
- **Bot impact:** `BotLib/hero_lich.lua`

**Marci**
- 7.40b: Str gain 3.0->3.2; Rebound radius 275->300; Unleash CD 90/75/60 -> 80/70/60; LVL10 Rebound landing radius +75->+50
- **Bot impact:** `BotLib/hero_marci.lua`

**Mars**
- 7.40b: Base agi 20->18; LVL15 God's Rebuke CD -2s->-2.5s; LVL20 Spear of Mars stun +0.4s->+0.5s
- **Bot impact:** `BotLib/hero_mars.lua`

**Meepo**
- 7.40b: Aghs MegaMeepo Poof dmg factor 1->0.75; Aghs Shard Dig cast point 0->0.3; LVL25 Poof cast point -1s->-0.75s
- 7.40c: Aghs MegaMeepo Poof dmg factor 0.75->0.5; LVL10 Poof dmg +50->+40; LVL20 Ransack HP steal +8->+7
- **Bot impact:** `BotLib/hero_meepo.lua`

**Monkey King**
- 7.40b: Wukong's Command duration 13->14; Aghs Soldier duration 12->15
- 7.40c: Jingu Mastery dmg 30/75/120/165 -> 30/80/130/180; LVL10 Primal Spring max dmg +85->+90
- **Bot impact:** `BotLib/hero_monkey_king.lua`

**Morphling**
- 7.40b: Base armor -2 -> -1
- **Bot impact:** `BotLib/hero_morphling.lua`

**Nature's Prophet**
- 7.40c: Treant attack damage 14-18/22-26/30-34/38-42 -> 14-18/23-27/32-36/41-45
- **Bot impact:** `BotLib/hero_furion.lua`

**Necrophos**
- 7.40b: Ghost Shroud HP restoration factor 1.45/1.55/1.65/1.75 -> 1.55/1.6/1.65/1.7
- **Bot impact:** `BotLib/hero_necrolyte.lua`

**Omniknight**
- 7.40b: Repel base str bonus 7/14/21/28 -> 6/12/18/24
- **Bot impact:** `BotLib/hero_omniknight.lua`

**Outworld Destroyer**
- 7.40b: Sanity's Eclipse illusion dmg factor 2->1; Aghs Essence Flux barrier duration 15->12
- **Bot impact:** `BotLib/hero_obsidian_destroyer.lua`

**Pangolier**
- 7.40b: Int gain 2.2->2.5; Base MS 295->300; Swashbuckle range 400-700->575-800; slash range 700->850; dmg 30-120->35-125; Shield Crash CD 16-7->15-6; Rolling Thunder magic resist 60%->80%; base dmg 75-225->100-300; roll duration 9-11->10-12; Aghs Shard Roll Up magic resist 60%->80%
- 7.40c: Base str 19->20; Fortune Favors the Bold proc 40%->50%; Swashbuckle CD 20/17/14/11->19/16/13/10
- **Bot impact:** `BotLib/hero_pangolier.lua`

**Phantom Assassin**
- 7.40b: Aghs Fan of Knives now affects debuff immune enemies; LVL10 Phantom Strike duration +0.5s->+0.6s
- 7.40c: LVL10 Stifling Dagger CD -1.5s->-2s
- **Bot impact:** `BotLib/hero_phantom_assassin.lua`

**Phantom Lancer**
- 7.40b: Spirit Lance dmg 70/140/210/280 -> 100/170/240/280 (rescaled); Phantom Rush toggle unaffected by silence
- 7.40c: Illusory Armaments min illusion dmg 18%->17%; Doppelganger mana 50->70
- **Bot impact:** `BotLib/hero_phantom_lancer.lua`

**Phoenix**
- 7.40: Sun Ray DPS 14/20/26/32 -> 15/20/25/30; current HP cost 6%->5%; LVL15 HP regen +20->+25; LVL25 changed to x1.7 Icarus Dive range/damage
- 7.40b: LVL25 confirmed as x1.7 Icarus Dive range/damage (was +1000 Icarus Dive range)
- **Bot impact:** `BotLib/hero_phoenix.lua`

**Primal Beast**
- 7.40b: Onslaught stun 0.8/1.0/1.2/1.4 -> 0.7/1.0/1.3/1.6; LVL15 changed from Uproar dispels to +6 Uproar armor/stack; LVL20 changed from +7 Uproar armor/stack to Uproar dispels
- **Bot impact:** `BotLib/hero_primal_beast.lua`

**Pudge**
- 7.40b: Meat Hook mana 110->120; Dismember Fresh Meat facet self str bonus 2-6->2-4
- 7.40c: Meat Shield mana 50/60/70/80 -> 65/70/75/80
- **Bot impact:** `BotLib/hero_pudge.lua`

**Pugna**
- 7.40b: Life Drain mana 100/130/170/200 -> 115/130/145/205 (rescaled); LVL15 HP +300->+250
- **Bot impact:** `BotLib/hero_pugna.lua`

**Riki**
- 7.40b: Tricks of the Trade dmg 30/50/70/90 -> 25/50/75/100
- **Bot impact:** `BotLib/hero_riki.lua`

**Ringmaster**
- 7.40b: LVL10 Impalement Arts first dmg +75->+85
- 7.40c: Base agi 13+1.4 -> 11+1.6; Whoopee Cushion radius 200->250
- **Bot impact:** `BotLib/hero_ringmaster.lua`

**Rubick**
- 7.40c: Telekinesis CD 23/20/17/14 -> 22/19/16/13
- **Bot impact:** `BotLib/hero_rubick.lua`

**Shadow Demon**
- 7.40b: Disseminate cast range 700/775/850/1000 -> 700/775/850/925; LVL10 Str +10->+8
- 7.40c: Promulgate set HP gain/loss 9/11/13/15% -> 9/10/11/12%
- **Bot impact:** `BotLib/hero_shadow_demon.lua`

**Shadow Fiend**
- 7.40b: Necromastery max stacks 20 -> 20/22/24/26; Requiem magic resist reduction 5/10/15% -> 10% all levels; Aghs no longer increases Necromastery stacks by 5
- **Bot impact:** `BotLib/hero_nevermore.lua`

**Silencer**
- 7.40b: LVL10 AS +20->+25
- **Bot impact:** `BotLib/hero_silencer.lua`

**Slardar**
- 7.40c: Str gain 3.6->3.4; LVL15 HP +300->+275
- **Bot impact:** `BotLib/hero_slardar.lua`

**Terrorblade**
- 7.40b: Base agi 22->23; Metamorphosis CD 155/150/145/140 -> 145/140/135/130; LVL15 Meta CD -20s->-10s
- 7.40c: Conjure Image mana 55/65/75/85 -> 50/60/70/80; Sunder CD 120/80/40 -> 110/75/40; Aghs Shard Demon Zeal no longer affects Reflection illusions; LVL15 Reflection slow/illusion dmg +10%->+15%
- **Bot impact:** `BotLib/hero_terrorblade.lua`

**Tidehunter**
- 7.40b: Krill Eater str gain 4.1->3.9; Aghs Shard Dead in the Water: no longer deals 100 dmg on impact; LVL10 Anchor Smash dmg reduction +20%->+10%; LVL20 Blubber Anchor Smash proc 100%->50%
- 7.40c: Base str 27->26
- **Bot impact:** `BotLib/hero_tidehunter.lua`

**Timbersaw**
- 7.40b: Whirling Death base dmg 85/130/175/220 -> 75/120/165/210; debuff duration 12/13/14/15 -> 11/12/13/14; Aghs Reactive Armor radius 600->450
- 7.40c: Base str+gain 26+3.5 -> 23+3.6; LVL15 Whirling Death attr reduction +2.5%->+2%
- **Bot impact:** `BotLib/hero_shredder.lua`

**Tiny**
- 7.40b: Tree Grab area dmg factor 0.55/0.7/0.85/1.0 -> 0.7/0.8/0.9/1.0
- **Bot impact:** `BotLib/hero_tiny.lua`

**Troll Warlord**
- 7.40b: Battle Stance toggle unaffected by silence
- **Bot impact:** `BotLib/hero_troll_warlord.lua`

**Underlord**
- 7.40b: LVL15 Firestorm CD -3s->-4s
- **Bot impact:** `BotLib/hero_abyssal_underlord.lua`

**Ursa**
- 7.40: Enrage CD 70/50/30 -> 60/45/30; Aghs Shard reworked: now applies 2 Fury Swipes stacks in radius on Earthshock; LVL20 changed
- 7.40b: Bear Down debuff duration factor 1.14/1.16/1.18/1.2 -> 1.5 all levels; LVL15/LVL20 talents swapped (Fury Swipes <-> Maul)
- 7.40c: Fury Swipes dmg per stack 13/21/29/37 -> 12/20/28/36
- **Bot impact:** `BotLib/hero_ursa.lua`

**Viper**
- 7.40: Poison Attack mana 22->20; Caustic Bath max ability power duration 4->5s; LVL20 Predator dmg +0.2->+0.25
- 7.40b: Caustic Bath max ability factor 1->0.75; LVL10 changed to x1.1 Poison Attack dmg/slow; LVL15 replaced with +20 Corrosive Skin DPS (was at LVL10); LVL15 Nethertoxin DPS +40->+30
- 7.40c: Corrosive Skin dmg 8/16/24/32 -> 10/15/20/25; LVL20 Predator +0.25->+0.3; LVL20 Viper Strike DPS +80->+70
- **Bot impact:** `BotLib/hero_viper.lua`

**Void Spirit**
- 7.40: Aghs Resonant Pulse silence 2s->1.75s; LVL15 Aether Remnant dmg +60->+65
- 7.40b: Aether Remnant duration 20->17
- **Bot impact:** `BotLib/hero_void_spirit.lua`

**Warlock**
- 7.40: Chaotic Offering CD 160->165; LVL15 Upheaval ally AS 10->8; LVL20 changed to +25% Golem incoming dmg reduction; LVL25 changed to +3 Fatal Bonds bounces
- 7.40b: Minor Imp Eldritch Explosion dmg 25/70/115/160/205 -> 20/65/110/155/200; LVL20 Upheaval DPS +40->+45; LVL25 Fatal Bonds bounces +3->+4
- **Bot impact:** `BotLib/hero_warlock.lua`

**Windranger**
- 7.40: Agi gain 1.9->2.1; Aghs Shard Gale Force duration 3.5->3
- 7.40b: Shackleshot Tangled facet bonus dmg per hero 40->35; Powershot slow duration 4s->3s; Windrun physical dmg reduction 45%->35%
- **Bot impact:** `BotLib/hero_windrunner.lua`

**Winter Wyvern**
- 7.40: Base attack 15-22 -> 16-23; Attack range 425->450; Arctic Burn range bonus 275/300/325/350 -> 250/275/300/325; LVL25 Winter's Curse AS +55->+60
- 7.40b: LVL10 Cold Embrace heal/s +25->+20; LVL15 Splinter Blast shatter radius +300->+250; LVL25 Splinter Blast stun +1.25s->+1s
- **Bot impact:** `BotLib/hero_winter_wyvern.lua`

**Witch Doctor**
- 7.40: Voodoo Restoration activation mana 35/40/45/50->25 all; mana/s 8/12/16/20->9/12/15/18; Maledict affects player creeps; Malpractice facet added; Aghs Death Ward bounce radius 650->575; LVL15 changed to +4s Maledict duration; LVL25 changed to -6s Paralyzing Cask CD
- 7.40b: Death Ward dmg 60/95/130->60/90/120; Cleft Death facet dmg 55/90/125->55/85/115; LVL25 Death Ward dmg +45->+40
- **Bot impact:** `BotLib/hero_witch_doctor.lua`

**Wraith King**
- 7.40: Wraithfire Blast first dmg 75/90/105/120->80/100/120/140; LVL15 HP +400->+350; LVL20 AS +60->+50
- 7.40b: Bone Guard Skeleton MS 350->340
- **Bot impact:** `BotLib/hero_skeleton_king.lua`

**Zeus**
- 7.40: Arc Lightning bounces 5/7/9/15->5/7/9/11; LVL25 Static Field +1.5%->+2%
- 7.40b: Static Field dmg 2.5/3/3.5/4% -> 2.5/3.25/4/4.75%
- **Bot impact:** `BotLib/hero_zuus.lua`

### MINOR CHANGES (toggle-only or QoL)

**Muerta**: 7.40b - Gunslinger toggle unaffected by silence
**Phantom Lancer**: 7.40b - Phantom Rush toggle unaffected by silence (also has number changes above)
**Troll Warlord**: 7.40b - Battle Stance toggle unaffected by silence (listed above)
**Kez**: 7.40b - Switch Discipline toggle unaffected by silence (also has number changes above)
**Brewmaster**: 7.40b - Drunken Brawler toggle unaffected by silence (also has changes above)

### UNCHANGED HEROES (confirmed)
Ancient Apparition, Disruptor (7.40 only -- may have changes in b/c)

---

## 6. TOP 10 MOST IMPACTFUL CHANGES FOR BOT AI

1. **Talent system overhaul** -- Talents use separate talent points, not skill points. EVERY hero's leveling logic must update.
2. **Diffusal Blade illusion manabreak removed** -- Destroys PL/Naga/Meepo illusion builds. Must update item builds.
3. **5 heroes with FULL ability reworks** -- Lone Druid, Slark, Spectre, Treant Protector, Brewmaster need complete BotLib rewrites.
4. **2 heroes with significant reworks** -- Clinkz, also Largo (new hero) need new/rewritten BotLib files.
5. **Ethereal Blade rework** -- New recipe (Ultimate Orb + Ghost Scepter), different damage formula. Morphling/Lina/etc builds change.
6. **Guardian Greaves cost reduction** -- 5050g -> 4300g, recipe change. All pos_5 item builds should update.
7. **Hand of Midas XP multiplier removed** -- Midas no longer gives 2.1x XP. Much weaker item for bot farm logic.
8. **Map terrain changes** -- Wisdom Shrine lowered, camps reclassified, new defender's gates. Pathing and farm routes affected.
9. **Assist gold formula reworked** -- Lower base gold, different distribution. Affects kill priority calculations.
10. **Heart of Tarrasque reworked** -- New Behemoth's Blood passive, lower base regen. Tank item calculations change.

---

## 7. CHANGE COUNTS BY CATEGORY

| Category | Count |
|-|-|
| General/Mechanic changes | ~12 |
| Map/Terrain changes | ~15 |
| Item changes (regular) | ~30+ |
| Neutral item changes | ~10 |
| Hero full reworks | 5 (LD, Slark, Spectre, Treant, Brewmaster) |
| Hero significant reworks | 2 (Clinkz, + Largo new) |
| Hero moderate changes | ~55 heroes |
| Hero minor/QoL changes | ~5 |
| Total hero changes across all patches | ~65+ heroes affected |

---

## 8. DATA QUALITY NOTES

- **Liquipedia** was the primary source for exact numbers. The 7.40 base page was too large to fetch completely (truncated during item section), so individual item/hero changelogs were used to fill gaps.
- **Official dota2.com** patch pages use JavaScript rendering and could not be scraped directly.
- **Some 7.40 base hero changes may be incomplete** -- the Liquipedia 7.40 page hero section could not be fully fetched. Individual hero changelogs were checked for the most important heroes.
- **7.40b and 7.40c** data is comprehensive from Liquipedia.
- **New neutral items** (Ash Legion Shield, Flayer's Bota, Idol of Scree'Auk) -- specific stats not captured; need in-game verification.
- **Some heroes may have 7.40 changes not captured** -- heroes that appeared in Liquipedia's "nerfed/buffed" lists but whose specific changes were in the truncated portion.

Sources:
- https://liquipedia.net/dota2/Version_7.40
- https://liquipedia.net/dota2/Version_7.40b
- https://liquipedia.net/dota2/Version_7.40c
- Individual hero/item changelogs on Liquipedia
- https://www.gosugamers.net/dota2/news/77766
- https://hawk.live/posts/quick-overview-of-patch-740
- https://rdy.gg/en/dota2/news/dota-2-patch-7-40-reshapes-the-game
