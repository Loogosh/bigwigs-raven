-- BigWigs_Raven :: Ahn'Qiraj (RavenCraft additions)
--
-- Trash modules from the 1.18 fork that are missing from the stock AQ40 pack.

local RavenBW = _G.RavenBW

--------------------------------------------------------------------------------
-- Qiraji Champion (Intimidating Shout)
--

RavenBW:AddBoss("Qiraji Champion", "Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("Qiraji Champion", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.fear = "Intimidating Shout"
		L.fear_desc = "Timer for Intimidating Shout."
		L.fearBar = "Intimidating Shout CD"
	end
	L = mod:GetLocale()

	local function scheduleFear(self)
		local delay = math.random(19, 40)
		self:ScheduleTimer(function()
			if not self:IsEngaged() then return end
			self:Bar("fear", delay, L.fearBar, "ability_golemthunderclap")
			scheduleFear(self)
		end, delay)
	end

	function mod:GetOptions()
		return { "fear" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Fear", "Intimidating Shout")
	end

	function mod:OnEngage()
		scheduleFear(self)
	end

	function mod:Fear()
		self:StopBar(L.fearBar)
		self:Bar("fear", math.random(19, 40), L.fearBar, "ability_golemthunderclap")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Anubisath Warder (Fear / Silence / Roots / Dust Cloud)
--

RavenBW:AddBoss("Anubisath Warder", "Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("Anubisath Warder", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.warder = "Warder Abilities"
		L.warder_desc = "Timers and warnings for the Warder's abilities."
		L.fearCast = "Fear!"
		L.fearCd = "Fear CD"
		L.silenceCast = "Silence!"
		L.silenceCd = "Silence CD"
		L.rootsCast = "Roots!"
		L.rootsCd = "Roots CD"
		L.dustCast = "Dust Cloud!"
		L.dustCd = "Dust Cloud CD"

		L.foundFear = "Fear - next ability is Silence or Dust"
		L.foundSilence = "Silence - next ability is Roots or Fear"
		L.foundRoots = "Roots - next ability is Silence or Dust"
		L.foundDust = "Dust - next ability is Roots or Fear"
	end
	L = mod:GetLocale()

	local firstFound = false

	local function schedule(mod, key, text, icon, min, max)
		mod:ScheduleTimer(function()
			if not mod:IsEngaged() then return end
			mod:Bar(key, math.random(min, max), text, icon)
		end, 1.5)
	end

	function mod:GetOptions()
		return { "warder" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "Fear", "Fear")
		self:Log("SPELL_CAST_START", "Silence", "Silence")
		self:Log("SPELL_CAST_START", "Roots", "Entangling Roots")
		self:Log("SPELL_CAST_START", "Dust", "Dust Cloud")
	end

	function mod:OnEngage()
		firstFound = false
	end

	local function abilityWarn(self, text)
		if firstFound then return end
		firstFound = true
		self:Message("warder", "yellow", text)
	end

	function mod:Fear()
		self:Bar("warder", 1.5, L.fearCast, "Spell_Shadow_Possession")
		schedule(self, "warder", L.fearCd, "Spell_Shadow_Possession", 14, 19)
		abilityWarn(self, L.foundFear)
	end

	function mod:Silence()
		self:Bar("warder", 1.5, L.silenceCast, "Spell_Holy_Silence")
		schedule(self, "warder", L.silenceCd, "Spell_Holy_Silence", 10, 26)
		abilityWarn(self, L.foundSilence)
	end

	function mod:Roots()
		self:Bar("warder", 1.5, L.rootsCast, "Spell_Nature_StrangleVines")
		schedule(self, "warder", L.rootsCd, "Spell_Nature_StrangleVines", 15, 15)
		abilityWarn(self, L.foundRoots)
	end

	function mod:Dust()
		self:Bar("warder", 1.5, L.dustCast, "Ability_Hibernation")
		schedule(self, "warder", L.dustCd, "Ability_Hibernation", 14, 18)
		abilityWarn(self, L.foundDust)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Qiraji Brainwasher (Cause Insanity / Mind Flay)
--

RavenBW:AddBoss("Qiraji Brainwasher", "Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("Qiraji Brainwasher", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.mc = "Cause Insanity"
		L.mc_desc = "Timer for Cause Insanity (mind control)."
		L.mcBar = " MC"
		L.mindflay = "Mind Flay"
		L.mindflay_desc = "Timer for Mind Flay."
		L.mindflayBar = " Mind Flay"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "mc", "mindflay" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Mc", "Cause Insanity")
		self:Log("SPELL_AURA_REMOVED", "McFade", "Cause Insanity")
		self:Log("SPELL_AURA_APPLIED", "MindFlay", "Mind Flay")
		self:Log("SPELL_AURA_REMOVED", "MindFlayFade", "Mind Flay")
	end

	function mod:Mc(args)
		local name = args.destName or "?"
		self:Bar("mc", 10, name .. L.mcBar, "spell_shadow_shadowworddominate")
		if name == UnitName("player") then
			self:PlaySound("mc", "alarm")
		end
	end

	function mod:McFade(args)
		local name = args.destName or "?"
		self:StopBar(name .. L.mcBar)
	end

	function mod:MindFlay(args)
		local name = args.destName or "?"
		self:Bar("mindflay", 8, name .. L.mindflayBar, "spell_shadow_siphonmana")
	end

	function mod:MindFlayFade(args)
		local name = args.destName or "?"
		self:StopBar(name .. L.mindflayBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Qiraji Mindslayer (MC / Mind Flay / Mana Burn)
--

RavenBW:AddBoss("Qiraji Mindslayer", "Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("Qiraji Mindslayer", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.bossName = "Qiraji Mindslayer"
		L.mc = "Cause Insanity"
		L.mc_desc = "Warn for Mind Control."
		L.mcBar = " MC"
		L.mcMsg = "MC on "
		L.mindflay = "Mind Flay"
		L.mindflay_desc = "Warn for Mind Flay."
		L.mindflayBar = " Mind Flay"
		L.disorient = "Mana Burn"
		L.disorient_desc = "Warn for Mana Burn and the disorient below 20%."
		L.disorientBar = "Mana Burn & Disorient"
		L.disorientSoon = "Qiraji Mindslayer below 20% - Mana Burn and Disorient soon!"
	end
	L = mod:GetLocale()

	local warned = false

	function mod:GetOptions()
		return { "mc", "mindflay", "disorient" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Mc", "Cause Insanity")
		self:Log("SPELL_AURA_REMOVED", "McFade", "Cause Insanity")
		self:Log("SPELL_AURA_APPLIED", "MindFlay", "Mind Flay")
		self:Log("SPELL_AURA_REMOVED", "MindFlayFade", "Mind Flay")
		self:Log("SPELL_AURA_APPLIED", "ManaBurn", "Mana Burn")
		self:RegisterEvent("UNIT_HEALTH")
	end

	function mod:OnEngage()
		warned = false
	end

	function mod:Mc(args)
		local name = args.destName or "?"
		self:Bar("mc", 9.5, name .. L.mcBar, "Spell_Shadow_Charm")
		self:Message("mc", "yellow", L.mcMsg .. name)
		if name == UnitName("player") then
			self:Flash("mc")
		end
	end

	function mod:McFade(args)
		self:StopBar((args.destName or "?") .. L.mcBar)
	end

	function mod:MindFlay(args)
		self:Bar("mindflay", 8, (args.destName or "?") .. L.mindflayBar, "spell_shadow_siphonmana")
	end

	function mod:MindFlayFade(args)
		self:StopBar((args.destName or "?") .. L.mindflayBar)
	end

	function mod:ManaBurn()
		self:Bar("disorient", 8, L.disorientBar, "spell_shadow_manaburn")
	end

	function mod:UNIT_HEALTH(_, unit)
		if unit ~= "target" or warned then return end
		if UnitName("target") ~= L.bossName and UnitName("target") ~= "Qiraji Mindslayer" then return end
		local max = UnitHealthMax("target")
		if max and max > 0 and (UnitHealth("target") / max) < 0.2 then
			warned = true
			self:Message("disorient", "red", L.disorientSoon, "spell_shadow_manaburn")
			self:PlaySound("disorient", "alarm")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Anubisath Defender (Plague, Thunder Clap, Shadow Storm, Meteor, Explode)
--

RavenBW:AddBoss("Anubisath Defender", "Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("Anubisath Defender", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.defender = "Defender Abilities"
		L.defender_desc = "Timers and warnings for the Anubisath Defender abilities."
		L.plague = "Plague"
		L.plagueBar = " Plagued"
		L.plagueMsg = "Plague on "
		L.thunderClap = "Thunder Clap"
		L.thunderClapMsg = "Thunder Clap - ranged get out!"
		L.shadowStorm = "Shadow Storm"
		L.shadowStormMsg = "Shadow Storm - ranged get in!"
		L.meteor = "Meteor"
		L.meteorMsg = "Meteor!"
		L.explode = "Exploding!"
		L.explodeMsg = "Exploding!"
		L.enrage = "Enraged!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "defender" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Plague", "Plague")
		self:Log("SPELL_DAMAGE", "ThunderClap", "Thunderclap")
		self:Log("SPELL_DAMAGE", "ShadowStorm", "Shadow Storm")
		self:Log("SPELL_DAMAGE", "Meteor", "Meteor")
		self:Log("SPELL_AURA_APPLIED", "Explode", "Explode")
		self:Log("SPELL_AURA_APPLIED", "Enrage", "Enrage")
	end

	function mod:Plague(args)
		local name = args.destName or "?"
		self:Bar("defender", 40, name .. L.plagueBar, "Spell_Shadow_CurseOfTounges")
		self:Message("defender", "yellow", L.plagueMsg .. name)
		if name == UnitName("player") then
			self:Flash("defender")
			self:PlaySound("defender", "alarm")
		end
	end

	function mod:ThunderClap()
		self:StopBar(L.shadowStorm)
		self:Bar("defender", 600, L.thunderClap, "Ability_ThunderClap")
		self:Message("defender", "red", L.thunderClapMsg, "Ability_ThunderClap")
		self:Flash("defender")
	end

	function mod:ShadowStorm()
		self:StopBar(L.thunderClap)
		self:Bar("defender", 600, L.shadowStorm, "spell_shadow_shadowbolt")
		self:Message("defender", "yellow", L.shadowStormMsg, "spell_shadow_shadowbolt")
	end

	function mod:Meteor()
		self:Bar("defender", 600, L.meteor, "Spell_Fire_Fireball02")
		self:Message("defender", "yellow", L.meteorMsg, "Spell_Fire_Fireball02")
	end

	function mod:Explode()
		self:Bar("defender", 6, L.explode, "spell_fire_selfdestruct")
		self:Message("defender", "red", L.explodeMsg, "spell_fire_selfdestruct")
		self:Flash("defender")
		self:PlaySound("defender", "alarm")
	end

	function mod:Enrage()
		self:Message("defender", "yellow", L.enrage, "spell_shadow_unholyfrenzy")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- The Bug Family (Lord Kri / Princess Yauj / Vem)
--

RavenBW:AddBoss("The Bug Family", "Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("The Bug Family", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.family = "Bug Family"
		L.family_desc = "Timers for Panic, Toxic Volley, Great Heal and Toxic Vapors."
		L.panicBar = "Panic CD"
		L.volleyBar = "Toxic Volley"
		L.healBar = "Great Heal"
		L.healMsg = "Yauj casting Heal - interrupt!"
		L.vaporsMsg = "Move away from the Poison Cloud!"
		L.kriDead = "Kri is dead - POISON CLOUD!"
		L.yaujDead = "Yauj is dead - KILL THE SPAWNS!"
		L.vemDead = "Vem is dead - ENRAGE!"
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
		return { "family" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Panic", "Panic")
		self:Log("SPELL_DAMAGE", "Volley", "Toxic Volley")
		self:Log("SPELL_CAST_START", "Heal", "Great Heal")
		self:Log("SPELL_AURA_APPLIED", "Vapors", "Toxic Vapors")
	end

	function mod:OnEngage()
		schedule(self, "family", L.panicBar, "Spell_Shadow_DeathScream", 10, 20)
		schedule(self, "family", L.volleyBar, "Spell_Nature_Corrosivebreath", 8, 10)
	end

	function mod:Panic()
		self:StopBar(L.panicBar)
		self:Bar("family", 20, L.panicBar, "Spell_Shadow_DeathScream")
	end

	function mod:Volley()
		self:StopBar(L.volleyBar)
		self:Bar("family", math.random(8, 14), L.volleyBar, "Spell_Nature_Corrosivebreath")
	end

	function mod:Heal()
		self:Bar("family", 2, L.healBar, "Spell_Holy_Heal")
		self:Message("family", "red", L.healMsg, "Spell_Holy_Heal")
		self:PlaySound("family", "alarm")
	end

	function mod:Vapors()
		self:Message("family", "red", L.vaporsMsg, "Spell_Nature_AbolishMagic")
		self:Flash("family")
		self:PlaySound("family", "alarm")
	end

	function mod:OnUnitDied(name)
		if name == "Lord Kri" then
			self:Message("family", "green", L.kriDead)
		elseif name == "Princess Yauj" then
			self:Message("family", "green", L.yaujDead)
		elseif name == "Vem" then
			self:Message("family", "green", L.vemDead)
		end
	end

	return mod
end, { "Lord Kri", "Princess Yauj", "Vem" })

--------------------------------------------------------------------------------
-- Anubisath Sentinel (AQ40 trash)
--

local SENTINEL_ABILITIES = {
	{ "Knockback", "Knockback", "Inv_Gauntlets_05" },
	{ "Mana Burn", "Mana Burn", "Spell_Shadow_Manaburn" },
	{ "Mending", "Mending", "spell_nature_resistnature" },
	{ "Mortal Strike", "Mortal Strike", "ability_warrior_savageblow" },
	{ "Shadow Storm", "Shadow Storm", "spell_shadow_shadowbolt" },
	{ "Thorns", "Thorns", "Spell_Nature_Thorns" },
	{ "Thunderclap", "Thunderclap", "Ability_ThunderClap" },
}

RavenBW:AddBoss("Anubisath Sentinel", "Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("Anubisath Sentinel", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.sentinel = "Anubisath Sentinel"
		L.sentinel_desc = "Shows which abilities the Sentinel has."
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "sentinel" }
	end

	function mod:OnBossEnable()
		for i = 1, #SENTINEL_ABILITIES do
			local name = SENTINEL_ABILITIES[i][1]
			self:Log("SPELL_AURA_APPLIED", "Ability", name)
		end
	end

	function mod:Ability(args)
		local spell = args.spellName or "?"
		for i = 1, #SENTINEL_ABILITIES do
			local def = SENTINEL_ABILITIES[i]
			if def[1] == spell then
				self:Bar("sentinel", 600, def[2], def[3])
				self:Message("sentinel", "yellow", def[2], def[3])
				return
			end
		end
	end

	return mod
end)
