ExoY = ExoY or {}

local Prototype = {Name = "ExoY_Prototype"}
local Lib = LibExoYsUtilities


function Prototype.AutoJoinCampaign()
  local function OnCampaignChange(eventId, campaignId, isGroup, state)
    if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
      zo_callLater(function() ConfirmCampaignEntry(campaignId, isGroup, true) end, 4000)
    end
  end
  --ExoY.EM:RegisterForEvent(Prototype.name.."AutoJoin", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignChange)
end



local function Initialize() 

end 

ExoY.Initialize_Prototype = Initialize