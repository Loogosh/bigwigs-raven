-- BigWigs_Raven :: Molten Core (RavenCraft additions)
--
-- Modules that the 1.18 fork adds on top of the stock BigWigs Molten Core pack:
-- trash timers and the two extra bosses. The stock boss modules stay in
-- BigWigs_MoltenCore; BigWigs_Raven only fills the gaps.

local RavenBW = _G.RavenBW

local CLOCK = "inv_misc_pocketwatch_01"

--------------------------------------------------------------------------------
-- Core Hound (pack respawn / despawn)
--

RavenBW:AddBoss("Core Hound", "Molten Core", function(zoneId)
	local mod = BigWigs:NewBoss("Core Hound", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.respawn = "Core Hound Respawn"
		L.respawn_desc = "Warn when a Core Hound pack collapses."
		L.respawnBar = "Respawn"
		L.respawnMsg = "Kill all Core Hounds within 10 seconds"
		L.despawn = "Core Hound Despawn"
		L.despawn_desc = "Countdown until the corpses despawn."
		L.despawnBar = "Despawn"
		L.despawnMsg = "Corehounds despawned"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "respawn", "despawn" }
	end

	function mod:OnBossEnable()
		self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	end

	function mod:CHAT_MSG_MONSTER_EMOTE(_, msg)
		if not msg then return end
		if msg:find("collapses and begins to smolder", 1, true) then
			self:Message("respawn", "yellow", L.respawnMsg)
			self:Bar("respawn", 10, L.respawnBar, "spell_holy_resurrection")
			self:Bar("despawn", 11, L.despawnBar, CLOCK)
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Lava Surger (Surge stack check)
--

RavenBW:AddBoss("Lava Surger", "Molten Core", function(zoneId)
	local mod = BigWigs:NewBoss("Lava Surger", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.surge = "Surge"
		L.surge_desc = "Warn who the Lava Surger charged."
		L.surgeYou = "S T A C K on the Surger"
		L.surgeOther = " failed to stack on the Surger"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "surge" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "Surge", "Surge")
	end

	function mod:Surge(args)
		local name = args.destName
		if not name then return end
		if name == UnitName("player") then
			self:Message("surge", "red", L.surgeYou, "ability_warrior_charge")
			self:PlaySound("surge", "alarm")
			self:Flash("surge")
		else
			self:Message("surge", "yellow", name .. L.surgeOther, "ability_warrior_charge")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Incindis (Fire Nova after Quaking Stomp)
--

RavenBW:AddBoss("Incindis", "Molten Core", function(zoneId)
	local mod = BigWigs:NewBoss("Incindis", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.firenova = "Fire Nova"
		L.firenova_desc = "Warn for Fire Nova after Quaking Stomp."
		L.firenovaBar = "Fire Nova!"
		L.firenovaMsg = "FIRE NOVA - RUN AWAY!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "firenova" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "QuakingStomp", "Quaking Stomp")
	end

	function mod:QuakingStomp()
		self:StopBar(L.firenovaBar)
		self:Message("firenova", "red", L.firenovaMsg, "spell_fire_selfdestruct")
		self:Bar("firenova", 5.5, L.firenovaBar, "spell_fire_selfdestruct")
		self:PlaySound("firenova", "alarm")
		self:Flash("firenova")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Flame Imp (pack respawn timer)
--

RavenBW:AddBoss("Flame Imp", "Molten Core", function(zoneId)
	local mod = BigWigs:NewBoss("Flame Imp", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.respawn = "Flame Imp Respawn"
		L.respawn_desc = "Countdown until the imp pack respawns."
	end
	L = mod:GetLocale()

	local pack = 0

	function mod:GetOptions()
		return { "respawn" }
	end

	function mod:OnEngage()
		pack = 0
	end

	function mod:OnUnitDied(name)
		if name ~= "Flame Imp" then return end
		pack = pack + 1
		self:Bar("respawn", 420, "Imp Pack " .. pack .. " Respawn", CLOCK)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Ancient Core Hound (debuff tracker)
--

local ANCIENT_DEBUFFS = {
	"Ancient Dread",
	"Ancient Despair",
	"Ground Stomp",
	"Cauterizing Flames",
	"Withering Heat",
	"Ancient Hysteria",
}

RavenBW:AddBoss("Ancient Core Hound", "Molten Core", function(zoneId)
	local mod = BigWigs:NewBoss("Ancient Core Hound", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.bars = "Ancient Core Hound Debuffs"
		L.bars_desc = "Timers and dispel calls for the Ancient Core Hound debuffs."
		L.debuffBar = "Debuff"
		L.despairBar = "Disorient"
		L.stompBar = "Ground Stomp"
		L.dreadMsg = "Ancient Dread - Dispel!"
		L.flamesMsg = "Cauterizing Flames - Dispel!"
		L.heatMsg = "Withering Heat - Dispel!"
		L.hysteriaMsg = "Ancient Hysteria - Decurse!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "bars" }
	end

	function mod:OnBossEnable()
		for i = 1, #ANCIENT_DEBUFFS do
			self:Log("SPELL_AURA_APPLIED", "Debuff", ANCIENT_DEBUFFS[i])
		end
	end

	function mod:OnEngage()
		self:StopBar(L.debuffBar)
		self:Bar("bars", 12, L.debuffBar, "Spell_Shadow_UnholyFrenzy")
	end

	function mod:Debuff(args)
		local name = args.spellName
		local _, class = UnitClass("player")
		self:StopBar(L.debuffBar)
		self:Bar("bars", 14, L.debuffBar, "Spell_Shadow_UnholyFrenzy")

		if name == "Ancient Dread" then
			if class == "PRIEST" or class == "PALADIN" then
				self:Message("bars", "red", L.dreadMsg)
				self:PlaySound("bars", "info")
			end
		elseif name == "Ancient Despair" then
			self:Bar("bars", 5, L.despairBar, "spell_shadow_mindsteal")
		elseif name == "Ground Stomp" then
			self:Bar("bars", 5, L.stompBar, "ability_warstomp")
		elseif name == "Cauterizing Flames" then
			if class == "PRIEST" or class == "PALADIN" then
				self:Message("bars", "red", L.flamesMsg)
				self:PlaySound("bars", "info")
			end
		elseif name == "Withering Heat" then
			if class == "PRIEST" or class == "PALADIN" then
				self:Message("bars", "red", L.heatMsg)
				self:PlaySound("bars", "info")
			end
		elseif name == "Ancient Hysteria" then
			if class == "MAGE" or class == "DRUID" then
				self:Message("bars", "red", L.hysteriaMsg)
				self:PlaySound("bars", "info")
			end
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Twin Golems (Molten Bulwark swap)
--

RavenBW:AddBoss("Twin Golems", "Molten Core", function(zoneId)
	local mod = BigWigs:NewBoss("Twin Golems", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.bulwark = "Molten Bulwark"
		L.bulwark_desc = "Timer and target-switch call for Molten Bulwark."
		L.bulwarkBar = " Bulwark"
		L.switchMsg = "SWITCH to %s"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "bulwark" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "BulwarkGain", "Molten Bulwark")
		self:Log("SPELL_AURA_REMOVED", "BulwarkFade", "Molten Bulwark")
	end

	function mod:BulwarkGain(args)
		local name = args.destName or "?"
		self:Bar("bulwark", 15, name .. L.bulwarkBar, "ability_mage_moltenarmor")
	end

	function mod:BulwarkFade(args)
		local name = args.destName or "?"
		self:StopBar(name .. L.bulwarkBar)
		self:Message("bulwark", "yellow", L.switchMsg:format(name))
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Sorcerer-Thane Thaurissan (runes and floor zone)
--

RavenBW:AddBoss("Sorcerer-Thane Thaurissan", "Molten Core", function(zoneId)
	local mod = BigWigs:NewBoss("Sorcerer-Thane Thaurissan", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.bossName = "Sorcerer-Thane Thaurissan"
		L.runetimers = "Rune Timers"
		L.runetimers_desc = "Timers for Rune of Detonation and Rune of Combustion."
		L.floorwarn = "Rune of Power Warning"
		L.floorwarn_desc = "Warn before the floor zone moves (every 25% health)."
		L.detonationBar = "Detonation (move out)"
		L.combustionBar = "Combustion (get in)"
		L.nextDetonation = "next Detonation Rune"
		L.nextCombustion = "next Combustion Rune"
		L.detonationMsg = "Move out of the Zone - Rune of Detonation"
		L.combustionMsg = "Get into the Zone - Rune of Combustion"
		L.floorMsg = "Floor Zone moving soon! %s%%"
	end
	L = mod:GetLocale()

	local hasDetonation, hasPower, hasCombustion = false, false, false
	local nextFloorWarn

	local function scheduleDetonation(self)
		local delay = math.random(18, 22)
		self:ScheduleTimer(function()
			if not self:IsEngaged() then return end
			self:Bar("runetimers", delay, L.nextDetonation, "Spell_Shadow_Teleport")
			scheduleDetonation(self)
		end, delay)
	end

	function mod:GetOptions()
		return { "runetimers", "floorwarn" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Detonation", "Rune of Detonation")
		self:Log("SPELL_AURA_REMOVED", "DetonationFade", "Rune of Detonation")
		self:Log("SPELL_AURA_APPLIED", "Combustion", "Rune of Combustion")
		self:Log("SPELL_AURA_REMOVED", "CombustionFade", "Rune of Combustion")
		self:Log("SPELL_AURA_APPLIED", "Power", "Rune of Power")
		self:Log("SPELL_AURA_REMOVED", "PowerFade", "Rune of Power")
	end

	function mod:OnEngage()
		hasDetonation, hasPower, hasCombustion = false, false, false
		nextFloorWarn = 75
		scheduleDetonation(self)
		self:ScheduleRepeatingTimer("CheckHealth", 0.5)
	end

	function mod:OnDisengage()
	end

	function mod:Detonation(args)
		self:StopBar(L.detonationBar)
		if args.destName == UnitName("player") then
			hasDetonation = true
			self:Message("runetimers", "red", L.detonationMsg, "Spell_Shadow_Teleport")
			self:PlaySound("runetimers", "alarm")
			self:Bar("runetimers", 6, L.detonationBar, "Spell_Shadow_Teleport")
		end
	end

	function mod:DetonationFade(args)
		if args.destName == UnitName("player") then
			hasDetonation = false
		end
	end

	function mod:Combustion(args)
		self:StopBar(L.combustionBar)
		if args.destName == UnitName("player") then
			hasCombustion = true
			self:Message("runetimers", "red", L.combustionMsg, "Spell_Fire_SealOfFire")
			self:PlaySound("runetimers", "alarm")
			self:Bar("runetimers", 6, L.combustionBar, "Spell_Fire_SealOfFire")
		end
	end

	function mod:CombustionFade(args)
		if args.destName == UnitName("player") then
			hasCombustion = false
		end
	end

	function mod:Power(args)
		if args.destName == UnitName("player") then hasPower = true end
	end

	function mod:PowerFade(args)
		if args.destName == UnitName("player") then hasPower = false end
	end

	function mod:CheckHealth()
		if not self:IsEngaged() then return end
		if UnitName("target") ~= L.bossName and UnitName("target") ~= "Sorcerer-Thane Thaurissan" then
			return
		end
		local max = UnitHealthMax("target")
		if not max or max == 0 then return end
		local percent = math.ceil(100 * UnitHealth("target") / max)
		if nextFloorWarn and percent <= nextFloorWarn + 3 then
			self:Message("floorwarn", "yellow", L.floorMsg:format(nextFloorWarn))
			nextFloorWarn = nextFloorWarn - 25
		end
	end

	return mod
end)
