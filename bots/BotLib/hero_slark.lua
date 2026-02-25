----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,2,1,1,1,6,2,2,3,3,6,3,3,2,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {

	"item_melee_carry_outfit",
--	"item_wraith_band",
	"item_diffusal_blade",
	"item_yasha",
	"item_broadsword",
	"item_blitz_knuckles",
	"item_invis_sword",
	"item_sange_and_yasha",--
	"item_aghanims_shard",
	"item_black_king_bar",--
	"item_travel_boots",
	"item_abyssal_blade",--
	"item_silver_edge",--
    "item_disperser",--
	"item_ultimate_scepter",
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_butterfly",--
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = {
	"item_tango",
	"item_double_branches",
	"item_quelling_blade",
	"item_slippers",
	"item_circlet",

	"item_magic_wand",
	"item_wraith_band",
	"item_power_treads",
	"item_diffusal_blade",
	"item_echo_sabre",
	"item_ultimate_scepter",
	"item_aghanims_shard",
	"item_black_king_bar",--
	"item_skadi",--
	"item_basher",
	"item_disperser",--
	"item_abyssal_blade",--
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_orchid",
	"item_bloodthorn",--
	"item_nullifier",--
}

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_2']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_melee_carry' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_slark

7.40: Essence Shift is now innate. Slot 3 = Saltwater Shiv (new).

"Ability1"		"slark_dark_pact"
"Ability2"		"slark_pounce"
"Ability3"		"slark_saltwater_shiv"       -- NEW in 7.40 (autocast attack modifier)
"Ability4"		"slark_depth_shroud"
"Ability6"		"slark_shadow_dance"

Innate: slark_essence_shift

--]]

local abilityQ  = bot:GetAbilityByName('slark_dark_pact')
local abilityW  = bot:GetAbilityByName('slark_pounce')
local abilityE  = bot:GetAbilityByName('slark_saltwater_shiv')
local abilityR  = bot:GetAbilityByName('slark_shadow_dance')
local abilityAS = bot:GetAbilityByName('slark_depth_shroud')
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget
local castASDesire, castASTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )

	-- Saltwater Shiv autocast management (no early return)
	X.ConsiderE()

	castQDesire, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityQ )
		return
	end

	castWDesire, sMotive = X.ConsiderW()
	if castWDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityW )
		return
	end

	castASDesire, castASTarget, sMotive = X.ConsiderAS()
	if castASDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityAS, castASTarget )
		return
	end

	castRDesire, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

--		J.SetQueuePtToINT( bot, true )

		bot:Action_UseAbility( abilityR )
		return
	end

end


function X.ConsiderE()
	if not abilityE or not abilityE:IsTrained() then return end

	if J.IsValidHero(botTarget) then
		if not abilityE:GetAutoCastState()
		then
			abilityE:ToggleAutoCast()
		end
	else
		if abilityE:GetAutoCastState()
		then
			abilityE:ToggleAutoCast()
		end
	end
end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange()
	local nRadius = abilityQ:GetSpecialValueInt( 'radius' )
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = 0
	local nDelay = abilityQ:GetSpecialValueInt( 'delay' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( 800 )
	local hCastTarget = nil
	local sCastMotive = nil

	local vCastLocation = bot:GetExtrapolatedLocation( nDelay )


	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeCount = 0
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
			then
				local enemyLocation = npcEnemy:GetExtrapolatedLocation( nDelay )
				if J.GetLocationToLocationDistance( vCastLocation, enemyLocation ) < nRadius - 30
				then
					nAoeCount = nAoeCount + 1
				end
			end
		end

		if nAoeCount >= 2
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-TeamfightAOE'..nAoeCount
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, 400 )
		then
			local enemyLocation = botTarget:GetExtrapolatedLocation( nDelay )

			if J.GetLocationToLocationDistance( vCastLocation, enemyLocation ) < nRadius - 50
			then
				hCastTarget = botTarget
				sCastMotive = 'Q-Attack:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, sCastMotive
			end
		end
	end



	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 )
						or bot:GetCurrentMovementSpeed() < 200
						or bot:IsRooted() )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-Retreat'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, sCastMotive
			end
		end
	end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and #hAllyList <= 3
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nRadius + 50 , true )
		if ( #laneCreepList >= 4 or ( #laneCreepList >= 3 and nMP > 0.82 ) )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			hCastTarget = creep
			sCastMotive = 'Q-PushAOE'..(#laneCreepList)
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end


	if J.IsFarming( bot )
		and DotaTime() > 6 * 60
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nRadius + 300 )

		if #creepList >= 3
			and J.IsValid( botTarget )
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-FarmAOE'..(#creepList)
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
	    end
	end




	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetSpecialValueInt( 'pounce_distance' )
	local nRadius = nCastRange
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = 0
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nRadius - 80 )
			and not J.IsDisabled( botTarget )
			and bot:IsFacingLocation( botTarget:GetLocation(), 10 )
			and J.CanCastOnNonMagicImmune( botTarget )
		then
			hCastTarget = botTarget
			sCastMotive = 'W-Leash:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end



	if J.IsRetreating( bot )
		and J.IsRunning( bot )
		and ( nSkillLV >= 2 or nHP < 0.7 )
	then
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) or #nInBonusEnemyList >= 3 )
			then
				local neastEnemyHero = nInBonusEnemyList[1]
				if bot:IsFacingLocation( GetAncient(GetTeam()):GetLocation(), 20 )
					and not J.IsInRange( bot, neastEnemyHero, 100 )
				then
					hCastTarget = npcEnemy
					sCastMotive = 'W-Escape:'..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, sCastMotive
				end
			end
		end
	end


	if J.IsStuck( bot )
	then
		hCastTarget = bot
		sCastMotive = 'W-Stuck'..J.Chat.GetNormName( hCastTarget )
		return BOT_ACTION_DESIRE_HIGH, sCastMotive
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderAS()


	if not abilityAS:IsTrained()
		or not abilityAS:IsFullyCastable()
		or bot:HasModifier( "modifier_slark_shadow_dance" )
		or nHP > 0.85
	then return 0 end

	local nSkillLV = abilityAS:GetLevel()
	local nCastRange = abilityAS:GetCastRange()
	local nRadius = 300
	local nCastPoint = abilityAS:GetCastPoint()
	local nManaCost = abilityAS:GetManaCost()
	local nDamage = 0
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( 600 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( 800 )
	local hCastTarget = nil
	local sCastMotive = nil

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, 200 )
			and J.CanCastOnMagicImmune( botTarget )
			and bot:GetAttackTarget() == botTarget
			and not J.IsRunning( botTarget )
		then
			hCastTarget = J.GetFaceTowardDistanceLocation( bot, 100 )
			sCastMotive = 'AS-Attack'..J.Chat.GetNormName( botTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	if J.IsRetreating( bot )
		and J.IsRunning( bot )
		and bot:IsFacingLocation( GetAncient(GetTeam()):GetLocation(), 15 )
	then
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
				and npcEnemy:GetAttackTarget() == bot
				and bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 )
			then
				hCastTarget = J.GetFaceTowardDistanceLocation( bot, 300 )
				sCastMotive = 'AS-Hide'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderR()


	if not abilityR:IsFullyCastable() or nHP > 0.8 then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = 0
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( 600 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( 1000 )
	local hCastTarget = nil
	local sCastMotive = nil


	if J.IsGoingOnSomeone( bot )
	then
		if nHP < 0.76
			and J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, 300 )
			and ( #nInBonusEnemyList >= 2 or nHP < 0.55 )
		then
			hCastTarget = botTarget
			sCastMotive = 'R-Attack:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end




	if J.IsRetreating( bot )
		and nHP < 0.6 and bot:WasRecentlyDamagedByAnyHero( 5.0 )
		and ( X.IsEnemyCastAbility() or nHP < 0.5 or J.IsStunProjectileIncoming( bot, 800 ) )
		and #nInBonusEnemyList >= 1
	then
		hCastTarget = bot
		sCastMotive = 'R-Escape:'..J.Chat.GetNormName( hCastTarget )
		return BOT_ACTION_DESIRE_HIGH, sCastMotive
	end


	return BOT_ACTION_DESIRE_NONE


end


local sIgnoreAbilityIndex = {

	["antimage_blink"] = true,
	["arc_warden_magnetic_field"] = true,
	["arc_warden_spark_wraith"] = true,
	["arc_warden_tempest_double"] = true,
	["chaos_knight_phantasm"] = true,
	["clinkz_burning_army"] = true,
	["death_prophet_exorcism"] = true,
	["dragon_knight_elder_dragon_form"] = true,
	["juggernaut_healing_ward"] = true,
	["necrolyte_death_pulse"] = true,
	["necrolyte_sadist"] = true,
	["omniknight_guardian_angel"] = true,
	["phantom_assassin_blur"] = true,
	["pugna_nether_ward"] = true,
	["skeleton_king_mortal_strike"] = true,
	["sven_warcry"] = true,
	["sven_gods_strength"] = true,
	["templar_assassin_refraction"] = true,
	["templar_assassin_psionic_trap"] = true,
	["windrunner_windrun"] = true,
	["witch_doctor_voodoo_restoration"] = true,

}


function X.IsEnemyCastAbility()

	local enemyList = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )

	for _, npcEnemy in pairs( enemyList )
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
			and npcEnemy:IsFacingLocation( bot:GetLocation(), 30 )
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
			then
				local nAbilityBehavior = nAbility:GetBehavior()
				local sAbilityName = nAbility:GetName()
				if nAbilityBehavior ~= ABILITY_BEHAVIOR_UNIT_TARGET
					and ( npcEnemy:IsBot() or npcEnemy:GetLevel() >= 5 )
					and sIgnoreAbilityIndex[sAbilityName] ~= true
				then
					return true
				end

				if nAbilityBehavior == ABILITY_BEHAVIOR_UNIT_TARGET
					and not npcEnemy:IsBot()
					and npcEnemy:GetLevel() >= 6
					and not J.IsAllyUnitSpell( sAbilityName )
					and ( not J.IsProjectileUnitSpell( sAbilityName ) or J.IsInRange( bot, npcEnemy, 400 ) )
				then
					return true
				end
			end
		end
	end

	return false

end


return X
