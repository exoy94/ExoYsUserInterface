-- manually deleting combat Protocol: /script ExoY.combatProtocol.store.database = {}
-- 110118

ExoY = ExoY or {}
ExoY.combatProtocol = ExoY.combatProtocol or {}

local CombatProtocol = ExoY.combatProtocol

local trackedNames = {
  --["noxious sludge"] = true,
  --["noxious release"] = true,
  --["magma sludge"] = true,
  --["soul extraction"] = true,
  --["extrication"] = true,
  --["creeping eye"] = true,
  --["creeping manifold"] = true,
  --["oculus breach"] = true,
}
local trackedIds = {
  --[10298] = true, --ray of hope
}

local function GetCustomAbilityId( text )
  local startId = string.find(text, "(", 1, true)
  local endId = string.find(text, ")", 1, true)
  local abilityId = tonumber( string.sub(text, startId+1, endId-1) )
  return abilityId
end

function CombatProtocol.Analysis()
  local abilityList = {}
  for k, v in pairs( ExoY.combatProtocol.store.database ) do
    local abilityId = GetCustomAbilityId(v)
    if type(abilityId) == "number" then
      if abilityList[abilityId] then
        abilityList[abilityId] = abilityList[abilityId] + 1
      else
        abilityList[abilityId] = 1
      end
    end
  end


  for k, v in pairs(abilityList) do
    abilityList[k] = zo_strformat("true, -- <<1>> ", string.lower(GetAbilityName(k)) )
  end

  ExoY.store.testVar = nil
  ExoY.store.testVar = abilityList
end

-- /script d(#ExoY.combatProtocol.store.database)
-- /script ExoY.combatProtocol.Cleanup()
function CombatProtocol.Cleanup()
  d(#ExoY.combatProtocol.store.database)
  local start = 1
  local i = start
  while i < start + 5000 do
  --while i < #ExoY.combatProtocol.store.database do

    local abilityId = GetCustomAbilityId( ExoY.combatProtocol.store.database[i] )

    if ExoY.combatProtocol.IsAbilityOnIgnolist(abilityId) then
      table.remove(ExoY.combatProtocol.store.database, i)
    else
      i = i + 1
    end
  end
  d(#ExoY.combatProtocol.store.database)
end

function CombatProtocol.Initialize()
  --if not ExoY.store.combatProtocol.enabled then return end

  CombatProtocol.name = ExoY.name.."CombatProtocol"

  ExoY.EM:RegisterForEvent(ExoY.name.."CombatProtocol", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= "ExoYsCombatProtocol" then return end
    local database = {savedVarsName = "ExoYsCombatProtocolDatabase"}
    _G[database.savedVarsName] = _G[database.savedVarsName] or { database = {} }
    CombatProtocol.store = _G[database.savedVarsName]
    CombatProtocol.database = CombatProtocol.store.database or {}
    ExoY.EM:UnregisterForEvent(ExoY.name.."CombatProtocol", EVENT_ADD_ON_LOADED)
  end)

  CombatProtocol.bossList = {}

  CombatProtocol.record = false

  --ExoY.EM:RegisterForEvent(CombatProtocol.name, EVENT_COMBAT_EVENT, CombatProtocol.OnEvent)
  --ExoY.EM:AddFilterForEvent(CombatProtocol.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE )

  ExoY.EM:RegisterForEvent(CombatProtocol.name.."boss", EVENT_EFFECT_CHANGED, CombatProtocol.KnowBoss)
  ExoY.EM:AddFilterForEvent(CombatProtocol.name.."boss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss" )
end


function CombatProtocol.KnowBoss(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  if changeType == EFFECT_RESULT_GAINED then
    if unitTag and unitId then
      CombatProtocol.bossList[unitId] = unitTag
      CombatProtocol.bossList[unitTag] = unitId
    end
  end
end

function CombatProtocol.OnCombatStart()
  CombatProtocol.bossList = {}

  if CombatProtocol.record then
    local protocolEntry = {}
    protocolEntry.date = GetTimeString()
    protocolEntry.gameTime = GetGameTimeMilliseconds()
    protocolEntry.comment = "combat start"
    if GetUnitName("boss1") ~= "" then
      protocolEntry.boss = GetUnitName("boss1")
    end
    table.insert(CombatProtocol.database, protocolEntry)
  end
end


function CombatProtocol.AddToDisplayTab(guiName, ctrl, line)
  local Display = ExoY.display

  line = line + 1
  CombatProtocol.recordLabel = Display.CreateLabel(guiName.."RecordLabel", ctrl, {1,2}, line, {font = "big", align = TEXT_ALIGN_CENTER, text = "Off", color = {1,0,0,1}})
  Display.CreateButton(guiName.."ToggleRecord", ctrl, {2,2}, line, {text = "Toggle Record", texture = "esoui/art/cadwell/cadwell_indexicon_gold", handler = CombatProtocol.ToggleRecord, })

  line = line + 2
  local combatTime = Display.CreateLabel(guiName.."combatTime", ctrl, {1,1}, line, {font = "normal", align = TEXT_ALIGN_CENTER} )

  local function UpdateCombatTime()
    local time = "no fight"
    if ExoY.combat.state then
      time = GetGameTimeMilliseconds() - ExoY.combat.startTime
    end
    combatTime:SetText(time)
  end
  ExoY.EM:RegisterForUpdate(guiName.."UpdateCombatTime", 10, UpdateCombatTime)

  return line
end


function CombatProtocol.ToggleRecord()
  CombatProtocol.record = not CombatProtocol.record
  local label = CombatProtocol.recordLabel
  label:SetText(CombatProtocol.record and "On" or "Off")
  --label:SetColor(CombatProtocol.record and unpack({0,1,0,1}) or unpack{1,0,0,1} ) --TODO warum wird bei true die schrift schwarz?
  local r,g,b = 0
  if CombatProtocol.record then g = 1 else r = 1 end
  label:SetColor( r,g,b,1)

  if CombatProtocol.record then
    ExoY.EM:RegisterForEvent(CombatProtocol.name, EVENT_COMBAT_EVENT, CombatProtocol.OnEvent)
    ExoY.EM:RegisterForEvent(CombatProtocol.name, EVENT_EFFECT_CHANGED, CombatProtocol.OnEvent)
  else
    ExoY.EM:UnregisterForEvent(CombatProtocol.name, EVENT_COMBAT_EVENT, CombatProtocol.OnEvent)
    ExoY.EM:UnregisterForEvent(CombatProtocol.name, EVENT_EFFECT_CHANGED, CombatProtocol.OnEvent)
  end
end


function CombatProtocol.OnEvent(event, ...)
  if not ExoY.combat.state then return end
  if not CombatProtocol.record then return end

  local Development = ExoY.dev
  local protocolEntry = {}
  protocolEntry.gameTime = GetGameTimeMilliseconds()
  protocolEntry.combatTime = GetGameTimeMilliseconds() - ExoY.combat.startTime
  protocolEntry.event = Development.DecodeEventId(event)
  protocolEntry.data = {}

  local eventList = Development.GetEventList()
  local eventInfo = eventList[event]
  local params = {...}
  for num, data in ipairs(eventInfo) do
    local decoder = Development[data.decoder]
    if type(decoder) == "function" then
      params[num] = decoder(params[num])
    end
    protocolEntry.data[data.param] = params[num]
  end

  --if ExoY.combatProtocol.IsAbilityOnIgnolist( procotolEntry.abilityId ) then return end
  --TODO Option für detailed and non detailed version
  --WARNING abilityId decoder beachten

  --[[local interesting = false
  local abilityId = protocolEntry.data.abilityId
  if trackedIds[abilityId] then interesting = true end
  local abilityName = string.lower(GetAbilityName(abilityId))
  if trackedNames[abilityName] then interesting = true end

  if not interesting then return end
  table.insert(CombatProtocol.database, protocolEntry)
  ]]
  if protocolEntry.data.sourceType == "npc" or  protocolEntry.data.sourceType == "other" then
    local output = ""
    if event == EVENT_COMBAT_EVENT then
      output = zo_strformat("[<<2>>]<<3>> from <<6>> to <<1>> (<<4>>) - <<5>>", protocolEntry.data.targetUnitId, GetTimeString(), protocolEntry.data.abilityId, protocolEntry.data.result, protocolEntry.data.hitValue, protocolEntry.data.sourceUnitId)
    else
      output = zo_strformat("[<<2>>]<<3>> on <<1>> ><<6>>< (<<4>>) - <<5>>", protocolEntry.data.unitId, GetTimeString(), protocolEntry.data.abilityId, protocolEntry.data.changeType, protocolEntry.data.hitValue, protocolEntry.data.unitName)
    end
    table.insert(CombatProtocol.database, output)
  end




  --[[
  local result = ""
  if event == EVENT_COMBAT_EVENT then
    result = protocolEntry.data.result
  else
    result = protocolEntry.data.changeType
  end


  --if protocolEntry.data.sourceType == "npc" or  protocolEntry.data.sourceType == "other" then
    local output = zo_strformat("[<<2>>](<<7>>) <<3>> from <<6>> to <<1>> (<<4>>) - <<5>>", protocolEntry.data.targetUnitId, protocolEntry.combatTime, protocolEntry.data.abilityId, result, protocolEntry.data.hitValue, protocolEntry.data.sourceType, protocolEntry.event)
    table.insert(CombatProtocol.database, output)
  --end
  --if protocolEntry.data.sourceType == "other" then
  --  ExoY.chat.Warning("Sorce Type Other")
  --end
  ]]

end
