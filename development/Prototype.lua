ExoY = ExoY or {}
ExoY.prototype = ExoY.prototype or {}

local Prototype = ExoY.prototype
local Lib = LibExoYsUtilities

function Prototype.Initialize()
  Prototype.name = ExoY.name.."Prototype"
  Prototype.LibTest()
  Prototype.AutoJoinCampaign()
  Prototype.LibSetDetectionTest()
  Prototype.InitTribute()
  Prototype.CallbackManagerTest() 
  Prototype.TestFunc() 
--  Prototype.FindAbilityId()
--  Prototype.FindStacks()
--  Prototype.DomeLocations()
  --Prototype.BlockInteract()
  --/script LibAddonMenu2.OpenToPanel()
  --Prototype.HandleTributeSearch()
    --SLASH_COMMANDS["/exoytest"] = function()
    --local lam = LibAddonMenu2
    --lam.OpenToPanel("EPT_TEST")
  --end
  --Prototype.TributeResults()
  --[[ExoY.testVar = {}

  local function TestFunc(self, control, data)
    local leaderboardData = self.GetSelectedLeaderboardData and self:GetSelectedLeaderboardData() or GAMEPAD_LEADERBOARDS:GetSelectedLeaderboardData()
		if leaderboardData.leaderboardRankType ~= LEADERBOARD_TYPE_TRIBUTE then return end
    local dataList = {control, data}
    table.insert(ExoY.testVar, dataList)
  end
  -- only gets data for any LeaderBoard Entry displayed (scroll through list)
  ZO_PostHook(LEADERBOARDS, "SetupLeaderboardPlayerEntry", TestFunc)]]

  --[[ZO_PostHook(ZO_ActivityFinderTemplate_Shared, "OnTributeClubDataInitialized", function(self)
    ExoY.testVar = self
    local parent = self.clubRankObject.iconTexture

    local back = ExoY.WM:CreateControl( "testControl", parent, CT_BACKDROP )
    back:ClearAnchors()
    back:SetAnchor( CENTER, parent, CENTER, 0, 0)
    back:SetDimensions( 50 , 50 )
    back:SetEdgeColor(1,1,1,1)
    back:SetEdgeTexture(nil, 2, 2, 2)
    back:SetCenterColor(0,0,0, 0.5)
    back:SetDrawTier(2)
    --ExoY.testVar = back
  end)]]

end

function Prototype.TestFunc() 
  local function OnCombatStart() 
    d("CombatStart")
  end

  local function OnCombatEnd() 
    d("CombatEnd")
  end

  Lib.RegisterCombatStartCallback(OnCombatStart)
  Lib.RegisterCombatEndCallback(OnCombatEnd)

  SLASH_COMMANDS["/exoytest"] = function()
    Lib.UnregisterCombatStartCallback(OnCombatStart)
  end
end




function Prototype.CallbackManagerTest() 
  Lib.RegisterInitialActivationCallback(true)
  Lib.RegisterInitialActivationCallback(function() ExoY.testVar = true end)
end

function Prototype.FindStacks()
  local function OnEvent(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    d(GetAbilityName(abilityId) )
    d(abilityId)
    d(stackCount)
    d("-----")
  end

  ExoY.EM:RegisterForEvent("ExoYStackTest", EVENT_EFFECT_CHANGED, OnEvent)

end



function Prototype.FindAbilityId()
  local function OnEvent(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local name = string.lower( GetAbilityName(abilityId) )
    if string.find(name, "nirn") then
      if (result == ACTION_RESULT_EFFECT_GAINED) or (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
      d( abilityId )
      d( GetAbilityDuration(abilityId) )
      d("---")
      end
    end
  end
  ExoY.EM:RegisterForEvent("ExoYTest", EVENT_COMBAT_EVENT, OnEvent)
end



function Prototype.DomeLocations()
  if OSI then
    local id = {
      ["fire"] = 31759,   -- enter id for fire dome
      ["ice"] = 1,        -- enter id for ice dome
    }

    local function ColorIcon(vars, dome)
      local affected = false
      for i=1,GetNumBuffs("player") do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo( "player", i)
        if abilityId == id[dome] then
          affected = true
        end
      end
      if affected then
        if dome == "fire" then
          vars.color = {1,0,0,1}
        else
          vars.color = {0,0,1,1}
        end
      else
        vars.color = {0,0,0,0}
      end
    end

    local ice = OSI.CreatePositionIcon( 27584, 15516, 172053, "OdySupportIcons/icons/donut.dds", 90, {1,1,1}, -0.5, function(vars) ColorIcon(vars, "ice")  end)
    local fire = OSI.CreatePositionIcon( 27584, 15516, 172053, "OdySupportIcons/icons/donut.dds", 90, {1,1,1}, -0.5, function(vars) ColorIcon(vars, "fire") end)
  end

end

--/script d( GetTributeMatchStatistics() )
function Prototype.TributeResults()
  --local function OnResultEvent(...)
  --  d("Tribute Match End ready")
  --  ExoY.testVar = {...}
  --end
  --ExoY.EM:RegisterForEvent( Prototype.name.."TributeResult", EVENT_TRIBUTE_MATCH_END_SUMMARY_READY, OnResultEvent)
  SLASH_COMMANDS["/exoytest_old"] = function()
    --if GetTributeMatchType() == TRIBUTE_MATCH_TYPE_CLIENT then return end
    local opponentName, opponentType = GetTributePlayerInfo(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)
    --if not opponentType == TRIBUTE_PLAYER_TYPE_REMOTE_PLAYER then return end
    d("opponentName: "..tostring(opponentName))
    d("opponentType: "..tostring(opponentType))
    d("matchType: "..tostring(GetTributeMatchType()))
  end

  local function OnFlowChange(_, flowState)
    d("flow state: "..tostring(flowState) )
    if flowState == TRIBUTE_GAME_FLOW_STATE_INTRO then
      local opponentName, opponentType = GetTributePlayerInfo(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)
      --if not opponentType == TRIBUTE_PLAYER_TYPE_REMOTE_PLAYER then return end
      d("opponentName: "..tostring(opponentName))
      d("opponentType: "..tostring(opponentType))
      d("matchType: "..tostring(GetTributeMatchType()))
    end

    if flowState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER then
      local victoryPerspective, victoryType = GetTributeResultsWinnerInfo()

      if victoryPerspective == TRIBUTE_PLAYER_PERSPECTIVE_SELF then
          d("Player Victory")
          d(victoryType)
      else
          d("Player Defeat")
          d(victoryType)
      end
    end
  end
  ExoY.EM:RegisterForEvent(Prototype.name.."TributeResult", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE ,OnFlowChange)
end

function Prototype.HandleTributeSearch()
  local function OnUpdate(_, finderStatus)
    --d("finderStatus: "..tostring(finderStatus))
    if finderStatus == ACTIVITY_FINDER_STATUS_READY_CHECK then
      --local activityType = GetLFGReadyCheckNotificationInfo()
      -- ACTIVITY_FINDER_STATUS_NONE = abort

      local activityType = GetLFGReadyCheckActivityType()
      d("Ready Check Detected for: "..tostring(activityType) )

      if activityType == LFG_ACTIVITY_TRIBUTE_CASUAL then
        d("ToT Casual Game Ready Check")
        zo_callLater(function() AcceptTribute() end, 4000 )
      elseif activityType == LFG_ACTIVITY_TRIBUTE_COMPETITIVE then
        zo_callLater(function() AcceptTribute() end, 4000 )
        d("ToT Ranked Game Ready Check")
      end
      -- determin if LFG activity is tribute game
    end
  end



  ExoY.EM:RegisterForEvent( Prototype.name.."TributeSearch", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnUpdate)
  ExoY.EM:RegisterForEvent( Prototype.name.."TributeSearch2", EVENT_ACTIVITY_QUEUE_RESULT, function(_, var) d("activity result: "..tostring(var)) end )
  -- Hook into encounterlog toogle and update indicator accordingly
  ZO_PostHook("AcceptLFGReadyCheckNotification", function()
    d("LFG accepted")
  end)

  ZO_PostHook("AcceptTribute", function()
    d("Tribute accepted")
  end)

  -- Hook into encounterlog toogle and update indicator accordingly
  ZO_PostHook("DeclineLFGReadyCheckNotification", function()
    d("LFG declined")
  end)
end

function  Prototype.InitTribute()
  --ExoY.EM:RegisterForEvent("TributePatron", EVENT_TRIBUTE_PATRON_PROGRESSION_DATA_CHANGED, function(event, id) d("patron: "..tostring(id)) end )
  --ExoY.EM:RegisterForEvent("TributeFlowState", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, function(event, flowState) d("flowState: "..tostring(flowState) ) end)
  --ExoY.EM:RegisterForEvent("TributeTurn", EVENT_TRIBUTE_PLAYER_TURN_STARTED, function(event, localPlayer) d("turn: "..tostring(localPlayer) ) end)
end


function Prototype.AutoJoinCampaign()
  local function OnCampaignChange(eventId, campaignId, isGroup, state)
    if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
      zo_callLater(function() ConfirmCampaignEntry(campaignId, isGroup, true) end, 4000)
    end
  end
  ExoY.EM:RegisterForEvent(Prototype.name.."AutoJoin", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignChange)
end


function Prototype.LibTest()
  local Lib = LibExoYsUtilities
  local function EventTest(...)
    d( Lib.GetEventParameter("changeType", ...) )
  end
  local eventData = {
    name = "ExoYProtoEvent",
    code = EVENT_EFFECT_CHANGED,
    staticFilter = {
      [REGISTER_FILTER_ABILITY_ID] = 147872,
    },
    dynamicFilter = {
      --["hitValue"] = {1,0},
    }
  }

  --Lib.RegisterCustomEvent( eventData, EventTest)

end


function Prototype.LibSetDetectionTest()
  local function callback(slotTable)
    d("ExoY - LibSetDetection")
    d(slotTable)
    d("---")
  end

  --LibSetDetection.RegisterForCustomSlotUpdateEvent("ExoY", callback)

  local function callback2(setId, status)
    d("ExoY2 - LSD")
    d(setId )
    d(status)
    d("-----")

  end
  --LibSetDetection.RegisterForSetChanges("ExoY2", callback2)


end

function Prototype.CustomMapPin()
  PinManager=ZO_WorldMap_GetPinManager()
end

function Prototype.BlockInteract()
  local function DisableReticleTake_Hook(interactionPossible)
    d(interactionPossible)
    interactionPossible.interactionBlocked = true
    if interactionPossible then
      local action,text,empty,_,addinfo,_,_,crime = GetGameCameraInteractableActionInfo()
      if action == "Activate" then
        return true
      end
      --if text ~= '' and text ~= nil then
      --  if text == "Destructive Ember" then
      --    return true
      --  end
      --end
    end
    return false
  end
  --ZO_PreHook(ZO_Reticle, "UpdateInteractText", function() return true end )
  --ZO_PreHook(RETICLE, "TryHandlingInteraction", DisableReticleTake_Hook)
end
