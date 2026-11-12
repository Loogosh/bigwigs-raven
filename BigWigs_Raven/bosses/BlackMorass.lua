-- BigWigs_Raven :: The Black Morass (RavenCraft custom dungeon)
--
-- Ported from the 1.18 fork; the instance is not part of BigWigs v36.

local RavenBW = _G.RavenBW

local ZONE = "The Black Morass"

--------------------------------------------------------------------------------
-- Drifting Avatar of Sand
--

RavenBW:AddBoss("Drifting Avatar of Sand", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Drifting Avatar of Sand", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.sand = "Blinding Sand"
		L.sand_desc = "Duration of Blinding Sand."
		L.sandBar = " Blinded"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "sand" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Sand", "Blinding Sand")
		self:Log("SPELL_AURA_REMOVED", "SandFade", "Blinding Sand")
	end

	function mod:Sand(args)
		self:Bar("sand", 5, (args.destName or "?") .. L.sandBar, "spell_shadow_mindsteal")
	end

	function mod:SandFade(args)
		self:StopBar((args.destName or "?") .. L.sandBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Rotmaw
--

RavenBW:AddBoss("Rotmaw", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Rotmaw", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.rotmaw = "Rotmaw"
		L.rotmaw_desc = "Contagion of Rot and Consume."
		L.contagionBar = " Contagion"
		L.consumeBar = " Consumed"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "rotmaw" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Contagion", "Contagion of Rot")
		self:Log("SPELL_AURA_REMOVED", "ContagionFade", "Contagion of Rot")
		self:Log("SPELL_AURA_APPLIED", "Consume", "Consume")
		self:Log("SPELL_AURA_REMOVED", "ConsumeFade", "Consume")
	end

	function mod:Contagion(args)
		self:Bar("rotmaw", 240, (args.destName or "?") .. L.contagionBar, "spell_shadow_callofbone")
		local _, class = UnitClass("player")
		if class == "PALADIN" or class == "PRIEST" or class == "SHAMAN" then
			self:Flash("rotmaw")
		end
	end

	function mod:ContagionFade(args)
		self:StopBar((args.destName or "?") .. L.contagionBar)
	end

	function mod:Consume(args)
		self:Bar("rotmaw", 15, (args.destName or "?") .. L.consumeBar, "spell_nature_drowsy")
	end

	function mod:ConsumeFade(args)
		self:StopBar((args.destName or "?") .. L.consumeBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Epidamu
--

RavenBW:AddBoss("Epidamu", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Epidamu", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.epidamu = "Epidamu"
		L.epidamu_desc = "Drain Mana and Temporal Conflux."
		L.drainBar = " Drain Mana"
		L.confluxBar = " Temporal Conflux"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "epidamu" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Drain", "Drain Mana")
		self:Log("SPELL_AURA_REMOVED", "DrainFade", "Drain Mana")
		self:Log("SPELL_AURA_APPLIED", "Conflux", "Temporal Conflux")
		self:Log("SPELL_AURA_REMOVED", "ConfluxFade", "Temporal Conflux")
	end

	function mod:Drain(args)
		self:Bar("epidamu", 5, (args.destName or "?") .. L.drainBar, "spell_shadow_siphonmana")
		local _, class = UnitClass("player")
		if class ~= "PALADIN" then
			self:Flash("epidamu")
		end
	end

	function mod:DrainFade(args)
		self:StopBar((args.destName or "?") .. L.drainBar)
	end

	function mod:Conflux(args)
		self:Bar("epidamu", 15, (args.destName or "?") .. L.confluxBar, "spell_holy_borrowedtime")
	end

	function mod:ConfluxFade(args)
		self:StopBar((args.destName or "?") .. L.confluxBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Antnormi
--

RavenBW:AddBoss("Antnormi", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Antnormi", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.antnormi = "Antnormi"
		L.antnormi_desc = "Fear, Shadow Shock and Enrage."
		L.fearCast = "Casting Fear"
		L.fearDur = "Feared!"
		L.fearCd = "Fear CD"
		L.shockCd = "Shadow Shock CD"
		L.enrageMsg = "Enrage!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "antnormi" }
	end

	function mod:OnBossEnable()
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
		self:Log("SPELL_AURA_APPLIED", "Fear", "Cowering Roar")
		self:Log("SPELL_DAMAGE", "Shock", "Shadow Shock")
		self:Log("SPELL_AURA_APPLIED", "Enrage", "Enrage")
	end

	function mod:OnEngage()
		self:Bar("antnormi", 20, L.fearCd, "ability_devour")
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
		if not msg then return end
		if msg:find("preparing for a bellowing roar", 1, true) then
			self:StopBar(L.fearCd)
			self:Bar("antnormi", 7, L.fearCast, "ability_devour")
			if UnitClass("player") == "SHAMAN" then
				self:Flash("antnormi")
			end
		end
	end

	function mod:Fear()
		self:StopBar(L.fearCast)
		self:Bar("antnormi", 5, L.fearDur, "ability_devour")
		self:ScheduleTimer(function()
			self:Bar("antnormi", 20, L.fearCd, "ability_devour")
		end, 5)
	end

	function mod:Shock()
		self:StopBar(L.shockCd)
		self:Bar("antnormi", 10, L.shockCd, "spell_shadow_shadowbolt")
	end

	function mod:Enrage()
		self:Message("antnormi", "red", L.enrageMsg, "Spell_Shadow_UnholyFrenzy")
		self:Flash("antnormi")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Chronar
--

RavenBW:AddBoss("Chronar", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Chronar", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.chronar = "Chronar"
		L.chronar_desc = "Spell Reflection, Mortal Strike and Enrage."
		L.reflectBar = "Spell Reflect"
		L.reflectMsg = "Chronar is reflecting spells!"
		L.msBar = " Mortal Strike"
		L.enrageMsg = "Enrage!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "chronar" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Reflect", "Reflection")
		self:Log("SPELL_AURA_REMOVED", "ReflectFade", "Reflection")
		self:Log("SPELL_AURA_APPLIED", "Ms", "Mortal Strike")
		self:Log("SPELL_AURA_REMOVED", "MsFade", "Mortal Strike")
		self:Log("SPELL_AURA_APPLIED", "Enrage", "Enrage")
	end

	function mod:Reflect()
		self:Bar("chronar", 10, L.reflectBar, "Spell_Arcane_Blink")
		local _, class = UnitClass("player")
		if class ~= "WARRIOR" and class ~= "ROGUE" then
			self:Message("chronar", "red", L.reflectMsg, "Spell_Arcane_Blink")
			self:Flash("chronar")
		end
	end

	function mod:ReflectFade()
		self:StopBar(L.reflectBar)
	end

	function mod:Ms(args)
		self:Bar("chronar", 5, (args.destName or "?") .. L.msBar, "ability_warrior_savageblow")
	end

	function mod:MsFade(args)
		self:StopBar((args.destName or "?") .. L.msBar)
	end

	function mod:Enrage()
		self:Message("chronar", "red", L.enrageMsg, "Spell_Shadow_UnholyFrenzy")
		self:Flash("chronar")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Mossheart
--

RavenBW:AddBoss("Mossheart", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Mossheart", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.mossheart = "Mossheart"
		L.mossheart_desc = "Moss Covered Hands, Entangling Roots, Dredge Sickness and Rejuvenation."
		L.handsBar = " Moss"
		L.rootsBar = "Entangling Roots CD"
		L.rejuvBar = "Rejuvenation"
		L.rejuvMsg = "Mossheart gains Rejuvenation - purge/dispel!"
		L.rootsYell = "The very earth rises in defiance"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "mossheart" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Hands", "Moss Covered Hands")
		self:Log("SPELL_AURA_REMOVED", "HandsFade", "Moss Covered Hands")
		self:Log("SPELL_AURA_APPLIED", "Sickness", "Dredge Sickness")
		self:Log("SPELL_AURA_APPLIED", "Rejuv", "Rejuvenation")
		self:Log("SPELL_AURA_REMOVED", "RejuvFade", "Rejuvenation")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:OnEngage()
		self:Bar("mossheart", 25, L.rootsBar, "spell_nature_stranglevines")
	end

	function mod:Hands(args)
		self:Bar("mossheart", 180, (args.destName or "?") .. L.handsBar, "spell_nature_magicimmunity")
		local _, class = UnitClass("player")
		if class == "PALADIN" or class == "PRIEST" then
			self:Flash("mossheart")
		end
	end

	function mod:HandsFade(args)
		self:StopBar((args.destName or "?") .. L.handsBar)
	end

	function mod:Sickness()
		local _, class = UnitClass("player")
		if class == "PALADIN" or class == "PRIEST" or class == "SHAMAN" then
			self:Flash("mossheart")
		end
	end

	function mod:Rejuv()
		self:Bar("mossheart", 12, L.rejuvBar, "spell_nature_rejuvenation")
		local _, class = UnitClass("player")
		if class == "SHAMAN" or class == "PRIEST" then
			self:Message("mossheart", "red", L.rejuvMsg, "spell_nature_rejuvenation")
			self:Flash("mossheart")
		end
	end

	function mod:RejuvFade()
		self:StopBar(L.rejuvBar)
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find(L.rootsYell, 1, true) then
			self:StopBar(L.rootsBar)
			self:Bar("mossheart", 25, L.rootsBar, "spell_nature_stranglevines")
			local _, class = UnitClass("player")
			if class == "PALADIN" or class == "PRIEST" then
				self:Flash("mossheart")
			end
		elseif msg:find("Who dares defile the sanctity", 1, true) then
			self:Engage()
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Time-Lord Epochronos
--

RavenBW:AddBoss("Time-Lord Epochronos", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Time-Lord Epochronos", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.epo = "Time-Lord Epochronos"
		L.epo_desc = "Sand Breath, Banish, Death & Decay, Devouring Plague and Death Coil."
		L.sandCast = "Sand Breath Cast"
		L.sandCd = "Sand Breath CD"
		L.banishBar = "Banish"
		L.banishMsg = "Kill the spawned mini-boss!"
		L.dndCast = "Casting Death & Decay"
		L.dndMsg = "Casting Death & Decay - interrupt!"
		L.plagueBar = " Devouring Plague"
		L.coilBar = " Death Coil"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "epo" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "Sand", "Sand Breath")
		self:Log("SPELL_AURA_APPLIED", "Banish", "Banish")
		self:Log("SPELL_AURA_REMOVED", "BanishFade", "Banish")
		self:Log("SPELL_CAST_START", "Dnd", "Death & Decay")
		self:Log("SPELL_AURA_APPLIED", "Plague", "Devouring Plague")
		self:Log("SPELL_AURA_REMOVED", "PlagueFade", "Devouring Plague")
		self:Log("SPELL_AURA_APPLIED", "Coil", "Death Coil")
		self:Log("SPELL_AURA_REMOVED", "CoilFade", "Death Coil")
	end

	function mod:Sand()
		self:StopBar(L.sandCd)
		self:Bar("epo", 2, L.sandCast, "spell_fire_windsofwoe")
		self:ScheduleTimer(function()
			self:Bar("epo", 13, L.sandCd, "spell_fire_windsofwoe")
		end, 2)
	end

	function mod:Banish()
		self:Bar("epo", 30, L.banishBar, "spell_shadow_cripple")
		self:Message("epo", "green", L.banishMsg, "spell_shadow_cripple")
	end

	function mod:BanishFade()
		self:StopBar(L.banishBar)
	end

	function mod:Dnd()
		self:Bar("epo", 3, L.dndCast, "spell_shadow_deathanddecay")
		self:Message("epo", "red", L.dndMsg, "spell_shadow_deathanddecay")
	end

	function mod:Plague(args)
		self:Bar("epo", 30, (args.destName or "?") .. L.plagueBar, "spell_shadow_shadetruesight")
	end

	function mod:PlagueFade(args)
		self:StopBar((args.destName or "?") .. L.plagueBar)
	end

	function mod:Coil(args)
		self:Bar("epo", 3, (args.destName or "?") .. L.coilBar, "spell_shadow_deathcoil")
	end

	function mod:CoilFade(args)
		self:StopBar((args.destName or "?") .. L.coilBar)
	end

	return mod
end)
