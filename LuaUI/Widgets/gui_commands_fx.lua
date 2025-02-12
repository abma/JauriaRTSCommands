function widget:GetInfo()
   return {
      name      = "Commands FX",
      desc      = "Shows commands given by allies",
      author    = "Floris, Bluestone",
      date      = "28 January 2015",
      license   = "GNU GPL, v2 or later",
      layer     = 2,
      enabled   = true,
   }
end

-- future:          hotkey to show all current cmds? (like current shift+space)
--                  handle set target

local spGetUnitPosition	= Spring.GetUnitPosition
local spGetUnitCommands	= Spring.GetUnitCommands
local spIsUnitInView = Spring.IsUnitInView
local spIsSphereInView = Spring.IsSphereInView
local spIsUnitIcon = Spring.IsUnitIcon
local spValidUnitID = Spring.ValidUnitID
local spValidFeatureID = Spring.ValidFeatureID
local spGetFeaturePosition = Spring.GetFeaturePosition
local spIsUnitSelected = Spring.IsUnitSelected
local spIsGUIHidden = Spring.IsGUIHidden
local spTraceScreenRay = Spring.TraceScreenRay
local spIsUnitSelected = Spring.IsUnitSelected
local spGetUnitDefID = Spring.GetUnitDefID
local spLoadCmdColorsConfig	= Spring.LoadCmdColorsConfig

local GL_SRC_ALPHA = GL.SRC_ALPHA
local GL_ONE_MINUS_SRC_ALPHA = GL.ONE_MINUS_SRC_ALPHA
local GL_ONE = GL.ONE

local MAX_UNITS = Game.maxUnits

local CMD_ATTACK = CMD.ATTACK --icon unit or map
local CMD_CAPTURE = CMD.CAPTURE --icon unit or area
local CMD_FIGHT = CMD.FIGHT -- icon map
local CMD_GUARD = CMD.GUARD -- icon unit
local CMD_INSERT = CMD.INSERT 
local CMD_LOAD_ONTO = CMD.LOAD_ONTO -- icon unit
local CMD_LOAD_UNITS = CMD.LOAD_UNITS -- icon unit or area
local CMD_MANUALFIRE = CMD.MANUALFIRE -- icon unit or map (cmdtype edited by gadget)
local CMD_MOVE = CMD.MOVE -- icon map
local CMD_PATROL = CMD.PATROL --icon map
local CMD_RECLAIM = CMD.RECLAIM --icon unit feature or area
local CMD_REPAIR = CMD.REPAIR -- icon unit or area
local CMD_RESTORE = CMD.RESTORE -- icon area
local CMD_RESURRECT = CMD.RESURRECT -- icon unit feature or area
-- local CMD_SET_TARGET = 34923 -- custom command, doesn't go through UnitCommand
local CMD_UNLOAD_UNIT = CMD.UNLOAD_UNIT -- icon map
local CMD_UNLOAD_UNITS = CMD.UNLOAD_UNITS -- icon  unit or area
local BUILD = -1

--------------------------------------------------------------------------------

local commands = {}
local minCommand = 1 -- track lowest/highest entries that need to be processed
local minQueueCommand = 1
local maxCommand = 0

local unitCommand = {} -- most recent key in command table of order for unitID 
local setTarget = {} -- set targets of units
local osClock

local drawBuildQueue	= true
local drawPulse			= true
local drawPulseAllways	= false
local drawLineTexture	= true

local opacity      		= 1
local duration     		= 2

local lineWidth	   		= 5
local lineOpacity		= 0.85
local lineDuration 		= 1		-- set a value <= 1
local lineWidthEnd		= 0.5		-- multiplier (this wont affect textured lines)
local lineTextureLength = 4.5
local lineTextureSpeed  = 2

local glowRadius    	= 32
local glowDuration  	= 0.3
local glowOpacity   	= 0.13

local pulseRadius		= 21
local pulseDuration 	= 0.85		-- set a value <= 1
local pulseOpacity  	= 1
local pulseRotateSpeed  = 1		-- not working yet


local pulseImg			= LUAUI_DIRNAME.."Images/commandsfx/pulse.png"
local glowImg			= LUAUI_DIRNAME.."Images/commandsfx/glow.png"
local lineImg			= LUAUI_DIRNAME.."Images/commandsfx/line.png"


local mapX = Game.mapSizeX
local mapZ = Game.mapSizeZ

local CONFIG = {  
    [CMD_ATTACK] = {
        sizeMult = 1.4,
        colour = {1.00, 0.20, 0.20, 0.30},
    },
    [CMD_CAPTURE] = {
        sizeMult = 1.4,
        colour = {1.00, 1.00, 0.30, 0.30},
    },
    [CMD_FIGHT] = {
        sizeMult = 1.2,
        colour = {0.30, 0.50, 1.00, 0.25}, 
    },
    [CMD_GUARD] = {
        sizeMult = 1,
        colour = {0.10, 0.10, 0.50, 0.25},
    },
    [CMD_LOAD_ONTO] = {
        sizeMult = 1,
        colour = {0.30, 1.00, 1.00 ,0.25},
    },
    [CMD_LOAD_UNITS] = {
        sizeMult = 1,
        colour = {0.30, 1.00, 1.00, 0.30},
    },
    [CMD_MANUALFIRE] = {
        sizeMult = 1.4,
        colour = {1.00, 0.00, 0.00, 0.30},
    },
    [CMD_MOVE] = {
        sizeMult = 1, 
        colour = {0.00, 1.00, 0.00, 0.25},
    },
    [CMD_PATROL] = {
        sizeMult = 1,
        colour = {0.10, 0.10, 1.00, 0.25},
    },
    [CMD_RECLAIM] = {
        sizeMult = 1,
        colour = {1.00, 0.20, 1.00, 0.4},
    },
    [CMD_REPAIR] = {
        sizeMult = 1,
        colour = {0.30, 1.00, 1.00, 0.4},
    },
    [CMD_RESTORE] = {
        sizeMult = 1,
        colour = {0.00, 0.50, 0.00, 0.25},
    },
    [CMD_RESURRECT] = {
        sizeMult = 1,
        colour = {0.20, 0.60, 1.00, 0.25},
    },
    --[[
    [CMD_SET_TARGET] = {
        sizeMult = 1,
        colour = {1.00 ,0.75 ,1.00 ,0.25},
    },
    ]]
    [CMD_UNLOAD_UNIT] = {
        sizeMult = 1,
        colour = {1.00, 1.00 ,0.00 ,0.25},
    },
    [CMD_UNLOAD_UNITS] = {
        sizeMult = 1,
        colour = {1.00, 1.00 ,0.00 ,0.25},
    },
    [BUILD] = {
        sizeMult = 1,
        colour = {0.00, 1.00 ,0.00 ,0.25},    
    }
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local UNITCONF = {}
local shapes = {}
function SetUnitConf()
	local name, shape, xscale, zscale, scale, xsize, zsize, weaponcount
	for udid, unitDef in pairs(UnitDefs) do
		xsize, zsize = unitDef.xsize, unitDef.zsize
		scale = ( xsize^2 + zsize^2 )^0.5
		name = unitDef.name
		
		if (unitDef.isBuilding or unitDef.isFactory or unitDef.speed==0) then
			shapeName = 'square'
			shape = shapes.square
			xscale, zscale = xsize, zsize
		elseif (unitDef.isAirUnit) then
			shapeName = 'triangle'
			shape = shapes.triangle
			xscale, zscale = scale, scale
		else
			shapeName = 'circle'
			shape = shapes.circle
			xscale, zscale = scale, scale
		end
			
		UNITCONF[udid] = {name=name, shape=shape, shapeName=shapeName, xscale=xscale, zscale=zscale}
	end
end


local function setCmdLineColors(alpha)

	spLoadCmdColorsConfig('move        0.5  1.0  0.5  '..alpha)
	spLoadCmdColorsConfig('attack      1.0  0.2  0.2  '..alpha)
	spLoadCmdColorsConfig('fight       0.5  0.5  1.0  '..alpha)
	spLoadCmdColorsConfig('wait        0.5  0.5  0.5  '..alpha)
	spLoadCmdColorsConfig('build       0.0  1.0  0.0  '..alpha)
	spLoadCmdColorsConfig('guard       0.3  0.3  1.0  '..alpha)
	spLoadCmdColorsConfig('stop        0.0  0.0  0.0  '..alpha)
	spLoadCmdColorsConfig('patrol      0.3  0.3  1.0  '..alpha)
	spLoadCmdColorsConfig('capture     1.0  1.0  0.3  '..alpha)
	spLoadCmdColorsConfig('repair      0.3  1.0  1.0  '..alpha)
	spLoadCmdColorsConfig('reclaim     1.0  0.2  1.0  '..alpha)
	spLoadCmdColorsConfig('restore     0.0  1.0  0.0  '..alpha)
	spLoadCmdColorsConfig('resurrect   0.2  0.6  1.0  '..alpha)
	spLoadCmdColorsConfig('load        0.3  1.0  1.0  '..alpha)
	spLoadCmdColorsConfig('unload      1.0  1.0  0.0  '..alpha)
	spLoadCmdColorsConfig('deathWatch  0.5  0.5  0.5  '..alpha)
end

function widget:Initialize()
	--SetUnitConf()
	
	--spLoadCmdColorsConfig('useQueueIcons  0 ')
	spLoadCmdColorsConfig('queueIconScale  0.75 ')
	spLoadCmdColorsConfig('queueIconAlpha  0.4 ')
	--spLoadCmdColorsConfig('unitBox           0.0  1.0  0.0  0.85')
	
	setCmdLineColors(0.4)
end

function widget:Shutdown()

	--spLoadCmdColorsConfig('useQueueIcons  1 ')
	spLoadCmdColorsConfig('queueIconScale  1 ')
	spLoadCmdColorsConfig('queueIconAlpha  1 ')
	--spLoadCmdColorsConfig('unitBox           0.0  1.0  0.0  1.0')
	
	setCmdLineColors(0.7)
end


local pi = math.pi
local sin = math.sin
local cos = math.cos
local atan = math.atan 
local random = math.random


local function DrawLineEnd(x1,y1,z1, x2,y2,z2, width)
	y1 = y2
	
	local xDifference		= x2 - x1
	local yDifference		= y2 - y1
	local zDifference		= z2 - z1
	local distance			= math.sqrt(xDifference*xDifference + yDifference*yDifference + zDifference*zDifference)
	
	-- for 2nd rounding
	local distanceDivider = distance / (width/2.25)
	x1_2 = x2 - ((x1 - x2) / distanceDivider)
	z1_2 = z2 - ((z1 - z2) / distanceDivider)
	
	-- for first rounding
	distanceDivider = distance / (width/4.13)
	x1 = x2 - ((x1 - x2) / distanceDivider)
	z1 = z2 - ((z1 - z2) / distanceDivider)
	
    local theta	= (x1~=x2) and atan((z2-z1)/(x2-x1)) or pi/2
    local zOffset = cos(pi-theta) * width / 2
    local xOffset = sin(pi-theta) * width / 2
    
    local xOffset2 = xOffset / 1.35
    local zOffset2 = zOffset / 1.35
	
	-- first rounding
    gl.Vertex(x1+xOffset2, y1, z1+zOffset2)
    gl.Vertex(x1-xOffset2, y1, z1-zOffset2)
    
    gl.Vertex(x2-xOffset, y2, z2-zOffset)
    gl.Vertex(x2+xOffset, y2, z2+zOffset)
    
    -- second rounding
    gl.Vertex(x1+xOffset2, y1, z1+zOffset2)
    gl.Vertex(x1-xOffset2, y1, z1-zOffset2)
	
    xOffset2 = xOffset / 3.22
    zOffset2 = zOffset / 3.22
	
    gl.Vertex(x1_2-xOffset2, y1, z1_2-zOffset2)
    gl.Vertex(x1_2+xOffset2, y1, z1_2+zOffset2)
end


local function DrawLineEndTex(x1,y1,z1, x2,y2,z2, width, texLength, texOffset)
	y1 = y2
	
	local xDifference		= x2 - x1
	local yDifference		= y2 - y1
	local zDifference		= z2 - z1
	local distance			= math.sqrt(xDifference*xDifference + yDifference*yDifference + zDifference*zDifference)
	
	-- for 2nd rounding
	local distanceDivider = distance / (width/2.25)
	x1_2 = x2 - ((x1 - x2) / distanceDivider)
	z1_2 = z2 - ((z1 - z2) / distanceDivider)
	
	-- for first rounding
	local distanceDivider2 = distance / (width/4.13)
	x1 = x2 - ((x1 - x2) / distanceDivider2)
	z1 = z2 - ((z1 - z2) / distanceDivider2)
	
    local theta	= (x1~=x2) and atan((z2-z1)/(x2-x1)) or pi/2
    local zOffset = cos(pi-theta) * width / 2
    local xOffset = sin(pi-theta) * width / 2
    
    local xOffset2 = xOffset / 1.35
    local zOffset2 = zOffset / 1.35
	
	-- first rounding
	gl.TexCoord(0.2-texOffset,0)
    gl.Vertex(x1+xOffset2, y1, z1+zOffset2)
	gl.TexCoord(0.2-texOffset,1)
    gl.Vertex(x1-xOffset2, y1, z1-zOffset2)
    
	gl.TexCoord(0.55-texOffset,0.85)
    gl.Vertex(x2-xOffset, y2, z2-zOffset)
	gl.TexCoord(0.55-texOffset,0.15)
    gl.Vertex(x2+xOffset, y2, z2+zOffset)
    
    -- second rounding
	gl.TexCoord(0.8-texOffset,0.7)
    gl.Vertex(x1+xOffset2, y1, z1+zOffset2)
	gl.TexCoord(0.8-texOffset,0.3)
    gl.Vertex(x1-xOffset2, y1, z1-zOffset2)
	
    xOffset2 = xOffset / 3.22
    zOffset2 = zOffset / 3.22
	
	gl.TexCoord(0.55-texOffset,0.15)
    gl.Vertex(x1_2-xOffset2, y1, z1_2-zOffset2)
	gl.TexCoord(0.55-texOffset,0.85)
    gl.Vertex(x1_2+xOffset2, y1, z1_2+zOffset2)
end

local function DrawLine(x1,y1,z1, x2,y2,z2, width) -- long thin rectangle
	
    local theta	= (x1~=x2) and atan((z2-z1)/(x2-x1)) or pi/2
    local zOffset = cos(pi-theta) * width / 2
    local xOffset = sin(pi-theta) * width / 2
    
    gl.Vertex(x1+xOffset, y1, z1+zOffset)
    gl.Vertex(x1-xOffset, y1, z1-zOffset)
    
    gl.Vertex(x2-xOffset, y2, z2-zOffset)
    gl.Vertex(x2+xOffset, y2, z2+zOffset)
end

local function DrawLineTex(x1,y1,z1, x2,y2,z2, width, texLength, texOffset) -- long thin rectangle

	local xDifference		= x2 - x1
	local yDifference		= y2 - y1
	local zDifference		= z2 - z1
	local distance			= math.sqrt(xDifference*xDifference + yDifference*yDifference + zDifference*zDifference)
	
    local theta	= (x1~=x2) and atan((z2-z1)/(x2-x1)) or pi/2
    local zOffset = cos(pi-theta) * width / 2
    local xOffset = sin(pi-theta) * width / 2
    
	gl.TexCoord(((distance/width)/texLength)+1-texOffset, 1)
    gl.Vertex(x1+xOffset, y1, z1+zOffset)
	gl.TexCoord(((distance/width)/texLength)+1-texOffset, 0)
    gl.Vertex(x1-xOffset, y1, z1-zOffset)
    
	gl.TexCoord(0-texOffset,0)
    gl.Vertex(x2-xOffset, y2, z2-zOffset)
	gl.TexCoord(0-texOffset,1)
    gl.Vertex(x2+xOffset, y2, z2+zOffset)
end

local function DrawGroundquad(x,y,z,size)

	gl.TexCoord(0,0)
	gl.Vertex(x-size,y,z-size)
	gl.TexCoord(0,1)
	gl.Vertex(x-size,y,z+size)
	gl.TexCoord(1,1)
	gl.Vertex(x+size,y,z+size)
	gl.TexCoord(1,0)
	gl.Vertex(x+size,y,z-size)
end

------------------------------------------------------------------------------------

function RemovePreviousCommand(unitID)
    if unitCommand[unitID] and commands[unitCommand[unitID]] then
        commands[unitCommand[unitID]].draw = false
    end
end

function widget:UnitCommand(unitID, unitDefID, teamID, cmdID, _, _)
    -- record that a command was given (note: cmdID is not used, but useful to record for debugging)
    if unitID and (CONFIG[cmdID] or cmdID==CMD_INSERT or cmdID<0) then
        local el = {ID=cmdID,time=os.clock(),unitID=unitID,draw=false,selected=spIsUnitSelected(unitID),udid=spGetUnitDefID(unitID)} -- command queue is not updated until next gameframe
        maxCommand = maxCommand + 1
        --Spring.Echo("Adding " .. maxCommand)
        commands[maxCommand] = el
    end
end

function ExtractTargetLocation(a,b,c,d,cmdID)
    -- input is first 4 parts of cmd.params table
    local x,y,z
    if c or d then
        if cmdID==CMD_RECLAIM and a >= MAX_UNITS and spValidFeatureID(a-MAX_UNITS) then --ugh, but needed
            x,y,z = spGetFeaturePosition(a-MAX_UNITS)        
        elseif cmdID==CMD_REPAIR and spValidUnitID(a) then
            x,y,z = spGetUnitPosition(a)
        else
            x=a
            y=b
            z=c
        end
    elseif a then
        if a >= MAX_UNITS then
            x,y,z = spGetFeaturePosition(a-MAX_UNITS)
        else
            x,y,z = spGetUnitPosition(a)     
        end
    end
    return x,y,z
end

function widget:GameFrame()
    --Spring.Echo("GameFrame: minCommand " .. minCommand .. " minQueueCommand " .. minQueueCommand .. " maxCommand " .. maxCommand)
    local i = minQueueCommand
    while (i <= maxCommand) do
        --Spring.Echo("Processing " .. i) --debug
        
        local unitID = commands[i].unitID
        RemovePreviousCommand(unitID)
        unitCommand[unitID] = i

        -- get pruned command queue
        local q = spGetUnitCommands(commands[i].unitID,50) or {} --limit to prevent mem leak, hax etc
        local our_q = {}
        local gotHighlight = false
        for _,cmd in ipairs(q) do
            if CONFIG[cmd.id] or cmd.id < 0 then
                if cmd.id < 0 then
                    cmd.buildingID = -cmd.id;
                    cmd.id = BUILD
                    if not cmd.params[4] then
                        cmd.params[4] = 0 --sometimes the facing param is missing (wtf)
                    end
                end
                our_q[#our_q+1] = cmd
            end
        end
        
        commands[i].queue = our_q
        commands[i].queueSize = #our_q 
        if #our_q>0 then
            commands[i].highlight = CONFIG[our_q[1].id].colour
            commands[i].draw = true
        end
        
        -- get location of final command
        local lastCmd = our_q[#our_q]
        if lastCmd and lastCmd.params then
            local x,y,z = ExtractTargetLocation(lastCmd.params[1],lastCmd.params[2],lastCmd.params[3],lastCmd.params[4],lastCmd.id) 
            if x then
                commands[i].x = x
                commands[i].y = y
                commands[i].z = z
            end
        end
        
        commands[i].processed = true
        
        minQueueCommand = minQueueCommand + 1
        i = i + 1
    end
end

local function IsPointInView(x,y,z)
    if x and y and z then
        return spIsSphereInView(x,y,z,1) --better way of doing this?
    end
    return false
end

local prevRotationOffset	= 0
local rotationOffset		= 0
local prevTexOffset			= 0
local texOffset				= 0
local prevOsClock = os.clock()

function widget:DrawWorldPreUnit()
    --Spring.Echo(maxCommand-minCommand) --EXPENSIVE! often handling hundreds of command queues at once 
    --if spIsGUIHidden() then return end
    
    osClock = os.clock()
    gl.Blending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    gl.DepthTest(false)
	if drawLineTexture then
		texOffset = prevTexOffset - ((osClock - prevOsClock)*lineTextureSpeed)
		texOffset = texOffset - math.floor(texOffset)
		prevTexOffset = texOffset
		rotationOffset = prevRotationOffset - ((osClock - prevOsClock)*pulseRotateSpeed)
		rotationOffset = rotationOffset - math.floor(texOffset)
		prevRotationOffset = rotationOffset
    end
	prevOsClock = os.clock()
    local i = minCommand
    while (i <= maxCommand) do --only draw commands that have already been processed in GameFrame
        
        local progress = (osClock - commands[i].time) / duration
        local unitID = commands[i].unitID
        
        if progress > 1 and commands[i].processed then
            -- remove when duration has passed (also need to check if it was processed yet, because of pausing)
            --Spring.Echo("Removing " .. i)
            commands[i] = nil
            minCommand = minCommand + 1
            
        elseif commands[i].draw and (spIsUnitInView(unitID) or IsPointInView(commands[i].x,commands[i].y,commands[i].z)) then 				
            local prevX, prevY, prevZ = spGetUnitPosition(unitID)
            -- draw set target command (TODO)
            --[[
            if prevX and commands[i].set_target and commands[i].set_target.params and commands[i].set_target.params[1] then
                local lineColour = CONFIG[CMD_SET_TARGET].colour
                local lineAlpha = opacity * lineColour[4] * (1-progress)
                gl.Color(lineColour[1],lineColour[2],lineColour[3],lineAlpha)
                if commands[i].set_target.params[3] then
                    gl.BeginEnd(GL.QUADS, DrawLine, prevX,prevY,prevZ, commands[i].set_target.params[1], commands[i].set_target.params[2], commands[i].set_target.params[3], lineWidth) 
                else
                    local x,y,z = Spring.GetUnitPosition(commands[i].set_target.params[1])    
                    if x then
                        gl.BeginEnd(GL.QUADS, DrawLine, prevX,prevY,prevZ, x,y,z, lineWidth)                     
                    end
                end                  
            end
            ]]
            -- draw command queue
            if commands[i].queueSize > 0 and prevX then
				local lineAlphaMultiplier  = 1 - (progress / lineDuration)
                for j=1,commands[i].queueSize do
                    --Spring.Echo(CMD[commands[i].queue[j].id]) --debug
                    local X,Y,Z = ExtractTargetLocation(commands[i].queue[j].params[1], commands[i].queue[j].params[2], commands[i].queue[j].params[3], commands[i].queue[j].params[4], commands[i].queue[j].id)                                
                    local validCoord = X and Z and X>=0 and X<=mapX and Z>=0 and Z<=mapZ
                    -- draw
                    if X and validCoord then
                        -- lines
                        local usedLineWidth = lineWidth - (progress * (lineWidth - (lineWidth * lineWidthEnd)))
                        local lineColour = CONFIG[commands[i].queue[j].id].colour
                        local lineAlpha = opacity * lineOpacity * (lineColour[4] * 1.5) * lineAlphaMultiplier
                        if lineAlpha > 0 then 
							gl.Color(lineColour[1],lineColour[2],lineColour[3],lineAlpha)
							if drawLineTexture then
								usedLineWidth = lineWidth
								gl.Texture(lineImg)
								gl.BeginEnd(GL.QUADS, DrawLineTex, prevX,prevY,prevZ, X, Y, Z, usedLineWidth, lineTextureLength, texOffset)
								gl.Texture(false)
							else
								gl.BeginEnd(GL.QUADS, DrawLine, prevX,prevY,prevZ, X, Y, Z, usedLineWidth)
							end
							-- ghost of build queue
							if drawBuildQueue and commands[i].queue[j].buildingID then
								gl.PushMatrix()
								gl.Translate(X,Y+1,Z)
								gl.Rotate(90 * commands[i].queue[j].params[4], 0, 1, 0)
								gl.UnitShape(commands[i].queue[j].buildingID, Spring.GetMyTeamID())
								gl.Rotate(-90 * commands[i].queue[j].params[4], 0, 1, 0)
								gl.Translate(-X,-Y-1,-Z)
								gl.PopMatrix()
							end
							if j == 1 and not drawLineTexture then
								-- draw startpoint rounding
								gl.Color(lineColour[1],lineColour[2],lineColour[3],lineAlpha)
								gl.BeginEnd(GL.QUADS, DrawLineEnd, X, Y, Z, prevX,prevY,prevZ, usedLineWidth)
							end
						end
                        if j==commands[i].queueSize then
							
							-- draw pulse if unit was selected when the cmd was given
							if drawPulse and commands[i].selected or drawPulseAllways then
								local pulseProgress = 0.7 - ((progress/1.5) / pulseDuration)
								if progress < 0.05 then
									pulseProgress = 0.57 + ((progress/1.5) / pulseDuration)
								end
								local pulseAlphaMultiplier  = 1 - (progress / pulseDuration)
								local pulseAlpha = (opacity * (lineColour[4]*1.7) * pulseAlphaMultiplier) * pulseOpacity
								if pulseAlpha > 0.03 then
									local pulseSize = pulseRadius/7 + ((pulseRadius / 2) * pulseProgress)
									gl.Color(lineColour[1],lineColour[2],lineColour[3],pulseAlpha)
									gl.Texture(pulseImg)
									gl.BeginEnd(GL.QUADS,DrawGroundquad,X,Y,Z,pulseSize*1.5)
									gl.Texture(false)
								end
							end
							
							-- draw endpoint rounding
							if lineAlpha > 0 then 
								if drawLineTexture then
									gl.Texture(lineImg)
									gl.Color(lineColour[1],lineColour[2],lineColour[3],lineAlpha)
									gl.BeginEnd(GL.QUADS, DrawLineEndTex, prevX,prevY,prevZ, X, Y, Z, usedLineWidth, lineTextureLength, texOffset)
									gl.Texture(false)
								else
									gl.Color(lineColour[1],lineColour[2],lineColour[3],lineAlpha)
									gl.BeginEnd(GL.QUADS, DrawLineEnd, prevX,prevY,prevZ, X, Y, Z, usedLineWidth)
								end
                            end
                            
							-- ground glow
                            local size = glowRadius * CONFIG[commands[i].queue[j].id].sizeMult
							local glowAlpha = (1 - progress) * glowOpacity * opacity
							
							gl.Color(lineColour[1],lineColour[2],lineColour[3],glowAlpha)
							gl.Texture(glowImg)
							gl.BeginEnd(GL.QUADS,DrawGroundquad,X,Y,Z,size)
							gl.Texture(false)
							
                        end
                        prevX, prevY, prevZ = X, Y, Z
                    end
                end                            
            end
                                
        end
        
        i = i + 1
    end
    
    gl.Scale(1,1,1)
    gl.Color(1,1,1,1)
end

function widget:DrawWorld()
    if spIsGUIHidden() then return end

    -- highlight unit 
    gl.DepthTest(true)
    gl.PolygonOffset(-2, -2)
    gl.Blending(GL_SRC_ALPHA, GL_ONE)
    local i = minCommand
    while (i <= maxCommand) do
        if commands[i].draw and commands[i].highlight and not spIsUnitIcon(commands[i].unitID) then
            local progress = (osClock - commands[i].time) / duration
            gl.Color(commands[i].highlight[1],commands[i].highlight[2],commands[i].highlight[3],0.1*(1-progress))
            gl.Unit(commands[i].unitID, true)
        end
        i = i + 1
    end
    gl.Blending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    gl.PolygonOffset(false)
    gl.DepthTest(false)
end


