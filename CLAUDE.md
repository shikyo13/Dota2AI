# Dota2AI - Bot Scripts

Based on [OpenHyperAI](https://github.com/forest0xia/dota2bot-OpenHyperAI). Lua bot AI for 127 heroes, TypeScript modules via TSTL.

## Bot Lifecycle
1. **Hero Selection** (`bots/hero_selection.lua`) -- Matchup-aware drafting
2. **Bot Init** (`bots/bot_generic.lua`) -- Loads hero config from `BotLib/hero_<name>.lua`
3. **Item Purchase** (`bots/item_purchase_generic.lua`) -- Role-based item builds
4. **Ability Usage** (`bots/ability_item_usage_generic.lua`) -- Generic casting framework
5. **Mode Scripts** (`bots/mode_*_generic.lua`) -- Engine calls `GetDesire()` per mode, runs highest

## Key Directories
| Path | Purpose |
|------|---------|
| `bots/BotLib/` | Per-hero configs (127 files): talents, abilities, items, skill usage |
| `bots/FunLib/` | Shared utility library -- core AI logic (`jmz_func.lua` is the hub) |
| `bots/Customize/` | User settings (picks, bans, names, difficulty) |
| `bots/FretBots/` | Enhanced difficulty system |
| `bots/Buff/` | Buff/modifier handling per hero |
| `typescript/bots/` | TypeScript sources (compile to Lua) |
| `game/` | Game-level overrides |

## Build Commands
```bash
npm run build:lua    # Compile TypeScript to Lua + post-process require paths
npm run dev          # Watch mode
npm run build:node   # Build Node.js scripts (scrapers)
npm run prettier     # Format all code
```
**Note:** `npm install --legacy-peer-deps` required (TS 5.5.4 vs TSTL peer dep 5.5.2).

## Paths
| What | Path |
|------|------|
| Project root | `D:\Dev\Projects\Dota2AI` |
| Bot scripts | `D:\Dev\Projects\Dota2AI\bots` |
| TypeScript source | `D:\Dev\Projects\Dota2AI\typescript` |
| Dota 2 game | `D:\Steamlibrary\steamapps\common\dota 2 beta` |
| Bot symlink | `...\game\dota\scripts\vscripts\bots` -> project `bots/` |

## Git Workflow
- **`main`** -- Development branch
- **`upstream`** remote -- Sync with OpenHyperAI: `git fetch upstream && git merge upstream/main`
- **Always use version control** -- Commit working changes before starting new work. Never leave significant changes uncommitted across sessions.

## Testing Workflow
1. Build: `npm run build:lua`
2. Launch Dota 2, create Local Lobby with bots
3. Observe behavior, check console for `[ERROR]`/`[WARN]`
4. Use `dota_bot_debug_team 2` for desire values, `host_timescale 4.0` for speed

## Coding Conventions
- Lua local modules: `local X = {} ... return X`
- `J` table (from `jmz_func.lua`) is the primary API
- Role-based item builds: `pos_1` through `pos_5`
- Talents: `{left, right}` format, `0` = pick left, `10` = pick right
- Hero names: `npc_dota_hero_<name>`
- TypeScript compiled Lua uses post-processed `require()` paths
- New modules must NOT circular-require `jmz_func` -- use lazy-load pattern

## Documentation
| When | Read |
|------|------|
| Every session | `docs/tier1-quickref.md` (~120 lines) |
| Editing module structure / require paths | `docs/tier2-architecture.md` |
| Editing hero configs or item builds | `docs/tier2-patch-notes.md` |
| Specific API questions (GetDesire, Think, etc.) | `docs/tier3-bot-api-guide.md` -- check Section Index, read only relevant section |
