//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BDLevelRules extends KFLevelRules
    placeable;

var(Vehicles) int   MaxCarLimit;
var(Vehicles) int   MinCarLimit;

defaultproperties
{
     MaxCarLimit=6
     MinCarLimit=3
     ItemForSale(25)=Class'KF_Vehicles_BD.BDFuelCan_WeaponPickup'
}
