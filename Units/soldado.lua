local unitName = "soldado"

local unitDef = {
	name = "soldado",
	Description = "Complex, mobile unit.",
	objectName = "soldado.dae",
	script = "soldado.lua",
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
	
	sfxtypes = {
		explosiongenerators = {
			"custom:DEVA_SHELLS",
		},
	},

	weapons = {
		[1]={name  = "metralleta",
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
