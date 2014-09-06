function gadget:GetInfo()
	return {
		name      = "Texture preloader",
		desc      = "Loads select models/skins during the pre-game time instead of at game start",
		author    = "Gnome",
		date      = "October 2008",
		license   = "PD",
		layer     = -math.huge,
		enabled   = true
	}
end

if(gadgetHandler:IsSyncedCode()) then
else

function gadget:DrawWorld()
	local seconds = Spring.GetGameSeconds()
	if(seconds == 0) then
		gl.PushMatrix()
		gl.Translate(100, -1000, 100)
		gl.Color(1,1,1,0)
		gl.UnitShape(UnitDefNames["valkyria"].id,0)
		gl.UnitShape(UnitDefNames["militia"].id,0)
		gl.UnitShape(UnitDefNames["taurus"].id,0)
		gl.UnitShape(UnitDefNames["scorpio"].id,0)
		gl.Color(1,1,1,1)
		gl.PopMatrix()
	else
		gadgetHandler:RemoveGadget()
	end
end

end
