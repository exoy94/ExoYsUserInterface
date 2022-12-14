ExoY = ExoY or {}
ExoY.combatProtocol = ExoY.combatProtocol or {}

local abilityIgnolist = {
  [4282] = true, -- light attack (dual wield)

  [15385] = true, -- heavy attack (inferno)
  [16165] = true, -- light attack (inferno)
  [16277] = true, -- light attack (ice)
  [16321] = true, -- heavy attack (inferno)
  [17700] = true, -- heavy attack damage bonus
  [18084] = true, -- burning

  [20542] = true, -- prioritize hit
  [20546] = true, -- prioritize hit
  [21230] = true, -- berserker
  [21765] = true, -- purifying light
  [21927] = true, -- minor defile
  [21929] = true, -- poisoned
  [23429] = true, -- heavy attack damage bonus
  [26319] = true, -- combustion
  [26797] = true, -- pucturing sweep
  [26832] = true, -- blessed shards
  [26874] = true, -- blazing spear
  [28408] = true, -- whirlwind

  [29375] = true, -- heavy weapons
  [29597] = true, -- combustion

  [30869] = true, -- absorb
  [30872] = true, -- controlled fury
  [30873] = true, -- dual wield expert
  [30893] = true, -- twin blade and blunt
  [30923] = true, -- hasty retreat
  [30930] = true, -- accuracy
  [30936] = true, -- hawk eye
  [30937] = true, -- long shots
  [30942] = true, -- ranger
  [30948] = true, -- tri focus
  [30957] = true, -- ancient knowledge
  [30962] = true, -- elemental force
  [30965] = true, -- destruction expert
  [30980] = true, -- restoration expert
  [30959] = true, -- ancient knowledge
  [30972] = true, -- cycle of life
  [30981] = true, -- restoration master
  [31759] = true, -- sacred ground
  [34704] = true, -- dark talons
  [34706] = true, -- dark talons
  [34948] = true, -- burning embers
  [34949] = true, -- burning embers
  [35434] = true, -- dark shade
  [36515] = true, -- major defile
  [36908] = true, -- leeching strikes
  [36911] = true, -- leeching strikes
  [36912] = true, -- leeching strikes
  [37009] = true, -- channeled focus
  [38433] = true, -- prioritize hit
  [38660] = true, -- poison injection
  [38690] = true, -- endless hail
  [38788] = true, -- stampede
  [38791] = true, -- stampede
  [38792] = true, -- stampede
  [38819] = true, -- executioner
  [38839] = true, -- rending slashes
  [38840] = true, -- rending slashes
  [38841] = true, -- rending slashes
  [38842] = true, -- rending slashes
  [38891] = true, -- whirling blades
  [38906] = true, -- deadly cloak
  [39056] = true, -- unstable wall of fire
  [39067] = true, -- unstable wall of frost
  [39069] = true, -- unstable wall of frost
  [39070] = true, -- unstable wall of frost
  [39071] = true, -- unstable wall of frost
  [39072] = true, -- unstable wall of frost
  [39666] = true, -- whirling blades

  [40058] = true, -- illustrious healing
  [40059] = true, -- illustrious healing
  [40079] = true, -- radiating regeneration
  [40094] = true, -- combat prayer
  [40096] = true, -- combat prayer
  [40097] = true, -- combat prayer
  [40099] = true, -- combat prayer
  [40244] = true, -- razor caltrops
  [40249] = true, -- spear shards
  [40252] = true, -- razor caldrops
  [40254] = true, -- major breach
  [41958] = true, -- overflowing altar
  [42056] = true, -- inner Rage
  [42057] = true, -- inner Rage
  [42058] = true, -- inner Rage
  [42176] = true, -- bone surge
  [42193] = true, -- bone surge
  [44445] = true, -- blazing spear
  [44549] = true, -- poison injection
  [44828] = true, -- major resolve
  [45050] = true, -- executioner
  [45226] = true, -- major endurance
  [45316] = true, -- adrenaline rush
  [45430] = true, -- heavy weapons
  [45498] = true, -- hasty retreat
  [45428] = true, -- twin blade and blunt
  [45477] = true, -- dual wield expert
  [45478] = true, -- controlled fury
  [45482] = true, -- twin blade and blunt
  [45492] = true, -- accuracy
  [45493] = true, -- ranger
  [45494] = true, -- long shots
  [45497] = true, -- hawk eye
  [45500] = true, -- tri focus
  [45509] = true, -- penetrating magic
  [45512] = true, -- elemental force
  [45518] = true, -- essence drain
  [45513] = true, -- ancient kowledge
  [45514] = true, -- destruction expert
  [45519] = true, -- restoration expert
  [45520] = true, -- cycle of life
  [45521] = true, -- absorb
  [45522] = true, -- absorb
  [45524] = true, -- restoration master
  [46266] = true, -- radiating regeneration
  [48052] = true, -- spear shards / necrotic orb cd

  [50216] = true, -- combustion
  [55183] = true, -- puncturing sweep heal
  [55678] = true, -- undaunted command stamina rest
  [55679] = true, -- undaunted command magicka rest
  [57468] = true, -- radiating regeneration
  [58430] = true, -- constitution
  [58431] = true, -- constitution

  [61507] = true, -- resolving vigor
  [61509] = true, -- resolving vigor
  [61665] = true, -- major brutality
  [61666] = true, -- minor savagery
  [61667] = true, -- major savagery
  [61687] = true, -- major sorcery
  [61689] = true, -- major prophecy
  [61693] = true, -- minor resolve
  [61694] = true, -- major resolve
  [61704] = true, -- minor endurance
  [61705] = true, -- major endurance
  [61707] = true, -- major intellect
  [61711] = true, -- major mending
  [61716] = true, -- major evasion
  [61723] = true, -- minor maim
  [61726] = true, -- minor defile
  [61727] = true, -- major defile
  [61736] = true, -- major expedition
  [61737] = true, -- empower
  [61742] = true, -- minor breach
  [61743] = true, -- major breach
  [61744] = true, -- minor berserk
  [61927] = true, -- relentless focus
  [61928] = true, -- relentless focus
  [61932] = true, -- assassin's scourge
  [61898] = true, -- minor savagery
  [62305] = true, -- dawnbreaker
  [62415] = true, -- major brutality
  [62547] = true, -- deadly cloak
  [62634] = true, -- minor resolve
  [62636] = true, -- minor berserk
  [62800] = true, -- minor sorcery
  [62838] = true, -- unstable wall
  [62840] = true, -- unstable wall of frost
  [63046] = true, -- radiant oppression
  [63511] = true, -- healing combustion
  [63512] = true, -- healing combustion
  [63678] = true, -- major intellect
  [63683] = true, -- major endurance
  [63707] = true, -- catalyst
  [64555] = true, -- major brutality
  [64568] = true, -- major savagery
  [64746] = true, -- blade cloak aoe fx
  [66083] = true, -- major resolve
  [67797] = true, -- healing combustion
  [68368] = true, -- minor maim
  [68581] = true, -- purifying light
  [69168] = true, -- purifying light heal fx
  [69773] = true, -- tri focus

  [72932] = true, -- major intellect
  [72933] = true, -- major sorcery
  [74472] = true, -- dark talons
  [76420] = true, -- major prophecy
  [76426] = true, -- major savagery
  [76916] = true, -- puncturing sweep
  [77922] = true, -- major mending
  [77945] = true, -- major prophecy
  [78855] = true, -- hawk eye

  [80020] = true, -- minor lifesteal
  [86304] = true, -- minor lifesteal
  [88401] = true, -- minor magickasteal
  [88677] = true, -- dark shade


  [93109] = true, -- major slayer
  [93442] = true, -- major slayer
  [94793] = true, -- prioritize hit
  [94973] = true, -- blessed shards
  [94974] = true, -- blessed shards
  [95041] = true, -- healing combustion
  [95042] = true, -- healing combustion
  [95895] = true, -- leeching strikes
  [96696] = true, -- leeching strikes
  [96689] = true, -- leeching strikes
  [99780] = true, -- grand rejuvenation
  [99781] = true, -- grand rejuvenation
  [99851] = true, -- thunderous volley
  [99852] = true, -- thunderous volley
  [99853] = true, -- thunderous volley
  [99854] = true, -- thunderous volley
  [99875] = true, -- crushing wall
  [99876] = true, -- crushing wall

  [100155] = true, -- crushing wall
  [101436] = true, -- executioner
  [103707] = true, -- major expedition
  [103708] = true, -- minor force
  [103879] = true, -- spell orb
  [103966] = true, -- concentrated barrier
  [103968] = true, -- concentrated barrier
  [104338] = true, -- concentrated barrier
  [108939] = true, -- minor maim
  [108940] = true, -- dark shade

  [112166] = true, -- channeled focus
  [113771] = true, -- razor caltrops
  [114841] = true, -- minor protection
  [114886] = true, -- unstable wall of frost
  [116189] = true, -- reusable parts
  [118358] = true, -- minor maim
  [118809] = true, -- enduring undeath
  [118810] = true, -- enduring undeath
  [118811] = true, -- enduring undeath
  [118813] = true, -- enduring undeath
  [118814] = true, -- enduring undeath
  [118352] = true, -- empowering grasp
  [118354] = true, -- empowering grasp
  [118355] = true, -- empowering grasp
  [118356] = true, -- empowering grasp
  [118357] = true, -- empowering grasp
  [118359] = true, -- empowering grasp
  [118369] = true, -- empowering grasp
  [118840] = true, -- intensive mender
  [118843] = true, -- intensive mender
  [118852] = true, -- intensive mender spawn stun
  [119164] = true, -- death gleaning
  [119165] = true, -- death gleaning

  [120612] = true, -- corpse consumption
  [122379] = true, -- necromancer pet 6s tracker
  [122587] = true, -- assassin's scourge
  [123653] = true, -- major evasion
  [123946] = true, -- minor maim
  [124816] = true, -- empowering grasp
  [126474] = true, -- stampede
  [126475] = true, -- stampede
  [125848] = true, -- illustrious healing
  [126537] = true, -- minor endurance

  [131489] = true, -- grand rejuvenation
  [134627] = true, -- minor mending
  [135920] = true, -- roaring opportunist
  [135923] = true, -- major slayer
  [135924] = true, -- roaring opportunist cooldown
  [137006] = true, -- major prophecy

  [143948] = true, -- empoweringgrasp
  [143949] = true, -- empowering grasp
  [143950] = true, -- empowering grasp
  [143951] = true, -- empowering grasp

  [144028] = true, -- burning light
  [145975] = true, -- minor brittle
  [146697] = true, -- minor brittle
  [148797] = true, -- overcharged
  [148798] = true, -- minor magickasteal
  [148803] = true, -- minor breach

  [155167] = true, -- death dealer's fete

  [160047] = true, -- major expedition
  [163401] = true, -- aura of pride
  [163404] = true, -- price of pride
  [168220] = true, -- minor endurance
}

function ExoY.combatProtocol.IsAbilityOnIgnolist( abilityId )
  return abilityIgnolist[abilityId] ~= nil
end
