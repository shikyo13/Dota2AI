# Quick Reference

Loaded every session. Dense, high-signal. Consult before any edit.

---

## Dependency Graph

### Engine Entry Points
| File | Requires |
|------|----------|
| `hero_selection.lua` | aba_global_overrides, aba_role, utils, captain_mode, custom_loader, aba_hero_pos_weights, localization, aba_team_names, FretBots/matchups_data, FretBots/HeroNames |
| `bot_generic.lua` | utils, BotLib/hero_* (via dofile) |
| `item_purchase_generic.lua` | jmz_func, aba_item, aba_role, utils, BotLib/hero_* (via require) |
| `ability_item_usage_generic.lua` | jmz_func, utils, localization, Customize/general, BotLib/hero_* (via dofile) |
| `mode_defend_tower_*` | jmz_func, aba_defend |
| `mode_push_tower_*` | aba_push (which loads jmz_func internally) |
| `mode_laning_generic` | utils, jmz_func |
| `mode_farm_generic` | jmz_func, utils, version, localization, Customize/general |
| `mode_rune_generic` | jmz_func, Customize/general |
| `mode_retreat_generic` | jmz_func, Customize/general |
| `mode_roshan_generic` | jmz_func, Customize/general |
| `mode_roam_generic` | jmz_func, Customize/general |
| `mode_ward_generic` | jmz_func, aba_ward_utility, Customize/general |
| `mode_secret_shop_generic` | jmz_func, Customize/general |
| `mode_attack_generic` | utils only (no jmz_func) |

### Core Hub: jmz_func.lua (eager-loads at require time)
`J.Site`=aba_site, `J.Item`=aba_item, `J.Buff`=aba_buff, `J.Role`=aba_role,
`J.Skill`=aba_skill, `J.Chat`=aba_chat, `J.Utils`=utils, `J.Customize`=custom_loader

### TypeScript-compiled modules (aba_push, aba_defend, aba_ward_utility)
These live in `FunLib/` but are compiled from `typescript/bots/`. They require `ts_libs/dota/index`
and `ts_libs/utils/native-operators`. Edit the `.ts` source, not the `.lua` output.

### Leaf Layer (no game-logic dependencies)
`ts_libs/dota/index`, `ts_libs/utils/json`, `localization`, `version`, `aba_buff`, `spell_list`

### BotLib/hero_*.lua (127 files, one per hero)
Each exports: `sSkillList`, `sTalentList`, `sBuyList`, `sSellList`, `sRandoItemList`, `MinionThink`,
plus `SkillsComplement` for hero-specific ability usage. Loaded by `bot_generic` (dofile),
`item_purchase_generic` (require), and `ability_item_usage_generic` (dofile).

### Customize Layer
- `Customize/general.lua` -- global settings (ThinkLess throttle, Enable flag, difficulty)
- `Customize/hero/*.lua` -- per-hero overrides loaded by `jmz_func.SetUserHeroInit()` via xpcall
- `FunLib/custom_loader.lua` -- safe loader wrapping `Customize/general` with defaults

---

## Lua Gotchas Checklist

### API Return Values
- `GetItemInSlot()` returns handle -- use `:GetName()`, never compare to string
- `FindItemSlot()` returns -1 when not found -- check `>= 0`, not truthy
- `GetNearbyHeroes()` can return nil -- nil-check before `#`
- `GetHeroLastSeenInfo()` returns array -- access via `[1].time_since_seen`
- `GetMostRecentPing()` returns `.location` as Vector, not `.location_x`
- `GetToggleState()` can return nil -- check nil explicitly before boolean logic
- `GetTeamMember()` can return nil -- always nil-check before calling methods
- `GetUnitToLocationDistance()` uses pathing, not straight line -- can be much larger than expected

### Lua Language Traps
- `#array >= 0` is ALWAYS true -- use `>= 1` for non-empty check
- `not x == false` parses as `(not x) == false` -- use explicit parens
- `x ~= "a" or x ~= "b"` is ALWAYS true (tautology) -- use `and`
- `Vector(100 200)` silently subtracts -- always use comma: `Vector(100, 200)`
- `nil` in arrays breaks `#` -- length stops at first nil hole
- String concat with nil crashes -- always `tostring()` or nil-guard before `..`
- `pairs()` order is non-deterministic -- don't rely on iteration order

### Bot Framework Rules
- `DotaTime()` is negative pre-game -- guard modulo operations with `> 0` check
- Use `BOT_MODE_DESIRE_*` in `GetDesire()`, never `BOT_ACTION_DESIRE_*` (different scales)
- Desire values must be 0.0-1.0 -- never exceed 1.0, never negative
- Guard division: check `coreCount`, `manaRegen`, etc. are non-zero before dividing
- Cache `GetNearbyHeroes()` -- don't call multiple times per frame
- Check `IsChanneling()`, `IsUsingAbility()`, `IsCastingAbility()` before pushing actions
- `GetBot()` at file scope runs once at load -- don't assume bot is alive/valid at that point
- `dofile()` re-executes every time; `require()` caches -- know which entry points use which
- Role constants: `1`=carry, `2`=mid, `3`=offlane, `4`=soft support, `5`=hard support
- Item names use internal names: `"item_blink"` not `"Blink Dagger"` -- check wiki for exact strings
- `bot:GetActiveMode()` returns engine mode constant, not custom mode name
- Ability `GetLevel()` returns 0 if not skilled -- always check before computing damage/cooldown

---

## 7.40 Breaking Changes (Bot-Relevant Top 10)

1. **Talent system overhaul**: Talents use dedicated talent points at levels 10/15/20/25/27-30, no longer consume skill points. Every hero's `sSkillList` leveling logic in `ability_item_usage_generic.lua` and the `AbilityLevelUpComplement()` function must update.
2. **5 heroes fully reworked**: Lone Druid (True Form -> stance system), Slark (Dark Pact replaced by Saltwater Shiv), Spectre (Spectral Dagger reworked), Treant Protector (new Eyes in the Forest), Brewmaster (stance-based rework). Their `BotLib/hero_*.lua` files need complete rewrites.
3. **Clinkz significant rework + Largo new hero**: Clinkz abilities replaced (Skeleton Archers, Bone Army, new ult). Largo is brand new hero added in 7.40. Both need new/rewritten BotLib files.
4. **Diffusal Blade illusion manabreak removed**: Illusion-based heroes (PL, Naga, Meepo, TB) lose core item synergy. Their `sBuyList` item builds must drop Diffusal or reprioritize.
5. **Ethereal Blade reworked**: New recipe (Kaya + Ghost Scepter + recipe), different damage formula and stats. All heroes buying it (Morphling, Tinker, etc.) need updated builds.
6. **Guardian Greaves cost 5050g -> 4300g**: No longer requires Buckler in recipe. Support item builds in `pos_4`/`pos_5` get earlier timing.
7. **Hand of Midas XP multiplier removed**: Much weaker item overall. Heroes that rushed Midas (Invoker, Arc Warden, Doom) need build updates -- likely remove from `sBuyList`.
8. **Map terrain changes**: Wisdom shrines added near ancients, neutral camp reclassifications (small/medium/large shuffled), defender's gates at base. Affects `aba_site.lua` farm spots and ward locations.
9. **Assist gold formula reworked**: Lower base assist gold, different distribution formula favoring supports less. Affects role priority and farm allocation logic in `aba_role.lua`.
10. **Heart of Tarrasque reworked**: Old % HP regen replaced by Behemoth's Blood passive (flat HP regen + damage reduction when low). Tank item evaluation logic changes.

---

## Anti-Patterns

- Don't duplicate engine API -- use `GetHeroLastSeenInfo()`, `GetRawOffensivePower()`, `GetEstimatedDamageToTarget()`, `GetNearbyHeroes()` directly
- Don't batch multiple mode file edits -- test one at a time in-game
- Don't push actions every frame -- check `IsChanneling()`/`IsUsingAbility()`/`IsCastingAbility()` first
- Don't build centralized desire smoothing -- apply per-mode as needed
- New modules must NOT circular-require `jmz_func` -- use lazy-load pattern (`pcall(require)`)
- Guard every bot handle and `GetTeamMember()` return with nil checks
- Desire returns must be 0.0-1.0 range -- `BOT_MODE_DESIRE_*` not `BOT_ACTION_DESIRE_*`
- Every change must be testable in isolation in-game before making the next change
- Avoid modifying upstream files unnecessarily -- makes future upstream merges painful
- Don't use em-dashes or Chinese characters in Lua files -- the Edit tool cannot match them
- Don't edit compiled `.lua` files in `FunLib/` that come from TypeScript -- edit the `.ts` source instead
- Don't add `print()` calls in hot paths (per-frame Think functions) -- use throttled logging only
- Don't assume hero ability slots are stable across patches -- always look up by name with `GetAbilityByName()`
- Don't create global variables -- always use `local`; globals pollute the shared Lua VM across all bots
- Don't trust `GetLevel()` alone for item timing -- check `DotaTime()` as well for game-phase logic
- Don't forget: all 10 bots share one Lua VM -- a crash in one hero's script kills all bots
