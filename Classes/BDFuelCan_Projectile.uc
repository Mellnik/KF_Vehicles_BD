//-----------------------------------------------------------
// Game:      RoadKill Warriors
// Engine:    UnrealTournament 2004
// Creators:  RKW Team
// URL:       www.RoadKillWarriors.com
//
// Copyright (C) 2005  Dustin 'Capone' Brown
//-----------------------------------------------------------
class BDFuelCan_Projectile extends Projectile;

var float           ExplodeTimer;
var bool            bCanHitOwner, bHitWater;
var xEmitter        Trail;
var() float         DampenFactor, DampenFactorParallel;
var class<xEmitter> HitEffectClass;
var float           LastSparkTime;
var bool            bTimerSet;

var vector          CurrentHitNormal;

replication
{
    reliable if (Role==ROLE_Authority)
        ExplodeTimer;
}

//-----------------------------------------------------------
//  Destroyed
//-----------------------------------------------------------
simulated function Destroyed()
{
    if ( Trail != None )
        Trail.mRegen = false; // stop the emitter from regenerating
	Super.Destroyed();
}

//-----------------------------------------------------------
//  PostBeginPlay
//-----------------------------------------------------------
simulated function PostBeginPlay()
{
	local PlayerController PC;

    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer)
    {
		PC = Level.GetLocalPlayerController();
		//if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5500 )
		//	Trail = Spawn(class'PanzerfaustTrail', self,, Location, Rotation);
    }

    if ( Role == ROLE_Authority )
    {
        Velocity = Speed * Vector(Rotation);
        RandSpin(25000);
        bCanHitOwner = false;
        if (Instigator.HeadVolume.bWaterVolume)
        {
            bHitWater = true;
            Velocity = 0.6*Velocity;
        }
    }
}

//-----------------------------------------------------------
//  PostNetBeginPlay
//-----------------------------------------------------------
simulated function PostNetBeginPlay()
{
	if ( Physics == PHYS_None )
    {
        SetTimer(ExplodeTimer, false);
        bTimerSet = true;
    }
}

//-----------------------------------------------------------
//  Timer
//-----------------------------------------------------------
simulated function Timer()
{
    Explode(Location, vect(0,0,1));
}

//-----------------------------------------------------------
//  Landed
//-----------------------------------------------------------
simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

//-----------------------------------------------------------
//  ProcessTouch
//-----------------------------------------------------------
simulated function ProcessTouch( actor Other, vector HitLocation )
{
    if ( Other.bWorldGeometry && (Other != Instigator || bCanHitOwner) ) //!
    {
		Explode(HitLocation, Normal(HitLocation-Other.Location));
    }
}

//-----------------------------------------------------------
//  HitWall
//-----------------------------------------------------------
simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector            VNorm;
    local PlayerController  PC;

	//if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	//{
		Explode(Location, HitNormal);
		return;
	//}

    //if (!bTimerSet)
    //{
    //    SetTimer(ExplodeTimer, false);
    //    bTimerSet = true;
    //}

    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

    RandSpin(100000);
    DesiredRotation.Roll = 0;
    RotationRate.Roll = 0;
    Speed = VSize(Velocity);

    if ( Speed < 20 )
    {
        bBounce = False;
        PrePivot.Z = -1.5;
			SetPhysics(PHYS_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);
        if ( Trail != None )
            Trail.mRegen = false; // stop the emitter from regenerating
    }
    else
    {
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 250) )
			PlaySound(ImpactSound, SLOT_Misc );
		else
		{
			bFixedRotationDir = false;
			bRotateToDesired = true;
			DesiredRotation.Pitch = 0;
			RotationRate.Pitch = 50000;
		}
        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false) )
        {
			PC = Level.GetLocalPlayerController();
			//if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
				//Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
            LastSparkTime = Level.TimeSeconds;
        }
    }
}

//-----------------------------------------------------------
//  BlowUp
//-----------------------------------------------------------
simulated function BlowUp(vector HitLocation)
{
}

//-----------------------------------------------------------
//  Explode
//-----------------------------------------------------------
simulated function Explode(vector HitLocation, vector HitNormal)
{
    if ( EffectIsRelevant(Location,false) )
    {
     CurrentHitNormal = HitNormal;
     Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));

    }
    Spawn(class'BDFuel_SpillFire',,,HitLocation, rotator(-HitNormal));
    Destroy();
}

//=====================================================================================================
//=====================================================================================================
//==
//==        D E F A U L T P R O P E R T I E S
//==
//=====================================================================================================
//=====================================================================================================

defaultproperties
{
     ExplodeTimer=2.000000
     DampenFactor=0.500000
     DampenFactorParallel=0.800000
     Speed=200.000000
     MaxSpeed=300.000000
     TossZ=0.000000
     DamageRadius=80.000000
     MyDamageType=Class'KFMod.DamTypeFrag'
     ExplosionDecal=Class'KF_Vehicles_BD.BDFuel_Decal'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'KillingFloorStatics.FragProjectile'
     Physics=PHYS_Falling
     DrawScale=0.000000
     AmbientGlow=100
     FluidSurfaceShootStrengthMod=3.000000
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
