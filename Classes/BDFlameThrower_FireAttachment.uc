class BDFlameThrower_FireAttachment extends AimedAttachment;

var Actor               actFire;		// the actor on fire
var float               burnInterval;	// interval till next time to apply damage
var int                 burnDamage;		// how much damage to apply
var HitFlameBig         hFlame;		// the emitter
var class<DamageType>   myDmgType;

replication
{
	unreliable if ( Role == ROLE_Authority )
		actFire;
}

//-----------------------------------------------------------
//  PostNetBeginPlay
//-----------------------------------------------------------
simulated function PostNetBeginPlay()
{
	if((actFire == none) && (owner != none))
		actFire = owner;

	// spawn the effects
	if(actFire != none)
	{
		hFlame = Spawn(class'HitFlameBig',,,actFire.Location);
		hFlame.LifeSpan = LifeSpan + 5.0;
		hFlame.SetBase(actFire);

	}
}

//-----------------------------------------------------------
//  BeginPlay
//-----------------------------------------------------------
function BeginPlay()
{
	SetBase(actFire);
	SetTimer(burnInterval, false);  // sets a timer with that interval, and loop set to false
}

//-----------------------------------------------------------
//  Timer
//-----------------------------------------------------------
function Timer()
{
	if(actFire != none)
	{
		// apply damage to actor
		actFire.TakeDamage(burnDamage, Instigator, Location, vect(0.0,0.0,0.0), myDmgType);
		SetTimer(burnInterval, false);  // set timer again

		// make the flame age and stuff
		if(hFlame != none)
		{
			hFlame.mRegenRange[0] *= LifeSpan;
			hFlame.mRegenRange[1] = hFlame.mRegenRange[0];
			hFlame.SoundVolume = byte(hFlame.SoundVolume * LifeSpan);
		}
	}
}

//-----------------------------------------------------------
//  Destroyed
//-----------------------------------------------------------
simulated function Destroyed()
{
	if(hFlame != none)
	{
		hFlame.Destroy();
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
     BurnInterval=1.000000
     burnDamage=5
     myDmgType=Class'KFMod.DamTypeBurned'
     LifeSpan=9.000000
     Texture=None
}
