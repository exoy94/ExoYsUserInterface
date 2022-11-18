-- manually deleting combat Protocol: /script ExoY.combatProtocol.store.database = {}

--[[
  TODO Improvement Idea
  Seperate databases (9) --> seperate files (respect atom limitation)
  hotkey for toggle on/off to investigate mechanics which happen later during a fight
  always collect unit and combatStart/end information wenn database is selected
  display tab:
    show status (enabled, active, selected database)
    show gameTime and combattime for better analysis with video
    controll over which database is used (give them some sort of name), number of entries etc
]]


ExoY = ExoY or {}
ExoY.combatProtocol = ExoY.combatProtocol or {}

local CombatProtocol = ExoY.combatProtocol


function CombatProtocol.Initialize()
  if not ExoY.store.combatProtocol.enabled then return end

  CombatProtocol.name = ExoY.name.."CombatProtocol"

  ExoY.EM:RegisterForEvent(ExoY.name.."CombatProtocol", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= "ExoYsCombatProtocol" then return end
    local database = {savedVarsName = "ExoYsCombatProtocolDatabase"}
    _G[database.savedVarsName] = _G[database.savedVarsName] or { database = {} }
    CombatProtocol.store = _G[database.savedVarsName]
    CombatProtocol.database = CombatProtocol.store.database or {}
    ExoY.EM:UnregisterForEvent(ExoY.name.."CombatProtocol", EVENT_ADD_ON_LOADED)
  end)

  CombatProtocol.decodeProgressBar = CombatProtocol.CreateDecodeProgressbar()

  ExoY.EM:RegisterForEvent(CombatProtocol.name, EVENT_COMBAT_EVENT, CombatProtocol.OnEvent)
  --ExoY.EM:AddFilterForEvent(CombatProtocol.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE )

  CombatProtocol.unitList = {}
  ExoY.EM:RegisterForEvent(CombatProtocol.name.."boss", EVENT_EFFECT_CHANGED, CombatProtocol.KnowUnits)
  ExoY.EM:AddFilterForEvent(CombatProtocol.name.."boss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss" )
  ExoY.EM:RegisterForEvent(CombatProtocol.name.."group", EVENT_EFFECT_CHANGED, CombatProtocol.KnowUnits)
  ExoY.EM:AddFilterForEvent(CombatProtocol.name.."group", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group" )
end

function CombatProtocol.KnowUnits(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  if changeType == EFFECT_RESULT_GAINED then
    if unitTag and unitId then
      CombatProtocol.unitList[unitId] = unitTag
    end
  end
end

function CombatProtocol.GetDefaults()
  local defaults = {}
  defaults.enabled = true
  defaults.active = true
  for eventId, arguments in pairs( ExoY.dev.GetEventList() ) do
    defaults[eventId] = {}
    defaults[eventId].enabled = true
    for key, data in ipairs(arguments) do
      defaults[eventId][data.param] = true
    end
  end
  return defaults
end

function CombatProtocol.GetMenu()
  local menu = {}
  --table.insert(menu, {type="description", text= function() return #CombatProtocol.store.database end, width = "half", reference = "EXOY_MENU_COMBAT_PROTOCOL_DATABASE_ENTRY_NUMBER"} )
  --table.insert(menu, {type="button", name="Delete Protocol", func = function()
  --  CombatProtocol.store.database = {}
  --  EXOY_MENU_COMBAT_PROTOCOL_DATABASE_ENTRY_NUMBER:UpdateValue()
  --end, width = "half"})
  table.insert(menu, ExoY.menu.CreateCheckbox("enabled", ExoY.store.combatProtocol, true, "half") )
  table.insert(menu, ExoY.menu.CreateCheckbox("active", ExoY.store.combatProtocol, false, "half") )
  for eventId, arguments in pairs( ExoY.dev.GetEventList() ) do
    local submenu = {}
    table.insert(submenu, ExoY.menu.CreateCheckbox("enabled", ExoY.store.combatProtocol[eventId] ))
    table.insert(submenu, {type="divider"})
    for key, data in ipairs(arguments) do
      table.insert(submenu, ExoY.menu.CreateCheckbox(data.param, ExoY.store.combatProtocol[eventId]) )
    end
    table.insert(menu, {type="submenu", name=ExoY.dev.DecodeEventId(eventId), controls = submenu})
  end
  return menu
end


function CombatProtocol.OnCombatStart()
  if not ExoY.store.combatProtocol.active then return end
  local protocolEntry = {}
  protocolEntry.date = GetTimeString()
  protocolEntry.gameTime = GetGameTimeMilliseconds()
  protocolEntry.comment = "combat start"
  if GetUnitName("boss1") ~= "" then
    protocolEntry.boss = GetUnitName("boss1")
  end
  table.insert(CombatProtocol.database, protocolEntry)
end

function CombatProtocol.OnCombatEnd()
  if not ExoY.store.combatProtocol.active then return end

  local protocolEntry = {}
  for unitId, unitTag in pairs(CombatProtocol.unitList) do
    if string.find(unitTag, "group") then
      protocolEntry[unitId] = GetUnitDisplayName(unitTag)
    else
      protocolEntry[unitId] = unitTag
    end
  end


  table.insert(CombatProtocol.database, protocolEntry)
  CombatProtocol.unitList = {}

  protocolEntry = {}
  protocolEntry.date = GetTimeString()
  protocolEntry.gameTime = GetGameTimeMilliseconds()
  protocolEntry.comment = "combat end"
  table.insert(CombatProtocol.database, protocolEntry)
end

function CombatProtocol.OnEvent(event, ...)
  if not ExoY.store.combatProtocol.active then return end
  if not ExoY.inCombat then return end

  local protocolEntry = {}
  protocolEntry.gameTime = GetGameTimeMilliseconds()
  protocolEntry.event = event
  protocolEntry.arguments = {...}
  table.insert(CombatProtocol.database, protocolEntry)
end

function CombatProtocol.DecodeDatabase() --TODO Statusbar to show progress
  local eventList = ExoY.dev.GetEventList()
  local lastCombatStart = 0
  local progressBar = CombatProtocol.decodeProgressBar
  progressBar.win:SetHidden(false)
  progressBar.bar:SetMinMax(0, #CombatProtocol.store.database )
  progressBar.bar:SetValue(0)

  local unitIds = CombatProtocol.database[1379]

  for entry, data in ipairs(CombatProtocol.database) do
    progressBar.bar:SetValue(entry)
    if data.comment == "combat start" then
      lastCombatStart = data.gameTime
    end
    if data.event then
      data.combatTime = data.gameTime - lastCombatStart
      for key, param in ipairs(data.arguments) do
        local decoder = ExoY.dev[eventList[data.event][key].decoder]
        if type(decoder) == "function" then
          CombatProtocol.database[entry].arguments[key] = decoder(param)
        end

        -- manuel
        if key == 3 and param == "" then
          local output = GetAbilityName( data.arguments[16] )
          CombatProtocol.database[entry].arguments[key] = output
        end

        if key == 14 or key == 15 then
          local output = unitIds[param] and unitIds[param] or param
          CombatProtocol.database[entry].arguments[key] = output
        end
      end
    end
  end
  progressBar.win:SetHidden(true)
end

--   /script ExoY.combatProtocol.CleanUpDataBase()
function CombatProtocol.CleanUpDataBase()
  local tabuList = {
    "Player Pet Speed",
    "Player Pet Battle Spirit",
    "Player Pet Defenses",
    "Player Pet Critical Chance",
    "Pet Battle Spirit",
    "Necromancer Pet 6s Tracker",
    "Intensive Mender Spawn Stun",
    "Intensive Mender",
    "Unstable Wall of Frost",
    "Major Intellect",
    "Major Prophecy",
    "Major Sorcery",
    "Major Intellect",
    "Restore Magicka",
    "Overflowing Altar",
    "Minor Lifesteal",
    "Roaring Opportunist",
    "Tri Focus",
    "Restoration Expert",
    "Cycle of Life",
    "Restoration Master",
    "Absorb",
    "Shocking Siphon",
    "Combat Prayer",
    "Minor Resolve",
    "Minor Berserk",
    "Elemental Force",
    "Reconstitute",
    "Illustrious Healing",
    "Grand Healing Fx",
    "Minor Courage",
    "Taunt",
    "Taunt Counter",
    "Light Attack (Ice)",
    "Unstable Frost Shield",
    "Minor Magickasteal",
    "Absorb Magicka",
    "Defensive Stance",
    "Medium Armor Evasion",
    "Roll Dodge",
    "Immobilize Immunity",
    "Dodge Fatigue",
    "Frozen",
    "Chill",
    "Minor Maim",
    "Minor Brittle",
  }
  for entry, data in ipairs(CombatProtocol.database) do
    if data.event then
      for key, param in ipairs(data.arguments) do
          if key == 3 then
            for _, tabu in ipairs(tabuList) do
              if param == tabu then
                zo_callLater(function() CombatProtocol.database[entry] ={} end, 1000)
              end
            end
          end
      end
    end
  end

end



--/script ExoY.combatProtocol.decodeProgressBar.bar:SetMinMax(0,11)
function CombatProtocol.CreateDecodeProgressbar()
  local name = CombatProtocol.name.."DecodeProgressBar"

  local win = ExoY.WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors()
  win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  win:SetHidden(true)

  local back = ExoY.WM:CreateControl( name.."Back", win, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(CENTER, win, CENTER, 0, 0)
  back:SetDimensions( 310, 35 )
  back:SetCenterColor(0,0,0,0.5)
  back:SetEdgeColor(0,0,0,1)

  local bar = ExoY.WM:CreateControl( name.."Bar", win, CT_STATUSBAR)
  bar:ClearAnchors()
  bar:SetAnchor(CENTER, win, CENTER, 0, 0)
  bar:SetDimensions( 300, 25 )
  bar:SetColor( 0, 1, 0, 1)

  return {
    win = win,
    bar = bar,
  }

end
