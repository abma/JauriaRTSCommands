
local weaponName = "carson1"

local weaponDef = {
	
	name                    = "Burst",
	weaponType              = "LaserCannon",
	
	Accuracy=100,
	movingAccuracy=150,
	
	--damage
	
	avoidFeature = false,
	
	damage = {
		default = 500,
	},
--	areaOfEffect            = 10,
	
	--physics
	
	
	weaponVelocity          = 880,
	reloadtime              = 5,
	range                   = 500,
	sprayAngle              = 100,
	weaponaceleration       = 860,
	tolerance               = 3000,
	lineOfSight             = true,
	turret                  = true,
	craterMult              = 0,
	burst                   = 10,
	burstrate               = 0.1,
	proyectiles             = 1,
	
	--apperance
	
	duration                = 0.005,
	thickness               = 0.8,
	rgbColor                = [[1 1 0]],
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
