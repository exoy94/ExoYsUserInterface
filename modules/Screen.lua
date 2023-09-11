ExoY = ExoY or {}
ExoY.screen = ExoY.screen or {}

local Screen = ExoY.screen
local Lib = LibExoYsUtilities


function Screen.Initialize()
  Screen.name = ExoY.name.."Screen"

  ZO_PreHook(PLAYER_PROGRESS_BAR, "Show", function() --esoui/ingame/playerprogressbar/playerprogressbar.lua: 582
    if SCENE_MANAGER:GetCurrentScene():GetName() == "hud" then

        local self = PLAYER_PROGRESS_BAR
        self:SetBarState(PPB_STATE_SHOWING)
        self:UpdateBar()
        --self.control:SetHidden(false)
        self.fadeTimeline:PlayForward()
        CALLBACK_MANAGER:FireCallbacks("PlayerProgressBarFadingIn")

      return true
    else
      return false
    end
  end)
end



function Screen.OnInitialPlayerActivated()
  ZO_ActionBar1KeybindBG:SetAlpha(0)   -- actionbar hotkey background transparent
  ZO_HousingHUDFragmentTopLevelKeybindButton:SetHidden(true)   --hide housing-editor hotkey (default F5)

  ZO_ActionBar1:SetScale(1.2)

  -- Hiding Reticle and preventing it for showing up on impactful hit
  RETICLE.reticleTexture:SetAlpha(0)
  RETICLE.control:UnregisterForEvent(EVENT_IMPACTFUL_HIT)
end


function Screen.OnPlayerActivated()
  --ZO_AlertTextNotification:SetHidden(true) --WARNING missed out on usefull information
  --hide actionbar hotkeys (3-7 skills; 8 ultimate )
  for x = 3, 8 do
      _G['ActionButton' .. x .. 'ButtonText']:SetHidden(true)
  end
  if GetAPIVersion() == 101034 then --TODO
    QuickslotButtonButtonText:SetHidden(true)
  end
  CompanionUltimateButtonButtonText:SetHidden(true)

  --CompanionUltimateButton:ClearAnchors()
  --CompanionUltimateButton:SetAnchor(LEFT, ZO_ActionBar1, RIGHT)

  --ActionButton9:ClearAnchors()
  --ActionButton9:SetAnchor(RIGHT, ZO_ActionBar1, LEFT)
  --ActionButton8Decoration:SetHidden(true)
  --ActionButton8LeadingEdge:SetHidden(true)
  --ActionButton8:ClearAnchors()
  --ActionButton8:SetAnchor(CENTER, GuiRoot, CENTER, 0,0)



  --CompanionUltimateButton:ClearAnchors()
  --CompanionUltimateButton:SetAnchor(RIGHT, weaponSwapControl, LEFT, -style.quickslotOffsetXFromFirstSlot * scale)
  --ActionButton9 <-- quickslot

  -- hide experience bar
  --ZO_PlayerProgress:SetHidden(true)
  --ZO_PlayerProgress:SetAlpha(0)
  --ZO_PlayerProgress:SetHidden(true)

  Screen.MoveDefaultPanels()
end

-------------------------
-- Move Default Panels --
-------------------------

--[[local defaultPanels_old = { --from Lui
    [ZO_HUDTelvarMeter]	= {"TelVar Meter"},
  --  [ZO_HUDDaedricEnergyMeter] = { GetString(SI_LUIE_DEFAULT_FRAME_VOLENDRUNG_METER) },
  --  [ZO_HUDEquipmentStatus]	= { GetString(SI_LUIE_DEFAULT_FRAME_EQUIPMENT_STATUS) },
  --  [ZO_FocusedQuestTrackerPanel] = { GetString(SI_LUIE_DEFAULT_FRAME_QUEST_LOG), nil, 200 },
    [ZO_LootHistoryControl_Keyboard] = { "Loot History", 280, 400 },
    [ZO_BattlegroundHUDFragmentTopLevel] = { "Battleground Score" },
    [ZO_ActionBar1]	= {"ActionBar"},
    [ZO_Subtitles] = {"Subtitles", 256, 80 },
  --  [ZO_TutorialHudInfoTipKeyboard]	= { GetString(SI_LUIE_DEFAULT_FRAME_TUTORIALS) },
    [ZO_ObjectiveCaptureMeter] = {"Objective Capture", 128, 128 },
  --  [ZO_PlayerToPlayerAreaPromptContainer] = { GetString(SI_LUIE_DEFAULT_FRAME_PLAYER_INTERACTION), nil, 30 },
    [ZO_SynergyTopLevelContainer] = {"Synergy"},
  --  [ZO_AlertTextNotification] = { GetString(SI_LUIE_DEFAULT_FRAME_ALERTS), 600, 56 },
    [ZO_CompassFrame] = {"Compass"}, -- Needs custom template applied
  --  [ZO_ActiveCombatTipsTip] = { GetString(SI_LUIE_DEFAULT_FRAME_ACTIVE_COMBAT_TIPS), 250, 20 }, -- Needs custom template applied
  --  [ZO_PlayerProgress] = { GetString(SI_LUIE_DEFAULT_FRAME_PLAYER_PROGRESS) }, -- Needs custom template applied
    --[ZO_CenterScreenAnnounce] = { GetString(SI_LUIE_DEFAULT_FRAME_CSA), nil, 100 }, -- Needs custom template applied

    [ZO_RamTopLevel] = {"AvA Ram"},

    [ZO_HUDTelvarMeter]	= { GetString(SI_LUIE_DEFAULT_FRAME_TEL_VAR_METER) },
    [ZO_HUDDaedricEnergyMeter] = { GetString(SI_LUIE_DEFAULT_FRAME_VOLENDRUNG_METER) },
    [ZO_HUDEquipmentStatus]	= { GetString(SI_LUIE_DEFAULT_FRAME_EQUIPMENT_STATUS) },
    [ZO_FocusedQuestTrackerPanel] = { GetString(SI_LUIE_DEFAULT_FRAME_QUEST_LOG), nil, 200 },

    [ZO_BattlegroundHUDFragmentTopLevel] = { GetString(SI_LUIE_DEFAULT_FRAME_BATTLEGROUND_SCORE) },
    [ZO_Subtitles] = { GetString(SI_LUIE_DEFAULT_FRAME_SUBTITLES), 256, 80 },
    [ZO_TutorialHudInfoTipKeyboard]	= { GetString(SI_LUIE_DEFAULT_FRAME_TUTORIALS) },
    [ZO_AlertTextNotification] = { GetString(SI_LUIE_DEFAULT_FRAME_ALERTS), 600, 56 },
    [ZO_CompassFrame] = { GetString(SI_LUIE_DEFAULT_FRAME_COMPASS) }, -- Needs custom template applied
    [ZO_ActiveCombatTipsTip] = { GetString(SI_LUIE_DEFAULT_FRAME_ACTIVE_COMBAT_TIPS), 250, 20 }, -- Needs custom template applied
    [ZO_CenterScreenAnnounce] = { GetString(SI_LUIE_DEFAULT_FRAME_CSA), nil, 100 }, -- Needs custom template applied
}]]

local defaultPanels = {
    -- panel = {anchorChild, anchorParent, offsetX, offsetY}
    [ZO_ActiveCombatTipsTip] = {CENTER, CENTER, 0, 0},
    [ZO_AlertTextNotification] = {TOP, TOP, 0, 300},
    [ZO_MainMenuCategoryBar] = {TOP, TOP, -100, 60},
    [ZO_CompassCenterOverPinLabel] = {TOP, TOP,  0, 70},
    [ZO_InstanceKickWarning_AliveContainer] = {CENTER, CENTER, 0, 0},
    [ZO_InstanceKickWarning_DeadContainer] = {CENTER, CENTER, 0, 0},
    [ZO_LootHistoryControl_Keyboard] = {BOTTOMRIGHT, BOTTOMRIGHT, -35, -355}, -- -415, -18
    [ZO_ActionBar1] = {TOP, TOP, 0, 1125},
    [ZO_PlayerToPlayerAreaPromptContainer] = {BOTTOM, BOTTOM, 0, -100},
    [ZO_SynergyTopLevelContainer] = {TOP, TOP, 0, 950},
    [ZO_ObjectiveCaptureMeter] = { TOP, TOP, 0, 500 },
    [ZO_BuffDebuffTopLevelSelfContainerContainer1] = {TOP, TOP, 0, 920},
    [ZO_HUDInfamyMeter] = {BOTTOMRIGHT, BOTTOMRIGHT, -400,0},
    [ZO_ChampionPerksActionBar] = {TOP, TOP, 0, 60},
    [ZO_HUDTelvarMeter] = {BOTTOMRIGHT, BOTTOMRIGHT, -400,0},
    [ZO_RamTopLevel] = {BOTTOMRIGHT, BOTTOMRIGHT, -800,0},
    --ZO_TopBarBackground
}


function Screen.MoveDefaultPanels()
  for panel, data in pairs(defaultPanels) do
    local panelName = panel:GetName()
    panel:ClearAnchors()
    panel:SetAnchor(data[1], GuiRoot, data[2] ,data[3], data[4])

    if panelName == ZO_ObjectiveCaptureMeter then
      ZO_ObjectiveCaptureMeterFrame:SetAnchor(BOTTOM, ZO_ObjectiveCaptureMeter, BOTTOM, 0, 0)
    end

  end
end


---------------------------
-- Coordinates Indicator --
---------------------------

function Screen.TogglePositionIndicator()
  local function InitializePositionIndicator()
    local name = Screen.name.."PositionIndicator"
    local win = WM:CreateTopLevelWindow( name.."win")
    win:ClearAnchors()
    win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)
    win:SetMovable(false)
    win:SetDimensions(70,25)
    win:SetHidden(true)

    local label = WM:CreateControl( name.."label", win, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, win , TOPLEFT, 0, 0)
    label:SetFont( Lib.GetFont() )

    return { ["win"]=win, ["label"]=label }
  end

  -- initialize indicator first time is is called upon
  if not Screen.positionIndicator then
    Screen.positionIndicator = InitializePositionIndicator()
  end
  if Screen.positionIndicator.win:IsHidden() then
    Screen.positionIndicator.win:SetHidden(false)
    EM:RegisterForUpdate(Screen.name.."PositionIndicatorUpdate", 10, function()
        local x,y = GetUIMousePosition()
        Screen.positionIndicator.win:ClearAnchors()
        Screen.positionIndicator.win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x+20 , y)
        Screen.positionIndicator.label:SetText( zo_strformat("<<1>>:<<2>>", x, y) ) --Normal
        --Screen.positionIndicator.label:SetText( zo_strformat("<<1>>:<<2>>", x-695, y-144) ) -- WorldMap
      end)
  else
    Screen.positionIndicator.win:SetHidden(true)
    EM:UnregisterForUpdate(Screen.name.."PositionIndicatorUpdate")
  end
end

---------------------------------
-- Draw Horizontal Center Line --
---------------------------------

function Screen.ToggleCenterLine()
  local function InitializeCenterLine()
    local name = Screen.name.."CenterLine"
    local width, height = GuiRoot:GetDimensions()
    local win = WM:CreateTopLevelWindow( name.."win" )
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(false)
    win:SetMovable(false)
    win:ClearAnchors()
    win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0)
    win:SetHidden(true)
    win:SetDimensions( 0 , 0 )

    local back = WM:CreateControl( name.."line", win, CT_BACKDROP)
    back:ClearAnchors()
    back:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
    back:SetDimensions( 1, height)
    back:SetEdgeColor(0,0,0,0)
    back:SetCenterColor( 0, 1, 0, 1)

    return win
  end

  if not Screen.centerLine then
    Screen.centerLine = InitializeCenterLine()
  end
  if Screen.centerLine:IsHidden() then
    Screen.centerLine:SetHidden(false)
  else
    Screen.centerLine:SetHidden(true)
  end
end
