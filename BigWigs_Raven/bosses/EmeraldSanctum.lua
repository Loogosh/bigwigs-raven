-- BigWigs_Raven :: Emerald Sanctum
--
-- Ported from the 1.18 fork (BigWigs 2.x, chat triggers) to the BigWigs v36
-- module API. The 1.12 modules listened for lines like
--   "Erennius begins to cast Wail of Erennius."
-- which the 1.14 client no longer emits; the same information now arrives as
-- SPELL_CAST_START / SPELL_AURA_APPLIED, so the triggers became Log() calls.
--
-- Bars/messages keep the original timings from the 1.18 modules.

local RavenBW = _G.RavenBW

local WAIL_ICON = "Spell_Shadow_ShadeTruesight"
local HOWL_ICON = "Spell_Shadow_AuraOfDarkness"
local VOLLEY_ICON = "Spell_Nature_CorrosiveBreath"
local CLOCK_ICON = "Inv_Misc_Pocketwatch_01"

--------------------------------------------------------------------------------
-- Erennius
--

RavenBW:AddBoss("Erennius", "Emerald Sanctum", function(zoneId)
	local mod, CL = BigWigs:NewBoss("Erennius", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.bossName = "Erennius"

		L.wail = "Wail of Erennius"
		L.wail_desc = "Warn for Wail of Erennius."
		L.wailCast = "Wail Casting"
		L.wailAfflicted = "Wail Afflicted"
		L.wailCd = "Wail CD"

		L.howl = "Howl of Erennius"
		L.howl_desc = "Warn for Howl of Erennius."
		L.howlAfflicted = "Silenced!"
		L.howlCd = "Silence CD"

		L.volley = "Poison Bolt Volley"
		L.volley_desc = "Warn for Poison Bolt Volley."
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "wail", "howl", "volley" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "WailCast", "Wail of Erennius")
		self:Log("SPELL_AURA_APPLIED", "HowlApplied", "Howl of Erennius")
		self:Log("SPELL_AURA_APPLIED", "VolleyApplied", "Poison Bolt Volley")
	end

	function mod:OnEngage()
		self:StopBar(L.wailCast)
		self:StopBar(L.wailAfflicted)
		self:StopBar(L.wailCd)
		self:StopBar(L.howlAfflicted)
		self:StopBar(L.howlCd)
		self:StopBar(L.volley)
	end

	function mod:WailCast()
		self:StopBar(L.wailCd)
		self:Bar("wail", 6, L.wailCast, WAIL_ICON)
		self:ScheduleTimer(function()
			self:Bar("wail", 3, L.wailAfflicted, WAIL_ICON)
		end, 6)
		self:ScheduleTimer(function()
			self:Bar("wail", 26, L.wailCd, WAIL_ICON)
		end, 9)
	end

	function mod:HowlApplied()
		self:StopBar(L.howlCd)
		self:Bar("howl", 8, L.howlAfflicted, HOWL_ICON)
		self:ScheduleTimer(function()
			self:Bar("howl", math.random(22, 38), L.howlCd, HOWL_ICON)
		end, 8)
	end

	function mod:VolleyApplied()
		self:StopBar(L.volley)
		self:Bar("volley", 12, L.volley, VOLLEY_ICON)
		local _, class = UnitClass("player")
		if class == "SHAMAN" then
			self:Flash("volley")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Solnius (with the Erennius hard mode)
--

RavenBW:AddBoss("Solnius", "Emerald Sanctum", function(zoneId)
	local mod, CL = BigWigs:NewBoss("Solnius", zoneId)
	if not mod then return end
	mod:SetAllowWin(true)

	local L = mod:NewLocale("enUS", true)
	if L then
		L.bossName = "Solnius"

		L.transitions = "Transitions"
		L.transitions_desc = "Warn for Solnius' sleep and immunity phases."

		L.isImmune = "Solnius is Immune"
		L.isSleeping = "Solnius is Sleeping"
		L.sleepMsg = "Mobs incoming! 45 sec to kill"
		L.awakeMsg = "Solnius is awake!"

		L.hardMode = "Hard Mode"
		L.hardMode_desc = "Announce Erennius joining the fight."
		L.hardModeOn = "Erennius is joining the fight; Hard Mode - good luck!"
		L.hardModeOff = "Erennius died before Solnius; Hard Mode cancelled."

		L.engage = "You think you can interfere with my eternal duty?"
		L.hardModeYell = "You will not disturb the Awakener..."
	end
	L = mod:GetLocale()

	local hardMode = false

	function mod:GetOptions()
		return { "transitions", "hardMode" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Sleeping", "Sleep Visual DND")
		self:Log("SPELL_AURA_REMOVED", "Awake", "Sleep Visual DND")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
		self:RegisterEvent("UNIT_HEALTH")
	end

	function mod:OnEngage()
		hardMode = false
		self:StopBar(L.isImmune)
		self:StopBar(L.isSleeping)
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg, sender)
		if msg == L.engage and sender == L.bossName then
			self:Engage()
		elseif msg == L.hardModeYell and self:IsEngaged() then
			hardMode = true
			self:Message("hardMode", "red", L.hardModeOn)
			self:PlaySound("hardMode", "alarm")
		end
	end

	function mod:Sleeping()
		self:StopBar(L.isImmune)
		self:Bar("transitions", 45, L.isSleeping, CLOCK_ICON)
		self:Message("transitions", "red", L.sleepMsg, CLOCK_ICON)
	end

	function mod:Awake()
		self:StopBar(L.isSleeping)
		self:Message("transitions", "yellow", L.awakeMsg)
	end

	function mod:UNIT_HEALTH(_, unit)
		if unit ~= "target" then return end
		if UnitName("target") ~= L.bossName then return end
		local health, max = UnitHealth("target"), UnitHealthMax("target")
		if max and max > 0 and (health / max) < 0.59 then
			self:StopBar(L.isImmune)
			self:Bar("transitions", 600, L.isImmune, CLOCK_ICON)
			self:Message("transitions", "red", L.isImmune, CLOCK_ICON)
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Trash: Sanctum Wyrm
--

RavenBW:AddBoss("Sanctum Wyrm", "Emerald Sanctum", function(zoneId)
	local mod = BigWigs:NewBoss("Sanctum Wyrm", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.volley = "Poison Volley"
		L.volley_desc = "Warn for Poison Bolt Volley."
		L.volleyBar = "Poison Bolt Volley"
		L.volleyMsg = "Get max range to avoid Poison Volley!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "volley" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_SUCCESS", "Volley", "Poison Bolt Volley")
		self:Log("SPELL_DAMAGE", "VolleyHit", "Poison Bolt Volley")
	end

	function mod:Volley()
		self:StopBar(L.volleyBar)
		self:Bar("volley", 15, L.volleyBar, VOLLEY_ICON)
	end

	function mod:VolleyHit(args)
		if args.destName ~= UnitName("player") then return end
		local _, class = UnitClass("player")
		if class == "MAGE" or class == "WARLOCK" or class == "PRIEST" then
			self:Message("volley", "red", L.volleyMsg)
			self:PlaySound("volley", "info")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Trash: Sanctum Wyrmkin
--

RavenBW:AddBoss("Sanctum Wyrmkin", "Emerald Sanctum", function(zoneId)
	local mod = BigWigs:NewBoss("Sanctum Wyrmkin", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.venom = "Wyrmkins Venom"
		L.venom_desc = "Warn for Wyrmkins Venom."
		L.venomBar = " Venom"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "venom" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Venom", "Wyrmkins Venom")
		self:Log("SPELL_AURA_REMOVED", "VenomFade", "Wyrmkins Venom")
	end

	function mod:Venom(args)
		local name = args.destName or "?"
		self:Bar("venom", 30, name .. L.venomBar, "Ability_Creature_Poison_03")
	end

	function mod:VenomFade(args)
		local name = args.destName or "?"
		self:StopBar(name .. L.venomBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Trash: Sanctum Dreamer
--

RavenBW:AddBoss("Sanctum Dreamer", "Emerald Sanctum", function(zoneId)
	local mod = BigWigs:NewBoss("Sanctum Dreamer", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.dreamstate = "Dreamstate"
		L.dreamstate_desc = "Warn for Dreamstate."
		L.dreamBar = "People Sleeping"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "dreamstate" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Sleep", "Dreamstate")
	end

	function mod:Sleep()
		self:StopBar(L.dreamBar)
		self:Bar("dreamstate", 10, L.dreamBar, "Spell_Nature_Sleep")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Trash: Sanctum Supressor
--

RavenBW:AddBoss("Sanctum Supressor", "Emerald Sanctum", function(zoneId)
	local mod = BigWigs:NewBoss("Sanctum Supressor", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.supression = "Emerald Supression"
		L.supression_desc = "Warn for Emerald Supression."
		L.supressionBar = " Supression"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "supression" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Supressed", "Emerald Supression")
		self:Log("SPELL_AURA_REMOVED", "SupressionFade", "Emerald Supression")
	end

	function mod:Supressed(args)
		local name = args.destName or "?"
		self:Bar("supression", 12, name .. L.supressionBar, "Spell_Nature_MagicImmunity")
	end

	function mod:SupressionFade(args)
		local name = args.destName or "?"
		self:StopBar(name .. L.supressionBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Trash: Sanctum Dragonkin
--

RavenBW:AddBoss("Sanctum Dragonkin", "Emerald Sanctum", function(zoneId)
	local mod = BigWigs:NewBoss("Sanctum Dragonkin", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.reflect = "Spell Reflect"
		L.reflect_desc = "Warn for the Dragonkin's spell reflection."
		L.reflectBar = "Dragonkin Spell Reflect"
		L.reflectMsg = "Dragonkin Spell Reflect"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "reflect" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Reflect", "Reflection")
		self:Log("SPELL_AURA_REMOVED", "ReflectFade", "Reflection")
	end

	function mod:Reflect()
		self:StopBar(L.reflectBar)
		self:Bar("reflect", 5, L.reflectBar, "Spell_Arcane_Blink")
		local _, class = UnitClass("player")
		if class == "MAGE" or class == "WARLOCK" then
			self:Flash("reflect")
			self:Message("reflect", "yellow", L.reflectMsg)
		end
	end

	function mod:ReflectFade()
		self:StopBar(L.reflectBar)
	end

	return mod
end)
