# Documentation Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace outdated docs with a tiered documentation system that cuts routine session token usage by ~87%.

**Architecture:** Four doc tiers: CLAUDE.md (always loaded) -> tier1-quickref (every session) -> tier2 files (on demand) -> tier3 API guide (section lookups). Old docs deleted, not archived.

**Tech Stack:** Markdown, web scraping for patch notes, Git

**Design doc:** `docs/plans/2026-02-25-documentation-redesign.md`

---

### Task 1: Scrape 7.40 Patch Notes

**Files:**
- Output: raw patch data (not saved to file, used as input for Tasks 4 and 2)

**Step 1: Fetch 7.40 base patch notes**

Use WebFetch or WebSearch to get the Dota 2 7.40 patch notes from the official Dota 2 blog or wiki. Look for:
- https://www.dota2.com/patches/7.40
- https://www.dota2.com/patches/7.40b
- https://www.dota2.com/patches/7.40c
- Fallback: https://liquipedia.net/dota2/Patch_7.40

Extract and note:
- Hero ability changes (reworks, new abilities, significant number changes)
- Item changes (new items, removed items, reworked items, recipe changes)
- Map/mechanic changes (Tormentor, Roshan, rune spawns, creep changes, outposts)
- General gameplay changes (gold/XP formulas, tower stats, etc.)

**Step 2: Filter for bot relevance**

From the raw patch data, keep ONLY changes that would require editing:
- `BotLib/hero_*.lua` files (ability changes, talent changes)
- `item_purchase_generic.lua` or hero item builds (item changes)
- `mode_*.lua` files (map/mechanic changes)
- `jmz_func.lua` or FunLib modules (gameplay formula changes)

Discard cosmetic changes, tournament features, UI changes, etc.

---

### Task 2: Write tier1-quickref.md

**Files:**
- Create: `docs/tier1-quickref.md`

**Step 1: Write the dependency graph section (~40 lines)**

Source data from the exploration agent's findings. Structure as:

```markdown
# Quick Reference

## Dependency Graph

### Engine Entry Points
| File | Requires |
|-|-|
| hero_selection.lua | aba_role, utils, captain_mode, custom_loader, aba_hero_pos_weights, localization, aba_team_names, FretBots/matchups_data |
| bot_generic.lua | utils |
| item_purchase_generic.lua | jmz_func, aba_item, aba_role, utils, BotLib/hero_* |
| ability_item_usage_generic.lua | jmz_func, utils, localization, Customize/general, BotLib/hero_* |
| mode_*_generic.lua | jmz_func (most), plus: aba_defend, aba_push, aba_item, aba_role, utils, Customize/general (varies) |

### Core Hub: jmz_func.lua (lazy-loads)
J.Site=aba_site, J.Item=aba_item, J.Buff=aba_buff, J.Role=aba_role,
J.Skill=aba_skill, J.Chat=aba_chat, J.Utils=utils, J.Customize=custom_loader

### Leaf Layer (no game-logic deps)
ts_libs/dota/index, ts_libs/utils/json, localization, version, aba_buff
```

**Step 2: Write the Lua gotchas checklist (~30 lines)**

Compress content from existing `docs/lua-gotchas.md` into one-liner bullets. Include all items from the "Common Mistakes Checklist" section plus the most critical gotchas. No code blocks  -  just terse reminders.

```markdown
## Lua Gotchas Checklist
- `GetItemInSlot()` returns handle  -  use `:GetName()`, never compare to string
- `FindItemSlot()` returns -1 when not found  -  check `>= 0`, not truthy
- `GetNearbyHeroes()` can return nil  -  nil-check before `#`
- `GetHeroLastSeenInfo()` returns array  -  access via `[1].time_since_seen`
- `#array >= 0` is ALWAYS true  -  use `>= 1` for non-empty check
- `not x == false` parses as `(not x) == false`  -  use explicit parens
- `x ~= "a" or x ~= "b"` is ALWAYS true (tautology)  -  use `and`
- `Vector(100 200)` silently subtracts  -  always use comma: `Vector(100, 200)`
- `DotaTime()` is negative pre-game  -  guard modulo operations with `> 0` check
- `GetToggleState()` can return nil  -  check nil explicitly before boolean logic
- Use `BOT_MODE_DESIRE_*` in `GetDesire()`, never `BOT_ACTION_DESIRE_*` (different scales)
- Desire values must be 0.0-1.0  -  never exceed 1.0, never negative
- Guard division: check `coreCount`, `manaRegen`, etc. are non-zero
- Cache `GetNearbyHeroes()`  -  don't call multiple times per frame
- Check `IsChanneling()`, `IsUsingAbility()`, `IsCastingAbility()` before pushing actions
```

**Step 3: Write the 7.40 breaking changes section (~30 lines)**

Distill the ~10 most impactful bot-relevant changes from the patch data scraped in Task 1. Format:

```markdown
## 7.40 Breaking Changes
(Content depends on scrape results  -  ~10 highest-impact items with format:)
- **[Hero/Item/Mechanic]**: [what changed] -> [bot config impact]
```

**Step 4: Write the anti-patterns section (~15 lines)**

Source from existing `docs/rules-of-engagement.md` and `docs/changelog.md` lessons learned:

```markdown
## Anti-Patterns
- Don't duplicate engine API  -  use `GetHeroLastSeenInfo()`, `GetRawOffensivePower()`, `GetEstimatedDamageToTarget()`, `GetNearbyHeroes()` etc. directly
- Don't batch multiple mode file edits  -  test one at a time in-game
- Don't push actions every frame  -  check `IsChanneling()`/`IsUsingAbility()`/`IsCastingAbility()` first
- Don't build centralized desire smoothing  -  apply per-mode as needed
- New modules must NOT circular-require `jmz_func`  -  use lazy-load pattern (`pcall(require)`)
- Guard every bot handle and `GetTeamMember()` return with nil checks
- Desire returns must be 0.0-1.0 range  -  `BOT_MODE_DESIRE_*` not `BOT_ACTION_DESIRE_*`
- Every change must be testable in isolation in-game before making the next change
- Avoid modifying upstream files unnecessarily  -  makes future upstream merges painful
```

**Step 5: Verify line count**

Run: `wc -l docs/tier1-quickref.md`
Expected: 120-160 lines. If over 160, trim the least critical items.

**Step 6: Commit**

```bash
git add docs/tier1-quickref.md
git commit -m "Add tier1 quick reference doc"
```

---

### Task 3: Write tier2-architecture.md

**Files:**
- Create: `docs/tier2-architecture.md`

**Step 1: Write Bot Execution Flow section**

Copy the 5-step lifecycle from existing `docs/architecture.md` lines 1-12. This content is accurate for upstream.

**Step 2: Write J Table section**

Copy the J table from existing `docs/architecture.md` lines 14-28. Remove these rows that were our custom additions:
- `J.Log` | `aba_log.lua`
- `J.Comms` | `aba_comms.lua`
- `J.Strategy` | `aba_strategy.lua`
- `J.Desire` | `aba_desire.lua`

Keep only: J.Site, J.Item, J.Buff, J.Role, J.Skill, J.Chat, J.Utils, J.Customize

Add the circular dependency rule from existing doc line 33.

**Step 3: Write Full Require Graph section**

Create the complete module dependency table. Source data from the exploration agent's findings:

```markdown
## Full Require Graph

| Module | Requires |
|-|-|
| aba_buff | (none) |
| aba_chat | localization, custom_loader, aba_chat_table |
| aba_defend | jmz_func, ts_libs/dota/index, ts_libs/utils/native-operators, utils, Customize/general |
| aba_global_overrides | utils |
| aba_hero_pos_weights | ts_libs/dota/heroes |
| aba_hero_roles_map | ts_libs/dota/heroes |
| aba_item | aba_global_overrides, aba_role |
| aba_minion | minion_lib/utils, Customize/general |
| aba_push | jmz_func, ts_libs/dota/index, Customize/general |
| aba_role | ts_libs/dota/index, utils, aba_hero_roles_map, enemy_role_estimation |
| aba_site | ts_libs/dota/index, utils |
| aba_skill | utils |
| aba_special_units | jmz_func |
| aba_team_names | utils |
| aba_ward_utility | jmz_func |
| captain_mode | ts_libs/dota/index, aba_role |
| enemy_role_estimation | ts_libs/dota/index, utils |
| localization | (none) |
| morphling_utility | jmz_func |
| rubick_utility | jmz_func, rubick_hero/* (20+ modules) |
| spell_list | (none) |
| spell_prob_list | (none) |
| techies_utility | jmz_func |
| utils | ts_libs/dota/index, ts_libs/utils/http_req, ts_libs/utils/native-operators, ts_libs/dota/heroes, ts_libs/utils/json |
| version | (none) |
```

**Step 4: Write Hero Config Pattern section**

Copy from existing `docs/architecture.md` lines 51-62 (hero config pattern). Unchanged  -  still accurate.

**Step 5: Write TypeScript Pipeline section (new)**

```markdown
## TypeScript -> Lua Pipeline

Source: `typescript/bots/` (26 files)
Build: `npm run build:lua` (TSTL + post-process require paths)
Output: Compiled Lua in `bots/` alongside hand-written Lua

TS-compiled modules: utils, aba_role, aba_defend, aba_push, aba_site,
enemy_role_estimation, captain_mode, aba_hero_pos_weights, aba_hero_roles_map

Hand-written Lua: jmz_func, aba_item, aba_buff, aba_skill, aba_chat,
all BotLib/hero_*, all mode_*, hero_selection, bot_generic,
item_purchase_generic, ability_item_usage_generic
```

**Step 6: Write FretBots, File Layout, and Known Weak Heroes sections**

- FretBots: copy from existing architecture.md lines 64-69
- File Layout: copy from existing architecture.md lines 76-112, but remove lines 96-102 (our custom module references: aba_log, aba_comms, aba_support, aba_deward, aba_strategy, aba_item_counter, aba_desire)
- Known Weak Heroes: copy from existing architecture.md lines 71-74

**Step 7: Verify line count**

Run: `wc -l docs/tier2-architecture.md`
Expected: 160-210 lines.

**Step 8: Commit**

```bash
git add docs/tier2-architecture.md
git commit -m "Add tier2 architecture reference"
```

---

### Task 4: Write tier2-patch-notes.md

**Files:**
- Create: `docs/tier2-patch-notes.md`

**Step 1: Organize scraped patch data**

Using the data from Task 1, write the full patch notes doc. Structure:

```markdown
# Patch Notes (Bot-Relevant)

Consult when editing BotLib/hero_*.lua or item builds in sBuyList/sSellList.
Each entry shows what changed and which bot config it affects.

## 7.40c
### Hero Changes
- **Hero Name**: [change] -> [impact on hero_*.lua config]

### Item Changes
- **Item Name**: [change] -> [impact on sBuyList/sSellList]

### Map / Mechanic Changes
- [change] -> [impact on mode_*.lua or jmz_func.lua]

## 7.40b
(Same format. ONLY include changes NOT superseded by 7.40c.)

## 7.40
(Same format. ONLY include changes NOT superseded by 7.40b or 7.40c.)

## Stale Code References
List any inline patch comments in the codebase that reference
outdated behavior (e.g., a comment saying "7.33 change" for
something that was changed again in 7.40).
```

**Step 2: Apply superseding rule**

Review all three patches. If 7.40c modified something from 7.40b, remove the 7.40b entry and keep only 7.40c. The most recent state is the source of truth.

**Step 3: Verify line count**

Run: `wc -l docs/tier2-patch-notes.md`
Expected: 150-220 lines.

**Step 4: Commit**

```bash
git add docs/tier2-patch-notes.md
git commit -m "Add tier2 patch notes (7.40/b/c)"
```

---

### Task 5: Add Section Index to API Guide and Rename

**Files:**
- Rename: `docs/Dota_2_Bot_Scripting_Definitive_Guide.md` -> `docs/tier3-bot-api-guide.md`
- Modify: `docs/tier3-bot-api-guide.md` (add index at top)

**Step 1: Rename the file**

```bash
cd /d/Dev/Projects/Dota2AI
git mv docs/Dota_2_Bot_Scripting_Definitive_Guide.md docs/tier3-bot-api-guide.md
```

**Step 2: Add section index at top**

Insert after line 1 (the title), before line 2 (the intro paragraph). The index uses the actual line numbers from the current file (adjust +12 for the inserted index itself):

```markdown
## Section Index
| # | Topic | Read Lines |
|-|-|-|
| 1 | Environment Setup | 23-68 |
| 2 | Architecture: Three-Tier Hierarchy | 70-107 |
| 3 | File Naming & Override System | 108-210 |
| 4 | Team-Level Desires | 211-243 |
| 5 | Hero Selection & Lane Assignment | 244-289 |
| 6 | Desire System: Preventing Oscillation | 290-435 |
| 7 | Action Stack Management | 436-530 |
| 8 | Item Builds | 531-611 |
| 9 | Ability Builds & Combat Usage | 612-729 |
| 10 | Inter-Bot Coordination | 730-810 |
| 11 | Movement & Pathfinding | 811-880 |
| 12 | External Infrastructure & ML | 881-892 |
| 13 | Bot Difficulties | 893-912 |
| 14 | Hero Power & Potential Locations | 913-937 |
| 15 | Complete API Reference | 938-1135 |
| 16 | Constants Reference | 1136-1234 |
| 17 | Common Pitfalls | 1235-1268 |
| 18 | Advanced AI Architectures | 1269-1288 |
| 19 | Essential Resources | 1289-1312 |

> Use Read tool with `offset` and `limit` to load specific sections.
```

Note: After inserting the index (~14 lines), all subsequent line numbers shift by +12. Verify the actual offsets after insertion and adjust the table to match.

**Step 3: Verify the index is accurate**

Spot-check 3 sections by reading them with offset/limit:
- Section 6 (Desire System)  -  should start with `## 6. The Desire System`
- Section 15 (API Reference)  -  should start with `## 15. Complete API Reference`
- Section 17 (Common Pitfalls)  -  should start with `## 17. Common Pitfalls`

If offsets are wrong, adjust the index table.

**Step 4: Commit**

```bash
git add docs/tier3-bot-api-guide.md
git commit -m "Rename API guide to tier3, add section index for targeted reads"
```

---

### Task 6: Rewrite Both CLAUDE.md Files

**Files:**
- Modify: `CLAUDE.md` (root)
- Modify: `.claude/CLAUDE.md`

**Step 1: Write root CLAUDE.md**

Rewrite to ~80 lines. Key changes from current:
- First line: `# Dota2AI - Bot Scripts` (not "Fork of")
- Second line: `Based on [OpenHyperAI](https://github.com/forest0xia/dota2bot-OpenHyperAI). Lua bot AI for 127 heroes, TypeScript modules via TSTL.`
- Bot Lifecycle: unchanged
- Key Directories: unchanged
- Build Commands: unchanged
- Paths: unchanged
- Git Workflow section becomes:
  ```
  ## Git Workflow
  - **`main`**  -  Development branch
  - **`upstream`** remote  -  Sync with OpenHyperAI: `git fetch upstream && git merge upstream/main`
  ```
- Testing Workflow: unchanged
- Coding Conventions: unchanged
- Documentation section becomes tiered guidance:
  ```
  ## Documentation
  | When | Read |
|-|-|
  | Every session | `docs/tier1-quickref.md` (~150 lines) |
  | Editing module structure / require paths | `docs/tier2-architecture.md` |
  | Editing hero configs or item builds | `docs/tier2-patch-notes.md` |
  | Specific API questions (GetDesire, Think, etc.) | `docs/tier3-bot-api-guide.md`  -  check Section Index, read only relevant section |
  ```

**Step 2: Write .claude/CLAUDE.md**

Mirror root CLAUDE.md exactly.

**Step 3: Verify line count**

Run: `wc -l CLAUDE.md .claude/CLAUDE.md`
Expected: both ~75-85 lines.

**Step 4: Commit**

```bash
git add CLAUDE.md .claude/CLAUDE.md
git commit -m "Rewrite CLAUDE.md files for tiered doc system"
```

---

### Task 7: Delete Old Docs

**Files:**
- Delete: `docs/architecture.md`
- Delete: `docs/lua-gotchas.md`
- Delete: `docs/rules-of-engagement.md`
- Delete: `docs/changelog.md`

**Step 1: Remove old doc files**

```bash
cd /d/Dev/Projects/Dota2AI
rm docs/architecture.md docs/lua-gotchas.md docs/rules-of-engagement.md docs/changelog.md
```

**Step 2: Verify only tiered docs remain**

```bash
ls docs/
```

Expected output:
```
plans/
tier1-quickref.md
tier2-architecture.md
tier2-patch-notes.md
tier3-bot-api-guide.md
```

**Step 3: Commit**

```bash
git add -A docs/architecture.md docs/lua-gotchas.md docs/rules-of-engagement.md docs/changelog.md
git commit -m "Remove old docs (replaced by tiered system)"
```

---

### Task 8: Update Memory Files

**Files:**
- Modify: `C:\Users\Zero\.claude\projects\D--Dev-Projects-Dota2AI\memory\MEMORY.md`

**Step 1: Update MEMORY.md**

Update the Documentation Structure section to reflect the new tiered system. Remove references to old doc files. Update Current Status to reflect the clean repo with new docs.

Key changes:
- Documentation Structure section lists tier1/tier2/tier3 files
- Remove "Detailed Notes" section referencing architecture.md, review-findings.md, review-phase7.md
- Update Project Setup to reflect new repo name/URL

**Step 2: Check for stale memory files**

```bash
ls "C:\Users\Zero\.claude\projects\D--Dev-Projects-Dota2AI\memory\"
```

Delete any stale files (review-findings.md, review-phase7.md, architecture.md) that reference the old codebase if they exist.

**Step 3: Commit (no git  -  memory is outside repo)**

Memory files are outside the git repo. No commit needed.

---

### Task 9: Final Verification

**Step 1: Run full file tree check**

```bash
cd /d/Dev/Projects/Dota2AI
ls CLAUDE.md .claude/CLAUDE.md docs/
wc -l CLAUDE.md docs/tier1-quickref.md docs/tier2-architecture.md docs/tier2-patch-notes.md docs/tier3-bot-api-guide.md
```

Expected:
- CLAUDE.md: 75-85 lines
- tier1-quickref.md: 120-160 lines
- tier2-architecture.md: 160-210 lines
- tier2-patch-notes.md: 150-220 lines
- tier3-bot-api-guide.md: ~1310 lines

**Step 2: Verify no broken cross-references**

```bash
cd /d/Dev/Projects/Dota2AI
grep -r "reference docs/" . --include="*.md"
grep -r "architecture.md" . --include="*.md" | grep -v tier2 | grep -v plans
grep -r "lua-gotchas.md" . --include="*.md" | grep -v plans
grep -r "rules-of-engagement.md" . --include="*.md" | grep -v plans
grep -r "changelog.md" . --include="*.md" | grep -v plans
grep -r "Dota_2_Bot_Scripting_Definitive_Guide" . --include="*.md" | grep -v plans
```

Expected: no results (all old references should be gone).

**Step 3: Verify git status is clean**

```bash
git status
git log --oneline -10
```

Expected: all changes committed, no untracked files except possibly `docs/plans/`.

**Step 4: Push to origin**

```bash
git push origin main
```
