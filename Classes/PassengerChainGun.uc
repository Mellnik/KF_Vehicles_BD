class PassengerChainGun extends BDVisibleHullMG;


#exec OBJ LOAD FILE=..\Animations\BDVehiclesB.ukx
#exec OBJ LOAD FILE=..\Textures\BDVehicle_T.utx

var() int    SpinSpeed;
var() float  MaxPitchSpeed;

var()  sound FireSoundClass2;
var()  sound FireSoundClass3;

var bool           Spindown;
var rotator        R;

var localized   string  JammedMessage;

replication
{
    reliable if (Role == ROLE_Authority)
        spinspeed, spindown;
}


function HandleReload()
{

	if( NumMags > 0 && !bReloading)
	{
PlayerController(Instigator.Controller).ClientMessage(JammedMessage, 'CriticalEvent');
		bReloading = true;
		NumMags--;
		ClientDoReload();
		NetUpdateTime = Level.TimeSeconds - 1;

		//log("Reloading duration = "$VehicleWeaponPawn(Owner).HUDOverlay.GetAnimDuration('fire', 1.0));
		//SetTimer(VehicleWeaponPawn(Owner).HUDOverlay.GetAnimDuration('fire', 1.0), false);
        SetTimer(ReloadLength, false);
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
		 if (Level.NetMode != NM_DedicatedServer)

			SpinSpeed -= 1000;

			else

			Spinspeed -= 10000;

		}
	   
	   else
       {
          SpinSpeed=0;
          SpinDown=False;
          Disable('Tick');
      

	  }
    }
}


simulated function InitEffects()
{
	spindown = True;
	SPinspeed = 0;
	Disable ('Tick');

	
	super.InitEffects();
}



simulated function Tick(float DeltaTime)
{


    spinRotor(DeltaTime);
    UpdateRotorSpeed(DeltaTime);

    Super.Tick(DeltaTime);
}


simulated function spinRotor (float DeltaTime)
{
   if (R.Roll >= 65535)
       R.Roll = 0;


   R.Roll += SpinSpeed * DeltaTime;
   SetBoneRotation('Barrels', R, 0, 1);


}






function CeaseFire(Controller C, bool bWasAltFire)
{
	super.CeaseFire(C, bWasAltFire);

		 if (Level.NetMode == NM_DedicatedServer)
			{	
				SpinDown=True;
				Disable ('Tick');
               PlaySound(FireSoundClass2,slot_none, FireSoundVolume/255.0,, FireSoundRadius,, false);                           
			}
			else
			{
				Spindown=True;
               PlaySound(FireSoundClass2,slot_none, FireSoundVolume/255.0,, FireSoundRadius,, false);
			}
				
}



Simulated event FlashMuzzleFlash(bool bWasAltFire)
{

          SpinDown=False;
          Enable('Tick');
                PlaySound(FireSoundClass3, slot_none, FireSoundVolume/255.0,, FireSoundRadius,, false); 
	super.FlashMuzzleFlash(bWasAltFire);
}

defaultproperties
{
     FireSoundClass2=Sound'KF_BasePatriarch.Attack.Kev_MG_TurbineWindDown'
     FireSoundClass3=Sound'BDVehicles_A.AttackHeli.turbine'
     JammedMessage="OVERHEATED!"
     NumMags=500
     ReloadLength=5.000000
     YawBone="Yaw01"
     YawStartConstraint=36000.000000
     YawEndConstraint=63000.000000
     PitchBone="GunBody"
     PitchUpLimit=6000
     WeaponFireAttachmentBone="Bone01"
     GunnerAttachmentBone="GunnerPos"
     WeaponFireOffset=0.200000
     DualFireOffset=5.000000
     Spread=0.015000
     FlashEmitterClass=Class'KF_Vehicles_BD.CGMuzzleFlash'
     FireSoundClass=Sound'BDVehicles_A.AttackHeli.MGFire'
     FireSoundVolume=512.000000
     FireForce="Explosion05"
     DamageMin=30
     DamageMax=40
     TraceRange=20000.000000
     Momentum=150000.000000
     ProjectileClass=Class'KFMod.BoomStickBullet'
     ShakeRotTime=0.000000
     MaxPositiveYaw=36000
     MaxNegativeYaw=63000
     InitialPrimaryAmmo=100
     Mesh=SkeletalMesh'BDVehiclesB.chaingunb'
     Skins(0)=Combiner'BDVehicle_T.HoverTankGroup.CGFinal'
}
