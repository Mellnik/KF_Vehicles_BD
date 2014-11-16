class BDFuelCan_Fire extends BaseProjectileFire;

var() float FireDelay;
var Emitter MTipFlame;

//-----------------------------------------------------------
//  AllowFire
//-----------------------------------------------------------
simulated function bool AllowFire()
{
    if (Instigator != None && Instigator.DrivenVehicle != None)
    {
        if ((Instigator.DrivenVehicle != None && ThisModeNum == 1) || (Instigator.DrivenVehicle.IsA('BDWeaponPawn') && ThisModeNum == 1))// && ThisModeNum == 1) //ThisModeNum
        {
            //log("========> AllowFire() Returning False");
            return false;
        }
    }
    //log("========> AllowFire() Returning True");
	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
    if (super.AllowFire())
        return true;
}

//-----------------------------------------------------------
//  DoFireEffects
//-----------------------------------------------------------
function DoFireEffect()
{
 if (MTipFlame == None)
  {
   MTipFlame = spawn(class'BDMatch_Flame');
   Weapon.AttachToBone(MTipFlame, 'Matchstick');
  }
 SetTimer(FireDelay, false);
}

//-----------------------------------------------------------
//  CheckFire
//-----------------------------------------------------------
function CheckFire()
{
    local Vector    StartProj, StartTrace, X,Y,Z;
    local Rotator   R, Aim;
    local Vector    HitLocation, HitNormal;
    local Actor     Other;
    local int       p;
    local int       SpawnCount;
    local float     theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        SpawnProjectile(StartProj, Aim);
    }
}

//-----------------------------------------------------------
//  Timer
//-----------------------------------------------------------
event Timer()
{
    //DoFireEffect();
         //PlayFiring();
    //FlashMuzzleFlash();
    CheckFire();
    Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,Default.FireAnimRate/FireAnimRate,false);
    Weapon.PlayAnim(Weapon.SelectAnim, Weapon.SelectAnimRate, 0.0);
}

//-----------------------------------------------------------
//  PlayFiring
//-----------------------------------------------------------
function PlayFiring()
{
	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if ( Weapon.HasAnim(FireLoopAnim) )
			{
				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
			}
			else
			{
				Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
			}
		}
		else
		{
			Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
		}
	}
    //Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,Default.FireAnimRate/FireAnimRate,false);
    ClientPlayForceFeedback(FireForce);  // jdf

    FireCount++;
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
     FireDelay=1.500000
     bFireOnRelease=True
     FireAnim="matchthrow"
     FireLoopAnim=
     FireEndAnim=
     FireRate=1.000000
     ProjectileClass=Class'KF_Vehicles_BD.BDFuelCan_MatchProjectile'
}
