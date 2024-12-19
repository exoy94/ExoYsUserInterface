ExoY = ExoY or {}
ExoY.characterInfo = ExoY.characterInfo or {}

local CharacterInfo = ExoY.characterInfo

local EM = GetEventManager()
local WM = GetEventManager() 

local cpData =   {
  [1] = { iconName = "stamina", actionBarName = "world"}, --craft
  [2] = { iconName = "magicka", actionBarName = "combat"}, --warfare
  [3] = { iconName = "health", actionBarName = "conditioning"}, --fitness
}


function CharacterInfo.Initialize()
  CharacterInfo.name = ExoY.name.."CharacterInfo"

  CharacterInfo.CreateDisplayTab()

  EM:RegisterForEvent(CharacterInfo.name.."CpPurchase", EVENT_CHAMPION_PURCHASE_RESULT, CharacterInfo.OnCpPurchase)
  EM:RegisterForEvent(CharacterInfo.name.."CpGain", EVENT_CHAMPION_POINT_GAINED, CharacterInfo.UpdateCpUnspendPointsIndicator)
  EM:RegisterForEvent(CharacterInfo.name.."ArmoryBuildChange", EVENT_ARMORY_BUILD_OPERATION_STARTED, CharacterInfo.OnArmoryBuildChange)

  LibSetDetection.RegisterForCustomSlotUpdateEvent("ExoYUICharacterInfo", CharacterInfo.OnCustomSlotUpdate)

end


function CharacterInfo.CreateDisplayTab()
  local tabSettings = {
    ["name"] = CharacterInfo.name,
    ["number"] = 5,
    ["icon"] = "esoui/art/treeicons/tutorial_idexicon_adventuring",
    ["header"] = "Character Info",
  }
  local guiName = CharacterInfo.name.."Tab"
  local Display = ExoY.display
  local ctrl = Display.AddTab( tabSettings )
  local line = 0

  line = line + 1
  CharacterInfo.armory = Display.CreateButton(guiName.."armory", ctrl, {1,2}, line, { texture = "esoui/art/treeicons/antiquities_tabicon_eyevea", handler = function() SLASH_COMMANDS["/wizard"]() end, } )
  local wizard = Display.CreateButton(guiName.."wizard", ctrl, {2,2}, line, {text = "setup unkown", texture = "esoui/art/treeicons/antiquities_tabicon_eyevea", handler = function() SLASH_COMMANDS["/wizard"]() end, } )
  if WizardsWardrobe then
    ZO_PostHook(WizardsWardrobe.gui, "SetPanelText", function()
      local pageTextRaw = WizardsWardrobePanelMiddleLabel:GetText()
      local setupText = WizardsWardrobePanelBottomLabel:GetText()
      local pageText = pageTextRaw
      if setupText ~= "@ownedbynico" then
        pageText = zo_strformat("(<<1>>)", pageText)
      end
      wizard.label:SetText( zo_strformat("<<1>> <<2>>", setupText, pageText) )
      return false
    end)
  else
    wizard.button:SetEnabled(false)
    --wizard.label:SetColor(1,0,0,1)
  end

  
  --[[  Displays Equipped Champion Points ]]



  line = line + 0.7
  Display.CreateDivider(ctrl, line)
  CharacterInfo.cp = { ["unspend"]={}, ["slotable"]={} }
  for discipline = 1,3 do
    local cpLine = line + discipline*1.2
    table.insert(CharacterInfo.cp.unspend, discipline, Display.CreateLabel(guiName.."cpUnspend"..tostring(discipline), ctrl, {3,3}, cpLine, {align = TEXT_ALIGN_LEFT} ) )

    local function GetOffsetX(i)
      -- advance + cap after disciplineChange + adjustment
      return  26*(i-1) + math.ceil(i/4)*10 + 70
    end
    for slotable = 1,4 do
      local index = (discipline-1)*4 + slotable
      CharacterInfo.cp.slotable[index] = Display.CreateChampionSlotableIndicator(guiName.."cpSlot"..tostring(index), ctrl, cpData[discipline].actionBarName, index, GetOffsetX(slotable), cpLine+0.6)
    end
  end

  line = line + 2.5
  CharacterInfo.cp.cooldown = Display.CreateLabel(guiName.."cpCooldown", ctrl, {1,1}, line, {font = 20, align = TEXT_ALIGN_LEFT, color = {1,0,0,1} } )


  line = line + 1.8
  Display.CreateDivider(ctrl, line)
  line = line + 1
  CharacterInfo.sets = {}
  CharacterInfo.sets.left = Display.CreateLabel(guiName.."SetsLeft", ctrl, {1,2}, line, {font = 16, align = TEXT_ALIGN_LEFT} )
  CharacterInfo.sets.left:SetDimensions(150, 200)
  CharacterInfo.sets.left:SetVerticalAlignment(TEXT_ALIGN_TOP)
  CharacterInfo.sets.right = Display.CreateLabel(guiName.."SetsRight", ctrl, {2,2}, line, {font = 16, align = TEXT_ALIGN_LEFT} )
  CharacterInfo.sets.right:SetDimensions(150, 200)
  CharacterInfo.sets.right:SetVerticalAlignment(TEXT_ALIGN_TOP)
end

function CharacterInfo.OnPlayerActivated()
  CharacterInfo.UpdateCpSlotableIndicator()
  CharacterInfo.UpdateCpUnspendPointsIndicator()
  CharacterInfo.OnArmoryBuildChange()
end

function CharacterInfo.GetDefaults()
  return { armoryBuild = {} }
end
------------------
-- Armory Build --
------------------

function CharacterInfo.SetLastKnownArmoryBuildNum( numBuild )
  local charId = GetCurrentCharacterId()
  local lastArmoryBuild = ExoY.store.characterInfo.armoryBuild
  lastArmoryBuild[charId] = numBuild
end

function CharacterInfo.GetLastKnownArmoryBuildNum()
  local charId = GetCurrentCharacterId()
  local lastArmoryBuild = ExoY.store.characterInfo.armoryBuild
  return lastArmoryBuild[charId]
end

function CharacterInfo.GetLastKnownArmoryBuildName()
  local lastBuild = CharacterInfo.GetLastKnownArmoryBuildNum()
  if lastBuild == nil then
    return ""
  else
    return GetArmoryBuildName( lastBuild )
  end
end

function CharacterInfo.OnArmoryBuildChange(event, maxBuilds, numBuild)
  if numBuild then
    CharacterInfo.armory.label:SetText( GetArmoryBuildName(numBuild) )
    CharacterInfo.SetLastKnownArmoryBuildNum(numBuild)
  else
    CharacterInfo.armory.label:SetText( CharacterInfo.GetLastKnownArmoryBuildName() )
  end
  zo_callLater(function() CharacterInfo.OnCpPurchase() end, 500)
end

--------------------------------
-- Champion Points Slottables --
--------------------------------

function CharacterInfo.OnCpPurchase()
  CharacterInfo.UpdateCpUnspendPointsIndicator()
  CharacterInfo.UpdateCpSlotableIndicator()
end

function CharacterInfo.UpdateCpUnspendPointsIndicator()
  for index = 1,3 do
    local unspendPoints = GetNumUnspentChampionPoints( GetChampionDisciplineId( index ) )
    local icon = "|t24:24:esoui/art/champion/champion_points_"..cpData[index].iconName.."_icon.dds|t"
    local text = zo_strformat("<<1>> <<2>>", icon,  unspendPoints)
    CharacterInfo.cp.unspend[index]:SetText( text )
  end
end

function CharacterInfo.UpdateCpSlotableIndicator()
  local function UpdateIndicator(index, show)
    CharacterInfo.cp.slotable[index].ring:SetHidden( not show )
    CharacterInfo.cp.slotable[index].star:SetHidden( not show )
  end

  for index=1,12 do
    local cpId = GetSlotBoundId(index, HOTBAR_CATEGORY_CHAMPION)
    local show = true
    if cpId == 0 then show=false end
    UpdateIndicator(index,show)
  end
end

-- Set Changes
function CharacterInfo.OnCustomSlotUpdate()
  local mapBarSet = LibSetDetection.GetBarActiveSetIdMap()
  local completeSets = LibSetDetection.GetCompleteSetsList()
  local equippedSets = LibSetDetection.GetEquippedSetsTable()

  local textLeft = "Body:"
  local textRight = "Front:"
  local textBuffer = "Back:"

  local function AddCompleteSets(string, refTable)
    for k,v in pairs(refTable) do
      string = zo_strformat("<<1>>\n<<2>>", string, v)
    end
    return string
  end
  textLeft = AddCompleteSets(textLeft, mapBarSet["body"])
  textRight = AddCompleteSets(textRight, mapBarSet["frontSpecific"])
  textBuffer = AddCompleteSets(textBuffer, mapBarSet["backSpecific"])

  local function AddUncompleteSets( string, bar)
    for setId, setInfo in pairs(equippedSets) do
      if not completeSets[setId] then
        local numEquipped = setInfo.numEquipped[bar]
        if numEquipped > 0 then
          string = zo_strformat("<<1>>\n<<2>> x <<3>>", string, numEquipped, setInfo.setName)
        end
      end
    end
    return string
  end
  textLeft = AddUncompleteSets(textLeft, "body")
  textRight = AddUncompleteSets(textRight, "front")
  textBuffer = AddUncompleteSets(textBuffer, "back")

  textRight = zo_strformat("<<1>>\n\n<<2>>", textRight, textBuffer)
  CharacterInfo.sets.left:SetText( textLeft )
  CharacterInfo.sets.right:SetText( textRight )
end
