ExoyUI = ExoyUI or {}
ExoyUI.smartCast = ExoyUI.smartCast or {}

local SmartCast = ExoyUI.smartCast

ZO_CreateStringId("SI_BINDING_NAME_EXOY_SKILL_BLOCK_OVERWRITE", "Overwrite Skill-Block")

--GetSlotBoundId() to find AbilityId's

local skillId = {
  ["innerFire"] = 39475,
  ["innerRage"] = 42056,
  ["pierceArmor"] = 38250,
  ["frostClench"] = 38989,
  ["revealingFlare"] = 61489,
  ["innerLight"] = 40478,
  ["temporalGuard"] = 103564,
}

function SmartCast.Initialize()
  SmartCast.name = ExoyUI.name.."SmartCast"

  if not LibSkillBlocker then return end

  SmartCast.overwrite = false
  local indicator = ExoyUI.display.AddToHeader(   {
        name = "overwriteSkillBlock",
        hidden = false,
        texture = "esoui/art/hud/broken_weapon.dds",
        offsetX = 0,
        offsetY = -5,
        dimensionX = 40,
        dimensionY = 40,
    })
    function SmartCast.GetOverwriteIndicator()
      return indicator
    end

  SmartCast.Taunt()
  SmartCast.UselessSkills()
end

function SmartCast.ToggleOverwrite()
  SmartCast.overwrite = not SmartCast.IsOverwriteActive()
  SmartCast.GetOverwriteIndicator():SetHidden( SmartCast.overwrite )
end

function SmartCast.IsOverwriteActive()
  return SmartCast.overwrite
end

local doNotTaunt = {
  "Target Skeleton, Humanoid",
  --"Oaxiltso",
  "Flame-Herald Bahsei",
  "Xalvakka",
  "Vigil Statue",
  "Nahviintaas",
  --"Forgotten Archer",
}

local tauntAbilities = {
  "innerRage",
  "innerFire",
  "pierceArmor",
  "frostClench",
}

function SmartCast.Taunt()
  local function TauntBlockCriteria()
    if SmartCast.IsOverwriteActive() then return false end
    local targetName = GetUnitName("reticleover")
    for _, unitName in pairs(doNotTaunt) do
      if unitName == targetName then
        return true
      end
    end
    return false
  end
  for _, ability in pairs(tauntAbilities) do
    if skillId[ability] then
      LibSkillBlocker.RegisterSkillBlock(SmartCast.name..ability, skillId[ability], TauntBlockCriteria)
    end
  end
  LibSkillBlocker.RegisterSkillBlock(SmartCast.name.."BlockInnerRage", skillId.innerRage, TauntBlockCriteria)
  LibSkillBlocker.RegisterSkillBlock(SmartCast.name.."BlockInnerFire", skillId.innerFire, TauntBlockCriteria)
  LibSkillBlocker.RegisterSkillBlock(SmartCast.name.."BlockPiercegArmor", skillId.pierceArmor, TauntBlockCriteria)
  LibSkillBlocker.RegisterSkillBlock(SmartCast.name.."BlockFrostClench", skillId.frostClench, TauntBlockCriteria)
end


function SmartCast.UselessSkills()
  local function SkillBlockCriteria()
    if SmartCast.IsOverwriteActive() then return false end
    return true
  end
  LibSkillBlocker.RegisterSkillBlock(SmartCast.name.."InnerLight", skillId.innerLight, SkillBlockCriteria)
  LibSkillBlocker.RegisterSkillBlock(SmartCast.name.."RevealingFlare", skillId.revealingFlare, SkillBlockCriteria)
  LibSkillBlocker.RegisterSkillBlock(SmartCast.name.."temporalGuard", skillId.temporalGuard, SkillBlockCriteria)
end




--
