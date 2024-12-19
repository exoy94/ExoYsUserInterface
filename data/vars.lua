ExoY = ExoY or {}
ExoY.vars = ExoY.vars or {}
local Variables = ExoY.vars

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
