# Dota 2 Bot Scripting Source Audit

Date: 2026-05-01

Purpose: collect source-backed guidance for improving OpenHyperAI-style Dota 2 bot scripts without making them brittle, overcomplicated, or worse in play.

## Source Map

Primary references:

- [Valve Developer Community: Dota Bot Scripting](https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting)
- [Valve Developer Community: Dota 2 Workshop Tools Scripting](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting)
- [Valve Developer Community: Built-In Ability Names](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Ability_Names)
- [ModDota Lua Bot API Reference](https://docs.moddota.com/lua_bots/)
- [ModDota Lua Bot Enums Reference](https://docs.moddota.com/lua_bots_enums/)
- [Ruoyu Sun: Dota 2 AI Quick Start](https://ruoyusun.com/2017/01/08/dota2-ai-quickstart.html)

Community project references:

- [OpenHyperAI](https://github.com/forest0xia/dota2bot-OpenHyperAI)
- [Ranked Matchmaking AI](https://github.com/adamqqqplay/dota2ai)
- [VUL-FT](https://github.com/Yewchi/vulft)
- [Dota 2 Combo Bots](https://github.com/ellysh/dota2-combo-bots)
- [FuriousPuppy Dota2_Bots](https://github.com/furiouspuppy/Dota2_Bots)
- [FretBots](https://github.com/fretmute/fretbots)

Research and external-controller references:

- [d2ai](https://github.com/2aius/d2ai)
- [Malmö University Dota 2 5v5 Framework tutorial](https://games.mau.se/research/the-dota2-5v5-ai-competition/intro-tutorial-dota-framework/)
- [Malmö University strategy tips](https://games.mau.se/research/the-dota2-5v5-ai-competition/strategy-tips-for-building-your-dota-2-bot/)
- [The Dota 2 Bot Competition](https://arxiv.org/abs/2103.02943)
- [Dota 2 with Large Scale Deep Reinforcement Learning](https://arxiv.org/abs/1912.06680)

Context7 note: a `ctx7 library` lookup for Dota 2 bot scripting did not return a relevant bot scripting library. The source material above was collected through web lookup instead.

## High-Level Model

Valve's bot scripting model has three useful layers:

- Team level: computes team-wide strategic desires such as push, defend, farm, roam, and Roshan. These are guidance signals, not commands.
- Mode level: each individual bot evaluates mode desires. The highest scoring mode becomes active.
- Action level: the active mode's `Think()` issues movement, attack, ability, item, and purchase commands.

Good scripts respect this separation. Bad scripts usually blur it by making a mode issue unrelated actions, returning action desire constants from mode desire functions, or letting opportunistic side behavior override retreat, defend, farm, or active fights.

OpenHyperAI is already a partial-overwrite system built on Valve's mode architecture. That is the right base for iterative improvements. A full rewrite would need to recreate drafting, laning, retreat, pathing, item purchase, ability usage, summons, warding, Roshan, and team coordination before it even reaches parity.

## Installation And Playtest Reality

The practical development target is:

`<Steam>/steamapps/common/dota 2 beta/game/dota/scripts/vscripts/bots`

For this checkout, that path is a junction to:

`D:/Dev/Projects/Dota2AI/bots`

Most sources agree that custom scripts are most reliable in Custom Lobby with Local Host and Local Dev Script selected. Community projects repeatedly document manual install or symlink workflows because Workshop delivery can be unreliable for newer scripts.

Good playtest setup:

- Use Custom Lobby, Local Host, Local Dev Script.
- Confirm bot names or other obvious markers prove the intended script loaded.
- Keep console enabled.
- Use `dota_bot_reload_scripts` only when safe. If reload is unstable in the current Dota build, restart the lobby instead.
- Test one behavior at a time. A broad batch of AI changes is hard to debug because mode competition hides root causes.

Useful debug commands from Valve docs and quickstart material:

- `dota_bot_debug_team`
- `dota_bot_select_debug`
- `dota_bot_select_debug_attack`
- `dota_bot_debug_lanes`
- `dota_bot_debug_ward_locations`
- `dota_bot_debug_grid`
- `dota_bot_debug_minimap`
- `dota_bot_debug_clear`
- `dump_modifier_list`

## API And Runtime Constraints

The bot VM is Lua-based and server-side. Scripts query game state and issue orders through the API; they do not read pixels or simulate mouse input.

Important constraints:

- Fog of war matters. Do not assume enemy units, wards, or item state are queryable when unseen.
- Commands can only be issued to controllable units.
- Many API calls return handles or tables that can become invalid between frames.
- Several functions can return nil or empty tables in edge cases.
- Most logic runs in hot paths, so repeated expensive scans can cause performance problems.
- The public bot API is old and incomplete relative to modern Dota. New heroes, facets, map objects, neutral items, Tormentor, and newer item mechanics often need defensive fallback logic.

Practical rule: every API read should be treated as unreliable unless the code just validated it in the same frame.

## File Discovery Rules

The Dota bot engine discovers behavior by filename convention. There is no project manifest for arbitrary new modes.

Known useful entry points include:

- `hero_selection.lua`
- `team_desires.lua`
- `bot_generic.lua`
- `bot_<hero>.lua`
- `mode_<mode>_generic.lua`
- `mode_<mode>_<hero>.lua`
- `ability_item_usage_generic.lua`
- `ability_item_usage_<hero>.lua`
- `item_purchase_generic.lua`
- `item_purchase_<hero>.lua`

Therefore, new behavior should usually be added through a loaded entry point or a helper required by one. A standalone file such as `mode_stack_generic.lua` is suspicious unless Valve recognizes that exact mode name or another loaded file requires it.

## Desire System Rules

Mode `GetDesire()` must return a mode desire in the 0.0 to 1.0 range. Use `BOT_MODE_DESIRE_*` constants and clamp computed values.

Common failure patterns:

- Returning `BOT_ACTION_DESIRE_*` from mode `GetDesire()`.
- Returning values above `BOT_MODE_DESIRE_ABSOLUTE`.
- Returning a nonzero desire for a long time window before the action is actually executable.
- Letting utility behavior beat retreat, defend, attack, or urgent item/ability usage.
- Recomputing a target in `Think()` that differs from the target selected by `GetDesire()`.
- Forgetting cooldown or hysteresis, causing mode oscillation.

Good mode behavior:

- `GetDesire()` answers "should this mode own the bot now?"
- `Think()` only performs the job selected by that mode.
- Once a mode selects a job, store enough state to finish or cancel it intentionally.
- Clear state in `OnEnd()` or explicit reset paths.
- Cool down failed attempts when repeated attempts would waste the same game window.

## Action Sequencing Rules

The API has immediate, push, queue, and current-action forms. The important design point is not the exact method name, but preserving the intended sequence across frames.

Good action code:

- Checks `IsChanneling()`, `IsUsingAbility()`, `IsCastingAbility()`, and interrupted actions before replacing an order.
- Uses queue or a timed state machine when an attack must land before movement.
- Uses `bOnce = true` for a single attack tap.
- Does not issue a different movement command on the next frame before the previous attack, projectile, or cast has mattered.
- Cancels cleanly when a target disappears, becomes invalid, or the bot becomes unsafe.

For stacking specifically, a support should not attack and immediately move in the same frame unless the implementation can prove aggro happened. The safer pattern is:

1. Select camp and target near stack timing.
2. Move into attack range.
3. Issue one attack.
4. Wait at least the bot's attack point or another hero-specific confirmation window.
5. Move to the camp's pull location.
6. Mark that minute as attempted even if the attempt aborts after selecting a real job.

## Lua Safety Rules

High-value Lua traps in this codebase:

- `x ~= "a" or x ~= "b"` is always true. Use `and` for exclusion lists.
- `#table >= 0` is always true. Use `> 0`.
- `GetNearbyHeroes()` and similar calls can be nil in practice. Use `or {}` when immediately iterating or counting.
- `GetTeamMember()` takes a team slot index, not a player ID.
- `GetItemInSlot()` returns an item handle, not a string.
- `FindItemSlot()` returns `-1` when not found.
- Ability handles can be nil when ability slots changed after a patch.
- String concatenation with nil crashes.
- Global variables leak across file scope and can collide in surprising ways.
- `require()` caches modules, while `dofile()` re-executes files.

## Dota Logic Priorities

A bot feels smarter when it preserves Dota fundamentals before it adds clever tricks.

Highest priority behaviors:

- Do not feed. Retreat and survival must beat opportunistic jobs.
- Do not miss obvious farm for low-impact movement.
- Do not abandon a defended tower, active fight, or Roshan decision for a low-confidence ward or stack.
- Do not hold critical consumables or wards forever.
- Do not let supports steal farm from cores except for tactical necessity.
- Do not send fragile supports into dark enemy territory alone for dewarding.
- Do not force five-bot grouping too early unless defending or executing a real objective.

For support play:

- Warding, dewarding, stacking, pulling, smoke, dust, and save-item use should be opportunity-driven and safety-gated.
- Support jobs should prefer already-planned travel paths over long detours.
- Post-laning stacking should happen when a support is near a camp near stack time, not as a broad 20-second commute.
- Dewarding should require either visible ward evidence, missing friendly observer evidence, enemy behavior evidence, or high-value objective timing.

## Warding And Dewarding Guidance

Good observer placement considers:

- Current objective: safe lane defense, mid defense, triangle farm, Roshan setup, high ground siege, retreat vision.
- Tower state. Ward spots change once outer towers fall.
- Hero roles and current farm pattern. Carry triangle farming needs different vision from mid ganking.
- Enemy last-seen movement and likely smoke paths.
- Avoiding duplicate vision.
- Avoiding spots already covered by allied observers or obvious sentries.

Good sentry placement considers:

- Visible enemy ward target.
- Recent friendly observer disappearance before expected expiration.
- Enemy supports pausing on high ground or known ward cliffs.
- Enemy invisibility threats near active fights.
- Roshan and rune timing.
- Whether the bot can safely stand long enough to place it.

Do not treat a friendly observer's presence as proof that an enemy observer exists. A friendly observer can justify protecting the area, but sentry deward evidence should be separate.

## Item And Ability Usage Guidance

Community scripts that feel better usually invest heavily in item and spell use. The sources consistently call out item builds, ability names, and internal names as a major maintenance surface.

Good ability usage:

- Looks up abilities by internal name when slots are unstable.
- Checks level, cooldown, mana, target validity, spell immunity, invisibility, modifiers, and expected damage.
- Accounts for cast point, projectile timing, channeling, and current active mode.
- Uses save spells defensively, not only offensively.
- Avoids casting into invulnerable, reincarnating, borrowed-time, shallow-grave, or false-promise states unless specifically intended.

Good item usage:

- Tracks modern item charge semantics, including dispenser-like split charge items.
- Does not assume all item APIs exist for every item.
- Uses defensive items before lethal damage, not after a retreat mode already fired.
- Keeps support detection items such as Dust and Sentries tied to enemy invisibility and ward evidence.
- Updates item builds after every meaningful patch.

## Patch Maintenance

Patch drift is the biggest long-term risk for a Dota bot script. It breaks:

- Internal ability names.
- Ability slots.
- Talent names.
- Item recipes and component chains.
- Neutral item and token behavior.
- Map locations, camp boxes, ward cliffs, Roshan location, gates, Twin Gates, Tormentor, Lotus Pools, Watchers, and Wisdom Runes.
- Hero role assumptions after reworks.

Patch maintenance should be a first-class workflow:

- Pull official patch notes and machine-readable game data where possible.
- Compare `npc_abilities`, `npc_items`, and hero data against current BotLib builds.
- Run scans for removed item or ability names.
- Treat new heroes and reworked heroes as unsafe until their BotLib file is reviewed.
- Keep map data in one module and avoid scattering magic coordinates.

## Architecture Guidance For This Repo

OpenHyperAI already has:

- Loaded engine entry points.
- A central `J` utility hub.
- TypeScript-generated support modules.
- Hand-written Lua mode files.
- Per-hero BotLib files.
- FretBots support.
- Customization layers.

Recommended direction:

- Keep improving loaded modes and helpers.
- Prefer small behavior slices that can be playtested in isolation.
- Keep opportunistic support behavior in roam, ward, or farm contexts instead of adding unknown standalone modes.
- Keep TS-source changes in `typescript/bots/...` for generated modules.
- Avoid new global mutable state unless keyed by bot player ID or explicitly mode-local.
- Add telemetry only if throttled and removable.
- Add Dota logic tests as static scans where real in-game tests are impossible.

Avoid:

- A full rewrite before the current behavior is instrumented and measured.
- A generic "AI brain" that competes with existing modes without clear ownership.
- Broad map or ward rewrites based only on theory.
- Hot-path HTTP or ML calls for regular live gameplay unless a separate framework is intentionally adopted.

## Evaluation Checklist

Before calling a bot improvement good, validate:

- It loads from a known engine entry point.
- It does not crash on nil handles, missing abilities, empty unit lists, or invalid wards.
- It returns mode desires in the correct range.
- It does not preempt retreat, defend, urgent combat, or channeling.
- It has clear state reset paths.
- It has a failure cooldown.
- It works for Radiant and Dire.
- It works before and after laning phase if intended.
- It behaves acceptably when the target dies, disappears, becomes invisible, or enters fog.
- It is playtested in a local lobby with debug overlays or console output.

## Playtest Notes To Capture

When playtesting a change, record:

- Game time.
- Hero and role.
- Active mode if visible.
- Expected behavior.
- Actual behavior.
- Whether enemy heroes were visible.
- Nearby allied heroes.
- Item inventory and ward counts.
- Whether the bot was retreating, defending, pushing, farming, or fighting.
- Console errors.
- Whether `dota_bot_reload_scripts` was used.

For support stacking, record:

- Camp name or location.
- Stack second.
- Bot attack range and projectile status.
- Whether creeps aggroed.
- Whether the bot moved to the pull point.
- Whether the camp actually stacked.
- Whether the bot abandoned a higher-priority job.

For warding or dewarding, record:

- Ward spot.
- Observer or sentry.
- Evidence source.
- Enemy proximity.
- Whether the bot walked into danger.
- Whether it held too many wards before acting.

## Best Next Improvements For This Branch

High confidence:

- Keep hardening nil and invalid-handle risks in touched hot paths.
- Add a lightweight playtest log template and use it after every lobby.
- Improve ward evidence scoring before expanding ward maps.
- Make deward movement safety continuously reevaluate enemy proximity.
- Add explicit objective context to ward desire: Roshan, tower siege, triangle farm, rune control.

Medium confidence:

- Add support smoke behavior only after warding and retreat priority are stable.
- Add camp stacking metrics or debug chat gated behind a config flag.
- Add better item inventory accounting for more modern items.
- Create static scans for action desire constants in mode desire files and raw `GetTeamMember(playerId)` misuse.

Low confidence until more evidence:

- Replacing all ward spots.
- Creating a new standalone stack mode.
- Full takeover architecture.
- External ML controller.
