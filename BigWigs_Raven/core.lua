-- BigWigs_Raven :: RavenCraft custom content for BigWigs (1.14.2)
--
-- BigWigs v36 knows the classic instances only. RavenCraft adds its own dungeons
-- and raids (Emerald Sanctum, Karazhan Crypt, Lower Karazhan Halls, Tower of
-- Karazhan, Timbermaw Hold, Black Morass, Stormwind Vault, ...). This addon
-- registers those bosses with the BigWigs boss prototype and provides the two
-- things BigWigs cannot know by itself:
--
--   * zone ids for the custom maps (discovered at login by scanning
--     GetRealZoneText, because the ids are not in BigWigs' static zone table);
--   * an engage trigger that works by boss *name*, because custom bosses carry
--     no encounter ids and we do not ship mob ids for every one of them.
--
-- Everything else (bars, messages, sounds, options, combat log parsing) is the
-- normal BigWigs machinery.

local ADDON, RavenBW = ...

_G.RavenBW = RavenBW

RavenBW.version = "0.1.0"
RavenBW.pending = {}      -- boss definitions waiting for BigWigs_Core
RavenBW.bosses = {}       -- moduleName -> BigWigs module
RavenBW.zoneCache = {}    -- zone name -> zone id
RavenBW.zoneNames = nil   -- id -> name, built once
RavenBW.built = false

local FALLBACK_ZONE = -947 -- "Azeroth (Fake)" is always in BigWigs' zone table

--------------------------------------------------------------------------------
-- small helpers
--

local function print_(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cffeda55fBigWigs_Raven|r: " .. tostring(msg))
end

function RavenBW:Print(msg) print_(msg) end

-- File export via DLL gate — disabled in this release build.
local SEP = string.char(1)
local DLL_FILE_DEBUG = false
local function exportFile(path, text)
	if not DLL_FILE_DEBUG then return false end
	local lib = _G.RavenEraLib
	if lib and lib.Sept then
		local ok = pcall(lib.Sept, lib, "ExportFile", path, text)
		if ok then return true end
	end
	local gate = _G.RavenEraGate or _G.RavenEra_S1
	if type(gate) == "function" then
		return pcall(gate, "ExportFile", path .. SEP .. text)
	end
	return false
end

local function loadBigWigsCore()
	if BigWigs and type(BigWigs.NewBoss) == "function" then
		return true
	end
	if type(LoadAddOn) == "function" then
		local ok = LoadAddOn("BigWigs_Core")
		if ok and BigWigs and type(BigWigs.NewBoss) == "function" then
			return true
		end
	end
	return false
end

-- BigWigs_Plugins draws the bars/messages; it has to exist before the first
-- boss module calls Bar(). Options are left alone: the BigWigs loader opens
-- them itself on /bw, and forcing them at login only wastes memory.
local function loadBigWigsPlugins()
	if type(LoadAddOn) == "function" then
		LoadAddOn("BigWigs_Plugins")
	end
	-- BigWigs only initialises the plugins that were present when its own
	-- ADDON_LOADED fired. Loading the pack later leaves them with plugin.db
	-- unset, and the first Enable() then crashes in Proximity/RestyleWindow.
	if BigWigs and type(BigWigs.IteratePlugins) == "function" then
		for _, plugin in BigWigs:IteratePlugins() do
			if not plugin.db and type(plugin.Initialize) == "function" then
				pcall(plugin.Initialize, plugin)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- zone discovery
--
-- GetRealZoneText(id) answers for every area id the client knows, including the
-- custom ones. A single sweep at login builds the name -> id table; it costs a
-- few milliseconds and removes the need to hardcode ids that differ between
-- client builds.
--

local function sweepZones(maxId)
	RavenBW.zoneNames = RavenBW.zoneNames or {}
	for id = 1, maxId do
		local ok, name = pcall(GetRealZoneText, id)
		if ok and type(name) == "string" and name ~= "" then
			RavenBW.zoneNames[id] = name
			if not RavenBW.zoneCache[name] then
				RavenBW.zoneCache[name] = id
			end
		end
	end
end

function RavenBW:ZoneId(name)
	if not name or name == "" then return FALLBACK_ZONE end
	if self.zoneCache[name] then return self.zoneCache[name] end
	if not self.zoneNames then sweepZones(2000) end
	if self.zoneCache[name] then return self.zoneCache[name] end

	-- Loose match: the client may localize the name ("Karazhan Crypt" etc.).
	local needle = name:lower()
	for id, zoneName in pairs(self.zoneNames) do
		if zoneName:lower():find(needle, 1, true) then
			self.zoneCache[name] = id
			return id
		end
	end
	return FALLBACK_ZONE
end

local function ensureZone(zoneId)
	if type(zoneId) ~= "number" or zoneId == 0 then return end
	if not BigWigsLoader or not BigWigsLoader.zoneTbl then return end
	if not BigWigsLoader.zoneTbl[zoneId] then
		BigWigsLoader.zoneTbl[zoneId] = "BigWigs_Raven"
	end
end

--------------------------------------------------------------------------------
-- registration
--

-- Called by the boss files. zoneName is the name as it appears in the client.
-- aliases are extra unit names that should enable the same module (event
-- bosses are often known by an add name, e.g. Ezzel's charger Ton'Raka).
function RavenBW:AddBoss(moduleName, zoneName, factory, aliases)
	self.pending[#self.pending + 1] = { name = moduleName, zone = zoneName, factory = factory, aliases = aliases }
end

function RavenBW:Build()
	if self.built then return end
	if not loadBigWigsCore() then
		self:Print("BigWigs core is not loaded, modules will register on the next login.")
		return
	end
	loadBigWigsPlugins()

	if not self.zoneNames then sweepZones(2000) end

	for i = 1, #self.pending do
		local def = self.pending[i]
		-- A stock BigWigs raid pack may already provide this boss. Keep it,
		-- otherwise NewBoss() refuses the duplicate and both copies break.
		if BigWigs.GetBossModule and BigWigs:GetBossModule(def.name, true) then
			-- already provided by an installed pack
		else
		local zoneId = self:ZoneId(def.zone)
		ensureZone(zoneId)
		local ok, mod = pcall(def.factory, zoneId)
		if ok and mod then
			-- BigWigs initialises the modules it loaded itself on its ADDON_LOADED.
			-- Ours are created afterwards, so they have to be registered by hand,
			-- otherwise mod.db is nil and every Bar()/Message() call fails.
			if not mod.db then
				local okInit, err = pcall(mod.Initialize, mod)
				if not okInit then
					self:Print(("module %s init failed: %s"):format(def.name, tostring(err)))
				end
			end
			mod.enableName = def.name
			mod.zoneName = def.zone
			mod.names = { def.name }
			if def.aliases then
				for a = 1, #def.aliases do
					mod.names[#mod.names + 1] = def.aliases[a]
				end
			end
			for n = 1, #mod.names do
				self.bosses[mod.names[n]] = mod
			end
		elseif not ok then
			self:Print(("module %s failed: %s"):format(def.name, tostring(mod)))
		end
		end
	end
	self.built = true
end

--------------------------------------------------------------------------------
-- engage engine
--
-- BigWigs can only enable a module through RegisterEnableMob (mob ids) or a
-- known encounter id. Custom bosses have neither, so a name match against the
-- current target (and mouseover) is used instead. Once a module is enabled its
-- own combat log handlers do the rest.
--

local engine = CreateFrame("Frame")

local function bossForUnit(unit)
	if not UnitExists(unit) then return nil end
	if UnitIsPlayer(unit) then return nil end
	local name = UnitName(unit)
	if not name then return nil end
	return RavenBW.bosses[name]
end

function RavenBW:CheckUnit(unit)
	local mod = bossForUnit(unit)
	if not mod then return end
	-- BigWigs only enables its plugins (bars, messages, sounds) together with
	-- the core. Custom zones are outside its own zone table, so the core has to
	-- be switched on here or Bar()/Message() would go nowhere.
	if BigWigs and type(BigWigs.Enable) == "function" and not BigWigs:IsEnabled() then
		BigWigs:Enable()
	end
	if not mod:IsEnabled() then
		mod:Enable()
	end
	if UnitAffectingCombat(unit) and not mod:IsEngaged() then
		mod:Engage()
	end
end

local wipeTimer
local function isBossName(mod, name)
	if not name or not mod.names then return false end
	for i = 1, #mod.names do
		if mod.names[i] == name then return true end
	end
	return false
end

function RavenBW:CheckCombatEnd()
	if wipeTimer then return end
	wipeTimer = true
	C_Timer.After(1.5, function()
		wipeTimer = nil
		for _, mod in pairs(RavenBW.bosses) do
			if mod:IsEngaged() then
				local alive = false
				if UnitExists("target") and isBossName(mod, UnitName("target")) and not UnitIsDead("target") then
					alive = true
				end
				if not alive then
					mod:Wipe()
				end
			end
		end
	end)
end

engine:RegisterEvent("PLAYER_TARGET_CHANGED")
engine:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
engine:RegisterEvent("PLAYER_REGEN_DISABLED")
engine:RegisterEvent("PLAYER_REGEN_ENABLED")
engine:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_REGEN_ENABLED" then
		RavenBW:CheckCombatEnd()
	else
		RavenBW:CheckUnit("target")
		if event == "PLAYER_REGEN_DISABLED" or event == "UPDATE_MOUSEOVER_UNIT" then
			RavenBW:CheckUnit("mouseover")
		end
	end
end)

-- Custom bosses have no mob ids, so BigWigs' Death() helper cannot be used.
-- A single combat log listener forwards UNIT_DIED by unit name instead: a
-- module that needs it implements OnUnitDied(name).
local death = CreateFrame("Frame")
death:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
death:SetScript("OnEvent", function()
	local _, event, _, _, _, _, _, _, destName = CombatLogGetCurrentEventInfo()
	if event ~= "UNIT_DIED" or not destName then return end
	local mod = RavenBW.bosses[destName]
	if mod and mod:IsEnabled() and mod.OnUnitDied then
		mod:OnUnitDied(destName)
	end
end)

--------------------------------------------------------------------------------
-- combat log probe
--
-- The 1.12 boss modules trigger on chat lines ("X begins to cast Y.") that do
-- not exist on 1.14. The probe records the real event names and spell names for
-- a fight, which is what a ported module needs to build its Log() calls.
--

local probe = { active = false, lines = {}, count = 0 }

function RavenBW:ProbeStart()
	probe.active = true
	probe.lines = {}
	probe.count = 0
	self:Print("probe: recording combat log for 180 seconds")
	C_Timer.After(180, function()
		if probe.active then RavenBW:ProbeStop() end
	end)
end

function RavenBW:ProbeStop()
	if not probe.active then return end
	probe.active = false
	local text = table.concat(probe.lines, "\n")
	local path = "Logs\\RavenBW_probe.txt"
	if exportFile(path, text) then
		self:Print(("probe: %d lines written to %s"):format(probe.count, path))
	else
		self:Print(("probe: %d lines (file export disabled in this build)"):format(probe.count))
	end
end

local probeFrame = CreateFrame("Frame")
probeFrame:SetScript("OnEvent", function()
	if not probe.active then return end
	local ts, event, _, _, sourceName, _, _, destName, _, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
	if not event then return end
	if event ~= "SPELL_CAST_START" and event ~= "SPELL_CAST_SUCCESS" and event ~= "SPELL_AURA_APPLIED"
		and event ~= "SPELL_AURA_REMOVED" and event ~= "SPELL_MISSED" and event ~= "SPELL_DAMAGE"
		and event ~= "SPELL_PERIODIC_DAMAGE" and event ~= "UNIT_DIED" then
		return
	end
	probe.count = probe.count + 1
	probe.lines[#probe.lines + 1] = ("%.1f\t%s\t%s\t%s\t%s\t%s"):format(
		ts or 0, event, tostring(sourceName), tostring(destName), tostring(spellName), tostring(spellId))
end)

--------------------------------------------------------------------------------
-- slash command
--

local function reportZones(filter)
	if not RavenBW.zoneNames then sweepZones(2000) end
	local found = 0
	local lines = {}
	for id, name in pairs(RavenBW.zoneNames) do
		if not filter or name:lower():find(filter:lower(), 1, true) then
			found = found + 1
			lines[#lines + 1] = ("%d\t%s"):format(id, name)
		end
	end
	table.sort(lines)
	exportFile("Logs\\RavenBW_zones.txt", table.concat(lines, "\n"))
	RavenBW:Print(("%d zone(s), first: %s"):format(found, lines[1] or "none"))
end

SLASH_RAVENBW1 = "/bwr"
SlashCmdList["RAVENBW"] = function(msg)
	msg = (msg or ""):lower()
	if msg == "build" then
		RavenBW:Build()
		RavenBW:Print("build requested")
	elseif msg == "status" then
		local n = 0
		for _ in pairs(RavenBW.bosses) do n = n + 1 end
		RavenBW:Print(("v%s, %d/%d modules, core=%s, zones=%s"):format(
			RavenBW.version, n, #RavenBW.pending,
			tostring(BigWigs ~= nil and BigWigs.NewBoss ~= nil),
			tostring(RavenBW.zoneNames ~= nil)))
	elseif msg == "zones" then
		reportZones(nil)
	elseif msg:find("^find ") then
		reportZones(msg:sub(6))
	elseif msg == "probe" then
		RavenBW:ProbeStart()
	elseif msg == "probe stop" then
		RavenBW:ProbeStop()
	elseif msg == "combatlog on" then
		probeFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		RavenBW:Print("combat log listener on")
	elseif msg == "combatlog off" then
		probeFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		RavenBW:Print("combat log listener off")
	elseif msg == "diag" then
		local m = RavenBW.bosses["Erennius"]
		local ok, err = pcall(function() m:Enable() end)
		local ok2, err2 = pcall(function() m:Bar("diag", 3, "diag bar", "inv_misc_questionmark") end)
		RavenBW:Print(("db=%s enable=%s(%s) bar=%s(%s)"):format(
			tostring(BigWigs.db ~= nil), tostring(ok), tostring(err), tostring(ok2), tostring(err2)))
		for name, p in BigWigs:IteratePlugins() do
			if not p.db then
				RavenBW:Print("plugin without db: " .. tostring(name))
				break
			end
		end
	else
		RavenBW:Print("/bwr status | zones | find <text> | build | probe | probe stop | combatlog on|off")
	end
end

--------------------------------------------------------------------------------
-- boot
--

-- Try to bring BigWigs up during the addon loading phase, not at PLAYER_LOGIN:
-- a LOD pack loaded later never runs its own ADDON_LOADED handler in this
-- client, so BigWigs.db stays nil and every plugin registration fails.
-- The retry inside Build() covers the case where loading is refused here.
pcall(function()
	loadBigWigsCore()
	loadBigWigsPlugins()
end)

-- Loading BigWigs_Core during the ADDON_LOADED chain happens before its own
-- ADDON_LOADED handler runs, so BigWigs.db is still nil and every plugin
-- registration fails. Waiting for PLAYER_LOGIN lets the LOD load complete the
-- normal way: Core fires its ADDON_LOADED, creates the DB, plugins register.
local boot = CreateFrame("Frame")
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function()
	RavenBW:Build()
end)
