local mod	= DBM:NewMod("SanguineDepthsTrash", "DBM-Party-Shadowlands", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220803233609")
--mod:SetModelID(47785)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 320991 321038 326827 328170 326836 334558 324103",
	"SPELL_CAST_SUCCESS 324086 334558",
	"SPELL_AURA_APPLIED 334673 321038 324089 324086",
	"SPELL_AURA_REMOVED 326827"
)

--Кровавые Катакомбы--
--https://www.wowhead.com/guides/sanguine-depths-shadowlands-dungeon-strategy-guide
--TODO, verify echoing thrust actually targets only tank, and that it can be side stepped
--TODO, more trash warnings? this is all that was in guide
--General
local warnZralisEssence						= mod:NewTargetNoFilterAnnounce(324089, 1)
local warnShiningRadiance					= mod:NewTargetNoFilterAnnounce(324086, 1)
local warnDreadBindings						= mod:NewFadesAnnounce(326827, 1)
local warnVolatileTrap						= mod:NewCastAnnounce(334558, 4) --Неустойчивая ловушка

--General
local specWarnVolatileTrap					= mod:NewSpecialWarningYou(334558, nil, nil, nil, 1, 2) --Неустойчивая ловушка
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)
--Notable Kryxis Trash
local specWarnSanctifiedMists				= mod:NewSpecialWarningMove(334673, "Tank", nil, nil, 1, 10)
local specWarnEchoingThrust					= mod:NewSpecialWarningDodge(320991, "Tank", nil, nil, 1, 2)
--Notable Grand Proctor Berylli
local specWarnCurseofSuppression			= mod:NewSpecialWarningInterrupt(326836, "HasInterrupt", nil, nil, 1, 2)
local specWarnCurseofSuppressionDispel		= mod:NewSpecialWarningDispel(326836, "RemoveCurse", nil, nil, 1, 2)
local specWarnWrackSoul						= mod:NewSpecialWarningInterrupt(321038, false, nil, 2, 1, 2)
local specWarnWrackSoulDispel				= mod:NewSpecialWarningDispel(321038, "RemoveMagic", nil, nil, 1, 2)
--Notable General Kaal Trash
local specWarnGloomSquall					= mod:NewSpecialWarningMoveTo(324103, nil, nil, nil, 3, 2) --Порыв мрака
local specWarnGloomSquall2					= mod:NewSpecialWarningUseSpell(324103, nil, nil, nil, 3, 2) --Порыв мрака
--Unknown, user request
local specWarnDreadBindings					= mod:NewSpecialWarningRun(326827, nil, nil, nil, 4, 2)
local specWarnCraggyFracture				= mod:NewSpecialWarningDodge(328170, nil, nil, nil, 2, 2)

--local timerShiningRadiance					= mod:NewCDTimer(35, 324086, nil, nil, nil, 5)

local yellShiningRadiance					= mod:NewYell(324086, nil, nil, nil, "YELL")
local yellVolatileTrap						= mod:NewYell(334558, nil, nil, nil, "YELL") --Неустойчивая ловушка

local shelter = DBM:GetSpellInfo(324086)
local essence = DBM:GetSpellInfo(324089)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc

function mod:VolatileTrapTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnVolatileTrap:Show()
		specWarnVolatileTrap:Play("watchstep")
		yellVolatileTrap:Yell()
	elseif self:AntiSpam(2, 10) then
		warnVolatileTrap:Show()
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 320991 and self:AntiSpam(3, 2) then
		specWarnEchoingThrust:Show()
		specWarnEchoingThrust:Play("shockwave")
	elseif spellId == 326836 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnCurseofSuppression:Show(args.sourceName)
		specWarnCurseofSuppression:Play("kickcast")
	elseif spellId == 321038 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnWrackSoul:Show(args.sourceName)
		specWarnWrackSoul:Play("kickcast")
	elseif spellId == 324103 then --Порыв мрака
		if ExtraActionBarFrame:IsShown() then
			specWarnGloomSquall2:Show(essence)
			specWarnGloomSquall2:Play("useitem")
		else
			specWarnGloomSquall:Show(shelter)
			specWarnGloomSquall:Play("findshelter")
		end
	elseif spellId == 326827 then
		specWarnDreadBindings:Show()
		specWarnDreadBindings:Play("justrun")
	elseif spellId == 328170 and self:AntiSpam(3, 2) then
		specWarnCraggyFracture:Show()
		specWarnCraggyFracture:Play("watchstep")
	elseif spellId == 334558 then --Неустойчивая ловушка
		self:BossTargetScanner(args.sourceGUID, "VolatileTrapTarget", 0.1, 2)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 324086 then
		warnShiningRadiance:Show(args.sourceName)
--		timerShiningRadiance:Start()
		if args:IsPlayerSource() then
			yellShiningRadiance:Yell()
		end
	elseif spellId == 334558 and self:AntiSpam(3, 2) then
		--Using success because it can be interrupted, so we don't want to warn to dodge it unless it's NOT interupted
	--	specWarnVolatileTrap:Show()
	--	specWarnVolatileTrap:Play("watchstep")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 334673 and args:IsDestTypeHostile() and self:AntiSpam(3, 5) then
		specWarnSanctifiedMists:Show()
		specWarnSanctifiedMists:Play("mobout")
	elseif spellId == 326836 and args:IsDestTypePlayer() and self:CheckDispelFilter() and self:AntiSpam(3, 5) then
		specWarnCurseofSuppressionDispel:Show(args.destName)
		specWarnCurseofSuppressionDispel:Play("helpdispel")
	elseif spellId == 321038 and args:IsDestTypePlayer() and self:CheckDispelFilter() and self:AntiSpam(3, 5) then
		specWarnWrackSoulDispel:Show(args.destName)
		specWarnWrackSoulDispel:Play("helpdispel")
	elseif spellId == 324089 then
		warnZralisEssence:Show(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 326827 and args:IsPlayer() then
		warnDreadBindings:Show()
	end
end
