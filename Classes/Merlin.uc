//-----------------------------------------------------------
// Combine Helicopter
//-----------------------------------------------------------
class Merlin extends ROChopperCraft
    placeable;

#exec OBJ LOAD FILE=..\Animations\BDVehiclesB.ukx
#exec obj load file=..\sounds\BDVehicles_A.uax
#exec obj load file=..\Textures\kf_generic_t.utx


var Actor LastAttackedTarget;
var() sound DropMineSound;
var byte BombDropCounter;
var		array<vector>		ThrusterOffsets;
var()	float				HoverSoftness;
var()	float				HoverPenScale;
var()	float				HoverCheckDist;

var() int    SpinSpeed;
var() float  MaxPitchSpeed;

var bool           Spindown;
var rotator        R;
var rotator        J;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		BombDropCounter;
}

simulated exec function ToggleIronSights()
{

	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

//	bWeaponIsAltFiring = true;
////	PC.ToggleZoom();
	PC.ToggleBehindView();
}


function AltFire(optional float F)
{

}

simulated event SVehicleUpdateParams()
{
	local KarmaParams kp;
	local int i;

	Super.SVehicleUpdateParams();

	kp = KarmaParams(KParams);

    for(i=0;i<kp.Repulsors.Length;i++)
	{
        kp.Repulsors[i].Softness = HoverSoftness;
        kp.Repulsors[i].PenScale = HoverPenScale;
        kp.Repulsors[i].CheckDist = HoverCheckDist;
    }
}


simulated function DrawHUD(Canvas Canvas)
{}
simulated function PostNetBeginPlay()
{
//	if( Level.NetMode!=NM_DedicatedServer )
//		LoopAnim('Idle',,,0);

	local vector RotX, RotY, RotZ;
	local KarmaParams kp;
	local KRepulsor rep;
	local int i;

	BombDropCounter = 0;
	bNetNotify = True;
	Super.PostNetBeginPlay();


    GetAxes(Rotation,RotX,RotY,RotZ);

	// Spawn and assign 'repulsors' to hold bike off the ground
	kp = KarmaParams(KParams);
	kp.Repulsors.Length = ThrusterOffsets.Length;

	for(i=0;i<ThrusterOffsets.Length;i++)
	{
    	rep = spawn(class'KRepulsor', self,, Location + ThrusterOffsets[i].X * RotX + ThrusterOffsets[i].Y * RotY + ThrusterOffsets[i].Z * RotZ);
    	rep.SetBase(self);
    	rep.bHidden = true;
    	rep.bRepulseWater = True;
    	kp.Repulsors[i] = rep;
    }

    J.Pitch=0;
    R.Yaw=0;

bteamlocked=false;
}


simulated function PostNetReceive()
{
	if( BombDropCounter!=0 )
	{
		BombDropCounter = 0;
		PlayDeployAnim();
		if( Weapons[0]!=None )
			Weapons[0].FireCountdown = 2;
	}
	Super.PostNetReceive();

}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType, optional int HitIndex)
{
	local int ActualDamage;
	local Controller Killer;

	// Spawn Protection: Cannot be destroyed by a player until possessed
	if ( bSpawnProtected && instigatedBy != None && instigatedBy != Self )
		return;

	NetUpdateTime = Level.TimeSeconds - 1; // force quick net update

	if (DamageType != None && DamageType != class'DamTypeWelder')
	{
		if ((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
			instigatedBy = DelayedDamageInstigatorController.Pawn;

		Damage *= DamageType.default.VehicleDamageScaling;
		momentum *= DamageType.default.VehicleMomentumScaling * MomentumMult;

	        if (bShowDamageOverlay && DamageType.default.DamageOverlayMaterial != None && Damage > 0 )
			    SetOverlayMaterial( DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, false );
	}

	if (DamageType != None && DamageType == class'DamTypeWelder')
	{
		Health = Health+1;
	}


	if (bRemoteControlled && Driver!=None)
	{
	    ActualDamage = Damage;
	    if (Weapon != None && Weapon != class'BDWelder')
	        Weapon.AdjustPlayerDamage(ActualDamage, InstigatedBy, HitLocation, Momentum, DamageType );
	    if (InstigatedBy != None && InstigatedBy.HasUDamage())
	        ActualDamage *= 2;

	    ActualDamage = Level.Game.ReduceDamage(ActualDamage, self, instigatedBy, HitLocation, Momentum, DamageType);

	    if (Health - ActualDamage <= 0)
	       	KDriverLeave(false);
	}

	if ( Physics != PHYS_Karma )
	{
		super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType);
		return;
	}

	if (Weapon != None)
	        Weapon.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	if (InstigatedBy != None && InstigatedBy.HasUDamage())
		Damage *= 2;
	ActualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	Health -= ActualDamage;

	PlayHit(actualDamage, InstigatedBy, hitLocation, damageType, Momentum);
	// The vehicle is dead!
	if ( Health <= 0 )
	{

		if ( Driver!=None && (bEjectDriver || bRemoteControlled) )
		{
			if ( bEjectDriver )
				EjectDriver();
			else
				KDriverLeave( false );
		}

		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.GetKillerController();
		if ( Killer == None && (DamageType != None) && DamageType.Default.bDelayedDamage )
			Killer = DelayedDamageInstigatorController;
		Died(Killer, damageType, HitLocation);
	}
	else if ( Controller != None )
		Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);

	MakeNoise(1.0);

	if ( !bDeleteMe )
	{
		if ( Location.Z > Level.StallZ )
			Momentum.Z = FMin(Momentum.Z, 0);
		KAddImpulse(Momentum, hitlocation);
	}
}



/*
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType,optional int h)
{
	if(instigatedby!=self)health-=damage;
	Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}
*/

// AI hint
function bool FastVehicle()
{
	return true;
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	if ( FRand() < 0.7 )
	{
		VehicleMovingTime = Level.TimeSeconds + 1;
		Rise = 1;
	}
	return false;
}
function ChooseFireAt(Actor A)
{
	local vector V;

	if (ActiveWeapon < Weapons.length)
	{
		V = (A.Location+A.Velocity*1.5)-Location;
		V.Z = 0;
		if( VSize(V)>400 )
			Fire(0);
		else AltFire(0);
	}
}

simulated event Destroyed()
{
	local KarmaParams kp;
	local int i;

	// Destroy repulsors
	kp = KarmaParams(KParams);
	for(i=0;i<kp.Repulsors.Length;i++)
    	kp.Repulsors[i].Destroy();

    kp.Repulsors.Length = 0;

	Super.Destroyed();
}

function ServerPlayHorn(int HornIndex); // This one has no horn sounds


function KDriverEnter(Pawn P)
{
	bHeadingInitialized = False;
	Super.KDriverEnter(P);
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	bHeadingInitialized = False;
	Super.ClientKDriverEnter(PC);
}

exec function ToggleViewLimit()
{
}


simulated event DrivingStatusChanged()
{
	local KarmaParams kp;
	local int i;

	kp = KarmaParams(KParams);

    if (bDriving)
    {
        SpinDown=False;
        Enable('Tick');
        for(i=0;i<kp.Repulsors.Length;i++)
           kp.Repulsors[i].bEnableRepulsion=true;
    }
    else
    {
        SpinDown=True;
        for(i=0;i<kp.Repulsors.Length;i++)
           kp.Repulsors[i].bEnableRepulsion=false;
    }
}

simulated function UpdateRotorSpeed(float DeltaTime)
{
    if (!SpinDown)
    {
       SpinSpeed = 305000.00;
    }
    else
    {
       if (SpinSpeed > 0)
       {
          SpinSpeed -= 1000;
       }
       else
       {
          SpinSpeed=0;
          SpinDown=False;
          Disable('Tick');
       }
    }
}




simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector CamLookAt, HitLocation, HitNormal, OffsetVector;
	local Actor HitActor;
	local vector x, y, z;

	if (DesiredTPCamDistance < TPCamDistance)
		TPCamDistance = FMax(DesiredTPCamDistance, TPCamDistance - CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));
	else if (DesiredTPCamDistance > TPCamDistance)
		TPCamDistance = FMin(DesiredTPCamDistance, TPCamDistance + CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));

	GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;
	CamLookAt = GetCameraLocationStart() + (TPCamLookat >> Rotation) + TPCamWorldOffset;

	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCamDistance;

	CameraLocation = CamLookAt + (OffsetVector >> PC.Rotation);

	HitActor = Trace(HitLocation, HitNormal, CameraLocation, Location, true, vect(40, 40, 40));
	if ( HitActor != None
	     && (HitActor.bWorldGeometry || HitActor == GetVehicleBase() || Trace(HitLocation, HitNormal, CameraLocation, Location, false, vect(40, 40, 40)) != None) )
			CameraLocation = HitLocation;

	CameraRotation = Normalize(PC.Rotation + PC.ShakeRot);
	CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

function float ImpactDamageModifier()
{
	local float Multiplier;
	local vector X, Y, Z;

	GetAxes(Rotation, X, Y, Z);
	if (ImpactInfo.ImpactNorm Dot Z > 0)
		Multiplier = 1-(ImpactInfo.ImpactNorm Dot Z);
	else Multiplier = 1.0;

	return Super.ImpactDamageModifier() * Multiplier;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

//FIXME Fix to not be specific to this class after demo
function bool PlaceExitingDriver()
{
	local int i;
	local vector tryPlace, Extent, HitLocation, HitNormal, ZOffset;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent *= 2;
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,1);
	if (Trace(HitLocation, HitNormal, Location + (ZOffset * 6), Location, false, Extent) != None)
		return false;

	//avoid running driver over by placing in direction perpendicular to velocity
	if ( VSize(Velocity) > 100 )
	{
		tryPlace = Normal(Velocity cross vect(0,0,1)) * (CollisionRadius + Driver.default.CollisionRadius ) * 1.25 ;
		if ( FRand() < 0.5 )
			tryPlace *= -1; //randomly prefer other side
		if ( (Trace(HitLocation, HitNormal, Location + tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location + tryPlace + ZOffset))
		     || (Trace(HitLocation, HitNormal, Location - tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location - tryPlace + ZOffset)) )
			return true;
	}

	for( i=0; i<ExitPositions.Length; i++)
	{
		if ( ExitPositions[0].Z != 0 )
			ZOffset = Vect(0,0,1) * ExitPositions[0].Z;
		else
			ZOffset = Driver.default.CollisionHeight * vect(0,0,2);

		if ( bRelativeExitPos )
			tryPlace = Location + ( (ExitPositions[i]-ZOffset) >> Rotation) + ZOffset;
		else
			tryPlace = ExitPositions[i];

		// First, do a line check (stops us passing through things on exit).
		if ( bRelativeExitPos && Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None )
			continue;

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

}

simulated function UpdatePrecacheStaticMeshes()
{

	Super.UpdatePrecacheStaticMeshes();
}
simulated function PlayDeployAnim()
{
	AnimBlendParams(1, 1.0, 0.0, 0.2, 'Chopper_Deploy_Mech_Back');
	PlayAnim('Deploy',,,1);
	AnimBlendParams(2, 1.0, 0.0, 0.2, 'Chopper_Deploy_Mech_Forward');
	PlayAnim('Deploy',,,2);
}
simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();
}

simulated function Tick(float DeltaTime)
{
    spinRotor(DeltaTime);
    UpdateRotorSpeed(DeltaTime);

    Super.Tick(DeltaTime);
}

simulated function spinRotor (float DeltaTime)
{
   if (R.Yaw >= 65535)
       R.Yaw = 0;

   if (J.Pitch >= 65535)
       J.Pitch = 0;

   R.Yaw += SpinSpeed * DeltaTime;
   J.Pitch += SpinSpeed * DeltaTime;
   SetBoneRotation('Object01', R, 0, 1);
   SetBoneRotation('back_blades', J, 0, 1);
}

/*
simulated event TeamChanged()
{
	local int i;

	Super(Vehicle).TeamChanged();

	/*Skins = Default.Skins;
	if (Team == 0 && RedSkin != None)
		Skins[2] = RedSkin;
	else if (Team == 1 && BlueSkin != None)
		Skins[2] = BlueSkin;*/

	if (Level.NetMode != NM_DedicatedServer && Team <= 2 && SpawnOverlay[0] != None && SpawnOverlay[1] != None)
		SetOverlayMaterial(SpawnOverlay[Team], 1.5, True);

	//for (i = 0; i < Weapons.Length; i++)
		//Weapons[i].SetTeam(Team);
}
*/
simulated function bool PointOfView()
{
	if (!bAllowViewChange)
		return true;

	return default.bDesiredBehindView;
}

defaultproperties
{
     UprightStiffness=500.000000
     UprightDamping=300.000000
     MaxThrustForce=100.000000
     LongDamping=0.050000
     MaxStrafeForce=50.000000
     LatDamping=0.050000
     MaxRiseForce=30.000000
     UpDamping=0.050000
     TurnTorqueFactor=600.000000
     TurnTorqueMax=200.000000
     TurnDamping=50.000000
     MaxYawRate=0.700000
     PitchTorqueFactor=200.000000
     PitchTorqueMax=35.000000
     PitchDamping=40.000000
     RollTorqueTurnFactor=450.000000
     RollTorqueStrafeFactor=50.000000
     RollTorqueMax=30.000000
     RollDamping=30.000000
     StopThreshold=100.000000
     MaxRandForce=3.000000
     RandForceInterval=0.750000
     DriverWeapons(0)=(WeaponClass=Class'KF_Vehicles_BD.BDSecondaryTurret',WeaponBone="RGun")
     PassengerWeapons(0)=(WeaponPawnClass=Class'KF_Vehicles_BD.BDPassengerChainGunPawn',WeaponBone="LGun")
     PassengerWeapons(1)=(WeaponPawnClass=Class'KF_Vehicles_BD.BDPassPawn',WeaponBone="PSeat")
     PassengerWeapons(2)=(WeaponPawnClass=Class'KF_Vehicles_BD.BDPassPawn',WeaponBone="PSeat02")
     PassengerWeapons(3)=(WeaponPawnClass=Class'KF_Vehicles_BD.BDPassPawn',WeaponBone="PSeat03")
     IdleSound=Sound'KF_EnvAmbientSnd.Machinery.Merlin_TurbineLoop'
     StartUpSound=Sound'BDVehicles_A.AttackCraft.AttackCraftStartUp'
     ShutDownSound=Sound'BDVehicles_A.AttackCraft.AttackCraftShutDown'
     StartUpForce="AttackCraftStartUp"
     ShutDownForce="AttackCraftShutDown"
     DestroyedVehicleMesh=StaticMesh'BDVehicle_SB.MerlinDestroyed'
     DestructionEffectClass=Class'KF_Vehicles_BD.BDVehicleDestroyedEmitter'
     DamagedEffectOffset=(X=-120.000000,Y=10.000000,Z=65.000000)
     VehicleMass=9.000000
     bDrawDriverInTP=True
     bTurnInPlace=True
     bDrawMeshInFP=True
     bDesiredBehindView=False
     bDriverHoldsFlag=False
     bCanCarryFlag=False
     DrivePos=(X=205.000000,Y=30.000000,Z=145.000000)
     DriveAnim="driving"
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     EntryPosition=(X=70.000000,Z=10.000000)
     EntryRadius=200.000000
     FPCamPos=(X=215.000000,Y=30.000000,Z=155.000000)
     TPCamDistance=500.000000
     TPCamLookat=(X=-260.000000,Z=200.000000)
     TPCamWorldOffset=(Z=200.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Merlin Helicopter"
     VehicleNameString="Merlin"
     MaxDesireability=0.950000
     FlagBone="PlasmaGunAttachment"
     FlagRotation=(Yaw=32768)
     GroundSpeed=2000.000000
     HealthMax=175.000000
     Health=175
     Mesh=SkeletalMesh'BDVehiclesB.Merlinmesh'
     Skins(0)=Combiner'kf_generic_t.merlinhc3_cmb'
     Skins(1)=Texture'kf_generic_t.MerlinHC3InteriorDiffuse'
     bFullVolume=True
     SoundRadius=500.000000
     CollisionRadius=150.000000
     CollisionHeight=70.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000)
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=0.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsRBFull'KF_Vehicles_BD.Merlin.KParams0'

}
