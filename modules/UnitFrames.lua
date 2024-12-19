ExoY = ExoY or {}

ExoY.unitFrames= ExoY.unitFrames or {}

local UnitFrames = ExoY.unitFrames

local Lib = LibExoYsUtilities
local EM = GetEventManager()
local WM = GetWindowManager()

function UnitFrames.Initialize()
  UnitFrames.name = ExoY.name.."UnitFrames"
  -- hide default frames


  -- Initialize Player Frame
  UnitFrames.InitializePlayerFrame()
  UnitFrames.InitializeShield()
  --UnitFrames.InitializeTargetFrame()
end

function UnitFrames.CreateUnitBar( name, parent, info)
  local barHeight = 29
  local barWidth = 240

  local ctrl = WM:CreateControl(name.."Control", parent, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, info.y)
  ctrl:SetDimensions()

  local back = WM:CreateControl(name.."Back", ctrl, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
  back:SetDimensions(  barWidth, barHeight )
  back:SetCenterColor(0,0,0,0.5)
  back:SetEdgeColor(0,0,0,1)

  local bar = WM:CreateControl(name.."Bar", ctrl, CT_STATUSBAR)
  bar:ClearAnchors()
  bar:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
  bar:SetDimensions( barWidth, barHeight )
  bar:SetColor( unpack(info.color) )
  bar:SetTexture("/ExoYsUserInterface/textures/UnitFrameTexture.dds")

  return bar
end

local function CreateLabel(power, parent)
  local label = WM:CreateControl("attributeLabel"..power, parent, CT_LABEL)
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

  local win = WM:CreateTopLevelWindow(name.."Win")
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

  EM:RegisterForEvent(name.."PowerUpdate", EVENT_POWER_UPDATE, OnPlayerPowerUpdate)
  EM:AddFilterForEvent(name.."PowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
end



function UnitFrames.InitializeTargetFrame()
  local name = UnitFrames.name.."TargetFrame"
  UnitFrames.player = {}

  local win = WM:CreateTopLevelWindow(name.."Win")
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

  EM:RegisterForEvent(name.."PowerUpdateTarget", EVENT_POWER_UPDATE, OnPlayerPowerUpdate)
  EM:AddFilterForEvent(name.."PowerUpdateTarget", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")
  EM:AddFilterForEvent(name.."PowerUpdateTarget", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE , POWERTYPE_HEALTH)
end







function UnitFrames.InitializeShield()
  local name = UnitFrames.name.."PlayerShield"

  local label = WM:CreateControl(name.."Label", UnitFrames.player.win, CT_LABEL)
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

  EM:RegisterForEvent(name.."added", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnAdded)
  EM:AddFilterForEvent(name.."added", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, "player")


  local function OnRemoved(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
    OnShieldUpdate(unitAttributeVisual, 0, maxValue)
  end

  EM:RegisterForEvent(name.."removed", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnRemoved)
  EM:AddFilterForEvent(name.."removed", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, "player")


  local function OnUpdated(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
    OnShieldUpdate(unitAttributeVisual, newValue, newMaxValue)
  end

  EM:RegisterForEvent(name.."Updated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnUpdated)
  EM:AddFilterForEvent(name.."Updated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")

end

