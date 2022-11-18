ExoY = ExoY or {}

ExoY.worldMap = ExoY.worldMap or {}
local WorldMap = ExoY.worldMap

function WorldMap.Initialize()
  WorldMap.name = ExoY.name.."WorldMap"

  WorldMap.HidePoI()
  --WorldMap.RegionNames()
end

function WorldMap.HidePoI()

  local oldFunc = GetFastTravelNodeInfo

  GetFastTravelNodeInfo = function(nodeIndex)
  local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = oldFunc(nodeIndex)
  if GetMapType() == MAPTYPE_WORLD then
    if poiType ~= POI_TYPE_ACHIEVEMENT then -- POI_TYPE_GROUP_DUNGEON
      known = false
    end
  end
  return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked
  end

end


local regionList = {
  --Alik'r Desert
  --Auridon
  --Bal Foyen
  --Bangkorai
  --Betnikh
  --Bleakrock Isle
  --Blackwood
  --Craglorn
  --Cyrodiil
  --Deshaan
  --Eastmarch
  --Glenumbra
  --Gold Coast
  --Grahtwood
  --Greenshade
  --Hew's Bane
  --Khenarithi's Roost
  --Malabal Tor
  --Murkmire
  --Northern Elsweyer
  --Reaper's March
  --Rivenspire
  --Shadowfen
  --Southern Elsweyer
  --Stonefalls
  --Stormhaven
  --Stros M'Kai
  --Summerset
  --The Reach
  --The Rift
  --Western Skyrim
  --Wrothgar
  --{"Vvardenfell", 100, 100}
}


function WorldMap.RegionNames()

  --TODO fix movement while scrolling

  local name = WorldMap.name.."Region"
  local font = zo_strformat("<<1>>|<<2>>|<<3>>", "EsoUI/Common/Fonts/ProseAntiquePSMT.otf", 15, "soft-shadow-thick")
  local parent = ZO_WorldMapContainer

  local labelList = {}

  for _, region in ipairs(regionList) do
    local label = ExoY.WM:CreateControl(name..region[1], parent, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor(CENTER, parent, TOPLEFT, region[2], region[3] )
    label:SetFont( font ) --TODO change
    label:SetText( region[1] )
    table.insert(labelList, label)
  end

  local function CheckMap(event, triggerId)
    if triggerId ~= 54 then return end

    for _, label in ipairs(labelList) do
      label:SetHidden( GetMapType() ~= MAPTYPE_WORLD )
    end

  end
  ExoY.EM:RegisterForEvent(name, EVENT_TUTORIAL_TRIGGER_COMPLETED, CheckMap)
end

--[[

local parent = ZO_WorldMapContainer

local function OnWorldMap()
  if GetMapType() == MAPTYPE_WORLD then
    return false
  else
    return true
  end
end

local label = ExoY.WM:CreateControl("ExoYLabel", parent, CT_LABEL)
label:ClearAnchors()
label:SetAnchor(CENTER, parent, CENTER, 0, 0)
label:SetText("Vvardenfall")
label:SetHidden( OnWorldMap() )
--EVENT_TUTORIAL_TRIGGER_COMPLETED
--TUTORIAL_TRIGGER_MAP_OPENED_PVE

--to check for map opening and adapt hidden status

label:SetFont( ExoY.GetFont("big") )
label:SetColor(1,1,1,1)

]]
