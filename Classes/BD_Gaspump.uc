//=============================================================================
// Derived from RKW_Gaspump & KFGlassMover by Alex
//=============================================================================
// Original code created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class BD_Gaspump extends Decoration;

var int			Backup_Health;
var VolumeTimer	VT;
var Controller	DelayedDamageInstigatorController;
var float		RadiusDamage;
var bool		bCheckForStackedBarrels;
var () class <Emitter> BreakGlassBits;


replication
{
    reliable if (Role == ROLE_Authority)
    BreakGlassBits,BreakWindow;
}


function Landed(vector HitNormal);
function HitWall (vector HitNormal, actor Wall);
singular function PhysicsVolumeChange( PhysicsVolume NewVolume );
singular function BaseChange();

   
function PostBeginPlay()
{
}

simulated function PostNetBeginPlay()
{
//	bClientCracked = bCracked;
//	if( !bHidden && bCracked )
//		CrackWindow();
	bNetNotify = !bHidden;
}


simulated function PostNetReceive()
{
	if( bHidden )
	{
		BreakWindow();
		bNetNotify = False;
	}
}

function SetDelayedDamageInstigatorController(Controller C)
{
	DelayedDamageInstigatorController = C;
}



simulated function SetInitialState();



function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, class<DamageType> damageType, optional int HitIndex)
{
	if ( !bDamageable || (Health<0) )
		return;

	if ( damagetype == None )
		DamageType = class'DamageType';

///	if ( InstigatedBy != None )
//		Instigator = InstigatedBy;
//	else if ((instigatedBy == None || instigatedBy.Controller == None) && //DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
//		instigatedBy = DelayedDamageInstigatorController.Pawn;

//	if ( Instigator != None )
//		MakeNoise(1.0);

	Health -= NDamage;
	FragMomentum = Momentum;

	if ( Health <= 0 )
	{
		BreakWindow();
//		SetCollision(false, false, false);
//		bHidden = true;
//		NetUpdateTime = Level.TimeSeconds - 1;
//		CheckNearbyBarrels();

//		if ( BreakGlassBits != None )
			Spawn( BreakGlassBits, Owner,, Location );
//			Spawn( BreakGlassBits );

//		VT = Spawn(class'VolumeTimer', Self);
//		VT.SetTimer(0.2, false);
	}
}

/*
/* Barrels stacked on top, are set off instantly. Sides and below are set off with a slight delay */
function CheckNearbyBarrels()
{
	bCheckForStackedBarrels = true;
	HurtRadius( 100, RadiusDamage, class'RKW_DamTypeExploGaspumpl', 256, Location );
}

// delayed explosion for barrel chain reaction explosions
function TimerPop( VolumeTimer T )
{
	VT.Destroy();
	bCheckForStackedBarrels = false;
	HurtRadius( 100, RadiusDamage, class'RKW_DamTypeExploGaspumpl', 256, Location );
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
		/* Set off top barrels instantly, side and below are set off with a delay*/
		if ( bCheckForStackedBarrels && Victims.IsA('RKW_Gaspump') && Victims.Location.Z <= HitLocation.Z )
			continue;

		/* limit damage radius to right next barrel, so we can set them of one after the other */
		if ( Victims.IsA('RKW_Gaspump') && !IsNearbyBarrel(Victims) )
			continue;

		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( DelayedDamageInstigatorController );
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
		}
	}
	bHurtEntry = false;
}

simulated final function bool IsNearbyBarrel(Actor A)
{
	local vector Dir;

	Dir = Location - A.Location;
	if ( abs(Dir.Z) > CollisionHeight*2.67 )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius*2.25 );
}

*/
/*
function Reset()
{
	super.Reset();

	NetUpdateTime = Level.TimeSeconds - 1;
	Health	= Backup_Health;
	bHidden = false;
	SetCollision(true, true, true);
}
*/
function Bump( actor Other )
{

	local KFMonster GlassCrasher;
	local class <DamageType> DummyDam;


	if ( Mover(Other) != None && Mover(Other).bResetting )
		return;

	if ( VSize(Other.Velocity) > 500 )
	{
		Instigator = Pawn(Other);
		if ( Instigator != None && Instigator.Controller != None )
			SetDelayedDamageInstigatorController( Instigator.Controller );
		TakeDamage( VSize(Other.Velocity)*0.03, Instigator, Location, vect(0,0,0), class'Crushed');
	}

	if (Other.IsA('KFMonster'))
	{
		GlassCrasher = KFMonster(Other);

        GlassCrasher.HandleBumpGlass();

		TakeDamage(GlassCrasher.MeleeDamage,GlassCrasher,location,Other.Velocity,DummyDam);
	}
	else if( ExtendedZCollision(Other)!=None &&
        Other.Base != none && KFMonster(Other.Base) != none )
    {
		GlassCrasher = KFMonster(Other.Base);

        GlassCrasher.HandleBumpGlass();

		TakeDamage(GlassCrasher.MeleeDamage,GlassCrasher,location,Other.Velocity,DummyDam);
	}
}

simulated function BreakWindow()
{
	SetCollision(false,false,false);
	bHidden = true;
	NetUpdateTime = Level.TimeSeconds - 1;
//	if( Level.NetMode!=NM_DedicatedServer )
		Spawn(BreakGlassBits);
}

event EncroachedBy(Actor Other)
{
	if ( Mover(Other) != None && Mover(Other).bResetting )
		return;

	Instigator = Pawn(Other);
	if ( Instigator != None && Instigator.Controller != None )
		SetDelayedDamageInstigatorController( Instigator.Controller );
	TakeDamage( 1000, Instigator, Location, vect(0,0,0), class'Crushed');
}

function bool EncroachingOn(Actor Other)
{
	if ( Mover(Other) != None && Mover(Other).bResetting )
		return false;

	Instigator = Pawn(Other);
	if ( Instigator != None && Instigator.Controller != None )
		SetDelayedDamageInstigatorController( Instigator.Controller );
	TakeDamage( 1000, Instigator, Location, vect(0,0,0), class'Crushed');
	return false;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RadiusDamage=256.000000
     BreakGlassBits=Class'KFMod.BreakWindowGlassEmitter'
     bDamageable=True
     Health=25
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'22Patch.OilSpill'
     bStatic=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=1.000000
     NetPriority=2.700000
     DrawScale=3.000000
     Skins(0)=Shader'KillingFloorLabTextures.Statics.GlassShader'
     AmbientGlow=10
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockKarma=True
     bEdShouldSnap=True
}
