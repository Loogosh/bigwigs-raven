-- BigWigs_Raven :: Zul'Gurub (RavenCraft additions)
--
-- Edge of Madness bosses and trash modules from the 1.18 fork that are missing
-- from the stock Zul'Gurub pack.

local RavenBW = _G.RavenBW

--------------------------------------------------------------------------------
-- Wushoolay
--

RavenBW:AddBoss("Wushoolay", "Zul'Gurub", function(zoneId)
	local mod = BigWigs:NewBoss("Wushoolay", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.wushoolay = "Chain Lightning"
		L.wushoolay_desc = "Warn for Chain Lightning and Lightning Cloud."
		L.chainBar = "Chain Lightning"
		L.chainMsg = "Chain Lightning! Interrupt it!"
		L.cloudMsg = "Get out of the Lightning Cloud!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "wushoolay" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "ChainLightning", "Chain Lightning")
		self:Log("SPELL_AURA_APPLIED", "LightningCloud", "Lightning Cloud")
	end

	function mod:ChainLightning()
		self:StopBar(L.chainBar)
		self:Bar("wushoolay", 1.5, L.chainBar, "Spell_Nature_ChainLightning")
		self:Message("wushoolay", "red", L.chainMsg, "Spell_Nature_ChainLightning")
		self:PlaySound("wushoolay", "alarm")
	end

	function mod:LightningCloud(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("wushoolay", "yellow", L.cloudMsg, "Spell_Nature_ChainLightning")
		self:PlaySound("wushoolay", "alarm")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Gurubashi Bat Rider
--

RavenBW:AddBoss("Gurubashi Bat Rider", "Zul'Gurub", function(zoneId)
	local mod = BigWigs:NewBoss("Gurubashi Bat Rider", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.batrider = "Exploding"
		L.batrider_desc = "Warn before the Bat Rider explodes."
		L.exploding = "Exploding"
		L.explodingMsg = "Exploding!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "batrider" }
	end

	function mod:OnBossEnable()
		self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	end

	function mod:CHAT_MSG_MONSTER_EMOTE(_, msg)
		if not msg then return end
		if msg:find("crazed look in his eye", 1, true) or msg:find("fully engulfed in flames", 1, true) then
			self:Bar("batrider", 3, L.exploding, "spell_fire_incinerate")
			self:Message("batrider", "red", L.explodingMsg, "spell_fire_incinerate")
			self:Flash("batrider")
			self:PlaySound("batrider", "alarm")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Gurubashi Berserker
--

RavenBW:AddBoss("Gurubashi Berserker", "Zul'Gurub", function(zoneId)
	local mod = BigWigs:NewBoss("Gurubashi Berserker", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.berserker = "Berserker Abilities"
		L.berserker_desc = "Timers for Intimidating Roar, Knock Away and Thunderclap."
		L.fearBar = "Fear CD"
		L.knockBar = "KnockAway CD"
		L.clapBar = "Thunderclap CD"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "berserker" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Fear", "Intimidating Roar")
		self:Log("SPELL_DAMAGE", "Knock", "Knock Away")
		self:Log("SPELL_DAMAGE", "Clap", "Thunderclap")
	end

	function mod:OnEngage()
		self:Bar("berserker", 15, L.fearBar, "Ability_GolemThunderClap")
		self:Bar("berserker", 10, L.knockBar, "INV_Gauntlets_05")
		self:Bar("berserker", 5, L.clapBar, "Ability_ThunderClap")
	end

	function mod:Fear()
		self:StopBar(L.fearBar)
		self:Bar("berserker", 25, L.fearBar, "Ability_GolemThunderClap")
	end

	function mod:Knock()
		self:StopBar(L.knockBar)
		self:Bar("berserker", 10, L.knockBar, "INV_Gauntlets_05")
	end

	function mod:Clap()
		self:StopBar(L.clapBar)
		self:Bar("berserker", 15, L.clapBar, "Ability_ThunderClap")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Mad Servant (Portal of Madness)
--

RavenBW:AddBoss("Mad Servant", "Zul'Gurub", function(zoneId)
	local mod = BigWigs:NewBoss("Mad Servant", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.portal = "Portal of Madness"
		L.portal_desc = "Warn for Portal of Madness."
		L.portalBar = "Void Spawn - Portal "
		L.portalMsg = "D E L A Y killing other imps if you value your life!"
	end
	L = mod:GetLocale()

	local portalNum = 1

	function mod:GetOptions()
		return { "portal" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_SUCCESS", "Portal", "Portal of Madness")
	end

	function mod:OnEngage()
		portalNum = 1
	end

	function mod:Portal()
		self:Bar("portal", 11, L.portalBar .. portalNum, "spell_shadow_sealofkings")
		self:Message("portal", "red", L.portalMsg, "spell_shadow_sealofkings")
		self:Flash("portal")
		self:PlaySound("portal", "info")
		portalNum = portalNum + 1
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Hazza'rah (Nightmare Illusions, Sleep, Chain Burn)
--

RavenBW:AddBoss("Hazza'rah", "Zul'Gurub", function(zoneId)
	local mod = BigWigs:NewBoss("Hazza'rah", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.hazzarah = "Hazza'rah"
		L.hazzarah_desc = "Timers for the Nightmare Illusions, Sleep and Chain Burn."
		L.addsBar = "Adds Spawn"
		L.addsMsg = "3 Nightmare Illusions - ranged, kill the adds!"
		L.sleepBar = "Sleeping!"
		L.sleepCd = "Sleep CD"
		L.sleepMsg = "Sleep - Tremor Totem!"
		L.burnBar = "AoE Mana Burn CD"
		L.burnMsg = "AoE Mana Burn - drain his mana!"
	end
	L = mod:GetLocale()

	local addDeaths = 0

	function mod:GetOptions()
		return { "hazzarah" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_SUCCESS", "Adds", "Summon Nightmare Illusions")
		self:Log("SPELL_AURA_APPLIED", "Sleep", "Sleep")
		self:Log("SPELL_DAMAGE", "ChainBurn", "Chain Burn")
	end

	function mod:OnEngage()
		addDeaths = 0
		self:Bar("hazzarah", 21, L.addsBar, "spell_magic_lesserinvisibilty")
		self:Bar("hazzarah", 10, L.sleepCd, "spell_nature_sleep")
	end

	function mod:Adds()
		self:StopBar(L.addsBar)
		self:Bar("hazzarah", 24, L.addsBar, "spell_magic_lesserinvisibilty")
		self:Message("hazzarah", "red", L.addsMsg, "spell_magic_lesserinvisibilty")
		self:PlaySound("hazzarah", "alarm")
		addDeaths = 0
	end

	function mod:Sleep()
		self:StopBar(L.sleepCd)
		self:Bar("hazzarah", 6, L.sleepBar, "spell_nature_sleep")
		self:Message("hazzarah", "yellow", L.sleepMsg, "spell_nature_sleep")
		self:ScheduleTimer(function()
			self:Bar("hazzarah", 18, L.sleepCd, "spell_nature_sleep")
		end, 6)
		if UnitClass("player") == "SHAMAN" then
			self:Flash("hazzarah")
		end
	end

	function mod:ChainBurn()
		self:StopBar(L.burnBar)
		self:Bar("hazzarah", 60, L.burnBar, "spell_shadow_manaburn")
		self:Message("hazzarah", "yellow", L.burnMsg, "spell_shadow_manaburn")
	end

	function mod:OnUnitDied(name)
		if name ~= "Nightmare Illusion" then return end
		addDeaths = addDeaths + 1
		if addDeaths == 3 then
			self:StopBar(L.addsBar)
			addDeaths = 0
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Renataki (Vanish / Enrage / Gouge)
--

RavenBW:AddBoss("Renataki", "Zul'Gurub", function(zoneId)
	local mod = BigWigs:NewBoss("Renataki", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.renataki = "Renataki"
		L.renataki_desc = "Warn for Vanish, Enrage and Gouge."
		L.vanishBar = "Vanish"
		L.returnBar = "Return"
		L.vanishMsg = "Renataki has vanished!"
		L.returnMsg = "Renataki appears!"
		L.enrageMsg = "Enrage!"
		L.gougeBar = "Gouge CD"
	end
	L = mod:GetLocale()

	local vanished = false

	local function isVisible()
		if UnitName("target") == "Renataki" then return true end
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid" .. i .. "target") == "Renataki" then return true end
		end
		return false
	end

	local function checkVanish(self)
		if not self:IsEngaged() then return end
		local visible = isVisible()
		if vanished and visible then
			vanished = false
			self:StopBar(L.returnBar)
			self:Bar("renataki", 28, L.vanishBar, "ability_vanish")
			self:Message("renataki", "yellow", L.returnMsg)
		elseif not vanished and not visible then
			vanished = true
			self:StopBar(L.vanishBar)
			self:Bar("renataki", 20, L.returnBar, "ability_rogue_ambush")
			self:Message("renataki", "yellow", L.vanishMsg)
		end
		self:ScheduleTimer(checkVanish, 0.5, self)
	end

	function mod:GetOptions()
		return { "renataki" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Enrage", "Enrage")
		self:Log("SPELL_DAMAGE", "Gouge", "Gouge")
	end

	function mod:OnEngage()
		vanished = false
		self:Bar("renataki", 28, L.vanishBar, "ability_vanish")
		self:Bar("renataki", 9, L.gougeBar, "ability_gouge")
		self:ScheduleTimer(checkVanish, 0.5, self)
	end

	function mod:Enrage()
		self:Message("renataki", "red", L.enrageMsg, "spell_shadow_unholyfrenzy")
		self:Flash("renataki")
		self:PlaySound("renataki", "alarm")
	end

	function mod:Gouge()
		self:StopBar(L.gougeBar)
		self:Bar("renataki", 9, L.gougeBar, "ability_gouge")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Gri'lek (Avatar, Stun, Ground Tremor, Roots, Sweeping Strikes)
--

RavenBW:AddBoss("Gri'lek", "Zul'Gurub", function(zoneId)
	local mod = BigWigs:NewBoss("Gri'lek", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.grilek = "Gri'lek"
		L.grilek_desc = "Timers for Avatar, Stun, Ground Tremor, Roots and Sweeping Strikes."
		L.avatarBar = "Avatar!"
		L.avatarCd = "Avatar CD"
		L.avatarMsg = "Avatar - run away from the boss!"
		L.stunBar = "Gri'lek Stunned"
		L.tremorBar = "Ground Tremor Stun"
		L.tremorCd = "Ground Tremor CD"
		L.rootsBar = " Rooted"
		L.sweepingBar = "Sweeping Strikes!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "grilek" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Avatar", "Avatar")
		self:Log("SPELL_AURA_REMOVED", "AvatarFade", "Avatar")
		self:Log("SPELL_AURA_APPLIED", "Stun", "Stun")
		self:Log("SPELL_AURA_APPLIED", "Tremor", "Ground Tremor")
		self:Log("SPELL_AURA_APPLIED", "Roots", "Entangling Roots")
		self:Log("SPELL_AURA_REMOVED", "RootsFade", "Entangling Roots")
		self:Log("SPELL_AURA_APPLIED", "Sweeping", "Sweeping Strikes")
	end

	function mod:OnEngage()
		self:Bar("grilek", 25, L.avatarCd, "Ability_Creature_Cursed_05")
		self:Bar("grilek", 18, L.tremorCd, "spell_nature_earthquake")
	end

	function mod:Avatar()
		self:StopBar(L.avatarCd)
		self:Bar("grilek", 15, L.avatarBar, "Ability_Creature_Cursed_05")
		self:Message("grilek", "red", L.avatarMsg, "Ability_Creature_Cursed_05")
		self:PlaySound("grilek", "alarm")
	end

	function mod:AvatarFade()
		self:StopBar(L.avatarBar)
		self:Bar("grilek", 10, L.avatarCd, "Ability_Creature_Cursed_05")
	end

	function mod:Stun()
		self:Bar("grilek", 2, L.stunBar, "spell_frost_stun")
	end

	function mod:Tremor()
		self:StopBar(L.tremorCd)
		self:Bar("grilek", 2, L.tremorBar, "spell_nature_earthquake")
		self:ScheduleTimer(function()
			self:Bar("grilek", 18, L.tremorCd, "spell_nature_earthquake")
		end, 2)
	end

	function mod:Roots(args)
		local name = args.destName or "?"
		self:Bar("grilek", 10, name .. L.rootsBar, "spell_nature_stranglevines")
	end

	function mod:RootsFade(args)
		self:StopBar((args.destName or "?") .. L.rootsBar)
	end

	function mod:Sweeping()
		self:Bar("grilek", 20, L.sweepingBar, "ability_rogue_slicedice")
	end

	return mod
end)
