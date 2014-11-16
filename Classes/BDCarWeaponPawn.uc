//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BDCarWeaponPawn extends Vehicleweaponpawn;


function BeginPlay()
{
	Super.BeginPlay();

	Gun.bHidden = True;

}

function bool TooCloseToAttack(Actor Other)
{
	local int NeededPitch;

	if (Gun == None || VSize(Location - Other.Location) > 2500)
		return false;

	Gun.CalcWeaponFire(false);
	NeededPitch = rotator(Other.Location - Gun.WeaponFireLocation).Pitch;
	NeededPitch = NeededPitch & 65535;
	return (LimitPitch(NeededPitch) == NeededPitch);
}


// Keeps pawn from setting PHYS_Falling
singular event BaseChange() {}

function Fire(optional float F)
{
	Super.Fire(F);

	if (Gun != None && PlayerController(Controller) != None)
		Gun.attemptFire(Controller, false);
}

function AltFire(optional float F)
{
	Super.AltFire(F);

	if (!bWeaponIsFiring && Gun != None && PlayerController(Controller) != None)
		Gun.ClientStartFire(Controller, true);
}



function VehicleCeaseFire(bool bWasAltFire)
{
	Super.VehicleCeaseFire(bWasAltFire);
	if (Gun != None)
	{
		Gun.CeaseFire(Controller,bwasaltfire);
	}
}
/*
function bool TryToDrive(Pawn P)
{
	if (VehicleBase != None)
	{
		if (VehicleBase.NeedsFlip())
		{
			VehicleBase.Flip(vector(P.Rotation), 1);
			return false;
		}

		if (P.GetTeamNum() != Team)
		{
			if (VehicleBase.Driver == None)
				return VehicleBase.TryToDrive(P);

			VehicleLocked(P);
			return false;
		}
	}

	return Super.TryToDrive(P);
}
*/

function bool TryToDrive(Pawn P)
{
	if (VehicleBase != None)
	{
		if (VehicleBase.NeedsFlip())
		{
			VehicleBase.Flip(vector(P.Rotation), 1);
			return false;
		}

		if (P.GetTeamNum() != Team)
		{
			VehicleLocked(P);
			return false;
		}
	}

	return Super.TryToDrive(P);
}

function KDriverEnter(Pawn P)
{
	local rotator NewRotation;

	Super.KDriverEnter(P);

	if (VehicleBase != None && VehicleBase.bTeamLocked && VehicleBase.bEnterringUnlocks)
		VehicleBase.bTeamLocked = false;

	Gun.bActive = True;
	if (!bHasOwnHealth && VehicleBase == None)
	{
		Health = Driver.Health;
		HealthMax = Driver.HealthMax;
	}

//        if (xPawn(Driver) != None && Driver.HasUDamage())
//		Gun.SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, xPawn(Driver).UDamageTime - Level.TimeSeconds, false);

	NewRotation = Controller.Rotation;
	NewRotation.Pitch = LimitPitch(NewRotation.Pitch);
	SetRotation(NewRotation);
	Driver.bSetPCRotOnPossess = false; //so when driver gets out he'll be facing the same direction as he was inside the vehicle

	if (Gun != None)
	{
             	Gun.bHidden = False;
		Gun.NetPriority = 2.0;
		Gun.NetUpdateFrequency = 10;
	}
}

function PossessedBy(Controller C)
{
	Super.PossessedBy(C);
	NetPriority = 1.0;
}

function bool KDriverLeave( bool bForceLeave )
{
    local Controller C;

    // We need to get the controller here since Super.KDriverLeave() messes with it.
    C = Controller;
    if (Super.KDriverLeave(bForceLeave) || bForceLeave)
    {
        bWeaponIsFiring = False;

		if (!bHasOwnHealth && VehicleBase == None)
		{
			HealthMax = default.HealthMax;
			Health = HealthMax;
		}

		if (C != None)
		{
			if (Gun != None && xPawn(C.Pawn) != None && C.Pawn.HasUDamage())
				Gun.SetOverlayMaterial(xPawn(C.Pawn).UDamageWeaponMaterial, 0, false);

			C.Pawn.bSetPCRotOnPossess = C.Pawn.default.bSetPCRotOnPossess;

			if (Bot(C) != None)
				Bot(C).ClearTemporaryOrders();
		}

		if (Gun != None)
		{
			Gun.bActive = False;
			Gun.bHidden = True;
			Gun.FlashCount = 0;
			Gun.NetUpdateFrequency = Gun.default.NetUpdateFrequency;
			Gun.NetPriority = Gun.default.NetPriority;
		}

        return True;
    }
    else
    {
		if ( (Bot(Controller) != None) && (VehicleBase.Driver == None) )
			ServerChangeDriverPosition(1);
        //Log("Cannot leave "$self);
        return False;
    }
}

function bool HasUDamage()
{
	return (Driver != None && Driver.HasUDamage());
}

function DriverDied()
{
//        if (Gun != None && xPawn(Driver) != None && Driver.HasUDamage())
//		Gun.SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, 0, false);
	    Gun.bHidden = True;
    	Super.DriverDied();
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	local rotator NewRotation;

	Super.ClientKDriverEnter(PC);

	    Gun.bHidden = False;
	NewRotation = PC.Rotation;
	NewRotation.Pitch = LimitPitch(NewRotation.Pitch);
	SetRotation(NewRotation);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	if (Gun != None)
	{
		if (bWeaponisFiring)
			Gun.ClientStopFire(PC, false);
		if (bWeaponisAltFiring)
			Gun.ClientStopFire(PC, true);
	}

	Super.ClientKDriverLeave(PC);
}

function bool PlaceExitingDriver()
{
	local int i;
	local vector tryPlace, Extent, HitLocation, HitNormal, ZOffset;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,0.5);

	//avoid running driver over by placing in direction perpendicular to velocity
	if (VehicleBase != None && VSize(VehicleBase.Velocity) > 100)
	{
		tryPlace = Normal(VehicleBase.Velocity cross vect(0,0,1)) * (VehicleBase.CollisionRadius * 1.25);
		if (FRand() < 0.5)
			tryPlace *= -1; //randomly prefer other side
		if ( (VehicleBase.Trace(HitLocation, HitNormal, VehicleBase.Location + tryPlace + ZOffset, VehicleBase.Location + ZOffset, false, Extent) == None && Driver.SetLocation(VehicleBase.Location + tryPlace + ZOffset))
		     || (VehicleBase.Trace(HitLocation, HitNormal, VehicleBase.Location - tryPlace + ZOffset, VehicleBase.Location + ZOffset, false, Extent) == None && Driver.SetLocation(VehicleBase.Location - tryPlace + ZOffset)) )
			return true;
	}

	for(i=0; i<ExitPositions.Length; i++)
	{
		if ( bRelativeExitPos )
		{
		    if (VehicleBase != None)
		    	tryPlace = VehicleBase.Location + (ExitPositions[i] >> VehicleBase.Rotation) + ZOffset;
        	    else if (Gun != None)
                	tryPlace = Gun.Location + (ExitPositions[i] >> Gun.Rotation) + ZOffset;
	            else
        	        tryPlace = Location + (ExitPositions[i] >> Rotation);
	        }
		else
			tryPlace = ExitPositions[i];

		// First, do a line check (stops us passing through things on exit).
		if ( bRelativeExitPos )
		{
			if (VehicleBase != None)
			{
				if (VehicleBase.Trace(HitLocation, HitNormal, tryPlace, VehicleBase.Location + ZOffset, false, Extent) != None)
					continue;
			}
			else
				if (Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None)
					continue;
		}

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}

simulated function AttachDriver(Pawn P)
{
    local coords GunnerAttachmentBoneCoords;

    if (Gun == None)
    	return;

    P.bHardAttach = True;
    Gun.bHidden = False;
    GunnerAttachmentBoneCoords = Gun.GetBoneCoords(Gun.GunnerAttachmentBone);
    P.SetLocation(GunnerAttachmentBoneCoords.Origin);

    P.SetPhysics(PHYS_None);

    Gun.AttachToBone(P, Gun.GunnerAttachmentBone);
    P.SetRelativeLocation(DrivePos);
	P.SetRelativeRotation( DriveRot );
}

simulated function DetachDriver(Pawn P)
{
    if (Gun != None && P.AttachmentBone != '')
        Gun.DetachFromBone(P);
}





simulated function DrawHUD(Canvas Canvas)
{
    local PlayerController PC;
    local vector CameraLocation;
    local rotator CameraRotation;
    local Actor ViewActor;

	if (IsLocallyControlled() && Gun != None && Gun.bCorrectAim)
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

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local vector x, y, z;
	local vector VehicleZ, CamViewOffsetWorld;
	local float CamViewOffsetZAmount;
	local coords CamBoneCoords;

    GetAxes(CameraRotation, x, y, z);
	ViewActor = self;

	CamViewOffsetWorld = FPCamViewOffset >> CameraRotation;

	if(CameraBone != '' && Gun != None)
	{
		CamBoneCoords = Gun.GetBoneCoords(CameraBone);
		CameraLocation = CamBoneCoords.Origin + (FPCamPos >> Rotation) + CamViewOffsetWorld;

		if(bFPNoZFromCameraPitch)
		{
			VehicleZ = vect(0,0,1) >> Rotation;
			CamViewOffsetZAmount = CamViewOffsetWorld Dot VehicleZ;
			CameraLocation -= CamViewOffsetZAmount * VehicleZ;
		}
	}
	else
	{
		CameraLocation = GetCameraLocationStart() + (FPCamPos >> Rotation) + CamViewOffsetWorld;

		if(bFPNoZFromCameraPitch)
		{
			VehicleZ = vect(0,0,1) >> Rotation;
			CamViewOffsetZAmount = CamViewOffsetWorld Dot VehicleZ;
			CameraLocation -= CamViewOffsetZAmount * VehicleZ;
		}
	}

    CameraRotation = Normalize(CameraRotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

simulated function vector GetCameraLocationStart()
{
	if (VehicleBase != None && Gun != None)
		return VehicleBase.GetBoneCoords(Gun.AttachmentBone).Origin;
	else
		return Super.GetCameraLocationStart();
}
simulated function PostNetReceive()
{
	local int i;

	if (VehicleBase != None)
	{
		bNetNotify = false;
		for (i = 0; i < VehicleBase.WeaponPawns.Length; i++)
			if (VehicleBase.WeaponPawns[i] == self)
				return;
		VehicleBase.WeaponPawns[VehicleBase.WeaponPawns.length] = self;
	}
}

event ApplyFireImpulse(bool bAlt)
{
    if (!bAlt)
        VehicleBase.KAddImpulse(FireImpulse >> Gun.WeaponFireRotation, Gun.WeaponFireLocation);
    else
        VehicleBase.KAddImpulse(AltFireImpulse >> Gun.WeaponFireRotation, Gun.WeaponFireLocation);
}

static function StaticPrecache(LevelInfo L)
{
    Default.GunClass.static.StaticPrecache(L);
}

simulated function ProjectilePostRender2D(Projectile P, Canvas C, float ScreenLocX, float ScreenLocY);

defaultproperties
{
     CrossHairColor=(G=255,A=255)
     CrosshairX=32.000000
     CrosshairY=32.000000
     DriveAnim="driving"
}
