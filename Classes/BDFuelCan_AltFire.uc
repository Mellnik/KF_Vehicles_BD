class BDFuelCan_AltFire extends KFFire;


var() float             MaxPreFireTime;
var() float             MinPreFireTime;
var() float             CyclesPerSec;
var() int               AmmoPerCycle;
var() float             FireTime;
var() Sound             FiringSound;
var() byte              FuelCanSoundVolume;
var BDFuelCan_Weapon  Gun;
var() float             PreFuelAnimTime;
var() float             FuelAmount;
var int                 FuelPause;
var int                 FuelPauseMax;
var Emitter             FuelStream;

var bool                bRefueling;

var() int               ProjPerFire;
var() Vector            ProjSpawnOffset; // +x forward, +y right, +z up



simulated function bool AllowFire()
{
	return (Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}





//-----------------------------------------------------------
//  DoFireEffect
//-----------------------------------------------------------
function DoFireEffect()
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

    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);


   if (FuelStream != None)
	{    
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
}

//-----------------------------------------------------------
//  PostBeginPlay
//-----------------------------------------------------------
function PostBeginPlay()
{
    super.PostBeginPlay();
    FireRate = 1.f / (AmmoPerCycle * CyclesPerSec);
    MaxPreFireTime = 65536.f*CyclesPerSec;
    Gun = BDFuelCan_Weapon(Weapon);
}

//-----------------------------------------------------------
//  FlashMuzzleFlash
//-----------------------------------------------------------
function FlashMuzzleFlash()
{
}

//-----------------------------------------------------------
//  InitEffects
//-----------------------------------------------------------
function InitEffects()
{
    Super.InitEffects();
}

//-----------------------------------------------------------
//  PlayAmbientSound
//-----------------------------------------------------------
function PlayAmbientSound(Sound aSound)
{
    if ( (BDFuelCan_Weapon(Weapon) == None) || (Instigator == None) || (aSound == None && ThisModeNum != Gun.CurrentMode) )
        return;

	if(aSound == None)
		Instigator.SoundVolume = Instigator.default.SoundVolume;
	else
		Instigator.SoundVolume = FuelCanSoundVolume;

    Instigator.AmbientSound = aSound;
    Gun.CurrentMode = ThisModeNum;
}

//-----------------------------------------------------------
//  StopRolling
//-----------------------------------------------------------
function StopRolling()
{
    if (Gun == None)
        return;

    MinPreFireTime = 0.f;
}

function PlayPreFire() {}
function PlayStartHold() {}
function PlayFiring() {}
function PlayFireEnd() {}
function StartFiring();
function StopFiring();
function bool IsIdle()
{
	return false;
}

auto state Idle
{
	function bool IsIdle()
	{
		return true;
	}

    function BeginState()
    {
        StopRolling();
    }

    function EndState()
    {
    }

    function StartFiring()
    {
        MinPreFireTime = 0;
		FireTime = (MinPreFireTime/MaxPreFireTime) * PreFuelAnimTime;
        GotoState('PreFire');
    }
}

state PreFire
{
    function BeginState()
    {
        Gun.PlayAnim(PreFireAnim, FireLoopAnimRate, TweenTime);
    }

    function EndState()
    {
     if (MinPreFireTime < MaxPreFireTime)
         Gun.PlayAnim(FireEndAnim, FireAnimRate, TweenTime);
    }

    function ModeTick(float dt)
    {
        FireTime += dt;
        MinPreFireTime = (FireTime/PreFuelAnimTime) * MaxPreFireTime;

        if ( !bIsFiring )
        {
			GotoState('EndFire');
			return;
		}

        if (MinPreFireTime >= MaxPreFireTime)
        {
            MinPreFireTime = MaxPreFireTime;
            FireTime = PreFuelAnimTime;

                        GotoState('FireLoop');
            return;
        }
    }

    function StopFiring()
    {
        GotoState('EndFire');
    }
}

state FireLoop
{
    function BeginState()
    {
       if (FuelStream == None)
        FuelStream = spawn(class'BDFuel_Flow');
        Weapon.AttachToBone(FuelStream, 'Nozzle');
        //Instigator.AmbientSound = sound'BDVehicles_A.Fuel.PourLoop';
        FuelPause = default.FuelPause;
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
        PlayAmbientSound(FiringSound);
        Gun.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);
    }

    function StopFiring()
    {
        GotoState('EndFire');
    }

    function EndState()
    {
        if (FuelStream != None)
            FuelStream.Destroy();
        Gun.PlayAnim(FireEndAnim, FireAnimRate, TweenTime);
     }

    function ModeTick(float dt)
    {
	local Vector StartTrace, EndTrace, X, Y, Z;
	local Vector HitLocation, HitNormal;
	local Actor Other;
        local int NewFA;
	local Vehicle V;

        Super.ModeTick(dt);

        if (Weapon.AmmoAmount(ThisModeNum) <= 0)
         {
          GotoState('EndFire');
          return;
         }

       if (FuelStream == None && !bRefueling)
        FuelStream = spawn(class'BDFuel_Flow');
       else if (FuelStream != None && bRefueling)
        FuelStream.Destroy(); 
	StartTrace = Instigator.Location + Instigator.EyePosition();
	Weapon.GetViewAxes(X, Y, Z);
	EndTrace = StartTrace + TraceRange * X;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true, vect(16, 16, 16));
        if (FuelPause >= default.FuelPauseMax)
            FuelPause = default.FuelPause;
        if (FuelPause < default.FuelPauseMax)
            FuelPause++;
        if ( !bIsFiring )
        {
			GotoState('EndFire');
			return;
	}
        foreach Weapon.VisibleCollidingActors( class 'Vehicle', V, 200, HitLocation ) //DamageRadius
	{
         if (BDWheeledvehicle(V).Fuel < BDWheeledvehicle(V).MaxFuel)
         {
          Instigator.ReceiveLocalizedMessage(class'BDMessageGas', 1);
          if ((BDWheeledvehicle(V).Fuel + default.FuelAmount) > BDWheeledvehicle(V).MaxFuel)
           {
            bRefueling=true;
            NewFA = (BDWheeledvehicle(V).Fuel + default.FuelAmount) - BDWheeledvehicle(V).MaxFuel;
              if (FuelPause == default.FuelPauseMax)
                  BDWheeledvehicle(V).Fuel += NewFA;
           }
          if ((BDWheeledvehicle(V).Fuel + default.FuelAmount) <= BDWheeledvehicle(V).MaxFuel)
           {
            bRefueling=true;
            if (FuelPause == default.FuelPauseMax)
                BDWheeledvehicle(V).Fuel += FuelAmount;
           }
         }
         else
           Instigator.ReceiveLocalizedMessage(class'BDMessageGas', 0);
	}
    }
}

state EndFire
{
    function BeginState()
    {
     Instigator.AmbientSound = None;
    }

    function ModeTick(float dt)
    {
        FireTime -= dt;
        MinPreFireTime = (FireTime/PreFuelAnimTime) * MaxPreFireTime;

        if (MinPreFireTime <= 0.f)
        {
            MinPreFireTime = 0.f;
            FireTime = 0.f;
            bRefueling=false;
            GotoState('Idle');
            return;
        }
    }

    function StartFiring()
    {
        GotoState('PreFire');
    }
}

//-----------------------------------------------------------
//  SpawnProjectile
//-----------------------------------------------------------
function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    if( ProjectileClass != None )
        p = Weapon.Spawn(ProjectileClass,,, Start, Dir);

    if( p == None )
        return None;

    p.Damage *= DamageAtten;
    return p;

}

//-----------------------------------------------------------
//  GetFireStart
//-----------------------------------------------------------
simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Instigator.Location + Instigator.EyePosition() + X*ProjSpawnOffset.X + Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
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
     MinPreFireTime=0.270000
     CyclesPerSec=3.000000
     AmmoPerCycle=2
     FiringSound=Sound'BDVehicles_A.Fuel.PourLoop'
     FuelCanSoundVolume=220
     PreFuelAnimTime=0.270000
     FuelAmount=2.000000
     FuelPauseMax=3
     ProjPerFire=1
     ProjSpawnOffset=(Z=-20.000000)
     DamageType=Class'KFMod.DamTypeFlameNade'
     DamageMin=35
     DamageMax=45
     TraceRange=50.000000
     Momentum=0.000000
     bPawnRapidFireAnim=True
     PreFireAnim="Start"
     FireLoopAnim="Fill"
     FireEndAnim="Stop"
     AmmoClass=Class'KF_Vehicles_BD.BDFuelCanAmmo'
     AmmoPerFire=1
     ProjectileClass=Class'KF_Vehicles_BD.BDFuelCan_Projectile'
     BotRefireRate=0.990000
}
