-- BigWigs_Raven :: outdoor / world bosses (RavenCraft additions)
--
-- The 1.18 fork has modules for the outdoor bosses that v36's World pack does
-- not cover. They are enabled by boss name, like the custom dungeon modules.

local RavenBW = _G.RavenBW

--------------------------------------------------------------------------------
-- Doctor Weavil (Dustwallow Marsh)
--

RavenBW:AddBoss("Doctor Weavil", "Dustwallow Marsh", function(zoneId)
	local mod = BigWigs:NewBoss("Doctor Weavil", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.weavil = "Doctor Weavil"
		L.weavil_desc = "Mind Shatter and Mental Domination timers."
		L.shatterCd = "Mind Shatter CD"
		L.shatterSoon = "Mind Shatter Soon..."
		L.mcBar = " MC"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "weavil" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "MindShatter", "Mind Shatter")
		self:Log("SPELL_AURA_APPLIED", "Mc", "Mental Domination")
		self:Log("SPELL_AURA_REMOVED", "McFade", "Mental Domination")
	end

	function mod:OnEngage()
		self:Bar("weavil", 10, L.shatterCd, "spell_nature_earthquake")
	end

	function mod:MindShatter()
		self:StopBar(L.shatterCd)
		self:StopBar(L.shatterSoon)
		self:Bar("weavil", 10, L.shatterCd, "spell_nature_earthquake")
		self:ScheduleTimer(function()
			self:Bar("weavil", 6, L.shatterSoon, "spell_nature_earthquake")
		end, 10)
		self:Flash("weavil")
		self:PlaySound("weavil", "info")
	end

	function mod:Mc(args)
		local name = args.destName or "?"
		self:Bar("weavil", 120, name .. L.mcBar, "spell_shadow_metamorphosis")
		if name == UnitName("player") then
			self:Flash("weavil")
		end
	end

	function mod:McFade(args)
		self:StopBar((args.destName or "?") .. L.mcBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Twilight Corrupter (Duskwood)
--

RavenBW:AddBoss("Twilight Corrupter", "Duskwood", function(zoneId)
	local mod = BigWigs:NewBoss("Twilight Corrupter", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.twilight = "Twilight Corrupter"
		L.twilight_desc = "Creature of Nightmare and Soul Corruption timers."
		L.mcBar = " MC"
		L.mcCd = "MC CD"
		L.soulCd = "Soul Corruption CD"
		L.soulSoon = "Soul Corruption Soon..."
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "twilight" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Nightmare", "Creature of Nightmare")
		self:Log("SPELL_AURA_REMOVED", "NightmareFade", "Creature of Nightmare")
		self:Log("SPELL_AURA_APPLIED", "SoulCorruption", "Soul Corruption")
	end

	function mod:OnEngage()
		self:Bar("twilight", 20, L.soulCd, "spell_shadow_fumble")
	end

	function mod:Nightmare(args)
		local name = args.destName or "?"
		self:Bar("twilight", 30, name .. L.mcBar, "spell_shadow_shadowworddominate")
		self:ScheduleTimer(function()
			self:Bar("twilight", 8, L.mcCd, "spell_shadow_shadowworddominate")
		end, 30)
		if name == UnitName("player") then
			self:Flash("twilight")
		end
	end

	function mod:NightmareFade(args)
		self:StopBar((args.destName or "?") .. L.mcBar)
	end

	function mod:SoulCorruption()
		self:StopBar(L.soulCd)
		self:StopBar(L.soulSoon)
		self:Bar("twilight", 20, L.soulCd, "spell_shadow_fumble")
		self:ScheduleTimer(function()
			self:Bar("twilight", 10, L.soulSoon, "spell_shadow_fumble")
		end, 20)
		self:Flash("twilight")
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Atiesh (Stratholme, Elders' Square)
--

RavenBW:AddBoss("Atiesh", "Stratholme", function(zoneId)
	local mod = BigWigs:NewBoss("Atiesh", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.atiesh = "Atiesh"
		L.atiesh_desc = "Unholy Aura, Shadow Bolt, Breath of Sargeras and the Eye of Naxxramas."
		L.auraBar = "Unholy Aura"
		L.boltCast = "Shadow Bolt Cast!"
		L.boltCd = "Shadow Bolt CD"
		L.breathCast = "Breath of Sargeras Cast"
		L.breathCd = "Breath of Sargeras CD"
		L.breathAfflic = " Cursed"
		L.breathMsg = "Breath of Sargeras - decurse (melee and hunters only)"
		L.eyeBar = "Eye of Naxxramas!"
		L.eyeYell = "The living are here!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "atiesh" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "Aura", "Unholy Aura")
		self:Log("SPELL_CAST_START", "Bolt", "Shadow Bolt")
		self:Log("SPELL_CAST_START", "Breath", "Breath of Sargeras")
		self:Log("SPELL_AURA_APPLIED", "BreathAfflic", "Breath of Sargeras")
		self:Log("SPELL_AURA_REMOVED", "BreathFade", "Breath of Sargeras")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:Aura()
		self:StopBar(L.auraBar)
		self:Bar("atiesh", 2, L.auraBar, "spell_shadow_unholystrength")
	end

	function mod:Bolt()
		self:StopBar(L.boltCd)
		self:Bar("atiesh", 0.5, L.boltCast, "spell_shadow_shadowbolt")
		self:ScheduleTimer(function()
			self:Bar("atiesh", math.random(12, 17), L.boltCd, "spell_shadow_shadowbolt")
		end, 0.5)
	end

	function mod:Breath()
		self:StopBar(L.breathCd)
		self:Bar("atiesh", 2, L.breathCast, "spell_shadow_metamorphosis")
		self:ScheduleTimer(function()
			self:Bar("atiesh", math.random(13, 23), L.breathCd, "spell_shadow_metamorphosis")
		end, 2)
	end

	function mod:BreathAfflic(args)
		local name = args.destName or "?"
		self:Bar("atiesh", 90, name .. L.breathAfflic, "spell_shadow_metamorphosis")
		if name == UnitName("player") then
			self:Flash("atiesh")
		end
	end

	function mod:BreathFade(args)
		self:StopBar((args.destName or "?") .. L.breathAfflic)
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if msg and msg:find(L.eyeYell, 1, true) then
			self:Bar("atiesh", 7, L.eyeBar, "inv_misc_shadowegg")
			self:Flash("atiesh")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Dark Reaver of Karazhan (Deadwind Pass)
--

RavenBW:AddBoss("Dark Reaver of Karazhan", "Deadwind Pass", function(zoneId)
	local mod = BigWigs:NewBoss("Dark Reaver of Karazhan", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.reaver = "Dark Reaver of Karazhan"
		L.reaver_desc = "Adds, enrage, deterrence, reflexes, strike and armor debuffs."
		L.forlornBar = "4 Forlorn Spirit"
		L.forlornMsg = "4 Forlorn Spirits spawned!"
		L.shadowBar = "Lurking Shadow"
		L.shadowMsg = " Lurking Shadow!"
		L.deterrenceBar = "Deterrence 25% Dodge/Parry"
		L.reflexesBar = "Reflexes 75% Parry"
		L.strikeBar = " Unbalancing"
		L.armorBar = " Pierce Armor"
		L.enrageMsg = "Enrage!"
	end
	L = mod:GetLocale()

	local forlorn = 0

	function mod:GetOptions()
		return { "reaver" }
	end

	function mod:OnBossEnable()
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
		self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
		self:Log("SPELL_AURA_APPLIED", "Enrage", "Furious Anger")
		self:Log("SPELL_AURA_APPLIED", "Deterrence", "Deterrence")
		self:Log("SPELL_AURA_REMOVED", "DeterrenceFade", "Deterrence")
		self:Log("SPELL_AURA_APPLIED", "Reflexes", "Nimble Reflexes")
		self:Log("SPELL_AURA_REMOVED", "ReflexesFade", "Nimble Reflexes")
		self:Log("SPELL_AURA_APPLIED", "Strike", "Unbalancing Strike")
		self:Log("SPELL_AURA_REMOVED", "StrikeFade", "Unbalancing Strike")
		self:Log("SPELL_AURA_APPLIED", "Armor", "Pierce Armor")
		self:Log("SPELL_AURA_REMOVED", "ArmorFade", "Pierce Armor")
	end

	function mod:OnEngage()
		forlorn = 0
		self:Bar("reaver", 22, L.forlornBar, "spell_shadow_burningspirit")
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find("Spirits, rise, and drive back", 1, true) or msg:find("Rise, spirits. Defend the Master", 1, true) then
			forlorn = forlorn + 1
			self:StopBar(L.forlornBar)
			self:Bar("reaver", 2 * forlorn, L.forlornBar, "spell_shadow_burningspirit")
			self:ScheduleTimer(function()
				self:Bar("reaver", 20, L.forlornBar, "spell_shadow_burningspirit")
			end, 2 * forlorn)
			self:Message("reaver", "yellow", L.forlornMsg)
		end
	end

	function mod:CHAT_MSG_MONSTER_EMOTE(_, msg)
		if not msg then return end
		local class = msg:match("A (.+) shadow appears next to")
		if class then
			self:Bar("reaver", 10, class .. L.shadowBar, "ability_creature_poison_05")
			self:Message("reaver", "yellow", class .. L.shadowMsg)
		end
	end

	function mod:Enrage()
		self:Flash("reaver")
		self:PlaySound("reaver", "alarm")
		self:Message("reaver", "red", L.enrageMsg)
	end

	function mod:Deterrence()
		self:Bar("reaver", 10, L.deterrenceBar, "ability_whirlwind")
	end

	function mod:DeterrenceFade()
		self:StopBar(L.deterrenceBar)
	end

	function mod:Reflexes()
		self:Bar("reaver", 8, L.reflexesBar, "ability_meleedamage")
	end

	function mod:ReflexesFade()
		self:StopBar(L.reflexesBar)
	end

	function mod:Strike(args)
		self:Bar("reaver", 6, (args.destName or "?") .. L.strikeBar, "ability_warrior_decisivestrike")
	end

	function mod:StrikeFade(args)
		self:StopBar((args.destName or "?") .. L.strikeBar)
	end

	function mod:Armor(args)
		self:Bar("reaver", 20, (args.destName or "?") .. L.armorBar, "spell_shadow_vampiricaura")
	end

	function mod:ArmorFade(args)
		self:StopBar((args.destName or "?") .. L.armorBar)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Nerubian Overseer (Eastern Plaguelands)
--

RavenBW:AddBoss("Nerubian Overseer", "Eastern Plaguelands", function(zoneId)
	local mod = BigWigs:NewBoss("Nerubian Overseer", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.overseer = "Nerubian Overseer"
		L.overseer_desc = "Shadow Shock, poisons, Web Spray and Explode."
		L.shockBar = "Shadow Shock"
		L.spitBar = "Venom Spit"
		L.corrosiveBar = " Corrosive Poison"
		L.necroticBar = " Necrotic Poison"
		L.webCd = "Next Web Spray"
		L.webBar = " Web Spray"
		L.explodeMsg = " exploded, 4 Nerublings spawned!"
		L.cloudMsg = "Move out of the Poison Cloud!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "overseer" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_DAMAGE", "Shock", "Shadow Shock")
		self:Log("SPELL_AURA_APPLIED", "Spit", "Venom Spit")
		self:Log("SPELL_AURA_APPLIED", "Cloud", "Poison Cloud")
		self:Log("SPELL_AURA_APPLIED", "Corrosive", "Corrosive Poison")
		self:Log("SPELL_AURA_REMOVED", "CorrosiveFade", "Corrosive Poison")
		self:Log("SPELL_AURA_APPLIED", "Necrotic", "Necrotic Poison")
		self:Log("SPELL_AURA_REMOVED", "NecroticFade", "Necrotic Poison")
		self:Log("SPELL_AURA_APPLIED", "Web", "Web Spray")
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	end

	function mod:OnEngage()
		self:Bar("overseer", 10, L.shockBar, "spell_shadow_shadowbolt")
		self:Bar("overseer", 30, L.spitBar, "spell_nature_corrosivebreath")
		self:Bar("overseer", 19, L.webCd, "spell_nature_web")
	end

	function mod:Shock()
		self:StopBar(L.shockBar)
		self:Bar("overseer", 10, L.shockBar, "spell_shadow_shadowbolt")
	end

	function mod:Spit()
		self:StopBar(L.spitBar)
		self:Bar("overseer", 30, L.spitBar, "spell_nature_corrosivebreath")
		if UnitClass("player") == "SHAMAN" then
			self:Flash("overseer")
		end
	end

	function mod:Cloud(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("overseer", "red", L.cloudMsg, "spell_nature_abolishmagic")
		self:Flash("overseer")
		self:PlaySound("overseer", "alarm")
	end

	function mod:Corrosive(args)
		self:Bar("overseer", 30, (args.destName or "?") .. L.corrosiveBar, "Corrosive Acid Spit")
	end

	function mod:CorrosiveFade(args)
		self:StopBar((args.destName or "?") .. L.corrosiveBar)
	end

	function mod:Necrotic(args)
		self:Bar("overseer", 30, (args.destName or "?") .. L.necroticBar, "ability_creature_poison_03")
	end

	function mod:NecroticFade(args)
		self:StopBar((args.destName or "?") .. L.necroticBar)
	end

	function mod:Web(args)
		self:Bar("overseer", 10, (args.destName or "?") .. L.webBar, "inv_egg_04")
		self:StopBar(L.webCd)
		self:Bar("overseer", 24, L.webCd, "spell_nature_web")
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
		if not msg then return end
		local who = msg:match("^(.+) explodes")
		if who then
			self:Message("overseer", "yellow", who .. L.explodeMsg)
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Concavius (Desolace)
--

RavenBW:AddBoss("Concavius", "Desolace", function(zoneId)
	local mod = BigWigs:NewBoss("Concavius", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.concavius = "Concavius"
		L.concavius_desc = "Void Bolt, Piercing Shadow, Mana Burn, Veil of Shadow and Vacuum."
		L.shockBar = "Shadow Shock CD"
		L.shockMsg = "Concavius below 30%: Shadow Shocks and more Piercing Shadows"
		L.manaCd = "Mana Burn CD"
		L.manaAfflic = "Disorient"
		L.manaSoon = "Mana Burn in 3 sec - hide!"
		L.veilBar = "Veil of Shadow"
		L.veilMsg = "Veil of Shadow - decurse!"
		L.voidBar = "Void Bolt CD"
		L.voidCast = "Casting Void Bolt"
		L.pierceBar = "Piercing Shadow CD"
		L.pierceCast = "Casting Piercing Shadow"
		L.pierceAfflic = "Piercing Shadow"
		L.pierceMsg = "Piercing Shadow - decurse!"
		L.vacuumBar = "Vacuum CD"
		L.engage = "Let the void claim you"
		L.perish = "Perish."
		L.vacuum = "Embrace the void!"
	end
	L = mod:GetLocale()

	local p2 = false

	function mod:GetOptions()
		return { "concavius" }
	end

	function mod:OnBossEnable()
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
		self:Log("SPELL_AURA_APPLIED", "P2", "Shadowform")
		self:Log("SPELL_DAMAGE", "Shock", "Shadow Shock")
		self:Log("SPELL_AURA_APPLIED", "ManaBurn", "Mana Burn")
		self:Log("SPELL_AURA_APPLIED", "Veil", "Veil of Shadow")
		self:Log("SPELL_AURA_REMOVED", "VeilFade", "Veil of Shadow")
		self:Log("SPELL_CAST_START", "VoidBolt", "Void Bolt")
		self:Log("SPELL_CAST_START", "Piercing", "Piercing Shadow")
		self:Log("SPELL_AURA_APPLIED", "PiercingAfflic", "Piercing Shadow")
		self:Log("SPELL_AURA_REMOVED", "PiercingFade", "Piercing Shadow")
	end

	function mod:OnEngage()
		p2 = false
		self:Bar("concavius", 20, L.vacuumBar, "spell_shadow_shadowbolt")
		self:Bar("concavius", 30, L.manaCd, "spell_shadow_manaburn")
		self:Bar("concavius", 4.5, L.voidCast, "spell_shadow_shadowbolt")
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		if msg:find(L.engage, 1, true) then
			self:Engage()
		elseif msg:find(L.perish, 1, true) then
			self:StopBar(L.manaCd)
			self:Bar("concavius", 30, L.manaCd, "spell_shadow_manaburn")
			self:Message("concavius", "yellow", L.manaSoon, "spell_shadow_manaburn")
		elseif msg:find(L.vacuum, 1, true) then
			self:StopBar(L.vacuumBar)
			self:Bar("concavius", 30, L.vacuumBar, "spell_shadow_shadowbolt")
		end
	end

	function mod:P2()
		p2 = true
		self:Message("concavius", "red", L.shockMsg, "spell_holy_prayerofshadowprotection")
	end

	function mod:Shock()
		self:Bar("concavius", math.random(8, 16), L.shockBar, "spell_holy_prayerofshadowprotection")
	end

	function mod:ManaBurn(args)
		local name = args.destName or "?"
		self:Bar("concavius", 8, name, "spell_shadow_manaburn")
	end

	function mod:Veil(args)
		local name = args.destName or "?"
		self:Bar("concavius", 10, name .. L.veilBar, "spell_shadow_curseofsargeras")
		if name == UnitName("player") then
			self:Message("concavius", "yellow", L.veilMsg)
		end
	end

	function mod:VeilFade(args)
		self:StopBar((args.destName or "?") .. L.veilBar)
	end

	function mod:VoidBolt()
		self:StopBar(L.voidBar)
		self:StopBar(L.voidCast)
		self:Bar("concavius", 4.5, L.voidCast, "spell_shadow_shadowbolt")
		self:ScheduleTimer(function()
			self:Bar("concavius", math.random(4, 7), L.voidBar, "spell_shadow_shadowbolt")
		end, 4.5)
	end

	function mod:Piercing()
		self:StopBar(L.pierceBar)
		self:Bar("concavius", 2, L.pierceCast, "spell_shadow_shadowbolt")
		self:ScheduleTimer(function()
			self:Bar("concavius", p2 and 10 or 58, L.pierceBar, "spell_shadow_shadowbolt")
		end, 2)
	end

	function mod:PiercingAfflic(args)
		local name = args.destName or "?"
		self:Bar("concavius", 1800, name .. L.pierceAfflic, "spell_shadow_shadowbolt")
		if name == UnitName("player") then
			self:Message("concavius", "yellow", L.pierceMsg)
		end
	end

	function mod:PiercingFade(args)
		self:StopBar((args.destName or "?") .. L.pierceAfflic)
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Ostarius (Tanaris)
--

RavenBW:AddBoss("Ostarius", "Tanaris", function(zoneId)
	local mod = BigWigs:NewBoss("Ostarius", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.ostarius = "Ostarius"
		L.ostarius_desc = "Activation countdown, portals, Conflagration, Chain Lightning, AoEs and phases."
		L.activeBar = "Ostarius Activates"
		L.portalsBar = "Next Portals"
		L.portalsMsg = "Portals!"
		L.conflagBar = " Conflag"
		L.conflagYou = "CONFLAG ON ME! RUN AWAY!"
		L.conflagMove = "Move away from Conflagration!"
		L.chainBar = "Next Chain Lightning"
		L.blizzardMsg = "Move away from Blizzard!"
		L.rainMsg = "Move away from Rain of Fire!"
		L.sonicMsg = "Sonic Burst is 20 yards..."
		L.stompBar = " Stomped"
		L.eqMsg = "Earthquake soon! Melee out!"
		L.eqDone = "Earthquake done! Melee in!"
		L.phase2 = "Phase 2 - AoEs"
		L.phase3 = "Phase 3 - no more Blizzard, go slow"
		L.phase4 = "Phase 4 - kill the boss!"
		L.trapsMsg = "Traps phase - disarm on sight!"
		L.trapsDone = "Traps phase ended"
		L.active = {
			["Welcome, honored guests, to the research facility."] = 33,
			["Please wait for the initial scanning..."] = 27,
			["WARNING! Curse of the flesh detected!"] = 17,
			["Initiating manual gate override... Gate locked successfully."] = 13,
			["Activating defensive system for threat elimination."] = 6,
		}
		L.activeNow = "Guardians, awaken and smite these intruders!"
		L.p3 = "Still you persist, servants of the old ones?"
		L.p4 = "NO! I will not fail again!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "ostarius" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Conflag", "Conflagration")
		self:Log("SPELL_AURA_REMOVED", "ConflagFade", "Conflagration")
		self:Log("SPELL_DAMAGE", "Chain", "Chain Lightning")
		self:Log("SPELL_AURA_APPLIED", "Blizzard", "Blizzard")
		self:Log("SPELL_AURA_APPLIED", "Rain", "Rain of Fire")
		self:Log("SPELL_AURA_APPLIED", "Sonic", "Sonic Burst")
		self:Log("SPELL_AURA_APPLIED", "Stomp", "Stomp")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if not msg then return end
		local delay = L.active[msg]
		if delay then
			self:Bar("ostarius", delay, L.activeBar, "inv_misc_pocketwatch_01")
			return
		end
		if msg == L.activeNow then
			self:Bar("ostarius", 1, L.activeBar, "inv_misc_pocketwatch_01")
			self:Bar("ostarius", 40, L.portalsBar, "spell_arcane_portaldarnassus")
			self:Engage()
		elseif msg:find(L.p3, 1, true) then
			self:Message("ostarius", "yellow", L.phase3)
		elseif msg:find(L.p4, 1, true) then
			self:Message("ostarius", "red", L.phase4)
		end
	end

	function mod:Conflag(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("ostarius", "red", L.conflagYou, "spell_fire_incinerate")
		self:Bar("ostarius", 10, L.conflagBar, "spell_fire_incinerate")
		self:PlaySound("ostarius", "alarm")
	end

	function mod:ConflagFade()
		self:StopBar(L.conflagBar)
	end

	function mod:Chain()
		self:StopBar(L.chainBar)
		self:Bar("ostarius", 15, L.chainBar, "Spell_Nature_ChainLightning")
	end

	function mod:Blizzard(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("ostarius", "red", L.blizzardMsg, "spell_frost_icestorm")
		self:Flash("ostarius")
	end

	function mod:Rain(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("ostarius", "red", L.rainMsg, "spell_shadow_rainoffire")
		self:Flash("ostarius")
	end

	function mod:Sonic(args)
		if args.destName ~= UnitName("player") then return end
		self:Message("ostarius", "yellow", L.sonicMsg, "spell_shadow_teleport")
	end

	function mod:Stomp(args)
		self:Bar("ostarius", 12, (args.destName or "?") .. L.stompBar, "Ability_WarStomp")
	end

	return mod
end)
