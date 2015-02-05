
local weaponName = "riflefranco"

local weaponDef = {
	
	name                    = "riflefranco",
	weaponType              = "LaserCannon",
	
	Accuracy=10,
	movingAccuracy=30,
	
	commandfire = true,
	
	--damage
	
	avoidFeature = false,
	
	damage = {
		default = 32,
		heavyarmor = 28,
		lightarmor = 32,
		torrearmor = 26,
	},
--	areaOfEffect            = 10,
	
	--physics

	weaponVelocity          = 1500,
	reloadtime              = 12,
	range                   = 1200,
--	sprayAngle              = 45,
	weaponaceleration       = 850,
	tolerance               = 10000,
	lineOfSight             = true,
	turret                  = true,
	craterMult              = 0,
--	burst                   = 2,
--	burstrate               = 0.08,
	--proyectiles             = 2,
	
	--apperance
	
	duration                = 0.02,
	thickness               = 0.6,
	rgbColor                = [[0.5 0 0.5]],
	--size                    = 0,
	--stages                  = 0,
	intensity               = 1,
	--separation              = 0,
	
	--sounds
	
	soundStart              = "laser_gfx",
	
	collideFriendly=true,
	noSelfDamage= false,
}
return lowerkeys({[weaponName] = weaponDef})