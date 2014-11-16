//==================================================================================
// TeamVehicleFactory.
// Spawn any Vehicle or Turret, set Team, pre & post spawn Events, timing, and more.
// Glenn 'SuperApe' Storm -- June 2004 -- Updated: July 2005
//==================================================================================
class BDVehicleFactory extends SVehicleFactory
        placeable;
 
var()     int       TeamNum;            // 0= red, 1= blue, 255= neutral / none
var()     bool      bPlayerControl;     // Only player instigators can trigger
 
var()     bool      bAutoSpawn;         // Will spawn at regular intervals
var()     int       RespawnTime;        // Interval to wait before AutoSpawning
 
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

var()     bool      SpawnOnce;		//Factory can either spawn one time only or respawn

var(Events) const name OnKilledEvent;   //event when vehicle is destroyed
 
struct SpawnedVehicle
{
     var() class<BDWheeledVehicle> SpawnVehicle; // Selected random vehicle class
};
var()     array<SpawnedVehicle>     RandomVehicles;   // List for random vehicle spawn
 
 
simulated function PostBeginPlay()
{
     Super.PostBeginPlay();
 
     if ( bAutoSpawn )
          bWaiting = true;
          bPreSpawn = true;
          if ( RespawnTime > 0 )
               FactoryTime = Level.TimeSeconds - RespawnTime + PreSpawnTime;
          else
               FactoryTime = Level.TimeSeconds - PreSpawnTime;
}
 
simulated event Trigger( Actor Other, Pawn EventInstigator )
{


     if ( bAutoSpawn )
          // bAutoSpawn overrides Trigger
          return;
 
     if ( !EventInstigator.IsA('KFHumanPawn') && bPlayerControl )
          return;
 
     if ( VehicleCount >= MaxVehicleCount )
          return;
 
/* 
     if ( VehicleClass == None || ( bRandomSpawn && RandomVehicles.length > 0 ) )
     {
          Log("TeamVehicleFactory:"@self@"has no VehicleClass");
          return;
     }
*/
     if (!bdisabled)
     {		
     bWaiting = true;
     bPreSpawn = true;
     	if ( RespawnTime > 0 )
        	  FactoryTime = Level.TimeSeconds - RespawnTime + PreSpawnTime;
     	else
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
	 	local vector TrySpawnPoint;
//	local KFPlayerReplicationInfo PRI;
//	
//	PRI = KFPlayerReplicationInfo(P.PlayerReplicationInfo);

 
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
 
     if ( bBlocked && !bCrushable || PlayerCanSeePoint(TrySpawnPoint) )
     {
          bWaiting = true;
          bPreSpawn = true;
          if ( RespawnTime > 0 )
               FactoryTime = Level.TimeSeconds - RespawnTime + RetrySpawnTime + PreSpawnTime;
          else
               FactoryTime = Level.TimeSeconds - RetrySpawnTime + PreSpawnTime;
          return;
     }
     else
     {
          CreatedVehicle = spawn(VehicleClass, , , Location, Rotation);
 	  
		
          if ( CreatedVehicle != None && SpawnOnce )
          {
               VehicleCount++;
               CreatedVehicle.Event = Tag;
               CreatedVehicle.ParentFactory = self;
               CreatedVehicle.SetTeamNum(TeamNum);
               TriggerEvent(SpawnEvent, self, none);
	       bDisabled = True;
          }
		else
	  {
               VehicleCount++;
               CreatedVehicle.Event = Tag;
               CreatedVehicle.ParentFactory = self;
               CreatedVehicle.SetTeamNum(TeamNum);
               TriggerEvent(SpawnEvent, self, none);
	       bDisabled = False;
	  }	
     }
}
 
event VehicleDestroyed(Vehicle V)
{
     Super.VehicleDestroyed(V);

     if ( OnKilledEvent != '' ) {
          TriggerEvent( OnKilledEvent, self, None );
     }

     if ( bAutoSpawn && !SpawnOnce )
     {
          bWaiting = true;
          bPreSpawn = true;
          FactoryTime = Level.TimeSeconds;
     }
}
 
simulated function Tick(float DeltaTime)
{
     if ( bWaiting )
     {
          if ( Level.TimeSeconds - FactoryTime < RespawnTime - PreSpawnTime )
               return;
 
          if ( VehicleCount < MaxVehicleCount )
                    if ( !bPreSpawn )
                    {
                         if ( Level.TimeSeconds - FactoryTime >= RespawnTime )
                         {
                              bWaiting = false;
                              FactoryTime = Level.TimeSeconds;
                              SpawnItNow();
                         }
                    }
                    else
                    {
                         bPreSpawn = false;
                         TriggerEvent(PreSpawnEvent, self, None);
                    }
     }
}

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
	

defaultproperties
{
     TeamNum=255
     RespawnTime=40
     RetrySpawnTime=10
     bRandomSpawn=True
     SpawnOnce=True
     RandomVehicles(0)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniR')
     RandomVehicles(1)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniG')
     RandomVehicles(2)=(SpawnVehicle=Class'KF_Vehicles_BD.ForkLift')
     RandomVehicles(3)=(SpawnVehicle=Class'KF_Vehicles_BD.ArmyTruck')
     RandomVehicles(4)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniB')
     RandomVehicles(5)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniP')
     RandomVehicles(6)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniW')
     RandomVehicles(7)=(SpawnVehicle=Class'KF_Vehicles_BD.PoliceCar')
     RandomVehicles(8)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniPurp')
}
