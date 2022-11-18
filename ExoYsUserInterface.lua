ExoY = ExoY or {}

local Lib = LibExoYsUtilities
-- currentPowerLevel = GetPlayerStat(STAT_SPELL_POWER)
-- GetAttributeSpentPoints(number attributeType)
-- /script ZO_CompassFrame:SetHidden(true)
-- /script ZO_CompassFrame:SetAlpha(0)

-- Checkups ( Todo, Question, Idea, Warning )

-- Addon Variables
ExoY.name = "ExoYsUserInterface"
ExoY.displayName = "|c00FF00ExoY|rs User Interface"
ExoY.author = "@|c00FF00ExoY|r94 (PC/EU)"
ExoY.version = "Infinity"
ExoY.EM = GetEventManager()
ExoY.WM = GetWindowManager()
ExoY.window = GetWindowManager()


-- order is also order in which modules will be initialized
local moduleList = {
	"display",

	"dev",

	"characterInfo",
	"chat",
	"group",
	"misc",
	"screen",
	"smartCast",
	"statusPanel",
	"unitFrames",
	"widgets",
	"worldMap",
}


--------------------
-- Initialization --
--------------------

function ExoY.OnAddOnLoaded(event, addonName)
  if addonName == ExoY.name then
		ExoY.Initialize()
		ExoY.EM:UnregisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED)
  end
end
ExoY.EM:RegisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED, ExoY.OnAddOnLoaded)


function ExoY.Initialize()
	-- Load SaveVariables
  --SafeAddString(SI_ACHIEVEMENT_EARNED_FORMATTER, "|c00FF00You are awesome!|r", 2)
  --ZO_PreHook(Achievement, "RefreshTooltip", function()
  --  return true --suppress call to original function
  --end)

	local defaults = ExoY.GetDefaults()
	ExoY.store = ZO_SavedVars:NewAccountWide("ExoYSaveVariables", 0, nil, defaults, "Settings")

	ExoY.moduleList = moduleList
 	--ExoY.festival = ExoY.vars.festivals["anniversary"]

	-- Tables
	ExoY.callbackList = {}
	ExoY.combat = {}


	-- Initializing modules
	for _, module in ipairs(moduleList) do
		local init = ExoY[module].Initialize or nil
		if type(init) == "function" then init() end
	end

	-- Events
  ExoY.RegisterCombatStateEvents()

	ExoY.EM:RegisterForEvent(ExoY.name.."InitialPlayerActivated", EVENT_PLAYER_ACTIVATED, ExoY.OnInitialPlayerActivated)
	ExoY.EM:RegisterForEvent(ExoY.name.."PlayerActivated", EVENT_PLAYER_ACTIVATED, ExoY.OnPlayerActivated)
	--ExoY.EM:RegisterForEvent(ExoY.name.."OnPlayerCombatState", EVENT_PLAYER_COMBAT_STATE, ExoY.OnPlayerCombatState)
end


function ExoY.GetDefaults()
	local defaults = {}
	for _, module in ipairs(moduleList) do
		local getDefaults = ExoY[module].GetDefaults or nil
		if type(getDefaults) == "function" then
			defaults[module] = getDefaults()
		end
	end
	return defaults
end

------------
-- Events --
------------

function ExoY.OnInitialPlayerActivated()
	for _, module in ipairs(moduleList) do
		local func = ExoY[module].OnInitialPlayerActivated or nil
		if type(func) == "function" then func() end
	end
	ExoY.EM:UnregisterForEvent(ExoY.name.."InitialPlayerActivated", EVENT_PLAYER_ACTIVATED)
end


function ExoY.OnPlayerActivated()
	for _, module in ipairs(moduleList) do
		local func = ExoY[module].OnPlayerActivated or nil
		if type(func) == "function" then func() end
	end
end


function ExoY.RegisterCombatStateEvents()

	local function OnCombatStart()
		ExoY.combat.state = true
		ExoY.combat.startTime = GetGameTimeMilliseconds()
		for _, module in ipairs(moduleList) do
			local func = ExoY[module].OnCombatStart or nil
			if type(func) == "function" then func() end
		end
	end

	local function OnCombatEnd()
		ExoY.combat.state = false
		ExoY.combat.endTime = GetGameTimeMilliseconds()
		for _, module in ipairs(moduleList) do
			local func = ExoY[module].OnCombatEnd or nil
			if type(func) == "function" then func() end
		end
	end

  Lib.RegisterCombatStartCallback("ExoYUI", OnCombatStart)
  Lib.RegisterCombatEndCallback("ExoYUI", OnCombatEnd)

end


---------------
-- Utilities --
---------------

function ExoY.GetFont( layout )
  local sizes = {
		["small"] = 16,
		["normal"] = 18,
		["big"] = 20,
		["header"] = 24,
	}
	local font = "/EsoUI/Common/Fonts/Univers67.otf"
  local outline = "soft-shadow-thick"
	local size
	if type(layout) == "number" then
		size = layout
	else
		size = sizes[layout]
	end
  return string.format( "%s|%d|%s", font , size , outline )
end


function ExoY.IsPlayerNameAccountName( playerName )
	if string.find(playerName, "@") then
		return true
	else
		return false
	end
end


function ExoY.AnalyseDuration( duration, InMilliseconds)
	local factor = InMilliseconds and 1000 or 1
	local timeUnits = {
		["days"] = 86400,
		["hours"] = 3600,
		["minutes"] = 60,
	}
	local result = {}
	for unit, ratio in pairs(timeUnits) do
		local inter = math.floor(duration/(ratio*factor) )
		result[unit] = inter > ratio and inter%ratio or inter
	end
	result.seconds = math.floor((duration/factor)%60)
	result.milliSeconds = InMilliseconds and duration%1000 or 0
	return result.days, result.hours, result.minutes, result.seconds, result.milliSeconds
end


--IDEA for purge Tracking (gameuiart/siege)
-- IDEA Collection Set Book Total
