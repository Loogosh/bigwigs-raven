-- BigWigs_Raven :: Ruins of Ahn'Qiraj (RavenCraft additions)
--
-- Trash modules from the 1.18 fork for AQ20: Flesh Hunter, Hive'Zara Soldier
-- and the Anubisath Guardian (same ability set as the AQ40 Defender).

local RavenBW = _G.RavenBW

--------------------------------------------------------------------------------
-- Flesh Hunter (Consume)
--

RavenBW:AddBoss("Flesh Hunter", "Ruins of Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("Flesh Hunter", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.consume = "Consume"
		L.consume_desc = "Timer for Consume on raid members."
		L.consumeBar = " Consumed!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "consume" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Consume", "Consume")
	end

	function mod:Consume(args)
		local name = args.destName or "?"
		self:Bar("consume", 15, name .. L.consumeBar, "spell_nature_drowsy")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Hive'Zara Soldier (Retaliation)
--

RavenBW:AddBoss("Hive'Zara Soldier", "Ruins of Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("Hive'Zara Soldier", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.retaliation = "Retaliation"
		L.retaliation_desc = "Warn when the soldier gains Retaliation and when it hits you."
		L.retaliationGain = "Hive'Zara Soldier gains Retaliation!"
		L.retaliationHit = "STOP KILLING YOURSELF!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "retaliation" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Gain", "Retaliation")
		self:Log("SPELL_DAMAGE", "Hit", "Retaliation")
	end

	function mod:Gain()
		self:Message("retaliation", "yellow", L.retaliationGain, "ability_warrior_challange")
	end

	function mod:Hit(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("retaliation", "red", L.retaliationHit, "ability_warrior_challange")
		self:Flash("retaliation")
		self:PlaySound("retaliation", "alarm")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Anubisath Guardian (Plague, Thunder Clap, Shadow Storm, Meteor, Explode)
--

RavenBW:AddBoss("Anubisath Guardian", "Ruins of Ahn'Qiraj", function(zoneId)
	local mod = BigWigs:NewBoss("Anubisath Guardian", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.guardian = "Guardian Abilities"
		L.guardian_desc = "Timers and warnings for the Anubisath Guardian abilities."
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
		return { "guardian" }
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
		self:Bar("guardian", 40, name .. L.plagueBar, "Spell_Shadow_CurseOfTounges")
		self:Message("guardian", "yellow", L.plagueMsg .. name)
		if name == UnitName("player") then
			self:Flash("guardian")
			self:PlaySound("guardian", "alarm")
		end
	end

	function mod:ThunderClap()
		self:StopBar(L.shadowStorm)
		self:Bar("guardian", 600, L.thunderClap, "Ability_ThunderClap")
		self:Message("guardian", "red", L.thunderClapMsg, "Ability_ThunderClap")
	end

	function mod:ShadowStorm()
		self:StopBar(L.thunderClap)
		self:Bar("guardian", 600, L.shadowStorm, "spell_shadow_shadowbolt")
		self:Message("guardian", "yellow", L.shadowStormMsg, "spell_shadow_shadowbolt")
	end

	function mod:Meteor()
		self:Bar("guardian", 600, L.meteor, "Spell_Fire_Fireball02")
		self:Message("guardian", "yellow", L.meteorMsg, "Spell_Fire_Fireball02")
	end

	function mod:Explode()
		self:Bar("guardian", 6, L.explode, "spell_fire_selfdestruct")
		self:Message("guardian", "red", L.explodeMsg, "spell_fire_selfdestruct")
		self:Flash("guardian")
		self:PlaySound("guardian", "alarm")
	end

	function mod:Enrage()
		self:Message("guardian", "yellow", L.enrage, "spell_shadow_unholyfrenzy")
	end

	return mod
end)
