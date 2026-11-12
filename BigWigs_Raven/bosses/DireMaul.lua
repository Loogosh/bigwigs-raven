-- BigWigs_Raven :: Dire Maul (RavenCraft additions)
--
-- Dire Maul boss modules from the 1.18 fork; v36 has no Dire Maul pack.

local RavenBW = _G.RavenBW

--------------------------------------------------------------------------------
-- Eye of Kilrogg (Nether portal)
--

RavenBW:AddBoss("Eye of Kilrogg", "Dire Maul", function(zoneId)
	local mod = BigWigs:NewBoss("Eye of Kilrogg", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.eye = "Nether Portal"
		L.eye_desc = "Warn when a Wandering Eye of Kilrogg opens a portal."
		L.portalBar = "Kill the Eye!"
		L.portalEmote = "senses your presence and opens a nether portal"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "eye" }
	end

	function mod:OnBossEnable()
		self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	end

	function mod:CHAT_MSG_MONSTER_EMOTE(_, msg)
		if not msg then return end
		if msg:find(L.portalEmote, 1, true) then
			self:Bar("eye", 4, L.portalBar, "Spell_Shadow_AntiShadow")
			self:Flash("eye")
			self:PlaySound("eye", "alarm")
		end
	end

	function mod:OnUnitDied(name)
		if name ~= "Wandering Eye of Kilrogg" then return end
		self:StopBar(L.portalBar)
	end

	return mod
end, { "Wandering Eye of Kilrogg" })

--------------------------------------------------------------------------------
-- King Gordok
--

RavenBW:AddBoss("King Gordok", "Dire Maul", function(zoneId)
	local mod = BigWigs:NewBoss("King Gordok", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.gordok = "King Gordok"
		L.gordok_desc = "Timers for War Stomp, Mortal Strike and Charge."
		L.stompBar = "War Stomp"
		L.stomp2Bar = "2nd War Stomp"
		L.msBar = "Mortal Strike"
		L.chargeBar = "Charge"
	end
	L = mod:GetLocale()

	local function schedule(self, key, text, icon, min, max)
		local delay = math.random(min, max)
		self:ScheduleTimer(function()
			if not self:IsEngaged() then return end
			self:Bar(key, delay, text, icon)
			schedule(self, key, text, icon, min, max)
		end, delay)
	end

	function mod:GetOptions()
		return { "gordok" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "Stomp", "War Stomp")
		self:Log("SPELL_DAMAGE", "MortalStrike", "Mortal Strike")
		self:Log("SPELL_DAMAGE", "Charge", "Charge")
	end

	function mod:OnEngage()
		self:Bar("gordok", 7, L.stompBar, "Ability_WarStomp")
		schedule(self, "gordok", L.stomp2Bar, "Ability_WarStomp", 27, 38)
		schedule(self, "gordok", L.msBar, "Ability_Warrior_SavageBlow", 15, 25)
		schedule(self, "gordok", L.chargeBar, "Ability_Warrior_Charge", 34, 42)
	end

	function mod:Stomp()
		self:StopBar(L.stomp2Bar)
		self:Bar("gordok", math.random(20, 30), L.stompBar, "Ability_WarStomp")
	end

	function mod:MortalStrike()
		self:StopBar(L.msBar)
		self:Bar("gordok", math.random(12, 20), L.msBar, "Ability_Warrior_SavageBlow")
	end

	function mod:Charge()
		self:StopBar(L.chargeBar)
		self:Bar("gordok", math.random(25, 30), L.chargeBar, "Ability_Warrior_Charge")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Captain Kromcrush
--

RavenBW:AddBoss("Captain Kromcrush", "Dire Maul", function(zoneId)
	local mod = BigWigs:NewBoss("Captain Kromcrush", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.krom = "Captain Kromcrush"
		L.krom_desc = "Fear, Retaliation and the add wave."
		L.fearBar = "Fear CD"
		L.fearMsg = "Feared"
		L.retBar = "Retaliation"
		L.retUp = "Retaliation! Stop melee damage!"
		L.retDown = "Retaliation faded - melee damage go!"
		L.retHurt = "Stop attacking!"
		L.addsMsg = "Adds are up!"
		L.addsYell = "Help me crush these"
	end
	L = mod:GetLocale()

	local lastFear = 0

	function mod:GetOptions()
		return { "krom" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Fear", "Intimidating Shout")
		self:Log("SPELL_AURA_APPLIED", "RetUp", "Retaliation")
		self:Log("SPELL_AURA_REMOVED", "RetDown", "Retaliation")
		self:Log("SPELL_DAMAGE", "RetHurt", "Retaliation")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:OnEngage()
		lastFear = 0
		self:Bar("krom", 11.4, L.fearBar, "spell_shadow_possession")
		if UnitClass("player") == "SHAMAN" then
			self:Flash("krom")
		end
	end

	function mod:Fear()
		if GetTime() < lastFear + 2 then return end
		lastFear = GetTime()
		self:Message("krom", "yellow", L.fearMsg, "spell_shadow_possession")
		self:Bar("krom", 11.4, L.fearBar, "spell_shadow_possession")
	end

	function mod:RetUp()
		self:Message("krom", "red", L.retUp, "ability_warrior_challange")
		self:Bar("krom", 15, L.retBar, "ability_warrior_challange")
		self:Flash("krom")
	end

	function mod:RetDown()
		self:Message("krom", "green", L.retDown)
		self:StopBar(L.retBar)
	end

	function mod:RetHurt(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("krom", "red", L.retHurt, "ability_warrior_challange")
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if msg and msg:find(L.addsYell, 1, true) then
			self:Message("krom", "red", L.addsMsg)
			self:PlaySound("krom", "alarm")
		end
	end

	return mod
end)
