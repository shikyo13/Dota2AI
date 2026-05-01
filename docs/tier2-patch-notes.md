# Patch Notes (Bot-Relevant)

Consult when editing `BotLib/hero_*.lua` or item builds in `sBuyList`/`sSellList`.
Each entry shows what changed and which bot config it affects.

> **#1 impact:** Talents no longer consume skill points. Dedicated talent points at levels 10/15/20/25/27-30. Every hero's leveling logic in `ability_item_usage_generic.lua` and `jmz_func.lua` must update.

---

## 7.40c (2026-01-21)

### Hero Changes
- **Largo**: Added to Captain's Mode. Frogstomp 36/48/60/72 dmg, int gain 2.6, ult 800 radius, toggle unaffected by silence -> needs NEW `BotLib/hero_largo.lua`
- **Axe**: Str gain 2.8->2.7; LVL15 Battle Hunger DPS +10->+8 -> `hero_axe.lua` talents
- **Bloodseeker**: Bloodrage self dmg 1.4%->1.2%; LVL20 Agi +20->+15; Rupture range +425->+400 -> `hero_bloodseeker.lua`
- **Broodmother**: Spin Web charges 4/6/8/10->3/5/7/9; Necrotic Webs reduction 10/30/50/70%->10/25/40/55%; Incap Bite no longer from illusions -> `hero_broodmother.lua`
- **Ember Spirit**: Searing Chains dmg 50/70/90/110->100 all; duration 1.5/2/2.5/3->1.25/1.75/2.25/2.75 -> `hero_ember_spirit.lua`
- **Grimstroke**: Ink Swell range rescaled 500-800->650-800; LVL15 MS +12%->+15% -> `hero_grimstroke.lua`
- **Huskar**: Cauterize CD 50/40/30/20->60/50/40/30 -> `hero_huskar.lua`
- **Jakiro**: Base int 26->25; Ice Path duration 3/3.5/4/4.5->2.6/3.1/3.6/4.1 -> `hero_jakiro.lua`
- **Legion Commander**: Aghs Duel duration bonus 2->1 -> `hero_legion_commander.lua`
- **Meepo**: Aghs MegaMeepo Poof factor 1->0.5; LVL10 Poof dmg +50->+40 -> `hero_meepo.lua`
- **Monkey King**: Jingu Mastery dmg rescaled up; LVL10 Primal Spring +85->+90 -> `hero_monkey_king.lua`
- **Pangolier**: Base str 19->20; Fortune Favors proc 40%->50%; Swashbuckle CD -1 all levels -> `hero_pangolier.lua`
- **Phantom Lancer**: Illusory Armaments min illusion dmg 18%->17%; Doppelganger mana 50->70 -> `hero_phantom_lancer.lua`
- **Pudge**: Meat Shield mana 50/60/70/80->65/70/75/80 -> `hero_pudge.lua`
- **Rubick**: Telekinesis CD -1 all levels -> `hero_rubick.lua`
- **Shadow Demon**: Promulgate HP gain/loss 9/11/13/15%->9/10/11/12% -> `hero_shadow_demon.lua`
- **Slardar**: Str gain 3.6->3.4; LVL15 HP +300->+275 -> `hero_slardar.lua`
- **Spectre**: Str gain 2.5->2.4; LVL20 HP +350->+325; LVL25 Desolate illusion dmg +20%->+15% -> `hero_spectre.lua`
- **Terrorblade**: Conjure Image mana -5 all; Sunder CD 120/80/40->110/75/40; LVL15 Reflection +10%->+15% -> `hero_terrorblade.lua`
- **Tidehunter**: Base str 27->26 -> `hero_tidehunter.lua`
- **Timbersaw**: Base str+gain 26+3.5->23+3.6; LVL15 Whirling Death attr reduction +2.5%->+2% -> `hero_shredder.lua`
- **Treant Protector**: Eyes gold bounty 50g -> `hero_treant.lua`
- **Ursa**: Fury Swipes dmg per stack -1 all levels -> `hero_ursa.lua`
- **Viper**: Corrosive Skin dmg rescaled; LVL20 Predator +0.25->+0.3; Viper Strike DPS +80->+70 -> `hero_viper.lua`
- **Abaddon**: Curse of Avernus no longer applied by illusions -> `hero_abaddon.lua`
- **Clinkz**: Skeleton Archer building dmg 0.75->0.25; LVL15 range +60->+50; LVL25 multishot no longer on Archers -> `hero_clinkz.lua`
- **Brewmaster**: Earth Stance armor 2/4/6/8->3/5/7/9; Shard Liquid Courage regen 2%->2.5% -> `hero_brewmaster.lua`
- **Drow Ranger**: LVL25 Marksmanship proc +10%->+8% -> `hero_drow_ranger.lua`
- **Lone Druid**: Base agi 20->22; Savage Roar rescaled; LVL25 True Form slow resist +60%->+70% -> `hero_lone_druid.lua`
- **Slark**: Saltwater Shiv steals 2/4/6/8 MS/HP regen/HP restoration; duration 12s all -> `hero_slark.lua`
- **Nature's Prophet**: Treant attack dmg buffed across levels -> `hero_furion.lua`

### Item Changes
- **Phylactery**: All attributes 7->6; Mana regen 2.5->2.25 -> `item_purchase_generic.lua`
- **Khanda**: Can now be disassembled -> `item_purchase_generic.lua`

### Map / Mechanic Changes
- None exclusive to 7.40c (all mechanic changes were in 7.40/b).

---

## 7.40b (2025-12-23)
*(Only changes NOT superseded by 7.40c)*

### Hero Changes
- **Batrider**: Flamebreak mana standardized to 110 all levels -> `hero_batrider.lua`
- **Beastmaster**: Agi gain 1.9->2.0; Wild Axes amp +1% per stack -> `hero_beastmaster.lua`
- **Bristleback**: Viscous Nasal Goo base slow 10%->12% -> `hero_bristleback.lua`
- **Centaur Warrunner**: Base MS 305->300; Aghs Work Horse 7->6s; LVL15 Str +12->+10 -> `hero_centaur.lua`
- **Dazzle**: Poison Touch first slow 16-22%->13-22%; LVL20 Shallow Grave CD -4s->-3s -> `hero_dazzle.lua`
- **Death Prophet**: Exorcism spirits 10/17/24->10/18/26; LVL20 Spirit Siphon +25->+30 -> `hero_death_prophet.lua`
- **Doom**: Str gain 3.5->3.6 -> `hero_doom_bringer.lua`
- **Enigma**: Aghs Black Hole outer radius 1200->1000 -> `hero_enigma.lua`
- **Faceless Void**: Base agi 21->24; base attack 37-43->34-40 -> `hero_faceless_void.lua`
- **Invoker**: Aghs Tornado twister 3.2-5.0->2.7-4.5; EMP mana burn to dmg 90%->80% -> `hero_invoker.lua`
- **Juggernaut**: Healing Ward duration 25->18-24 scaled; Omnislash rate 1.5->1.4; LVL25 lifesteal +50%->+40% -> `hero_juggernaut.lua`
- **Kez**: Katana BAT 1.8->1.9; dmg/agi 1.12->1.16; Falcon Rush nerfed; no building targets -> `hero_kez.lua`
- **Kunkka**: LVL25 Tidebringer cleave +120%->+130% -> `hero_kunkka.lua`
- **Lich**: Agi gain 2.0->1.7 -> `hero_lich.lua`
- **Marci**: Str gain 3.0->3.2; Rebound radius 275->300; Unleash CD rescaled -> `hero_marci.lua`
- **Mars**: Base agi 20->18; LVL15 God's Rebuke CD -2s->-2.5s; LVL20 Spear stun +0.4s->+0.5s -> `hero_mars.lua`
- **Morphling**: Base armor -2->-1 -> `hero_morphling.lua`
- **Necrophos**: Ghost Shroud restoration rescaled -> `hero_necrolyte.lua`
- **Omniknight**: Repel base str bonus 7/14/21/28->6/12/18/24 -> `hero_omniknight.lua`
- **OD**: Sanity's Eclipse illusion factor 2->1; Essence Flux barrier 15->12 -> `hero_obsidian_destroyer.lua`
- **Phantom Assassin**: Aghs Fan of Knives affects debuff immune; LVL10 +0.5s->+0.6s -> `hero_phantom_assassin.lua`
- **Primal Beast**: Onslaught stun rescaled; LVL15/20 talents swapped -> `hero_primal_beast.lua`
- **Pugna**: Life Drain mana rescaled; LVL15 HP +300->+250 -> `hero_pugna.lua`
- **Riki**: Tricks of Trade dmg 30/50/70/90->25/50/75/100 -> `hero_riki.lua`
- **Ringmaster**: LVL10 Impalement Arts +75->+85 -> `hero_ringmaster.lua`
- **Shadow Fiend**: Necromastery max 20->20/22/24/26; Requiem reduction 5/10/15%->10% all -> `hero_nevermore.lua`
- **Silencer**: LVL10 AS +20->+25 -> `hero_silencer.lua`
- **Tiny**: Tree Grab area factor 0.55/0.7/0.85/1.0->0.7/0.8/0.9/1.0 -> `hero_tiny.lua`
- **Underlord**: LVL15 Firestorm CD -3s->-4s -> `hero_abyssal_underlord.lua`
- **Ursa**: Bear Down debuff 1.14-1.2->1.5 all; LVL15/20 talents swapped -> `hero_ursa.lua`
- **Void Spirit**: Aether Remnant duration 20->17 -> `hero_void_spirit.lua`
- **Warlock**: Minor Imp dmg -5 all; LVL20 Upheaval DPS +40->+45; LVL25 Fatal Bonds +3->+4 -> `hero_warlock.lua`
- **Windranger**: Shackleshot Tangled bonus 40->35; Powershot slow 4s->3s; Windrun phys reduction 45%->35% -> `hero_windrunner.lua`
- **Winter Wyvern**: LVL10 Cold Embrace +25->+20; LVL15 Splinter Blast radius +300->+250; LVL25 stun +1.25s->+1s -> `hero_winter_wyvern.lua`
- **Witch Doctor**: Death Ward dmg 60/95/130->60/90/120; Cleft Death 55/90/125->55/85/115; LVL25 +45->+40 -> `hero_witch_doctor.lua`
- **Wraith King**: Bone Guard Skeleton MS 350->340 -> `hero_skeleton_king.lua`
- **Toggle QoL (7.40b)**: Muerta Gunslinger, PL Phantom Rush, Troll Battle Stance, Kez Switch Discipline, Brewmaster Drunken Brawler toggles now unaffected by silence -> respective hero files

### Item Changes
- **Silver Edge**: Total 5800->5700g; debuff 6->5s; caps target MS at 200 -> `item_purchase_generic.lua`
- **Mask of Madness**: Berserk shows Silenced overhead icon -> minor visual
- **Spirit Vessel / Urn**: Only one gains charges if player owns multiples -> `item_purchase_generic.lua`

---

## 7.40 (2025-12-15)
*(Only changes NOT superseded by 7.40b or 7.40c)*

### Hero Changes  -  Major Reworks (FULL REWRITE needed)
- **Largo**: New melee STR support hero. Frogstomp, Catchy Lick, Croak of Genius, Amphibian Rhapsody (rhythm ult) -> NEW `BotLib/hero_largo.lua`
- **Lone Druid**: Spirit Bear now innate; NEW Entangle (slot 1, stacking root); Spirit Link reworked (MS + lifesteal); True Form reworked (dmg/armor, shorter CD); base MS 325->295 -> FULL REWRITE `hero_lone_druid.lua`
- **Slark**: Essence Shift now innate; Pounce applies stacks; NEW Saltwater Shiv (attack modifier stealing MS/regen); Shadow Dance merged with Barracuda -> FULL REWRITE `hero_slark.lua`
- **Spectre**: Universal->Agility; Desolate now innate scaling; NEW Shadow Step (single-target illusion); Haunt now ultimate; Reality as sub-ability -> FULL REWRITE `hero_spectre.lua`
- **Treant Protector**: Nature's Guise active invis added; Leech Seed now attack modifier with root; Living Armor reworked (dmg negation, no armor); Aghs/Shard reworked -> FULL REWRITE `hero_treant.lua`
- **Brewmaster**: NEW innate Liquid Courage (sub-50% HP status resist + MS); Cinder Brew now rolling barrel; Drunken Brawler: Void Stance removed, cycle changed, stance amplification; Primal Split: 4 levels, no Void Brewling -> MAJOR REWRITE `hero_brewmaster.lua`
- **Clinkz**: Skeleton Archers moved to Skeleton Walk; NEW Searing Arrows; Removed Bone and Arrow/Tar Bomb; Strafe buffs Archers -> MAJOR REWRITE `hero_clinkz.lua`

### Hero Changes  -  Moderate
- **Phoenix**: Sun Ray DPS rescaled; HP cost 6%->5%; LVL25 changed to x1.7 Icarus Dive range/dmg -> `hero_phoenix.lua`
- **Viper**: Poison Attack mana 22->20; Caustic Bath max duration 4->5s -> `hero_viper.lua`
- **Void Spirit**: Aghs silence 2s->1.75s; LVL15 Aether Remnant +60->+65 -> `hero_void_spirit.lua`
- **Warlock**: Chaotic Offering CD 160->165; LVL15 Upheaval AS 10->8; LVL20/25 changed -> `hero_warlock.lua`
- **Windranger**: Agi gain 1.9->2.1; Shard Gale Force 3.5->3s -> `hero_windrunner.lua`
- **Winter Wyvern**: Base attack +1; range 425->450; Arctic Burn range -25 all levels -> `hero_winter_wyvern.lua`
- **Witch Doctor**: Voodoo Restoration mana rescaled; Maledict affects player creeps; Aghs bounce radius 650->575; talents changed -> `hero_witch_doctor.lua`
- **Wraith King**: Wraithfire Blast dmg rescaled up; LVL15 HP +400->+350; LVL20 AS +60->+50 -> `hero_skeleton_king.lua`
- **Zeus**: Arc Lightning bounces 5/7/9/15->5/7/9/11 -> `hero_zuus.lua`
- **Ursa**: Enrage CD 70/50/30->60/45/30; Shard reworked (2 Fury Swipes stacks on Earthshock) -> `hero_ursa.lua`
- **Axe**: Battle Hunger now deals pure damage, no longer slows creeps -> `hero_axe.lua`

### Item Changes
- **Ethereal Blade** [REWORKED]: Now Ultimate Orb + Ghost Scepter + Recipe(900) = 5200g; 24 all stats; damage = 50 + 100% all attributes; magic res -30% -> all Ethereal Blade builders
- **Guardian Greaves** [REWORKED]: No Buckler; total 5050->4300g; low-HP boost wielder-only -> pos_5 builds
- **Khanda** [REWORKED]: Now Phylactery + Soul Booster = 5600g; 450 HP, 450 Mana -> hero sBuyList
- **Refresher Orb** [REWORKED]: No Cornucopia; 12 HP regen, 6 Mana regen, no damage -> hero sBuyList
- **Heart of Tarrasque** [REWORKED]: Total 5200->5100g; regen 1.4%->1%; NEW Behemoth's Blood (1.5% missing HP regen) -> tank builds
- **Holy Locket** [REWORKED]: Crown(450) replaces Diadem(1000); recipe adjusted; NEW 10% heal amp for 4s -> support builds
- **Radiance**: Evasion 15%->25%; blind removed; no longer 1.5x dmg to illusions -> illusion hero builds
- **Veil of Discord**: New recipe (Chainmail + Circlet + Ring of Health); HP regen 4->4.5 -> `item_purchase_generic.lua`
- **Diffusal Blade**: Manabreak NO LONGER works for illusions -> **MAJOR**: PL, Naga, Meepo builds
- **Disperser**: Manabreak no longer for illusions; Suppress basic dispels enemies -> illusion builds
- **Hand of Midas**: NO LONGER multiplies XP by 2.1; charge time 110->90s -> **MAJOR**: Midas builds much weaker
- **Ghost Scepter**: Magic res reduction 40%->30% -> targeting/survivability logic
- **Heaven's Halberd**: Disarm only removed by strong dispels; duration 3.5/4.5->3; CD 18->20 -> `ability_item_usage_generic.lua`
- **Healing Salve**: Stock 4->5; duration no longer halved on allies; regen halved to 15 on allies -> courier/laning
- **Clarity**: Stock 4->5; cost 50->60g -> starting items
- **Iron Branch**: Cost 50->55g -> starting items
- **Smoke of Deceit**: Can be used directly from backpack -> `ability_item_usage_generic.lua`
- **Bloodstone**: Spell lifesteal 20%->25%; Bloodpact 4->3; total 4400->4350 -> caster builds
- **Boots of Bearing**: Now uses Ring of Tarrasque; HP regen 15->18 -> support builds
- **Crimson Guard**: Guard debuff no longer dispelable -> teamfight logic
- **Helm of Dominator**: Dominate grants 50% creep XP/gold (was 100%) -> farm builds
- **Glimmer Cape**: Shadow Amulet 1000->900g; recipe 350->450g -> support builds
- **Giant's Maul**: Crushing Blow crit 150%->140% -> carry builds

### Neutral Item Changes
- **New**: Ash Legion Shield, Flayer's Bota, Idol of Scree'Auk (stats TBD)
- **Removed**: Brigand's Blade, Gale Guard, Helm of the Undying
- **Defiant Shell**: Re-added Tier 2; 80% return dmg, no longer works on buildings
- **Duelist Gloves**: Re-added Tier 1; removed 12 attack damage
- **Dezun Bloodrite**: Tier 4->5; Blood Invocation AoE 12%->15%
- **Jidi Pollen Bag**: Max HP dmg 12%->9%; duration 12->9; CD 45->25

### Map / Mechanic Changes
- **Talent system**: Talents no longer consume skill points. Dedicated points at 10/15/20/25/27-30 -> `ability_item_usage_generic.lua`, all hero leveling
- **Assist gold**: Reworked formula lowers base, different split -> `aba_strategy.lua` kill priority
- **Courier**: Respawn `60+6*LVL`->`45+5*LVL`; no consumable slow penalty -> `mode_courier_generic.lua`
- **Roshan**: Treated as creep for lifesteal; Slam 2x damage (not slow); disarm undispelable -> `mode_roshan_generic.lua`
- **Illusions**: All have 800/400 day/night vision -> `jmz_func.lua`
- **Invulnerability targeting**: Most abilities/items can no longer target invulnerable units (Dark Seer, Naga, Oracle, Sniper, Sven, VS + Nullifier, Diffusal, Disperser) -> targeting logic
- **Base terrain**: New defender's gates; hard camp near T3 demoted to medium; safelane camp repositioned -> `mode_laning_generic.lua`
- **Wisdom Shrine**: Lowered to low ground, moved closer to T1 towers -> `mode_rune_generic.lua`
- **Jungle**: Triangle hard camp demoted to medium; primary Watchers moved to bounty rune cliffs -> `mode_farm_generic.lua`
- **Neutral creeps**: Satyr Purge can't target invulnerable; Mana Burn multiplier nerfed -> `jmz_func.lua`
