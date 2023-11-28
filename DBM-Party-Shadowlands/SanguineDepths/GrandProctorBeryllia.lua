local mod	= DBM:NewMod(2421, "DBM-Party-Shadowlands", 8, 1189)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220803233609")
mod:SetCreatureID(162102)
mod:SetEncounterID(2362)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_AURA_APPLIED",
	"SPELL_CAST_START 325254 325360 326039"
--	"SPELL_CAST_SUCCESS",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

-- https://www.wowhead.com/ru/npc=162102/верховная-надзирательница-бериллия/эпохальный-журнал-сражений --
local warnRiteofSupremacy			= mod:NewCastAnnounce(325360, 4) --Ритуал превосходства

local specWarnRiteofSupremacy		= mod:NewSpecialWarningMoveTo(325360, nil, nil, nil, 3, 2) --Ритуал превосходства
local specWarnIronSpikes			= mod:NewSpecialWarningDefensive(325254, nil, nil, 2, 1, 2) --Железные шипы
local specWarnEndlessTorment		= mod:NewSpecialWarningMoveAway(326039, nil, nil, nil, 2, 2)
--local specWarnGTFO					= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

local timerIronSpikesCD				= mod:NewCDTimer(31.6, 325254, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON) --Железные шипы Change to next if the custom rule for 2nd cast works out good
local timerRiteofSupremacyCD		= mod:NewNextCountTimer(34.5, 325360, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON) --Ритуал превосходства
local timerRiteofSupremacy			= mod:NewCastTimer(10, 325360, nil, nil, nil, 5, nil, DBM_COMMON_L.DEADLY_ICON) --Ритуал превосходства
local timerEndlessTormentCD			= mod:NewNextTimer(38.8, 326039, nil, nil, nil, 2)

mod:AddRangeFrameOption(6, 325885)

local Radiance = DBM:GetSpellInfo(328737)

mod.vb.spikesCast = 0
mod.vb.tormentCast = 0
mod.vb.riteCast = 0
local tormentTimers = {24.2, 11.3, 32.7, 39.7, 11.3, 31.1}
local spikesTimers = {3.5, 44.1, 32.7, 50.6}
local riteTimers = {11, 38.9, 40, 42.5}

function mod:IronSpikesTarget(targetname, uId) 
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnIronSpikes:Show()
		specWarnIronSpikes:Play("defensive")
	end
end

function mod:OnCombatStart(delay)
	self.vb.spikesCast = 0
	self.vb.tormentCast = 0
	self.vb.riteCast = 0
	timerIronSpikesCD:Start(3.5-delay)
	timerRiteofSupremacyCD:Start(11-delay, 1)
	timerEndlessTormentCD:Start(24.2-delay)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(6)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 325254 then
		self.vb.spikesCast = self.vb.spikesCast + 1
		self:BossTargetScanner(args.sourceGUID, "IronSpikesTarget", 0.1, 2)
		local timer = spikesTimers[self.vb.spikesCast+1] or 32.7
		timerIronSpikesCD:Start(timer)
	elseif spellId == 325360 then
		self.vb.riteCast = self.vb.riteCast + 1
		warnRiteofSupremacy:Show()
		specWarnRiteofSupremacy:Show(Radiance)
		specWarnRiteofSupremacy:Play("findshelter")
		timerRiteofSupremacy:Start()
		local timer = riteTimers[self.vb.riteCast+1] or 38.9
		timerRiteofSupremacyCD:Start(timer, self.vb.riteCast + 1)
	elseif spellId == 326039 then
		self.vb.tormentCast = self.vb.tormentCast + 1
		specWarnEndlessTorment:Show()
		specWarnEndlessTorment:Play("range5")
		local timer = tormentTimers[self.vb.tormentCast+1] or 11.3
		timerEndlessTormentCD:Start(timer)
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 257316 then

	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 194966 then

	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 309991 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257453  then

	end
end
--]]
