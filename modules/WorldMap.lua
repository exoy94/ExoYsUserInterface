ExoyUI = ExoyUI or {}

ExoyUI.worldMap = ExoyUI.worldMap or {}
local WorldMap = ExoyUI.worldMap


function WorldMap.Initialize()
  WorldMap.name = ExoyUI.name.."WorldMap"
  WorldMap.HidePoI()
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

