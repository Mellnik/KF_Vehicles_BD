//===================================================================
//Borrowed from:  ROMountedTankMG Copyright (C) 2004 John "Ramm-Jaeger"  Gibson
//
//===================================================================

class BDMountedMG extends ROVehicleWeapon
      abstract;

static function StaticPrecache(LevelInfo L)
{
   // L.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
}

simulated function UpdatePrecacheMaterials()
{
   // Level.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');

    Super.UpdatePrecacheMaterials();
}

simulated function PostBeginPlay()
{
	YawConstraintDelta = (YawEndConstraint - YawStartConstraint) & 65535;
	super.postbeginplay();
}

// Limit the left and right movement of the turret based on the rotation of the vehicle
simulated function int LimitYaw(int yaw)
{

    if ( !bLimitYaw )
    {
        return yaw;
    }

}

function byte BestMode()
{
	return 0;
}

defaultproperties
{
     bUsesTracers=True
     bIsMountedTankMG=True
     YawBone="Object01"
     PitchBone="Object02"
     PitchUpLimit=12500
     PitchDownLimit=59500
     WeaponFireAttachmentBone="Object02"
     WeaponFireOffset=85.000000
     RotationsPerSecond=2.000000
     bDoOffsetTrace=True
     bIsRepeatingFF=True
     Spread=0.010000
     FireInterval=0.100000
     AmbientSoundScaling=3.000000
     FireForce="minifireb"
     DamageMin=25
     DamageMax=25
     TraceRange=15000.000000
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=1.000000,Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     bLimitYaw=True
     CullDistance=8000.000000
}
