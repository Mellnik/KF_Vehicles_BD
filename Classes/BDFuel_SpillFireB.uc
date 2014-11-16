//-----------------------------------------------------------
// Game:      RoadKill Warriors
// Engine:    UnrealTournament 2004
// Creators:  RKW Team
// URL:       www.RoadKillWarriors.com
//
// Copyright (C) 2005  Dustin 'Capone' Brown
//-----------------------------------------------------------
class BDFuel_SpillFireB extends Projectile;

var Emitter Flames;
var bool    bOnFire;

simulated function PreBeginPlay()
{
	CatchFire();
}

//-----------------------------------------------------------
//  Destroyed
//-----------------------------------------------------------
simulated function Destroyed()
{
  local int i;

    if(Flames != None)
     {
      for (i=0; i < Flames.Emitters.Length; i++)
       {
        Flames.Kill();
       }
     }
    Super.Destroyed();
}

//-----------------------------------------------------------
//  CatchFire
//-----------------------------------------------------------
simulated function CatchFire()
{
    if (bOnFire)
        return;
    bOnFire=true;

    Flames=Spawn(class'BDFuelFlameB');

    LifeSpan = default.LifeSpan;
    GotoState('OnFire');
}

//-----------------------------------------------------------
//  State OnFire
//-----------------------------------------------------------
simulated State OnFire
{
    simulated function Spread()
    {
      local BDFuel_SpillFire    SF;

      foreach RadiusActors(class'BDFuel_SpillFire', SF, 120)
      {
          if (!SF.bOnFire)
           {
            SF.CatchFire();
           }
      }
    }

    simulated function FindPlayers()
    {
     local xPawn P;
     
     foreach RadiusActors(class'xPawn', P, 150)
     {
      AttachFlames(P);
     }
    }

    simulated function AttachFlames(xPawn P)
    {
      local BDFlameThrower_FireAttachment NewAttach, OldAttach;

      foreach RadiusActors(class'BDFlameThrower_FireAttachment', OldAttach, 100)
      {
       if (OldAttach.Base == P)
       {
        OldAttach.LifeSpan = 3.0;
        return;
       }
      }
      NewAttach = Spawn(class'BDFlameThrower_FireAttachment',P,,P.Location);
      NewAttach.actFire = P;
      NewAttach.SetBase(P);
      NewAttach.Instigator = Instigator;
    }

Begin:
       Sleep(0.30);
       Spread();
       FindPlayers();
       HurtRadius(Damage, DamageRadius, MyDamageType, 0, Location);
       Goto('Begin');
}

//-----------------------------------------------------------
//  Touch
//-----------------------------------------------------------
simulated function Touch(Actor Other) //singular
{
    return;
}

//-----------------------------------------------------------
//  HurtRadius
//-----------------------------------------------------------
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
local actor Victims;
local float dist;
local vector dir;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;
			Victims.TakeDamage(DamageAmount,Instigator,	Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir, (Momentum * dir),	DamageType);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched!=Instigator) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		Victims.TakeDamage(DamageAmount,Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir, (Momentum * dir),DamageType);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
	}

	bHurtEntry = false;
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
     Damage=10.000000
     DamageRadius=150.000000
     MyDamageType=Class'KFMod.DamTypeBurned'
     Physics=PHYS_None
     LifeSpan=10.000000
     SoundVolume=51
     CollisionRadius=60.000000
     CollisionHeight=150.000000
     bCollideActors=False
     bCollideWorld=False
}
