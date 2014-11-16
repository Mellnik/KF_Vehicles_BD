class BDvehicle extends ROWheeledVehicle;

// Handle the engine damage
function DamageEngine(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{


}



function ServerChangeViewPoint(bool bForward)
{}

simulated state ViewTransition
{}

simulated state EnteringVehicle
{}

simulated state LeavingVehicle
{}


simulated function NextViewPoint()
{}

simulated function PostNetReceive()
{}

simulated function vector GetCameraLocationStart()
{
	return Location;
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

	HitActor = Trace(HitLocation, HitNormal, CameraLocation, CamLookAt, true, vect(40, 40, 40));
	if ( HitActor != None
	     && (HitActor.bWorldGeometry || HitActor == GetVehicleBase() || Trace(HitLocation, HitNormal, CameraLocation, CamLookAt, false, vect(40, 40, 40)) != None) )
			CameraLocation = HitLocation;

	CameraRotation = Normalize(PC.Rotation + PC.ShakeRot);
	CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local quat CarQuat, LookQuat, ResultQuat;
	local vector VehicleZ, CamViewOffsetWorld, x, y, z;
	local float CamViewOffsetZAmount;

	GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;

	if (bPCRelativeFPRotation)
	{
		CarQuat = QuatFromRotator(Rotation);
		CameraRotation = Normalize(PC.Rotation);
		LookQuat = QuatFromRotator(CameraRotation);
		ResultQuat = QuatProduct(LookQuat, CarQuat);
		CameraRotation = QuatToRotator(ResultQuat);
	}
	else
		CameraRotation = PC.Rotation;

	// Camera position is locked to car
	CamViewOffsetWorld = FPCamViewOffset >> CameraRotation;
	CameraLocation = GetCameraLocationStart() + (FPCamPos >> Rotation) + CamViewOffsetWorld;

	if(bFPNoZFromCameraPitch)
	{
		VehicleZ = vect(0,0,1) >> Rotation;
		CamViewOffsetZAmount = CamViewOffsetWorld Dot VehicleZ;
		CameraLocation -= CamViewOffsetZAmount * VehicleZ;
	}

	CameraRotation = Normalize(CameraRotation + PC.ShakeRot);
	CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

// Special calc-view for vehicles
simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local PlayerController pc;

	pc = PlayerController(Controller);

	// Only do this mode we have a playercontroller
	if( (pc == None) || (pc.Viewtarget != self) )
		return false;

	if( pc.bBehindView )
		SpecialCalcBehindView(PC,ViewActor,CameraLocation,CameraRotation);
	else
		SpecialCalcFirstPersonView(PC,ViewActor,CameraLocation,CameraRotation);

	LastCameraCalcTime = Level.TimeSeconds;

	return true;
}

function KDriverEnter(Pawn P)
{
	local Controller C;

	bDriving = True;
	StuckCount = 0;

	// We don't have pre-defined exit positions here, so we use the original player location as an exit point
	if ( !bRelativeExitPos )
	{
		PlayerEnterredRotation = P.Rotation;
		ExitPositions[0] =  P.Location + Vect(0,0,16);
	}

	// Set pawns current controller to control the vehicle pawn instead
	C = P.Controller;
	if ( !bCanCarryFlag && (C.PlayerReplicationInfo.HasFlag != None)  )
		P.DropFlag();

	Driver = P;
	Driver.StartDriving( Self );

	// Disconnect PlayerController from Driver and connect to SVehicle.
	C.bVehicleTransition = true; // to keep Bots from doing Restart()
	C.Unpossess();
	Driver.SetOwner( Self ); // This keeps the driver relevant.
	C.Possess( Self );
	C.bVehicleTransition = false;

	DrivingStatusChanged();

	if ( PlayerController(C) != None )
		VehicleLostTime = 0;

	AttachFlag(PlayerReplicationInfo.HasFlag);

	Level.Game.DriverEnteredVehicle(self, P);
}

function AttachFlag(Actor FlagActor)
{
	if ( !bDriverHoldsFlag && (FlagActor != None) )
	{
		AttachToBone(FlagActor,FlagBone);
		FlagActor.SetRelativeRotation(FlagRotation);
		FlagActor.SetRelativeLocation(FlagOffset);
	}
}

simulated event SetWheelsScale(float NewScale)
{
	WheelsScale = NewScale;
}

//KF Vehicle test




// Called from the PlayerController when player wants to get out.
event bool KDriverLeave( bool bForceLeave )
{
	local Controller C;
	local PlayerController	PC;
	local bool havePlaced;

	if( !bForceLeave && !Level.Game.CanLeaveVehicle(self, Driver) )
		return false;

	if ( (PlayerReplicationInfo != None) && (PlayerReplicationInfo.HasFlag != None) )
		Driver.HoldFlag(PlayerReplicationInfo.HasFlag);

	// Do nothing if we're not being driven
	if (Controller == None )
		return false;

	// Before we can exit, we need to find a place to put the driver.
	// Iterate over array of possible exit locations.

	if ( (Driver != None) && (!bRemoteControlled || bHideRemoteDriver) )
	{
	    Driver.bHardAttach = false;
	    Driver.bCollideWorld = true;
	    Driver.SetCollision(true, true);
	    havePlaced = PlaceExitingDriver();

	    // If we could not find a place to put the driver, leave driver inside as before.
	    if (!havePlaced && !bForceLeave )
	    {
	        Driver.bHardAttach = true;
	        Driver.bCollideWorld = false;
	        Driver.SetCollision(false, false);
	        return false;
	    }
	}

	bDriving = False;

	// Reconnect Controller to Driver.
	C = Controller;
	if (C.RouteGoal == self)
		C.RouteGoal = None;
	if (C.MoveTarget == self)
		C.MoveTarget = None;
	C.bVehicleTransition = true;
	Controller.UnPossess();

	if ( (Driver != None) && (Driver.Health > 0) )
	{
		Driver.SetOwner( C );
		C.Possess( Driver );

		PC = PlayerController(C);
		if ( PC != None )
			PC.ClientSetViewTarget( Driver ); // Set playercontroller to view the person that got out

		Driver.StopDriving( Self );
	}
	C.bVehicleTransition = false;

	if ( C == Controller )	// If controller didn't change, clear it...
		Controller = None;

	Level.Game.DriverLeftVehicle(self, Driver);

	// Car now has no driver
	Driver = None;

	DriverLeft();

	// Put brakes on before you get out :)
	Throttle	= 0;
	Steering	= 0;
	Rise		= 0;

	return true;
}

// DriverLeft() called by KDriverLeave()
function DriverLeft()
{
	DrivingStatusChanged();
}

simulated event UpdateTiltForceFeedback()
{
	local rotator SpringCenter;
	local float pitch, roll;
	local PlayerController PC;

	PC = PlayerController(Controller);
	if ( PC != None )
	{
		SpringCenter = rotation;
		pitch = Clamp(SpringCenter.Pitch, -CenterSpringRangePitch, CenterSpringRangePitch);
		roll = Clamp(SpringCenter.Roll, -CenterSpringRangeRoll, CenterSpringRangeRoll);
		pitch /= CenterSpringRangePitch;
		roll /= CenterSpringRangeRoll;
		PC.ChangeSpringFeedbackEffect(CenterSpringForce, roll, pitch);
	}
}

simulated function ClientKDriverEnter(PlayerController PC)
{
//	PC.bFreeCamera = true;

	// Set rotation of camera when getting into vehicle based on bZeroPCRotOnEntry
	if ( bZeroPCRotOnEntry )
		PC.SetRotation( rot(0, 0, 0) );

	//set starting camera distance to local player's preferences
	TPCamDistance = default.TPCamDistance;
	DesiredTPCamDistance = TPCamDistance;

	if (!PC.bBehindView)
	   ActivateOverlay(True);

	if ( PC.bEnableGUIForceFeedback
		&&	PC.bForceFeedbackSupported
		&&	(Viewport(PC.Player) != None) )
	{
		if ( (CenterSpringRangePitch > 0) && (CenterSpringRangeRoll > 0) )
			UpdateTiltForceFeedback();
		PC.ClientPlayForceFeedback(CenterSpringForce);
	}

	if (Driver!=None)
	{
		Driver.AmbientSound=none;
		if (Driver.Weapon!=None)
			Driver.Weapon.AmbientSound=none;
	}


}

simulated function ClientClearController()
{
	ActivateOverlay(False);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
//	PC.bFreeCamera = false;

	// Stop messing with bOwnerNoSee
	if ( Driver != None )
		Driver.bOwnerNoSee = Driver.default.bOwnerNoSee;

	if (PC.bEnableGUIForceFeedback)
		PC.StopForceFeedback(CenterSpringForce);

	bWeaponisFiring = False;
	bWeaponisAltFiring = False;

	ActivateOverlay(False);
}

simulated function AttachDriver(Pawn P)
{
	local vector AttachPos;

	P.bHardAttach = true;
	AttachPos = Location + (DrivePos >> Rotation);
	P.SetLocation( AttachPos );
	P.SetPhysics( PHYS_None );
	P.SetBase( Self );
	P.SetRelativeRotation( DriveRot );
}


//end KF Vehicle test

simulated function NextWeapon()
{
	local PlayerController PC;

	if ( Level.Pauser != None )
		return;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	if (!PC.bBehindView)
	{
		PC.BehindView(true);
	DesiredTPCamDistance = TPCamDistRange.Min;
	TPCamDistance = DesiredTPCamDistance;
	}
	else
	DesiredTPCamDistance = Min(DesiredTPCamDistance + 100, TPCamDistRange.Max);

	default.TPCamDistance = DesiredTPCamDistance;
	StaticSaveConfig();
}

simulated function PrevWeapon()
{
	local PlayerController PC;

	if ( Level.Pauser != None )
		return;

	PC = PlayerController(Controller);
	if (PC == None || !PC.bBehindView)
		return;

	if (DesiredTPCamDistance ~= TPCamDistRange.Min)
		PC.BehindView(false);
	else
	{
	DesiredTPCamDistance = Max(DesiredTPCamDistance - 100, TPCamDistRange.Min);
	default.TPCamDistance = DesiredTPCamDistance;
	StaticSaveConfig();
	}
}

simulated function DetachDriver(Pawn P) {}



simulated function int LimitYaw(int yaw)
{

    if ( !bLimitYaw )
    {
        return yaw;
    }

}

function int LimitPawnPitch(int pitch)
{
    pitch = pitch & 65535;

    if ( !bLimitPitch )
    {
        return pitch;
    }


}

function VehicleExplosion(vector MomentumNormal, float PercentMomentum)
{
    local vector LinearImpulse, AngularImpulse;

    HurtRadius(ExplosionDamage, ExplosionRadius, ExplosionDamageType, ExplosionMomentum, Location);

    if (!bDisintegrateVehicle)
    {
        ExplosionCount++;

        if (Level.NetMode != NM_DedicatedServer)
            ClientVehicleExplosion(False);

        LinearImpulse = PercentMomentum * RandRange(DestructionLinearMomentum.Min, DestructionLinearMomentum.Max) * MomentumNormal;
        AngularImpulse = PercentMomentum * RandRange(DestructionAngularMomentum.Min, DestructionAngularMomentum.Max) * VRand();

//        log(" ");
//        log(self$" Explosion");
//        log("LinearImpulse: "$LinearImpulse$"("$VSize(LinearImpulse)$")");
//        log("AngularImpulse: "$AngularImpulse$"("$VSize(AngularImpulse)$")");
//        log(" ");

		NetUpdateTime = Level.TimeSeconds - 1;
        KAddImpulse(LinearImpulse, vect(0,0,0));
        KAddAngularImpulse(AngularImpulse);
    }
}

simulated event ClientVehicleExplosion(bool bFinal)
{
	local int SoundNum;
	local PlayerController PC;
	local float Dist, Scale;

	//viewshake
	if (Level.NetMode != NM_DedicatedServer)
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget != None)
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			if (Dist < ExplosionRadius * 2.5)
			{
				if (Dist < ExplosionRadius)
					Scale = 1.0;
				else
					Scale = (ExplosionRadius*2.5 - Dist) / (ExplosionRadius);
				PC.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
			}
		}
	}

    // Explosion effect
	if(ExplosionSounds.Length > 0)
	{
		SoundNum = Rand(ExplosionSounds.Length);
		PlaySound(ExplosionSounds[SoundNum], SLOT_None, ExplosionSoundVolume*TransientSoundVolume,, ExplosionSoundRadius);
	}

	if (bFinal)
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
			if( Level.bDropDetail || Level.DetailMode == DM_Low )
				DestructionEffect = spawn(DisintegrationEffectLowClass,,, Location, Rotation);
			else
				DestructionEffect = spawn(DisintegrationEffectClass,,, Location, Rotation);

			DestructionEffect.SetBase(self);
        }
    }
	else
	{
        if (Level.NetMode != NM_DedicatedServer)
        {
     	    if( Level.bDropDetail || Level.DetailMode == DM_Low )
				DestructionEffect = spawn(DestructionEffectLowClass, self);
			else
				DestructionEffect = spawn(DestructionEffectClass, self);

    		DestructionEffect.SetBase(self);
    	}
    }
}

/*
function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIndex)
{
	local int i;

	if ( Health <= 0 )
	{
	

	Super.PlayHit(Damage, InstigatedBy, HitLocation, damageType, Momentum);

	for (i = 0; i < WeaponPawns.length; i++)
		if (!WeaponPawns[i].bHasOwnHealth && WeaponPawns[i].Controller != None)
			WeaponPawns[i].Controller.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);

        }
       else
	{
      	Super.PlayHit(Damage, InstigatedBy, HitLocation, damageType, Momentum);

	for (i = 0; i < WeaponPawns.length; i++)
		if (!WeaponPawns[i].bHasOwnHealth)
			WeaponPawns[i].Controller.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
	}
}
*/


function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIndex)
{
	local int i;

	Super.PlayHit(Damage, InstigatedBy, HitLocation, damageType, Momentum);

	for (i = 0; i < WeaponPawns.length; i++)
		if (!WeaponPawns[i].bHasOwnHealth && WeaponPawns[i].Controller != None)
			WeaponPawns[i].Controller.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
}

//Vehicle has been in the middle of nowhere with no driver for a while, so consider resetting it
event CheckReset()
{
	local Pawn P;

	if ( bKeyVehicle && IsVehicleEmpty() )
	{
		Died(None, class'DamageType', Location);
		return;
	}

	if ( !IsVehicleEmpty() )
	{
    	ResetTime = Level.TimeSeconds + 10;
    	return;
	}

	foreach CollidingActors(class 'Pawn', P, 2500.0)
	{
		if (P.Controller != none && P != self && P.GetTeamNum() == GetTeamNum() && FastTrace(P.Location + P.CollisionHeight * vect(0,0,1), Location + CollisionHeight * vect(0,0,1)))
		{
			ResetTime = Level.TimeSeconds + 10;
			return;
		}
	}

	//if factory is active, we want it to spawn new vehicle NOW
	if ( ParentFactory != None )
	{
		ParentFactory.VehicleDestroyed(self);
		ParentFactory.Timer();
		ParentFactory = None; //so doesn't call ParentFactory.VehicleDestroyed() again in Destroyed()
	}

	Destroy();
}



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
}

defaultproperties
{
     TimeTilDissapear=15.000000
     IdleTimeBeforeReset=0.000000
     bDisableThrottle=False
     bDontUsePositionMesh=True
     VehicleSpikeTime=0.000000
     EngineHealth=0
}
