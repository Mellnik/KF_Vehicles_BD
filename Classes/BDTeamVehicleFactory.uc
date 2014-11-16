//==================================================================================
// TeamVehicleFactory.
// Spawn any Vehicle or Turret, set Team, pre & post spawn Events, timing, and more.
// Glenn 'SuperApe' Storm -- June 2004 -- Updated: July 2005
//==================================================================================
class BDTeamVehicleFactory extends SVehicleFactory
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
var()     int       RetrySpawnTime;     // Interval to wait if bBlocked
 
var()     bool      bRandomFlip;        // Neutral vehicles may face backwards
 
var()     bool      bRandomSpawn;       // Spawn random vehicle class

//var()     float     helicost;            //cost to trigger helicopter
 
struct SpawnedVehicle
{
     var() class<Vehicle> SpawnVehicle; // Selected random vehicle class
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
 
 
     if ( VehicleClass == None || ( bRandomSpawn && RandomVehicles.length > 0 ) )
     {
          Log("TeamVehicleFactory:"@self@"has no VehicleClass");
          return;
     }

		
     bWaiting = true;
     bPreSpawn = true;
     if ( RespawnTime > 0 )
          FactoryTime = Level.TimeSeconds - RespawnTime + PreSpawnTime;
     else
          FactoryTime = Level.TimeSeconds - PreSpawnTime;
}
 
simulated function SpawnItNow()
{
     local  Vehicle         CreatedVehicle;
     local  bool           bBlocked;
     local  Pawn              P;
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
 
     if ( bBlocked && !bCrushable )
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
          if ( TeamNum == 255 )
          {
               if ( bRandomFlip && Rand(2) == 1 )
                    CreatedVehicle = spawn(VehicleClass, , , Location, Rotation + rot(0,32768,0));
               else
               CreatedVehicle = spawn(VehicleClass, , , Location, Rotation);
 
               // Unlock neutral vehicles
               CreatedVehicle.bTeamLocked = false;
          }
          else
          CreatedVehicle = spawn(VehicleClass, , , Location, Rotation);
 
          if ( CreatedVehicle != None )
          {
               VehicleCount++;
               CreatedVehicle.Event = Tag;
               CreatedVehicle.ParentFactory = self;
               CreatedVehicle.SetTeamNum(TeamNum);
               TriggerEvent(SpawnEvent, self, none);
//		PRI.Score = PRI.Score - helicost;
          }
     }
}
 
event VehicleDestroyed(Vehicle V)
{
     Super.VehicleDestroyed(V);
 
     if ( bAutoSpawn )
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

defaultproperties
{
     TeamNum=255
     bAutoSpawn=True
     RespawnTime=20
     bRandomSpawn=True
     RandomVehicles(0)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniR')
     RandomVehicles(1)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniG')
     RandomVehicles(2)=(SpawnVehicle=Class'KF_Vehicles_BD.ForkLift')
     RandomVehicles(3)=(SpawnVehicle=Class'KF_Vehicles_BD.ArmyTruck')
     RandomVehicles(4)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniB')
     RandomVehicles(5)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniP')
     RandomVehicles(6)=(SpawnVehicle=Class'KF_Vehicles_BD.MiniW')
     RandomVehicles(7)=(SpawnVehicle=Class'KF_Vehicles_BD.PoliceCar')
}
