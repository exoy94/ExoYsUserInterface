ExoY = ExoY or {}
ExoY.prototype = ExoY.prototype or {}

local Prototype = ExoY.prototype
local Lib = LibExoYsUtilities

local EM = GetEventManager()
local WM = GetWindowManager()

function Prototype.Initialize()
  Prototype.name = ExoY.name.."Prototype"
ExoY.testVar = '/mama' or '/MaMa' or '/MAMA' 
-- Prototype.ParentTest() 

SLASH_COMMANDS["/hallo"] = function() d("hallo") end


end 


function Prototype.ParentTest() 
  local name = Prototype.name
  local win = WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors() 
  win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

  local ctrl = WM:CreateControl(name.."Window".."_test", win, CT_CONTROL) 
  ctrl:ClearAnchors()
  ctrl:SetAnchor( CENTER, win, CENTER, 0, 0)
  ctrl:SetDimensions(50,50)

  local icon = WM:CreateControl(name.."Icon", ctrl, CT_TEXTURE) 
  icon:ClearAnchors()
  icon:SetAnchor( CENTER, ctrl, CENTER, 0, 0)
  icon:SetDimensions(50,50)
  icon:SetTexture( "/art/fx/texture/arcanist_trianglerune_01.dds" )
  
 -- ExoY.testVar = {win=win, ctrl=ctrl, icon=icon}
end