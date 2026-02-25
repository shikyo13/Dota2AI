local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
                        ['t25'] = {0, 10},
                        ['t20'] = {0, 10},
                        ['t15'] = {0, 10},
                        ['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
                        {1,2,1,3,1,6,1,2,2,3,6,3,3,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_enchanted_mango",
    "item_blood_grenade",
    "item_priest_outfit",
    "item_mekansm",
    "item_glimmer_cape",--
    "item_guardian_greaves",--
    "item_aghanims_shard",
    "item_force_staff",
    "item_shivas_guard",--
    "item_ultimate_scepter",
    "item_ultimate_scepter_2",
    "item_sheepstick",--
    "item_moon_shard",
    "item_octarine_core",--
}

sRoleItemsBuyList['pos_5'] = {
    "item_blood_grenade",
    "item_mage_outfit",
    "item_ancient_janggo",
    "item_glimmer_cape",
    "item_boots_of_bearing",--
    "item_pipe",
    "item_force_staff",
    "item_shivas_guard",--
    "item_cyclone",
    "item_sheepstick",--
    "item_wind_waker",
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_4']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_black_king_bar",
    "item_quelling_blade",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
end

return X
