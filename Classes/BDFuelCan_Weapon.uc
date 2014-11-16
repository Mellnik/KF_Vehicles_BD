//-----------------------------------------------------------
// Game:      RoadKill Warriors
// Engine:    UnrealTournament 2004
// Creators:  RKW Team
// URL:       www.RoadKillWarriors.com
//
// Copyright (C) 2005  Dustin 'Capone' Brown
//-----------------------------------------------------------
class BDFuelCan_Weapon extends KFWeapon
    config(user);

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=BDVehicle_T.utx
//#exec OBJ LOAD FILE=BDVehicles.uax

var   int       CurrentMode;


simulated function PlayRunning()
{
	if(HasAnim(RunAnim))
		LoopAnim(RunAnim, RunAnimRate, 0.0);
}



//-----------------------------------------------------------
//  ConsumeAmmo
//-----------------------------------------------------------
function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	return Super.ConsumeAmmo(Mode, load, bAmountNeededIsMax);
}

//---------------------------------------------------
//  AnimEnd
//---------------------------------------------------
simulated function AnimEnd(int Channel)
{
  local name  AnimSeq;
  local float Frame;
  local float Rate;

    GetAnimParams(0,AnimSeq,Frame,Rate);

    if (AnimSeq == FireMode[1].FireAnim)
     {
      PlayAnim(SelectAnim, SelectAnimRate, 0.0);
     }
}
//-----------------------------------------------------------
//  StartFire
//-----------------------------------------------------------
simulated function bool StartFire(int mode)
{
    local bool bStart;

	if ( !BDFuelCan_AltFire(FireMode[0]).IsIdle() )
		return false;

    bStart = Super.StartFire(mode);
    if (bStart)
        FireMode[mode].StartFiring();

    return bStart;
}

//-----------------------------------------------------------
//  DetachFromPawn
//-----------------------------------------------------------
// Allow fire modes to return to idle on weapon switch (server)
simulated function DetachFromPawn(Pawn P)
{
    //log(self$" detach from pawn p="$p);

    ReturnToIdle();

    Super.DetachFromPawn(P);
}

//-----------------------------------------------------------
//  PutDown
//-----------------------------------------------------------
// Allow fire modes to return to idle on weapon switch (client)
simulated function bool PutDown()
{
    ReturnToIdle();

    return Super.PutDown();
}

//-----------------------------------------------------------
//  ReturnToIdle
//-----------------------------------------------------------
simulated function ReturnToIdle()
{
    if (FireMode[0] != None)
     {
      FireMode[0].GotoState('Idle');
     }
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
     MagCapacity=1
     HudImage=Texture'BDVehicle_T.HUD.FuelCan_unSelected'
     SelectedHudImage=Texture'BDVehicle_T.HUD.FuelCan_Selected'
     Weight=6.000000
     bAmmoHUDAsBar=True
     IdleAimAnim="Idle"
     StandardDisplayFOV=70.000000
     TraderInfoTexture=Texture'BDVehicle_T.HUD.Trader_FuelCan'
     FireModeClass(0)=Class'KF_Vehicles_BD.BDFuelCan_AltFire'
     FireModeClass(1)=Class'KF_Vehicles_BD.BDFuelCan_Fire'
     PutDownAnim="PutDown"
     IdleAnimRate=0.030000
     SelectSound=Sound'BDVehicles_A.Fuel.Melee1'
     AIRating=-2.000000
     CurrentRating=0.680000
     Description="Use this to set someone on fire or refuel your car..."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-3.000000)
     DisplayFOV=70.000000
     Priority=7
     InventoryGroup=5
     GroupOffset=3
     PickupClass=Class'KF_Vehicles_BD.BDFuelCan_WeaponPickup'
     PlayerViewOffset=(X=25.000000,Z=-10.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KF_Vehicles_BD.FuelCan_Attachment'
     IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
     ItemName="Fuel Canister"
     Mesh=SkeletalMesh'BDVehicles.fuel_1st'
     Skins(0)=Combiner'BDVehicle_T.Fuel.Fuel_Final'
}
