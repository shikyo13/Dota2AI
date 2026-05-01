# Data Library Index

Generated: 2026-05-01

This folder is the Tier 3L source data library for the Dota2AI bot script. It stores generated ledgers so higher-level docs can stay short and route readers to exact source slices.

|Document|Use|
|-|-|
|[source-coverage.md](source-coverage.md)|Coverage summary, file counts, line counts, largest source files.|
|[module-inventory.md](module-inventory.md)|Full non-third-party file inventory.|
|[dependency-edges.md](dependency-edges.md)|Literal `require`, `dofile`, and TypeScript `import` dependency edges.|
|[runtime-entrypoints.md](runtime-entrypoints.md)|Files called by the Dota bot runtime and their callbacks.|
|[mode-entrypoints.md](mode-entrypoints.md)|Mode files, callback exports, and local function samples.|
|[hero-library.md](hero-library.md)|Hero build and ability logic ledger.|
|[funlib-symbols.md](funlib-symbols.md)|FunLib helper files, dependencies, and function samples.|

## Regeneration Notes

Regenerate this library after structural source edits, large hero changes, TypeScript regeneration, or dependency changes. Keep generated docs free of padded markdown tables and em dash characters.
