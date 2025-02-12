function widget:GetInfo()
	return {
		name		= "Death Counter",
		desc		= "Count team death units.",
		author		= "TurBoss",
		date		= "1/2/2015",
		license		= "GNU GPL V2 or Later",
		layer		= 5,
		enabled		= true,  -- loaded by default?
	}
end

local unitDestroyedCounterA = 0
local unitDestroyedCounterB = 0

local Teams = Spring.GetTeamList()

local spGetViewGeometry		= Spring.GetViewGeometry
local spGetTeamColor		= Spring.GetTeamColor

local screenSizeX, screenSizeY	= spGetViewGeometry()

local aColor = {0, 0, 0, 1}
local bColor = {0, 0, 0, 1}

local Chili
local black	= {0.1, 0.1, 0.1, 1.0}
local grey	= {0.5, 0.5, 0.5, 1.0}
local white	= {1.0, 1.0, 1.0, 1.0}
local red	= {0.8, 0.0, 0.0, 1.0}


local counterWindow = {}
local counterPanel1, counterPanel2, counterLabel1, counterLabel2

local function getTeamsColor()

	local r, g, b  = spGetTeamColor(Teams[1])

	aColor[1] = r
	aColor[2] = g
	aColor[3] = b
	
	
	local r, g, b  = spGetTeamColor(Teams[2])

	bColor[1] = r
	bColor[2] = g
	bColor[3] = b
	
end

local function CreateWindow()
	counterWindow	= Chili.Window:New{
		parent		= Chili.Screen0;
		name		= "counter window";
		x			= "50%";
		y			= 0;
		width		= "15%";
		height		= "10%";
		dockable	= false;
		draggable	= false;
		resizable	= false;
		padding		= {2,2,2,2};
		children	= {
			Chili.Label:New{
				caption	= "Team ".. Teams[1]+1;
				y		= "6%";
				x		= "7.5%";
				fontsize = math.floor(screenSizeX/75);
			},
			Chili.Label:New{
				caption	= "Team ".. Teams[2]+1;
				y		= "6%";
				x		= "55%";
				fontsize = math.floor(screenSizeX/75);
			},
		},
	}
	
	counterPanel1	= Chili.Panel:New{
		parent		= counterWindow;
		name		= "counter A";
		padding 	= {10,10,10,10};
		x			= "5%";
		y			= "35%";
		width		= "40%";
		height		= "60%";
		dockable	= false;
		draggable	= false;
		resizable	= false;
	}
	
	counterPanel2	= Chili.Panel:New{
		parent		= counterWindow;
		name		= "counter B";
		padding 	= {10,10,10,10};
		x			= "55%";
		y			= "35%";
		width		= "40%";
		height		= "60%";
		dockable	= false;
		draggable	= false;
		resizable	= false;
	}
	
end

function UpdateCounter()
	counterLabel1	= Chili.Label:New{
		parent		= counterPanel1;
		name		= "counter label A";
		caption		= unitDestroyedCounterA;
		textColor	= aColor;
		fontsize	= math.floor(screenSizeX/50);
		padding 	= {0,0,0,0};
		valign		= 'center';
		halign		= 'center';
		x			= "30%";
		y			= "25%";
		width		= "40%";
		height		= "55%";
		dockable	= false;
		draggable	= false;
		resizable	= false;
	}
	counterLabel2	= Chili.Label:New{
		parent		= counterPanel2;
		name		= "counter label B";
		caption		= unitDestroyedCounterB;
		textColor	= bColor;
		fontsize	= math.floor(screenSizeX/50);
		padding 	= {0,0,0,0};
		valign		= 'center';
		x			= "30%";
		y			= "25%";
		width		= "40%";
		height		= "55%";
		dockable	= false;
		draggable	= false;
		resizable	= false;
	}
end

function widget:Initialize()
	Chili = WG.Chili
	
	if (not Chili) then
		widgetHandler:RemoveWidget()
		return
	end
	
	getTeamsColor()
	CreateWindow()
	UpdateCounter()
end

function widget:GameFrame(f)
	if (f % 30 ==0) then 
		unitDestroyedCounterA = Spring.GetGameRulesParam("unitDestroyedCounterA")
		unitDestroyedCounterB = Spring.GetGameRulesParam("unitDestroyedCounterB")
		counterLabel1:Dispose()
		counterLabel2:Dispose()
		counterLabel1 = nil
		counterLabel2 = nil
		UpdateCounter()
	end
end
