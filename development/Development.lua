
ExoY = ExoY or {}
ExoY.dev = ExoY.dev or {}

local Development = ExoY.dev

function Development.Initialize()
	Development.name = ExoY.name.."Development"

	ExoY.prototype.Initialize()
	ExoY.combatProtocol.Initialize()

	Development.CreateDisplayTab()
	Development.CreateDisplayTabForDebug()
end


-------------
-- Display --
-------------

function Development.CreateDisplayTab()

	local tabSettings = {
    ["name"] = Development.name,
    ["number"] = 1,
    ["icon"] = "esoui/art/mainmenu/menubar_journal",
    ["header"] = "Development",
  }
  local guiName = Development.name.."Tab"
  local Display = ExoY.display
  local ctrl = Display.AddTab( tabSettings )
  local line = 0

	line = ExoY.combatProtocol.AddToDisplayTab(guiName, ctrl, line)
	--line = ExoY.prototyp.AddToDisplayTab(guiName, ctrl, line)
end

function Development.CreateDisplayTabForDebug()
	local tabSettings = {
		["name"] = Development.name.."Debug",
		["number"] = 2,
		["icon"] = "esoui/art/mainmenu/menubar_journal",
		["header"] = "Debug",
	}
	local guiName = Development.name.."DebugTab"
	local Display = ExoY.display
	local ctrl = Display.AddTab( tabSettings )
	local line = 0

	line = line + 1
	local Location = {}
	Location.zoneId = Display.CreateLabel(guiName.."ZoneId", ctrl, {1,4}, line, {font = "normal", align = TEXT_ALIGN_CENTER} )
	--Location.zoneIndex = Display.CreateLabel(guiName.."ZoneIndex", ctrl, {2,2}, line, {font = "normal", align = TEXT_ALIGN_CENTER} )
	Location.wX = Display.CreateLabel(guiName.."WorldX", ctrl, {2,4}, line, {font = "normal", align = TEXT_ALIGN_CENTER} )
	Location.wY = Display.CreateLabel(guiName.."WorldY", ctrl, {3,4}, line, {font = "normal", align = TEXT_ALIGN_CENTER} )
	Location.wZ = Display.CreateLabel(guiName.."WorldZ", ctrl, {4,4}, line, {font = "normal", align = TEXT_ALIGN_CENTER} )


	local function UpdateDebugOutput()
			--local zoneIndex = GetUnitZoneIndex("player")
			local zoneId, wX, wY, wZ = GetUnitRawWorldPosition( "player" )
			Location.zoneId:SetText( "Id: "..tostring(zoneId) )
			--Location.zoneIndex:SetText( "ZoneIndex: "..tostring(zoneIndex) )
			Location.wX:SetText( "X: "..tostring(wX) )
			Location.wY:SetText( "Y: "..tostring(wY) )
			Location.wZ:SetText( "Z: "..tostring(wZ) )
	end
	ExoY.EM:RegisterForUpdate(Development.name.."DebugUpdate", 100, UpdateDebugOutput)

	line = line + 2

	--[[

	local flare = Display.CreateLabel(guiName.."flare", ctrl, {1,2}, line, { font = "header", align = TEXT_ALIGN_LEFT})
	line = line + 1
	local flareExecute = Display.CreateLabel(guiName.."flareExecute", ctrl, {1,2}, line, { font = "header", align = TEXT_ALIGN_LEFT})

	local Lib = LibExoYsUtilities

	local function OnFlare(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
		--local params = Lib.GetEventParamter(...)
		--local targetUnitId = params["targetUnitId"]
		--local targetUnitId = Lib.GetEventParameter(...)["targetUnitId"]
		local displayName = GetUnitDisplayName( Lib.GetGroupMemberTagById(targetUnitId) )
		flare:SetText(displayName)
	end

	local function OnFlareExecute(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
		--local targetUnitId = Lib.GetEventParameter(...)["targetUnitId"]
		local displayName = GetUnitDisplayName( Lib.GetGroupMemberTagById(targetUnitId) )
		flareExecute:SetText(displayName)
	end

	ExoY.EM:RegisterForEvent("ExoYFlare", EVENT_COMBAT_EVENT, OnFlare)
	ExoY.EM:AddFilterForEvent("ExoYFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
	ExoY.EM:AddFilterForEvent("ExoYFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 103531)

	ExoY.EM:RegisterForEvent("ExoYFlareExecute", EVENT_COMBAT_EVENT, OnFlareExecute)
	ExoY.EM:AddFilterForEvent("ExoYFlareExecute", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
	ExoY.EM:AddFilterForEvent("ExoYFlareExecute", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 110431)
	]]

	local boss1 = Display.CreateLabel(guiName.."boss1", ctrl, {1,2}, line, { font = "header", align = TEXT_ALIGN_LEFT})
	line = line + 1
	local boss2 = Display.CreateLabel(guiName.."boss2", ctrl, {1,2}, line, { font = "header", align = TEXT_ALIGN_LEFT})

	local function UpdateBossHp()
		--local currentHp, maxHp = GetUnitPower("boss1")
		--boss1:SetText( zo_strformat("<<1>>% (<<2>>)", currentHp*100/maxHp, GetUnitName("boss1") )
		--local currentHp, maxHp = GetUnitPower("boss2" )
		--boss2:SetText( zo_strformat("<<1>>% (<<2>>)", currentHp*100/maxHp, GetUnitName("boss2") )
	end

	ExoY.EM:RegisterForUpdate("ExoYBossHp", 100, UpdateBossHp)

end

--

function Development.DecodeTargetUnitId( var )
	--return ExoY.group.GetDisplayNameByUnitId( var)
	return var
end

function Development.DecodeSourceUnitId( var )
	return var
end

function Development.DecodeAbilityId( var )
	return zo_strformat("<<1>> (<<2>>)", GetAbilityName(var), var)
	--return var
end

----------------
-- Chat Debug --
----------------

function Development.DisplayTestVariable()	--TODO use debug function
	local var = ExoY.testVar
	if type(var)=="table" then
		d("TestVar is Table:")
		for key, cont in pairs(var) do
			d("["..tostring(key).."] "..tostring(cont) )
		end
	elseif type(var) == "string" and var=="" then
    d("TestVar is empty string")
  else
		d(tostring(var))
	end
end

---------------
-- Utilities --
---------------

function Development.SaveItemLink( slotId, bagId )
	slotId = slotId or EQUIP_SLOT_HEAD
	bagId = bagId or BAG_WORN
	local link = GetItemLink(bagId, slotId)
	local _, setName = GetItemLinkSetInfo( link )
	local store = ExoY.store.dev.itemLink
	store.setName = setName
	store.link = link
	ExoY.chat.Debug( "itemLink saved", link )
end

function Development.GetSetId( slotId, bagId )
	slotId = slotId or EQUIP_SLOT_HEAD
	bagId = bagId or BAG_WORN
	local _, setName, _, _, _, setId = GetItemLinkSetInfo(GetItemLink(bagId, slotId))
	ExoY.chat.Debug( setName, setId)
end

function Development.FindCollectibles( str, limit)	--TODO use debug function
  local output = false
  for id=1,type(limit)=="number" and limit or 11000 do
    local collectible = string.lower( GetCollectibleName(id) )
    if string.find(collectible, string.lower(str)) then
      d( zo_strformat("<<1>> <<2>>", id, collectible) )
      output = true
    end
  end
  if not output then d("no collectible found") end
end

function Development.FindAbilityId( str )
	local output = false
	for id=1,type(limit)=="number" and limit or 200000 do
		local abilityName = string.lower( GetAbilityName(id) )
		if string.find(abilityName, string.lower(str)) then
			local descr
			local duration = GetAbilityDuration(id)
			if GetAbilityDescription(id) ~= "" then
				descr = "("..GetAbilityDescription(id)..")"
		  end
			--local minRange, maxRange = GetAbilityRange(id)
			local cd = GetAbilityCooldown(id)
			--local range = zo_strformat("(d:<<1>>-<<2>>)", minRange, maxRange)
		--	ExoY.chat.Debug( zo_strformat("<<1>> (<<2>>) - <<3>> <<4>> <<5>> (r:<<6>>)", id, duration, abilityName, descr, range, GetAbilityRadius(id) ) )
			ExoY.chat.Debug( zo_strformat("<<1>> (<<2>>) - t:<<3>> cd:<<4>> <<5>>", abilityName, id, duration, cd, descr ) )
			output = true
		end
	end
	if not output then d("no ability found") end
end

function Development.FindAbilityName( start, range)
	for id=start, start + range do
		ExoY.chat.Debug( zo_strformat("<<1>>: <<2>>", id, GetAbilityName(id)))
	end
end

function Development.FindAbilityIcon(str)
	local output = false
	for id=1,type(limit)=="number" and limit or 200000 do
		local abilityIcon = string.lower( GetAbilityIcon(id) )
		if string.find(abilityIcon, string.lower(str)) then
			ExoY.chat.Debug( zo_strformat("<<1>> - <<2>> (<<3>>)", id, GetAbilityName(id) ,abilityIcon) )
			output = true
		end
	end
	if not output then d("no ability found") end
end

function Development.FindEmoteIndex( collectibleId )
	--for i = 1, GetNumEmotes() do
	for i = 1, 1000 do
		if GetEmoteCollectibleId(i) == collectibleId then
			ExoY.chat.Debug(i)
		end
	end
end
--[[
local function callAlert(abilityId, text, duration)
  if not CombatAlerts then return end
  local durationMax = duration
  CombatAlerts.CastAlertsStart(abilityId, text , duration, durationMax, {1,0,0,1})
end]]
