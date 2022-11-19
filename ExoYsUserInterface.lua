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

local EM = GetEventManager() 
local WM = GetWindowManager() 


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




--[[ ------------ ]]
--[[ -- Events -- ]]
--[[ ------------ ]]

local function OnInitialPlayerActivated()
	for _, module in ipairs(moduleList) do
		Lib.ExeFunc( ExoY[module].OnInitialPlayerActivated or nil )
	end
end


local function OnPlayerActivated()
	for _, module in ipairs(moduleList) do
		Lib.ExeFunc( ExoY[module].OnPlayerActivated or nil )
	end
end


local function RegisterCombatStateEvents()

	local function OnCombatStart()
		ExoY.combat.state = true
		ExoY.combat.startTime = GetGameTimeMilliseconds()
		for _, module in ipairs(moduleList) do
			Lib.ExeFunc( ExoY[module].OnCombatStart or nil )
		end
	end

	local function OnCombatEnd()
		ExoY.combat.state = false
		ExoY.combat.endTime = GetGameTimeMilliseconds()
		for _, module in ipairs(moduleList) do
			Lib.ExeFunc( ExoY[module].OnCombatEnd or nil )
		end
	end

  Lib.RegisterCombatStart(OnCombatStart)
  Lib.RegisterCombatEnd(OnCombatEnd)

end



--[[ -------------------- ]]
--[[ -- Initialization -- ]]
--[[ -------------------- ]]

local function GetDefaults()
	local defaults = {}
	for _, module in ipairs(moduleList) do
		local getDefaults = ExoY[module].GetDefaults or nil
		if Lib.IsFunc(getDefaults) then
			defaults[module] = getDefaults()
		end
	end
	return defaults
end


local function Initialize()
	-- Load SaveVariables
  --SafeAddString(SI_ACHIEVEMENT_EARNED_FORMATTER, "|c00FF00You are awesome!|r", 2)
  --ZO_PreHook(Achievement, "RefreshTooltip", function()
  --  return true --suppress call to original function
  --end)

	local defaults = GetDefaults()
	ExoY.store = ZO_SavedVars:NewAccountWide("ExoYSaveVariables", 0, nil, defaults, "Settings")

	ExoY.moduleList = moduleList
 	--ExoY.festival = ExoY.vars.festivals["anniversary"]

	-- Tables
	ExoY.callbackList = {}
	ExoY.combat = {}

	-- Initializing modules
	for _, module in ipairs(moduleList) do
		local init = ExoY[module].Initialize or nil
		Lib.ExeFunc(init)
	end

	-- Events
	RegisterCombatStateEvents()

	Lib.RegisterInitialPlayerActivation(OnInitialPlayerActivated) 
	Lib.RegisterPlayerActivation(OnPlayerActivated)
	--EM:RegisterForEvent(ExoY.name.."InitialPlayerActivated", EVENT_PLAYER_ACTIVATED, ExoY.OnInitialPlayerActivated)
	--EM:RegisterForEvent(ExoY.name.."PlayerActivated", EVENT_PLAYER_ACTIVATED, ExoY.OnPlayerActivated)
	--ExoY.EM:RegisterForEvent(ExoY.name.."OnPlayerCombatState", EVENT_PLAYER_COMBAT_STATE, ExoY.OnPlayerCombatState)
end



local function OnAddOnLoaded(event, addonName)
  if addonName == ExoY.name then
		Initialize()
		EM:UnregisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED)
  end
end
EM:RegisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)






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
