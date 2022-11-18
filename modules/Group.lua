ExoY = ExoY or {}
ExoY.group = ExoY.group or {}

local Lib = LibExoYsUtilities
local Group = ExoY.group

function Group.Initialize()
  Group.name = ExoY.name.."Group"

  Group.unitList = {}

  ExoY.EM:RegisterForEvent(Group.name.."EffectChanged", EVENT_EFFECT_CHANGED, Group.OnEffectChanged)
  ExoY.EM:AddFilterForEvent(Group.name.."EffectChanged", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

function Group.OnEffectChanged(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  if changeType == EFFECT_RESULT_GAINED then
    if unitTag and unitId then
      Group.unitList[unitId] = unitTag
      Group.unitList[unitTag] = unitId
    end
  end
end

function Group.OnCombatStart()
  --Group.unitList = {}
  --d("ExoYUiCombatStart")
end

function Group.OnCombatEnd()
  --d("ExoYUiCombatEnd")
end

function Group.GetDisplayNameByUnitId( unitId )
  local displayName = GetUnitDisplayName( Group.unitList[unitId] )
  if not displayName or displayName == "" then
    displayName = "unknown"
  end
  return displayName
end

function Group.GetDisplayNameByGroupTag( unitTag )
  local displayName = GetUnitDisplayName( unitTag )
  if not displayName or displayName == "" then
    displayName = "unknown"
  end
  return displayName
end

function Group.GetGroupMemberAccountNameByUnitName( unitName )
  --early out when not in a group
  if not IsUnitGrouped("player") then return end

  for i = 1, GetGroupSize() do
    local unitTag = GetGroupUnitTagByIndex(i)
    if GetUnitName(unitTag) == zo_strformat( SI_UNIT_NAME, unitName ) then
      return GetUnitDisplayName(unitTag)
    end
  end
end

function Group.IsPlayerInSameGroup( playerName )
  --early out when not in a group
  if not IsUnitGrouped("player") then return end

  for i = 1, GetGroupSize() do
    local unitTag = GetGroupUnitTagByIndex(i)
    if Lib.IsAccount( playerName ) then
      if GetUnitDisplayName(unitTag) == playerName then return true end
    else
      if GetUnitName(unitTag) == playerName then return true end
    end
  end
  return false

end
