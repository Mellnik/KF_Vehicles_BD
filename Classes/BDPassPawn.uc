class BDPassPawn extends BDweaponPawn;

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

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

defaultproperties
{
     GunClass=Class'KF_Vehicles_BD.PassnoWeapon'
     CameraBone="CHR_Head"
     DrivePos=(X=-20.000000,Z=50.000000)
     DriveRot=(Pitch=2000)
     DriveAnim="passenger"
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryRadius=130.000000
     FPCamPos=(Z=50.000000)
     TPCamDistance=300.000000
     TPCamLookat=(X=-200.000000,Z=120.000000)
     TPCamWorldOffset=(Z=120.000000)
     DriverDamageMult=0.600000
     VehiclePositionString="Passenger"
     VehicleNameString="Passenger"
}
