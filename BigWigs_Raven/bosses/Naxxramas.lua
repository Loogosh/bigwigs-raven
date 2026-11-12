-- BigWigs_Raven :: Naxxramas (RavenCraft additions)
--
-- Trash modules that the 1.18 fork adds on top of the stock Naxxramas pack:
-- Gargoyle (Stoneskin), Living Monstrosity (Lightning Totem), Patchwork Golem
-- (War Stomp) and the spider trash (Poison Charge).

local RavenBW = _G.RavenBW

--------------------------------------------------------------------------------
-- Gargoyle (Stoneskin)
--

RavenBW:AddBoss("Gargoyle", "Naxxramas", function(zoneId)
	local mod = BigWigs:NewBoss("Gargoyle", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.stoneskin = "Stoneskin"
		L.stoneskin_desc = "Warn when a gargoyle starts casting Stoneskin."
		L.stoneskinMsg = "Casting Stoneskin!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "stoneskin" }
	end

	function mod:OnBossEnable()
		self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	end

	function mod:CHAT_MSG_MONSTER_EMOTE(_, msg)
		if not msg then return end
		if msg:find("emits a strange noise", 1, true) then
			self:Message("stoneskin", "yellow", L.stoneskinMsg, "spell_nature_enchantarmor")
			self:Bar("stoneskin", 6, L.stoneskinMsg, "spell_nature_enchantarmor")
			self:PlaySound("stoneskin", "info")
		end
	end

	return mod
end, { "Stoneskin Gargoyle", "Plagued Gargoyle" })

--------------------------------------------------------------------------------
-- Living Monstrosity (Lightning Totem)
--

RavenBW:AddBoss("Living Monstrosity", "Naxxramas", function(zoneId)
	local mod = BigWigs:NewBoss("Living Monstrosity", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.totem = "Lightning Totem"
		L.totem_desc = "Warn when the Lightning Totem is summoned or destroyed."
		L.totemMsg = "Lightning Totem!"
		L.totemDead = "Totem is dead =)"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "totem" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_SUCCESS", "Totem", "Lightning Totem")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end

	function mod:Totem()
		self:Message("totem", "red", L.totemMsg, "Spell_Nature_Lightning")
		self:Flash("totem")
		self:PlaySound("totem", "alarm")
	end

	function mod:COMBAT_LOG_EVENT_UNFILTERED()
		local _, event, _, _, _, _, _, _, destName = CombatLogGetCurrentEventInfo()
		if event == "UNIT_DIED" and destName == "Lightning Totem" then
			self:Message("totem", "green", L.totemDead, "Spell_Nature_Lightning")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Patchwork Golem (initial War Stomp)
--

RavenBW:AddBoss("Patchwork Golem", "Naxxramas", function(zoneId)
	local mod = BigWigs:NewBoss("Patchwork Golem", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.warstomp = "War Stomp"
		L.warstomp_desc = "Timer for the initial synchronised War Stomp."
		L.warstompBar = "Warstomp"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "warstomp" }
	end

	function mod:OnEngage()
		self:StopBar(L.warstompBar)
		self:Bar("warstomp", 8, L.warstompBar, "ability_bullrush")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Spider trash (Poison Charge)
--

RavenBW:AddBoss("Venom Stalker", "Naxxramas", function(zoneId)
	local mod = BigWigs:NewBoss("Venom Stalker", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.charge = "Poison Charge"
		L.charge_desc = "Timer and personal warning for Poison Charge."
		L.chargeBar = "Poison Charge CD"
		L.chargeWarn = "You've been poisoned, dispel now!"
	end
	L = mod:GetLocale()

	local nextCharge = 1

	local function scheduleCharge(self)
		local delay = math.random(10, 15)
		self:ScheduleTimer(function()
			if not self:IsEngaged() then return end
			self:Bar("charge", delay, L.chargeBar .. " " .. nextCharge, "spell_nature_corrosivebreath")
			scheduleCharge(self)
		end, delay)
	end

	function mod:GetOptions()
		return { "charge" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Charge", "Poison Charge")
	end

	function mod:OnEngage()
		scheduleCharge(self)
	end

	function mod:Charge(args)
		if args.destName == UnitName("player") then
			self:Message("charge", "red", L.chargeWarn, "spell_nature_corrosivebreath")
			self:Flash("charge")
			self:PlaySound("charge", "alarm")
		end
	end

	return mod
end, { "Carrion Spinner", "Necro Stalker" })

--------------------------------------------------------------------------------
-- Deathknight Captain (Whirlwind)
--

RavenBW:AddBoss("Deathknight Captain", "Naxxramas", function(zoneId)
	local mod = BigWigs:NewBoss("Deathknight Captain", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.whirlwind = "Whirlwind"
		L.whirlwind_desc = "Timer and melee warning for Whirlwind."
		L.whirlwindBar = "Whirlwind"
		L.whirlwindCd = "Whirlwind CD"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "whirlwind" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Whirlwind", "Whirlwind")
		self:Log("SPELL_AURA_REMOVED", "WhirlwindFade", "Whirlwind")
	end

	function mod:Whirlwind()
		self:StopBar(L.whirlwindBar)
		self:Bar("whirlwind", 6, L.whirlwindBar, "ability_whirlwind")
		local _, class = UnitClass("player")
		if class == "WARRIOR" or class == "ROGUE" or class == "DRUID" or class == "PALADIN" then
			self:Flash("whirlwind")
		end
	end

	function mod:WhirlwindFade()
		self:StopBar(L.whirlwindBar)
		self:Bar("whirlwind", 9, L.whirlwindCd, "ability_whirlwind")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Deathknight Cavalier (Death Coil)
--

RavenBW:AddBoss("Deathknight Cavalier", "Naxxramas", function(zoneId)
	local mod = BigWigs:NewBoss("Deathknight Cavalier", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.deathcoil = "Death Coil"
		L.deathcoil_desc = "Timer for Death Coil on raid members."
		L.deathcoilBar = " Death Coil"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "deathcoil" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "DeathCoil", "Death Coil")
		self:Log("SPELL_AURA_REMOVED", "DeathCoilFade", "Death Coil")
	end

	function mod:DeathCoil(args)
		local name = args.destName or "?"
		self:Bar("deathcoil", 3, name .. L.deathcoilBar, "spell_shadow_deathcoil")
	end

	function mod:DeathCoilFade(args)
		local name = args.destName or "?"
		self:StopBar(name .. L.deathcoilBar)
	end

	return mod
end, { "Death Lord" })
