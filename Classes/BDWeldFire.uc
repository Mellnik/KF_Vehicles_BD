// Weld Fire //
class BDWeldFire extends KFMeleeFire;

var 			KFDoorMover LastHitActor;
var				BDWheeledVehicle LastHitActorB;
var localized 	string 		NoWeldTargetMessage;
var localized 	string 		CantWeldTargetMessage;
var 			float 		FailTime;
var				float	LastHealAttempt;
var				float	HealAttemptDelay;
var 			float 	LastHealMessageTime;
var 			float 	HealMessageDelay;
var localized   string  NoHealTargetMessage;
var             BDWheeledVehicle    CachedHealee;
var() float             tracerange;





function PlayFiring()
{
	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if ( Weapon.HasAnim(FireLoopAnim) )
				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
			else Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
		}
	}
	else Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
	Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,Default.FireAnimRate/FireAnimRate,false);
	ClientPlayForceFeedback(FireForce);  // jdf
	FireCount++;
}



simulated Function Timer()
{
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal,AdjustedLocation;
	local rotator PointRot;
	local int MyDamage;



	If( !KFWeapon(Weapon).bNoHit )
	{
		MyDamage = damageConst + Rand(MaxAdditionalDamage);

		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			MyDamage = float(MyDamage) * KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetWeldSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));
		}

		PointRot = Instigator.GetViewRotation();
		StartTrace = Instigator.Location + Instigator.EyePosition();

		if( AIController(Instigator.Controller)!=None && Instigator.Controller.Target!=None )
		{
			EndTrace = StartTrace + vector(PointRot)*weaponRange;
			Weapon.bBlockHitPointTraces = false;
			HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);
            Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;

			if( HitActor==None )
			{
				EndTrace = Instigator.Controller.Target.Location;
    			Weapon.bBlockHitPointTraces = false;
				HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);
                Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;
			}
			if( HitActor==None )
				HitLocation = Instigator.Controller.Target.Location;
			HitActor = Instigator.Controller.Target;
		}
		else
		{
			EndTrace = StartTrace + vector(PointRot)*weaponRange;
            Weapon.bBlockHitPointTraces = false;
            HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);
            Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;
		}

		

			LastHitActor = KFDoorMover(HitActor);
			LastHitActorB = BDWheeledVehicle(HitActor);

			if( LastHitActor!=none && Level.NetMode!=NM_Client )
			{
			AdjustedLocation = Hitlocation;
			AdjustedLocation.Z = (Hitlocation.Z - 0.15 * Instigator.collisionheight);

			HitActor.TakeDamage(MyDamage, Instigator, HitLocation , vector(PointRot),hitDamageClass);
			Spawn(class'KFWelderHitEffect',,, AdjustedLocation, rotator(HitLocation - StartTrace));
			}
			
			if( LastHitActorB!=none && Level.NetMode!=NM_Client )
			{

			
//						Instigator.ReceiveLocalizedMessage(class'BDMessageGas', 1);
//						LastHitActorB.Health+=(LastHitActorB.Health+1);
						AdjustedLocation = Hitlocation;
						AdjustedLocation.Z = (Hitlocation.Z - 0.15 * Instigator.collisionheight);
						HitActor.TakeDamage(0, Instigator, HitLocation , vector(PointRot),hitDamageClass);
						Spawn(class'KFWelderHitEffect',,, AdjustedLocation, rotator(HitLocation - StartTrace));			


					
			}

	}
			

}



function BDWheeledVehicle GetHealee()
{
	local Actor B;
	local vector Dummy,End,Start;

	if( AIController(Instigator.Controller)!=None )
		Return BDWheeledVehicle(Instigator.Controller.Target);
	Start = Instigator.Location+Instigator.EyePosition();
	End = Start+vector(Instigator.GetViewRotation())*weaponRange;
    Instigator.bBlockHitPointTraces = false;
	B = Instigator.Trace(Dummy,Dummy,End,Start,True);
    Instigator.bBlockHitPointTraces = Instigator.default.bBlockHitPointTraces;
	return BDWheeledVehicle(B);
}


function KFDoorMover GetDoor()
{
	local Actor A;
	local vector Dummy,End,Start;

	if( AIController(Instigator.Controller)!=None )
		Return KFDoorMover(Instigator.Controller.Target);
	Start = Instigator.Location+Instigator.EyePosition();
	End = Start+vector(Instigator.GetViewRotation())*weaponRange;
    Instigator.bBlockHitPointTraces = false;
	A = Instigator.Trace(Dummy,Dummy,End,Start,True);
    Instigator.bBlockHitPointTraces = Instigator.default.bBlockHitPointTraces;
	return KFDoorMover(A);
}

function bool AllowFire()
{
	local KFDoorMover WeldTarget;
	local BDWheeledVehicle RepairTarget;

	RepairTarget = GetHealee();
	WeldTarget = GetDoor();

	// Can't use welder, if no door.
	if ( WeldTarget == none && RepairTarget == none )
	{
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).CheckForHint(54);

			if ( FailTime + 0.5 < Level.TimeSeconds )
			{
				PlayerController(Instigator.Controller).ClientMessage(NoWeldTargetMessage, 'CriticalEvent');
				FailTime = Level.TimeSeconds;
			}

		}

		return false;
	}

	if(WeldTarget.bDisallowWeld)
	{
		if( PlayerController(Instigator.controller)!=None )
			PlayerController(Instigator.controller).ClientMessage(CantWeldTargetMessage, 'CriticalEvent');

	return false;
	}
	
	if(RepairTarget!=none && (RepairTarget.health >= RepairTarget.HealthMax))
	{
		if( PlayerController(Instigator.controller)!=None )
			PlayerController(Instigator.controller).ClientMessage(NoHealTargetMessage, 'CriticalEvent');
	
	return false;
	}
	
    return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire ;

		
	
}

defaultproperties
{
     NoWeldTargetMessage="You must be near a weldable door or damaged vehicle to use the welder."
     CantWeldTargetMessage="You cannot weld this door."
     HealAttemptDelay=0.500000
     HealMessageDelay=10.000000
     NoHealTargetMessage="You do not need to repair this vehicle!"
     TraceRange=50.000000
     damageConst=10
     maxAdditionalDamage=0
     DamagedelayMin=0.100000
     DamagedelayMax=0.100000
     hitDamageClass=Class'KFMod.DamTypeWelder'
     MeleeHitSounds(0)=Sound'PatchSounds.WelderFire'
     TransientSoundVolume=1.800000
     FireRate=0.200000
     AmmoClass=Class'KFMod.WelderAmmo'
     AmmoPerFire=20
}
