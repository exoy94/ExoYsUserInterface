ExoyUI = ExoyUI or {}

local EM = GetEventManager()

ExoyUI.widgets = ExoyUI.widgets or {}
local Widgets = ExoyUI.widgets


function Widgets.Initialize()
  Widgets.name = ExoyUI.name.."Widgets"

  Widgets.CreateDisplayTab()
  Widgets.SetupDisplayHeaderInfo()



end


function Widgets.CreateDisplayTab()
  local tabSettings = {
    ["name"] = Widgets.name,
    ["number"] = 4,
    ["icon"] = "esoui/art/treeicons/tools",
    ["header"] = "Widgets",
  }
  local guiName = Widgets.name.."Tab"

  local Display = ExoyUI.display
  local ctrl = Display.AddTab( tabSettings )


  local Display = ExoyUI.display
  local line = 0

  -- Utilities
  line = line + 1
  local function OnScry()
    UseCollectible(8006)
    Widgets.scry.label:SetColor(1,0,0,0.7)
    zo_callLater(function() Widgets.scry.label:SetColor(1,1,1,0.7) end, 20000)
  end
  Widgets.scry = Display.CreateButton(guiName.."scry", ctrl, {1,3} , line, {text = "Scrying", texture = "esoui/art/journal/journal_tabicon_antiquities", handler = OnScry, })

  --Display.CreateButton(guiName.."FixVisual", ctrl, {3,3}, line, {text = "Fix Visual", texture = "esoui/art/help/help_tabicon_feedback", handler = ExoY.misc.FixVisuals})

  line = line + 0.85
  Display.CreateDivider(ctrl, line)
  line = line + 0.85

  --Display.CreateButton(guiName.."primaryHouse", ctrl, {1,2} , line, {text = "Psijic Villa", texture = "esoui/art/collections/collections_tabicon_housing", handler = function() RequestJumpToHouse( GetHousingPrimaryHouse() )end, })
  Display.CreateButton(guiName.."villa", ctrl, {1,4}, line, {text = "Villa", texture="esoui/art/collections/collections_tabicon_housing", handler = function() RequestJumpToHouse(62) end})
  Display.CreateButton(guiName.."cavern", ctrl, {2,4}, line, {text = "Cavern", texture="esoui/art/collections/collections_tabicon_housing", handler = function() RequestJumpToHouse(41) end})
  Display.CreateButton(guiName.."workshop", ctrl, {3,4}, line, {text = "Workshop", texture="esoui/art/collections/collections_tabicon_housing", handler = function() JumpToSpecificHouse("@PALIMPSESTE", 47) end}) --@Ireniicus (46); @PALIMPSESTE (47)

  line = line + 0.85
  Display.CreateDivider(ctrl, line)
  line = line + 0.85

  --Display.CreateButton(guiName.."armory", ctrl, {1,3} , line,  {text = "Ghrasharog", texture = "esoui/art/collections/collections_tabicon_itemsets" , collectible = 9745 })
  Display.CreateButton(guiName.."banker", ctrl, {1,2} , line,  {text = "Tythis Andromo", texture = "esoui/art/inventory/inventory_tabicon_container" , collectible = 267 })
  Display.CreateButton(guiName.."merchant", ctrl, {2,2}, line, {text = "Nuzhimeh", texture = "esoui/art/vendor/vendor_tabicon_sell", collectible = 301 })
  line = line + 1
  Display.CreateButton(guiName.."armory", ctrl, {1,2} , line,  {text = "Ghrasharog", texture = "esoui/art/inventory/inventory_tabicon_armorheavy" , collectible = 9745 })
  Display.CreateButton(guiName.."decon", ctrl, {2,2}, line, {text = "Giladil", texture = "esoui/art/crafting/enchantment_tabicon_deconstruction", collectible = 10184 })

  --line = line + 0.85
  --Display.CreateDivider(ctrl, line)
  --line = line + 0.85
  --Display.CreateButton(guiName.."bastian", ctrl, {1,2} , line, {text = "Bastian Hallix", texture = "esoui/art/companion/keyboard/category_u30_allies", collectible = 9245 })
  --Display.CreateButton(guiName.."isobel", ctrl, {2,2} , line,  {text = "Isobel Veloise", texture = "esoui/art/companion/keyboard/category_u30_allies", collectible = 9912})
  --line = line + 1
  --Display.CreateButton(guiName.."mirri", ctrl, {1,2} , line,  {text = "Mirri Elandis", texture = "esoui/art/companion/keyboard/category_u30_allies", collectible = 9353})
  --Display.CreateButton(guiName.."ember", ctrl, {2,2} , line,  {text = "Ember", texture = "esoui/art/companion/keyboard/category_u30_allies", collectible = 9911})

  line = line + 0.85
  Display.CreateDivider(ctrl, line)
  line = line + 0.85

  -- addon interfaces
  local function AddonMissing( addon )
    addon.button:SetEnabled(false)
    addon.button:SetNormalTexture("esoui/art/collections/collections_categoryicon_locked_up.dds")
    addon.label:SetColor(1,0,0,0.7)
  end
  local addon
  local addonTexture = "esoui/art/collections/collections_categoryicon_unlocked"


  addon = Display.CreateButton(guiName.."IIfA", ctrl, {1,2} , line, {text = "Inventory Insight", texture = addonTexture, handler = function() IIfA:ToggleInventoryFrame() end, })
  if not IIfA then AddonMissing( addon ) end
  addon = Display.CreateButton(guiName.."Traitbuddy", ctrl, {2,2} , line,  {text = "Traitbuddy", texture = addonTexture, handler = function() TraitBuddy.ui:Toggle() end, })
  if not TraitBuddy then AddonMissing( addon ) end

  line = line + 1
  addon = Display.CreateButton(guiName.."USPF", ctrl, {1,2} , line, {text = "Skillpoint Finder", texture = addonTexture, handler = function() USPF:ToggleWindow() end, })
  if not USPF then AddonMissing( addon ) end
  addon = Display.CreateButton(guiName.."CMX", ctrl, {2,2} , line, {text = "Combat Metrics", texture = addonTexture, handler = function() CombatMetrics_Report:Toggle() end, })
  if not CMX then AddonMissing( addon ) end

  line = line + 1
  addon = Display.CreateButton(guiName.."Wizard", ctrl, {1,2} , line,  {text = "Wizard Wardrobe", texture = addonTexture, handler = function() SLASH_COMMANDS["/wizard"]() end, })
  if not WizardsWardrobe then AddonMissing( addon ) end
  addon = Display.CreateButton(guiName.."TBUG", ctrl, {2,2} , line, {text = "Mer Torchbug", texture = addonTexture, handler = function() TBUG.slashCommand("addons") end, })
  if not TBUG then AddonMissing( addon ) end
  --/script TBUG.slashCommand("addons")
  --addon = Display.CreateButton(guiName.."WritWorthy", ctrl, {2,2} , line,  {text = "WritWorthy", texture = addonTexture, handler = function() WritWorthyUI_ToggleUI() end, })
  --if not WritWorthy then AddonMissing( addon ) end

  --line = line + 1
  --Display.CreateDivider(ctrl, line)

  -- Special Mementos / Emotes
  --line = line + 1
  --Display.CreateButton(guiName.."dawnbringer", ctrl, {1,2} , line, {text = "Dawnbringer", texture = "esoui/art/campaign/campaign_tabicon_leaderboard", collectible = 7862, })
  --Display.CreateButton(guiName.."esraj", ctrl, {2,2} , line, {text = "Esraj", texture = "esoui/art/emotes/emotes_indexicon_entertain", emote = 271, }) --collectible = 6360

  --line = line + 1
  --Display.CreateButton(guiName.."frostSentinel", ctrl, {1,2} , line, {text = "Frost Sentinel", texture = "esoui/art/campaign/campaign_tabicon_leaderboard", collectible = 8883, })
  --Display.CreateButton(guiName.."qanun", ctrl, {2,2} , line, {text = "Qanun", texture = "esoui/art/emotes/emotes_indexicon_entertain", emote = 272, }) --collectible = 8653


end

-------------------------
-- Display Header Info --
-------------------------

--TODO add exp and eventBuff
function Widgets.SetupDisplayHeaderInfo()

  local esologIndicatorSettings =
    {
        name = "esolog",
        hidden = not IsEncounterLogEnabled(),
        texture = "esoui/art/hud/trespassing_eye-red.dds",
        offsetX = 297,
        offsetY = -9,
        dimensionX = 50,
        dimensionY = 50,
    }
  local esologIndicator = ExoyUI.display.AddToHeader( esologIndicatorSettings )

  -- Hook into encounterlog toogle and update indicator accordingly
  ZO_PostHook("SetEncounterLogEnabled", function()
    esologIndicator:SetHidden( not IsEncounterLogEnabled() )
    return false
  end)

end
