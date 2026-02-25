# Documentation Redesign

## Context

Fresh clone of upstream OpenHyperAI in new standalone repo (shikyo13/Dota2AI). Old custom modules wiped. Existing docs reference dead code. Need clean, token-efficient documentation for Claude Code sessions.

## Approach: Layered (Context-Tiered) Docs

Structure docs in tiers by frequency of use. CLAUDE.md indexes them with explicit guidance on when to read what.

## Final File Tree

```
CLAUDE.md                              (~80 lines, always in context)
.claude/CLAUDE.md                      (mirrors root)
docs/
  tier1-quickref.md                    (~150 lines, read every session)
  tier2-architecture.md                (~200 lines, read when editing modules/requires)
  tier2-patch-notes.md                 (~200 lines, read when editing hero configs/items)
  tier3-bot-api-guide.md               (~1310 lines, read specific sections on demand)
```

## File Specifications

### CLAUDE.md (~80 lines)

Rewrite both root and .claude/ versions:
- Remove fork language, custom module references, dev branch
- Update git workflow (main is our branch, upstream remote for syncing)
- Replace documentation table with tiered guidance:

| When | Read |
|------|------|
| Every session | `docs/tier1-quickref.md` |
| Editing module structure / require paths | `docs/tier2-architecture.md` |
| Editing hero configs or item builds | `docs/tier2-patch-notes.md` |
| Specific API questions | `docs/tier3-bot-api-guide.md` (relevant section only) |

### docs/tier1-quickref.md (~150 lines)

Dense, high-signal reference read every session. Four sections:

1. **Dependency Graph** (~40 lines) — Compact text table: engine entry points and what they require, jmz_func lazy-load map, leaf layer. Not every file, just the key load paths.

2. **Lua Gotchas Checklist** (~30 lines) — One-liner bullet list of the ~15 most critical pitfalls from current lua-gotchas.md. No code blocks.

3. **7.40 Breaking Changes** (~30 lines) — Bot-relevant subset only. Changes that affect hero configs or item builds. Sourced from tier2-patch-notes.md.

4. **Anti-Patterns** (~15 lines) — Surviving lessons from previous work: don't duplicate engine API, test one mode file at a time, nil-check everything, desire range 0.0-1.0, no circular requires.

### docs/tier2-architecture.md (~200 lines)

Full architecture reference. Sections:

1. **Bot Execution Flow** — 5-step lifecycle (unchanged from current)
2. **The J Table** — Upstream-only entries (remove J.Log, J.Comms, J.Strategy, J.Desire)
3. **Full Require Graph** — Every FunLib module and its requires, as a table
4. **Hero Config Pattern** — sBuyList, sSellList, sSkillList, exports (unchanged)
5. **TypeScript Pipeline** — Source, build command, output, which modules are TS-compiled
6. **FretBots Difficulty System** — Brief overview
7. **File Layout** — Clean upstream tree
8. **Known Weak Heroes** — Current list

### docs/tier2-patch-notes.md (~200 lines)

Consolidated 7.40/b/c gameplay reference. Scraped from web. Format:

- Reverse chronological (7.40c first)
- Superseding rule: if 7.40c changed something from 7.40b, only 7.40c entry kept
- Every change maps to bot config impact (hero file, item build, or mode logic)
- Three categories per patch: Hero Changes, Item Changes, Map/Mechanic Changes

### docs/tier3-bot-api-guide.md (~1310 lines)

Existing Dota_2_Bot_Scripting_Definitive_Guide.md renamed. Only change: add section index at top (~10 lines) with line ranges so Claude can use Read tool offset/limit for targeted lookups.

## Cleanup

Delete (not archive):
- `docs/architecture.md` — replaced by tier2-architecture.md
- `docs/lua-gotchas.md` — folded into tier1-quickref.md
- `docs/rules-of-engagement.md` — folded into tier1-quickref.md
- `docs/changelog.md` — key lesson folded into tier1 anti-patterns

## Token Budget Analysis

| Scenario | Lines Read | vs Current |
|----------|-----------|------------|
| Routine session | ~230 (CLAUDE.md + tier1) | ~1750 -> 230 (87% reduction) |
| Editing modules | ~430 (+tier2-arch) | Same files, better organized |
| Editing hero configs | ~430 (+tier2-patches) | New capability |
| API lookup | ~280 (+50-100 lines of tier3 section) | vs reading full 1300 |

## Implementation Order

1. Scrape 7.40/b/c patch notes from web
2. Write tier1-quickref.md
3. Write tier2-architecture.md
4. Write tier2-patch-notes.md
5. Add section index to tier3-bot-api-guide.md (rename existing guide)
6. Rewrite both CLAUDE.md files
7. Delete old docs
8. Update memory files
9. Commit everything
