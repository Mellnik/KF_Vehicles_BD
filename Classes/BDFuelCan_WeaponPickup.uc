//-----------------------------------------------------------
// Game:      RoadKill Warriors
// Engine:    UnrealTournament 2004
// Creators:  RKW Team
// URL:       www.RoadKillWarriors.com
//
// Copyright (C) 2005  Dustin 'Capone' Brown
//-----------------------------------------------------------
class BDFuelCan_WeaponPickup extends KFWeaponPickup;

#exec OBJ LOAD FILE=BDVehicle_T.utx

var int currentShell;
var int fired;
var Rotator shellRotation;
//var int damage;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
  // instigator = eventInstigator;

   GotoState('Exploding');
}

state Exploding
{
   ignores Touch, TakeDamage;

   function BeginState()
   {
      NetUpdateTime = Level.TimeSeconds - 1;
      bHidden = true;
      bProjTarget = false;
   }

   
   function HurtEverything()
   {
      local float damage, radius, momentum;

      damage = class'KFMod.Nade'.default.Damage;
      radius = class'KFMod.Nade'.default.DamageRadius;
      momentum = class'KFMod.Nade'.default.MomentumTransfer;

      HurtRadius(damage, radius, class'KFMod.DamTypeFrag', momentum, Location);
   }

   function SpawnExplosionEffect()
   {
      local BDFuelCanExplosion effect;
      local BDFuel_SpillFireB projectile;


      PlaySound(sound'KF_GrenadeSnd.Nade_Explode_1', , 1.0, , 800);

      effect = Spawn(class'BDFuelCanExplosion');
      projectile = Spawn(class'BDFuel_SpillFireB');
      Projectile.gotostate('onfire');
      projectile.RemoteRole = ROLE_SimulatedProxy;
      
   }

Begin:

   // Then spawn a nice little explosion.
   SpawnExplosionEffect();


   // Next, hurt anything that's nearby.
   HurtEverything();

   destroy();


}

state Pickup
{
   function BeginState()
   {
      bProjTarget = true;
   }
}

state Sleeping
{
   ignores TakeDamage;
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
     Weight=6.000000
     cost=750
     AmmoCost=30
     BuyClipSize=750
     PowerValue=30
     SpeedValue=100
     RangeValue=40
     Description="Canister of flammable liquid, which can be used for refueling vehicles, pouring onto the ground and lit to create a wall of fire or as a last resort, can be thrown and shot to cause a devastating explosion"
     ItemName="Fuel Can"
     ItemShortName="Fuel Can"
     AmmoItemName="Petrol"
     CorrespondingPerkIndex=5
     EquipmentCategoryID=3
     MaxDesireability=0.700000
     InventoryType=Class'KF_Vehicles_BD.BDFuelCan_Weapon'
     PickupMessage="You got a Fuel Can"
     PickupSound=Sound'BDVehicles_A.Fuel.Melee1'
     StaticMesh=StaticMesh'BDVehicles_S.fuelcan'
     DrawScale=0.650000
}
