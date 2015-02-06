local unitName = "asesino"

local unitDef = {
	name = "asesino",
	Description = "Complex, mobile unit.",
	objectName = "asesino.dae",
	script = "asesino.lua",
	buildPic = "placeholder.png",
	--iconType = "rk2",

	--cost

	buildCostMetal = 85,
	buildCostEnergy = 0,
	buildTime = 4.25,

	--Health

	maxDamage = 980,
	idleAutoHeal = 14,
	idleTime     = 3,

	--Movement
	
	moveState = 0,
	mass=600,
	Acceleration = 2,
	BrakeRate = 1.5,
	FootprintX = 1.5,
	FootprintZ = 1.5,
	MaxSlope = 12,
	MaxVelocity = 4.6,
	MaxWaterDepth = 20,
	MovementClass = "Default2x2",
	TurnRate = 3200,

	sightDistance = 340,

	Category = [[LAND]],
	CanManualFire = true, 
	CanAttack = true,
	CanGuard = true,
	CanMove = true,
	CanPatrol = true,
	CanStop = true,
	LeaveTracks = false,
	noAutoFire = true, 

	CanCloak = true,
	MinCloakDistance = 150,
	InitCloaked = true,

	Builder = true,
	ShowNanoSpray = false,
	CanBeAssisted = false, 
	workerTime = 0.50,
	repairSpeed = 1,
	reclaimSpeed = 1,
	buildDistance = 30,
	
	buildoptions = {
		"mine",
	},


	weapons = {
		[1]={name  = "pistola",
			onlyTargetCategory = [[LAND]],
		},
		[3]={name  = "granada",
			onlyTargetCategory = [[LAND]],
		},
		--[2]={name  = "shieldheik",
		--},
	},
}

return lowerkeys({ [unitName] = unitDef })
