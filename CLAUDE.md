# Dota2AI Claude Routing

This repo uses a tiered documentation route for agent work.

Start with:

1. `campaign.md`
2. `AGENTS.md`
3. `docs/_index.md`
4. `docs/tier1-quickref.md`

Use the deeper docs by task:

|Need|Read|
|-|-|
|Architecture|`docs/tier2-architecture.md`|
|Gameplay behavior|`docs/tier2-gameplay-systems.md`|
|Current script reference|`docs/tier3-current-script-reference.md`|
|Patch update process|`docs/PATCH_UPDATE_GUIDE.md`|
|Bot scripting API|`docs/BOT_API_REFERENCE.md`|
|Generated source ledgers|`docs/data/_index.md`|

Keep this file as a router only. Put durable project knowledge in `docs/` and active work state in `campaign.md`.
