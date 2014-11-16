//-----------------------------------------------------------
// Game:      RoadKill Warriors
// Engine:    UnrealTournament 2004
// Creators:  RKW Team
// URL:       www.RoadKillWarriors.com
//
// Copyright (C) 2005  Dustin 'Capone' Brown
//-----------------------------------------------------------
class BDFuelCan_MatchProjectile extends Projectile;

var bool            bCanHitOwner, bHitWater;
var() float         DampenFactor, DampenFactorParallel;
var Actor           IgnoreActor;
var bool            bLanded;
var vector          Dir;
var Emitter         Trail;

var float           ExplodeTimer;
var class<xEmitter> HitEffectClass;
var float           LastSparkTime;
var bool            bTimerSet;

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
    //if ( Trail != None )
      //  Trail.mRegen = false; // stop the emitter from regenerating
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
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5500 )
		 {
		  Trail = Spawn(class'BDMatch_Flame', self,, Location, Rotation);
		  Trail.SetBase(self);
		 }
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
    //Explode(Location, vect(0,0,1));
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

    if (!bTimerSet)
    {
        SetTimer(ExplodeTimer, false);
        bTimerSet = true;
    }

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
        //if ( Trail != None )
        //    Trail.mRegen = false; // stop the emitter from regenerating
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
			if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
				Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
            LastSparkTime = Level.TimeSeconds;
        }
    }
}

//-----------------------------------------------------------
//  BlowUp
//-----------------------------------------------------------
simulated function BlowUp(vector HitLocation)
{
  local BDFuel_SpillFire SF;
	//DelayedHurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
    foreach RadiusActors(class'BDFuel_SpillFire', SF, 40)
     {
      SF.CatchFire();
      //log("=========> match Trying to catch fire.....");
        if ( Role == ROLE_Authority )
		MakeNoise(1.0);
     }
}

//-----------------------------------------------------------
//  Explode
//-----------------------------------------------------------
simulated function Explode(vector HitLocation, vector HitNormal)
{
    BlowUp(HitLocation);
	//PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        //Spawn(class'NewExplosionB',,, HitLocation, rotator(vect(0,0,1)));
		//Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
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
     DampenFactor=0.500000
     DampenFactorParallel=0.800000
     ExplodeTimer=2.000000
     Speed=700.000000
     MaxSpeed=700.000000
     TossZ=0.000000
     DamageRadius=50.000000
     MyDamageType=Class'KFMod.DamTypeFrag'
     ExplosionDecal=Class'KFMod.KFScorchMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'kf_generic_sm.Bullet_Shells.winchester_shell'
     Physics=PHYS_Falling
     LifeSpan=4.000000
     AmbientGlow=100
     FluidSurfaceShootStrengthMod=3.000000
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
