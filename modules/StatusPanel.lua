ExoY = ExoY or {}
ExoY.statusPanel = ExoY.statusPanel or {}

local Status = ExoY.statusPanel
local Lib = LibExoYsUtilities
local EM = GetEventManager()

function Status.Initialize()
  Status.name = ExoY.name.."StatusPanel"
  Status.gui = Status.CreateGui()
  EM:RegisterForUpdate(Status.name.."Update", 500, Status.OnUpdate)
end

function Status.OnInitialPlayerActivated()
  local func = Status.endeavorUpdate
  if type(func) == "function" then func() end
end


function Status.OnUpdate()
  Status.gui.clock:SetText( GetTimeString() )

  local latency = GetLatency()
  Status.gui.latency:SetText( latency )
  if latency > 240 then
    Status.gui.latency:SetColor(1,0,0,1)
    Status.gui.latencyIcon:SetColor(1,0,0,1)
    Status.gui.latencyIcon:SetTexture("/esoui/art/campaign/campaignbrowser_lowpop.dds")
  elseif latency > 120 then
    Status.gui.latency:SetColor(1,0.7,0,1)
    Status.gui.latencyIcon:SetColor(1,0.7,0,1)
    Status.gui.latencyIcon:SetTexture("/esoui/art/campaign/campaignbrowser_medpop.dds")
  else
    Status.gui.latency:SetColor(1,1,1,1)
    Status.gui.latencyIcon:SetColor(1,1,1,1)
    Status.gui.latencyIcon:SetTexture("/esoui/art/campaign/campaignbrowser_hipop.dds")
  end

  local frameRate = math.ceil(GetFramerate())
  Status.gui.frames:SetText( frameRate )
  if frameRate < 20 then
    Status.gui.frames:SetColor(1,0,0,1)
    Status.gui.framesIcon:SetColor(1,0,0,1)
  elseif frameRate < 40 then
    Status.gui.frames:SetColor(1,0.7,0,1)
    Status.gui.framesIcon:SetColor(1,0.7,0,1)
  else
    Status.gui.frames:SetColor(1,1,1,1)
    Status.gui.framesIcon:SetColor(1,1,1,1)
  end
end


function Status.CreateGui()
  local name = Status.name

  local win = ExoY.WM:CreateTopLevelWindow( name.."Window" )
  win:SetClampedToScreen(true)
  win:SetMouseEnabled(true)
  win:ClearAnchors()
  win:SetAnchor( CENTER, GuiRoot, TOP, 0, 12)
  win:SetDimensions( 200 , 40 )
  win:SetHidden(false)

  local ctrl = ExoY.WM:CreateControl(name.."Control", win, CT_CONTROL )
  ctrl:ClearAnchors()
  ctrl:SetAnchor(CENTER , win, CENTER, 0, 0 )
  ctrl:SetDimensions( 120, 40)


  local back = ExoY.WM:CreateControl(name.."Back", ctrl, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(CENTER, ctrl, CENTER, -70, 0)
  back:SetDimensions(930,40)
  back:SetCenterColor(0,0,0,0.8)
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil, 2,2,2)


  local clock = ExoY.WM:CreateControl(name.."Clock", ctrl, CT_LABEL)
  clock:ClearAnchors()
  clock:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
  clock:SetColor( 1, 1, 1, 1 )
  clock:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  clock:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
  clock:SetFont( Lib.GetFont(30) )

  local function CreateInfo( name, offsetX, texture, size, gap)
    local icon = ExoY.WM:CreateControl(name.."icon", ctrl, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchor( CENTER, ctrl, CENTER, offsetX, 0)
    icon:SetDimensions(size , size)
    icon:SetTexture( texture )

    local label = ExoY.WM:CreateControl(name.."label", ctrl, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor( LEFT, icon, RIGHT, gap and gap or 0, 0)
    label:SetColor( 1, 1, 1, 1 )
    label:SetFont( Lib.GetFont() )
    label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    label:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
    --label:SetDimensions(80,50)
    return label, icon
  end

  -- left side
  local offsetX = 0

  offsetX = offsetX - 100
  local frames, framesIcon = CreateInfo(name.."Frames", offsetX, "esoui/art/miscellaneous/rateicon.dds", 25)

  offsetX = offsetX - 80
  local bank = CreateInfo(name.."bank", offsetX, "esoui/art/icons/housing_nor_duc_chest005.dds", 35, 5)
  local function UpdateBankSlots()
    bank:SetText( GetNumBagFreeSlots(BAG_SUBSCRIBER_BANK)+GetNumBagFreeSlots(BAG_BANK) )
  end
  UpdateBankSlots()
  EM:RegisterForEvent( name.."SubBankUpdate",  EVENT_INVENTORY_SINGLE_SLOT_UPDATE, UpdateBankSlots)
  EM:AddFilterForEvent( name.."SubBankUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_SUBSCRIBER_BANK)
  EM:RegisterForEvent( name.."BankUpdate",  EVENT_INVENTORY_SINGLE_SLOT_UPDATE, UpdateBankSlots)
  EM:AddFilterForEvent( name.."BankUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BANK)


  offsetX = offsetX - 80
  local crystals = CreateInfo(name.."Crystals", offsetX, "/esoui/art/currency/icon_seedcrystal.dds", 25, 5)
  crystals:SetText( GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT ) )

  offsetX = offsetX - 75
  local keys = CreateInfo(name.."Keys", offsetX, "/esoui/art/icons/undaunted_gold_key_01.dds", 25, 5)
  keys:SetText( Lib.GetFormattedCurrency(GetCurrencyAmount(CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_ACCOUNT ) ) )

  offsetX = offsetX - 110
  local endeavor = CreateInfo(name.."Endeavor", offsetX, "/esoui/art/currency/currency_seals_of_endeavor_64.dds", 25, 5)
  local function OnEndeavorUpdate()
    local dailyDone = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_DAILY)
    local dailyLimit = GetTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_DAILY)
    local weeklyDone = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)
    local weeklyLimit = GetTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_WEEKLY)
    endeavor:SetText( zo_strformat("<<1>>/<<2>> - <<3>>/<<4>>", dailyDone, dailyLimit, weeklyDone, weeklyLimit) )
  end
  Status.endeavorUpdate = OnEndeavorUpdate
  EM:RegisterForEvent(name.."EndeavorProgress", EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, OnEndeavorUpdate)
  EM:RegisterForEvent(name.."EndeavorReset", EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED, OnEndeavorUpdate)

  offsetX = offsetX - 60
  local eventTicket = CreateInfo(name.."EventTickets", offsetX, "/esoui/art/currency/currency_eventticket.dds", 30)
  eventTicket:SetText( GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT ) )

  -- right side
  offsetX = 0

  offsetX = offsetX + 80
  local latency, latencyIcon = CreateInfo(name.."Latency", offsetX, "/esoui/art/campaign/campaignbrowser_hipop.dds", 30)

  offsetX = offsetX + 75
  local bag = CreateInfo(name.."Bag", offsetX, "esoui/art/icons/collectible_crafting_bag.dds", 30)
  local function OnBagUpdate()
    bag:SetText( GetNumBagFreeSlots(BAG_BACKPACK) )
  end
  OnBagUpdate()
  EM:RegisterForEvent( name.."BagUpdate",  EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnBagUpdate)
  EM:AddFilterForEvent( name.."BagUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BACK_BAGPACK)
  EM:RegisterForEvent( name.."BuybackUpdate", EVENT_UPDATE_BUYBACK, OnBagUpdate )

  offsetX = offsetX + 75
  local gold = CreateInfo(name.."Gold", offsetX, "esoui/art/loot/icon_goldcoin_pressed.dds", 30)
  gold:SetText( Lib.GetFormattedCurrency(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER ) ) )

  offsetX = offsetX + 90
  local alliance = CreateInfo(name.."Alliance", offsetX, "esoui/art/icons/icon_alliancepoints.dds", 30, 5)
  alliance:SetText( Lib.GetFormattedCurrency(GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER ) ) )

  offsetX = offsetX + 90
  local location = CreateInfo(name.."Location", offsetX, "esoui/art/mappins/battlegrounds_mobilecapturepoint_pin_neutral_c.dds", 30)
  local function SetLocationString()
    local output = ""
    local zone = GetUnitZone("player")
    local subZone = GetPlayerLocationName()
    if zone == subZone then
      output = zone
    else
      output = zo_strformat("<<1>> - <<2>>", zone , subZone)
    end
    location:SetText( output )
  end
  SetLocationString()
  EM:RegisterForEvent( name.."ZoneChange", EVENT_ZONE_CHANGED, SetLocationString )
  EM:RegisterForEvent( name.."Activated", EVENT_PLAYER_ACTIVATED, SetLocationString )


  -- Currency Update
  local function OnCurrencyUpdate(event, currencyType, currencyLocation, newAmount, oldAmount, reason)
    if currencyLocation == CURRENCY_LOCATION_ACCOUNT then
      if currencyType == CURT_EVENT_TICKETS then
        eventTicket:SetText( newAmount )
      elseif currencyType == CURT_CHAOTIC_CREATIA then
        crystals:SetText( newAmount )
      elseif currencyType == CURT_UNDAUNTED_KEYS then
        keys:SetText( Lib.GetFormattedCurrency(newAmount) )
      end
    elseif currencyLocation == CURRENCY_LOCATION_CHARACTER then
      if currencyType == CURT_MONEY then
        gold:SetText( Lib.GetFormattedCurrency(newAmount) )
      elseif currencyType == CURT_ALLIANCE_POINTS then
        alliance:SetText( Lib.GetFormattedCurrency(newAmount) )
      end
    end
  end
  EM:RegisterForEvent( name.."CurrencyChange", EVENT_CURRENCY_UPDATE, OnCurrencyUpdate)

  return {clock = clock, latency = latency, latencyIcon = latencyIcon, frames = frames, framesIcon= framesIcon}
end
