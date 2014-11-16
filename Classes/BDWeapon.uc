//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BDWeapon extends ROvehicleweapon
   ;


var() name  fireanim;

simulated function PostBeginPlay()
{
	YawConstraintDelta = (YawEndConstraint - YawStartConstraint) & 65535;
	if (AltFireInterval ~= 0.0) //doesn't have an altfire
	{
		AltFireInterval = FireInterval;
		AIInfo[1] = AIInfo[0];
	}

	if (bShowChargingBar && Owner != None)
		Vehicle(Owner).bShowChargingBar = true; //for listen/standalone clients

	if (Level.GRI != None && Level.GRI.WeaponBerserk > 1.0)
		SetFireRateModifier(Level.GRI.WeaponBerserk);

	// RO functionality
	if( BeginningIdleAnim != '' && HasAnim(BeginningIdleAnim))
	{
	    PlayAnim(BeginningIdleAnim);
	}

}



simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
//	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);
	Canvas.DrawText("bActive: "$bActive@"bCorrectAim: "$bCorrectAim);
	YPos += YL;
	Canvas.SetPos(4, YPos);
	Canvas.DrawText("DebugInfo: "$DebugInfo);
}
/*
simulated function PostBeginPlay()
{
    YawConstraintDelta = (YawEndConstraint - YawStartConstraint) & 65535;
    if (AltFireInterval ~= 0.0) //doesn't have an altfire
    {
    	AltFireInterval = FireInterval;
    	AIInfo[1] = AIInfo[0];
    }

    if (bShowChargingBar && Owner != None)
    	Vehicle(Owner).bShowChargingBar = true; //for listen/standalone clients

    if (Level.GRI != None && Level.GRI.WeaponBerserk > 1.0)
    	SetFireRateModifier(Level.GRI.WeaponBerserk);
}
*/
simulated function PostNetBeginPlay()
{
    if (bInstantFire)
        GotoState('InstantFireMode');
    else
        GotoState('ProjectileFireMode');

    InitEffects();

    MaxRange();

    Super.PostNetBeginPlay();
}

simulated function InitEffects()
{
    // don't even spawn on server
    if (Level.NetMode == NM_DedicatedServer)
		return;

    if ( (FlashEmitterClass != None) && (FlashEmitter == None) )
    {
        FlashEmitter = Spawn(FlashEmitterClass);
        FlashEmitter.SetDrawScale(DrawScale);
        if (WeaponFireAttachmentBone == '')
            FlashEmitter.SetBase(self);
        else
            AttachToBone(FlashEmitter, WeaponFireAttachmentBone);

        FlashEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0));
    }

    if (AmbientEffectEmitterClass != none && AmbientEffectEmitter == None)
    {
        AmbientEffectEmitter = spawn(AmbientEffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);
        if (WeaponFireAttachmentBone == '')
            AmbientEffectEmitter.SetBase(self);
        else
            AttachToBone(AmbientEffectEmitter, WeaponFireAttachmentBone);

        AmbientEffectEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0));
    }
}

simulated function SetGRI(GameReplicationInfo GRI)
{
	if (GRI.WeaponBerserk > 1.0)
		SetFireRateModifier(GRI.WeaponBerserk);
}

simulated function SetFireRateModifier(float Modifier)
{
	if (FireInterval == AltFireInterval)
	{
		FireInterval = default.FireInterval / Modifier;
		AltFireInterval = FireInterval;
	}
	else
	{
		FireInterval = default.FireInterval / Modifier;
		AltFireInterval = default.AltFireInterval / Modifier;
	}
}

function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal);
simulated event ClientSpawnHitEffects();


//ClientStartFire() and ClientStopFire() are only called for the client that owns the weapon (and not at all for bots)
simulated function ClientStartFire(Controller C, bool bAltFire)
{
    bIsAltFire = bAltFire;

	if (FireCountdown <= 0)
	{
		if (bIsRepeatingFF)
		{
			if (bIsAltFire)
				ClientPlayForceFeedback( AltFireForce );
			else
				ClientPlayForceFeedback( FireForce );
		}
		OwnerEffects();
	}
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
	if (bIsRepeatingFF)
	{
		if (bIsAltFire)
			StopForceFeedback( AltFireForce );
		else
			StopForceFeedback( FireForce );
	}

	if (Role < ROLE_Authority && AmbientEffectEmitter != None)
		AmbientEffectEmitter.SetEmitterStatus(false);
}

simulated function ClientPlayForceFeedback( String EffectName )
{
    local PlayerController PC;

    if (Instigator == None)
    	return;

    PC = PlayerController(Instigator.Controller);
    if ( PC != None && PC.bEnableGUIForceFeedback )
    {
        PC.ClientPlayForceFeedback( EffectName );
    }
}

simulated function StopForceFeedback( String EffectName )
{
    local PlayerController PC;

    if (Instigator == None)
    	return;

    PC = PlayerController(Instigator.Controller);
    if ( PC != None && PC.bEnableGUIForceFeedback )
    {
        PC.StopForceFeedback( EffectName );
    }
}

//do effects (muzzle flash, force feedback, etc) immediately for the weapon's owner (don't wait for replication)
simulated event OwnerEffects()
{
	if (!bIsRepeatingFF)
	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
    

	if (Role < ROLE_Authority)
	{
		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        FlashMuzzleFlash(false);

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

        // Play firing noise
        if (!bAmbientFireSound)
        {
            if (bIsAltFire)
                PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            else
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
	}
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (FireCountdown <= 0)
	{
		CalcWeaponFire(baltfire);
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			FireCountdown = AltFireInterval;
			AltFire(C);
		}
		else
		{
		    FireCountdown = AltFireInterval;
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}

function rotator AdjustAim(bool bAltFire)
{
	local rotator AdjustedAim, ControllerAim;
	local int n;

	if ( (Instigator == None) || (Instigator.Controller == None) )
		return WeaponFireRotation;

	if ( bAltFire )
		n = 1;

	if ( !SavedFireProperties[n].bInitialized )
	{
		SavedFireProperties[n].AmmoClass = class'Ammo_Dummy';
		if ( bAltFire )
			SavedFireProperties[n].ProjectileClass = AltFireProjectileClass;
		else
			SavedFireProperties[n].ProjectileClass = ProjectileClass;
		SavedFireProperties[n].WarnTargetPct = AIInfo[n].WarnTargetPct;
		SavedFireProperties[n].MaxRange = MaxRange();
		SavedFireProperties[n].bTossed = AIInfo[n].bTossed;
		SavedFireProperties[n].bTrySplash = AIInfo[n].bTrySplash;
		SavedFireProperties[n].bLeadTarget = AIInfo[n].bLeadTarget;
		SavedFireProperties[n].bInstantHit = AIInfo[n].bInstantHit;
		SavedFireProperties[n].bInitialized = true;
	}

	ControllerAim = Instigator.Controller.Rotation;

	AdjustedAim = Instigator.AdjustAim(SavedFireProperties[n], WeaponFireLocation, AIInfo[n].AimError);
	if (AdjustedAim == Instigator.Rotation || AdjustedAim == ControllerAim)
		return WeaponFireRotation; //No adjustment
	else
	{
		AdjustedAim.Pitch = Instigator.LimitPitch(AdjustedAim.Pitch);
		return AdjustedAim;
}
}

//AI: return the best fire mode for the situation
function byte BestMode()
{
	return Rand(2);
}

function Fire(Controller C)
{
    log(self$": Fire has been called outside of a state!");
}

function AltFire(Controller C)
{
    log(self$": AltFire has been called outside of a state!");
}

// return false if out of range, can't see target, etc.
function bool CanAttack(Actor Other)
{
    local float Dist, CheckDist;
    local vector HitLocation, HitNormal, projStart;
    local actor HitActor;

    if ( (Instigator == None) || (Instigator.Controller == None) )
        return false;

    // check that target is within range
    Dist = VSize(Instigator.Location - Other.Location);
    if (Dist > MaxRange())
        return false;

    // check that can see target
    if (!Instigator.Controller.LineOfSightTo(Other))
        return false;

	if (ProjectileClass != None)
	{
		CheckDist = FMax(CheckDist, 0.5 * ProjectileClass.Default.Speed);
		CheckDist = FMax(CheckDist, 300);
		CheckDist = FMin(CheckDist, VSize(Other.Location - Location));
	}
	if (AltFireProjectileClass != None)
	{
		CheckDist = FMax(CheckDist, 0.5 * AltFireProjectileClass.Default.Speed);
		CheckDist = FMax(CheckDist, 300);
		CheckDist = FMin(CheckDist, VSize(Other.Location - Location));
	}

    // check that would hit target, and not a friendly
	CalcWeaponFire(false);
    projStart = WeaponFireLocation;
    if (bInstantFire)
        HitActor = Trace(HitLocation, HitNormal, Other.Location + Other.CollisionHeight * vect(0,0,0.8), projStart, true);
    else
    {
        // for non-instant hit, only check partial path (since others may move out of the way)
        HitActor = Trace(HitLocation, HitNormal,
                projStart + CheckDist * Normal(Other.Location + Other.CollisionHeight * vect(0,0,0.8) - Location),
                projStart, true);
    }

    if ( (HitActor == None) || (HitActor == Other) || (Pawn(HitActor) == None)
		|| (Pawn(HitActor).Controller == None) || !Instigator.Controller.SameTeamAs(Pawn(HitActor).Controller) )
        return true;

    return false;
}

simulated function float MaxRange()
{
	if (bInstantFire)
	{
        if (Instigator != None && Instigator.Region.Zone != None && Instigator.Region.Zone.bDistanceFog)
			TraceRange = FClamp(Instigator.Region.Zone.DistanceFogEnd, 8000, default.TraceRange);
		else
			TraceRange = default.TraceRange;

		AimTraceRange = TraceRange;
	}
	else if ( ProjectileClass != None )
		AimTraceRange = ProjectileClass.static.GetRange();
	else
		AimTraceRange = 10000;

	return AimTraceRange;
}

state InstantFireMode
{
    function Fire(Controller C)
    {
        FlashMuzzleFlash(false);

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

    function AltFire(Controller C)
    {
    }

    simulated event ClientSpawnHitEffects()
    {
    	local vector HitLocation, HitNormal, Offset;
    	local actor HitActor;

    	// if standalone, already have valid HitActor and HitNormal
    	if ( Level.NetMode == NM_Standalone )
    		return;
    	Offset = 20 * Normal(WeaponFireLocation - LastHitLocation);
    	HitActor = Trace(HitLocation, HitNormal, LastHitLocation - Offset, LastHitLocation + Offset, False);
    	SpawnHitEffects(HitActor, LastHitLocation, HitNormal);
    }

    simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
    {
		local PlayerController PC;

		PC = Level.GetLocalPlayerController();
		if (PC != None && ((Instigator != None && Instigator.Controller == PC) || VSize(PC.ViewTarget.Location - HitLocation) < 5000))
		{
			if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) )
			{
				// check for splash
				if ( Base != None )
				{
					Base.bTraceWater = true;
					HitActor = Base.Trace(HitLocation,HitNormal,HitLocation,Location + 200 * Normal(HitLocation - Location),true);
					Base.bTraceWater = false;
				}
				else
				{
					bTraceWater = true;
					HitActor = Trace(HitLocation,HitNormal,HitLocation,Location + 200 * Normal(HitLocation - Location),true);
					bTraceWater = false;
				}
			}
		}
    }
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
        PlayAnim(fireanim);
    	SpawnProjectile(ProjectileClass, False);
    }

    function AltFire(Controller C)
    {
        if (AltFireProjectileClass == None)
            Fire(C);
        else
            SpawnProjectile(AltFireProjectileClass, True);
    }
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local vehicleWeaponPawn WeaponPawn;
    local vector StartLocation, HitLocation, HitNormal, Extent;

    if (bDoOffsetTrace)
    {
       	Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
       	WeaponPawn = vehicleweaponpawn(Owner);
    	if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
    	{
    		if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
	else
	{
		if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
    }
    else
    	StartLocation = WeaponFireLocation;

    P = spawn(ProjClass, self, , StartLocation, WeaponFireRotation);

    if (P != None)
    {
        if (bInheritVelocity)
            P.Velocity = Instigator.Velocity;

        FlashMuzzleFlash(baltfire);

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
                AmbientSound = AltFireSoundClass;
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else
                PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
    }

    return P;
}

function CeaseFire(Controller C, bool alt)
{
    FlashCount = 0;
    HitCount = 0;

    if (AmbientEffectEmitter != None)
    {
        AmbientEffectEmitter.SetEmitterStatus(false);
    }

    if (bAmbientFireSound || bAmbientAltFireSound)
    {
        AmbientSound = None;
    }
}

function WeaponCeaseFire(Controller C, bool bWasAltFire);

simulated event FlashMuzzleFlash(bool Alt)
{
    if (Role == ROLE_Authority)
    {
    	FlashCount++;
    	NetUpdateTime = Level.TimeSeconds - 1;
    }
    else
        CalcWeaponFire(alt);

    if (FlashEmitter != None)
        FlashEmitter.Trigger(Self, Instigator);

    if ( (EffectEmitterClass != None) && EffectIsRelevant(Location,false) )
        EffectEmitter = spawn(EffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);
}

simulated function Destroyed()
{
    DestroyEffects();

    Super.Destroyed();
}

simulated function DestroyEffects()
{
    if (FlashEmitter != None)
        FlashEmitter.Destroy();
    if (EffectEmitter != None)
    	EffectEmitter.Destroy();
    if (AmbientEffectEmitter != None)
    	AmbientEffectEmitter.Destroy();
}

simulated function SetTeam(byte T)
{
    

}

/* simulated TraceFire to get precise start/end of hit */
simulated function SimulateTraceFire( out vector Start, out Rotator Dir, out vector HitLocation, out vector HitNormal )
{
    local Vector		X, End;
    local Actor			Other;
    local vehicleweaponpawn WeaponPawn;
    local Vehicle		VehicleInstigator;

    if ( bDoOffsetTrace )
    {
    	WeaponPawn = vehicleweaponpawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

	X = Vector(Dir);
    End = Start + TraceRange * X;

    // skip past vehicle driver
    VehicleInstigator = Vehicle(Instigator);
    if ( VehicleInstigator != None && VehicleInstigator.Driver != None )
    {
        VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        Other = Trace(HitLocation, HitNormal, End, Start, true);
        VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
    }
    else
        Other = Trace(HitLocation, HitNormal, End, Start, True);

    if ( Other != None && Other != Instigator )
    {
		if ( !Other.bWorldGeometry )
        {
 			if ( Vehicle(Other) != None || Pawn(Other) == None )
 			{
 				LastHitLocation = HitLocation;
			}
			HitNormal = vect(0,0,0);
        }
        else
        {
            LastHitLocation = HitLocation;
		}
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }
}

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local vehicleweaponpawn WeaponPawn;
    local Vehicle VehicleInstigator;
    local int Damage;
    local bool bDoReflect;
    local int ReflectNum;

    MaxRange();

    if ( bDoOffsetTrace )
    {
    	WeaponPawn = vehicleweaponpawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

    ReflectNum = 0;
    while ( true )
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        //skip past vehicle driver
        VehicleInstigator = Vehicle(Instigator);
        if ( ReflectNum == 0 && VehicleInstigator != None && VehicleInstigator.Driver != None )
        {
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        	Other = Trace(HitLocation, HitNormal, End, Start, true);
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
        }
        else
        	Other = Trace(HitLocation, HitNormal, End, Start, True);

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = True;
                HitNormal = vect(0,0,0);
            }
            else if (!Other.bWorldGeometry)
            {
                Damage = (DamageMin + Rand(DamageMax - DamageMin));
 				if ( Vehicle(Other) != None || Pawn(Other) == None )
 				{
 					HitCount++;
 					LastHitLocation = HitLocation;
					SpawnHitEffects(Other, HitLocation, HitNormal);
				}
               	Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
				HitNormal = vect(0,0,0);
            }
            else
            {
                HitCount++;
                LastHitLocation = HitLocation;
                SpawnHitEffects(Other, HitLocation, HitNormal);
	    }
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
            HitCount++;
            LastHitLocation = HitLocation;
        }

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if ( bDoReflect && ++ReflectNum < 4 )
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start	= HitLocation;
            Dir		= Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }

    NetUpdateTime = Level.TimeSeconds - 1;
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum);

simulated function CalcWeaponFire(bool alt)
{
    local coords WeaponBoneCoords;
    local vector CurrentFireOffset;

    // Calculate fire offset in world space
    WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);
    CurrentFireOffset = (WeaponFireOffset * vect(1,0,0)) + (DualFireOffset * vect(0,1,0));

    // Calculate rotation of the gun
    WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);

    // Calculate exact fire location
    WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);

    // Adjust fire rotation taking dual offset into account
    if (bDualIndependantTargeting)
        WeaponFireRotation = rotator(CurrentHitLocation - WeaponFireLocation);
}

function DoCombo();

simulated function float ChargeBar();

static function StaticPrecache(LevelInfo L);

defaultproperties
{
}
