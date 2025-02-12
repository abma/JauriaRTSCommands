-- warmuzzle

return {
  ["warmuzzle"] = {
    bitmapmuzzleflame = {
      air                = true,
      class              = [[CBitmapMuzzleFlame]],
      count              = 1,
      ground             = true,
      underwater         = 1,
      water              = true,
      properties = {
        colormap           = [[1 1 0.5 0.01	1 0.7 0 0.01	0 0 0 0.01]],
        dir                = [[dir]],
        frontoffset        = 0.3,
        fronttexture       = [[plasma0029]],
        length             = 1,
        sidetexture        = [[plasma2]],
        size               = 0.2,
        sizegrowth         = 40,
        ttl                = 5,
      },
    },
    bitmapmuzzleflame2 = {
      air                = true,
      class              = [[CBitmapMuzzleFlame]],
      count              = 1,
      ground             = true,
      underwater         = 1,
      water              = true,
      properties = {
        colormap           = [[1 1 0 0.01	1 0.5 0 0.01	0 0 0 0.01]],
        dir                = [[dir]],
        frontoffset        = -0.1,
        fronttexture       = [[flowerflash]],
        length             = 0.1,
        sidetexture        = [[plasma2]],
        size               = 10,
        sizegrowth         = 1,
        ttl                = 3,
      },
    },
    muzzleflash = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.90,
        colormap           = [[1 0.7 0.2 0.01    1 0.7 0.2 0.01    0 0 0 0.01]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 10,
        emitvector         = [[dir]],
        gravity            = [[0, 0, 0]],
        numparticles       = 5,
        particlelife       = 18,
        particlelifespread = 5,
        particlesize       = 1,
        particlesizespread = 0.3,
        particlespeed      = 2,
        particlespeedspread = 4,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0,
        sizemod            = 1.0,
        texture            = [[plasma]],
      },
    },
    muzzlesmoke = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 10,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.8,
        colormap           = [[0 0 0 0.01  0.5 0.5 0.5 0.5     0 0 0 0.01]],
        directional        = false,
        emitrot            = 0,
        emitrotspread      = 10,
        emitvector         = [[dir]],
        gravity            = [[0, 0.2, 0]],
        numparticles       = 1,
        particlelife       = 5,
        particlelifespread = 0,
        particlesize       = [[7 i-0.4]],
        particlesizespread = 1,
        particlespeed      = [[10 i-1]],
        particlespeedspread = 1,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0,
        sizemod            = 1.0,
        texture            = [[smokesmall]],
      },
    },
  },
}

