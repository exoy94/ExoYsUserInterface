ExoY = ExoY or {}

ExoY.unitFrames= ExoY.unitFrames or {}

local UnitFrames = ExoY.unitFrames

local Lib = LibExoYsUtilities

function UnitFrames.Initialize()
  UnitFrames.name = ExoY.name.."UnitFrames"
  -- hide default frames


  -- Initialize Player Frame
  UnitFrames.InitializePlayerFrame()
  UnitFrames.InitializeShield()
  --UnitFrames.InitializeTargetFrame()
end


function UnitFrames.GetDefaults()
  return {
    ["playerFrame"] = {left = 600, top = 600},

  }
end

function UnitFrames.CreateUnitBar( name, parent, info)
  local barHeight = 29
  local barWidth = 240

  local ctrl = ExoY.WM:CreateControl(name.."Control", parent, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, info.y)
  ctrl:SetDimensions()

  local back = ExoY.window:CreateControl(name.."Back", ctrl, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
  back:SetDimensions(  barWidth, barHeight )
  back:SetCenterColor(0,0,0,0.5)
  back:SetEdgeColor(0,0,0,1)

  local bar = ExoY.window:CreateControl(name.."Bar", ctrl, CT_STATUSBAR)
  bar:ClearAnchors()
  bar:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
  bar:SetDimensions( barWidth, barHeight )
  bar:SetColor( unpack(info.color) )
  bar:SetTexture("/ExoYsUserInterface/textures/UnitFrameTexture.dds")

  return bar
end

local function CreateLabel(power, parent)
  local label = ExoY.WM:CreateControl("attributeLabel"..power, parent, CT_LABEL)
  label:ClearAnchors()
  label:SetAnchor(CENTER, parent, CENTER, 0, 0)
  label:SetColor(1,1,1,1)
  label:SetFont( Lib.GetFont() )
  local current, max, effMax = GetUnitPower("player", power)
  local text = string.format( "%.1f k", current/1000)
  label:SetText(text)
  return label
end

------------------
-- Player Frame --
------------------

function UnitFrames.InitializePlayerFrame()
  local name = UnitFrames.name.."PlayerFrame"
  UnitFrames.player = {}

  local win = ExoY.window:CreateTopLevelWindow(name.."Win")
  win:ClearAnchors()
  win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 600, 800)
  win:SetDimensions(200, 90)
  win:SetClampedToScreen(true)
  win:SetHidden(false)

  UnitFrames.player.win = win

  local frag = ZO_HUDFadeSceneFragment:New( win )
  HUD_UI_SCENE:AddFragment( frag )
  HUD_SCENE:AddFragment( frag )

  UnitFrames.player.bars = {}
  UnitFrames.player.labels = {}

  local resources = {
    [POWERTYPE_HEALTH] =  {y=0, color = {0.8,0,0,1} },
    [POWERTYPE_MAGICKA] = {y=30,  color = {0,0,0.8,1} },
    [POWERTYPE_STAMINA] = {y=60, color = {0,0.8,0,1} },
  }

  for powerType, data in pairs(resources) do
    UnitFrames.player.bars[powerType] = UnitFrames.CreateUnitBar(name..tostring(powerType), win, data)
    UnitFrames.player.labels[powerType] = CreateLabel(powerType, UnitFrames.player.bars[powerType])
  end

  local function OnPlayerPowerUpdate(_, _, _, powerType, powerValue, powerMax, powerEffectiveMax)
    if not UnitFrames.player.bars[powerType] then return end

    local bar = UnitFrames.player.bars[powerType]
    bar:SetMinMax(0, powerMax)
    bar:SetValue(powerValue)

    --local percent = string.format( "%.0f", powerValue*100/powerMax)
    --local text = zo_strformat("<<1>> ", percent, powerValue/)
    local text = string.format( "%.1f k", powerValue/1000)

    UnitFrames.player.labels[powerType]:SetText( text )

  end

  ExoY.EM:RegisterForEvent(name.."PowerUpdate", EVENT_POWER_UPDATE, OnPlayerPowerUpdate)
  ExoY.EM:AddFilterForEvent(name.."PowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
end



function UnitFrames.InitializeTargetFrame()
  local name = UnitFrames.name.."TargetFrame"
  UnitFrames.player = {}

  local win = ExoY.window:CreateTopLevelWindow(name.."Win")
  win:ClearAnchors()
  win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 700, 900)
  win:SetDimensions(200, 90)
  win:SetClampedToScreen(true)
  win:SetHidden(false)

  local frag = ZO_HUDFadeSceneFragment:New( win )
  HUD_UI_SCENE:AddFragment( frag )
  HUD_SCENE:AddFragment( frag )

  UnitFrames.target.bar = UnitFrames.CreateUnitBar(name..tostring(powerType), win, {y=0, color = {0.8,0,0,1} })


  local function OnPlayerPowerUpdate(_, _, _, powerType, powerValue, powerMax, powerEffectiveMax)
    if not UnitFrames.player.bars[powerType] then return end

    local bar = UnitFrames.player.bars[powerType]
    bar:SetMinMax(0, powerMax)
    bar:SetValue(powerValue)

    local percent = string.format( "%.0f", powerValue*100/powerMax)
    local text = zo_strformat("<<1>>", percent)
    UnitFrames.player.labels[powerType]:SetText( text )

  end

  ExoY.EM:RegisterForEvent(name.."PowerUpdateTarget", EVENT_POWER_UPDATE, OnPlayerPowerUpdate)
  ExoY.EM:AddFilterForEvent(name.."PowerUpdateTarget", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")
  ExoY.EM:AddFilterForEvent(name.."PowerUpdateTarget", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE , POWERTYPE_HEALTH)
end







function UnitFrames.InitializeShield()
  local name = UnitFrames.name.."PlayerShield"

  local label = ExoY.WM:CreateControl(name.."Label", UnitFrames.player.win, CT_LABEL)
  label:ClearAnchors()
  label:SetAnchor(TOPLEFT, UnitFrames.player.win, TOPLEFT, 70, -30)
  label:SetColor(1,1,1,1)
  label:SetFont( Lib.GetFont(24) )

  local function OnShieldUpdate(unitAttributeVisual, value, maxValue)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
      local output = ""
      if value > 0 then
        local text = string.format( "%.1f", value/1000)
        output = zo_strformat("Shield: <<1>> k", text)
      end
      label:SetText(output)
    end
  end

  local function OnAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
    OnShieldUpdate(unitAttributeVisual, value, maxValue)
  end

  ExoY.EM:RegisterForEvent(name.."added", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnAdded)
  ExoY.EM:AddFilterForEvent(name.."added", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, "player")


  local function OnRemoved(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
    OnShieldUpdate(unitAttributeVisual, 0, maxValue)
  end

  ExoY.EM:RegisterForEvent(name.."removed", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnRemoved)
  ExoY.EM:AddFilterForEvent(name.."removed", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, "player")


  local function OnUpdated(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
    OnShieldUpdate(unitAttributeVisual, newValue, newMaxValue)
  end

  ExoY.EM:RegisterForEvent(name.."Updated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnUpdated)
  ExoY.EM:AddFilterForEvent(name.."Updated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")

end


--[[
function UnitFrames.InitializePlayerFrame()
  local name = UnitFrames.name.."PlayerFrame"

  local data = {
    position = {x=700, y=900},
    dimensions = {width = 200, height = 150},
    bars = {width = 200, height = 30},
  }

  local win = ExoY.window:CreateTopLevelWindow(name.."Win")
  win:ClearAnchors()
  win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, data.position.x, data.position.y)
  win:SetDimensions(data.dimensions.width, data.dimensions.height)
  win:SetClampedToScreen(true)
  win:SetMouseEnabled(true)
  win:SetHidden(false)

  local resources = {
    health = {y = 0, power = POWERTYPE_HEALTH, color = {1,0,0,1}},
    magicka = {y = 30, power = POWERTYPE_MAGICKA, color = {0,0,1,1} },
    stamina = {y = 60, power = POWERTYPE_STAMINA, color = {0,1,0,1} },
  }

  for resource, info in pairs(resources) do
    local bar = UnitFrames.CreateUnitBar(name..resource, win, info)

    local function OnPowerUpdate(_, _, _, powerType, powerValue, powerMax, powerEffectiveMax)
      bar:SetMinMax(0, powerMax)
      bar:SetValue(powerValue)
    end

    ExoY.EM:RegisterForEvent(barName, EVENT_POWER_UPDATE, OnPowerUpdate)
    ExoY.EM:AddFilterForEvent(barName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    ExoY.EM:AddFilterForEvent(barName, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE , info.power)
  end
end




function UnitFrames.CreatePlayerFrame()
  local name = UnitFrames.name.."PlayerFrame"
  local store = ExoY.store.unitFrames.playerFrame

  local barHeight = 30
  local barWidth = 200

  local win = ExoY.window:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors()
  win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, store.left, store.top)
  win:SetDimensions(0,0)
  win:SetClampedToScreen(true)
  win:SetMouseEnabled(true)
  win:SetMovable(true)
  win:SetHidden(true)
  win:SetHandler( "OnMoveStop", function()
      store.left = win:GetLeft()
      store.top = win:GetTop()
    end)

  local frag = ZO_HUDFadeSceneFragment:New( win )
  HUD_UI_SCENE:AddFragment( frag )
  HUD_SCENE:AddFragment( frag )

  local ctrl = ExoY.window:CreateControl(name.."Control", win, CT_CONTROL )
  ctrl:ClearAnchors()
  ctrl:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0 )
  ctrl:SetDimensions( barWidth, 4*barHeight)


  local function CreateBar( barName, position, barPowerType, color )
    local back = ExoY.window:CreateControl(barName.."back", ctrl, CT_BACKDROP)
    back:ClearAnchors()
    back:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, position*barHeight)
    back:SetDimensions( barWidth, barHeight )
    back:SetCenterColor(0,0,0,0.5)
    back:SetEdgeColor(0,0,0,1)

    local bar = ExoY.window:CreateControl(barName.."bar", ctrl, CT_STATUSBAR)
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, position*barHeight)
    bar:SetDimensions( barWidth, barHeight )
    bar:SetColor( unpack(color) )
    bar:SetTexture("/ExoYsUserInterface/textures/UnitFrameTexture.dds")

    -- update function
    local function OnPowerUpdate(_, _, _, powerType, powerValue, powerMax, powerEffectiveMax)
      if powerMax ~= powerEffectiveMax then d("ExoY Error PlayerFrame Effective") end  --WARNING
      bar:SetMinMax(0, powerMax)
      bar:SetValue(powerValue)
    end

    -- register tracking events
    ExoY.EM:RegisterForEvent(barName, EVENT_POWER_UPDATE, OnPowerUpdate)
    ExoY.EM:AddFilterForEvent(barName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    ExoY.EM:AddFilterForEvent(barName, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE , barPowerType)
  end

  CreateBar( name.."playerHealth", 1, POWERTYPE_HEALTH,{1,0,0,1} )
end
]]
