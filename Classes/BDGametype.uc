Class BDGametype extends KFGameType;

var int   MaxCarLimit;
var	  int	NumCars;
var int   MinCarLimit;

struct OKEvents
{
     var name  MyOKevents;
};

var     array<OKEvents> RandomOKEvents;   
 


/*
event PreBeginPlay()
{

local BDLevelRules BDL;

    Super.PreBeginPlay();

foreach Allactors ( Class'BDLevelRules', BDL )
	{
      	MaxCarLimit = BDL.MaxCarLimit;
      	MinCarLimit = BDL.MinCarLimit;
	}

}
*/

function NotifyAddCar(){
   NumCars++;
}


function NotifyRemoveCar(){
   NumCars--;
}


function bool TooManyCars(Controller CarToRemove){
   local int CurrentInPlayLimit;


     CurrentInPlayLimit = MaxCarLimit;


   if (NumCars >= CurrentInPlayLimit){ return true; }
   return false;
}


function bool NotEnoughCars(){
   local int CurrentInPlayLimit;


     CurrentInPlayLimit = MinCarLimit;


   if (NumCars < CurrentInPlayLimit){ return true; }
   return false;
}



event Tick(float DeltaTime)
{

	super.tick(deltatime);

	If (NotEnoughCars())
	{
	 	if (  RandomOKEvents.length > 0 )
		Event = RandomOKEvents[ int( FRand() * RandomOKEvents.length ) ].MyOKEvents;
		TriggerEvent( Event, self, None );
	}
}


	
function AddDefaultInventory( pawn PlayerPawn )
{
    PlayerPawn.giveweapon("KFMod.knife");
    PlayerPawn.giveweapon("KFMod.dualies");
    PlayerPawn.giveweapon("KFMod.syringe");
    PlayerPawn.giveweapon("KF_Vehicles_BD.BDwelder");
    PlayerPawn.giveweapon("KFMod.frag");
    PlayerPawn.giveweapon("KFMod.frag");
    SetPlayerDefaults(PlayerPawn);



}

defaultproperties
{
     MaxCarLimit=6
     MinCarLimit=3
     RandomOKEvents(0)=(MyOKevents="OK0")
     RandomOKEvents(1)=(MyOKevents="OK1")
     RandomOKEvents(2)=(MyOKevents="OK2")
     RandomOKEvents(3)=(MyOKevents="OK3")
     RandomOKEvents(4)=(MyOKevents="OK4")
     RandomOKEvents(5)=(MyOKevents="OK5")
     RandomOKEvents(6)=(MyOKevents="OK6")
     RandomOKEvents(7)=(MyOKevents="OK7")
     RandomOKEvents(8)=(MyOKevents="OK8")
     RandomOKEvents(9)=(MyOKevents="OK9")
     RandomOKEvents(10)=(MyOKevents="OK10")
     RandomOKEvents(11)=(MyOKevents="OK11")
     RandomOKEvents(12)=(MyOKevents="OK12")
     RandomOKEvents(13)=(MyOKevents="OK13")
     RandomOKEvents(14)=(MyOKevents="OK14")
     RandomOKEvents(15)=(MyOKevents="OK15")
     RandomOKEvents(16)=(MyOKevents="OK16")
     RandomOKEvents(17)=(MyOKevents="OK17")
     RandomOKEvents(18)=(MyOKevents="OK18")
     RandomOKEvents(19)=(MyOKevents="OK19")
     RandomOKEvents(20)=(MyOKevents="OK20")
     RandomOKEvents(21)=(MyOKevents="OK21")
     RandomOKEvents(22)=(MyOKevents="OK22")
     RandomOKEvents(23)=(MyOKevents="OK23")
     RandomOKEvents(24)=(MyOKevents="OK24")
     RandomOKEvents(25)=(MyOKevents="OK25")
     RandomOKEvents(26)=(MyOKevents="OK26")
     RandomOKEvents(27)=(MyOKevents="OK27")
     RandomOKEvents(28)=(MyOKevents="OK28")
     RandomOKEvents(29)=(MyOKevents="OK29")
     HUDType="KF_Vehicles_BD.BDKFHUD"
}
