-- BigWigs_Raven :: Lower Karazhan Halls (RavenCraft custom raid)
--
-- Ported from the 1.18 fork. The zone is not part of v36 at all, so these
-- modules are the only boss timers for the instance.

local RavenBW = _G.RavenBW

local ZONE = "Lower Karazhan Halls"

--------------------------------------------------------------------------------
-- Phantom Servant (trash)
--

RavenBW:AddBoss("Phantom Servant", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Phantom Servant", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.scream = "Phantom Scream"
		L.scream_desc = "Cooldown of Phantom Scream."
		L.screamBar = "Phantom Scream CD"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "scream" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Scream", "Phantom Scream")
	end

	function mod:Scream()
		self:StopBar(L.screamBar)
		self:Bar("scream", 10, L.screamBar, "Spell_Shadow_PsychicScream")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Grizikil
--

RavenBW:AddBoss("Grizikil", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Grizikil", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.grizikil = "Grizikil"
		L.grizikil_desc = "Rain of Fire warning and the Flamewave timer."
		L.rainMsg = "Get out of Rain of Fire!"
		L.flameBar = "Flamewave"
		L.flameMsg = "Flamewave - melee run out!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "grizikil" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_PERIODIC_DAMAGE", "Rain", "Rain of Fire")
		self:Log("SPELL_AURA_APPLIED", "Flamewave", "Flamewave")
		self:Log("SPELL_AURA_REMOVED", "FlamewaveFade", "Flamewave")
	end

	function mod:Rain(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("grizikil", "red", L.rainMsg, "spell_shadow_rainoffire")
		self:Flash("grizikil")
		self:PlaySound("grizikil", "info")
	end

	function mod:Flamewave()
		self:Bar("grizikil", 9, L.flameBar, "spell_fire_incinerate")
		self:Message("grizikil", "red", L.flameMsg, "spell_fire_incinerate")
		self:Flash("grizikil")
		self:PlaySound("grizikil", "alarm")
	end

	function mod:FlamewaveFade()
		self:StopBar(L.flameBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Brood Queen Araxxna
--

RavenBW:AddBoss("Brood Queen Araxxna", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Brood Queen Araxxna", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.araxxna = "Brood Queen Araxxna"
		L.araxxna_desc = "Brood Venom Volley, Leeching Bite and the egg spawn."
		L.volleyBar = "Brood Venom Volley"
		L.biteBar = " Leeching Bite"
		L.eggBar = "Skitterweb Egg Hatch"
		L.eggMsg = "2 eggs spawned!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "araxxna" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "Volley", "Brood Venom Volley")
		self:Log("SPELL_AURA_APPLIED", "Bite", "Leeching Bite")
		self:Log("SPELL_AURA_REMOVED", "BiteFade", "Leeching Bite")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:OnEngage()
		self:Bar("araxxna", 8, L.volleyBar, "Spell_Nature_InsectSwarm")
	end

	function mod:Volley()
		self:StopBar(L.volleyBar)
		self:Bar("araxxna", 8, L.volleyBar, "Spell_Nature_InsectSwarm")
		if UnitClass("player") == "SHAMAN" then
			self:Flash("araxxna")
		end
	end

	function mod:Bite(args)
		self:Bar("araxxna", 10, (args.destName or "?") .. L.biteBar, "ability_poisonsting")
	end

	function mod:BiteFade(args)
		self:StopBar((args.destName or "?") .. L.biteBar)
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find("My minions shall consume you", 1, true) then
			self:Bar("araxxna", 20, L.eggBar, "inv_egg_02")
			self:Message("araxxna", "red", L.eggMsg, "inv_egg_02")
			self:PlaySound("araxxna", "alarm")
		elseif msg:find("new prey to be entangled", 1, true) then
			self:Engage()
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Clawlord Howlfang
--

RavenBW:AddBoss("Clawlord Howlfang", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Clawlord Howlfang", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.howlfang = "Clawlord Howlfang"
		L.howlfang_desc = "Terrifying Presence, Shadowbane Curse and Enrage."
		L.presenceBar = "% reduced"
		L.curseMsg = "Shadowbane Curse - decurse!"
		L.enrageMsg = "Enrage!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "howlfang" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Presence", "Terrifying Presence")
		self:Log("SPELL_AURA_APPLIED", "Curse", "Shadowbane Curse")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:Presence(args)
		local name = args.destName or "?"
		local count = args.amount or 1
		self:Bar("howlfang", 10, name .. " " .. (count * 5) .. L.presenceBar, "Spell_Shadow_VampiricAura")
	end

	function mod:Curse()
		self:Message("howlfang", "red", L.curseMsg, "Spell_Shadow_GatherShadows")
		local _, class = UnitClass("player")
		if class == "MAGE" or class == "DRUID" then
			self:Flash("howlfang")
		end
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find("My pack shall tear you apart", 1, true) then
			self:Message("howlfang", "red", L.enrageMsg, "Spell_Shadow_UnholyFrenzy")
			self:Flash("howlfang")
		elseif msg:find("So it was you I smelled", 1, true) then
			self:Engage()
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Dark Rider Champion (trash)
--

RavenBW:AddBoss("Dark Rider Champion", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Dark Rider Champion", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.rider = "Reaver Storm"
		L.rider_desc = "Cast and cooldown of Reaver Storm."
		L.stormCast = "Reaver Storm Cast"
		L.stormCd = "Reaver Storm CD"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "rider" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "Storm", "Reaver Storm")
	end

	function mod:Storm()
		self:StopBar(L.stormCd)
		self:Bar("rider", 1.5, L.stormCast, "Ability_Whirlwind")
		self:ScheduleTimer(function()
			self:Bar("rider", 5.5, L.stormCd, "Ability_Whirlwind")
		end, 1.5)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Lord Blackwald II
--

RavenBW:AddBoss("Lord Blackwald II", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Lord Blackwald II", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.blackwald = "Lord Blackwald II"
		L.blackwald_desc = "Reaver Storm, Blackwalds Boon, Empowered Soul and the summon."
		L.stormCast = "Reaver Storm Cast"
		L.stormCd = "Reaver Storm CD"
		L.boonBar = "Boon on "
		L.soulBar = " Empowered"
		L.summonBar = "Summons add"
		L.summonMsg = "Shadowbane Ragefang summoned!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "blackwald" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "Storm", "Reaver Storm")
		self:Log("SPELL_AURA_APPLIED", "Boon", "Blackwalds Boon")
		self:Log("SPELL_AURA_REMOVED", "BoonFade", "Blackwalds Boon")
		self:Log("SPELL_AURA_APPLIED", "Soul", "Empowered Soul")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:OnEngage()
		self:Bar("blackwald", 30, L.summonBar, "inv_misc_bone_orcskull_01")
	end

	function mod:Storm()
		self:StopBar(L.stormCd)
		self:Bar("blackwald", 1.5, L.stormCast, "Ability_Whirlwind")
		self:ScheduleTimer(function()
			self:Bar("blackwald", 5.5, L.stormCd, "Ability_Whirlwind")
		end, 1.5)
	end

	function mod:Boon(args)
		local name = args.destName or "?"
		self:Bar("blackwald", 15, L.boonBar .. name, "Spell_Shadow_ChillTouch")
		local _, class = UnitClass("player")
		if class == "MAGE" or class == "DRUID" then
			self:Flash("blackwald")
		end
	end

	function mod:BoonFade(args)
		self:StopBar(L.boonBar .. (args.destName or "?"))
	end

	function mod:Soul(args)
		local name = args.destName or "?"
		self:Bar("blackwald", 10, name .. L.soulBar, "Spell_Shadow_Haunting")
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find("I call upon the Scythe of Elune", 1, true) then
			self:StopBar(L.summonBar)
			self:Bar("blackwald", 45, L.summonBar, "inv_misc_bone_orcskull_01")
			self:Message("blackwald", "red", L.summonMsg, "inv_misc_bone_orcskull_01")
			self:PlaySound("blackwald", "alarm")
		elseif msg:find("You dare disturb the Dark Rider Lord", 1, true) then
			self:Engage()
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Moroes
--

RavenBW:AddBoss("Moroes", ZONE, function(zoneId)
	local mod = BigWigs:NewBoss("Moroes", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.moroes = "Moroes"
		L.moroes_desc = "Smoke Bomb, Reflection, Shuffle Kick, Curse and Glittering Dust."
		L.p1Bar = "Moroes Phase 1"
		L.p2Bar = "Moroes Phase 2"
		L.smokeBar = "Players Smoke Bombed"
		L.reflectBar = "Spell Reflect!"
		L.kickBar = " Kicked"
		L.curseMsg = "Moroes Curse - decurse!"
		L.dustBar = " Dusted"
		L.dustCd = "Tank Stun (FAP soon)"
		L.p1 = "New guests? It has been a while"
		L.p1End = "Now now, why don't we save such pleasantries"
		L.p2 = "It is my duty to protect and watch over this tower"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "moroes" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Smoke", "Smoke Bomb")
		self:Log("SPELL_AURA_REMOVED", "SmokeFade", "Smoke Bomb")
		self:Log("SPELL_AURA_APPLIED", "Reflect", "Reflection")
		self:Log("SPELL_AURA_REMOVED", "ReflectFade", "Reflection")
		self:Log("SPELL_AURA_APPLIED", "Kick", "Shuffle Kick")
		self:Log("SPELL_AURA_REMOVED", "KickFade", "Shuffle Kick")
		self:Log("SPELL_AURA_APPLIED", "Curse", "Moroes Curse")
		self:Log("SPELL_AURA_APPLIED", "Dust", "Glittering Dust")
		self:Log("SPELL_AURA_REMOVED", "DustFade", "Glittering Dust")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:OnEngage()
		self:Bar("moroes", 20, L.dustCd, "Inv_Potion_04")
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find(L.p1, 1, true) then
			self:Engage()
			self:Bar("moroes", 7, L.p1Bar, "Inv_Misc_Pocketwatch_01")
		elseif msg:find(L.p1End, 1, true) then
			self:StopBar(L.p1Bar)
		elseif msg:find(L.p2, 1, true) then
			self:Engage()
			self:Bar("moroes", 12, L.p2Bar, "Inv_Misc_Pocketwatch_01")
		end
	end

	function mod:Smoke(args)
		self:Bar("moroes", 10, L.smokeBar, "Ability_Vanish")
		if args.destName == UnitName("player") then
			self:Flash("moroes")
		end
	end

	function mod:SmokeFade()
		self:StopBar(L.smokeBar)
	end

	function mod:Reflect()
		self:Bar("moroes", 5, L.reflectBar, "Spell_Arcane_Blink")
		self:Message("moroes", "red", L.reflectBar, "Spell_Arcane_Blink")
	end

	function mod:ReflectFade()
		self:StopBar(L.reflectBar)
	end

	function mod:Kick(args)
		self:Bar("moroes", 4, (args.destName or "?") .. L.kickBar, "Ability_Kick")
	end

	function mod:KickFade(args)
		self:StopBar((args.destName or "?") .. L.kickBar)
	end

	function mod:Curse()
		self:Message("moroes", "red", L.curseMsg, "Spell_Shadow_GatherShadows")
		local _, class = UnitClass("player")
		if class == "MAGE" or class == "DRUID" then
			self:Flash("moroes")
		end
	end

	function mod:Dust(args)
		self:Bar("moroes", 10, (args.destName or "?") .. L.dustBar, "Ability_Hibernation")
		self:StopBar(L.dustCd)
		self:Bar("moroes", 20, L.dustCd, "Inv_Potion_04")
	end

	function mod:DustFade(args)
		self:StopBar((args.destName or "?") .. L.dustBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Kruul (Tower of Karazhan)
--

RavenBW:AddBoss("Kruul", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("Kruul", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.kruul = "Kruul"
		L.kruul_desc = "Mark of the Highlord and Remorseless Strikes."
		L.markBar = "Mark on YOU! GET OUT!"
		L.markOther = "Mark of the Highlord on %s!"
		L.markYou = "Mark of the Highlord on YOU - GET OUT!"
		L.cursesBar = "Next Curses"
		L.strikesBar = "Next Remorseless Strikes"
		L.enrageMsg = "Kruul is ENRAGED - good luck!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "kruul" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Mark", "Mark of the Highlord")
		self:Log("SPELL_AURA_REMOVED", "MarkFade", "Mark of the Highlord")
		self:Log("SPELL_DAMAGE", "Strikes", "Remorseless Strikes")
		self:Log("SPELL_AURA_APPLIED", "Wrath", "Wrath of the Highlord")
	end

	function mod:OnEngage()
		self:Bar("kruul", 30, L.cursesBar, "Spell_Shadow_AntiShadow")
		self:Bar("kruul", 2, L.strikesBar, "Spell_Shadow_RaiseDead")
	end

	function mod:Mark(args)
		local name = args.destName or "?"
		if name == UnitName("player") then
			self:Message("kruul", "red", L.markYou, "Spell_Shadow_AntiShadow")
			self:Bar("kruul", 20, L.markBar, "Spell_Shadow_AntiShadow")
			self:PlaySound("kruul", "alarm")
		else
			self:Message("kruul", "yellow", L.markOther:format(name), "Spell_Shadow_AntiShadow")
		end
	end

	function mod:MarkFade(args)
		self:StopBar(L.markBar)
	end

	function mod:Strikes()
		self:StopBar(L.strikesBar)
		self:Bar("kruul", 4, L.strikesBar, "Spell_Shadow_RaiseDead")
	end

	function mod:Wrath()
		self:Message("kruul", "red", L.enrageMsg, "Spell_Shadow_UnholyFrenzy")
		self:PlaySound("kruul", "alarm")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Mephistroth (Tower of Karazhan)
--

RavenBW:AddBoss("Mephistroth", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("Mephistroth", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.meph = "Mephistroth"
		L.meph_desc = "Shackles, Shards of Hellfury, Doom, Nightmare, Vampiric Aura and Fear."
		L.shacklesCast = "Casting Shackles"
		L.shacklesMsg = "Shackles of the Legion incoming! DO NOT MOVE"
		L.shacklesBar = "Shackles of the Legion"
		L.shacklesYou = "You are shackled! DO NOT MOVE"
		L.shacklesOther = "%s is shackled!"
		L.shacklesCd = "Shackles on CD"
		L.shardsCast = "Shards Incoming!"
		L.shardsMsg = "Hellfire Shards casting, spread out!"
		L.shardsCd = "Shards on CD"
		L.shardsWindow = "Shards Spawn Window"
		L.doomBar = "Doom on %s"
		L.nightmareMsg = "Crawler spawning on %s"
		L.vampMsg = "Purge!"
		L.fearCast = "Fear casting!"
		L.fearMsg = "Fear incoming!"
		L.fearCd = "Fear on CD"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "meph" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "ShacklesCast", "Shackles of the Legion")
		self:Log("SPELL_AURA_APPLIED", "Shackles", "Shackles of the Legion")
		self:Log("SPELL_CAST_START", "Shards", "Shards of Hellfury")
		self:Log("SPELL_AURA_APPLIED", "Doom", "Doom of Outland")
		self:Log("SPELL_AURA_APPLIED", "Nightmare", "Waking Nightmare")
		self:Log("SPELL_AURA_APPLIED", "Vampiric", "Vampiric Aura")
		self:Log("SPELL_CAST_START", "Fear", "Nathrezim Terror")
	end

	function mod:OnEngage()
		self:Bar("meph", 60, L.shacklesCd, "INV_Belt_18")
	end

	function mod:ShacklesCast()
		self:StopBar(L.shacklesCd)
		self:Bar("meph", 2.5, L.shacklesCast, "INV_Belt_18")
		self:Message("meph", "red", L.shacklesMsg, "INV_Belt_18")
		self:PlaySound("meph", "alarm")
	end

	function mod:Shackles(args)
		local name = args.destName or "?"
		self:StopBar(L.shacklesCast)
		self:Bar("meph", 6, L.shacklesBar, "INV_Belt_18")
		if name == UnitName("player") then
			self:Message("meph", "red", L.shacklesYou, "INV_Belt_18")
			self:PlaySound("meph", "alarm")
		else
			self:Message("meph", "yellow", L.shacklesOther:format(name), "INV_Belt_18")
		end
		self:ScheduleTimer(function()
			self:Bar("meph", math.random(40, 60), L.shacklesCd, "INV_Belt_18")
		end, 6)
	end

	function mod:Shards()
		self:StopBar(L.shardsCd)
		self:StopBar(L.shardsWindow)
		self:Bar("meph", 6, L.shardsCast, "Spell_Fire_SoulBurn")
		self:Message("meph", "red", L.shardsMsg, "Spell_Fire_SoulBurn")
		self:PlaySound("meph", "alarm")
		self:ScheduleTimer(function()
			self:Bar("meph", 90, L.shardsCd, "Spell_Fire_Fire")
		end, 6)
		self:ScheduleTimer(function()
			self:Bar("meph", 30, L.shardsWindow, "Spell_Fire_Fire")
		end, 96)
	end

	function mod:Doom(args)
		local name = args.destName or "?"
		self:Bar("meph", 8, L.doomBar:format(name), "Spell_Shadow_NightOfTheDead")
		if name == UnitName("player") then
			self:Flash("meph")
		end
	end

	function mod:Nightmare(args)
		self:Message("meph", "yellow", L.nightmareMsg:format(args.destName or "?"))
	end

	function mod:Vampiric()
		self:Message("meph", "yellow", L.vampMsg, "Spell_Shadow_VampiricAura")
	end

	function mod:Fear()
		self:StopBar(L.fearCd)
		self:Bar("meph", 2.5, L.fearCast, "Spell_Shadow_DeathCoil")
		self:Message("meph", "red", L.fearMsg, "Spell_Shadow_DeathCoil")
		self:ScheduleTimer(function()
			self:Bar("meph", math.random(26, 52), L.fearCd, "Spell_Shadow_DeathCoil")
		end, 2.5)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Tower of Karazhan trash
--

RavenBW:AddBoss("Kara Trash", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("Kara Trash", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.trash = "Kara Trash"
		L.trash_desc = "Warnings for the Tower of Karazhan trash abilities."
		L.enrageMsg = "Frenzied - use Tranq Shot!"
		L.darknessBar = "Call of Darkness"
		L.darknessMsg = "Call of Darkness - interrupt!"
		L.crystalMsg = "Resonating Crystal incoming - interrupt the Suppressor!"
		L.buildupBar = "Mana Buildup blowing up"
		L.buildupYou = "Mana Buildup - get dispelled or get out of the raid!"
		L.buildupOther = "Dispel %s - Mana Buildup!"
		L.unstableBar = "Unstable Mana expires"
		L.unstableYou = "Unstable Mana - wait for it to expire (no dispels!)"
		L.unstableOther = "DON'T dispel %s - Unstable Mana!"
		L.arcanaMsg = "Flee from the Arcane Anomaly!"
		L.blizzardMsg = "Move out of Blizzard!"
		L.insightMsg = "Stop casting - Astral Insight!"
		L.rainMsg = "Shackle the Astrologist - Rain of Stars!"
		L.polyMsg = "Polymorphed!"
		L.flamesMsg = "Enveloped Flames - stop moving!"
		L.reflectMsg = "Golem spell reflect!"
		L.destructBar = "Self Destruction Protocol"
		L.destructMsg = "Self Destruction Protocol - run!"
		L.shiftedMsg = "Phase Shifted on a mob (-90% damage)!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "trash" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Enrage", "Shadowclaw Enrage")
		self:Log("SPELL_AURA_APPLIED", "Enrage", "Enrage Dragonkin")
		self:Log("SPELL_CAST_START", "Darkness", "Call of Darkness")
		self:Log("SPELL_CAST_START", "Crystal", "Summon Resonating Crystal")
		self:Log("SPELL_AURA_APPLIED", "Buildup", "Mana Buildup")
		self:Log("SPELL_AURA_REMOVED", "BuildupGone", "Mana Buildup")
		self:Log("SPELL_AURA_APPLIED", "Unstable", "Unstable Mana")
		self:Log("SPELL_AURA_APPLIED", "Arcana", "Overflowing Arcana")
		self:Log("SPELL_AURA_APPLIED", "Blizzard", "Blizzard")
		self:Log("SPELL_AURA_APPLIED", "Insight", "Astral Insight")
		self:Log("SPELL_AURA_APPLIED", "Rain", "Rain of Stars")
		self:Log("SPELL_AURA_APPLIED", "Polymorph", "Polymorph")
		self:Log("SPELL_AURA_APPLIED", "Flames", "Enveloped Flames")
		self:Log("SPELL_AURA_APPLIED", "Reflect", "Reflection Protocol")
		self:Log("SPELL_CAST_START", "Destruct", "Self Destruction Protocol")
		self:Log("SPELL_AURA_APPLIED", "Shifted", "Phase Shifted")
	end

	function mod:Enrage()
		self:Message("trash", "red", L.enrageMsg, "ability_hunter_pet_wolf")
		self:PlaySound("trash", "alarm")
	end

	function mod:Darkness()
		self:Bar("trash", 2, L.darknessBar, "Spell_Shadow_Shadowform")
		self:Message("trash", "yellow", L.darknessMsg, "Spell_Shadow_Shadowform")
	end

	function mod:Crystal()
		self:Message("trash", "yellow", L.crystalMsg, "Spell_Arcane_Arcane03")
	end

	function mod:Buildup(args)
		local name = args.destName or "?"
		if name == UnitName("player") then
			self:Message("trash", "red", L.buildupYou, "Spell_Arcane_Arcane03")
		else
			self:Message("trash", "yellow", L.buildupOther:format(name), "Spell_Arcane_Arcane03")
		end
		self:Bar("trash", 10, L.buildupBar, "Spell_Arcane_Arcane03")
	end

	function mod:BuildupGone()
		self:StopBar(L.buildupBar)
	end

	function mod:Unstable(args)
		local name = args.destName or "?"
		if name == UnitName("player") then
			self:Message("trash", "red", L.unstableYou, "Spell_Arcane_Arcane03")
		else
			self:Message("trash", "yellow", L.unstableOther:format(name), "Spell_Arcane_Arcane03")
		end
		self:Bar("trash", 10, L.unstableBar, "Spell_Arcane_Arcane03")
	end

	function mod:Arcana()
		self:Message("trash", "red", L.arcanaMsg, "Spell_Arcane_Arcane03")
		self:Flash("trash")
	end

	function mod:Blizzard(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("trash", "red", L.blizzardMsg, "Spell_Frost_IceStorm")
		self:Flash("trash")
	end

	function mod:Insight(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("trash", "red", L.insightMsg, "Spell_Arcane_Arcane03")
		self:Flash("trash")
	end

	function mod:Rain()
		self:Message("trash", "yellow", L.rainMsg, "Spell_Arcane_StarFire")
	end

	function mod:Polymorph(args)
		self:Message("trash", "yellow", L.polyMsg, "Spell_Nature_Polymorph")
	end

	function mod:Flames(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("trash", "red", L.flamesMsg, "Spell_Fire_Incinerate")
		self:Flash("trash")
	end

	function mod:Reflect()
		self:Message("trash", "red", L.reflectMsg, "Spell_Arcane_Blink")
	end

	function mod:Destruct()
		self:Bar("trash", 6, L.destructBar, "spell_fire_selfdestruct")
		self:Message("trash", "red", L.destructMsg, "spell_fire_selfdestruct")
		self:PlaySound("trash", "alarm")
	end

	function mod:Shifted()
		self:Message("trash", "yellow", L.shiftedMsg, "Spell_Shadow_Shadowform")
	end

	return mod
end, {
	"Shadowclaw Rager", "Shadowclaw Darkbringer", "Manascale Suppressor", "Manascale Drake",
	"Unstable Arcane Elemental", "Disrupted Arcane Elemental", "Arcane Anomaly",
	"Lingering Arcanist", "Lingering Astrologist", "Lingering Magus",
	"Karazhan Protector Golem", "Crumbling Protector", "Warbringer Overseer",
})

--------------------------------------------------------------------------------
-- Keeper Gnarlmoon
--

RavenBW:AddBoss("Keeper Gnarlmoon", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("Keeper Gnarlmoon", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.gnarlmoon = "Keeper Gnarlmoon"
		L.gnarlmoon_desc = "Moons, Lunar Shift, Blood Boil, the ravens and the owl phase."
		L.redMoon = "You have RED MOON!"
		L.blueMoon = "You have BLUE MOON!"
		L.shiftCast = "Lunar Shift Casting!"
		L.shiftMsg = "Lunar Shift casting!"
		L.shiftCd = "Next Lunar Shift"
		L.boilBar = "Next Blood Boil"
		L.ravensBar = "Flock of Ravens"
		L.ravensMsg = "12 ravens incoming"
		L.owlStart = "Owl Phase - kill both at the same time"
		L.owlEnd = "Owl Phase ended!"
		L.owlEnrageBar = "Owls Enrage"
		L.owlEnrageMsg = "Owls will enrage in 10 seconds!"
		L.owlGazeBar = "Color Change!"
		L.owlGazeMsg = "Imminent color change - swap sides!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "gnarlmoon" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "RedMoon", "Red Moon")
		self:Log("SPELL_AURA_APPLIED", "BlueMoon", "Blue Moon")
		self:Log("SPELL_CAST_START", "Shift", "Lunar Shift")
		self:Log("SPELL_DAMAGE", "Boil", "Blood Boil")
		self:Log("SPELL_AURA_APPLIED", "OwlStart", "Worgen Dimension")
		self:Log("SPELL_AURA_REMOVED", "OwlEnd", "Worgen Dimension")
		self:Log("SPELL_AURA_APPLIED", "Gaze", "Owl Gaze")
		self:Log("SPELL_CAST_START", "Ravens", "Flock of Ravens")
	end

	function mod:RedMoon()
		if UnitName("player") then
			self:Message("gnarlmoon", "red", L.redMoon, "inv_misc_orb_05")
			self:Flash("gnarlmoon")
		end
	end

	function mod:BlueMoon()
		self:Message("gnarlmoon", "yellow", L.blueMoon, "inv_ore_arcanite_02")
		self:Flash("gnarlmoon")
	end

	function mod:Shift()
		self:StopBar(L.shiftCd)
		self:Bar("gnarlmoon", 5, L.shiftCast, "Spell_Nature_StarFall")
		self:Message("gnarlmoon", "yellow", L.shiftMsg, "Spell_Nature_StarFall")
		self:ScheduleTimer(function()
			self:Bar("gnarlmoon", 30, L.shiftCd, "Spell_Nature_StarFall")
		end, 5)
	end

	function mod:Boil()
		self:StopBar(L.boilBar)
		self:Bar("gnarlmoon", 11, L.boilBar, "Spell_Shadow_BloodBoil")
	end

	function mod:OwlStart()
		self:Message("gnarlmoon", "red", L.owlStart, "Ability_EyeOfTheOwl")
		self:Bar("gnarlmoon", 60, L.owlEnrageBar, "Spell_Shadow_UnholyFrenzy")
		self:ScheduleTimer(function()
			self:Message("gnarlmoon", "red", L.owlEnrageMsg, "Spell_Shadow_UnholyFrenzy")
		end, 50)
	end

	function mod:OwlEnd()
		self:StopBar(L.owlEnrageBar)
		self:Message("gnarlmoon", "green", L.owlEnd)
	end

	function mod:Gaze()
		if UnitName("player") == nil then return end
		self:Message("gnarlmoon", "red", L.owlGazeMsg, "Ability_EyeOfTheOwl")
		self:Bar("gnarlmoon", 2.5, L.owlGazeBar, "Ability_EyeOfTheOwl")
		self:Flash("gnarlmoon")
	end

	function mod:Ravens()
		self:StopBar(L.ravensBar)
		self:Bar("gnarlmoon", math.random(15, 35), L.ravensBar, "Ability_Hunter_Pet_Bat")
		self:Message("gnarlmoon", "yellow", L.ravensMsg, "Ability_Hunter_Pet_Bat")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Echo of Medivh
--

RavenBW:AddBoss("Echo of Medivh", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("Echo of Medivh", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.echo = "Echo of Medivh"
		L.echo_desc = "Corruption, Doom, Arcane Focus, Flamestrike, Fury, Ire and the interrupts."
		L.corruptionYou = "YOU have Corruption! Get away from others!"
		L.corruptionOther = "%s has Corruption! Get away from them!"
		L.corruptionBar = "Corruption of Medivh"
		L.corruptionSay = "I am corrupted! STAY AWAY!"
		L.doomBar = "Doom of Medivh"
		L.doomWarn = "DOOM 4"
		L.focusMsg = "Arcane Focus on %s - dispel!"
		L.flameMsg = "Move out of Flamestrike!"
		L.furyMsg = "FURY! +%d%% cast speed"
		L.ireMsg = "Interrupt %d of 3"
		L.castMsg = "%s incoming!"
		L.castWarn = "INTERRUPT!"
	end
	L = mod:GetLocale()

	local doomStack = 0

	function mod:GetOptions()
		return { "echo" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Corruption", "Corruption of Medivh")
		self:Log("SPELL_AURA_APPLIED", "Doom", "Doom of Medivh")
		self:Log("SPELL_AURA_APPLIED", "Focus", "Arcane Focus")
		self:Log("SPELL_AURA_APPLIED", "Flamestrike", "Flamestrike")
		self:Log("SPELL_AURA_APPLIED", "Fury", "Medivh's Fury")
		self:Log("SPELL_AURA_APPLIED", "Ire", "Guardian's Ire")
		for _, spell in ipairs({ "Frost Nova", "Shadow Bolt", "Pyroblast", "Flamestrike" }) do
			self:Log("SPELL_CAST_START", "Cast", spell)
		end
	end

	function mod:OnEngage()
		doomStack = 0
	end

	function mod:Corruption(args)
		local name = args.destName or "?"
		self:Bar("echo", 12, L.corruptionBar, "INV_Misc_ShadowEgg")
		if name == UnitName("player") then
			self:Message("echo", "red", L.corruptionYou, "INV_Misc_ShadowEgg")
			self:PlaySound("echo", "alarm")
			SendChatMessage(L.corruptionSay, "SAY")
		else
			self:Message("echo", "yellow", L.corruptionOther:format(name), "INV_Misc_ShadowEgg")
		end
	end

	function mod:Doom()
		doomStack = doomStack + 1
		self:StopBar(L.doomBar)
		self:Bar("echo", math.random(14, 24), L.doomBar .. " (" .. doomStack .. ")", "Spell_Nature_Drowsy")
		if doomStack >= 4 then
			self:Message("echo", "red", L.doomWarn, "Spell_Nature_Drowsy")
			self:PlaySound("echo", "alarm")
		end
	end

	function mod:Focus(args)
		local name = args.destName or "?"
		self:Message("echo", "yellow", L.focusMsg:format(name), "Spell_Holy_FlashHeal")
		local _, class = UnitClass("player")
		if class == "PRIEST" or class == "PALADIN" then
			self:Flash("echo")
		end
	end

	function mod:Flamestrike(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("echo", "red", L.flameMsg, "Spell_Fire_SelfDestruct")
		self:Flash("echo")
	end

	function mod:Fury(args)
		local stacks = args.amount or 1
		self:Message("echo", "yellow", L.furyMsg:format(stacks * 10), "Spell_Shadow_UnholyFrenzy")
	end

	function mod:Ire(args)
		local stacks = args.amount or 1
		self:Message("echo", "yellow", L.ireMsg:format(stacks), "Spell_Shadow_Possession")
		self:Bar("echo", 15, "Interrupt Stacks Reset", "Spell_Shadow_Possession")
	end

	function mod:Cast(args)
		local spell = args.spellName or "?"
		self:Message("echo", "red", L.castMsg:format(spell) .. " " .. L.castWarn, "Spell_Frost_FrostNova")
		self:Flash("echo")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Rupturan the Broken
--

RavenBW:AddBoss("Rupturan the Broken", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("Rupturan the Broken", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.rupturan = "Rupturan the Broken"
		L.rupturan_desc = "Boulder, Ignite Earth/Rock, Dirt Mound, Living Stone stomp and Reform."
		L.boulderMsg = "Boulder casting on %s"
		L.boulderSay = "Boulder incoming on me!"
		L.earthCd = "Ignite Earth CD"
		L.earthCast = "Ignite Earth casting"
		L.rockCast = "Flamestrike casting"
		L.rockWarn = "Incoming!"
		L.rockMove = "Move out of Flamestrike!"
		L.stompBar = "Living Stone STOMP"
		L.quakeMsg = "Dirt Mound Quake! MOVE AWAY!"
		L.chaseMsg = "Dirt Mound chasing you!"
		L.reformBar = "Rupturan Reforming"
		L.phase2 = "Phase 2 - kill the fragments!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "rupturan" }
	end

	function mod:OnBossEnable()
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
		self:Log("SPELL_CAST_START", "Earth", "Ignite Earth")
		self:Log("SPELL_CAST_START", "Rock", "Ignite Rock")
		self:Log("SPELL_AURA_APPLIED", "RockMove", "Ignite Rock")
		self:Log("SPELL_DAMAGE", "Quake", "Quake")
		self:Log("SPELL_CAST_START", "Reform", "Reform")
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
		if not msg then return end
		if msg:find("Throw Boulder", 1, true) then
			self:Bar("rupturan", 2, "Boulder", "INV_Misc_PocketWatch_01")
			return
		end
		local target = msg:match("preparing to charge (.+)!")
		if target then
			self:Message("rupturan", "yellow", L.boulderMsg:format(target), "INV_Misc_PocketWatch_01")
			if target == UnitName("player") then
				SendChatMessage(L.boulderSay, "SAY")
				self:Flash("rupturan")
			end
			return
		end
		local crushed = msg:match("commands the earth to crush (.+)!")
		if crushed then
			self:Message("rupturan", "red", L.quakeMsg, "Spell_Nature_Earthquake")
			if crushed == UnitName("player") then
				self:Message("rupturan", "red", L.chaseMsg, "Spell_Nature_Earthquake")
				self:Flash("rupturan")
			end
		end
	end

	function mod:Earth()
		self:StopBar(L.earthCd)
		self:Bar("rupturan", 3, L.earthCast, "Spell_Fire_Immolation")
		self:ScheduleTimer(function()
			self:Bar("rupturan", math.random(15, 19), L.earthCd, "Spell_Fire_Immolation")
		end, 3)
	end

	function mod:Rock()
		self:StopBar(L.rockCast)
		self:Bar("rupturan", 3, L.rockCast, "Spell_Fire_SelfDestruct")
		self:Message("rupturan", "red", L.rockWarn, "Spell_Fire_SelfDestruct")
	end

	function mod:RockMove(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("rupturan", "red", L.rockMove, "Spell_Fire_Fire")
		self:Flash("rupturan")
	end

	function mod:Quake(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("rupturan", "red", L.quakeMsg, "Spell_Nature_Earthquake")
		self:Flash("rupturan")
	end

	function mod:Reform()
		self:StopBar(L.reformBar)
		self:Bar("rupturan", 10, L.reformBar, "Spell_Nature_AstralRecalGroup")
	end

	function mod:OnUnitDied(name)
		if name == "Fragment of Rupturan" then
			self:Bar("rupturan", 10, L.reformBar, "Spell_Nature_AstralRecalGroup")
		elseif name == "Living Stone" then
			self:Bar("rupturan", 5, L.stompBar, "Ability_ThunderClap")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Anomalus
--

RavenBW:AddBoss("Anomalus", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("Anomalus", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.anomalus = "Anomalus"
		L.anomalus_desc = "Arcane Overload, Dampening, Prison, Unstable Magic and Manabound Strikes."
		L.bombYou = "BOMB ON YOU"
		L.bombSay = "I have the bomb!"
		L.bombOther = "BOMB on %s!"
		L.bombBar = "Next Bomb"
		L.bombExplosion = "BOMB Explosion"
		L.dampenBar = "Arcane Dampening - Can Soak"
		L.dampenYell = "I can soak now!"
		L.prisonMsg = "Arcane Prison on %s!"
		L.zoneMsg = "Move out of the floor zone!"
		L.zoneSoak = "Soaking..."
		L.manaboundBar = "Manabound stacks expire"
	end
	L = mod:GetLocale()

	local bombCount = 0

	function mod:GetOptions()
		return { "anomalus" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Bomb", "Arcane Overload")
		self:Log("SPELL_AURA_APPLIED", "Dampen", "Arcane Dampening")
		self:Log("SPELL_AURA_REMOVED", "DampenFade", "Arcane Dampening")
		self:Log("SPELL_AURA_APPLIED", "Prison", "Arcane Prison")
		self:Log("SPELL_AURA_APPLIED", "Unstable", "Unstable Magic")
		self:Log("SPELL_AURA_APPLIED", "Manabound", "Manabound Strikes")
		self:Log("SPELL_AURA_REMOVED", "ManaboundFade", "Manabound Strikes")
	end

	function mod:OnEngage()
		bombCount = 0
	end

	function mod:Bomb(args)
		bombCount = bombCount + 1
		local name = args.destName or "?"
		local delay = 15
		self:Bar("anomalus", delay, L.bombBar, "INV_Misc_Bomb_04")
		if name == UnitName("player") then
			self:Message("anomalus", "red", L.bombYou, "INV_Misc_Bomb_04")
			self:Bar("anomalus", delay, L.bombExplosion, "INV_Misc_Bomb_04")
			self:PlaySound("anomalus", "alarm")
			SendChatMessage(L.bombSay, "SAY")
		else
			self:Message("anomalus", "yellow", L.bombOther:format(name), "INV_Misc_Bomb_04")
		end
	end

	function mod:Dampen()
		self:Bar("anomalus", 45, L.dampenBar, "Spell_Nature_AbolishMagic")
		if L.dampenYell then
			SendChatMessage(L.dampenYell, "YELL")
		end
	end

	function mod:DampenFade()
		self:StopBar(L.dampenBar)
	end

	function mod:Prison(args)
		self:Message("anomalus", "yellow", L.prisonMsg:format(args.destName or "?"), "Spell_Frost_Glacier")
	end

	function mod:Unstable(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("anomalus", "red", L.zoneMsg, "Spell_Nature_WispSplode")
		self:Flash("anomalus")
		self:PlaySound("anomalus", "alarm")
	end

	function mod:Manabound(args)
		self:Bar("anomalus", 60, (args.destName or "?") .. " " .. L.manaboundBar, "Spell_Arcane_FocusedPower")
	end

	function mod:ManaboundFade(args)
		self:StopBar((args.destName or "?") .. " " .. L.manaboundBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Ley-Watcher Incantagos
--

RavenBW:AddBoss("Ley-Watcher Incantagos", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("Ley-Watcher Incantagos", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.incantagos = "Ley-Watcher Incantagos"
		L.incantagos_desc = "Affinities, Ley-Line, Surge of Mana, summons, beams and Blizzard."
		L.leyCast = "Next Affinity"
		L.leyMsg = "Affinity incoming!"
		L.surgeYou = "Surge of Mana on YOU!"
		L.surgeOther = "Surge on %s"
		L.surgeSay = "Help me! (Surge of Mana)"
		L.seekerMsg = "Ley-Seeker summoned!"
		L.whelpsMsg = "Whelps summoned!"
		L.beamMsg = "Guided Ley-Beam on you - move!"
		L.blizzardMsg = "Blizzard - move out!"
		L.curseMsg = "Curse of Manascale at 33% - watch out!"
		L.affinity = {
			["Black Affinity"] = "BLACK AFFINITY - priests and warlocks",
			["Blue Affinity"] = "BLUE AFFINITY - mages",
			["Crystal Affinity"] = "CRYSTAL AFFINITY - warriors, rogues, paladins, hunters",
			["Green Affinity"] = "GREEN AFFINITY - shamans and druids",
			["Mana Affinity"] = "MANA AFFINITY - mages and druids",
			["Red Affinity"] = "RED AFFINITY - mages and warlocks",
		}
	end
	L = mod:GetLocale()

	local curseWarned = false

	function mod:GetOptions()
		return { "incantagos" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "LeyLine", "Ley-Line Disturbance")
		for affinity in pairs(L.affinity) do
			self:Log("SPELL_AURA_APPLIED", "Affinity", affinity)
		end
		self:Log("SPELL_AURA_APPLIED", "Surge", "Surge of Mana")
		self:Log("SPELL_CAST_SUCCESS", "Seeker", "Summon Manascale Ley-Seeker")
		self:Log("SPELL_CAST_SUCCESS", "Whelps", "Summon Manascale Whelps")
		self:Log("SPELL_AURA_APPLIED", "Beam", "Guided Ley-Beam")
		self:Log("SPELL_AURA_APPLIED", "Blizzard", "Blizzard")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:OnEngage()
		curseWarned = false
	end

	function mod:LeyLine()
		self:Bar("incantagos", 2.5, L.leyCast, "Spell_Arcane_Arcane03")
		self:Message("incantagos", "yellow", L.leyMsg, "Spell_Arcane_Arcane03")
	end

	function mod:Affinity(args)
		local text = L.affinity[args.spellName or ""]
		if text then
			self:Message("incantagos", "red", text, "Spell_Arcane_Arcane03")
			self:PlaySound("incantagos", "alarm")
		end
	end

	function mod:Surge(args)
		local name = args.destName or "?"
		if name == UnitName("player") then
			self:Message("incantagos", "red", L.surgeYou, "Spell_Arcane_Arcane03")
			self:Flash("incantagos")
			self:PlaySound("incantagos", "alarm")
			SendChatMessage(L.surgeSay, "SAY")
		else
			self:Message("incantagos", "yellow", L.surgeOther:format(name), "Spell_Arcane_Arcane03")
		end
	end

	function mod:Seeker()
		self:Message("incantagos", "yellow", L.seekerMsg)
	end

	function mod:Whelps()
		self:Message("incantagos", "yellow", L.whelpsMsg)
	end

	function mod:Beam(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("incantagos", "red", L.beamMsg, "Spell_Arcane_Arcane03")
		self:Flash("incantagos")
	end

	function mod:Blizzard(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("incantagos", "red", L.blizzardMsg, "Spell_Frost_IceStorm")
		self:Flash("incantagos")
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg or curseWarned then return end
		if msg:find("Curse of Manascale", 1, true) then
			curseWarned = true
			self:Message("incantagos", "red", L.curseMsg)
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Chess event (King, Queen, Rook, Bishop, Knight)
--

RavenBW:AddBoss("King", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("King", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.chess = "Chess Event"
		L.chess_desc = "King's Fury and Curse, Blunder, Subservience, Charming Presence, Bishop casts."
		L.furyMsg = "King's Fury incoming!"
		L.curseBar = "King's Curse CD"
		L.blunderBar = "Blunder - void zone"
		L.blunderMsg = "Void zone on you - move!"
		L.consumeMsg = "Move out of the void zone!"
		L.subBar = " Dark Subservience"
		L.charmMsg = "Charmed: %s"
		L.gloryMsg = "Knight's Glory on the King/Bishop!"
		L.volleyBar = "Shadow Bolt Volley"
		L.empoweredMsg = "Empowered Shadow Bolt - tank back off!"
		L.tonguesMsg = "Bishop needs Curse of Tongues!"
		L.queenMsg = "Queen's Fury"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "chess" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "Fury", "King's Fury")
		self:Log("SPELL_CAST_START", "Blunder", "Blunder")
		self:Log("SPELL_DAMAGE", "Consume", "Consumption")
		self:Log("SPELL_AURA_APPLIED", "Subservience", "Dark Subservience")
		self:Log("SPELL_AURA_REMOVED", "SubservienceFade", "Dark Subservience")
		self:Log("SPELL_AURA_APPLIED", "Charm", "Charming Presence")
		self:Log("SPELL_AURA_APPLIED", "Glory", "Knight's Glory")
		self:Log("SPELL_CAST_START", "Volley", "Shadow Bolt Volley")
		self:Log("SPELL_CAST_START", "Empowered", "Empowered Shadow Bolt")
		self:Log("SPELL_AURA_APPLIED", "Curse", "King's Curse")
		self:Log("SPELL_AURA_REMOVED", "CurseFade", "King's Curse")
	end

	function mod:Fury()
		self:Message("chess", "red", L.furyMsg, "Spell_Shadow_UnholyFrenzy")
		self:PlaySound("chess", "alarm")
	end

	function mod:Blunder()
		self:Bar("chess", 3, L.blunderBar, "spell_shadow_shadowbolt")
		self:Message("chess", "red", L.blunderMsg, "spell_shadow_shadowbolt")
		self:Flash("chess")
	end

	function mod:Consume(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("chess", "red", L.consumeMsg, "spell_shadow_shadowbolt")
		self:Flash("chess")
	end

	function mod:Subservience(args)
		local name = args.destName or "?"
		self:Bar("chess", 8, name .. L.subBar, "Spell_Shadow_ShadowWordDominate")
		if name == UnitName("player") then
			self:Message("chess", "red", "Dark Subservience on YOU", "Spell_Shadow_ShadowWordDominate")
			self:PlaySound("chess", "alarm")
		end
	end

	function mod:SubservienceFade()
		self:StopBar(L.subBar)
	end

	function mod:Charm(args)
		self:Message("chess", "yellow", L.charmMsg:format(args.destName or "?"), "Spell_Shadow_Charm")
	end

	function mod:Glory()
		self:Message("chess", "yellow", L.gloryMsg, "Spell_Holy_MindVision")
	end

	function mod:Volley()
		self:Bar("chess", 2.5, L.volleyBar, "spell_shadow_shadowbolt")
		self:Message("chess", "red", L.volleyBar, "spell_shadow_shadowbolt")
	end

	function mod:Empowered()
		self:Message("chess", "red", L.empoweredMsg, "spell_shadow_shadowbolt")
		self:PlaySound("chess", "alarm")
	end

	function mod:Curse(args)
		self:Bar("chess", 8, (args.destName or "?") .. " King's Curse", "Spell_Shadow_CurseOfSargeras")
	end

	function mod:CurseFade()
		self:StopBar("King's Curse")
	end

	return mod
end, { "Queen", "Rook", "Bishop", "Knight" })

--------------------------------------------------------------------------------
-- Sanv Tas'dal
--

RavenBW:AddBoss("Sanv Tas'dal", "Tower of Karazhan", function(zoneId)
	local mod = BigWigs:NewBoss("Sanv Tas'dal", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.sanv = "Sanv Tas'dal"
		L.sanv_desc = "Phase Shifted, Overflowing Hatred, the add phase, Curse of the Rift and Rift Feedback."
		L.phaseYou = "Phase Shifted - kill Netherwalkers!"
		L.phaseOther = "%s has Phase Shifted."
		L.phaseBar = "Phase Shifted"
		L.hatredBar = "Overflowing Hatred"
		L.hatredMsg = "Get away from the boss - Overflowing Hatred casting!"
		L.addBar = "Add Phase"
		L.addMsg = "40% - add phase!"
		L.portalsMsg = "80% - portals opening"
		L.curseBar = "next Curse"
		L.feedbackBar = "Rift Feedback CD"
		L.keepCurse = "Keep the Curse - Feedback soon!"
		L.enrageMsg = "Enrage - Tranq now!"
	end
	L = mod:GetLocale()

	local hit80, hit40 = false, false

	function mod:GetOptions()
		return { "sanv" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Phase", "Phase Shifted")
		self:Log("SPELL_AURA_REMOVED", "PhaseFade", "Phase Shifted")
		self:Log("SPELL_CAST_START", "Hatred", "Overflowing Hatred")
		self:Log("SPELL_AURA_APPLIED", "Curse", "Curse of the Rift")
		self:Log("SPELL_DAMAGE", "Feedback", "Rift Feedback")
		self:Log("SPELL_AURA_APPLIED", "Enrage", "Enrage")
		self:RegisterEvent("UNIT_HEALTH")
	end

	function mod:OnEngage()
		hit80, hit40 = false, false
		self:Bar("sanv", 15, L.curseBar, "Spell_Shadow_GrimWard")
	end

	function mod:Phase(args)
		local name = args.destName or "?"
		self:Bar("sanv", 25, L.phaseBar, "Spell_Shadow_AbominationExplosion")
		if name == UnitName("player") then
			self:Message("sanv", "red", L.phaseYou, "Spell_Shadow_AbominationExplosion")
			self:PlaySound("sanv", "alarm")
		else
			self:Message("sanv", "yellow", L.phaseOther:format(name), "Spell_Shadow_AbominationExplosion")
		end
	end

	function mod:PhaseFade()
		self:StopBar(L.phaseBar)
	end

	function mod:Hatred()
		self:Bar("sanv", 6, L.hatredBar, "Spell_Fire_Incinerate")
		self:Message("sanv", "red", L.hatredMsg, "Spell_Fire_Incinerate")
		self:PlaySound("sanv", "alarm")
	end

	function mod:Curse()
		self:StopBar(L.curseBar)
		self:Bar("sanv", 15, L.curseBar, "Spell_Shadow_GrimWard")
	end

	function mod:Feedback()
		self:Message("sanv", "yellow", L.keepCurse, "Spell_Nature_Wispsplode")
		self:Bar("sanv", 45, L.feedbackBar, "Spell_Nature_Wispsplode")
	end

	function mod:Enrage()
		self:Message("sanv", "red", L.enrageMsg, "Spell_Shadow_UnholyFrenzy")
	end

	function mod:UNIT_HEALTH(_, unit)
		if unit ~= "target" then return end
		if UnitName("target") ~= "Sanv Tas'dal" then return end
		local max = UnitHealthMax("target")
		if not max or max == 0 then return end
		local percent = math.ceil(100 * UnitHealth("target") / max)
		if not hit80 and percent <= 80 then
			hit80 = true
			self:Message("sanv", "yellow", L.portalsMsg)
		end
		if not hit40 and percent <= 40 then
			hit40 = true
			self:Message("sanv", "red", L.addMsg)
			self:Bar("sanv", 50, L.addBar, "Spell_Arcane_TeleportOrgrimmar")
			self:PlaySound("sanv", "alarm")
		end
	end

	return mod
end)
