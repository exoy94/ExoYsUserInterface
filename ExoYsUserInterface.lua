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

local function CallForEachModules( funcName, param)
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

	local defaults = CallForEachModules('GetDefaults')

	ExoY.store = ZO_SavedVars:NewAccountWide("ExoYSaveVariables", 0, nil, defaults, "Settings")

	CallForEachModules('Initialize')

	Lib.RegisterCombatStart(function() CallForEachModules('OnCombatStart') end)
	Lib.RegisterCombatEnd(function() CallForEachModules('OnCombatEnd') end)
	
	Lib.RegisterForInitialPlayerActivated(function() CallForEachModules('OnInitialPlayerActivated') end) 
	Lib.RegisterForPlayerActivated(function() CallForEachModules('OnPlayerActivated') end)
end


local function OnAddOnLoaded(event, addonName)
  if addonName == ExoY.name then
		Initialize()
		EM:UnregisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED)
  end
end
EM:RegisterForEvent(ExoY.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)



--IDEA for purge Tracking (gameuiart/siege)
