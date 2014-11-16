class SPGameMut extends mutator config (KF_Vehicles_BD);

var globalconfig int MaxCarLimit, MinCarLimit;

static function FillPlayInfo(PlayInfo PlayInfo) 
{
	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent
 
	PlayInfo.AddSetting("Vehicles", "MaxCarLimit", "Max Vehicles", 0, 0, "Text", "2;1:12",,,True);
	PlayInfo.AddSetting("Vehicles", "MinCarLimit", "Min Vehicles", 0, 0, "Text", "1;1:8",,,True);
}

function PostNetBeginPlay()
{
	if(BDgametype(level.game) == none)
	{		
		level.servertravel("?game=KF_Vehicles_BD.BDgametype", true);
	}
}

function postBeginPlay()
{
/*	local string currentmap;

	if(level.game == None)
		return;
	
	if(BDgametype(level.game) == none)
	{
		currentmap = GetURLMap(false);

		level.servertravel("?game=KF_Vehicles_BD.BDgametype", true);
	}*/
	
	if ( Role != ROLE_Authority )
        return;
	
	if(level.game != none && BDgametype(level.game) != none)
	{
		BDgametype(level.game).MaxCarLimit = MaxCarLimit;
		BDgametype(level.game).MinCarLimit = MinCarLimit;
	}
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "MaxCarLimit":		return "Maximum amount of cars that can appears on map.";
		case "MinCarLimit":		return "Minimum amount of cars that can appears on map.";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     MaxCarLimit=8
     MinCarLimit=6
     GroupName="KF-Vehicles"
     FriendlyName="Killing Floor Vehicle Mod"
     Description="Allows random spawnable vehicles in Single Player maps"
}
