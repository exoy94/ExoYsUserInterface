ExoY = ExoY or {}
ExoY.dev = ExoY.dev or {}

local Development = ExoY.dev

function Development.DecodeEventId( var )
  local eventList = {
    [EVENT_COMBAT_EVENT] = "combat event", --131106 or 131107
    [EVENT_EFFECT_CHANGED] = "effect changed", --131151
  }
  return eventList[var] or var
end

function Development.DecodeChangeType( var )
  local changeTypeList = {
    [EFFECT_RESULT_GAINED] = "gained", --1
    [EFFECT_RESULT_FADED] = "faded", --2
    [EFFECT_RESULT_UPDATED] = "updated", --3
    [EFFECT_RESULT_FULL_REFRESH] = "full refresh", --4
    [EFFECT_RESULT_TRANSFER] = "transfer", --5
  }
  return changeTypeList[var] or var
end

function Development.DecodeActionResult( var )
  local actionResultList = {
    [ACTION_RESULT_DAMAGE] = "damage", -- 1
    [ACTION_RESULT_CRITICAL_DAMAGE] = "critical damage", --2
    [ACTION_RESULT_BEGIN] = "begin", --2200 (esolog casts?)
    [ACTION_RESULT_STUNNED] = "stunned", --2020
    [ACTION_RESULT_ABSORBED] = "absorbed", --2120
    [ACTION_RESULT_EFFECT_GAINED] = "gained", --2240
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = "gained duration", --2245
    [ACTION_RESULT_EFFECT_FADED] = "faded", --2250
    [ACTION_RESULT_ABILITY_ON_COOLDOWN] = "ability on cooldown", --2080
  }
  return actionResultList[var] or var
end

function Development.DecodeBuffType( var )
  local buffTypeList = {
    [BUFF_TYPE_NONE] = "none", --0
    [BUFF_TYPE_MINOR_BRUTALITY] = "minor brutality", --1
    [BUFF_TYPE_MAJOR_BRUTALITY] = "major brutality", --2
    [BUFF_TYPE_MINOR_SAVAGERY] = "minor savagery", --3
    [BUFF_TYPE_MAJOR_SAVAGERY] = "major savagery", --4
    [BUFF_TYPE_MINOR_SORCERY] =  "minor sorcery", --5
    [BUFF_TYPE_MAJOR_SORCERY] = "major sorcery", --6
    [BUFF_TYPE_MINOR_PROPHECY] = "minor prophecy", --7
    [BUFF_TYPE_MAJOR_PROPHECY] = "major prophecy", --8
    [BUFF_TYPE_MINOR_RESOLVE] = "minor resolve", --9
    [BUFF_TYPE_MAJOR_RESOLVE] = "major resolve", --10
    [BUFF_TYPE_MINOR_BRITTLE] = "minor brittle", --11
    [BUFF_TYPE_MAJOR_BRITTLE] = "major brittle", --12
    [BUFF_TYPE_MINOR_FORTITUDE] = "minor fortitude", --13
    [BUFF_TYPE_MAJOR_FORTITUDE] = "major fortitude", --14
    [BUFF_TYPE_MINOR_ENDURANCE] = "minor endurance", --15
    [BUFF_TYPE_MAJOR_ENDURANCE] = "major enduracne", --16
    [BUFF_TYPE_MINOR_INTELLECT] = "minor intellect", --17
    [BUFF_TYPE_MAJOR_INTELLECT] = "major intellect", --18
    [BUFF_TYPE_MINOR_HEROISM] = "minor heroism", --19
    [BUFF_TYPE_MAJOR_HEROISM] = "major heroism", --20
    [BUFF_TYPE_MINOR_MENDING] = "minor mending", --21
    [BUFF_TYPE_MAJOR_MENDING] = "major mending", --22
    [BUFF_TYPE_MINOR_VITALITY] = "minor vitality", --23
    [BUFF_TYPE_MAJOR_VITALITY] = "major vitality", --24
    [BUFF_TYPE_MINOR_EVASION] = "minor evasion", --25
    [BUFF_TYPE_MAJOR_EVASION] = "major evasion", --26
    [BUFF_TYPE_MINOR_PROTECTION] = "minor protection", --27
    [BUFF_TYPE_MAJOR_PROTECTION] = "major protection", --28
    [BUFF_TYPE_MINOR_MAIM] = "minor maim", --29
    [BUFF_TYPE_MAJOR_MAIM] = "major maim", --30
    [BUFF_TYPE_MINOR_DEFILE] = "minor defile", --31
    [BUFF_TYPE_MAJOR_DEFILE] = "major defile", --32
    [BUFF_TYPE_MINOR_MANGLE] = "minor mangle", --33
    [BUFF_TYPE_MAJOR_MANGLE] = "major mangle", --34
    [BUFF_TYPE_MINOR_EXPEDITION] = "minor expedition", --35
    [BUFF_TYPE_MAJOR_EXPEDITION] = "major expedition", --36
    [BUFF_TYPE_EMPOWER] = "empower", --37
    [BUFF_TYPE_MINOR_COWARDICE] = "minor cowardice", --38
    [BUFF_TYPE_MAJOR_COWARDICE] = "major cowardice", --39
    [BUFF_TYPE_MINOR_BREACH] = "minor breach", --40
    [BUFF_TYPE_MAJOR_BREACH] = "major breach", --41
    [BUFF_TYPE_MINOR_BERSERK] = "minor berserk", --42
    [BUFF_TYPE_MAJOR_BERSERK] = "major berserk", --43
    [BUFF_TYPE_MINOR_FORCE] = "minor force", --44
    [BUFF_TYPE_MAJOR_FORCE] = "major force", --45
    [BUFF_TYPE_MINOR_SLAYER] = "minor slayer", --46
    [BUFF_TYPE_MAJOR_SLAYER] = "major slayer", --47
    [BUFF_TYPE_MINOR_COURAGE] = "minor courage", --48
    [BUFF_TYPE_MAJOR_COURAGE] = "major courage", --49
    [BUFF_TYPE_MINOR_TOUGHNESS] = "minor toughness", --50
    [BUFF_TYPE_MINOR_AEGIS] = "minor aegis", --51
    [BUFF_TYPE_MAJOR_AEGIS] = "major aegis", --52
    [BUFF_TYPE_MINOR_GALLOP] = "minor gallop", --53
    [BUFF_TYPE_MAJOR_GALLOP] = "major gallop", --54
    [BUFF_TYPE_MINOR_ENERVATION] = "minor enervation", --55
    [BUFF_TYPE_MINOR_UNCERTAINTY] = "minor uncertainty", --56
    [BUFF_TYPE_MINOR_LIFESTEAL] = "minor lifesteal", --57
    [BUFF_TYPE_MINOR_MAGICKASTEAL] = "minor magickasteal", --58
    [BUFF_TYPE_DEPRECATED_INCREASE_ULT_COST] = "deprecated increase ult cost", --59
    [BUFF_TYPE_MINOR_VULNERABILITY] = "minor vulnerability", --60
    [BUFF_TYPE_MAJOR_VULNERABILITY] = "major vulnerability", --61
    [BUFF_TYPE_MINOR_TIMIDITY] = "minor timidity", --62
    [BUFF_TYPE_MAJOR_TIMIDITY] = "major timidity", --63
  }
  return buffTypeList[var] or var
end

function Development.DecodeCombatUnitType( var )
  local combatUnitTypeList = {
    [COMBAT_UNIT_TYPE_NONE] = "npc", --0
    [COMBAT_UNIT_TYPE_PLAYER] = "player", --1
    [COMBAT_UNIT_TYPE_PLAYER_PET] = "player pet", --2
    [COMBAT_UNIT_TYPE_GROUP] = "group", --3
    [COMBAT_UNIT_TYPE_TARGET_DUMMY] = "target dummy", --4
    [COMBAT_UNIT_TYPE_OTHER] = "other", --5
  }
  return combatUnitTypeList[var] or var
end



function Development.DecodeAbilityActionSlotType( var )
  return var
end

function Development.DecodePowerType( var )
  return var
end

function Development.DecodeDamageType( var )
  return var
end

--[[
function Development.DecodePowerType(number)
  local type = "PowerType"
  if number == POWERTYPE_HEALTH then return feedback(type, number, "health") -- -2
  elseif number == POWERTYPE_INVALID then return feedback(type, number, "invalid") -- -1
  elseif number == POWERTYPE_MAGICKA then return feedback(type, number, "magica") --0
  elseif number == POWERTYPE_WEREWOLF then return feedback(type, number, "werewolf") --1
  elseif number == 2 then return feedback(type, number, "fervor") --2
  elseif number == 3 then return feedback(type, number, "combo") --3
  elseif number == 4 then return feedback(type, number, "power") --4
  elseif number == 5 then return feedback(type, number, "charges") --5
  elseif number == POWERTYPE_STAMINA then return feedback(type, number, "stamina") --6
  elseif number == 7 then return feedback(type, number, "momentum") --7
  elseif number == 8 then return feedback(type, number, "adrenaline") --8
  elseif number == 9 then return feedback(type, number, "finesse") --9
  elseif number == POWERTYPE_ULTIMATE then return feedback(type, number, "ultimate") --10
  elseif number == POWERTYPE_MOUNT_STAMINA then return feedback(type, number, "mount stamina") --11
  elseif number == POWERTYPE_HEALTH_BONUS then return feedback(type, number, "health bonus") --12
  elseif number == POWERTYPE_DAEDRIC then return feedback(type, number, "deadric") -- 13
  else return feedback(type, number, "unknown") end
end

function Development.DecodeActionResult(number) --ActionResultEffekt?
  local type = "ActionResult"
  if number == ACTION_RESULT_DAMAGE then return feedback(type, number, "damage") --1
  elseif number == ACTION_RESULT_CRITICAL_DAMAGE then return feedback(type, type, number, "critical damage") --2
  elseif number == ACTION_RESULT_POWER_ENERGIZE then return feedback(type, number, "power energize") --128
  elseif number == ACTION_RESULT_BEGIN then return feedback(type, number, "begin") --2200
  elseif number == ACTION_RESULT_EFFECT_GAINED then return feedback(type, number, "gained") --2240
  elseif number == ACTION_RESULT_EFFECT_GAINED_DURATION then return feedback(type, number, "gained duration") --2245
  elseif number == ACTION_RESULT_EFFECT_FADED then return feedback(type, number, "faded") --2250
  elseif number == ACTION_RESULT_KILLING_BLOW then return feedback(type, number, "killing blow") --2265
  else return feedback(type, number, "unknown") end
end

function Development.DecodeStatusEffectType(number)
  if number == STATUS_EFFECT_TYPE_NONE then return feedback(number, "none") --0
  elseif number == STATUS_EFFECT_TYPE_ROOT then return feedback(number, "root") --1
  elseif number == STATUS_EFFECT_TYPE_SNARE then return feedback(number, "snare") --2
  elseif number == STATUS_EFFECT_TYPE_BLEED then return feedback(number, "bleed") --3
  elseif number == STATUS_EFFECT_TYPE_POISON then return feedback(number, "poison") --4
  elseif number == STATUS_EFFECT_TYPE_WEAKNESS then return feedback(number, "weakness") --5
  elseif number == STATUS_EFFECT_TYPE_BLIND then return feedback(number, "blind") --6
  elseif number == STATUS_EFFECT_TYPE_NEARSIGHT then return feedback(number, "nearsight") --7
  elseif number == STATUS_EFFECT_TYPE_DISEASE then return feedback(number, "disease") --8
  elseif number == STATUS_EFFECT_TYPE_TRAUMA then return feedback(number, "trauma") --9
  elseif number == STATUS_EFFECT_TYPE_PUNCTURE then return feedback(number, "puncture") --10
  elseif number == STATUS_EFFECT_TYPE_WOUND then return feedback(number, "wound") --11
  elseif number == STATUS_EFFECT_TYPE_DAZED then return feedback(number, "dazed") --12
  elseif number == STATUS_EFFECT_TYPE_SILENCE then return feedback(number, "silence") --13
  elseif number == STATUS_EFFECT_TYPE_PACIFY then return feedback(number, "pacify") --14
  elseif number == STATUS_EFFECT_TYPE_FEAR then return feedback(number, "fear") --15
  elseif number == STATUS_EFFECT_TYPE_MESMERIZE then return feedback(number, "mesmerize") --16
  elseif number == STATUS_EFFECT_TYPE_CHARM then return feedback(number, "charm") --17
  elseif number == STATUS_EFFECT_TYPE_LEVITATE then return feedback(number, "levitate") --18
  elseif number == STATUS_EFFECT_TYPE_STUN then return feedback(number, "stun") --19
  elseif number == STATUS_EFFECT_TYPE_ENVIRONMENT then return feedback(number, "environment") --20
  elseif number == STATUS_EFFECT_TYPE_MAGIC then return feedback(number, "magic") --21
  else return feedback(number, "unknown") end
end

function Development.DecodeAblityType()
  if number == 0 then return feedback(number, "damage")
  elseif number == 2 then return feedback(number, "heal")
  else return feedback(number, "unknown") end
end

function Development.DecodeAbilityActionSlotType(number)
  if number == 0 then return feedback(number, "normal abiity")
  elseif number == 1 then return feedback(number, "weapon attack")
  elseif number == 2 then return feedback(number, "ultimate")
  elseif number == 3 then return feedback(number, "other")
  elseif number == 4 then return feedback(number, "block")
  elseif number == 5 then return feedback(number, "light attack")
  elseif number == 6 then return feedback(number, "heavy attack")
  else return feedback(number, "unknown") end
end

function Development.DecodeDamageType(number)
  if number == 0 then return feedback(number, "none")
  elseif number == 1 then return feedback(number, "generic")
  elseif number == 2 then return feedback(number, "physical")
  elseif number == 3 then return feedback(number, "fire")
  elseif number == 4 then return feedback(number, "shock")
  elseif number == 5 then return feedback(number, "oblivion")
  elseif number == 6 then return feedback(number, "cold")
  elseif number == 7 then return feedback(number, "earth")
  elseif number == 8 then return feedback(number, "magic")
  elseif number == 9 then return feedback(number, "drown")
  elseif number == 10 then return feedback(number, "disease")
  elseif number == 11 then return feedback(number, "poison")
  else return feedback(number, "unknown") end
end
]]
