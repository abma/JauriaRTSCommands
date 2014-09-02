local unitName = "cnm1"

local unitDef = {
	name = "NM-1",
	Description = "Light Infantry",
	objectName = "nm1.dae",
	script = "nm1.lua",
	buildPic = "nm1.png",
	iconType = "nm1",

	--cost

	buildCostMetal = 100,
	buildCostEnergy = 0,
	buildTime = 6.5,

	--Health

	maxDamage = 1080,
	idleAutoHeal = 18,
	idleTime     = 3,

	--Movement

	mass=800,
	Acceleration = 1.2,
	BrakeRate = 5,
	FootprintX = 2,
	FootprintZ = 2,
	MaxSlope = 12,
	MaxVelocity = 4.2,
	MaxWaterDepth = 20,
	MovementClass = "Default2x2",
	TurnRate = 2600,

	sightDistance = 350,

	Category = [[LAND]],
	
	CanAttack = true,
	CanGuard = true,
	CanMove = true,
	CanPatrol = true,
	CanStop = true,
	LeaveTracks = false, 

	sfxtypes = {
		explosiongenerators = {
			"custom:smoke1",
		},
	},

	weapons = {
		[1]={name  = "weaponnm1",
			onlyTargetCategory = [[LAND]],
			maxAngleDif = 210,
			mainDir = [[-1 0 1]],
		},
		[2]={name  = "weaponnm1",
			onlyTargetCategory = [[LAND]],
			maxAngleDif = 210,
			mainDir = [[1 0 1]],
		},
	},
}

return lowerkeys({ [unitName] = unitDef })
