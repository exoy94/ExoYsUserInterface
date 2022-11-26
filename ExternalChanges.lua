Fancy Action Bar:

+ ui.xml: Anchor for Duration: Bottom and Bottom
+ changed bg texture to: textureFile="EsoUI/Art/ActionBar/actionslot_pressed.dds"
+ changed alpha to 1

+ changed UpdateOverlay()

-- Update overlay controls.
function UpdateOverlay(index)
	local overlay = overlays[index]
	if overlay then
		local effect = overlay.effect
		-- Get controls to update.
		local durationControl = overlay:GetNamedChild('Duration')
		local stacksControl = overlay:GetNamedChild('Stacks')
		local bgControl = overlay:GetNamedChild('BG')

		local function Blink(duration)
			local num = math.floor(duration*(-10))
			local interval = 5
			if num%interval == 0 then
				if num/interval % 2 == 0 then
					bgControl:SetHidden(false)
					durationControl:SetText("0")
				else
					bgControl:SetHidden(true)
					durationControl:SetText("")
				end
			end
		end

		if effect then
			-- Update duration.
			local duration = effect.endTime - time()
			--duration = GetActionSlotEffectTimeRemaining(index, index < SLOT_INDEX_OFFSET and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP) / 1000
			if duration > -3 then
				if SV.decimalThreshold > 0 and duration < SV.decimalThreshold then
					if duration < 0 then
						bgControl:SetAlpha(1)
						durationControl:SetColor(unpack(SV.zeroColor))
						Blink( duration )
					else
						bgControl:SetAlpha(0.5)
						bgControl:SetHidden(false)
						durationControl:SetText(strformat('%0.1f', zo_max(0, duration)))
						durationControl:SetColor(unpack(SV.decimalColor))
					end
				else
					bgControl:SetHidden(true)
					durationControl:SetText(zo_max(0, zo_ceil(duration)))
					if duration > 0 then
						durationControl:SetColor(unpack(SV.timerColor))
					else
						durationControl:SetColor(unpack(SV.zeroColor))
					end
				end
				--bgControl:SetHidden(duration <= 0 or not SV.showHighlight)
			else
				bgControl:SetHidden(true)
				durationControl:SetText('')
			end
			-- Update stacks.
			if stacks[effect.id] and stacks[effect.id] > 0 then
				stacksControl:SetText(stacks[effect.id])
			else
				stacksControl:SetText('')
			end
		else
			bgControl:SetHidden(true)
			durationControl:SetText('')
		end
	end
end



-- Add defensive Stance

--config.lua
add to: FancyActionBar.abilityConfig 
	[39163] = {145975}, -- frost pulsar (minor brittle)

FancyActionBar.reflects          = {
  -- to track the reflect / absorb charges.
  -- abilities entered here will be updated with EVENT_COMBAT_EVENT 'OnReflect'.
  [126608] = 38312, -- defensive stance
}


--TODO add to stackMap
-- defensive stance
[126608] = 38312,


-- add before events for stack map

local function OnReflect( _, result, _, aName, _, _, _, _, tName, tType, hit, _, _, _, _, tId, aId)
	if (tType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if SV.debugAll then
		local ts = tostring
		d('===================')
		d(aName..' ('..ts(aId)..') || result: '..ts(result)..' || hit: '..ts(hit))
		d('===================')
	end

	if (FAB.reflects[aId]) then
		if (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
				stacks[FAB.stackMap[aId]] = 1
			elseif result == ACTION_RESULT_EFFECT_FADED then
			stacks[FAB.stackMap[aId]] = 0
		end
	end
end

for i, x in pairs(FAB.reflects) do
EM:RegisterForEvent( NAME .. 'Reflect' .. i, EVENT_COMBAT_EVENT, OnReflect)
EM:AddFilterForEvent(NAME .. 'Reflect' .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, i)

EM:RegisterForEvent( NAME .. 'Reflect' .. x, EVENT_COMBAT_EVENT, OnReflect)
EM:AddFilterForEvent(NAME .. 'Reflect' .. x, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, x, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
end
