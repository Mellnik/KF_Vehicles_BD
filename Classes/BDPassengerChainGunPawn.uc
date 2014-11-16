//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BDPassengerChainGunPawn extends BDWeaponPawn;

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

defaultproperties
{
     GunClass=Class'KF_Vehicles_BD.PassengerChainGun'
     CameraBone="Camera"
     bDrawDriverInTP=False
     bAllowViewChange=False
     DrivePos=(Y=80.000000,Z=90.000000)
     DriveRot=(Yaw=16000)
     DriveAnim="passenger"
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=100.000000)
     ExitPositions(3)=(Y=165.000000,Z=100.000000)
     EntryRadius=160.000000
     FPCamViewOffset=(Z=10.000000)
     TPCamDistance=0.000000
     TPCamLookat=(X=-25.000000,Z=0.000000)
     TPCamWorldOffset=(Z=50.000000)
     DriverDamageMult=0.600000
     VehiclePositionString="in a Merlin"
     VehicleNameString="Merlin Chain Gun"
}
