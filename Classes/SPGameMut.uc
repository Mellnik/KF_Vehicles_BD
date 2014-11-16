class SPGameMut extends mutator config (KF_Vehicles_BD);


var globalconfig int MaxCarLimit,MinCarLimit;


static function FillPlayInfo(PlayInfo PlayInfo) {


//local string option;
//local int i;



  Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent
 
PlayInfo.AddSetting("Max Vehicles", "MaxCarLimit", "Max Vehicles", 0, 0, "Text", "2;1:12",);
PlayInfo.AddSetting("Min Vehicles", "MinCarLimit", "Min Vehicles", 0, 0, "Text", "1;1:8",);

}



function postBeginPlay()
{

local string currentmap;



if(BDgametype(level.game)==none)
{
currentmap=GetURLMap(false);

level.servertravel("?game=KF_Vehicles_BD.BDgametype",true);

}

BDgametype(level.game).MaxCarLimit=MaxCarLimit;

BDgametype(level.game).MinCarLimit=MinCarLimit;


}

defaultproperties
{
     MaxCarLimit=8
     MinCarLimit=6
     GroupName="KF-Vehicles"
     FriendlyName="Killing Floor Vehicle Mod"
     Description="Allows random spawnable vehicles in Single Player maps"
}
