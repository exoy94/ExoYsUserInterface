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

local EM = GetEventManager() 
local WM = GetWindowManager() 

--TODO Cleanup
ExoY.EM = GetEventManager()
ExoY.WM = GetWindowManager()
ExoY.window = GetWindowManager()


--[[ ---------------- ]]
--[[ -- Modularity -- ]]
--[[ ---------------- ]]

local moduleList = {
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
--"dev",

local function ExecuteForAllModules( funcName )
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

	local defaults = GetDefaults()

	ExoY.store = ZO_SavedVars:NewAccountWide("ExoYSaveVariables", 0, nil, defaults, "Settings")

	--TODO graphical interface
 	ExoY.festival = ExoY.vars.festivals["anniversary"]

	-- TODO Investivate
	ExoY.callbackList = {}

	-- initialize display 
	Lib.ExeFunc( ExoY.display.Initialize )

	ExecuteForAllModules('Initialize')

	Lib.RegisterCombatStart(function() ExecuteForAllModules('OnCombatStart') end)
	Lib.RegisterCombatEnd(function() ExecuteForAllModules('OnCombatEnd') end)
	
	Lib.RegisterInitialPlayerActivation(function() ExecuteForAllModules('OnInitialPlayerActivated') end) 
	Lib.RegisterPlayerActivation(function() ExecuteForAllModules('OnPlayerActivated') end)
end


local function OnAddOnLoaded(event, addonName)
  if addonName == ExoY.name then
		Initialize()
		EM:UnregisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED)
  end
end
EM:RegisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)



--IDEA for purge Tracking (gameuiart/siege)
-- IDEA Collection Set Book Total
