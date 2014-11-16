//-----------------------------------------------------------
// It Breaks good..
//-----------------------------------------------------------
class BDKFDECO_Smashable extends decoration;

var () float RespawnTime;
var () bool  bNeedsSingleShot;     // If true, it will only smash on damage if it's all in a single shot
var  bool  bImperviusToPlayer;   // If true, the player can't smash it
var () bool bExplosive;
var () float       ExplosionDamage;
var () float ExplosionRadius;
var () float ExplosionForce;
var class<DamageType> ExplosionDamType;
Var () sound       explosionsound;  //sound to make when exploded if not available in emitter
var() class<Pickup> DestroyedContents;    // spawned when destroyed
var() bool bContentsRespawn;
var() bool bShootable;
var() bool bZombieIgnore;
var() class<StaticMeshActor>   ResiDestroyedSM; // Mesh left after main mesh destroyed
var() class<Actor>           ResiDestroyedEffect; //Effect left after main mesh destroyed mainly for gas pump

replication
{
    reliable if (Role == ROLE_Authority)
          ResiDestroyedEffect;
}

function Landed(vector HitNormal);
function HitWall (vector HitNormal, actor Wall);
singular function PhysicsVolumeChange( PhysicsVolume NewVolume );
singular function BaseChange();

function Reset()
{
    super.Reset();
    Gotostate('Working');
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    disable('tick');
    CullDistance = default.CullDistance;
}


function BreakApart(vector HitLocation, vector momentum)
{


    // If we are single player or on a listen server, just spawn the actor, otherwise
    // bHidden will trigger the effect

    if (Level.NetMode == NM_ListenServer || Level.NetMode == NM_StandAlone)
    {
        if ( EffectWhenDestroyed!=None && EffectIsRelevant(location,false) )
            Spawn( EffectWhenDestroyed, Owner,, Location );
            PlaySound(explosionsound,Slot_None,2.0);

    }

    gotostate('Broken');
}

auto state Working
{
    function BeginState()
    {
        super.BeginState();

        SetCollision(true,true,true);
        NetUpdateTime = Level.TimeSeconds - 1;
        bHidden = false;
        //Health = default.health;
    }

    function EndState()
    {
        local Pawn DummyPawn;
        local pickup DroppedPickup;
        local vector AdjustedLoc;


        super.EndState();

        NetUpdateTime = Level.TimeSeconds - 1;
        bHidden = true;
        SetCollision(false,false,false);
        TriggerEvent( Event, self , DummyPawn);
        //PostNetReceive();
 //       Spawn( EffectWhenDestroyed, Owner,, Location );
            PlaySound(explosionsound,Slot_None,2.0);
        AdjustedLoc = Location;
        AdjustedLoc.Z += 0.5 * collisionHeight;

		if (bExplosive)
			HurtRadius( ExplosionDamage, ExplosionRadius, ExplosionDamType, ExplosionForce, Location );

		if ( Role == ROLE_Authority )
		{
			if( (DestroyedContents!=None) && !Level.bStartup )
			{
				DroppedPickup = Spawn(DestroyedContents,,,AdjustedLoc );
				if( !bContentsRespawn && DroppedPickup!=None )
					DroppedPickup.RespawnTime = 0;
			}
		}
	}

    function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
    {




        if ( Instigator != None )
            MakeNoise(1.0);


     if (Instigator != none && Instigator.IsA('KFMonster'))
     {
            Health -= Damage;
            if ( Health < 0 )
                BreakApart(HitLocation, Momentum);
     }


     if(!bShootable)
     {
       if(DamageType != None && (DamageType == Class'KFMod.DamTypeAA12Shotgun' || DamageType == Class'KFMod.DamTypeAK47AssaultRifle' || DamageType == Class'KFMod.DamTypeBullpup' || DamageType == Class'KFMod.DamTypeCrossbow' || DamageType == Class'KFMod.DamTypeCrossbowHeadShot' || DamageType == Class'KFMod.DamTypeDBShotgun' || DamageType == Class'KFMod.DamTypeDeagle' || DamageType == Class'KFMod.DamTypeDualDeagle' || DamageType == Class'KFMod.DamTypeDualies' || DamageType == Class'KFMod.DamTypeKFSnipe' || DamageType == Class'KFMod.DamTypeM14EBR' || DamageType == Class'KFMod.DamTypeMP7M' || DamageType == Class'KFMod.DamTypeSCARMK17AssaultRifle' || DamageType == Class'KFMod.DamTypeShotgun' || DamageType == Class'KFMod.Axe' || DamageType == Class'KFMod.DamTypeKnife' || DamageType == Class'KFMod.DamTypeMachete' || DamageType == Class'KFMod.DamTypeWinchester' || DamageType == Class'KFMod.DamTypeMAC10MP' || DamageType == Class'KFMod.DamTypeMac10MPInc' ))
           {
           damage = 0;
	   }
	else
           {
            Health -= Damage;
            if ( Health < 0 )
                BreakApart(HitLocation, Momentum);
           }
     }
      else
     {
            Health -= Damage;
            if ( Health < 0 )
            BreakApart(HitLocation, Momentum);
     }

        

    }

    function Bump( actor Other )
    {

	local KFMonster GlassCrasher;
	local class <DamageType> DummyDam;

        if ( Mover(Other) != None && Mover(Other).bResetting )
            return;

        if ( KFHumanPawn(Other)!=None && bImperviusToPlayer )
            return;

        if ( VSize(Other.Velocity)>500 )
            BreakApart(Other.Location, Other.Velocity);

	if (!bZombieIgnore)
        {
	 	if (Other.IsA('KFMonster'))
	 	{
			GlassCrasher = KFMonster(Other);
	
        	 GlassCrasher.DoorAttack(Self);

			TakeDamage(GlassCrasher.MeleeDamage,GlassCrasher,location,Other.Velocity,DummyDam);
         	}
 
         	else if( ExtendedZCollision(Other)!=None &&
         	Other.Base != none && KFMonster(Other.Base) != none )
         	{
			GlassCrasher = KFMonster(Other.Base);

         	GlassCrasher.DoorAttack(Self);

			TakeDamage(GlassCrasher.MeleeDamage,GlassCrasher,location,Other.Velocity,DummyDam);
	 	}
         }
         else
         {
         	return;
         }


    }

    function bool EncroachingOn(Actor Other)
    {
        if ( Mover(Other) != None && Mover(Other).bResetting )
            return false;

        BreakApart(Other.Location, Other.Velocity);
        return false;
    }


    event EncroachedBy(Actor Other)
    {
        if ( Mover(Other) != None && Mover(Other).bResetting )
            return;

        BreakApart(Other.Location, Other.Velocity);
    }
}


state Broken
{
    function BeginState()
    {
        super.BeginState();

            Spawn( ResiDestroyedSM );

    if ( ResiDestroyedEffect!=None )
         Spawn( ResiDestroyedEffect );

       if(RespawnTime > 0)
        SetTimer(RespawnTime,false);
    }

    event Timer()
    {
        local pawn p;
        super.Timer();

        foreach RadiusActors(class'Pawn', P, CollisionRadius * 1.25)
        {
            SetTimer(5,false);
            return;
        }

        GotoState('Working');
    }
}

simulated function PostNetReceive()
{
    if ( bHidden &&  EffectWhenDestroyed != none && EffectIsRelevant(location,false) )
 
       Spawn( EffectWhenDestroyed, Owner,, Location );

}


/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;

    if( bHurtEntry )
        return;

    bHurtEntry = true;
    foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
    {
        // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
        if( (Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
        {
            dir = Victims.Location - HitLocation;
            dist = FMax(1,VSize(dir));
            dir = dir/dist;
            damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

            Victims.TakeDamage
            (
                damageScale * DamageAmount,
                Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                (damageScale * Momentum * dir),
                DamageType
            );

        }
    }
    bHurtEntry = false;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
    DrawType=DT_StaticMesh
    bStatic=false
    bStasis=false
    bDamageable=true
    bCanBeDamaged=true
    bEdShouldSnap=true
    bUseCylinderCollision=false
    bCollideActors=true
    bCollideWorld=true
    bBlockActors=true
    bBlockKarma=true
    bFixedRotationDir=true
    explosionsound=none
    StaticMesh=StaticMesh'BDVehicle_SB.Fence01'

    bPushable=false
   bMovable=true
    bshootable=False

    bOrientOnSlope=true
    bNoDelete = true
    EffectWhenDestroyed=Class'KF_Vehicles_BD.BDKFDoorExplodeWood'


    Health=50
    RespawnTime=0
    bNeedsSingleShot=False
    bImperviusToPlayer=true
    bNetInitialRotation=true
    RemoteRole=ROLE_SimulatedProxy
    bNetNotify=true
    CullDistance=4500
    NetUpdateFrequency=1

    Physics = PHYS_None
}
