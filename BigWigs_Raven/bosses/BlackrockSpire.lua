-- BigWigs_Raven :: Blackrock Spire / UBRS (RavenCraft additions)
--
-- UBRS boss modules from the 1.18 fork. The stock BigWigs v36 has no UBRS pack,
-- so these are the only source of timers for the upper spire.

local RavenBW = _G.RavenBW

--------------------------------------------------------------------------------
-- The Beast
--

RavenBW:AddBoss("The Beast", "Blackrock Spire", function(zoneId)
	local mod = BigWigs:NewBoss("The Beast", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.beast = "Terrifying Roar"
		L.beast_desc = "Fear duration and cooldown."
		L.fearDur = "Fear Duration"
		L.fearCd = "Fear CD"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "beast" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Fear", "Terrifying Roar")
	end

	function mod:Fear()
		self:StopBar(L.fearDur)
		self:Bar("beast", 5, L.fearDur, "ability_devour")
		self:ScheduleTimer(function()
			self:Bar("beast", 10, L.fearCd, "ability_devour")
		end, 5)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Pyroguard Emberseer
--

RavenBW:AddBoss("Pyroguard Emberseer", "Blackrock Spire", function(zoneId)
	local mod = BigWigs:NewBoss("Pyroguard Emberseer", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.emberseer = "Fire Nova"
		L.emberseer_desc = "Timer for Fire Nova and a count of dead incarcerators."
		L.firenovaBar = "Fire Nova"
		L.addDead = " Incarcerator dead"
		L.engage = "Ha! Ha! Ha! Thank you for freeing me, fools."
	end
	L = mod:GetLocale()

	local deadAdds = 0

	function mod:GetOptions()
		return { "emberseer" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "FireNova", "Fire Nova")
		self:RegisterEvent("CHAT_MSG_MONSTER_SAY")
	end

	function mod:OnEngage()
		deadAdds = 0
	end

	function mod:CHAT_MSG_MONSTER_SAY(_, msg)
		if msg and msg:find(L.engage, 1, true) then
			self:Engage()
		end
	end

	function mod:FireNova()
		self:StopBar(L.firenovaBar)
		self:Bar("emberseer", 6, L.firenovaBar, "spell_fire_sealoffire")
	end

	function mod:OnUnitDied(name)
		if name ~= "Blackhand Incarcerator" then return end
		deadAdds = deadAdds + 1
		self:Message("emberseer", "yellow", deadAdds .. L.addDead)
	end

	return mod
end, { "Blackhand Incarcerator" })

--------------------------------------------------------------------------------
-- Solakar Flamewreath (Rookery waves)
--

RavenBW:AddBoss("Solakar Flamewreath", "Blackrock Spire", function(zoneId)
	local mod = BigWigs:NewBoss("Solakar Flamewreath", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.solakar = "Rookery Waves"
		L.solakar_desc = "Wave timers, War Stomp and Solakar spawn."
		L.wave1 = "Wave 1/5 - 2 Rookery Hatcher / Guardian"
		L.wave2 = "Wave 2/5 - 2 Rookery Hatcher / Guardian"
		L.wave3 = "Wave 3/5 - 2 Rookery Hatcher / Guardian"
		L.wave4 = "Wave 4/5 - 2 Rookery Hatcher / Guardian"
		L.wave5 = "Wave 5/5 - 2 Rookery Hatcher / Guardian"
		L.bossSpawn = "Solakar spawned!"
		L.stompBar = "Stun!"
		L.engage = "Intruders are destroying our eggs"
		L.spawn = "I am here! Now, puny little worms"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "solakar" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "Stomp", "War Stomp")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:OnEngage()
		self:Message("solakar", "yellow", L.wave1)
		self:ScheduleTimer(function() self:Message("solakar", "yellow", L.wave2) end, 40)
		self:ScheduleTimer(function() self:Message("solakar", "yellow", L.wave3) end, 80)
		self:ScheduleTimer(function() self:Message("solakar", "yellow", L.wave4) end, 115)
		self:ScheduleTimer(function() self:Message("solakar", "yellow", L.wave5) end, 155)
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find(L.engage, 1, true) then
			self:Engage()
		elseif msg:find(L.spawn, 1, true) then
			self:Message("solakar", "red", L.bossSpawn)
			self:PlaySound("solakar", "alarm")
		end
	end

	function mod:Stomp()
		self:Bar("solakar", 5, L.stompBar, "ability_bullrush")
	end

	return mod
end, { "Rookery Hatcher", "Rookery Guardian" })

--------------------------------------------------------------------------------
-- General Drakkisath
--

RavenBW:AddBoss("General Drakkisath", "Blackrock Spire", function(zoneId)
	local mod = BigWigs:NewBoss("General Drakkisath", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.drak = "Drakkisath"
		L.drak_desc = "Conflagration, Flamestrike and the Chromatic Elite Guards."
		L.conflagBar = " Conflag"
		L.conflagMsg = " Conflag"
		L.flameMsg = "Move away from Flamestrike!"
		L.proxyMsg = "Move away from the Conflagrated player!"
		L.addMsg = " add dead"
		L.bringBoss = "Adds are dead, bring Drakkisath back!"
	end
	L = mod:GetLocale()

	local deadAdds = 0

	function mod:GetOptions()
		return { "drak" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Conflag", "Conflagration")
		self:Log("SPELL_AURA_REMOVED", "ConflagFade", "Conflagration")
		self:Log("SPELL_AURA_APPLIED", "Flame", "Flamestrike")
		self:Log("SPELL_DAMAGE", "Proxy", "Conflagration")
	end

	function mod:OnEngage()
		deadAdds = 0
	end

	function mod:Conflag(args)
		local name = args.destName or "?"
		self:Bar("drak", 10, name .. L.conflagBar, "spell_fire_incinerate")
		self:Message("drak", "yellow", name .. L.conflagMsg)
	end

	function mod:ConflagFade(args)
		self:StopBar((args.destName or "?") .. L.conflagBar)
	end

	function mod:Flame(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("drak", "red", L.flameMsg, "spell_fire_selfdestruct")
		self:Flash("drak")
		self:PlaySound("drak", "alarm")
	end

	function mod:Proxy(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("drak", "red", L.proxyMsg, "spell_fire_incinerate")
		self:PlaySound("drak", "alarm")
	end

	function mod:OnUnitDied(name)
		if name ~= "Chromatic Elite Guard" then return end
		deadAdds = deadAdds + 1
		self:Message("drak", "yellow", deadAdds .. L.addMsg)
		if deadAdds == 2 then
			self:Message("drak", "red", L.bringBoss)
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Warchief Rend Blackhand / Gyth (Rookery waves)
--

RavenBW:AddBoss("Warchief Rend Blackhand", "Blackrock Spire", function(zoneId)
	local mod = BigWigs:NewBoss("Warchief Rend Blackhand", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.rend = "Rend / Gyth"
		L.rend_desc = "Flame Breath, Freeze, Whirlwind, Enrage and the seven waves."
		L.breathCast = "Flamebreath"
		L.breathCd = "Flamebreath CD"
		L.freezeMsg = "Dispel Freeze!"
		L.dismountMsg = "Rend has dismounted!"
		L.whirlCast = "Whirlwind!"
		L.whirlCd = "Whirlwind CD"
		L.enrageMsg = "Rend enraged!"
		L.waves = "Wave %d/7"
		L.engage = "Excellent... it would appear as if the meddlesome insects"
		L.bossNext = "THIS CANNOT BE"
	end
	L = mod:GetLocale()

	local wave = 0

	function mod:GetOptions()
		return { "rend" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "Breath", "Flame Breath")
		self:Log("SPELL_AURA_APPLIED", "Freeze", "Freeze")
		self:Log("SPELL_AURA_APPLIED", "Whirl", "Whirlwind")
		self:Log("SPELL_AURA_APPLIED", "Enrage", "Enrage")
		self:Log("SPELL_CAST_SUCCESS", "Dismount", "Summon Rend Blackhand")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:OnEngage()
		wave = 0
		self:Bar("rend", 8, L.breathCast, "Spell_fire_fire")
		self:ScheduleTimer(function()
			self:Bar("rend", 13.5, "Waves start", "Inv_Misc_Pocketwatch_01")
		end, 8)
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find(L.engage, 1, true) then
			self:Engage()
		elseif msg:find(L.bossNext, 1, true) then
			self:Message("rend", "red", "Gyth incoming!", "Inv_Misc_Pocketwatch_01")
		end
	end

	function mod:Breath()
		self:StopBar(L.breathCd)
		self:Bar("rend", 2, L.breathCast, "Spell_fire_fire")
		self:ScheduleTimer(function()
			self:Bar("rend", math.random(8, 18), L.breathCd, "Spell_fire_fire")
		end, 2)
	end

	function mod:Freeze(args)
		local name = args.destName or "?"
		if name == UnitName("player") then
			self:Message("rend", "red", L.freezeMsg, "spell_frost_glacier")
			self:Flash("rend")
		end
	end

	function mod:Whirl()
		self:StopBar(L.whirlCd)
		self:Bar("rend", 1.9, L.whirlCast, "ability_whirlwind")
		self:ScheduleTimer(function()
			self:Bar("rend", 9.6, L.whirlCd, "ability_whirlwind")
		end, 1.9)
	end

	function mod:Enrage()
		self:Message("rend", "red", L.enrageMsg, "spell_shadow_unholyfrenzy")
		self:PlaySound("rend", "alarm")
	end

	function mod:Dismount()
		self:Message("rend", "yellow", L.dismountMsg)
	end

	return mod
end, { "Gyth" })
