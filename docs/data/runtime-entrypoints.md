# Runtime Entrypoints

Generated: 2026-05-01

These files are called directly by the Dota bot runtime or by the generic runtime wrappers.

|Path|Lines|Callbacks|Dependencies|
|-|-|-|-|
|bots/ability_item_usage_generic.lua|8430|AbilityLevelUpThink, AbilityUsageThink, BuybackUsageThink, CourierUsageThink, ItemUsageThink|: , [ARDM] dofile FAILED for , [Reload] dofile FAILED for , /BotLib/, /Customize/general, /FunLib/jmz_func, /FunLib/localization, /FunLib/utils, npc_dota_|
|bots/bot_generic.lua|21|MinionThink|/BotLib/, /FunLib/utils, npc_dota_|
|bots/FretBots.lua|185||bots.FretBots.BonusTimers, bots.FretBots.DataTables, bots.FretBots.Debug, bots.FretBots.DynamicDifficulty, bots.FretBots.Flags, bots.FretBots.HeroLoneDruid, bots.FretBots.modifiers.Modifier, bots.FretBots.NeutralItems, bots.FretBots.OnEntityHurt, bots.FretBots.OnEntityKilled, bots.FretBots.RoleDetermination, bots.FretBots.Settings, bots.FretBots.Timers, bots.FretBots.Utilities, bots.FunLib.aba_team_names, bots.FunLib.version|
|bots/hero_selection.lua|1122|GetBotNames, Think, UpdateLaneAssignments|/FretBots/HeroNames, /FretBots/matchups_data, /FunLib/aba_global_overrides, /FunLib/aba_hero_pos_weights, /FunLib/aba_matchups, /FunLib/aba_role, /FunLib/aba_team_names, /FunLib/captain_mode, /FunLib/custom_loader, /FunLib/localization, /FunLib/utils|
|bots/item_purchase_generic.lua|1298|ItemPurchaseThink|/BotLib/, /FunLib/aba_item, /FunLib/aba_role, /FunLib/jmz_func, /FunLib/utils, npc_dota_|
|bots/mode_assemble_generic.lua|65|GetDesire, OnEnd, Think|/FunLib/jmz_func|
|bots/mode_assemble_with_humans_generic.lua|7|GetDesire||
|bots/mode_attack_generic.lua|21|GetDesire, OnEnd, OnStart, Think|/FunLib/override_generic/mode_attack_generic, /FunLib/utils|
|bots/mode_defend_tower_bot_generic.lua|11|GetDesire, Think|/FunLib/aba_defend|
|bots/mode_defend_tower_mid_generic.lua|11|GetDesire, Think|/FunLib/aba_defend|
|bots/mode_defend_tower_top_generic.lua|11|GetDesire, Think|/FunLib/aba_defend|
|bots/mode_farm_generic.lua|1210|GetDesire, OnEnd, OnStart, Think|/Customize/general, /FunLib/jmz_func, /FunLib/localization, /FunLib/utils, /FunLib/version|
|bots/mode_laning_generic.lua|271|GetDesire, Think|/FunLib/jmz_func, /FunLib/localization, /FunLib/override_generic/mode_laning_generic, /FunLib/utils, /FunLib/version|
|bots/mode_outpost_generic.lua|183|GetDesire, OnEnd, OnStart, Think|/Customize/general, /FunLib/jmz_func|
|bots/mode_push_tower_bot_generic.lua|11|GetDesire, Think|/FunLib/aba_push|
|bots/mode_push_tower_mid_generic.lua|11|GetDesire, Think|/FunLib/aba_push|
|bots/mode_push_tower_top_generic.lua|11|GetDesire, Think|/FunLib/aba_push|
|bots/mode_retreat_generic.lua|783|GetDesire|/Customize/general, /FunLib/jmz_func|
|bots/mode_roam_generic.lua|2015|GetDesire, OnEnd, OnStart, Think|/Customize/general, /FunLib/jmz_func|
|bots/mode_roshan_generic.lua|169|GetDesire|/Customize/general, /FunLib/jmz_func|
|bots/mode_rune_generic.lua|829|GetDesire, OnEnd, OnStart, Think|/Customize/general, /FunLib/jmz_func|
|bots/mode_secret_shop_generic.lua|177|GetDesire, OnEnd, OnStart, Think|/Customize/general, /FunLib/jmz_func|
|bots/mode_side_shop_generic.lua|514|GetDesire, Think|/Customize/general, /FunLib/jmz_func, /FunLib/localization|
|bots/mode_team_roam_generic.lua|1715|GetDesire, OnEnd, OnStart, Think|/Customize/general, /FunLib/aba_item, /FunLib/aba_role, /FunLib/aba_special_units, /FunLib/enemy_role_estimation, /FunLib/jmz_func, /FunLib/localization, /FunLib/utils|
|bots/mode_ward_generic.lua|207|GetDesire, Think|/Customize/general, /FunLib/aba_ward_utility, /FunLib/jmz_func|
|game/botsinit.lua|20|||
|game/dkjson.lua|714||debug, dkjson, lpeg|
|game/gameinit.lua|190||game/dkjson|
