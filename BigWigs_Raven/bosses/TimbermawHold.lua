-- BigWigs_Raven :: Timbermaw Hold (RavenCraft custom raid)
--
-- Ported from the 1.18 fork; the instance is not part of BigWigs v36.

local RavenBW = _G.RavenBW

local ZONE = "Timbermaw Hold"

--------------------------------------------------------------------------------
-- Selenaxx Foulheart
--

RavenBW:AddBoss("Selenaxx Foulheart", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Selenaxx Foulheart", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.selenaxx = "Rain of Destruction"
		L.selenaxx_desc = "Personal warning when you stand in Rain of Destruction."
		L.rainMsg = "MOVE - Rain of Destruction"
		L.rainSafe = "Out of Rain of Destruction"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "selenaxx" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Rain", "Rain of Destruction")
		self:Log("SPELL_AURA_REMOVED", "RainFade", "Rain of Destruction")
	end

	function mod:Rain(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("selenaxx", "red", L.rainMsg, "Spell_Shadow_RainOfFire")
		self:Flash("selenaxx")
		self:PlaySound("selenaxx", "alarm")
	end

	function mod:RainFade(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("selenaxx", "green", L.rainSafe)
		self:PlaySound("selenaxx", "info")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Chieftain Partath
--

RavenBW:AddBoss("Chieftain Partath", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Chieftain Partath", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.partath = "Chieftain Partath"
		L.partath_desc = "Might of the Chieftain stacks and the Shade of the Withermaw immunity."
		L.mightBar = "Might of the Chieftain"
		L.immuneBar = "Immune"
		L.nextImmune = "Next Immune"
		L.immuneMsg = "Chieftain Partath is immune - bring Illuminators to him!"
		L.immuneOver = "Immune ended!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "partath" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Might", "Might of the Chieftain")
		self:Log("SPELL_AURA_APPLIED", "Immune", "Shade of the Withermaw")
		self:Log("SPELL_AURA_REMOVED", "ImmuneFade", "Shade of the Withermaw")
	end

	function mod:OnEngage()
		self:Bar("partath", 52, L.nextImmune, "spell_cloaked_in_shadows_2")
	end

	function mod:Might(args)
		local stacks = args.amount or 1
		self:StopBar(L.mightBar)
		self:Bar("partath", 50 - stacks, L.mightBar .. " (" .. stacks .. ")", "Ability_Druid_Maul")
		if stacks >= 40 then
			self:Flash("partath")
		end
	end

	function mod:Immune()
		self:StopBar(L.immuneBar)
		self:Bar("partath", 15, L.immuneBar, "Spell_Shadow_SummonVoidWalker")
		self:Message("partath", "red", L.immuneMsg, "Spell_Shadow_SummonVoidWalker")
		self:PlaySound("partath", "alarm")
	end

	function mod:ImmuneFade()
		self:StopBar(L.immuneBar)
		self:Message("partath", "green", L.immuneOver)
		self:StopBar(L.nextImmune)
		self:Bar("partath", 52, L.nextImmune, "spell_cloaked_in_shadows_2")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Karrsh the Sentinel
--

RavenBW:AddBoss("Karrsh the Sentinel", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Karrsh the Sentinel", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.karrsh = "Karrsh the Sentinel"
		L.karrsh_desc = "Furious Roar while Spear of Timbermaw is up, and Seed of Corruption."
		L.roarBar = "Furious Roar"
		L.roarMsg = "Threat drop incoming!"
		L.seedYou = "SEED ON YOU - GET AWAY FROM OTHERS!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "karrsh" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Spear", "Spear of Timbermaw")
		self:Log("SPELL_CAST_SUCCESS", "Roar", "Furious Roar")
		self:Log("SPELL_AURA_APPLIED", "Seed", "Seed of Corruption")
	end

	function mod:Spear()
		self:StopBar(L.roarBar)
		self:Bar("karrsh", 12, L.roarBar, "Ability_Druid_DemoralizingRoar")
	end

	function mod:Roar()
		self:StopBar(L.roarBar)
		self:Bar("karrsh", 12, L.roarBar, "Ability_Druid_DemoralizingRoar")
		self:ScheduleTimer(function()
			self:Message("karrsh", "red", L.roarMsg, "Ability_Druid_DemoralizingRoar")
		end, 8)
	end

	function mod:Seed(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("karrsh", "red", L.seedYou, "ability_warlock_shadowflame")
		self:Flash("karrsh")
		self:PlaySound("karrsh", "alarm")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Loktanag the Vile
--

RavenBW:AddBoss("Loktanag the Vile", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Loktanag the Vile", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.loktanag = "Loktanag the Vile"
		L.loktanag_desc = "Infected Secretion target, cooldown and the damage zone."
		L.secretionBar = "next Secretion"
		L.secretionMsg = "Adds and zone on %s"
		L.secretionYou = "Adds and zone on YOU!"
		L.zoneMsg = "MOVE - Infected Secretion"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "loktanag" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "Secretion", "Infected Secretion")
		self:Log("SPELL_AURA_APPLIED", "Zone", "Infected Secretion")
	end

	function mod:Secretion(args)
		local name = args.destName or "?"
		self:StopBar(L.secretionBar)
		if name == UnitName("player") then
			self:Message("loktanag", "red", L.secretionYou, "Spell_Nature_NullifyDisease")
			self:PlaySound("loktanag", "alarm")
		else
			self:Message("loktanag", "yellow", L.secretionMsg:format(name), "Spell_Nature_NullifyDisease")
		end
		self:Bar("loktanag", math.random(12, 14), L.secretionBar, "Spell_Nature_NullifyDisease")
	end

	function mod:Zone(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("loktanag", "red", L.zoneMsg, "Spell_Nature_NullifyDisease")
		self:Flash("loktanag")
		self:PlaySound("loktanag", "info")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Ormanos the Cracked
--

RavenBW:AddBoss("Ormanos the Cracked", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Ormanos the Cracked", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.ormanos = "Ormanos the Cracked"
		L.ormanos_desc = "Crush Earth, the charge and the attunement swaps."
		L.crushBar = "New AoE Zone"
		L.crushMsg = "MOVE - Crush Earth"
		L.chargeBar = "Charge on %s"
		L.chargeSelf = "Run away and stack with others!"
		L.chargeOther = "Stack on %s far away from the boss!"
		L.attuneBar = "%s, no %s"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "ormanos" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "Crush", "Crush Earth")
		self:Log("SPELL_AURA_APPLIED", "CrushZone", "Crush Earth")
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	end

	function mod:Crush()
		self:StopBar(L.crushBar)
		self:Bar("ormanos", 2.5, L.crushBar, "Spell_Nature_Earthquake")
	end

	function mod:CrushZone(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("ormanos", "red", L.crushMsg, "Spell_Nature_Earthquake")
		self:Flash("ormanos")
		self:PlaySound("ormanos", "info")
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
		if not msg then return end
		local charged = msg:match("preparing to charge (.+)!")
		if charged then
			self:Charge(charged)
			return
		end
		local immunity, vulnerability = msg:match("becoming immune to (.+) and vulnerable to (.+)!")
		if immunity and vulnerability then
			self:Attunement(immunity, vulnerability)
		end
	end

	function mod:Charge(player)
		self:Bar("ormanos", 6, L.chargeBar:format(player), "Ability_Warrior_Charge")
		if player == UnitName("player") then
			self:Message("ormanos", "red", L.chargeSelf, "Ability_Warrior_Charge")
			self:PlaySound("ormanos", "alarm")
		else
			self:Message("ormanos", "yellow", L.chargeOther:format(player), "Ability_Warrior_Charge")
		end
	end

	function mod:Attunement(immunity, vulnerability)
		self:StopBar("attunement")
		self:Bar("ormanos", 200, L.attuneBar:format(vulnerability, immunity), "Spell_Nature_AstralRecalGroup")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Rotgrowl
--

RavenBW:AddBoss("Rotgrowl", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Rotgrowl", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.rotgrowl = "Rotgrowl"
		L.rotgrowl_desc = "Volley, Fire-Soaked Arrow, Fear, Kill Command and the revive."
		L.volleyMsg = "MOVE - Volley of Arrows"
		L.arrowBar = "Arrow on %s"
		L.arrowSelf = "Stack with others!"
		L.arrowOther = "Stack on %s to soak the arrow!"
		L.fearBar = "Incoming Fear"
		L.frenzyMsg = "Kodiak Rage - use Tranq Shot!"
		L.killBar = "Bear chasing %s"
		L.reviveBar = "Bear Revives"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "rotgrowl" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Volley", "Volley of Arrows")
		self:Log("SPELL_AURA_APPLIED", "Frenzy", "Rage of the Ursa")
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:Volley(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("rotgrowl", "red", L.volleyMsg, "Ability_Marksmanship")
		self:Flash("rotgrowl")
		self:PlaySound("rotgrowl", "info")
	end

	function mod:Frenzy()
		self:Message("rotgrowl", "red", L.frenzyMsg, "ability_hunter_pet_wolf")
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
		if not msg then return end
		local arrow = msg:match("aims a flaming bolt at (.+)!")
		if arrow then
			self:Bar("rotgrowl", 5, L.arrowBar:format(arrow), "Spell_Fire_Fireball02")
			if arrow == UnitName("player") then
				self:Message("rotgrowl", "red", L.arrowSelf, "Spell_Fire_Fireball02")
				self:PlaySound("rotgrowl", "alarm")
			else
				self:Message("rotgrowl", "yellow", L.arrowOther:format(arrow), "Spell_Fire_Fireball02")
			end
			return
		end
		if msg:find("bellows a deep roar", 1, true) then
			self:Bar("rotgrowl", 4, L.fearBar, "Spell_Shadow_PsychicScream")
			self:Message("rotgrowl", "red", L.fearBar, "Spell_Shadow_PsychicScream")
			return
		end
		local target = msg:match("commands Kodiak to kill (.+)!")
		if target then
			self:Bar("rotgrowl", 10, L.killBar:format(target), "Spell_Nature_Reincarnation")
		end
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find("Live and fight once more", 1, true) then
			self:Bar("rotgrowl", 25, L.reviveBar, "Spell_Holy_Resurrection")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Peroth'arn
--

RavenBW:AddBoss("Peroth'arn", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Peroth'arn", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.perotharn = "Peroth'arn"
		L.perotharn_desc = "Flames of Purgation, Spiral of Hellfire, Dirk, disarm and Nightmare Burst."
		L.flamesBar = "Fear from Flames"
		L.flamesOther = "%s has Flames of Purgation"
		L.flamesYou = "YOU have Flames - do not stand near people when it expires"
		L.spiralBar = "Spiral of Hellfire"
		L.spiralMsg = "Spiral - anyone around you taking damage will hurt you!"
		L.dirkMsg = "MOVE - Dirk of the Beast"
		L.disarmMsg = "Peroth'arn is vulnerable - DISARM"
		L.burstBar = "Incoming Knockback"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "perotharn" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Flames", "Flames of Purgation")
		self:Log("SPELL_AURA_APPLIED", "Spiral", "Spiral of Hellfire")
		self:Log("SPELL_AURA_APPLIED", "Dirk", "Dirk of the Beast")
		self:Log("SPELL_CAST_START", "Burst", "Nightmare Burst")
		self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	end

	function mod:Flames(args)
		local name = args.destName or "?"
		if name == UnitName("player") then
			self:Message("perotharn", "red", L.flamesYou, "Spell_Fire_Immolation")
			self:PlaySound("perotharn", "alarm")
		else
			self:Message("perotharn", "yellow", L.flamesOther:format(name), "Spell_Fire_Immolation")
		end
		self:Bar("perotharn", 8, L.flamesBar, "Spell_Shadow_Possession")
	end

	function mod:Spiral(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("perotharn", "red", L.spiralMsg, "Spell_Fire_Incinerate")
		self:Bar("perotharn", 15, L.spiralBar, "Spell_Fire_Incinerate")
		self:PlaySound("perotharn", "alarm")
	end

	function mod:Dirk(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("perotharn", "red", L.dirkMsg, "Spell_Holy_InnerFire")
		self:Flash("perotharn")
	end

	function mod:Burst()
		self:Bar("perotharn", 3, L.burstBar, "Spell_Nature_ThunderClap")
		self:Message("perotharn", "yellow", L.burstBar, "Spell_Nature_ThunderClap")
	end

	function mod:CHAT_MSG_MONSTER_EMOTE(_, msg)
		if not msg then return end
		if msg:find("becomes vulnerable", 1, true) then
			self:Message("perotharn", "green", L.disarmMsg)
			self:PlaySound("perotharn", "info")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Timbermaw trash
--

RavenBW:AddBoss("Timbermaw Trash", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Timbermaw Trash", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.trash = "Timbermaw Trash"
		L.trash_desc = "Warnings for the Timbermaw trash abilities."
		L.auraMsg = "Fire aura around the Pathfinder!"
		L.blessingMsg = "%s is immune to physical - purge!"
		L.defilingYou = "Get out of the raid! - Withered Defiling"
		L.defilingOther = "Withered Defiling on %s"
		L.defilingBar = "Withered Defiling"
		L.cloudMsg = "MOVE - Poison Cloud"
		L.commandMsg = "Ursa buff aura active - Tranq Shot!"
		L.roarBar = "Ursa Fear"
		L.boilsMsg = "Black Boils on %s - cleanse!"
		L.euyoBar = "AoE Disease"
		L.euyoMsg = "You have Euyonalia - spreads on cleanse!"
		L.rageMsg = "Bear enrage - Tranq Shot!"
		L.siphonMsg = "Drain on %s - dispel!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "trash" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Illumination", "Cauterizing Illumination")
		self:Log("SPELL_AURA_APPLIED", "Blessing", "Withermaw Blessing")
		self:Log("SPELL_AURA_APPLIED", "Defiling", "Withered Defiling")
		self:Log("SPELL_AURA_APPLIED", "Cloud", "Poison Cloud")
		self:Log("SPELL_AURA_APPLIED", "Command", "Ursol's Command")
		self:Log("SPELL_CAST_START", "Roar", "Roar of the Ursa")
		self:Log("SPELL_AURA_APPLIED", "Boils", "Black Boils")
		self:Log("SPELL_CAST_START", "EuyonaliaCast", "Euyonalia")
		self:Log("SPELL_AURA_APPLIED", "Euyonalia", "Euyonalia")
		self:Log("SPELL_AURA_APPLIED", "Rage", "Ancient Rage")
		self:Log("SPELL_AURA_APPLIED", "Siphon", "Foulheart Siphon")
	end

	function mod:Illumination()
		self:Message("trash", "yellow", L.auraMsg, "Spell_Fire_Immolation")
	end

	function mod:Blessing(args)
		self:Message("trash", "yellow", L.blessingMsg:format(args.destName or "?"), "Spell_Holy_DispelMagic")
	end

	function mod:Defiling(args)
		local name = args.destName or "?"
		self:Bar("trash", 12, L.defilingBar, "Spell_Shadow_CurseOfSargeras")
		if name == UnitName("player") then
			self:Message("trash", "red", L.defilingYou, "Spell_Shadow_CurseOfSargeras")
			self:PlaySound("trash", "alarm")
		else
			self:Message("trash", "yellow", L.defilingOther:format(name), "Spell_Shadow_CurseOfSargeras")
		end
	end

	function mod:Cloud(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("trash", "red", L.cloudMsg, "Spell_Nature_NatureTouchDecay")
		self:Flash("trash")
	end

	function mod:Command()
		self:Message("trash", "red", L.commandMsg, "ability_hunter_pet_wolf")
	end

	function mod:Roar()
		self:Bar("trash", 3, L.roarBar, "Spell_Shadow_PsychicScream")
		self:Message("trash", "red", L.roarBar, "Spell_Shadow_PsychicScream")
	end

	function mod:Boils(args)
		self:Message("trash", "yellow", L.boilsMsg:format(args.destName or "?"), "Spell_Shadow_PlagueCloud")
	end

	function mod:EuyonaliaCast()
		self:Bar("trash", 3, L.euyoBar, "Spell_Shadow_PlagueCloud")
		self:Message("trash", "red", L.euyoBar, "Spell_Shadow_PlagueCloud")
	end

	function mod:Euyonalia(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("trash", "red", L.euyoMsg, "Spell_Shadow_PlagueCloud")
		self:Flash("trash")
	end

	function mod:Rage()
		self:Message("trash", "red", L.rageMsg, "ability_hunter_pet_wolf")
	end

	function mod:Siphon(args)
		self:Message("trash", "yellow", L.siphonMsg:format(args.destName or "?"), "Spell_Shadow_SiphonMana")
	end

	return mod
end, {
	"Withermaw Pathfinder", "Withermaw Shaman", "Withermaw Defiler", "Withermaw Ursa",
	"Corruption of Loktanag", "Tainted Mass", "Son of Ursol", "Foulheart Trickster",
})

--------------------------------------------------------------------------------
-- Archdruid Kronn
--

RavenBW:AddBoss("Archdruid Kronn", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Archdruid Kronn", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.kronn = "Archdruid Kronn"
		L.kronn_desc = "Dream Fever and the body-swap casts."
		L.feverYou = "DREAM FEVER ON YOU - GET AWAY FROM OTHERS!"
		L.feverOther = "Dream Fever on %s - get away from them!"
		L.returnBar = "Return to Body"
		L.reformBar = "Reform Body"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "kronn" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Fever", "Dream Fever")
		self:Log("SPELL_CAST_START", "Return", "Return to Body")
		self:Log("SPELL_CAST_START", "Reform", "Reform Body")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:Fever(args)
		local name = args.destName or "?"
		if name == UnitName("player") then
			self:Message("kronn", "red", L.feverYou, "Spell_Nature_NullifyDisease")
			self:PlaySound("kronn", "alarm")
		else
			self:Message("kronn", "yellow", L.feverOther:format(name), "Spell_Nature_NullifyDisease")
		end
	end

	function mod:Return()
		self:StopBar(L.returnBar)
		self:Bar("kronn", 10, L.returnBar, "Spell_Nature_Sleep")
		self:Message("kronn", "yellow", L.returnBar, "Spell_Nature_Sleep")
	end

	function mod:Reform()
		self:StopBar(L.reformBar)
		self:Bar("kronn", 10, L.reformBar, "Spell_Shadow_UnholyStrength")
		self:Message("kronn", "yellow", L.reformBar, "Spell_Shadow_UnholyStrength")
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find("You will not awaken him", 1, true) then
			self:Engage()
		end
	end

	return mod
end, { "Dreamform of Kronn" })
