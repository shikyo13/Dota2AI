# Mode Entrypoints

Generated: 2026-05-01

Every `mode_*_generic.lua` file exports behavior into Dota mode arbitration. Function samples are capped to keep this index navigable.

|Path|Lines|Callbacks|Function Sample|
|-|-|-|-|
|bots/mode_assemble_generic.lua|65|GetDesire, OnEnd, Think|GetDesire, OnEnd, Think|
|bots/mode_assemble_with_humans_generic.lua|7|GetDesire|GetDesire|
|bots/mode_attack_generic.lua|21|GetDesire, OnEnd, OnStart, Think|GetDesire, Think, OnStart, OnEnd|
|bots/mode_defend_tower_bot_generic.lua|11|GetDesire, Think|GetDesire, Think|
|bots/mode_defend_tower_mid_generic.lua|11|GetDesire, Think|GetDesire, Think|
|bots/mode_defend_tower_top_generic.lua|11|GetDesire, Think|GetDesire, Think|
|bots/mode_farm_generic.lua|1210|GetDesire, OnEnd, OnStart, Think|GetDesire, GetDesireHelper, OnStart, OnEnd, Think, X.IsNearLaneFront, X.IsUnitAroundLocation, X.CouldBlade, X.CouldBlink, X.IsLocCanBeSeen, PickOneAnnouncer, AnnounceMessages|
|bots/mode_laning_generic.lua|271|GetDesire, Think|GetDesire, GetFurthestEnemyAttackRange, GetBestLastHitCreep, GetBestDenyCreep, Think, PickOneAnnouncer, AnnounceMessages|
|bots/mode_outpost_generic.lua|183|GetDesire, OnEnd, OnStart, Think|GetDesire, GetDesireHelper, OnStart, OnEnd, Think, GetClosestOutpost, IsEnemyCloserToOutpostLoc, IsSuitableToCaptureOutpost|
|bots/mode_push_tower_bot_generic.lua|11|GetDesire, Think|GetDesire, Think|
|bots/mode_push_tower_mid_generic.lua|11|GetDesire, Think|GetDesire, Think|
|bots/mode_push_tower_top_generic.lua|11|GetDesire, Think|GetDesire, Think|
|bots/mode_retreat_generic.lua|783|GetDesire|scanDroppedForAegis, buildContext, GetDesire, GetDesireHelper, X.LowChanceToRun, X.GetUnitDesire, X.RetreatWhenTowerTargetedDesire, X.ShouldRun, X.ConsiderCompleteItem|
|bots/mode_roam_generic.lua|2015|GetDesire, OnEnd, OnStart, Think|GetDesire, GetDesireHelper, Think, ThinkIndividualRoaming, DoTrample, TrampleToBase, ThinkGeneralRoaming, GeneralReactToStackedDebuff, MoveAwayFromTarget, ActualGankDesire, SetupTwinGates, ThinkActualGankingInLanes|
|bots/mode_roshan_generic.lua|169|GetDesire|GetDesire, GetDesireHelper|
|bots/mode_rune_generic.lua|829|GetDesire, OnEnd, OnStart, Think|IsHumanClaimingRune, GetDesire, OnStart, OnEnd, Think, X.InitRune, X.IsSuitableToPickRune, X.IsNearRune, X.GetBestRune, X.IsTheClosestAlly, X.IsThereAllyWithBottle, X.IsTherePosition|
|bots/mode_secret_shop_generic.lua|177|GetDesire, OnEnd, OnStart, Think|GetDesire, GetDesireHelper, OnStart, OnEnd, Think, X.HaveItemToSell, X.GetPreferedSecretShop, X.IsSuitableToBuy, X.IsStronger|
|bots/mode_side_shop_generic.lua|514|GetDesire, Think|GetDesire, GetDesireHelper, Think, X.IsTormentorAlive, X.IsEnoughAllies, X.GetClosestBot, X.IsTeamHealthy, X.IsGoodRighClickDamage, X.DidHumanPingedOrAtLocation|
|bots/mode_team_roam_generic.lua|1715|GetDesire, OnEnd, OnStart, Think|SetStickyTarget, CapForLanePush, GetDesire, GetDesireHelper, X.GetLastHitCreep, HasModifierThatNeedToAvoidEffects, ConsiderHelpAlly, OnStart, OnEnd, Think, X.SupportFindTarget, X.CarryFindTarget|
|bots/mode_ward_generic.lua|207|GetDesire, Think|GetDesire, GetDesireHelper, Think, X.IsSuitableToWard, X.IsIBecameTheTarget, X.IsEnemyCloserToWardLocation|
