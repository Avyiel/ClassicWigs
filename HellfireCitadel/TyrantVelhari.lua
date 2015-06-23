
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Tyrant Velhari", 1026, 1394)
if not mod then return end
mod:RegisterEnableMob(90269, 93439) -- 90269 on beta
mod.engageId = 1784

--------------------------------------------------------------------------------
-- Locals
--

local phase = 1
local mobCollector = {}
local annihilatingStrikeCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.add_warnings = "Add Spawn Warnings"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		--[[ Stage One: Oppression ]]--
		180004, -- Enforcer's Onslaught
		{180260, "SAY"}, -- Annihilating Strike
		{180300, "FLASH", "PROXIMITY"}, -- Infernal Tempest
		-11155, -- Ancient Enforcer
		--[[ Stage Two: Contempt ]]--
		180533, -- Tainted Shadows
		180025, -- Harbinger's Mending
		{180526, "SAY", "FLASH"}, -- Font of Corruption
		-11163, -- Ancient Harbinger
		--[[ Stage Three: Malice ]]--
		180608, -- Gavel of the Tyrant
		180040, -- Sovereign's Ward
		-11170, -- Ancient Sovereign
		--[[ General ]]--
		{180000, "TANK"}, -- Seal of Decay
		{185237, "FLASH"}, -- Touch of Harm
		{182459, "SAY", "PROXIMITY", "ICON"}, -- Edict of Condemnation
	}, {
		[180004] = -11151, -- Stage One: Oppression
		[180533] = -11158, -- Stage Two: Contempt
		[180608] = -11166, -- Stage Three: Malice
		[180000] = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "EnforcersOnslaught", 180004)
	self:Log("SPELL_CAST_START", "AnnihilatingStrike", 180260)
	self:Log("SPELL_CAST_START", "InfernalTempestStart", 180300)
	self:Log("SPELL_CAST_SUCCESS", "InfernalTempestEnd", 180300)

	self:Log("SPELL_AURA_APPLIED", "FontOfCorruption", 180526)

	self:Log("SPELL_CAST_START", "TaintedShadows", 180533)
	self:Log("SPELL_CAST_START", "HarbingersMending", 180025, 181990)
	self:Log("SPELL_AURA_APPLIED", "HarbingersMendingApplied", 180025, 181990)

	self:Log("SPELL_CAST_START", "GavelOfTheTyrant", 180608)
	self:Log("SPELL_AURA_APPLIED", "SovereignsWard", 180040)

	self:Log("SPELL_AURA_APPLIED", "SealOfDecay", 180000)
	self:Log("SPELL_AURA_APPLIED_DOSE", "SealOfDecay", 180000)
	self:Log("SPELL_AURA_APPLIED", "TouchOfHarmOriginal", 185237, 180166) -- Caster: Boss; MythicID, HeroicID XXX add normal and lfr ids ::if:: they are different
	self:Log("SPELL_AURA_APPLIED", "TouchOfHarmJumper", 185238, 180164) -- Dispelled version, caster: Environment; MythicID, HeroicID XXX add normal and lfr ids ::if:: they are different
	self:Log("SPELL_AURA_APPLIED", "EdictOfCondemnation", 182459,185241)
	self:Log("SPELL_AURA_REMOVED", "EdictOfCondemnationRemoved", 182459, 185241)

	self:Log("SPELL_CAST_SUCCESS", "AuraOfContempt", 179986) -- Phase 2
	self:Log("SPELL_CAST_SUCCESS", "AuraOfMalice", 179991) -- Phase 3

	self:Death("Deaths", 90270, 90271)
end

function mod:OnEngage()
	wipe(mobCollector)
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")

	self:Bar(180300, 40) -- Infernal Tempest
	self:Bar(180260, 10) -- Annihilating Strike
	self:Bar(182459, 57) -- Edict of Condemnation
	self:Bar(185237, 16) -- Touch of Harm

end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local adds = {
		[90270] = -11155, -- Ancient Enforcer
		[91304] = -11155, -- Ancient Enforcer
		[91302] = -11163, -- Ancient Harbinger
		[90271] = -11163, -- Ancient Harbinger
		[90272] = -11170, -- Ancient Sovereign
		[91303] = -11170, -- Ancient Sovereign
	}
	function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
		for i = 1, 5 do
			local guid = UnitGUID("boss"..i)
			if guid and not mobCollector[guid] then
				mobCollector[guid] = true
				local id = adds[self:MobId(guid)]
				if id then
					self:Message(id, "Neutral", nil, CL.spawned:format(self:SpellName(id)), false)
				end
			end
		end
	end
end

-- Stage 1
function mod:EnforcersOnslaught(args)
	self:CDBar(args.spellId, 11)
	self:Message(args.spellId, "Attention", nil, CL.casting:format(args.spellName))
end

do
	local function printTarget(self, name, guid)
		self:TargetMessage(180260, name, "Attention", "Info", nil, nil, true)
		if self:Me(guid) then
			self:Say(180260)
		end
	end
	function mod:AnnihilatingStrike(args)
		annihilatingStrikeCount = annihilatingStrikeCount + 1
		self:GetBossTarget(printTarget, 0.2, args.sourceGUID)
		self:Bar(args.spellId, 3, CL.cast:format(args.spellName))
		self:Bar(args.spellId, annihilatingStrikeCount % 3 == 0 and 20 or 10) -- 3 strikes between infernal tempests
	end
end

function mod:InfernalTempestStart(args)
	self:Message(args.spellId, "Attention", "Warning", CL.incoming:format(args.spellName))
	self:Bar(args.spellId, 6.5, CL.cast:format(args.spellName))
	self:Bar(args.spellId, 40)
	self:OpenProximity(args.spellId, 3) -- 2+1 for safety

end

function mod:InfernalTempestEnd(args)
	self:CloseProximity(args.spellId)
end

-- Stage 2

function mod:AuraOfContempt()
	self:StopBar(180300) -- Infernal Tempest
	self:StopBar(180260) -- Annihilating Strike
	self:Bar(180526, 22) -- Font of Corruption, 2sec cast + 20sec timer
end

do
	local function printTarget(self, name, guid)
		self:TargetMessage(180533, name, "Important", "Alert")
	end
	function mod:TaintedShadows(args)
		self:GetUnitTarget(printTarget, 0.2, args.sourceGUID)
	end
end

function mod:HarbingersMending(args)
	self:CDBar(180025, 11)
	self:Message(180025, "Attention", "Info", CL.casting:format(args.spellName))
end

function mod:HarbingersMendingApplied(args)
	self:TargetMessage(180025, args.destName, "Attention", "Info", nil, nil, true)
end

function mod:FontOfCorruption(args)
	self:Message(args.spellId, "Attention", "Info", args.spellName)
	self:Bar(args.spellId, 20)
	-- mayby add font of corruption targets?
	
	if self:Me(args.destGUID) then
		self:TargetMessage(args.spellId, args.destName, "Personal", "Alarm")
		self:Flash(args.spellId)
		self:Say(args.spellId)
	end
end

-- Stage 3

function mod:AuraOfMalice()
	self:StopBar(180526) -- Font of Corruption
	self:Bar(180608, 30) -- Gavel of the Tyrant
end

function mod:GavelOfTheTyrant(args)
	self:Bar(args.spellId, 40) -- from heroic logs
	self:Message(args.spellId, "Attention", "Info", CL.casting:format(args.spellName))
end

function mod:SovereignsWard(args)
	self:Message(args.spellId, "Urgent", "Long")
end

-- General

function mod:Deaths(args)
	if args.mobId == 90270 then
		self:StopBar(180004) -- Enforcer's Onslaught
	else
		self:StopBar(180025) -- Harbinger's Mending
	end
end
function mod:SealOfDecay(args)
	self:StackMessage(args.spellId, args.destName, args.amount, "Urgent")
end

function mod:TouchOfHarmOriginal(args)
	self:Bar(185237,45)
	self:TargetMessage(185237, args.destName, "Urgent", "Alarm")
	if self:Me(args.destGUID) then
		self:Flash(185237)
	end
end

function mod:TouchOfHarmJumper(args)
	self:TargetMessage(185237, args.destName, "Urgent", "Alarm")
	if self:Me(args.destGUID) then
		self:Flash(185237)
	end
end

do
	local timer1, timer2 = nil, nil
	function mod:EdictOfCondemnation(args)
		self:Bar(182459, 60)
		self:TargetBar(182459, 9, args.destName)
		self:TargetMessage(182459, args.destName, "Important", "Warning", nil, nil, true)
		if self:Me(args.destGUID) then
			self:Say(182459)
			self:OpenProximity(182459, 30)
			timer1 = self:ScheduleTimer("OpenProximity", 3, 182459, 20)
			timer2 = self:ScheduleTimer("OpenProximity", 6, 182459, 10)
		else
			self:OpenProximity(182459, 30, args.destName, true)
			timer1 = self:ScheduleTimer("OpenProximity", 3, 182459, 20, args.destName, true)
			timer2 = self:ScheduleTimer("OpenProximity", 6, 182459, 10, args.destName, true)
		end
		self:PrimaryIcon(182459, args.destName)
	end

	function mod:EdictOfCondemnationRemoved(args)
		self:CancelTimer(timer1)
		self:CancelTimer(timer2)
		timer1, timer2 = nil, nil
		self:CloseProximity(182459)
		self:PrimaryIcon(182459)
		self:StopBar(args.spellName, args.destName)
	end
end