-- manually deleting combat Protocol: /script ExoY.combatProtocol.store.database = {}
-- 110118

ExoY = ExoY or {}
ExoY.combatProtocol = ExoY.combatProtocol or {}

local CombatProtocol = ExoY.combatProtocol

local trackedNames = {
  --["noxious sludge"] = true,
  --["noxious release"] = true,
  ["magma sludge"] = true,
  --["creeping eye"] = true,
  --["creeping manifold"] = true,
}
local trackedIds = {
  [160180] = true, --creeping eye dspn
  [153661] = true, --creeping eye dspn
  [153660] = true, --creeping eye cd
  [153426] = true, --creeping eye 12
}


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

  CombatProtocol.CreateDisplayTab()

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


function CombatProtocol.AddToDisplayTab()
  local Display = ExoY.display
  local tabSettings = {
    ["name"] = CombatProtocol.name,
    ["number"] = 1,
    ["icon"] = "esoui/art/campaign/overview_indexicon_emperor",
    ["header"] = "Combat Protocol",
  }

  local guiName = CombatProtocol.name.."Tab"
  local ctrl = Display.AddTab( tabSettings )
  local line = 0

  line = line + 1
  CombatProtocol.recordLabel = Display.CreateLabel(guiName.."RecordLabel", ctrl, {1,2}, line, {font = "big", align = TEXT_ALIGN_CENTER, text = "Off", color = {1,0,0,1}})
  Display.CreateButton(guiName.."ToggleRecord", ctrl, {2,2}, line, {text = "Toggle Record", texture = "esoui/art/cadwell/cadwell_indexicon_gold", handler = CombatProtocol.ToggleRecord, })

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

  local interesting = false
  local abilityId = protocolEntry.data.abilityId
  if trackedIds[abilityId] then interesting = true end
  local abilityName = string.lower(GetAbilityName(abilityId))
  if trackedNames[abilityName] then interesting = true end

  if not interesting then return end
  table.insert(CombatProtocol.database, protocolEntry)
end
