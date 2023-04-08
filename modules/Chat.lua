ExoY = ExoY or {}
ExoY.chat = ExoY.chat or {}

local Chat = ExoY.chat
local Lib = LibExoYsUtilities
local EM = GetEventManager() 

local defaultChatEventDebug =
{
    [EVENT_GROUP_TYPE_CHANGED] = true,
    [EVENT_GROUP_INVITE_RESPONSE] = true,
    [EVENT_GROUP_MEMBER_LEFT] = true,
    [EVENT_SOCIAL_ERROR] = true,
    [EVENT_FRIEND_PLAYER_STATUS_CHANGED] = true,
    [EVENT_IGNORE_ADDED] = true,
    [EVENT_IGNORE_REMOVED] = true,
}

-------------
-- KnowHow --
-------------

-- CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_PARTY) --Sets the channel you write in
-- CHAT_SYSTEM:IsMinimized() then CHAT_SYSTEM:Maximize()
-- container.tabGroup:SetClickedButton(container.windows[tabToSet].tab)

function Chat.Initialize()
  Chat.name = ExoY.name.."Chat"
  --increase chat size
  CHAT_SYSTEM.maxContainerWidth, CHAT_SYSTEM.maxContainerHeight = GuiRoot:GetDimensions()
  -- Unregister ZOS handlers for events I dont want notifications of in system chat
  for eventCode, _ in pairs (defaultChatEventDebug) do
      EM:UnregisterForEvent("ChatRouter", eventCode)
  end
  -- changing Chat format
  CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, Chat.MessageFormatter)
  -- loot tracker
  EM:RegisterForEvent(Chat.name.."LootReceived", EVENT_LOOT_RECEIVED, Chat.OnLootReceived)
  -- adding options when clicking on a name in chat
  LibCustomMenu:RegisterPlayerContextMenu(Chat.PlayerContextMenu, MENU_ADD_OPTION_LABEL)

  EM:RegisterForEvent(Chat.name.."AutoGroupInivte", EVENT_CHAT_MESSAGE_CHANNEL, Chat.AutoGroupInvite)

  --TODO Why does ist only work this way?
  -- maybe put in "onPlayer Activated"
  -- pChat; Bindings.lua; 150
  local function OpenSystemTab()
    local tabToSet = 2
    local container=CHAT_SYSTEM.primaryContainer if not container then return end
    if tabToSet<1 or tabToSet>#container.windows then return end
    if container.windows[tabToSet].tab==nil then return end
    container.tabGroup:SetClickedButton(container.windows[tabToSet].tab)
  end
  if ExoY.store.chat.debug then
    --zo_callLater(function() OpenSystemTab() end, 0)
  end
end


function Chat.GetDefaults()
  return { debug = false, }
end

local function isPlayerInSameGuild( playerName )
  local isInSameGuild = false
  for g = 1, GetNumGuilds() do
    for m = 1, GetNumGuildMembers( GetGuildId(g) ) do
      local displayName = GetGuildMemberInfo( GetGuildId(g),m )
      if playerName == GetGuildMemberInfo( GetGuildId(g),m ) then
        JumpToGuildMember( playerName )
        break
      end
    end
  end
  return isInSameGuild
end

function Chat.PlayerContextMenu( playerName )
  ClearMenu()

  -- creates "send mail" options
  AddCustomMenuItem("Send Mail", function()
    SCENE_MANAGER:Show('mailSend')
    zo_callLater( function()
    ZO_MailSendToField:SetText( playerName )
    ZO_MailSendBodyField:TakeFocus()
  end, 250) end)

  --creates fast travel option if player is friend or groupmember or in same guild
  local portToPlayerString = "Port to Player"
  --local fastTravelOption = false
  --if not fastTravelOption then
  if IsFriend(playerName) then
    AddCustomMenuItem( portToPlayerString, function() JumpToFriend( playerName ) end)
      fastTravelOption = true
  elseif ExoY.group.IsPlayerInSameGroup( playerName ) then
    AddCustomMenuItem( portToPlayerString, function() JumpToGroupMember(playerName) end)
  else
    local hasCommonGuild = false
    for g = 1, GetNumGuilds() do
      for m = 1, GetNumGuildMembers( GetGuildId(g) ) do
        local displayName = GetGuildMemberInfo( GetGuildId(g),m )
        if playerName == GetGuildMemberInfo( GetGuildId(g),m ) then
          AddCustomMenuItem( portToPlayerString, function() JumpToGuildMember(playerName) end)
          hasCommonGuild = true
          break
        end
        if hasCommonGuild then
          break
        end
      end
    end
  end
  ShowMenu()
end


----------------
-- Chat Debug --
----------------

local function Output( color, msg, info)
  if info then info = zo_strformat("(<<1>>)", info) end
  d( zo_strformat("<<1>> <<2>>: <<3>> <<4>>", Chat.TimeStringFormatter(true), Lib.ColorString("ExoY UI", color), msg, info ) )
end

function Chat.Debug( ... )
  --if not ExoY.store.chat.debug then return end --TODO better solution
  Output("00FF00", ...)
end

function Chat.Warning( ... )
  Output("FF8800", ...)
end

function Chat.Error( ... )
  Output("FF0000", ...)
end

function Chat.Divider( length )
  if type(length) ~= "number" then
    length = 10
  end
  local divider = ""
  for i=1,length do
    divider = divider.."-"
  end
  return divider
end

---------------
-- Formatter --
---------------

local message_counter = 0

function Chat.TimeStringFormatter( showSeconds )
  local hours, minutes, seconds = GetTimeString():match("([^%:]+):([^%:]+):([^%:]+)")
  if showSeconds then
    return zo_strformat("|c8F8F8F[<<1>>:<<2>>:<<3>>]|r", hours, minutes, seconds)
  else
    return zo_strformat("|c8F8F8F[<<1>>:<<2>>]|r", hours, minutes)
  end
end

local function GetChatTimeString( hideSeconds )
  return Lib.ColorString( zo_strformat("[<<1>>]", Lib.GetTimeString(hideSeconds)), "8F8F8F")
end

function Chat.MessageFormatter(channelId, senderName, message, isCustomerService, senderDisplayName)

  -- channel name
  local channelName
  if channelId == CHAT_CHANNEL_WHISPER_SENT then channelName = " to" end
  if channelId == CHAT_CHANNEL_WHISPER then channelName = " from" end
  if channelId == CHAT_CHANNEL_GUILD_1 then channelName = " ["..GetGuildName(GetGuildId(1)).."]" end
  if channelId == CHAT_CHANNEL_GUILD_2 then channelName = " ["..GetGuildName(GetGuildId(2)).."]"  end
  if channelId == CHAT_CHANNEL_GUILD_3 then channelName = " ["..GetGuildName(GetGuildId(3)).."]"  end
  if channelId == CHAT_CHANNEL_GUILD_4 then channelName = " ["..GetGuildName(GetGuildId(4)).."]"  end
  if channelId == CHAT_CHANNEL_GUILD_5 then channelName = " ["..GetGuildName(GetGuildId(5)).."]"  end
  if channelId == CHAT_CHANNEL_PARTY then channelName = " [".."Party".."]"  end

  local originator = senderDisplayName ~= "" and senderDisplayName or senderName
  -- create player link, except for myself
  if originator ~= GetUnitDisplayName("player") then
    --originator = string.format("|H0:character:%s|h%s|h", originator, originator)
    originator = string.format("|H1:display:%s|h%s|h", originator, originator)
  end

  message_counter = message_counter + 1
  -- assemble chatmessage
  --return zo_strformat("<<1>><<2>> <<3>>: <<4>>", Chat.TimeStringFormatter(), channelName, Lib.ColorString(originator, "FFFFFF"), message)
  --if message_counter > 20 then
      return zo_strformat("<<1>><<2>> <<3>>: <<4>>", GetChatTimeString(true) , channelName, Lib.ColorString(originator, "FFFFFF"), message)
  --elseif message_counter > 10 then
  --  return ""
  --else
  --  return zo_strformat("<<1>><<2>> <<3>>: <<4>>", GetChatTimeString(true) , channelName, Lib.ColorString(originator, "FFFFFF"), message)
  --end
end


-------------------
-- Loot Tracking --
-------------------

function Chat.OnLootReceived(eventCode, receivedBy, itemLink, quantity, itemSound, lootType, lootedByPlayer, isPickpocketLoot, questItemIcon, itemId, isStolen)
  -- early outs
  if lootedByPlayer then return end
  if lootType ~= LOOT_TYPE_ITEM then return end

  -- create player link
  local accountName = ExoY.group.GetGroupMemberAccountNameByUnitName(receivedBy)
  accountName = string.format("|H0:character:%s|h%s|h", accountName, accountName)

  -- only displays items, which are not yet in the sticker book
  local hasSet = GetItemLinkSetInfo(itemLink)
  if hasSet and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) then
    local output = zo_strformat("[<<1>>] by |cFFFFFF<<2>>|r", itemLink, accountName )
    d(output)
  end
end


---------------------
-- AutoGroupInvite --
---------------------

function Chat.AutoGroupInvite(event, channelType, senderName, message, isCustomerService, senderDisplayName)
  if channelType == CHAT_CHANNEL_WHISPER_SENT then return end -- to prevent invite when I send the string to someone via wisper
  if message == "+lbnl" then
    GroupInviteByName(senderName)
  end
end

--------------------
-- Slash Commands --
--------------------

SLASH_COMMANDS["/exoy"] = function(options)
  local commandList = {
    ["chat"] = {Chat.ApplySettings, "applies chat settings"},
    ["testvar"] = {ExoY.dev.DisplayTestVariable, "debug test variable"},
    ["position"] = {ExoY.screen.TogglePositionIndicator, "toggle mouse position"},
    ["settings"] = {ExoY.settings.Apply, "applies game settings"},
    ["centerline"] = {ExoY.screen.ToggleCenterLine, "toggle center line"},
    ["decode"] = {ExoY.combatProtocol.DecodeDatabase, "decode combat protocol database"},
  }

  -- displays all possible commands with description if no additional parameter is given --TODO Design
  if options == "" then
    d( Chat.Divider(10) )
    d( Lib.ColorString("ExoY", "00FF00").." Chat Commands" )
    d( Chat.Divider(10) )
    for command, data in pairs(commandList) do
      d( zo_strformat("/exoy <<1>> - <<2>>", command, data[2]) )
    end
    d( Chat.Divider(10) )
    return
  end

  -- seperate command from potential parameters
  options = string.lower(options)
  local input={}
  for str in string.gmatch(options, "%S+") do
    table.insert(input, str)
  end

  -- check if command is listed
  if not commandList[input[1]] then
    Chat.Error("Command Unknown")
    return
  end

  -- execute selected command
  local func = commandList[input[1]][1]
  if type(func) == "function" then func(input[2])  end
end



----------------
-- Chat Setup --
----------------

function Chat.ApplySettings()
  local chatTabSettings = {
    [1] = {
      name = "Alles",
      categories = {
        CHAT_CATEGORY_ZONE,
        CHAT_CATEGORY_ZONE_ENGLISH,
        CHAT_CATEGORY_ZONE_GERMAN,
        CHAT_CATEGORY_YELL,
        CHAT_CATEGORY_WHISPER_OUTGOING,
        CHAT_CATEGORY_WHISPER_INCOMING,
        CHAT_CATEGORY_SAY,
        CHAT_CATEGORY_PARTY,
        CHAT_CATEGORY_OFFICER_1,
        CHAT_CATEGORY_OFFICER_2,
        CHAT_CATEGORY_OFFICER_3,
        CHAT_CATEGORY_OFFICER_4,
        CHAT_CATEGORY_OFFICER_5,
        CHAT_CATEGORY_EMOTE,
        CHAT_CATEGORY_GUILD_1,
        CHAT_CATEGORY_GUILD_2,
        CHAT_CATEGORY_GUILD_3,
        CHAT_CATEGORY_GUILD_4,
        CHAT_CATEGORY_GUILD_5,
        CHAT_CATEGORY_EMOTE,
      },
    },
    [2] = {
      name = "System",
      categories = {
        CHAT_CATEGORY_SYSTEM,
      },
    },
    [3] = {
      name = "NPC",
      categories = {
        CHAT_CATEGORY_MONSTER_YELL,
        CHAT_CATEGORY_MONSTER_WHISPER,
        CHAT_CATEGORY_MONSTER_SAY,
        CHAT_CATEGORY_MONSTER_EMOTE,
      },
    },
    [4] = {
      name = "Group",
      categories = {
        CHAT_CATEGORY_PARTY,
      },
    },
    [5] = {
      name = "Whisper",
      categories = {
        CHAT_CATEGORY_WHISPER_INCOMING,
        CHAT_CATEGORY_WHISPER_OUTGOING,
      },
    },
  }

  local container = CHAT_SYSTEM.primaryContainer
  local lastTab = 0

  for numTab, data in ipairs(chatTabSettings) do
    -- create Tab, if not enough exist already
    if (GetNumChatContainerTabs(1) < numTab) then
      container:AddWindow(data.name)
    end

    container:SetTabName(numTab, data.name)

    -- removing all categories
    for category = CHAT_CATEGORY_ITERATION_BEGIN, CHAT_CATEGORY_ITERATION_END do
      SetChatContainerTabCategoryEnabled(1, numTab, category, false)
    end
    -- setting the wanted categories
    for _, category in pairs(data.categories) do
      SetChatContainerTabCategoryEnabled(1, numTab, category, true)
    end

    lastTab = numTab
  end

  -- remove surplus tabs
  if lastTab < GetNumChatContainerTabs(1) then
    for i=1, (GetNumChatContainerTabs(1)-lastTab) do
      container:RemoveWindow(GetNumChatContainerTabs(1) ,nil)
    end
  end

  -- set maximum lines in a chat tab to 1000 (pChat; chatTabs.lua; 77)
  -- currently only done to the system channel to reduce performance impact
  container.windows[2].buffer:SetMaxHistoryLines(1000)
end



-- Analyse normal chat
--/script d(IsChatContainerTabCategoryEnabled(1,7,20))
-- testTab (7)
-- 1 to 19 true
-- 20 to 24 false
-- 25 true 40 true
-- 41 to 61 false
-- End Iteration 61
