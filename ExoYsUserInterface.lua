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


--[[ ---------------- ]]
--[[ -- Modularity -- ]]
--[[ ---------------- ]]

-- entry order defines module loop order
local moduleList = {
	"display", 
	---
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

local function ExecuteForAllModules( funcName, param)
	local r = {}
	for _,moduleName in ipairs(moduleList) do
		r[moduleName] = Lib.CallFunc( ExoY[moduleName][funcName], param )
	end
	return r
end

--[[ -------------------- ]]
--[[ -- Initialization -- ]]
--[[ -------------------- ]]

local function Initialize()

	local defaults = ExecuteForAllModules('GetDefaults')

	ExoY.store = ZO_SavedVars:NewAccountWide("ExoYSaveVariables", 0, nil, defaults, "Settings")

	ExecuteForAllModules('Initialize')

	Lib.RegisterCombatStart(function() ExecuteForAllModules('OnCombatStart') end)
	Lib.RegisterCombatEnd(function() ExecuteForAllModules('OnCombatEnd') end)
	
	Lib.RegisterForInitialPlayerActivated(function() ExecuteForAllModules('OnInitialPlayerActivated') end) 
	Lib.RegisterForPlayerActivated(function() ExecuteForAllModules('OnPlayerActivated') end)
end


local function OnAddOnLoaded(event, addonName)
  if addonName == ExoY.name then
		Initialize()
		EM:UnregisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED)
  end
end
EM:RegisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)



--IDEA for purge Tracking (gameuiart/siege)
