
local weaponName = "weaponheiknado2"

local weaponDef = {
	
	name                    = "Melee Test",
	weaponType              = "Melee",
	
	Accuracy=80,
	movingAccuracy=100,
	
	--damage
	
	avoidFeature = false,
	
	damage = {
		default = 240,
		heavyarmor = 160,
		lightarmor = 240,
		torrearmor = 1,
	},
	
	reloadtime = 0,
	range = 100,
	
	soundStart              = "melee_gfx",
}

return lowerkeys({[weaponName] = weaponDef})
