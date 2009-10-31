if not QueryQuestsCompleted then return end
--------------------------------------------------------------------------------
-- Module declaration
--

local mod = BigWigs:NewBoss("Lady Deathwhisper", "Icecrown Citadel")
if not mod then return end
mod:RegisterEnableMob(36855)
mod.toggleOptions = {71289, 71001, "berserk", "bosskill"}

--71289 Dominate Mind
--71001 Death&Decay
--70842 --mana barrier
--------------------------------------------------------------------------------
-- Locals
--

local pName = UnitName("player")

--------------------------------------------------------------------------------
--  Localization
--

local L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs: Lady Deathwhisper", "enUS", true)
if L then
	L.dnd_message = "Death and Decay on YOU!"
	L.Phase2 = "Phase 2"
end
local L = LibStub("AceLocale-3.0"):GetLocale("Big Wigs: Lady Deathwhisper")
mod.locale = L

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()

	--self:Log("SPELL_CAST_SUCCESS", "DnD_cast", 71001) --timer+cd?
	self:Log("SPELL_AURA_APPLIED", "DnD_aura", 71001)
	self:Log("SPELL_AURA_REMOVED", "Manabarrier", 70482)
	self:Log("SPELL_AURA_APPLIED", "DominateMind", 71289)
	self:Death("Win", 36855)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
end

