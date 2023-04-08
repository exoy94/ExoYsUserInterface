ExoY = ExoY or {}

ExoY.display = ExoY.display or {}
local Display = ExoY.display

local Lib = LibExoYsUtilities
local WM = GetWindowManager()

--TODO change variable names
-- Display Settings
local DISPLAY_WIDTH = 350
local TAB_NUMBER = 5
local BACKGROUND_ALPHA = 0.7
local ICON_SIZE = 50
local tabSize = 57
local lineHeight = 25

local DISPLAY_HIGHT = tabSize*(TAB_NUMBER+1)

local dividerCounter = 0


-- Bindings(Hotkey) Names
ZO_CreateStringId("SI_BINDING_NAME_EXOY_DISPLAY_TAB_ONE", "Display Tab 1")
ZO_CreateStringId("SI_BINDING_NAME_EXOY_DISPLAY_TAB_TWO", "Display Tab 2")
ZO_CreateStringId("SI_BINDING_NAME_EXOY_DISPLAY_TAB_THREE", "Display Tab 3")
ZO_CreateStringId("SI_BINDING_NAME_EXOY_DISPLAY_TAB_FOUR", "Display Tab 4")
ZO_CreateStringId("SI_BINDING_NAME_EXOY_DISPLAY_TAB_FIVE", "Display Tab 5")


local function GetOffsetX( data )
  return (DISPLAY_WIDTH*(data[1]-1) / data[2] ) + 10
end

local function GetOffsetY( line )
  return lineHeight*line + 20
end


function Display.Initialize()
  Display.name = ExoY.name.."Display"

  -- creating display menu to control tab
  Display.main = Display.CreateMain()

  -- creating Header, which will be visible on all tabs
  Display.header = Display.CreateHeader()

  Display.tabs = {}
end 


function Display.OnPlayerActivated()
  local lastTab = ExoY.store.display.currentTab
  local lastDisplay = ExoY.display.tabs[lastTab]

  if lastTab ~= 0 and lastDisplay then
    HUD_UI_SCENE:AddFragment( lastDisplay.frag )
    HUD_SCENE:AddFragment( lastDisplay.frag )
    lastDisplay.button:SetNormalTexture( lastDisplay.icon.."_down.dds")
  else
    -- lastDisplay is nil, when tab positions have been changed
    ExoY.store.display.currentTab = 0
  end
end


function Display.GetDefaults()
  return { currentTab = 0, }
end


function Display.Management( new )

  -- gets tabNumber if tabName was provided
  if type(new) == "string" then
    ExoY.chat.Error("tab string given") return
    --new = ExoY.GetModuleTabNumberByName(new)
  end

  -- early out to prevent error if tabNumber is no number
  if type(new) ~= "number" then ExoY.chat.Error("no tab-number found") return end
  -- early out if tab doesnt exits
  if not ExoY.display.tabs[new] then ExoY.chat.Error("tab does not exist", new) return end

  -- handles current tab
  -- current = 0 --> no tab was open
  local currentTab = ExoY.store.display.currentTab
  local header = ExoY.display.header.frag

  if currentTab ~= 0 then
    local currentDisplay = ExoY.display.tabs[currentTab]
    local currentFrag = currentDisplay.frag
    currentDisplay.button:SetNormalTexture( currentDisplay.icon.."_up.dds")
    HUD_UI_SCENE:RemoveFragment( currentFrag )
    HUD_SCENE:RemoveFragment( currentFrag )

    HUD_UI_SCENE:RemoveFragment( header )
    HUD_SCENE:RemoveFragment( header )
  end

  -- handels new tab
  -- if new equal current, tab just gets hidden and current tab set to zero
  local newDisplay = ExoY.display.tabs[new]
  if new ~= currentTab then
    ExoY.store.display.currentTab = new
    local newFrag = newDisplay.frag
    HUD_UI_SCENE:AddFragment( newFrag )
    HUD_SCENE:AddFragment( newFrag )
    newDisplay.button:SetNormalTexture( newDisplay.icon.."_down.dds")

    HUD_UI_SCENE:AddFragment( header )
    HUD_SCENE:AddFragment( header )
  else
    ExoY.store.display.currentTab = 0
  end
end

----------------------------
-- Main Display Interface --
----------------------------

function Display.CreateMain()
  local name = Display.name.."Main"

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:SetClampedToScreen(true)
  win:SetMouseEnabled(true)
  win:ClearAnchors()
  win:SetAnchor( BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
  win:SetDimensions( tabSize , tabSize )

  local frag = ZO_HUDFadeSceneFragment:New( win )
  HUD_UI_SCENE:AddFragment( frag )
  HUD_SCENE:AddFragment( frag )

  local ctrl = WM:CreateControl(name.."Control", win, CT_CONTROL )
  ctrl:ClearAnchors()
  ctrl:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0 )
  ctrl:SetDimensions(tabSize, tabSize)

  local back = WM:CreateControl( name.."Background", ctrl, CT_BACKDROP )
  back:ClearAnchors()
  back:SetAnchor( BOTTOMRIGHT, ctrl, BOTTOMRIGHT, 0, 0)
  back:SetDimensions( tabSize, DISPLAY_HIGHT)
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil, 2, 2, 2)
  back:SetCenterColor(0,0,0, BACKGROUND_ALPHA)

  local icon = WM:CreateControl( name.."Icon", ctrl, CT_TEXTURE )
  icon:ClearAnchors()
  icon:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
  icon:SetDimensions( ICON_SIZE-10, ICON_SIZE-10)
  icon:SetTexture( "exoysuserinterface/textures/exoy.dds" )

  return {
    ["win"] = win,
    ["ctrl"] = ctrl,
    ["frag"] = frag,
    }
end


function Display.AddTab( tabSettings )
  local guiName =tabSettings.name.."Display"
  local tabNo = tabSettings.number

  local gui = {}
  local icon = tabSettings.icon and tabSettings.icon or "esoui/art/menubar/menubar_help"

	local button = WM:CreateControl( guiName.."Button", Display.main.ctrl, CT_BUTTON )
  button:ClearAnchors()
  button:SetAnchor(CENTER, Display.main.ctrl, CENTER, 0, -(TAB_NUMBER-tabNo+1)*(tabSize) )
  button:SetDimensions( ICON_SIZE, ICON_SIZE )
  button:SetNormalTexture( icon.."_up.dds")
  button:SetMouseOverTexture( icon.."_over.dds" )
  button:SetHandler( "OnClicked", function( )
      Display.Management( tabNo )
    end)

  local win = WM:CreateTopLevelWindow( guiName )
  win:SetMouseEnabled(true)
  win:ClearAnchors()
  win:SetAnchor( BOTTOMRIGHT , Display.main.win , BOTTOMLEFT, 2, 0)
  win:SetHidden(true)
  win:SetDimensions( DISPLAY_WIDTH , DISPLAY_HIGHT )

  local frag = ZO_HUDFadeSceneFragment:New( win )

  local ctrl = WM:CreateControl( guiName.."Control", win, CT_CONTROL )
  ctrl:ClearAnchors()
  ctrl:SetAnchor( CENTER, win, CENTER, 0, 0 )
  ctrl:SetDimensions( DISPLAY_WIDTH , DISPLAY_HIGHT )

  local back = WM:CreateControl( guiName.."Background", ctrl, CT_BACKDROP )
  back:ClearAnchors()
  back:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
  back:SetDimensions( DISPLAY_WIDTH , DISPLAY_HIGHT )
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil, 2, 2, 2)
  back:SetCenterColor(0,0,0, BACKGROUND_ALPHA)

  local header = WM:CreateControl( guiName.."Header", ctrl, CT_LABEL )
  header:ClearAnchors()
  header:SetAnchor(TOP, ctrl, TOP, 0, 5 )
  header:SetColor( 1, 1, 1, 0.7 )
  header:SetFont( Lib.GetFont(24) )
  header:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  header:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
  header:SetText( tabSettings.header and tabSettings.header or "" )

  table.insert( ExoY.display.tabs, tabNo, { ["frag"]=frag, ["button"]=button, ["icon"]=icon } )

  return ctrl
end

------------
-- Header --
------------

function Display.CreateHeader()
  local name = Display.name.."Header"
  local height = 45

  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors()
  win:SetAnchor( BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -tabSize, -DISPLAY_HIGHT+50)
  win:SetHidden(false)
  win:SetDimensions( DISPLAY_WIDTH , height )
  win:SetDrawLayer(2)

  local frag = ZO_HUDFadeSceneFragment:New( win )
  HUD_UI_SCENE:AddFragment( frag )
  HUD_SCENE:AddFragment( frag )

  local ctrl = WM:CreateControl(name.."Control", win, CT_CONTROL )
  ctrl:ClearAnchors()
  ctrl:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 0 )
  ctrl:SetDimensions( DISPLAY_WIDTH, height)

  return {
    ["win"] = win,
    ["ctrl"] = ctrl,
    ["frag"] = frag,
    }
end

function Display.AddToHeader( data )
  local gui = Display.header
  local indicator = WM:CreateControl(Display.name.."Header"..data.name, gui.ctrl, CT_TEXTURE)
  indicator:ClearAnchors()
  indicator:SetAnchor( TOPLEFT, gui.ctrl, TOPLEFT, data.offsetX, data.offsetY)
  indicator:SetDimensions(data.dimensionX, data.dimensionY)
  indicator:SetHidden( data.hidden )
  indicator:SetTexture( data.texture )
  gui[data.name] = indicator
  return indicator
end


-----------------------
-- Creating Controls --
-----------------------

function Display.CreateLabel(name, parent, column, line, data)
  local label = WM:CreateControl(name.."label", parent, CT_LABEL)
  label:ClearAnchors()
  label:SetAnchor(TOPLEFT, parent, TOPLEFT, GetOffsetX(column), GetOffsetY(line) )
  label:SetFont( Lib.GetFont(data.font) ) 
  label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  label:SetDimensions(DISPLAY_WIDTH/column[2] -20, lineHeight)
  label:SetHorizontalAlignment( data.align and data.align or TEXT_ALIGN_LEFT )
  local color = data.color and data.color or {1,1,1,0.7 }
  label:SetColor(unpack(color))
  label:SetText( data.text and data.text or "" )
  return label
end


function Display.CreateButton( name, parent, column, line, data )
  local texture = data.texture and data.texture or "esoui/art/menubar/menubar_help"

  local button = WM:CreateControl(name.."button", parent, CT_BUTTON)
  button:ClearAnchors()
  button:SetAnchor(TOPLEFT, parent, TOPLEFT, GetOffsetX(column), GetOffsetY(line) )
  button:SetDimensions(33,33)
  button:SetNormalTexture( texture.."_up.dds" )
  button:SetMouseOverTexture( texture.."_down.dds" )

  if data.tooltip then
    button:SetHandler("OnMouseEnter", function()
      InitializeTooltip(InformationTooltip, button, RIGHT)
      --InformationTooltip:AddLine( zo_strformat("<<C:1>>", data.tooltip), "ZoFontWinH2" )
      InformationTooltip:AddLine( data.tooltip )
    end)
    button:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end )
  end

  if data.collectible then
    button:SetHandler( "OnClicked", function() UseCollectible(data.collectible) end)
  elseif data.emote then
    button:SetHandler( "OnClicked", function() PlayEmoteByIndex(data.emote) end)
  elseif data.handler then
    button:SetHandler( "OnClicked", function() data.handler() end)
  else
    button:SetHandler( "OnClicked", function() ExoY.chat.Warning("no function") end)
  end

  local label = WM:CreateControl(name.."label", parent, CT_LABEL)
  label:ClearAnchors()
  label:SetAnchor(LEFT, button, RIGHT, 0,0)
  label:SetFont( Lib.GetFont(16) )
  label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  label:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
  label:SetColor( 1, 1, 1, 0.7)
  label:SetText( data.text and data.text or "" )

  return { ["button"] = button, ["label"] = label,}
end


function Display.CreateDivider(parent, line)
  dividerCounter = dividerCounter + 1
  local name = ExoY.name.."divider"..tostring(dividerCounter)
  local divider = WM:CreateControl(name , parent, CT_TEXTURE)
  divider:ClearAnchors()
  divider:SetAnchor(TOP, parent, TOP, 0, GetOffsetY(line)+15)
  divider:SetDimensions(DISPLAY_WIDTH+80, 7)
  divider:SetTexture("esoui/art/interaction/conversation_divider.dds")
  return divider
end



--[[ ------------------------------- ]]
--[[ -- CP Slotable Visualization -- ]]
--[[ ------------------------------- ]]

function Display.CreateChampionSlotableIndicator(name, parent, discipline, index, offsetX, line )
  local function GetCpSlotableTooltip(index, control)
    local cpId = GetSlotBoundId(index, HOTBAR_CATEGORY_CHAMPION)
    InitializeTooltip(InformationTooltip, control, RIGHT) --reference SIDE_TO_TOOLTIP_SIDE table in esoui/libraries/zo_templates/tooltip.lua
    InformationTooltip:AddLine(zo_strformat("<<C:1>>", GetChampionSkillName(cpId)), "ZoFontWinH2")
    ZO_Tooltip_AddDivider(InformationTooltip)
    InformationTooltip:AddLine( GetChampionSkillDescription(cpId) )

    local currentBonus = GetChampionSkillCurrentBonusText( cpId, GetNumPointsSpentOnChampionSkill(cpId) )
    if currentBonus ~= "" then
      ZO_Tooltip_AddDivider(InformationTooltip)
      InformationTooltip:AddLine( currentBonus ) 
    end
  end

  local path = "esoui/art/champion/actionbar/champion_bar"
  local format = "<<1>>_<<2>>_<<3>>"
  local frameTexture = zo_strformat(format, path, "slot", "frame.dds")
  local ringTexture = zo_strformat(format, path, discipline, "selection.dds")
  local starTexture = zo_strformat(format, path, discipline, "slotted.dds")

  local frame = WM:CreateControl(name.."frame" , parent, CT_TEXTURE)
  frame:ClearAnchors()
  frame:SetAnchor(CENTER, parent, TOPLEFT, offsetX, GetOffsetY(line))
  frame:SetHidden(false)
  frame:SetDimensions(27, 27)
  frame:SetTexture(frameTexture)

  local ring = WM:CreateControl(name.."ring" , parent, CT_TEXTURE)
  ring:ClearAnchors()
  ring:SetAnchor(CENTER, parent, TOPLEFT, offsetX, GetOffsetY(line))
  ring:SetHidden(true)
  ring:SetDimensions(27, 27)
  ring:SetTexture(ringTexture)

  local star = WM:CreateControl(name.."star" , parent, CT_TEXTURE)
  star:ClearAnchors()
  star:SetAnchor(CENTER, parent, TOPLEFT, offsetX, GetOffsetY(line))
  star:SetHidden(true)
  star:SetDimensions(27, 27)
  star:SetTexture(starTexture)
  star:SetMouseEnabled(true)
  star:SetDrawLayer(1)
  star:SetHandler("OnMouseEnter", function(star) GetCpSlotableTooltip(index, star) end)
  star:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end )

  return {["ring"] = ring, ["star"] = star}
end
