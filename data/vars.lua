ExoY = ExoY or {}
ExoY.vars = ExoY.vars or {}
local Variables = ExoY.vars

Variables.festivals =
  {
    ["jester"] = {collectible = 1167, buff = 91369},
    -- ["anniversary"] = {collectible = 9012, buff = 152514}, -- 2021
    --["anniversary"] = {collectible = 10287, buff = 167846}, -- 2022
    ["anniversary"] = {collectible = 11089, buff = 181478}, -- 2023
    ["witch"] = {collectible = 479, buff = 96118 },
    ["newLife"] = {collectible = 1168, buff = 91449}
  }

-- disciplineIndex as key
-- GetChampionDisciplineId( index )
Variables.cpData =
  {
    [1] = --craft
      {
        iconName = "stamina",
        actionBarName = "world",
      },
    [2] = --warfare
      {
        iconName = "magicka",
        actionBarName = "combat",
      },
    [3] = --fitness
      {
        iconName = "health",
        actionBarName = "conditioning",
      },
  }


Variables.skillId = {
  ["innerFire"] = 39475,
  ["innerRage"] = 42056,
  ["pierceArmor"] = 38250,
  ["frostClench"] = 38989,
  ["revealingFlare"] = 61489,
  ["innerLight"] = 40478,
  ["temporalGuard"] = 103564,
}
