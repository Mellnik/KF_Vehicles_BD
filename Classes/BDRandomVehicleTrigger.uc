//==================================================================================
// TeamVehicleFactory.
// Spawn any Vehicle or Turret, set Team, pre & post spawn Events, timing, and more.
// Glenn 'SuperApe' Storm -- June 2004 -- Updated: July 2005
//==================================================================================
class BDRandomVehicleTrigger extends SVehicleFactory
        placeable;
 
var()     int       TeamNum;            // 0= red, 1= blue, 255= neutral / none
var()     bool      bPlayerControl;     // Only player instigators can trigger
 
 
var       bool      bWaiting;           // About to spawn
var       int       FactoryTime;        // Time last spawn
 
var()     name      PreSpawnEvent;      // Event to trigger before spawn
var()     int       PreSpawnTime;       // Time before spawn to trigger event
var       bool      bPreSpawn;                        // Should trigger PreSpawnEvent next
var()     name      SpawnEvent;         // Event to trigger after spawn
 
var()     bool      bCrushable;         // Allow spawning over colliding actors
var()     int       RetrySpawnTime;     // Interval to wait if bBlocked or Player can see factory
 
var()     bool      bRandomFlip;        // Neutral vehicles may face backwards
 
var()     bool      bRandomSpawn;       // Spawn random vehicle class

var       bool      bdisabled;		//Factory is disabled after spawn

//var()     bool      SpawnOnce;		//Factory can either spawn one time only or respawn

var(Events)  name OnKilledEvent;   //event when vehicle is destroyed
 
struct SpawnedVehicle
{
     var() class<BDWheeledVehicle> SpawnVehicle; // Selected random vehicle class
};
var()     array<SpawnedVehicle>     RandomVehicles;   // List for random vehicle spawn

struct  Tags
{
     var() name  mytags;
};

var()     array<Tags>     RandomTags;

struct OKEvents
{
     var() name  MyOKevents;
};

var()     array<OKEvents> RandomOKEvents;   
 
 
simulated function PostBeginPlay()
{
//	 if (  RandomOKEvents.length > 0 )
//		OnKilledEvent = RandomOKEvents[ int( FRand() * RandomOKEvents.length ) ].MyOKEvents;

     if ( Tag != '' && RandomTags.length > 0 )
               Tag = RandomTags[ Rand(RandomTags.length ) ].mytags;

	else

	return;
}

simulated event Trigger(Actor Other, Pawn EventInstigator)
{
	//local Vehicle tmpVehicle;
 
	//log("EventInstigator"@EventInstigator);
	
	//if(EventInstigator == None)
	//	return;
 
    if(!EventInstigator.IsA('KFHumanPawn') && bPlayerControl)
		return;
		
	//log("VehicleCount >= MaxVehicleCount"@VehicleCount@MaxVehicleCount);
 
    if(VehicleCount >= MaxVehicleCount)
        return;

    //if(tmpVehicle != none)
	//	return;
		
	//log("bdisabled"@bdisabled);

    if(!bdisabled)
	{		
		bWaiting = true;
		bPreSpawn = true;
		FactoryTime = Level.TimeSeconds - PreSpawnTime;
    }
    else
    {
		return;
	}	
}
 
simulated function SpawnItNow()
{
     local  Vehicle         CreatedVehicle;
     local  bool           bBlocked;
     local  Pawn              P;
//     local vector TrySpawnPoint;

	//log("trying to spawn");
 
     bBlocked = false;
 
     if ( VehicleClass != None || ( bRandomSpawn && RandomVehicles.length > 0 ) )
     {
          if ( bRandomSpawn && RandomVehicles.length > 0 )
               VehicleClass = RandomVehicles[ int( FRand() * RandomVehicles.length ) ].SpawnVehicle;
          foreach CollidingActors(class'Pawn', P, VehicleClass.default.CollisionRadius * 1.33)
               bBlocked = true;
     }
     else
     {
          Log("TeamVehicleFactory:"@self@"has no VehicleClass");
          return;
     }

if ( shouldCreate() )
 {
 
//     if ( bBlocked && !bCrushable || PlayerCanSeePoint(TrySpawnPoint) )
     if ( bBlocked && !bCrushable )
		{
          bWaiting = true;
          bPreSpawn = true;
          FactoryTime = Level.TimeSeconds -  RetrySpawnTime + PreSpawnTime;
		}
     else
     {
          CreatedVehicle = spawn(VehicleClass, , , Location, Rotation);
 	  
		//log("Spawn car");
		
          if ( CreatedVehicle != None )

	  {
               VehicleCount++;
               MaxVehicleCount--;
               BDGameType(Level.Game).NotifyAddCar();
//             CreatedVehicle.Event = Tag;
               CreatedVehicle.ParentFactory = self;
//             CreatedVehicle.SetTeamNum(TeamNum);
               TriggerEvent(SpawnEvent, self, none);
               
	  }	
     }
  }
	else
  {
        return;
  }
}
 
event VehicleDestroyed(Vehicle V)
{
     Super.VehicleDestroyed(V);
	 
	 	 if (  RandomOKEvents.length > 0 )
		OnKilledEvent = RandomOKEvents[ Rand(RandomOKEvents.length ) ].MyOKEvents;

	  	    MaxVehicleCount++;
                    BDGameType(Level.Game).NotifyRemoveCar();
		    TriggerEvent( OnKilledEvent,self, None );

	
}
 
simulated function Tick(float DeltaTime)
{
	//log("tick");
     if ( bWaiting )
     {
		//log("bwaiting");
 
          if ( ( VehicleCount < MaxVehicleCount ) )
                    {
						//log("VehicleCount < MaxVehicleCount");
 //		    if ( Tag != '' && RandomTags.length > 0 )
 ///             		 Tag = RandomTags[ int( FRand() * RandomTags.length ) ].mytags;

                              
                              bWaiting = false;
                              FactoryTime = Level.TimeSeconds;
                              SpawnItNow();
                        
                    }
                    else
                    {
                    return;
		    }
     }
	return;
}


/*
function bool PlayerCanSeePoint(vector TestLocation)
{
    local Controller C;
    local float dist;
    local vector Right, Test;
 //   local float CollRadius;

	// Now make sure no player sees the spawn point.
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.Pawn!=none && C.Pawn.Health>0 && C.bIsPlayer )
		{
            dist = VSize(TestLocation - C.Pawn.Location);

         //   CollRadius = TestVehicle.Default.CollisionRadius;
         //   CollRadius *= 1.1;
        //    Right = ((TestLocation - C.Pawn.Location) cross vect(0.f,0.f,1.f));
		//	Right = Normal(Right) * CollRadius;
		//	Test.Z = TestVehicle.Default.CollisionHeight;
		//	Test.Z *= 1.25;


            // Do three traces, one to the location, and one slightly above left and right of the collision
            // cylinder size so we don't see this zed spawn
            if( (!C.Pawn.Region.Zone.bDistanceFog || (dist < C.Pawn.Region.Zone.DistanceFogEnd)) &&
                FastTrace(TestLocation,C.Pawn.Location + C.Pawn.EyePosition()) &&
                FastTrace((TestLocation + Test) + Right,C.Pawn.Location + C.Pawn.EyePosition()) &&
                FastTrace((TestLocation + Test) - Right,C.Pawn.Location + C.Pawn.EyePosition()) )
		
			{
		
                return true;
			}
			else
			{
				return false;
			}
		}
	}
}
	 
*/

function bool shouldCreate() {

   if (BDGameType(Level.Game).TooManyCars(none)){
		//log("Too many cars");
       return False;
	}
	Return True;
}

defaultproperties
{
     TeamNum=255
     PreSpawnTime=25
     RetrySpawnTime=5
     bRandomSpawn=True
     RandomVehicles(0)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniR')
     RandomVehicles(1)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniG')
     RandomVehicles(2)=(SpawnVehicle=Class'KF_Vehicles_BD.ForkLift')
     RandomVehicles(3)=(SpawnVehicle=Class'KF_Vehicles_BD.ArmyTruck')
     RandomVehicles(4)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniB')
     RandomVehicles(5)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniP')
     RandomVehicles(6)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniW')
     RandomVehicles(7)=(SpawnVehicle=Class'KF_Vehicles_BD.PoliceCar')
     RandomVehicles(8)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniPurp')
     RandomVehicles(9)=(SpawnVehicle=Class'KF_Vehicles_BD.TWCampVan')
     RandomVehicles(10)=(SpawnVehicle=Class'KF_Vehicles_BD.TaxiA')
     RandomVehicles(11)=(SpawnVehicle=Class'KF_Vehicles_BD.TWHippieCampVan')
     RandomVehicles(12)=(SpawnVehicle=Class'KF_Vehicles_BD.PoliceRiotVan')
     RandomVehicles(13)=(SpawnVehicle=Class'KF_Vehicles_BD.Ambulance')
     RandomTags(0)=(mytags="OK0")
     RandomTags(1)=(mytags="OK1")
     RandomTags(2)=(mytags="OK2")
     RandomTags(3)=(mytags="OK3")
     RandomTags(4)=(mytags="OK4")
     RandomTags(5)=(mytags="OK5")
     RandomTags(6)=(mytags="OK6")
     RandomTags(7)=(mytags="OK7")
     RandomTags(8)=(mytags="OK8")
     RandomTags(9)=(mytags="OK9")
     RandomTags(10)=(mytags="OK10")
     RandomTags(11)=(mytags="OK11")
     RandomTags(12)=(mytags="OK12")
     RandomTags(13)=(mytags="OK13")
     RandomTags(14)=(mytags="OK14")
     RandomTags(15)=(mytags="OK15")
     RandomTags(16)=(mytags="OK16")
     RandomTags(17)=(mytags="OK17")
     RandomTags(18)=(mytags="OK18")
     RandomTags(19)=(mytags="OK19")
     RandomTags(20)=(mytags="OK20")
     RandomTags(21)=(mytags="OK21")
     RandomTags(22)=(mytags="OK22")
     RandomTags(23)=(mytags="OK23")
     RandomTags(24)=(mytags="OK24")
     RandomTags(25)=(mytags="OK25")
     RandomTags(26)=(mytags="OK26")
     RandomTags(27)=(mytags="OK27")
     RandomTags(28)=(mytags="OK28")
     RandomTags(29)=(mytags="OK29")
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
}
