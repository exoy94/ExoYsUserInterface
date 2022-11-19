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


--[[ ---------------- ]]
--[[ -- Modularity -- ]]
--[[ ---------------- ]]

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


local function ExecuteForAllModuls( funcName )
	for _,moduleName in ipairs(moduleList) do
		Lib.ExeFunc( ExoY[moduleName][funcName] or nil )
	end
end


--[[ -------------------- ]]
--[[ -- Initialization -- ]]
--[[ -------------------- ]]

local function GetDefaults()
	local defaults = {}
	for _, moduleName in ipairs(moduleList) do
		local getDefaults = ExoY[moduleName].GetDefaults or nil
		if Lib.IsFunc(getDefaults) then
			defaults[moduleName] = getDefaults()
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

	ExecuteForAllModuls('Initialize')

	Lib.RegisterCombatStart(function() ExecuteForAllModuls('OnCombatStart') end)
	Lib.RegisterCombatEnd(function() ExecuteForAllModules('OnCombatEnd') end)
	
	--TODO remove (only used in CombatProtocolFiles)
	ExoY.combat.state = true
	ExoY.combat.startTime = GetGameTimeMilliseconds()
	ExoY.combat.EndTime = GetGameTimeMilliseconds()

	--TODO chang to Activation for consistency
	Lib.RegisterInitialPlayerActivation(function() ExecuteForAllModuls('OnInitialPlayerActivated') end) 
	Lib.RegisterPlayerActivation(function() ExecuteForAllModuls('OnPlayerActivated') end)
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
