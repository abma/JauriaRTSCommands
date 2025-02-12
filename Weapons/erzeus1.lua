
local weaponName = "erzeus1"

local weaponDef = {
	
	name                    = "FastShot",
	weaponType              = "LaserCannon",
	
	Accuracy=10,
	movingAccuracy=30,
	
	--damage
	
	avoidFeature = false,
	
	damage = {
		default = 300,
	},
--	areaOfEffect            = 10,
	
	--physics
	
	weaponVelocity          = 800,
	reloadtime              = 6.5,
	range                   = 2000,
--	sprayAngle              = 45,
	weaponacceleration       = 450,
	tolerance               = 3000,
	lineOfSight             = true,
	turret                  = true,
	craterMult              = 100,
--	burst                   = 2,
--	burstrate               = 0.08,
	--projectiles             = 2,
	
	--apperance
	
	duration                = 0.005,
	thickness               = 0.8,
	rgbColor                = [[1 1 0]],
	--size                    = 0,
	--stages                  = 0,
	intensity               = 1,
	--separation              = 0,
	--sounds
	
	soundStart              = "erzeus1",
	
	collideFriendly=false,
	noSelfDamage= false,
}
return lowerkeys({[weaponName] = weaponDef})
