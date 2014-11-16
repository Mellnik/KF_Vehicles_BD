Class BDFuelCanAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

//=====================================================================================================
//=====================================================================================================
//==
//==        D E F A U L T P R O P E R T I E S
//==
//=====================================================================================================
//=====================================================================================================

defaultproperties
{
     AmmoPickupAmount=100
     MaxAmmo=200
     InitialAmount=200
     PickupClass=Class'KF_Vehicles_BD.BDFuelCanAmmo_Pickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
     ItemName="Fuel"
}
