ExoY = ExoY or {}
ExoY.dev = ExoY.dev or {}

local Development = ExoY.dev

local eventList = {
  --event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow
	[EVENT_COMBAT_EVENT] = {  --131107
		[1] = {param = "result", decoder = "DecodeActionResult"},
		[2] =	{param = "isError"},
		[3] =	{param = "abilityName"},
		[4] =	{param = "abilityGraphic"},
		[5] =	{param = "abilityActionSlotType", decoder = "DecodeAbilityActionSlotType"},
		[6] =	{param = "sourceName"},
		[7] =	{param = "sourceType", decoder = "DecodeCombatUnitType"},
		[8] =	{param = "targetName"},
		[9] =	{param = "targetType", decoder = "DecodeCombatUnitType"},
	 [10] =	{param = "hitValue"},
	 [11] = {param = "powerType", decoder = "DecodePowerType"},
	 [12] =	{param = "damageType", decoder = "DecodeDamageType"},
	 [13] =	{param = "log"},
	 [14] =	{param = "sourceUnitId", decoder = "DecodeSourceUnitId"},
	 [15] =	{param = "targetUnitId", decoder = "DecodeTargetUnitId"},
	 [16] =	{param = "abilityId", decoder = "DecodeAbilityId"},
	 [17] =	{param = "overflow"},
 	},
  --event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType
	[EVENT_EFFECT_CHANGED] = { -- 131153
    [1] = {param = "changeType", decoder = "DecodeChangeType"},
    [2] = {param = "effectSlot"},
    [3] = {param = "effectName"},
    [4] = {param = "unitTag"},
    [5] = {param = "beginTime"},
    [6] = {param = "endTime"},
    [7] = {param = "stackCount"},
    [8] = {param = "iconName"},
    [9] = {param = "buffType", decoder = "DecodeBuffType"},
    [10] = {param = "effectType"},
    [11] = {param = "abilityType", decoder = "DecodeAbilityType"},
    [12] = {param = "statusEffectType", decoder = "DecodeStatusEffectType"},
    [13] = {param = "unitName"},
    [14] = {param = "unitId"},
    [15] = {param = "abilityId", decoder = "DecodeAbilityId"},
    [16] = {param = "sourceType", decoder = "DecodeCombatUnitType"},
	},
}

function Development.GetEventList()
	return eventList
end
