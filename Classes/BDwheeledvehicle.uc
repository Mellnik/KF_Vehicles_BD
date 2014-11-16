//-----------------------------------------------------------
// Borrowed from roONSWheeledvehcile by TheBlackCheetah and reworked by Braindead
// 
//-----------------------------------------------------------

class BDwheeledvehicle extends BDvehicle;

var		ONSBrakelightCorona	BrakeLight[2];
var   float         CurrentRoll;
var   float         RollSpeed;
var() rotator       AttachRot;
var() float         Blend;
var() vector        AttachLoc;

// Fuel stuff

var()		sound	nofuelsound;
var() float         Fuel;
var() float         MaxFuel;
//var() bool          bFuelActive;
var() bool          bOutOfGas;
var() sound	    vehicleout;

var Texture         FuelGaugeTex, MPHGaugeTex;
var TexRotator      FuelPointer, MPHPointer;

var() int           MaxFuelPointerRotation;
var() int           MaxMPHPointerRotation;

//steering
var    rotator      SteeringRotation;
var    int          SteerVal;
var name            SteeringWheelBone;
var() float	    healthToGive;

var int AlphaAmount ; // Amount of Alpha for Cash bonus HUD.



replication
{
    reliable if (bNetDirty && Role == ROLE_Authority)
        boutofgas,Fuel;
}

/*

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
//	PC.ToggleZoom();
	PC.ToggleBehindView();


}
*/

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


//-----------------------------------------------------------
//  PreBeginPlay
//-----------------------------------------------------------
function PreBeginPlay() //Prevent Vehicle Destruction in non-vehicle gametypes...
{
  super(Pawn).PreBeginPlay();

  if (Fuel > MaxFuel)
      Fuel = MaxFuel;
  if (Fuel < 0)
      Fuel = 0;
}

//-----------------------------------------------------------
//  DrawGaugeFuel
//-----------------------------------------------------------
simulated function DrawGaugeFuel(Canvas C)
{
    local float fHeight;
    local float fWidth;
    local float fX;
    local float fY;

    //-----------------------------------------------------------
    // Draw Fuel gauge
//    fX = C.ClipX * 0.300;
//    fY = C.ClipY * 0.530;
//    fWidth = C.ClipX * 0.09375000;
//    fHeight = C.ClipY * 0.12500000;

    fX = C.ClipX * 0.150;
    fY = C.ClipY * 0.910;
    fWidth = C.ClipX * 0.09375000;
    fHeight = C.ClipY * 0.12500000;

    //-----------------------------------------------------------
    // Draw background
    C.SetPos(fX, fY);
    C.DrawTile(FuelGaugeTex, fWidth, fHeight, 0, 0, 256, 256);
    //-----------------------------------------------------------
    // Draw pointer
    C.SetPos(fX, fY);
    C.DrawTile(FuelPointer, fWidth, fHeight, 0, 0, 256, 256);
    //-----------------------------------------------------------
    // Set fuel level display
    FuelPointer.Rotation.Yaw = (Fuel * MaxFuelPointerRotation) / MaxFuel;
//DRE    C.DrawText(Fuel); //Debug Fuel, shows the fuel in numbers on screen
    //log("=========> FuelPointer.Rotation.Yaw = "$FuelPointer.Rotation.Yaw);
}

//-----------------------------------------------------------
//  DrawGaugeSpeed
//-----------------------------------------------------------
simulated function DrawGaugeSpeed(Canvas C)
{
    local float fHeight;
    local float fWidth;
    local float fX;
    local float fY;

    //-----------------------------------------------------------
    // Draw Speed gauge
    fX = C.ClipX * -0.010;
    fY = C.ClipY * 0.780;
    fWidth = C.ClipX * 0.19;
    fHeight = C.ClipY * 0.25;
    //-----------------------------------------------------------
    // Draw background
    C.SetPos(fX, fY);
    C.DrawTile(MPHGaugeTex, fWidth, fHeight, 0, 0, 512, 512);
    //-----------------------------------------------------------
    // Draw pointer
    C.SetPos(fX, fY);
    C.DrawTile(MPHPointer, fWidth, fHeight, 0, 0, 512, 512);
    //-----------------------------------------------------------
    // Set MPH display 2425=1000gs
    MPHPointer.Rotation.Yaw = (int(VSize(Velocity)) * MaxMPHPointerRotation) / 2425;
    //log("=========> MPHPointer.Rotation.Yaw = "$MPHPointer.Rotation.Yaw);
}

//-----------------------------------------------------------
//  DrawHUD
//-----------------------------------------------------------
simulated function DrawHUD(Canvas Canvas)
{
    local PlayerController PC;
    local vector CameraLocation;
    local rotator CameraRotation;
    local Actor ViewActor;

	if (IsLocallyControlled() && ActiveWeapon < Weapons.length && Weapons[ActiveWeapon] != None && Weapons[ActiveWeapon].bShowAimCrosshair && Weapons[ActiveWeapon].bCorrectAim)
	{
		Canvas.DrawColor = CrosshairColor;
		Canvas.DrawColor.A = 255;
		Canvas.Style = ERenderStyle.STY_Alpha;

		Canvas.SetPos(Canvas.SizeX*0.5-CrosshairX, Canvas.SizeY*0.5-CrosshairY);
		Canvas.DrawTile(CrosshairTexture, CrosshairX*2.0+1, CrosshairY*2.0+1, 0.0, 0.0, CrosshairTexture.USize, CrosshairTexture.VSize);
	}

    PC = PlayerController(Controller);
	if (PC != None && !PC.bBehindView && HUDOverlay != None)
	{
        if (!Level.IsSoftwareRendering())
        {
    		CameraRotation = PC.Rotation;
    		SpecialCalcFirstPersonView(PC, ViewActor, CameraLocation, CameraRotation);
    		HUDOverlay.SetLocation(CameraLocation + (HUDOverlayOffset >> CameraRotation));
    		HUDOverlay.SetRotation(CameraRotation);
    		Canvas.DrawActor(HUDOverlay, false, false, FClamp(HUDOverlayFOV * (PC.DesiredFOV / PC.DefaultFOV), 1, 170));
    	}
	}
	else
        ActivateOverlay(False);

	Super.DrawHUD(Canvas);

    //-----------------------------------------------------------
    // Draw the Fuel gauge
    DrawGaugeFuel(Canvas);
    //-----------------------------------------------------------
    // Draw the Speed gauge
    DrawGaugeSpeed(Canvas);

}




//=================================================================
// Lets make a custom vehicle.....
//=================================================================
simulated function ChangeStuff(bool bDriverOnRight, bool bRightPassenger, float NewFuel)
{
            Fuel = NewFuel;
}








simulated event SVehicleUpdateParams()
{
	local int i;

	Super.SVehicleUpdateParams();

	for(i=0; i<Wheels.Length; i++)
	{
		Wheels[i].Softness = WheelSoftness;
		Wheels[i].PenScale = WheelPenScale;
		Wheels[i].PenOffset = WheelPenOffset;
		Wheels[i].LongSlip = WheelLongSlip;
		Wheels[i].LatSlipFunc = WheelLatSlipFunc;
		Wheels[i].Restitution = WheelRestitution;
		Wheels[i].Adhesion = WheelAdhesion;
		Wheels[i].WheelInertia = WheelInertia;
		Wheels[i].LongFrictionFunc = WheelLongFrictionFunc;
		Wheels[i].HandbrakeFrictionFactor = WheelHandbrakeFriction;
		Wheels[i].HandbrakeSlipFactor = WheelHandbrakeSlip;
		Wheels[i].SuspensionTravel = WheelSuspensionTravel;
		Wheels[i].SuspensionOffset = WheelSuspensionOffset;
		Wheels[i].SuspensionMaxRenderTravel = WheelSuspensionMaxRenderTravel;
	}

	if(Level.NetMode != NM_DedicatedServer && bMakeBrakeLights)
	{
	// MergeTODO: Put this back in
		for(i=0; i<2; i++)
		{
			if (BrakeLight[i] != None)
			{
				BrakeLight[i].SetBase(None);
				BrakeLight[i].SetLocation( Location + (BrakelightOffset[i] >> Rotation) );
				BrakeLight[i].SetBase(self);
				BrakeLight[i].SetRelativeRotation( rot(0,32768,0) );
				BrakeLight[i].Skins[0] = BrakeLightMaterial;
			}
		} 
	}
}

//===========  new test ===============

function KDriverEnter(Pawn p)
{
    local int x;

    ResetTime = Level.TimeSeconds - 1;
    Instigator = self;

    super.KDriverEnter( P );

    if ( Weapons.Length > 0 )
        Weapons[ActiveWeapon].bActive = True;

    if ( IdleSound != None )
        AmbientSound = IdleSound;

if (bOutOfGas == True)
{
    if ( nofuelsound != None )
	PlaySound(Nofuelsound, Slot_None, 1.0);
}
else

if (bOutofgas == False)
{
    if ( StartUpSound != None )
        PlaySound(StartUpSound, SLOT_None, 1.0);
}

    if (xPawn(Driver) != None && Driver.HasUDamage())
    	for (x = 0; x < Weapons.length; x++)
		Weapons[x].SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, xPawn(Driver).UDamageTime - Level.TimeSeconds, false);

    Driver.bSetPCRotOnPossess = false; //so when driver gets out he'll be facing the same direction as he was inside the vehicle

	for (x = 0; x < Weapons.length; x++)
	{
		if (Weapons[x] == None)
		{
			Weapons.Remove(x, 1);
			x--;
		}
		else
		{
			Weapons[x].NetUpdateFrequency = 20;
			ClientRegisterVehicleWeapon(Weapons[x], x);
		}
	}
}

function bool KDriverLeave(bool bForceLeave)
{
    local Controller C;
    local int x;

    if (bDriverCannotLeaveVehicle)
    {
        if (FlipTimeLeft > 0)
    		return False;

    	if (NeedsFlip())
    	{
    		Flip(vector(Rotation + rot(0,16384,0)), 1);
    		return False;
    	}

    	return False;
    }

    // We need to get the controller here since Super.KDriverLeave() messes with it.
    C = Controller;
    if ( Super.KDriverLeave(bForceLeave) || bForceLeave )
    {
    	if (C != None)
    	{
	        if (xPawn(C.Pawn) != None && C.Pawn.HasUDamage())
        		for (x = 0; x < Weapons.length; x++)
	    			Weapons[x].SetOverlayMaterial(xPawn(C.Pawn).UDamageWeaponMaterial, 0, false);
    		C.Pawn.bSetPCRotOnPossess = C.Pawn.default.bSetPCRotOnPossess;
            Instigator = C.Pawn; //so if vehicle continues on and runs someone over, the appropriate credit is given
        }
    	for (x = 0; x < Weapons.length; x++)
    	{
    		Weapons[x].FlashCount = 0;
    		Weapons[x].NetUpdateFrequency = Weapons[x].default.NetUpdateFrequency;
    	}

        return True;
    }
    else
        return False;
}

function SetActiveWeapon(int i)
{
    Weapons[ActiveWeapon].bActive = False;
    ActiveWeapon = i;
    Weapons[ActiveWeapon].bActive = True;

    PitchUpLimit = Weapons[ActiveWeapon].PitchUpLimit;
    PitchDownLimit = Weapons[ActiveWeapon].PitchDownLimit;
}

// DriverLeft() called by KDriverLeave()
function DriverLeft()
{
    if (ActiveWeapon < Weapons.Length)
    {
        Weapons[ActiveWeapon].bActive = False;
        Weapons[ActiveWeapon].AmbientSound = None;
    }

    if (AmbientSound != None)
        AmbientSound = None;


	if (bOutOfGas == False)
	{
    	if (ShutDownSound != None)
        	PlaySound(ShutDownSound, SLOT_None, 1.0);
	}

    if (!bNeverReset && ParentFactory != None && (VSize(Location - ParentFactory.Location) > 5000.0 || !FastTrace(ParentFactory.Location, Location)))
    {
    	if (bKeyVehicle)
    		ResetTime = Level.TimeSeconds + 15;
    	else
		ResetTime = Level.TimeSeconds + 30;
    }

    Super.DriverLeft();
}


simulated function ClientKDriverEnter(PlayerController PC)
{
	Super.ClientKDriverEnter(PC);

	if (PC.bEnableGUIForceFeedback)
		PC.ClientPlayForceFeedback(StartUpForce);

	if (!bDesiredBehindView)
		PC.SetRotation(Rotation);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	if (ActiveWeapon < Weapons.length)
	{
		if (bWeaponisFiring)
			Weapons[ActiveWeapon].ClientStopFire(PC, false);
		if (bWeaponisAltFiring)
			Weapons[ActiveWeapon].ClientStopFire(PC, true);
	}

	if (PC.bEnableGUIForceFeedback)
		PC.StopForceFeedback(StartUpForce); // quick jump in and out

	Super.ClientKDriverLeave(PC);
}

//============== end new test =======================================


simulated event DrivingStatusChanged()
{
	local int i;
	local Coords WheelCoords;

	Super.DrivingStatusChanged();



	if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
		Dust.length = Wheels.length;
		for(i=0; i<Wheels.Length; i++)
			if (Dust[i] == None)
			{
				// Create wheel dust emitters.
				WheelCoords = GetBoneCoords(Wheels[i].BoneName);
				Dust[i] = spawn(class'VehicleWheelDustEffect', self,, WheelCoords.Origin + ((vect(0,0,-1) * Wheels[i].WheelRadius) >> Rotation));
				if( Level.bDropDetail || Level.DetailMode == DM_Low )
				{
				 	Dust[i].MaxSpritePPS=3;
				 	Dust[i].MaxMeshPPS=3;
				}

				Dust[i].SetBase(self);
			    Dust[i].SetDirtColor( Level.DustColor );
			}

		 for(i=0; i<ExhaustPipes.Length; i++)
			if (ExhaustPipes[i].ExhaustEffect == None)
			{
				// Create exhaust emitters.
	    	    if( Level.bDropDetail || Level.DetailMode == DM_Low )
					ExhaustPipes[i].ExhaustEffect = spawn(ExhaustEffectLowClass, self,, Location + (ExhaustPipes[i].ExhaustPosition >> Rotation), ExhaustPipes[i].ExhaustRotation + Rotation);
				else
					ExhaustPipes[i].ExhaustEffect = spawn(ExhaustEffectClass, self,, Location + (ExhaustPipes[i].ExhaustPosition >> Rotation), ExhaustPipes[i].ExhaustRotation + Rotation);

				ExhaustPipes[i].ExhaustEffect.SetBase(self);
			}


	   
		if(bMakeBrakeLights)
		{
			for(i=0; i<2; i++)
				if (BrakeLight[i] == None)
				{
					BrakeLight[i] = spawn(class'ONSBrakelightCorona', self,, Location + (BrakeLightOffset[i] >> Rotation) );
					BrakeLight[i].SetBase(self);
					BrakeLight[i].SetRelativeRotation( rot(0,32768,0) ); // Point lights backwards.
					BrakeLight[i].Skins[0] = BrakeLightMaterial;
				}
		} 
	}
	else
	{
		if (Level.NetMode != NM_DedicatedServer)
		{
			for(i=0; i<Dust.Length; i++)
			{
				if( Dust[i] != none )
					Dust[i].Kill();
			}

			Dust.Length = 0;

			for(i=0; i<ExhaustPipes.Length; i++)
			{
			    if (ExhaustPipes[i].ExhaustEffect != None)
			    {
					ExhaustPipes[i].ExhaustEffect.Kill();
				}
			}

			// MergeTOD: Put this back in

			if(bMakeBrakeLights)
			{
				for(i=0; i<2; i++)
					if (BrakeLight[i] != None)
						BrakeLight[i].Destroy();
			}  
		}

		TurnDamping = 0.0;
	}
}


	

exec function ToggleViewLimit()
{
}

// Vehicles don't get telefragged.
event EncroachedBy(Actor Other) {}

// RanInto() called for encroaching actors which successfully moved the other actor out of the way
event RanInto(Actor Other)
{
	local vector Momentum;
	local float Speed;

	if (Pawn(Other) == None || Vehicle(Other) != None || Other == Instigator || Other.Role != ROLE_Authority)
		return;

	Speed = VSize(Velocity);
	if (Speed > MinRunOverSpeed)
	{
		Momentum = Velocity * 0.25 * Other.Mass;

		if (Controller != None && Controller.SameTeamAs(Pawn(Other).Controller))
			Momentum += Speed * 0.25 * Other.Mass * Normal(Velocity cross vect(0,0,1));
		if (RanOverSound != None)
			PlaySound(RanOverSound,,TransientSoundVolume*2.5);

	   		Other.TakeDamage(int(Speed * 0.075), Instigator, Other.Location, Momentum, RanOverDamageType);
	}
}

// This will get called if we couldn't move a pawn out of the way.
function bool EncroachingOn(Actor Other)
{
	local vector Momentum;
	local float Speed;
    local BDKFGlassMover Breakable;

    if (Other.isA('BDKFGlassMover') )
	{
		Breakable = BDKFGlassMover(Other);

		Breakable.Health = 0;
		Breakable.BreakWindow();
    }
	
	if ( Other == None || Other == Instigator || Other.Role != ROLE_Authority || (!Other.bCollideActors && !Other.bBlockActors)
	     || VSize(Velocity) < 10 )
	//	return;

	if (Pawn(Other) != None || Vehicle(Other) == None || Other == Instigator || Other.Role != ROLE_Authority)
		return false;

	if(Other != None)
	{
		Speed = VSize(Velocity);
		if (Speed <= MinRunOverSpeed)
		{	
			Momentum = Velocity * 0.25 * Other.Mass;

			if (Controller != None && Controller.SameTeamAs(Pawn(Other).Controller))
				Momentum += Speed * 0.25 * Other.Mass * Normal(Velocity cross vect(0,0,1));
			if (RanOverSound != None)
				PlaySound(RanOverSound,,TransientSoundVolume*2.5);

			Other.TakeDamage(int(Speed * 0.075), Instigator, Other.Location, Momentum, RanOverDamageType);
		}   	
		else
		{	
			if (Controller != None && Controller.SameTeamAs(Pawn(Other).Controller))
				Momentum += Speed * 0.25 * Other.Mass * Normal(Velocity cross vect(0,0,1));
			if (RanOverSound != None)
				PlaySound(RanOverSound,,TransientSoundVolume*2.5);

			Other.TakeDamage(10000, Instigator, Other.Location, Velocity * Other.Mass, CrushedDamageType);
		}
	}
}


/*

// This will get called if we couldn't move a pawn out of the way.
function bool EncroachingOn(Actor Other)
{
	if ( Other == None || Other == Instigator || Other.Role != ROLE_Authority || (!Other.bCollideActors && !Other.bBlockActors)
	     || VSize(Velocity) < 10 )
		return false;

	// If its a non-vehicle pawn, do lots of damage.
	if( (Pawn(Other) != None) && (Vehicle(Other) == None) )
	{
		Other.TakeDamage(10000, Instigator, Other.Location, Velocity * Other.Mass, CrushedDamageType);
                health = health-5;
		return false;
	}
}
*/




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
		//if(Health<HealthMax)
			Health = Health+1;
		//return;
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
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType, optional int HitIndex)
{
	local int ActualDamage;
	local Controller Killer;

	// Spawn Protection: Cannot be destroyed by a player until possessed
	if ( bSpawnProtected && instigatedBy != None && instigatedBy != Self )
		return;

	NetUpdateTime = Level.TimeSeconds - 1; // force quick net update

	if (DamageType != None && DamageType == class'DamTypeWelder')
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
		if(Health<HealthMax)
			Health = Health+1;
		//return;
	}


	if (Weapon != None && Weapon != class'BDWelder')
		Weapon.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	if (InstigatedBy != None && InstigatedBy.HasUDamage())
		Damage *= 2;
	if( Driver!=None && KFPawn(instigatedBy)!=None )
	{
		Momentum*=0.1f;
		ActualDamage = 0;
	}
	else ActualDamage = Damage;
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

*/

simulated function Tick(float dt)
{
	local int i;
	local bool lostTraction;
	local float ThrottlePosition;

	Super.Tick(dt);

    //log("=========> VSize(Velocity) = "$VSize(Velocity));
    //==========================================================
    //steering
    //==========================================================
    if ( Steering != 0)
    {
        //                factor                     direction
        SteerVal += Round(65000 * dt) * Clamp(Steering, -1, 1);
        //                             min    max
        SteerVal = Clamp ( SteerVal, -32768, 32768 );
    }
    else
    {
        if ( SteerVal > 0 )
        {
        SteerVal -= Round(65000 * dt) * Clamp(SteerVal, -1, 1);
        if ( SteerVal < 0 )
            SteerVal = 0;
        }
        else if ( SteerVal < 0 )
        {
        SteerVal -= Round(65000 * dt) * Clamp(SteerVal, -1, 1);
        if ( SteerVal > 0 )
            SteerVal = 0;
        }
    }
    SteeringRotation.Yaw = SteerVal;
    SetBoneRotation(SteeringWheelBone, SteeringRotation, 0, 1);


	// Pack the throttle setting into a byte to replicate it
	if( Role == ROLE_Authority )
	{
		if( Throttle < 0 )
		{
			ThrottleRep = (100 * Abs(Throttle));
		}
		else
		{
			ThrottleRep = 101 + (100 * Throttle);
		}
	}

 	// Dont bother doing effects on dedicated server.
	if(Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
		lostTraction = true;

		// MergeTODO: Put this stuff back in

   		// Update dust kicked up by wheels.
   		for(i=0; i<Dust.Length; i++)
	   	   Dust[i].UpdateDust(Wheels[i], DustSlipRate, DustSlipThresh);

		// Unpack the replicated throttle byte
		if( ThrottleRep < 101 )
		{
			ThrottlePosition = (ThrottleRep * 1.0)/100;
		}
		else if ( ThrottleRep == 101 )
		{
			ThrottlePosition = 0;
		}
		else
		{
			ThrottlePosition = (ThrottleRep - 101)/100;
		}

		for(i=0; i<ExhaustPipes.Length; i++)
		{
		    if (ExhaustPipes[i].ExhaustEffect != None)
		    {
				ExhaustPipes[i].ExhaustEffect.UpdateExhaust(ThrottlePosition);
			}
		}

		
		if(bMakeBrakeLights)
		{
			for(i=0; i<2; i++)
				if (BrakeLight[i] != None)
					BrakeLight[i].bCorona = True;

			for(i=0; i<2; i++)
				if (BrakeLight[i] != None)
					BrakeLight[i].UpdateBrakelightState(OutputBrake, Gear);
				//	BrakeLight[i].bCorona = False;
		}  
	}

	TurnDamping = default.TurnDamping;

	// RO Functionality
	// Lets make the vehicle not slide when its parked
	if( Abs(ForwardVel) < 50 )
	{
		MinBrakeFriction = LowSpeedBrakeFriction;
	}
	else
	{
		MinBrakeFriction=Default.MinBrakeFriction;
	}


//==========================================================

	if (fuel > 0)
		{
			bOutofgas = False;
		}
	
	/*
	else
	if (fuel <= 0)
		{
			bOutOfgas = True;
		}
*/
     if ( Driver != None )
     {
        	if (Fuel > 0.0)          //do we have gas?
			{
				if(level.netmode != NM_DedicatedServer)
            		
							Fuel-=0.03;
					
							else
					
							Fuel-=0.3;
					
			}
	 
        	else
        {
            //log("==========> Sending Out of gas message!!!");
            AmbientSound=None;
            if (!bOutOfGas)
            {
                PlaySound(ShutDownSound, SLOT_None, 1.0);
            PlaySound(vehicleout, SLOT_NONE, 3.0);
                bOutOfGas = true;
            }
            Throttle	= 0;
            PlayerController(Controller).ReceiveLocalizedMessage(class'BDMessageGas', 2);

            
	    }
   }
}


//=================================================
// update the Steering Wheel rotation
//=================================================
simulated function UpdateRoll(float dt, float SteerSpeed)
{
    local rotator r;

    CurrentRoll += dt*SteerSpeed;
    CurrentRoll = CurrentRoll % 65536.f;
    r.Roll = int(CurrentRoll);
    SetBoneRotation('Bone SteeringWheel', r, 0, Blend);
}

simulated function bool PointOfView()
{
	if (!bAllowViewChange)
		return true;

	return default.bDesiredBehindView;
}

defaultproperties
{
     Fuel=1000.000000
     MaxFuel=1000.000000
     vehicleout=Sound'KF_MaleVoiceTwo.Automatic_Commands.Auto_Out_of_ammo_7'
     FuelGaugeTex=Texture'BDVehicle_T.HUD.FuelMeter'
     MPHGaugeTex=Texture'BDVehicle_T.HUD.SpeedMeter'
     FuelPointer=TexRotator'BDVehicle_T.HUD.FuelMeterPointer'
     MPHPointer=TexRotator'BDVehicle_T.HUD.SpeedMeterPointer'
     MaxFuelPointerRotation=-23000
     MaxMPHPointerRotation=-44000
     healthToGive=0.000000
     bHasAltFire=True
     ImpactDamageSounds(0)=Sound'ProjectileSounds.Bullets.PTRD_deflect01'
     ImpactDamageSounds(1)=Sound'ProjectileSounds.Bullets.PTRD_deflect04'
     ImpactDamageSounds(2)=Sound'ProjectileSounds.Bullets.PTRD_penetrate01'
     ImpactDamageSounds(3)=Sound'ProjectileSounds.Bullets.PTRD_penetrate02'
     ImpactDamageSounds(4)=Sound'ProjectileSounds.Bullets.PTRD_penetrate03'
     ImpactDamageSounds(5)=Sound'ProjectileSounds.Bullets.PTRD_penetrate04'
     bAllowViewChange=True
     bDesiredBehindView=True
     TPCamDistance=375.000000
     MinRunOverSpeed=1000.000000
}
