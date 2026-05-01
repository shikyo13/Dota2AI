# Dota 2 Bot Scripting: The Definitive Guide

## Section Index

Use `Read` tool with `offset` and `limit` to load specific sections only.

| # | Topic | Lines |
|-|-|-|
| 1 | Environment Setup | 39-85 |
| 2 | Architecture: Three-Tier Hierarchy | 86-123 |
| 3 | File Naming & Override System | 124-226 |
| 4 | Team-Level Desires | 227-259 |
| 5 | Hero Selection & Lane Assignment | 260-305 |
| 6 | Desire System & Oscillation Prevention | 306-451 |
| 7 | Action Stack Management | 452-546 |
| 8 | Item Builds | 547-627 |
| 9 | Ability Builds & Combat Usage | 628-745 |
| 10 | Inter-Bot Coordination | 746-826 |
| 11 | Movement & Pathfinding | 827-896 |
| 12 | External Infrastructure & ML | 897-908 |
| 13 | Bot Difficulties | 909-928 |
| 14 | Hero Power & Potential Locations | 929-953 |
| 15 | Complete API Reference | 954-1151 |
| 16 | Constants Reference | 1152-1250 |
| 17 | Common Pitfalls | 1251-1284 |
| 18 | Advanced AI Architectures | 1285-1304 |
| 19 | Essential Resources | 1305-1318 |

---

Bot scripting in Dota 2 uses a server-side Lua 5.1 sandbox embedded in the game engine. Scripts query the game state and issue orders directly to units  -  no screen reading, pixel scraping, or mouse simulation. The API respects fog of war (units in FoW can't be queried) and prevents cheating (you can't issue commands to units you don't control). Bots have full access to all entity locations, cooldowns, mana values, and other data that a player on that team would have.

This guide consolidates the official Valve Developer Community documentation, the full API reference, architectural best practices, and hard-won lessons from community projects like Open Hyper AI, Ranked Matchmaking AI, Nostrademous Full Overwrite, and VUL-FT into a single reference.

> **Important platform limitation:** The bot scripting API has not received meaningful updates from Valve since approximately October 2017. It remains functional and well-supported for custom games and lobbies, but new hero abilities and items added after that date may lack dedicated API support. Workshop delivery has become unreliable for some recent scripts  -  manual installation to `vscripts/bots/` is often necessary. The API itself is stable and the community is active.

---

## 1. Environment Setup

### 1.1 Directory Structure

All custom bot scripts reside in a specific directory within the Dota 2 installation:

- **Windows:** `C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts\bots\`
- **Mac:** `/Users/<username>/Library/Application Support/Steam/SteamApps/common/dota 2 beta/game/dota/scripts/vscripts/bots/`
- **Linux:** `~/.local/share/Steam/steamapps/common/dota 2 beta/game/dota/scripts/vscripts/bots/`

The directory **must** be named exactly `bots`. A `bots_example` directory ships with Dota 2  -  copy and rename it to get started. Workshop-downloaded bots install to `steamapps/workshop/content/570/<workshop_id>/`. Game data files for reference live in `game/dota/scripts/npc/`:

- `npc_abilities.txt`  -  All abilities and their parameters
- `npc_heroes.txt`  -  All heroes
- `npc_units.txt`  -  All non-hero units

**Pro tip:** Developers frequently use symbolic links (`mklink` on Windows, `ln -s` on macOS/Linux) to mirror a local Git repository directly into the Steam application folder, ensuring version control commits are immediately reflected in-game without manual file transfers.

### 1.2 Testing and Debugging Setup

1. Add `-console` and optionally `-condebug` to Dota 2's Steam launch options.
2. Create a lobby: Play Dota → Create Lobby → Edit Settings.
3. Set bot teams to **"Local Dev Script"** and server to **"Local Host"**.
4. Enable Cheats (required for testing commands, not just game manipulation).
5. Join as player, coach, or unassigned and start the match.

### 1.3 Essential Console Commands

- `dota_bot_reload_scripts` / `script_reload_code`  -  Reload scripts without restarting the client (the single most critical development command). Flushes Lua memory and recompiles all files.
- `host_timescale 4.0`  -  Accelerate game simulation to 4× speed (requires `sv_cheats 1`). Invaluable for testing late-game logic.
- `dota_bot_debug_team 2` (Radiant) or `3` (Dire)  -  Real-time panel showing team desires, bot modes, desire values, active actions, targets, power levels, and per-bot execution time.
- `dota_bot_select_debug`  -  For the under-cursor bot: white line-sphere for pathfinding, blue for last-hit target, red for attack target.
- `dota_bot_select_debug_attack`  -  Shows how much the under-cursor bot wants to attack nearby enemies.
- `dota_bot_debug_lanes`  -  Visualizes lane paths and "lane front" positions.
- `dota_bot_debug_ward_locations`  -  Shows yellow spheres at ward locations bots consider.
- `dota_bot_debug_grid` / `dota_bot_debug_minimap`  -  Grid overlays (cycle with `*_cycle` variants): 0=Off, 1=Radiant avoidance, 2=Dire avoidance, 3/4=Potential enemy locations, 5/6=Enemy visibility, 7=Height values, 8=Passability.
- `dota_bot_debug_clear`  -  Clears debug visualizations for the under-cursor bot.
- `dump_modifier_list`  -  Dumps a reference list of all modifier names.

Use `print()` for console logging. For visual debugging, the API provides `DebugDrawLine()`, `DebugDrawCircle()`, and `DebugDrawText()` to render directly in the game world.

### 1.4 Uploading to the Workshop

Scripts can be uploaded via the Workshop Tools DLC. Enable it in the DLC section of Dota 2 in Steam, then launch "Launch Dota 2 - Tools." The workshop tools have a section for uploading bot scripts  -  it uploads the entire contents of your `scripts/bots` directory under a specific name and description. The description can be updated later but the title cannot.

---

## 2. Architecture: The Three-Tier Hierarchy

### 2.0 The Lua Sandbox

The Dota 2 engine runs bot scripts in a restricted Lua 5.1 environment. Key limitations:

- **No external C libraries**  -  you cannot `require` anything outside the game's built-in modules
- **No file I/O**  -  no reading or writing to disk (ensures Workshop scripts can't be malicious)
- **Single-threaded**  -  all bot logic for all bots runs on one thread
- **No standard `io`, `os`, or `debug` libraries**  -  only the built-in API functions and basic Lua (`string`, `table`, `math`)
- **Scope isolation**  -  each scripting file runs in its own scope (mode files for different bots can't directly access each other's locals)

These constraints ensure security but mean any complex computation (ML inference, heavy pathfinding, large data analysis) must be offloaded to external servers via HTTP (see Section 12).

Bot AI is organized into three evaluation levels that cascade from strategic to tactical to mechanical:

### 2.1 Team Level (Strategic Directives)

Code in `team_desires.lua` assesses the global, macroeconomic state of the match  -  comparative net worth, structure health, enemy positioning, objective status. It broadcasts floating-point desire values (0.0–1.0) for macro-objectives that individual bots can factor into their own decisions.

**Crucially, team-level desires are non-authoritative.** They cannot force any entity to move. They are strategic suggestions  -  broadcasting a 0.85 desire to push top lane doesn't command any bot to do it; each bot independently weighs that signal against its local context.

### 2.2 Mode Level (Individual Decision-Making)

Every bot continuously evaluates a set of possible behavioral modes. Approximately every 300ms, the engine calls `GetDesire()` on all registered modes. Each returns a float between 0.0 and 1.0. **The mode with the highest score becomes the active mode** and takes exclusive control of issuing actions.

When a transition occurs, `OnEnd()` fires on the outgoing mode (for cleanup), then `OnStart()` fires on the incoming mode (for initialization). The active mode's `Think()` runs every frame until a different mode scores higher.

### 2.3 Action Level (Physical Execution)

Actions are the granular commands that physically move the entity  -  movement, attacks, ability casts, item usage. They roughly correspond to mouse clicks or button presses a human player would execute. The active mode's `Think()` function is solely responsible for issuing these commands.

### 2.4 The Flow

Team level provides top-level strategic guidance → Each bot evaluates mode desires incorporating both team-level and local context → The highest-scoring mode becomes active → The active mode issues action-level commands every frame.

---

## 3. File Naming Conventions and Override System

The engine discovers scripts entirely by filename convention  -  no manifest is needed. The presence of specific filenames dictates what logic is overridden. Each scripting element has its own script scope. Any function not implemented falls back to the default C++ bot logic.

| File | Purpose | Scope | Frequency |
|-|-|-|-|
| `hero_selection.lua` | Hero picking, banning, lane assignment, bot names | Initialization | Drafting phase |
| `team_desires.lua` | Team-wide push/defend/farm/roam/Roshan desires | Macro-Strategy | Per frame |
| `bot_generic.lua` | Complete takeover of ALL bots | Absolute | Per frame |
| `bot_<heroname>.lua` | Complete takeover of a specific hero | Absolute | Per frame |
| `mode_<modename>_generic.lua` | Override a specific mode for all bots | State Machine | ~300ms / Per frame |
| `mode_<modename>_<heroname>.lua` | Override a mode for one specific hero | State Machine | ~300ms / Per frame |
| `ability_item_usage_generic.lua` | Ability/item/courier/buyback logic for all heroes | Micro-Execution | Per frame |
| `ability_item_usage_<heroname>.lua` | Hero-specific ability and item usage | Micro-Execution | Per frame |
| `item_purchase_generic.lua` | Item purchase logic for all heroes | Economy | Per frame |
| `item_purchase_<heroname>.lua` | Hero-specific item purchasing | Economy | Per frame |

Hero names use the internal identifier minus the `npc_dota_hero_` prefix (e.g., `bot_lina.lua`, `item_purchase_zuus.lua` for Zeus). **Hero-specific files always take priority** over `_generic` files.

### 3.1 Complete Takeover

If you create `bot_generic.lua` with a `Think()` function, the engine disables all underlying C++ behavioral logic for all bots. No team-level or mode-level thinking occurs. You are responsible for reading the game state, making decisions, and issuing every action command every frame. For a single hero, use `bot_<heroname>.lua` instead.

Bots that have been completely taken over still respect difficulty modifiers and still calculate their estimated damage.

This paradigm provides maximal flexibility  -  preferred by developers bridging to external ML frameworks  -  but requires enormous effort to rebuild basic survivability and navigation from scratch.

### 3.2 Mode Override (Partial Takeover)

The recommended starting point. You maintain the robust C++ AI foundation while injecting custom logic into specific behavioral states. Create files targeting specific modes (e.g., `mode_laning_generic.lua`, `mode_retreat_lina.lua`) and implement up to four functions:

```lua
function GetDesire()  -- Called every ~300ms. Return 0.0–1.0.
function OnStart()    -- Called when this mode becomes active.
function OnEnd()      -- Called when this mode yields to another.
function Think()      -- Called every frame while active. Issue actions here.
```

### 3.3 Hybrid Approach

VUL-FT pioneered a clever hybrid: use partial takeover during early phases (leveraging default rune behavior), then switch to full takeover by dynamically defining `bot_generic.Think()` at runtime for mid/late game where custom logic excels.

### 3.4 Valid Modes to Override

```
laning              attack              roam
retreat             secret_shop         side_shop
rune                push_tower_top      push_tower_mid
push_tower_bot      defend_tower_top    defend_tower_mid
defend_tower_bot    assemble            team_roam
farm                defend_ally         evasive_maneuvers
roshan              item                ward
```

### 3.5 Ability and Item Usage Override

In `ability_item_usage_generic.lua` (or hero-specific variant), implement any of:

```lua
AbilityUsageThink()     -- Ability casting decisions (per frame)
ItemUsageThink()        -- Item usage decisions (per frame)
CourierUsageThink()     -- Courier commands (per frame)
BuybackUsageThink()    -- Buyback decisions (per frame)
AbilityLevelUpThink()  -- Skill point allocation (per frame)
```

Any function not implemented falls back to the default C++ logic.

### 3.6 Item Purchasing Override

In `item_purchase_generic.lua` (or hero-specific variant):

```lua
ItemPurchaseThink()     -- Called every frame. Purchase items here.
```

### 3.7 Minion Control

Override `MinionThink(hMinionUnit)` in your hero file (e.g., `bot_beastmaster.lua`). Called once per frame for every minion (illusions, summoned units, dominated units  -  not couriers) under the bot's control. The unit handle is passed in, and you can issue the same action commands as on the main hero.

### 3.8 Chaining Hero-Specific to Generic Implementations

At the bottom of your generic mode file:

```lua
BotsInit = require("game/botsinit")
local MyModule = BotsInit.CreateGeneric()
MyModule.OnStart = OnStart
MyModule.OnEnd = OnEnd
MyModule.Think = Think
MyModule.GetDesire = GetDesire
return MyModule
```

In the hero-specific file:

```lua
mode_defend_ally_generic = dofile(GetScriptDirectory().."/mode_defend_ally_generic")
-- Now you can call: mode_defend_ally_generic.OnStart()
```

---

## 4. Team-Level Desires

Implement in `team_desires.lua`:

```lua
function TeamThink()                  -- Single think call for entire team (per frame)
function UpdatePushLaneDesires()      -- Returns 3 floats: top, mid, bot push desires
function UpdateDefendLaneDesires()    -- Returns 3 floats: top, mid, bot defend desires
function UpdateFarmLaneDesires()      -- Returns 3 floats: top, mid, bot farm desires
function UpdateRoamDesire()           -- Returns float + unit handle (gank target)
function UpdateRoshanDesire()         -- Returns float for Roshan desire
```

Individual mode `GetDesire()` functions read these via: `GetPushLaneDesire(nLane)`, `GetDefendLaneDesire(nLane)`, `GetFarmLaneDesire(nLane)`, `GetRoamDesire()`, `GetRoamTarget()`, `GetRoshanDesire()`.

Example:

```lua
function UpdatePushLaneDesires()
    local members = GetTeamPlayers(GetTeam())
    local aliveCount = 0
    for _, pid in pairs(members) do
        if IsHeroAlive(pid) then aliveCount = aliveCount + 1 end
    end
    if aliveCount >= 4 then
        return 0.2, 0.8, 0.2  -- Push mid with numbers advantage
    end
    return 0.3, 0.3, 0.3
end
```

---

## 5. Hero Selection and Lane Assignment

Implement in `hero_selection.lua`:

```lua
function Think()                    -- Called every frame during pick phase
function UpdateLaneAssignments()    -- Returns 10 PlayerID-Lane pairs
function GetBotNames()              -- Called once, returns table of player names
```

Example:

```lua
function Think()
    if GetTeam() == TEAM_RADIANT then
        SelectHero(0, "npc_dota_hero_juggernaut")
        SelectHero(1, "npc_dota_hero_lina")
        SelectHero(2, "npc_dota_hero_axe")
        SelectHero(3, "npc_dota_hero_crystal_maiden")
        SelectHero(4, "npc_dota_hero_drow_ranger")
    end
end

function UpdateLaneAssignments()
    return {
        [1] = LANE_BOT,   -- Carry safelane
        [2] = LANE_MID,   -- Mid
        [3] = LANE_TOP,   -- Offlane
        [4] = LANE_TOP,   -- Offlane support
        [5] = LANE_BOT,   -- Hard support
    }
end

function GetBotNames()
    return {"Alpha", "Bravo", "Charlie", "Delta", "Echo"}
end
```

`UpdateLaneAssignments()` continues being called approximately 15 seconds into `GAME_STATE_GAME_IN_PROGRESS`, allowing dynamic re-laning. Individual bots read their assignment via `GetAssignedLane()`.

**Critical:** Player IDs differ by setup. Normal lobbies with a human: Radiant is 0–4, Dire is 5–9. Pure bot-vs-bot: Radiant is 2–6, Dire is 7–11 (slots 0–1 reserved). Always use `GetTeamPlayers(GetTeam())` rather than hardcoding IDs.

For Captain's Mode: `CMBanHero(sHeroName)`, `CMPickHero(sHeroName)`, `IsInCMBanPhase()`, `IsInCMPickPhase()`, `SetCMCaptain(nPlayerID)`, `GetCMCaptain()`, `IsCMBannedHero(sHeroName)`, `IsCMPickedHero(nTeam, sHeroName)`, `GetCMPhaseTimeRemaining()`.

---

## 6. The Desire System: Preventing Oscillation

The desire system is the beating heart of Dota 2 bot AI  -  and its most dangerous pitfall. **Valve provides no built-in solution for oscillation.** Prevention is entirely the scripter's responsibility, and it is the single biggest factor separating usable bots from chaotic ones.

### 6.0 Understanding the Problem

Consider a bot evaluating `mode_attack` and `mode_retreat`. Based on distance to the enemy, `mode_attack` evaluates to 0.55. Based on current HP, `mode_retreat` evaluates to 0.54. Attack wins  -  the bot moves toward the enemy. But closing the distance causes it to take one hit, dropping HP slightly. Now `mode_retreat` spikes to 0.56. The engine instantly transitions to retreat. The bot turns around. By turning, it exits the enemy's attack range, takes no further damage, and the localized threat drops  -  retreat falls back to 0.54, attack wins again. The bot turns back. This repeats every few frames: the bot rapidly spins in place, executing neither an attack nor an escape, effectively paralyzed by conflicting logical weights.

This isn't a rare edge case  -  it's the *default outcome* of any naive desire system where competing modes occupy similar value ranges. You will encounter this in every mode transition that involves proximity-based calculations (which is nearly all of them).

### 6.1 Hysteresis (Essential)

Add a bonus to the currently active mode so it takes a meaningfully larger competing desire to trigger a switch:

```lua
local HYSTERESIS_BONUS = 0.1

function GetDesire()
    local npcBot = GetBot()
    local rawDesire = CalculateRawDesire(npcBot)
    if npcBot:GetActiveMode() == BOT_MODE_FARM then
        rawDesire = rawDesire + HYSTERESIS_BONUS
    end
    return Clamp(rawDesire, 0.0, 1.0)
end
```

With a 0.1 bonus, if farming is active at desire 0.5, another mode needs 0.6+ to take over. Applying the scenario above: attack is active and hysteresis inflates its score from 0.55 to 0.65. Even if the bot takes minor damage raising retreat's baseline to 0.56 or 0.60, no state change occurs  -  retreat must overcome not just the baseline attack desire but the accumulated momentum of the hysteresis buffer, requiring 0.66+ to force a switch. Once the bot commits, only a substantial shift in game state will break it out. This should be applied to **every** mode.

### 6.2 Minimum Commitment Timers

Refuse to yield a mode until a minimum duration elapses:

```lua
local modeStartTime = 0
local MIN_MODE_DURATION = 5.0

function OnStart()
    modeStartTime = DotaTime()
end

function GetDesire()
    local npcBot = GetBot()
    local rawDesire = CalculateRawDesire(npcBot)
    if npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID then
        local timeInMode = DotaTime() - modeStartTime
        if timeInMode < MIN_MODE_DURATION then
            rawDesire = rawDesire + 0.2  -- Strong commitment bonus
        end
    end
    return Clamp(rawDesire, 0.0, 1.0)
end
```

A 3–10 second window works for most modes. Retreat/evade should have shorter or no timers.

### 6.3 Exponential Smoothing

Apply an exponential moving average so desire values change gradually:

```lua
local smoothedDesire = 0.0
local SMOOTHING_FACTOR = 0.1  -- Lower = more smoothing

function GetDesire()
    local rawDesire = CalculateRawDesire()
    smoothedDesire = smoothedDesire + SMOOTHING_FACTOR * (rawDesire - smoothedDesire)
    return smoothedDesire
end
```

At factor 0.1, only 10% of each frame's change applies, preventing sudden jumps.

### 6.4 Asymmetric Rise and Fall Rates

Allow desire to increase faster than it decreases  -  engage quickly, disengage slowly:

```lua
local smoothedDesire = 0.0
local RISE_RATE = 0.3
local FALL_RATE = 0.05

function GetDesire()
    local rawDesire = CalculateRawDesire()
    if rawDesire > smoothedDesire then
        smoothedDesire = smoothedDesire + RISE_RATE * (rawDesire - smoothedDesire)
    else
        smoothedDesire = smoothedDesire + FALL_RATE * (rawDesire - smoothedDesire)
    end
    return smoothedDesire
end
```

### 6.5 Non-Linear Desire Scaling

Avoid purely linear correlations (e.g., `Desire = 1.0 - healthPercent`), which make bots too timid at 80% HP and not urgent enough at 20%. Use `RemapValClamped()`  -  the single most-used utility across community projects:

```lua
-- RemapValClamped(input, inMin, inMax, outMin, outMax)
-- At 10% HP → desire 1.0; at 50% HP → desire 0.0
local retreatDesire = RemapValClamped(healthPct, 0.1, 0.5, 1.0, 0.0)

-- 1 nearby ally → desire 0.2; 4 allies → desire 0.8
local pushDesire = RemapValClamped(allyCount, 1, 4, 0.2, 0.8)
```

### 6.6 Design Desire Ranges with Clear Separation

Structure ranges so modes don't constantly overlap:

- **Retreat/Evade:** 0.8–1.0 (critical survival  -  always wins)
- **Attack/Kill:** 0.6–0.85 (high-value kill opportunities)
- **Push Tower:** 0.4–0.7 (strategic objectives)
- **Farm:** 0.3–0.6 (economic activity)
- **Laning:** 0.2–0.5 (default early-game)
- **Ward/Rune:** 0.1–0.4 (opportunistic tasks)

### 6.7 Emergency Overrides

Use `BOT_MODE_DESIRE_ABSOLUTE` (1.0) for genuine emergencies:

```lua
function GetDesire()  -- retreat mode
    local npcBot = GetBot()
    local hp_pct = npcBot:GetHealth() / npcBot:GetMaxHealth()
    if hp_pct < 0.15 and npcBot:WasRecentlyDamagedByAnyHero(3.0) then
        return BOT_MODE_DESIRE_ABSOLUTE
    end
    return RemapValClamped(hp_pct, 0.15, 0.5, BOT_MODE_DESIRE_HIGH, BOT_MODE_DESIRE_NONE)
end
```

Conversely, disable problematic default modes by returning zero:

```lua
-- mode_ward_generic.lua (disable to prevent bots getting stuck)
function GetDesire() return BOT_MODE_DESIRE_NONE end
function Think() end
```

### 6.8 Contextual Suppression

Actively suppress conflicting desires based on spatial context. A bot should zero out `mode_farm` desire when `GetNearbyHeroes(1000, true, BOT_MODE_NONE)` returns multiple hostile entities, forcing a choice between attacking or retreating  -  never farming during a teamfight.

---

## 7. Action Stack Management

### 7.1 The Four Command Paradigms

| Prefix | Behavior | Stack Interaction | Use Case |
|-|-|-|-|
| `Action_*` | Clears queue, executes immediately | Replaces entire stack | Starting a new action chain |
| `ActionPush_*` | Preemptive | Pushes to top of stack, suspends current | Reactive abilities, evasive moves |
| `ActionQueue_*` | Sequential | Appends to bottom of stack | Multi-waypoint paths, combo chains |
| `ActionImmediate_*` | Instantaneous | Bypasses stack entirely | Purchases, chat, pings, level-ups |

### 7.2 Core Action Functions

**Movement:**
- `Action_MoveToLocation(vLocation)`  -  Pathfinding-aware movement
- `Action_MoveDirectly(vLocation)`  -  Straight-line, bypasses bot pathfinder (identical to right-click)
- `Action_MovePath(tWaypoints)`  -  Follow a specific path
- `Action_MoveToUnit(hUnit)`  -  Follow a unit continuously

**Combat:**
- `Action_AttackUnit(hUnit, bOnce)`  -  Attack a unit (`bOnce` = stop after one attack)
- `Action_AttackMove(vLocation)`  -  Attack-move to a location

**Abilities/Items:**
- `Action_UseAbility(hAbility)`  -  No-target ability or item
- `Action_UseAbilityOnEntity(hAbility, hTarget)`  -  Unit-targeted
- `Action_UseAbilityOnLocation(hAbility, vLocation)`  -  Ground-targeted
- `Action_UseAbilityOnTree(hAbility, iTree)`  -  Tree-targeted

**Pickup/Drop:**
- `Action_PickUpRune(nRune)`  -  Pick up rune at location
- `Action_PickUpItem(hItem)`  -  Pick up dropped item
- `Action_DropItem(hItem, vLocation)`  -  Drop item

**Other:**
- `Action_UseShrine(hShrine)`  -  Use a shrine
- `Action_Delay(fDelay)`  -  Delay for specified time
- `Action_ClearActions(bStop)`  -  Clear queue, return to idle

All of the above (except `ClearActions`) also exist with `ActionPush_` and `ActionQueue_` prefixes.

**Immediate actions (bypass stack):**
- `ActionImmediate_PurchaseItem(sItemName)`  -  Returns purchase result code
- `ActionImmediate_SellItem(hItem)`
- `ActionImmediate_DisassembleItem(hItem)`
- `ActionImmediate_SetItemCombineLock(hItem, bLocked)`
- `ActionImmediate_SwapItems(index1, index2)`  -  Slots 0–5 inventory, 6–8 backpack, 9–15 stash
- `ActionImmediate_Courier(hCourier, nAction)`
- `ActionImmediate_Buyback()`
- `ActionImmediate_Glyph()`
- `ActionImmediate_LevelAbility(sAbilityName)`
- `ActionImmediate_Chat(sMessage, bAllChat)`
- `ActionImmediate_Ping(fXCoord, fYCoord, bNormalPing)`

**Action queries:**
- `GetCurrentActionType()`  -  Type of the currently active action
- `NumQueuedActions()`  -  Number of queued actions
- `GetQueuedActionType(nAction)`  -  Type of a specific queued action

### 7.3 Preventing Action Blocking

The most common and debilitating bug in custom bot scripts is **action blocking**  -  the bot visually stutters in place, unable to complete any animation.

**Why it happens:** `Think()` runs every frame (~30 times per second). If your Think function issues `ActionPush_UseAbility(ability)` unconditionally, the bot starts frame 1 of its casting animation, then on the very next frame (33ms later) receives a *new* push command that restarts the animation from frame 1 again. This repeats 30 times per second  -  the bot is locked in the first frame of its cast animation forever, never reaching the frame where the projectile or effect actually fires. The entity appears frozen, perfectly still, unable to attack, cast, or even move.

The same problem occurs with movement commands: pushing `MoveToLocation` every frame causes the bot to recalculate and restart its movement every 33ms, resulting in jittery micro-stuttering instead of smooth pathing.

**The fix:** Always query entity state before issuing commands. Use `IsChanneling()`, `IsUsingAbility()`, and `IsCastingAbility()` as guards. When the bot is already executing an action, `return` immediately to let the current action complete:

```lua
function Think()
    local npcBot = GetBot()
    -- Don't interrupt channels or active casts
    if npcBot:IsChanneling() or npcBot:IsUsingAbility() then return end
    -- Also check if we're already mid-action and it's still valid
    if npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_IDLE
       and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_NONE then
        -- Consider whether the current action is still relevant before overriding
    end

    local ability = npcBot:GetAbilityByName("lina_laguna_blade")
    if ability and ability:IsFullyCastable() then
        local target = npcBot:GetTarget()
        if target and target:IsAlive() then
            npcBot:Action_UseAbilityOnEntity(ability, target)
            return  -- Stop processing to avoid pushing conflicting commands
        end
    end
end
```

If the action stack becomes corrupted or filled with obsolete commands (e.g., queued movement to a bounty rune that an enemy already picked up), call `Action_ClearActions(true)` to purge everything and return to idle, giving the mode logic a clean slate.

---

## 8. Item Builds

### 8.1 Sequential Purchase Pattern

```lua
local tableItemsToBuy = {
    "item_tango", "item_flask", "item_branches",
    "item_boots", "item_ogre_axe", "item_mithril_hammer",
    "item_recipe_black_king_bar",
}

function ItemPurchaseThink()
    local npcBot = GetBot()
    if not npcBot:IsHero() then return end  -- Guard against summoned units
    if #tableItemsToBuy == 0 then
        npcBot:SetNextItemPurchaseValue(0)
        return
    end
    local sNextItem = tableItemsToBuy[1]
    local nCost = GetItemCost(sNextItem)
    npcBot:SetNextItemPurchaseValue(nCost)  -- Tells framework what you're saving for
    if npcBot:GetGold() >= nCost then
        npcBot:ActionImmediate_PurchaseItem(sNextItem)
        table.remove(tableItemsToBuy, 1)
    end
end
```

`SetNextItemPurchaseValue()` influences the default secret shop mode's desire to walk there. Items are purchased as individual components plus recipes  -  the game auto-combines when all components are in inventory.

### 8.2 Conditional Item Builds

For adaptive purchasing, check game state and enemy composition to branch the build:

```lua
local earlyGame = { "item_tango", "item_flask", "item_branches", "item_boots" }
local coreBuild = {}
local lateGame = {}

function ItemPurchaseThink()
    local npcBot = GetBot()
    if not npcBot:IsHero() then return end

    -- Build the conditional portions once
    if #coreBuild == 0 then
        -- Check enemy magic damage threat
        local enemies = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
        local magicThreat = false
        for _, enemy in pairs(enemies) do
            if enemy:GetEstimatedDamageToTarget(true, npcBot, 3.0, DAMAGE_TYPE_MAGICAL) > 300 then
                magicThreat = true
                break
            end
        end

        if magicThreat then
            coreBuild = { "item_ogre_axe", "item_mithril_hammer", "item_recipe_black_king_bar" }
        else
            coreBuild = { "item_blade_of_alacrity", "item_blade_of_alacrity", "item_robe", "item_recipe_diffusal_blade" }
        end
    end

    -- Merge build phases
    local fullBuild = {}
    for _, v in ipairs(earlyGame) do table.insert(fullBuild, v) end
    for _, v in ipairs(coreBuild) do table.insert(fullBuild, v) end

    -- Standard sequential purchase from fullBuild...
end
```

### 8.3 Secret Shop Handling

When the next item requires the secret shop, the bot needs to physically walk there. Use `IsItemPurchasedFromSecretShop(sItemName)` to detect this and `GetShopLocation(GetTeam(), SHOP_SECRET)` for the location. If you're using mode override (not complete takeover), the default `BOT_MODE_SECRET_SHOP` handles this automatically when you set `SetNextItemPurchaseValue()`  -  it reads the next item cost and triggers the secret shop mode's desire.

Useful functions: `GetItemCost(sItemName)`, `IsItemPurchasedFromSecretShop(sItemName)`, `IsItemPurchasedFromSideShop(sItemName)`, `GetItemStockCount(sItemName)`, `ActionImmediate_SellItem(hItem)`, `ActionImmediate_SetItemCombineLock(hItem, bLocked)`.

> **Note:** For complete item name constants, see the Valve wiki: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Item_Names

---

## 9. Ability Builds and Combat Usage

### 9.1 Leveling Abilities

```lua
local abilityOrder = {
    "lina_dragon_slave",           -- Level 1
    "lina_light_strike_array",     -- Level 2
    "lina_dragon_slave",           -- Level 3
    "lina_fiery_soul",             -- Level 4
    "lina_dragon_slave",           -- Level 5
    "lina_laguna_blade",           -- Level 6
    "lina_dragon_slave",           -- Level 7
    "lina_light_strike_array",     -- Level 8
    "lina_light_strike_array",     -- Level 9
    "special_bonus_unique_lina_2", -- Level 10 (talent)
    "lina_light_strike_array",     -- Level 11
    "lina_laguna_blade",           -- Level 12
    "lina_fiery_soul",             -- Level 13
    "lina_fiery_soul",             -- Level 14
    "special_bonus_unique_lina_3", -- Level 15 (talent)
    "lina_fiery_soul",             -- Level 16
    "-",                           -- Level 17 (no skill point spent)
    "lina_laguna_blade",           -- Level 18
    "-",                           -- Level 19
    "special_bonus_unique_lina_1", -- Level 20 (talent)
    "-",                           -- Level 21
    "-",                           -- Level 22
    "-",                           -- Level 23
    "-",                           -- Level 24
    "special_bonus_unique_lina_4", -- Level 25 (talent)
}

function AbilityLevelUpThink()
    local npcBot = GetBot()
    if npcBot:GetAbilityPoints() < 1 then return end
    local level = npcBot:GetLevel()
    if level <= #abilityOrder then
        local name = abilityOrder[level]
        if name ~= "-" then
            npcBot:ActionImmediate_LevelAbility(name)
        end
    end
end
```

Talent internal names follow `special_bonus_unique_<heroname>` with `_2`, `_3`, `_4` suffixes at levels 10, 15, 20, and 25. Use `"-"` for levels where no point should be spent (levels 17, 19, 21–24). The exact talent names for each hero must be looked up in the game data files or ability reference.

> **Note:** For complete ability and talent name constants, see: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Ability_Names

### 9.2 Casting in Combat

```lua
function AbilityUsageThink()
    local npcBot = GetBot()
    if not npcBot:IsAlive() or npcBot:IsSilenced()
       or npcBot:IsStunned() or npcBot:IsChanneling() then
        return
    end

    local abilityQ = npcBot:GetAbilityByName("lina_dragon_slave")
    if abilityQ and abilityQ:IsFullyCastable() then
        local castRange = abilityQ:GetCastRange()
        local target = npcBot:GetTarget()

        if target and target:IsAlive() and not target:IsMagicImmune()
           and GetUnitToUnitDistance(npcBot, target) <= castRange then
            npcBot:Action_UseAbilityOnLocation(abilityQ, target:GetLocation())
            return
        end

        -- AoE farming optimization
        local radius = abilityQ:GetSpecialValueInt("radius") or 275
        local creeps = npcBot:GetNearbyCreeps(castRange + radius, true)
        if #creeps >= 3 then
            local aoe = npcBot:FindAoELocation(true, false,
                npcBot:GetLocation(), castRange, radius, 0, 0)
            if aoe.count >= 3 then
                npcBot:Action_UseAbilityOnLocation(abilityQ, aoe.targetloc)
            end
        end
    end
end
```

### 9.3 Kill Estimation

`GetEstimatedDamageToTarget(bCurrentlyAvailable, hTarget, fDuration, nDamageTypes)` calculates exact damage potential factoring in mana, cooldowns, and target defenses. When estimated damage exceeds the target's health, dump the full spell payload:

```lua
local myDamage = npcBot:GetEstimatedDamageToTarget(true, enemy, 3.0, DAMAGE_TYPE_ALL)
if myDamage > enemy:GetHealth() then
    npcBot:SetTarget(enemy)
    -- Execute kill combo
end
```

### 9.4 Combo Execution with Action Queuing

```lua
-- Earthshaker: Blink → Echo Slam → Fissure
function ExecuteCombo(npcBot, target)
    local blink   = npcBot:GetAbilityByName("item_blink")
    local echo    = npcBot:GetAbilityByName("earthshaker_echo_slam")
    local fissure = npcBot:GetAbilityByName("earthshaker_fissure")

    if blink and blink:IsFullyCastable() and echo and echo:IsFullyCastable() then
        npcBot:Action_UseAbilityOnLocation(blink, target:GetLocation())
        npcBot:ActionQueue_UseAbility(echo)
        if fissure and fissure:IsFullyCastable() then
            npcBot:ActionQueue_UseAbilityOnLocation(fissure, target:GetLocation())
        end
    end
end
```

---

## 10. Inter-Bot Coordination

### 10.1 Team Desires as Coordination Backbone

`team_desires.lua` runs once per team per frame and can read all five bots' states to make collective decisions.

### 10.2 Shared State via Lua Modules

Since each scripting element has its own scope, share state through `require()`-loaded modules:

```lua
-- shared_state.lua
local SharedState = {}
SharedState.gangTarget = nil
SharedState.pushLane = LANE_MID
return SharedState

-- In any bot script:
local shared = require(GetScriptDirectory().."/shared_state")
shared.gangTarget = someEnemy  -- Bot A sets target
-- Bot B reads:
if shared.gangTarget then ... end
```

### 10.3 The Global Table (_G) Coordination Matrix

Advanced architectures use the `_G` global table for real-time telemetry sharing. Each bot pushes its coordinates, health/mana percentages, ability cooldowns, and current target every frame. Initiator bots query the matrix to verify ally readiness before engaging  -  checking proximity, ultimate cooldowns, and mana pools before committing to fights.

This is also the foundation for deterministic role assignment. Bots are explicitly assigned Positions 1–5 based on slot order. A Pos 5 support queries the global table and zeros out its last-hit desire when the Pos 1 carry is within 1000 units.

### 10.4 Reading Ally State Directly

```lua
local allyPlayers = GetTeamPlayers(GetTeam())
for i, playerID in pairs(allyPlayers) do
    local ally = GetTeamMember(i)
    if ally and ally:IsAlive() then
        local allyMode = ally:GetActiveMode()
        local allyTarget = ally:GetTarget()
        local allyHP = ally:GetHealth() / ally:GetMaxHealth()
        -- If ally is attacking a target, help them
    end
end
```

### 10.5 Pings and Chat

**Pings:** `ActionImmediate_Ping(x, y, bNormalPing)` sends a map ping. `hBot:GetMostRecentPing()` returns `{time, location, normal_ping}`. Normal ping (Alt+Click) = `true`; danger ping (Ctrl+Alt+Click) = `false`.

Pings persist indefinitely in the return value, so implement a temporal decay  -  ignore pings older than 3–5 seconds by comparing `time` against `GameTime()`.

Use ping proximity to modify desires: pings near enemy towers inflate push desire, pings on enemy heroes trigger gank priorities, danger pings spike retreat desire for nearby bots.

**Chat:** `ActionImmediate_Chat(sMessage, bAllChat)` broadcasts messages. `InstallChatCallback(function)` hooks into all chat events, passing `{string, team_only}` to the handler.

### 10.6 Chat Command Parsing

For interactive bots, implement a command router that filters for a prefix (e.g., `!`), parses the command and arguments, and executes programmatic overrides:

```lua
InstallChatCallback(function(tChat)
    local msg = string.lower(tChat.string)
    if string.sub(msg, 1, 1) ~= "!" then return end
    local cmd = string.match(msg, "^!(%w+)")
    local arg = string.match(msg, "^!%w+%s+(.*)")

    if cmd == "pos" and arg then
        -- Swap role assignments in global table
    elseif cmd == "pick" and arg then
        -- Translate colloquial names ("kotl" → "npc_dota_hero_keeper_of_the_light")
        -- and call SelectHero()
    elseif cmd == "ban" and arg then
        -- CMBanHero(translated_name)
    end
end)
```

Advanced systems like OpenHyperAI support batch parsing with delimiters (`!pick io;!ban sniper`) and maintain dictionaries translating colloquial hero names to internal engine nomenclature.

---

## 11. Movement, Pathfinding, and Map Navigation

`Action_MoveToLocation(vector)` handles pathfinding automatically around obstacles. `Action_MoveDirectly(vector)` is straight-line (identical to right-click). `Action_MovePath(pathTable)` follows a custom path.

`GeneratePath(vStart, vEnd, tAvoidanceZones, funcCompletion)` generates paths avoiding danger zones. The completion callback receives path distance and a waypoint table (distance 0 and empty table on failure).

Avoidance zones: `AddAvoidanceZone(vLocationAndRadius)` marks danger areas (Vector with x,y as location, z as radius), `RemoveAvoidanceZone(hZone)` clears them. `GetAvoidanceZones()` returns active zones from enemy AoE abilities. `GetLinearProjectiles()` tracks incoming skillshots.

**Retreat pattern:**

```lua
function Think()  -- retreat mode
    local npcBot = GetBot()
    local towers = npcBot:GetNearbyTowers(3000, false)
    if #towers > 0 then
        npcBot:Action_MoveToLocation(towers[1]:GetLocation())
    else
        npcBot:Action_MoveToLocation(GetAncient(GetTeam()):GetLocation())
    end
end
```

**Juking** requires manual implementation using `GetNearbyTrees(radius)` for tree-line concealment, `IsLocationVisible(vector)` for fog checks, and `RandomVector(length)` for unpredictable movement.

### 11.1 Warding

Ward placement requires finding the ward item, moving to a ward spot, and placing:

```lua
function Think()  -- mode_ward Think
    local npcBot = GetBot()

    -- Find ward in inventory
    local wardSlot = npcBot:FindItemSlot("item_ward_observer")
    if wardSlot < 0 then return end  -- No wards
    local wardItem = npcBot:GetItemInSlot(wardSlot)

    -- Define ward spots (typically hardcoded Vector tables)
    -- Use dota_bot_debug_ward_locations to see default bot ward spots
    local wardSpots = {
        Vector(2200, -200, 0),   -- Example mid high ground
        Vector(-1800, 1400, 0),  -- Example top rune area
        -- Add more spots based on game state...
    }

    -- Find best unwarded spot and move to it
    local bestSpot = nil
    local bestDist = 99999
    for _, spot in pairs(wardSpots) do
        if not IsLocationVisible(spot) then  -- Not already warded
            local dist = GetUnitToLocationDistance(npcBot, spot)
            if dist < bestDist then
                bestDist = dist
                bestSpot = spot
            end
        end
    end

    if bestSpot then
        if bestDist < 300 then
            npcBot:Action_UseAbilityOnLocation(wardItem, bestSpot)
        else
            npcBot:Action_MoveToLocation(bestSpot)
        end
    end
end
```

---

## 12. External Infrastructure and ML Integration

The Lua 5.1 sandbox intentionally lacks multithreading, external C library imports, and file I/O. For complex ML computations, use `CreateHTTPRequest(url)` (localhost) or `CreateRemoteHTTPRequest(url)` to bridge to external backends.

The architecture: serialize game state (health, inventory, cooldowns, positions  -  up to 16,000+ floats per frame) into JSON → POST to an external Python/C++ server → process through heuristics or neural networks → receive actionable directives → parse and map to `ActionPush`/`ActionQueue` commands.

This is the foundational architecture used by projects like OpenAI Five and the d2ai framework for reinforcement learning.

> **For deeper coverage:** The HTTP bridge architecture, observation space serialization, and external server integration patterns are covered extensively in the d2ai project (https://github.com/2aius/d2ai), Nostrademous's WebAI framework (https://github.com/Nostrademous/Dota2-WebAI), and the original OpenAI Five paper (https://cdn.openai.com/dota-2.pdf). The ModDota API documentation (https://docs.moddota.com/lua_bots/) provides the most cleanly formatted API reference for the Lua-side functions.

---

## 13. Bot Difficulties

The API defines six difficulty levels affecting ability usage, last-hit timing, and economy:

**Passive:** Cannot use abilities, items, or the courier. Always remains in laning mode.

**Easy:** Last-hit timing varies ±0.4s (enemy creeps), ±0.2s (allied creeps). Ability/item usage delayed 0.5–1.0s. Every 8s, abilities disabled for 6s. Using any ability disables further use for 6s.

**Medium:** Last-hit timing varies ±0.4s/±0.2s. Ability delay 0.3–0.6s. Every 10s, abilities disabled for 3s. Using any ability disables for 3s.

**Hard:** Last-hit timing varies ±0.2s/±0.1s. Ability delay 0.1–0.2s.

**Unfair:** Ability delay 0.075–0.15s. **25% bonus to XP and Gold earned.**

**New Player:** (no additional detail in API docs)

Access via `GetDifficulty()` on a bot handle.

---

## 14. Hero Power and Potential Locations

### 14.1 Hero Power

An estimate of offensive power, updated each frame per hero:

1. For each enemy hero, calculate damage over a time interval = 5s + stun duration + (slow duration / 2).
2. Include attack damage (with procs/debuffs) plus ability damage (factoring mana, cast time, cooldowns, silence).
3. Average across all enemy heroes.

`GetOffensivePower()`  -  teammates only (accounts for current state).
`GetRawOffensivePower()`  -  teammates or visible enemies (ignores cooldowns, mana, debuffs  -  theoretical max power).

### 14.2 Potential Locations

`GetUnitPotentialValue(hUnit, vLocation, fRadius)` returns 0–255 representing the likelihood an enemy hero is near a location. Uses a flood-fill algorithm:

- When a team loses sight of a hero, a flood-fill starts through passable areas at that hero's movement speed.
- Intensity starts high and decreases as the potential area becomes larger and more diffuse.
- Runs independently for each enemy hero.

Limitations: doesn't account for teleports, speed bursts (Lycan wolf form, AM blink), or directional intent. Still very useful for evaluating location danger when vision is lost.

---

## 15. Complete API Reference

> **Note:** This section covers every function documented in the official Valve API. For the most up-to-date reference with cleaner formatting, see the ModDota API docs: https://docs.moddota.com/lua_bots/. The canonical Valve source is: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting. In the following documentation, `hUnit` is a handle to a unit, `hAbility` is a handle to an ability, and `hItem` is used interchangeably with `hAbility` (abilities and items are largely the same under the hood).

### 15.1 Global Functions

**Game State:**
| Function | Returns | Description |
|-|-|-|
| `GetBot()` | hUnit | Handle to the current bot |
| `GetTeam()` | int | Team of the current script |
| `GetTeamPlayers(nTeam)` | {int,...} | Player IDs on a team |
| `GetTeamMember(nSlot)` | hUnit | Handle to Nth player on team |
| `IsTeamPlayer(nPlayerID)` | bool | Is the player on Radiant or Dire |
| `IsPlayerBot(nPlayerID)` | bool | Is the player a bot |
| `GetTeamForPlayer(nPlayerID)` | int | Team for a player ID |
| `GetUnitList(nUnitType)` | {hUnit,...} | Units matching type (performance-heavy) |
| `DotaTime()` | float | Game clock (pauses with game) |
| `GameTime()` | float | Time since hero picking (pauses with game) |
| `RealTime()` | float | Real-world time since app start (no pause) |
| `GetGameState()` | int | Current game state enum |
| `GetGameStateTimeRemaining()` | float | Time remaining in current state |
| `GetGameMode()` | int | Current game mode |
| `GetHeroPickState()` | int | Current hero pick state |
| `GetTimeOfDay()` | float | 0.0=midnight, 0.5=noon |
| `GetOpposingTeam()` | int | Opposing team ID |

**Distance/Geometry:**
| Function | Returns | Description |
|-|-|-|
| `GetUnitToUnitDistance(hUnit1, hUnit2)` | float | Distance between units |
| `GetUnitToUnitDistanceSqr(hUnit1, hUnit2)` | float | Squared distance (faster) |
| `GetUnitToLocationDistance(hUnit, vLoc)` | float | Distance unit to location |
| `GetUnitToLocationDistanceSqr(hUnit, vLoc)` | float | Squared distance |
| `PointToLineDistance(vStart, vEnd, vPoint)` | {distance, closest_point, within} | Distance to line segment |
| `GetWorldBounds()` | {minX, minY, maxX, maxY} | World boundary coordinates |
| `IsLocationPassable(vLoc)` | bool | Can units walk here |
| `IsLocationVisible(vLoc)` | bool | In team vision |
| `IsRadiusVisible(vLoc, fRadius)` | bool | Circle in vision |
| `GetHeightLevel(vLoc)` | int | Height value (1–5) |

**Map/Structures:**
| Function | Returns | Description |
|-|-|-|
| `GetTower(nTeam, nTower)` | hUnit | Tower handle |
| `GetBarracks(nTeam, nBarracks)` | hUnit | Barracks handle |
| `GetShrine(nTeam, nShrine)` | hUnit | Shrine handle |
| `GetAncient(nTeam)` | hUnit | Ancient handle |
| `GetGlyphCooldown()` | float | Glyph cooldown (0 if ready) |
| `GetRoshanKillTime()` | float | Last Roshan kill time |
| `GetShrineCooldown(hShrine)` | float | Shrine cooldown in seconds |
| `IsShrineHealing(hShrine)` | bool | Is shrine currently healing |
| `GetNeutralSpawners()` | {{string,vector},...} | Camp type + location pairs |
| `GetTreeLocation(nTree)` | vector | Tree location |
| `GetRuneSpawnLocation(nRuneLoc)` | vector | Rune spawner location |
| `GetShopLocation(nTeam, nShop)` | vector | Shop location |

**Lane Navigation:**
| Function | Returns | Description |
|-|-|-|
| `GetLaneFrontAmount(nTeam, nLane, bIgnoreTowers)` | float | Lane front 0.0–1.0 |
| `GetLaneFrontLocation(nTeam, nLane, fDelta)` | vector | Lane front position |
| `GetLocationAlongLane(nLane, fAmount)` | vector | Position along lane path |
| `GetAmountAlongLane(nLane, vLoc)` | {amount, distance} | Reverse lookup |

**Items:**
| Function | Returns | Description |
|-|-|-|
| `GetItemCost(sItemName)` | int | Item cost |
| `IsItemPurchasedFromSecretShop(sItemName)` | bool | Secret shop item |
| `IsItemPurchasedFromSideShop(sItemName)` | bool | Side shop item |
| `GetItemStockCount(sItemName)` | int | Current stock |
| `GetDroppedItemList()` | {{hItem,hOwner,nPlayer,vLoc},...} | Dropped items |

**Hero Info:**
| Function | Returns | Description |
|-|-|-|
| `IsHeroAlive(nPlayerID)` | bool | Hero alive |
| `GetHeroLevel(nPlayerID)` | int | Hero level |
| `GetHeroKills/Deaths/Assists(nPlayerID)` | int | KDA stats |
| `GetHeroLastSeenInfo(nPlayerID)` | {{location,time_since_seen},...} | Last seen data |
| `SelectHero(nPlayerID, sHeroName)` |  -  | Select hero for player |
| `GetSelectedHeroName(nPlayerID)` | string | Selected hero name |
| `IsPlayerInHeroSelectionControl(nPlayerID)` | bool | Player can pick |

**Projectiles/Hazards:**
| Function | Returns | Description |
|-|-|-|
| `GetLinearProjectiles()` | table | Visible linear projectiles |
| `GetLinearProjectileByHandle(nHandle)` | table | Specific projectile info |
| `GetAvoidanceZones()` | table | Visible avoidance zones |

**Runes:**
| Function | Returns | Description |
|-|-|-|
| `GetRuneType(nRuneLoc)` | int | Rune type at location |
| `GetRuneStatus(nRuneLoc)` | int | Rune status |
| `GetRuneTimeSinceSeen(nRuneLoc)` | float | Time since seen |

**Courier:**
| Function | Returns | Description |
|-|-|-|
| `IsCourierAvailable()` | bool | Courier available |
| `GetNumCouriers()` | int | Number of team couriers |
| `GetCourier(nCourier)` | hCourier | Courier handle (zero-based) |
| `GetCourierState(hCourier)` | int | Courier state enum |

**Utility:**
| Function | Returns | Description |
|-|-|-|
| `RandomInt(nMin, nMax)` | int | Random integer inclusive |
| `RandomFloat(fMin, fMax)` | float | Random float inclusive |
| `RandomVector(fLength)` | vector | Random X/Y direction |
| `RollPercentage(nChance)` | bool | Roll 1–100 ≤ nChance |
| `Min(a, b)` / `Max(a, b)` | float | Min/max |
| `Clamp(val, min, max)` | float | Clamped value |
| `RemapVal(val, fromMin, fromMax, toMin, toMax)` | float | Linear remap |
| `RemapValClamped(...)` | float | Clamped linear remap |
| `GetUnitPotentialValue(hUnit, vLoc, fRadius)` | int | Potential location (0–255) |

**Pathfinding:**
| Function | Description |
|-|-|
| `AddAvoidanceZone(vLocAndRadius)` | Add avoidance zone (returns handle) |
| `RemoveAvoidanceZone(hZone)` | Remove avoidance zone |
| `GeneratePath(vStart, vEnd, tZones, funcComplete)` | Async pathfind with avoidance |

**Debug:**
| Function | Description |
|-|-|
| `DebugDrawLine(vStart, vEnd, r, g, b)` | Draw line for one frame |
| `DebugDrawCircle(vCenter, fRadius, r, g, b)` | Draw circle for one frame |
| `DebugDrawText(fScreenX, fScreenY, sText, r, g, b)` | Draw text for one frame |

### 15.2 Unit-Scoped Functions (on hUnit/npcBot)

**Identity:**
`GetUnitName()`, `GetPlayerID()`, `GetTeam()`, `IsBot()`, `GetDifficulty()`, `IsHero()`, `IsIllusion()`, `IsCreep()`, `IsAncientCreep()`, `IsBuilding()`, `IsTower()`, `IsFort()`, `CanBeSeen()`

**Mode:**
`GetActiveMode()`, `GetActiveModeDesire()`

**Health/Mana:**
`GetHealth()`, `GetMaxHealth()`, `GetHealthRegen()`, `GetMana()`, `GetMaxMana()`, `GetManaRegen()`

**Movement:**
`GetBaseMovementSpeed()`, `GetCurrentMovementSpeed()`, `GetLocation()`, `GetFacing()`, `IsFacingLocation(vLoc, nDegrees)`, `GetGroundHeight()` (expensive!), `GetVelocity()`, `GetExtrapolatedLocation(fTime)`, `GetMovementDirectionStability()`

**Combat Stats:**
`GetBaseDamage()`, `GetBaseDamageVariance()`, `GetAttackDamage()`, `GetAttackRange()`, `GetAttackSpeed()`, `GetSecondsPerAttack()`, `GetAttackPoint()`, `GetLastAttackTime()`, `GetAttackTarget()`, `GetAcquisitionRange()`, `GetAttackProjectileSpeed()`, `GetActualIncomingDamage(nDmg, nDmgType)`, `GetAttackCombatProficiency(hTarget)`, `GetDefendCombatProficiency(hAttacker)`, `GetSpellAmp()`, `GetArmor()`, `GetMagicResist()`, `GetEvasion()`

**Economy/Progression:**
`GetGold()`, `GetNetWorth()`, `GetStashValue()`, `GetCourierValue()`, `GetLastHits()`, `GetDenies()`, `GetLevel()`, `GetXPNeededToLevel()`, `GetAbilityPoints()`, `GetPrimaryAttribute()`, `GetAttributeValue(nAttrib)`, `GetBountyXP()`, `GetBountyGoldMin()`, `GetBountyGoldMax()`

**Life/Death:**
`IsAlive()`, `GetRespawnTime()`, `HasBuyback()`, `GetBuybackCost()`, `GetBuybackCooldown()`, `GetRemainingLifespan()`

**Vision:**
`GetDayTimeVisionRange()`, `GetNightTimeVisionRange()`, `GetCurrentVisionRange()`

**Status Effects:**
`IsAttackImmune()`, `IsBlind()`, `IsBlockDisabled()`, `IsDisarmed()`, `IsDominated()`, `IsEvadeDisabled()`, `IsHexed()`, `IsInvisible()`, `IsInvulnerable()`, `IsMagicImmune()`, `IsMuted()`, `IsNightmared()`, `IsRooted()`, `IsSilenced()`, `IsSpeciallyDeniable()`, `IsStunned()`, `IsUnableToMiss()`, `HasScepter()`

**Damage History:**
`WasRecentlyDamagedByAnyHero(fInterval)`, `TimeSinceDamagedByAnyHero()`, `WasRecentlyDamagedByHero(hUnit, fInterval)`, `TimeSinceDamagedByHero(hUnit)`, `WasRecentlyDamagedByPlayer(nPlayerID, fInterval)`, `TimeSinceDamagedByPlayer(nPlayerID)`, `WasRecentlyDamagedByCreep(fInterval)`, `TimeSinceDamagedByCreep()`, `WasRecentlyDamagedByTower(fInterval)`, `TimeSinceDamagedByTower()`

**Nearby Queries (all require nRadius < 1600):**
`GetNearbyHeroes(nRadius, bEnemies, nMode)`, `GetNearbyCreeps(nRadius, bEnemies)`, `GetNearbyLaneCreeps(nRadius, bEnemies)`, `GetNearbyNeutralCreeps(nRadius)`, `GetNearbyTowers(nRadius, bEnemies)`, `GetNearbyBarracks(nRadius, bEnemies)`, `GetNearbyShrines(nRadius, bEnemies)`, `GetNearbyTrees(nRadius)`

**Spatial Analysis:**
`FindAoELocation(bEnemies, bHeroes, vBase, nMaxDist, nRadius, fFutureTime, nMaxHealth)`  -  returns `{count, targetloc}`, `GetBoundingRadius()`, `DistanceFromFountain()`, `DistanceFromSecretShop()`, `DistanceFromSideShop()`

**Offensive Estimation:**
`GetOffensivePower()`, `GetRawOffensivePower()`, `GetEstimatedDamageToTarget(bCurrentlyAvailable, hTarget, fDuration, nDamageTypes)`, `GetStunDuration(bCurrentlyAvailable)`, `GetSlowDuration(bCurrentlyAvailable)`, `HasBlink(bCurrentlyAvailable)`, `HasMinistunOnAttack()`, `HasSilence(bCurrentlyAvailable)`, `HasInvisibility(bCurrentlyAvailable)`, `UsingItemBreaksInvisibility()`

**Abilities/Items:**
`GetAbilityByName(sName)`, `GetAbilityInSlot(nSlot)` (0–23), `GetItemInSlot(nSlot)` (0–16), `FindItemSlot(sItemName)`, `GetItemSlotType(nSlot)`, `IsChanneling()`, `IsUsingAbility()`, `IsCastingAbility()`, `GetCurrentActiveAbility()`

**Modifiers:**
`HasModifier(sName)`, `GetModifierByName(sName)`, `NumModifiers()`, `GetModifierName(nMod)`, `GetModifierStackCount(nMod)`, `GetModifierRemainingDuration(nMod)`, `GetModifierAuxiliaryUnits(nMod)`

**Communication:**
`GetMostRecentPing()`  -  returns `{time, location, normal_ping}`, `GetIncomingTrackingProjectiles()`  -  returns `{{location, caster, player, ability, is_dodgeable, is_attack},...}`

**Target Management:**
`SetTarget(hUnit)`, `GetTarget()`, `SetNextItemPurchaseValue(nGold)`, `GetNextItemPurchaseValue()`, `GetAssignedLane()`

**Animation:**
`GetAnimActivity()`, `GetAnimCycle()`, `GetHealthRegenPerStr()`, `GetManaRegenPerInt()`

### 15.3 Ability-Scoped Functions (on hAbility/hItem)

`CanAbilityBeUpgraded()`, `GetAbilityDamage()`, `GetAutoCastState()`, `GetBehavior()`, `GetCaster()`, `GetCastPoint()`, `GetCastRange()`, `GetChannelledManaCostPerSecond()`, `GetChannelTime()`, `GetDuration()`, `GetCooldownTimeRemaining()` (self/allies only), `GetCurrentCharges()`, `GetDamageType()`, `GetHeroLevelRequiredToUpgrade()`, `GetInitialCharges()`, `GetLevel()`, `GetManaCost()`, `GetMaxLevel()`, `GetName()`, `GetSecondaryCharges()`, `GetSpecialValueFloat(key)`, `GetSpecialValueInt(key)`, `GetTargetFlags()`, `GetTargetTeam()`, `GetTargetType()`, `GetToggleState()`, `IsActivated()`, `IsAttributeBonus()`, `IsChanneling()`, `IsCooldownReady()` (self/allies only), `IsFullyCastable()`, `IsHidden()`, `IsInAbilityPhase()`, `IsItem()`, `IsOwnersManaEnough()`, `IsPassive()`, `IsStealable()`, `IsStolen()`, `IsToggle()`, `IsTrained()`, `ProcsMagicStick()`, `ToggleAutoCast()`

**Item-Only:** `CanBeDisassembled()`, `IsCombineLocked()`

---

## 16. Constants Reference

### 16.1 Bot Modes
`BOT_MODE_NONE`, `BOT_MODE_LANING`, `BOT_MODE_ATTACK`, `BOT_MODE_ROAM`, `BOT_MODE_RETREAT`, `BOT_MODE_SECRET_SHOP`, `BOT_MODE_SIDE_SHOP`, `BOT_MODE_PUSH_TOWER_TOP/MID/BOT`, `BOT_MODE_DEFEND_TOWER_TOP/MID/BOT`, `BOT_MODE_ASSEMBLE`, `BOT_MODE_TEAM_ROAM`, `BOT_MODE_FARM`, `BOT_MODE_DEFEND_ALLY`, `BOT_MODE_EVASIVE_MANEUVERS`, `BOT_MODE_ROSHAN`, `BOT_MODE_ITEM`, `BOT_MODE_WARD`

### 16.2 Desire Constants
| Constant | Value |
|-|-|
| `BOT_MODE_DESIRE_NONE` / `BOT_ACTION_DESIRE_NONE` | 0.0 |
| `BOT_MODE_DESIRE_VERYLOW` / `BOT_ACTION_DESIRE_VERYLOW` | 0.1 |
| `BOT_MODE_DESIRE_LOW` / `BOT_ACTION_DESIRE_LOW` | 0.25 |
| `BOT_MODE_DESIRE_MODERATE` / `BOT_ACTION_DESIRE_MODERATE` | 0.5 |
| `BOT_MODE_DESIRE_HIGH` / `BOT_ACTION_DESIRE_HIGH` | 0.75 |
| `BOT_MODE_DESIRE_VERYHIGH` / `BOT_ACTION_DESIRE_VERYHIGH` | 0.9 |
| `BOT_MODE_DESIRE_ABSOLUTE` / `BOT_ACTION_DESIRE_ABSOLUTE` | 1.0 |

### 16.3 Teams and Lanes
`TEAM_RADIANT`, `TEAM_DIRE`, `TEAM_NEUTRAL`, `TEAM_NONE`
`LANE_NONE`, `LANE_TOP`, `LANE_MID`, `LANE_BOT`

### 16.4 Damage Types
`DAMAGE_TYPE_PHYSICAL`, `DAMAGE_TYPE_MAGICAL`, `DAMAGE_TYPE_PURE`, `DAMAGE_TYPE_ALL`

### 16.5 Unit List Types
`UNIT_LIST_ALL`, `UNIT_LIST_ALLIES`, `UNIT_LIST_ALLIED_HEROES`, `UNIT_LIST_ALLIED_CREEPS`, `UNIT_LIST_ALLIED_WARDS`, `UNIT_LIST_ALLIED_BUILDINGS`, `UNIT_LIST_ENEMIES`, `UNIT_LIST_ENEMY_HEROES`, `UNIT_LIST_ENEMY_CREEPS`, `UNIT_LIST_ENEMY_WARDS`, `UNIT_LIST_NEUTRAL_CREEPS`, `UNIT_LIST_ENEMY_BUILDINGS`

### 16.6 Difficulties
`DIFFICULTY_INVALID`, `DIFFICULTY_PASSIVE`, `DIFFICULTY_EASY`, `DIFFICULTY_MEDIUM`, `DIFFICULTY_HARD`, `DIFFICULTY_UNFAIR`

### 16.7 Attributes
`ATTRIBUTE_INVALID`, `ATTRIBUTE_STRENGTH`, `ATTRIBUTE_AGILITY`, `ATTRIBUTE_INTELLECT`

### 16.8 Item Purchase Results
`PURCHASE_ITEM_SUCCESS`, `PURCHASE_ITEM_OUT_OF_STOCK`, `PURCHASE_ITEM_DISALLOWED_ITEM`, `PURCHASE_ITEM_INSUFFICIENT_GOLD`, `PURCHASE_ITEM_NOT_AT_HOME_SHOP`, `PURCHASE_ITEM_NOT_AT_SIDE_SHOP`, `PURCHASE_ITEM_NOT_AT_SECRET_SHOP`, `PURCHASE_ITEM_INVALID_ITEM_NAME`

### 16.9 Game States
`GAME_STATE_INIT`, `GAME_STATE_WAIT_FOR_PLAYERS_TO_LOAD`, `GAME_STATE_HERO_SELECTION`, `GAME_STATE_STRATEGY_TIME`, `GAME_STATE_PRE_GAME`, `GAME_STATE_GAME_IN_PROGRESS`, `GAME_STATE_POST_GAME`, `GAME_STATE_DISCONNECT`, `GAME_STATE_TEAM_SHOWCASE`, `GAME_STATE_CUSTOM_GAME_SETUP`, `GAME_STATE_WAIT_FOR_MAP_TO_LOAD`, `GAME_STATE_LAST`

### 16.10 Game Modes
`GAMEMODE_NONE`, `GAMEMODE_AP`, `GAMEMODE_CM`, `GAMEMODE_RD`, `GAMEMODE_SD`, `GAMEMODE_AR`, `GAMEMODE_REVERSE_CM`, `GAMEMODE_MO`, `GAMEMODE_CD`, `GAMEMODE_ABILITY_DRAFT`, `GAMEMODE_ARDM`, `GAMEMODE_1V1MID`, `GAMEMODE_ALL_DRAFT`

### 16.10a Hero Pick States (Partial)

Common states: `HEROPICK_STATE_NONE`, `HEROPICK_STATE_AP_SELECT`, `HEROPICK_STATE_SD_SELECT`, `HEROPICK_STATE_CM_INTRO`, `HEROPICK_STATE_CM_CAPTAINPICK`, `HEROPICK_STATE_AR_SELECT`, `HEROPICK_STATE_ALL_DRAFT_SELECT`

> **Partial coverage:** There are 40+ hero pick state constants covering every individual ban and pick phase in Captain's Mode (`HEROPICK_STATE_CM_BAN1` through `_BAN10`, `HEROPICK_STATE_CM_SELECT1` through `_SELECT10`), Captain's Draft, and other modes. For the complete list, see the Valve Developer Wiki: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting

### 16.11 Rune Types and Status
**Types:** `RUNE_INVALID`, `RUNE_DOUBLEDAMAGE`, `RUNE_HASTE`, `RUNE_ILLUSION`, `RUNE_INVISIBILITY`, `RUNE_REGENERATION`, `RUNE_BOUNTY`, `RUNE_ARCANE`
**Status:** `RUNE_STATUS_UNKNOWN`, `RUNE_STATUS_AVAILABLE`, `RUNE_STATUS_MISSING`
**Locations:** `RUNE_POWERUP_1`, `RUNE_POWERUP_2`, `RUNE_BOUNTY_1` through `RUNE_BOUNTY_4`

### 16.12 Item Slot Types
`ITEM_SLOT_TYPE_INVALID`, `ITEM_SLOT_TYPE_MAIN`, `ITEM_SLOT_TYPE_BACKPACK`, `ITEM_SLOT_TYPE_STASH`

### 16.13 Action Types
`BOT_ACTION_TYPE_NONE`, `BOT_ACTION_TYPE_IDLE`, `BOT_ACTION_TYPE_MOVE_TO`, `BOT_ACTION_TYPE_MOVE_TO_DIRECTLY`, `BOT_ACTION_TYPE_ATTACK`, `BOT_ACTION_TYPE_ATTACKMOVE`, `BOT_ACTION_TYPE_USE_ABILITY`, `BOT_ACTION_TYPE_PICK_UP_RUNE`, `BOT_ACTION_TYPE_PICK_UP_ITEM`, `BOT_ACTION_TYPE_DROP_ITEM`, `BOT_ACTION_TYPE_SHRINE`, `BOT_ACTION_TYPE_DELAY`

### 16.14 Courier Actions and States
**Actions:** `COURIER_ACTION_BURST`, `COURIER_ACTION_ENEMY_SECRET_SHOP`, `COURIER_ACTION_RETURN`, `COURIER_ACTION_SECRET_SHOP`, `COURIER_ACTION_SIDE_SHOP`, `COURIER_ACTION_SIDE_SHOP2`, `COURIER_ACTION_TAKE_STASH_ITEMS`, `COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS`, `COURIER_ACTION_TRANSFER_ITEMS`
**States:** `COURIER_STATE_IDLE`, `COURIER_STATE_AT_BASE`, `COURIER_STATE_MOVING`, `COURIER_STATE_DELIVERING_ITEMS`, `COURIER_STATE_RETURNING_TO_BASE`, `COURIER_STATE_DEAD`

### 16.15 Structures
**Towers:** `TOWER_TOP_1/2/3`, `TOWER_MID_1/2/3`, `TOWER_BOT_1/2/3`, `TOWER_BASE_1/2`
**Barracks:** `BARRACKS_TOP/MID/BOT_MELEE`, `BARRACKS_TOP/MID/BOT_RANGED`
**Shrines:** `SHRINE_BASE_1` through `SHRINE_BASE_5`, `SHRINE_JUNGLE_1/2`
**Shops:** `SHOP_HOME`, `SHOP_SIDE`, `SHOP_SECRET`, `SHOP_SIDE2`, `SHOP_SECRET2`

### 16.16 Ability Target Enums
**Teams:** `ABILITY_TARGET_TEAM_NONE`, `ABILITY_TARGET_TEAM_FRIENDLY`, `ABILITY_TARGET_TEAM_ENEMY`

**Types:** `ABILITY_TARGET_TYPE_NONE`, `ABILITY_TARGET_TYPE_HERO`, `ABILITY_TARGET_TYPE_CREEP`, `ABILITY_TARGET_TYPE_BUILDING`, `ABILITY_TARGET_TYPE_COURIER`, `ABILITY_TARGET_TYPE_OTHER`, `ABILITY_TARGET_TYPE_TREE`, `ABILITY_TARGET_TYPE_BASIC`, `ABILITY_TARGET_TYPE_ALL`

**Flags (commonly used):** `ABILITY_TARGET_FLAG_NONE`, `ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES`, `ABILITY_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES`, `ABILITY_TARGET_FLAG_INVULNERABLE`, `ABILITY_TARGET_FLAG_NOT_ANCIENTS`, `ABILITY_TARGET_FLAG_NOT_ILLUSIONS`, `ABILITY_TARGET_FLAG_NOT_SUMMONED`, `ABILITY_TARGET_FLAG_PLAYER_CONTROLLED`, `ABILITY_TARGET_FLAG_FOW_VISIBLE`, `ABILITY_TARGET_FLAG_PREFER_ENEMIES`

> **Partial coverage:** There are 20 target flags total including `_RANGED_ONLY`, `_MELEE_ONLY`, `_DEAD`, `_NO_INVIS`, `_NOT_DOMINATED`, `_NOT_ATTACK_IMMUNE`, `_MANA_ONLY`, `_CHECK_DISABLE_HELP`, `_NOT_CREEP_HERO`, `_OUT_OF_WORLD`, `_NOT_NIGHTMARED`. For the complete list, see: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting

### 16.17 Ability Behavior Bitfields (Partial)

These are **bitfields**  -  abilities can have multiple behaviors combined via bitwise OR. Common values:

- **Targeting:** `ABILITY_BEHAVIOR_NO_TARGET`, `ABILITY_BEHAVIOR_UNIT_TARGET`, `ABILITY_BEHAVIOR_POINT`, `ABILITY_BEHAVIOR_AOE`, `ABILITY_BEHAVIOR_DIRECTIONAL`, `ABILITY_BEHAVIOR_VECTOR_TARGETING`
- **Type:** `ABILITY_BEHAVIOR_PASSIVE`, `ABILITY_BEHAVIOR_CHANNELLED`, `ABILITY_BEHAVIOR_TOGGLE`, `ABILITY_BEHAVIOR_AUTOCAST`, `ABILITY_BEHAVIOR_ITEM`, `ABILITY_BEHAVIOR_AURA`
- **Behavior modifiers:** `ABILITY_BEHAVIOR_HIDDEN`, `ABILITY_BEHAVIOR_NOT_LEARNABLE`, `ABILITY_BEHAVIOR_IMMEDIATE`, `ABILITY_BEHAVIOR_ATTACK`, `ABILITY_BEHAVIOR_ROOT_DISABLES`, `ABILITY_BEHAVIOR_UNRESTRICTED`
- **Interaction flags:** `ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT`, `ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT`, `ABILITY_BEHAVIOR_DONT_ALERT_TARGET`, `ABILITY_BEHAVIOR_DONT_RESUME_ATTACK`, `ABILITY_BEHAVIOR_IGNORE_BACKSWING`, `ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL`, `ABILITY_BEHAVIOR_IGNORE_CHANNEL`, `ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE`
- **Other:** `ABILITY_BEHAVIOR_NONE`, `ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET`, `ABILITY_BEHAVIOR_OPTIONAL_POINT`, `ABILITY_BEHAVIOR_OPTIONAL_NO_TARGET`, `ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN`, `ABILITY_BEHAVIOR_RUNE_TARGET`, `ABILITY_BEHAVIOR_LAST_RESORT_POINT`

Check behaviors with bitwise AND: `if bit.band(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT) > 0 then -- ground targeted end`

> **Partial coverage:** The above is the complete list from the Valve API but organized by category for readability. For the raw enumeration order, see: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting

### 16.18 Misc
`GLYPH_COOLDOWN`

### 16.19 Animation Activities
`ACTIVITY_IDLE`, `ACTIVITY_IDLE_RARE`, `ACTIVITY_RUN`, `ACTIVITY_ATTACK/ATTACK2/ATTACK_EVENT`, `ACTIVITY_DIE`, `ACTIVITY_FLINCH`, `ACTIVITY_FLAIL`, `ACTIVITY_DISABLED`, `ACTIVITY_CAST_ABILITY_1` through `_6`, `ACTIVITY_OVERRIDE_ABILITY_1` through `_4`, `ACTIVITY_CHANNEL_ABILITY_1` through `_6`, `ACTIVITY_CHANNEL_END_ABILITY_1` through `_6`, `ACTIVITY_CONSTANT_LAYER`, `ACTIVITY_CAPTURE`, `ACTIVITY_SPAWN`, `ACTIVITY_KILLTAUNT`, `ACTIVITY_TAUNT`

---

## 17. Common Pitfalls

**Player ID confusion** is the #1 beginner mistake. Bot-vs-bot lobbies use IDs 2–6 and 7–11, not 0–4 and 5–9. Always iterate `GetTeamPlayers(GetTeam())`.

**Hero selection crashes are silent.** Parse errors in `hero_selection.lua` crash the game with no error display. Test carefully with liberal `print()` usage.

**Summoned units call your item purchase script.** Death Ward, Necronomicon warriors, etc. trigger `ItemPurchaseThink()`. Add an `if not GetBot():IsHero() then return end` guard.

**Global variables destroy performance.** Use persistent local tables (`local cache = {}` at file scope) instead.

**`GetNearbyHeroes()` has an edge-of-vision bug.** Sometimes returns heroes at vision edges that can't be fully queried. Always validate with `CanBeSeen()`.

**`require()` can crash the client** on parse errors in `team_desires` and `hero_selection` contexts. Test required modules independently.

**The `restart` console command doesn't fully reset state.** Internal values may be stale. Create a new lobby for clean tests.

**`Think()` runs every frame.** Keep computation minimal  -  cache `GetNearbyHeroes()` results, short-circuit `GetDesire()` when high-priority modes score above 0.9, and throttle team-level thinking to every ~0.1s with a time check:

```lua
local lastThinkTime = -99

function TeamThink()
    if GameTime() - lastThinkTime < 0.1 then return end
    lastThinkTime = GameTime()
    -- Expensive team-level logic here (runs at ~10Hz instead of every frame)
end
```

**Repeatedly pushing actions in Think() causes animation stutter.** Always check `IsChanneling()`, `IsUsingAbility()`, and `IsCastingAbility()` before issuing new commands. See Section 7.3 for the detailed explanation.

**`GetUnitList()` can be very slow.** The function itself builds lists on-demand and no more than once per frame, but the lists can be long. Performing logic on all units or even all creeps can easily tank performance. Prefer the `GetNearby*()` functions with tight radii when possible.

---

## 18. Advanced AI Architectures

### 18.1 Utility-Based AI

Valve's mode/desire system is already a utility-based architecture. The most successful community bots lean into this rather than fighting it. Nostrademous's Full Overwrite implements a two-tier utility system: TeamThink (throttled to ~10Hz) evaluates team-level assignments, and HeroThink (every frame) evaluates individual modes with short-circuit logic  -  if evade scores above `BOT_MODE_DESIRE_VERYHIGH`, skip all other evaluations.

### 18.2 State Machines vs. Behavior Trees

No major Dota 2 bot project has implemented a full behavior tree. The community consensus is that utility-based scoring is the natural fit  -  it's flexible, modular, and doesn't require building tree infrastructure the API doesn't support. The Musashi ML project tried rigid state machines, found them brittle, then evolved to weighted state machines combined with genetic algorithms for better results.

### 18.3 Progressive Override (Recommended Approach)

The Ranked Matchmaking AI author warns that "completely overwriting the default AI architecture will take full-time work for more than six months." Start by overriding one mode at a time, measure improvement against the default, and only expand when your replacement is proven better.

### 18.4 Dynamic Difficulty Adaptation

Advanced systems like FretBots monitor live GPM/XPM metrics of human players and dynamically inject economy boosts into bots (bonus gold/second, passive armor, experience on death) to maintain engagement. This creates an organic difficulty curve impossible with static if/else logic.

---

## 19. Essential Resources

### Official Documentation
- **Valve Developer Wiki:** https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
- **ModDota API Docs:** https://docs.moddota.com/lua_bots/
- **Built-In Item Names:** https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Item_Names
- **Built-In Ability Names:** https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Ability_Names

### Major Community Projects
- **Open Hyper AI** (forest0xia)  -  Most actively maintained (2025–2026), 126 heroes, FretBots integration. GitHub: `forest0xia/dota2bot-OpenHyperAI`
- **Ranked Matchmaking AI** (adamqqqplay)  -  Most subscribed (3M+), 100+ heroes, effective partial-override architecture. GitHub: `adamqqqplay/dota2ai`
- **Nostrademous Full Overwrite**  -  Most sophisticated architecture documentation. GitHub: `Nostrademous/Dota2-FullOverwrite`
- **VUL-FT** (Yewchi)  -  Hybrid partial/full takeover, dynamic fight behavior, escape curves. GitHub: `Yewchi/vulft`
- **FuriousPuppy's Bots**  -  Pioneer community effort, good learning reference. GitHub: `furiouspuppy/Dota2_Bots`

### Learning Resources
- **RuoyuSun's "Dota 2 AI Quick Start"** (ruoyusun.com)  -  Best beginner walkthrough
- **Musashi ML Bot** (Medium)  -  State machine design and genetic algorithms
- **/r/dota2AI**  -  Dedicated subreddit
- **PhalanxBot Discord** (discord.gg/MpA88P645B)  -  Active community server
- **Valve Dev Forums** (dev.dota2.com)  -  Historical but searchable

### Important Platform Note
The bot scripting API has not received meaningful updates since ~October 2017 (see note at top of guide). Community projects like Open Hyper AI and Ranked Matchmaking AI demonstrate that the existing API is sufficient for sophisticated, full-hero-roster bots. The key architectural insight from the community is that **utility-based scoring is the right paradigm**  -  each mode returns a desire, the highest wins, and your job is engineering those desire curves. Use `RemapValClamped()` for smooth gradients, add hysteresis to every mode, implement commitment timers for natural transitions, and always test with `dota_bot_debug_team` to watch desire values in real-time.
