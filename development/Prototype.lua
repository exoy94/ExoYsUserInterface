ExoY = ExoY or {}
ExoY.prototype = ExoY.prototype or {}

local Prototype = ExoY.prototype
local Lib = LibExoYsUtilities

local EM = GetEventManager()
local WM = GetWindowManager()

function Prototype.Initialize()
  Prototype.name = ExoY.name.."Prototype"

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

  ExoY.blub = "hallo"

  Prototype.SkillTargetMarker() 
end


function Prototype.SkillTargetMarker() 
  local demoTarget = ""
  local function AssignMarker(_, result) 
    if not IsUnitAttackable("reticleover") then return end
    if demoTarget == GetUnitName("reticleover") then return end
    demoTarget = GetUnitName("reticleover") 
    AssignTargetMarkerToReticleTarget(1)
  end
  EVENT_MANAGER:RegisterForEvent("skilltarget", EVENT_COMBAT_EVENT, AssignMarker) 
  EVENT_MANAGER:AddFilterForEvent("skilltarget", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 21763)
  EVENT_MANAGER:AddFilterForEvent("skilltarget", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE , COMBAT_UNIT_TYPE_PLAYER)
  EVENT_MANAGER:AddFilterForEvent("skilltarget", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT,  ACTION_RESULT_EFFECT_GAINED) 
  -- find abilityId with "/script d(GetSlotBoundId(3))", when skill is on first abilitySlot
end

SLASH_COMMANDS["/exoytest"] = function()
  local function test(a,b,c,e) 
    d(a)
    d(b)
    d(c)
    d(e)

    
  end

  test( GetUnitRawWorldPosition("player") )
end

SLASH_COMMANDS["/exoytest3"] = function()
  local gemId = 0
  for slotId = 0, GetBagSize(BAG_BACKPACK) do
    local name = GetItemName(BAG_BACKPACK, slotId)
    -- if name ~= "" then 
    --  d( zo_strformat("[<<1>>] <<2>>", slotId, GetItemName(BAG_BACKPACK, slotId) ) )
    --end
    if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, slotId) then
     -- d( zo_strformat("Soulgem at: <<1>>", slotId ))
			gemId = slotId
			df("found gems %s", gemId) -- <<<<<< returning 0 to chat as well which makes no sense to me.. it should be the slot# i would think
			return gemId
	  end
  end
end
SLASH_COMMANDS["/exoytest2"] = function()
for slotId = 0, GetBagSize(BAG_BACKPACK) do
  if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, slotId) then
    gemId = slotId
    df("found gems %s", gemId) -- <<<<<< returning 0 to chat as well which makes no sense to me.. it should be the slot# i would think
    return gemId
  end
      end
    end
--SLASH_COMMANDS["/exoytest"] = function()
    --local lam = LibAddonMenu2
    --lam.OpenToPanel("EPT_TEST")
  --end

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

function Prototype.AutoJoinCampaign()
  local function OnCampaignChange(eventId, campaignId, isGroup, state)
    if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
      zo_callLater(function() ConfirmCampaignEntry(campaignId, isGroup, true) end, 4000)
    end
  end
  EM:RegisterForEvent(Prototype.name.."AutoJoin", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignChange)
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
