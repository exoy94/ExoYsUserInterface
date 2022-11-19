ExoY = ExoY or {}
ExoY.misc = ExoY.misc or {}

local Lib = LibExoYsUtilities

local Misc = ExoY.misc

function Misc.Initialize()
  Misc.name = ExoY.name.."Misc"

  Misc.SearchForItemOnTTCWebsite()
  Misc.InitiateCpSlotableChangeCooldown()
  Misc.SoundOnKillingBlow()
  Misc.AutoBindItems()

  Misc.CreateDisplayTab()

  --Misc.LockArmoyBuilds() --TODO

  Misc.OnUpdateStopwatch()
  ExoY.EM:RegisterForUpdate(Misc.name.."UpdateStopwatch", 1000, Misc.OnUpdateStopwatch)

end


function Misc.GetDefaults()
  return {
    ["stopwatch"] = {
      ["running"] = false,
      ["timeSaved"] = 0,
      ["lastStart"] = 0,
    }
  }
end

--[[* GetEarnedAchievementPoints()
** _Returns:_ *integer* _points_

* GetTotalAchievementPoints()
** _Returns:_ *integer* _points_
]]

function Misc.OnPlayerActivated()
--  Misc.UpdateCpSlotableIndicator()
--  Misc.UpdateUnspentCpPoints()
  Misc.UpdateCollectionProgress()
  Misc.FixVisuals()
end


function Misc.CreateDisplayTab()
  local tabSettings = {
    ["name"] = Misc.name,
    ["number"] = 3,
    ["icon"] = "esoui/art/campaign/overview_indexicon_emperor",
    ["header"] = "Miscellaneous",
  }
  local guiName = Misc.name.."Tab"
  local Display = ExoY.display
  local ctrl = Display.AddTab( tabSettings )
  local line = 0

  line = line + 1
  Misc.stopwatch = { ["gui"]={} }
  local labelStartStop
  if ExoY.store.misc.stopwatch.running then labelStartStop = "Pause"
  elseif ExoY.store.misc.stopwatch.lastStart == 0 then labelStartStop = "Start"
  else labelStartStop = "Resume" end

  Misc.stopwatch.gui.label = Display.CreateLabel(guiName.."StopWatchLabel", ctrl, {1,2}, line, {font = "big", align = TEXT_ALIGN_CENTER} )
  Misc.stopwatch.gui.buttonStartStop = Display.CreateButton(guiName.."StopWatchStartStop", ctrl, {3,4} , line, {text = labelStartStop, texture = "esoui/art/cadwell/cadwell_indexicon_gold", handler = function() Misc.OnStopwatchStartStop() end, })
  Misc.stopwatch.gui.buttonReset = Display.CreateButton(guiName.."StopWatchReset", ctrl, {4,4} , line, {text = "Reset", texture = "esoui/art/cadwell/cadwell_indexicon_silver", handler = function() Misc.OnStopwatchReset() end, })

  line = line + 1
  Display.CreateDivider(ctrl, line)
  line = line + 1

--GetArmoryBuildIcon()
end

---------------------
-- Fix Visual Bugs --
---------------------

function Misc.FixVisuals()
  Misc.TogglePolymorphHelmet()
end
SLASH_COMMANDS["/fixvisuals"] = Misc.FixVisuals

function Misc.TogglePolymorphHelmet()
    local function InvertSetting(setting)
      return setting == "1" and 0 or 1
    end
    local function ApplySetting(setting)
      SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, setting)
    end
    local delay = 100
    local currentSetting = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM)

    zo_callLater( function() ApplySetting( InvertSetting(currentSetting) ) end, delay)
    zo_callLater( function() ApplySetting( currentSetting ) end, 2*delay)
  end

--------------------
-- Undress via WW --
--------------------

ZO_CreateStringId("SI_BINDING_NAME_EXOY_UNDRESS_VIA_WW", "Undress via WW")

function Misc.Undress()
  WizardsWardrobe.Undress()

 local CSA = CENTER_SCREEN_ANNOUNCE
 local params = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
 params:SetText("Undressed")
 params:SetLifespanMS(2500)
 params:MarkQueueImmediately(true)
 CSA:AddMessageWithParams(params)

end

------------------------
-- Lock Armory Builds --
------------------------
-- reference: ArmoryStyleManager



---------------
-- StopWatch --
---------------



function Misc.OnUpdateStopwatch()
  local store = ExoY.store.misc.stopwatch
  local label = Misc.stopwatch.gui.label
  local duration
  if store.running then
    duration = GetTimeStamp() - store.lastStart + store.timeSaved
  else
    duration = store.timeSaved
  end
  local durationTable = Lib.ConvertDuration(duration*1000) 
  label:SetText( zo_strformat("<<1>>:<<2>>:<<3>>", durationTable.hour, string.format("%02d", durationTable.minute), string.format("%02d", durationTable.second) ) )
end

function Misc.OnStopwatchStartStop()
  local store = ExoY.store.misc.stopwatch
  if store.running then
    ExoY.chat.Debug("Stopwatch stopped")
    store.timeSaved = GetTimeStamp() - store.lastStart
  else
    ExoY.chat.Debug("Stopwatch started")
    store.lastStart = GetTimeStamp()
  end
  store.running = not store.running
  Misc.stopwatch.gui.buttonStartStop.label:SetText(store.running and "Pause" or "Resume")
end

function Misc.OnStopwatchReset()
  ExoY.chat.Debug("Stopwatch reset")
  ExoY.store.misc.stopwatch.timeSaved = 0
  ExoY.store.misc.stopwatch.lastStart = GetTimeStamp()
  if not ExoY.store.misc.stopwatch.running then
    Misc.stopwatch.gui.buttonStartStop.label:SetText("Start")
  end
end



-------------------------------------
-- Search for Items on TTC-Website -- --TODO check for ui?!
-------------------------------------

function Misc.SearchForItemOnTTCWebsite()
  local function Open_TTC_URL( itemLink )
    local fullItemName = zo_strformat( "<<1>>", GetItemLinkName( itemLink) )
    local stringSplit = {}
    local words = 0
    for str in string.gmatch(fullItemName, "([^".."%s".."]+)") do
            table.insert(stringSplit, str)
            words = words + 1
    end
    local urlItemName = ""
    for word, str in pairs(stringSplit) do
      urlItemName = urlItemName..str
      if word < words then
        urlItemName = urlItemName.."+"
      end
    end
    local urlStart = "https://eu.tamrieltradecentre.com/pc/Trade/SearchResult?SearchType=Sell&ItemID=&ItemNamePattern="
    local urlEnd = "&ItemCategory1ID=&ItemTraitID=&ItemQualityID=&IsChampionPoint=false&LevelMin=&LevelMax=&MasterWritVoucherMin=&MasterWritVoucherMax=&AmountMin=&AmountMax=&PriceMin=&PriceMax="
    local url = urlStart..urlItemName..urlEnd
    RequestOpenUnsafeURL( url )
  end

  -- Adds Option for Item Links
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, function(link, button, _, _, linkType, ...)
        if button == MOUSE_BUTTON_INDEX_RIGHT and linkType == ITEM_LINK_TYPE then
      		zo_callLater(function()
      			AddCustomMenuItem("Search on TTC-Website" , function()
      				Open_TTC_URL( link )
      			end, MENU_ADD_OPTION_LABEL)
      			ShowMenu()
      		end, 50)
      	end
    end )

  -- Adds Option in Inventory
  if LibCustomMenu then
   LibCustomMenu:RegisterContextMenu(function(inventorySlot)
     local bagId, slotId = ZO_Inventory_GetBagAndIndex(inventorySlot)
     AddCustomMenuItem("Search on TTC-Website" , function() Open_TTC_URL( GetItemLink(bagId, slotId) ) end)
     ShowMenu()
   end)
  end
end


-------------------------
-- Collection Progress --
-------------------------

function Misc.UpdateCollectionProgress()
  local name = Misc.name.."CollectionProgress"
  local function Initialize()
    local win = ExoY.window:CreateTopLevelWindow( name.."Win")
    win:ClearAnchors()
    win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 2430, 135)
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)
    win:SetMovable(false)
    win:SetDimensions(70,25)
    win:SetHidden(true)

    local frag = ZO_HUDFadeSceneFragment:New( win )
    local scene = SCENE_MANAGER:GetScene("itemSetsBook")
    scene:AddFragment( frag )

    local label = ExoY.window:CreateControl( name.."label", win, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, win , TOPLEFT, 0, 0)
    label:SetColor(1,1,1,1)
    label:SetFont(ExoY.GetFont("normal"))

    return label
  end

  local function UpdateCollectionProgressGui()
  	local collected = 0
  	local total = 0
  	local setId = GetNextItemSetCollectionId()
  	while (setId) do
  		local setSize = GetNumItemSetCollectionPieces(setId)
  		if (setSize > 0) then
  			collected = collected + GetNumItemSetCollectionSlotsUnlocked(setId)
  			total = total + setSize
  		end
  		setId = GetNextItemSetCollectionId(setId)
  	end
    local percentage = math.floor(collected/total*100)
    Misc.collection:SetText( zo_strformat("<<1>>/<<2>> (<<3>>%)", collected, total, percentage) )
  end

  -- initial check
  if not Misc.collection then
    Misc.collection = Initialize()
    ExoY.EM:RegisterForEvent(name, EVENT_ITEM_SET_COLLECTION_UPDATED, UpdateCollectionProgressGui)
  end

  UpdateCollectionProgressGui()
end

--------------------------
-- Sound on KillingBlow -- TODO MoveToPvP
--------------------------

function Misc.SoundOnKillingBlow()
  local function OnKill(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if GetUnitName("player") == zo_strformat("<<1>>", sourceName) and abilityName ~= "" then
      ExoY.chat.Debug("Killing Blow")
      PlaySound(SOUNDS.LOCKPICKING_UNLOCKED)
    end
  end

  ExoY.EM:RegisterForEvent(Misc.name.."OnKillingBlow", EVENT_COMBAT_EVENT, OnKill)
  ExoY.EM:AddFilterForEvent(Misc.name.."OnKillingBlow", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW)
  ExoY.EM:AddFilterForEvent(Misc.name.."OnKillingBlow", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE , COMBAT_UNIT_TYPE_PLAYER)
end

-------------------------------------
-- Cooldown for CP-Slotable Change --
-------------------------------------

-- if both events happen simultaneously, a cp slotable has been changed
-- added 50ms delay to account for slight delays

function Misc.InitiateCpSlotableChangeCooldown()
  local name = Misc.name.."CpSlotableChangeCooldown"
  local win = ExoY.window:CreateTopLevelWindow( name.."win")
  win:ClearAnchors()
  win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 1270, 110)
  win:SetClampedToScreen(true)
  win:SetMouseEnabled(true)
  win:SetMovable(false)
  win:SetDimensions(70,25)
  win:SetHidden(true)

  local frag = ZO_HUDFadeSceneFragment:New( win )
  CHAMPION_PERKS_SCENE:AddFragment( frag )

  local label = ExoY.window:CreateControl( name.."label", win, CT_LABEL)
  label:ClearAnchors()
  label:SetAnchor(TOPLEFT, win , TOPLEFT, 0, 0)
  label:SetColor(1,0,0,1)
  label:SetFont(ExoY.GetFont("normal"))

  local lastHotbarUpdate = 0
  local cooldownEnd = 0
  ExoY.EM:RegisterForEvent(name.."HotbarsUpdated", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function() lastHotbarUpdate = GetGameTimeMilliseconds() end)

  local function OnChampionPurchaseResult()
    if GetGameTimeMilliseconds() - lastHotbarUpdate > 100 then return end
    ExoY.chat.Debug("cp slotable changed")
    cooldownEnd = GetGameTimeMilliseconds() + 30000
    win:SetHidden(false)
    local function OnCooldown()
      local timeRemaining = GetGameTimeMilliseconds() - cooldownEnd
      if timeRemaining < 0 then
        local output = tostring( math.floor((-1)*timeRemaining/1000) )
        label:SetText( output )
        ExoY.characterInfo.cp.cooldown:SetText( output )
      else
        ExoY.characterInfo.cp.cooldown:SetText( "" )
        label:SetText( "" )
        ExoY.EM:UnregisterForUpdate(name.."cooldown")
      end
    end
    ExoY.EM:RegisterForUpdate(name.."cooldown", 500, function() OnCooldown() end)
  end

  ExoY.EM:RegisterForEvent(name.."CpPurchaseResult", EVENT_CHAMPION_PURCHASE_RESULT, function() zo_callLater(function() OnChampionPurchaseResult() end, 10) end)
end

---------------
-- Auto Bind --
---------------

function Misc.AutoBindItems()
  function OnSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    local itemLink = GetItemLink(bagId, slotIndex)
    if IsItemLinkCrafted(itemLink) then return end
    if not GetItemLinkSetInfo(itemLink) then return end --checking *hasSet
    if IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) then return end
    BindItem(bagId, slotIndex)
  end
  ExoY.EM:RegisterForEvent(Misc.name.."AutoBind", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdate)
  ExoY.EM:AddFilterForEvent(Misc.name.."AutoBind", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
  ExoY.EM:AddFilterForEvent(Misc.name.."AutoBind", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
end
