-- BigWigs_Raven :: Blackwing Lair (RavenCraft additions)
--
-- The 1.18 fork adds a trash module for the Blackwing Alchemists (Alchemist's
-- Fire), the Ezzel Darkbrewer event and the Death Talon Wyrmguard vulnerability
-- tracker. The stock boss modules stay in BigWigs_BlackwingLair.

local RavenBW = _G.RavenBW

--------------------------------------------------------------------------------
-- Blackwing Alchemist (Alchemist's Fire)
--

RavenBW:AddBoss("Blackwing Alchemist", "Blackwing Lair", function(zoneId)
	local mod = BigWigs:NewBoss("Blackwing Alchemist", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.fire = "Alchemist's Fire"
		L.fire_desc = "Warn when Alchemist's Fire is applied."
		L.firesay = "Alchemist's Fire Say"
		L.firesay_desc = "Announce in /say that you have Alchemist's Fire."
		L.fireother = "Alchemist's Fire Warning"
		L.fireother_desc = "Warn when another player gets Alchemist's Fire."

		L.fireBar = "Alchemist's Fire"
		L.fireMsg = "Get out of the raid! - Alchemist's Fire"
		L.fireOtherMsg = "Alchemist's Fire on %s"
		L.fireSay = "Don't be near me - Alchemist's Fire!"
	end
	L = mod:GetLocale()

	function mod:GetOptions()
		return { "fire", "firesay", "fireother" }
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Fire", "Alchemist's Fire")
	end

	function mod:Fire(args)
		local name = args.destName
		if not name then return end
		if name == UnitName("player") then
			self:Message("fire", "red", L.fireMsg, "INV_Potion_33")
			self:Bar("fire", 8, L.fireBar, "INV_Potion_33")
			self:PlaySound("fire", "alarm")
			local say = self:GetOption("firesay")
			if say and say > 0 then
				SendChatMessage(L.fireSay, "SAY")
			end
		elseif self:GetOption("fireother") then
			self:Message("fire", "yellow", L.fireOtherMsg:format(name), "INV_Potion_33")
		end
	end

	return mod
end)

--------------------------------------------------------------------------------
-- Ezzel Darkbrewer (Alchemist event boss)
--

RavenBW:AddBoss("Ezzel Darkbrewer", "Blackwing Lair", function(zoneId)
	local mod = BigWigs:NewBoss("Ezzel Darkbrewer", zoneId)
	if not mod then return end

	local L = mod:NewLocale("enUS", true)
	if L then
		L.bossName = "Ezzel Darkbrewer"

		L.charge = "Charge"
		L.charge_desc = "Warn for incoming Charges."
		L.precharge = "Charge Soon"
		L.precharge_desc = "Warn before the next Charge (every 25% health)."
		L.acid = "Acid Bomb"
		L.acid_desc = "Warn when you stand in Acid Bomb."
		L.transmute = "Transmute to Gold"
		L.transmute_desc = "Warn when Ezzel begins to cast Transmute to Gold."
		L.tongues = "Curse of Tongues"
		L.tongues_desc = "Warn if Curse of Tongues is missing near the end."

		L.chargeBar = "Charge on %s"
		L.chargeSay = "Charge On Me!"
		L.preChargeMsg = "Charge soon!"
		L.acidMsg = "ACID - MOVE"
		L.transmuteBar = "Kill Boss"
		L.chemicalRage = "Damage Reduction active"
		L.tonguesMsg = "CoT missing!"
	end
	L = mod:GetLocale()

	local nextThreshold = 80

	function mod:GetOptions()
		return { "charge", "precharge", "acid", "transmute", "tongues" }
	end

	function mod:OnBossEnable()
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
		self:Log("SPELL_AURA_APPLIED", "Acid", "Acid Bomb")
		self:Log("SPELL_PERIODIC_DAMAGE", "AcidTick", "Acid Bomb")
		self:Log("SPELL_CAST_START", "Transmute", "Transmute to Gold")
		self:Log("SPELL_AURA_APPLIED", "Concussion", "Concussion")
	end

	function mod:OnEngage()
		nextThreshold = 80
		self:StopBar(L.chemicalRage)
		self:ScheduleRepeatingTimer("CheckHealth", 0.5)
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
		if not msg then return end
		local player = msg:match("begins charging (.+)!")
		if player then
			self:Charge(player)
		end
	end

	function mod:Charge(player)
		self:StopBar(L.chargeBar:format(player))
		self:Bar("charge", 8, L.chargeBar:format(player), "ABILITY_MOUNT_MOUNTAINRAM")
		if player == UnitName("player") then
			self:Flash("charge")
			self:PlaySound("charge", "alarm")
			SendChatMessage(L.chargeSay, "SAY")
		else
			self:PlaySound("charge", "alarm")
		end
	end

	function mod:Acid(args)
		if args and args.destName ~= UnitName("player") then return end
		self:Flash("acid")
		self:PlaySound("acid", "info")
	end

	function mod:AcidTick(args)
		if args.destName ~= UnitName("player") then return end
		self:Flash("acid")
		self:PlaySound("acid", "info")
	end

	function mod:Transmute()
		self:Bar("transmute", 8, L.transmuteBar, "SPELL_HOLY_HARMUNDEADAURA")
		self:PlaySound("transmute", "warning")
	end

	function mod:Concussion()
		self:StopBar(L.chemicalRage)
	end

	function mod:CheckHealth()
		if not self:IsEngaged() then return end
		local name = UnitName("target")
		if name ~= "Ezzel Darkbrewer" and name ~= "Ton'Raka" then return end
		local max = UnitHealthMax("target")
		if not max or max == 0 then return end
		local percent = math.ceil(100 * UnitHealth("target") / max)

		if percent <= nextThreshold then
			self:Message("precharge", "yellow", L.preChargeMsg, "ABILITY_MOUNT_MOUNTAINRAM")
			nextThreshold = nextThreshold - 25
		end

		if percent < 15 then
			if not UnitDebuff("target", "Curse of Tongues") then
				self:Message("tongues", "red", L.tonguesMsg, "Spell_Shadow_CurseOfTounges")
				self:PlaySound("tongues", "alarm")
			end
		end
	end

	return mod
end, { "Ton'Raka" })
