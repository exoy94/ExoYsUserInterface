ExoY = ExoY or {}

ExoY.worldMap = ExoY.worldMap or {}
local WorldMap = ExoY.worldMap


function WorldMap.Initialize()
  WorldMap.name = ExoY.name.."WorldMap"
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

