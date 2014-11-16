//=============================================================================
// Welder Inventory class
//=============================================================================
class BDWelder extends Welder
	dependson(KFVoicePack);

#exec OBJ LOAD FILE=KF_Weapons_Trip_T.utx

var() float             HealAmount;
var int                 HealPause;
var int                 HealPauseMax;
var bool                bRepairing;

// Scripted Nametag vars



// Speech



var () int HealBoostAmount;
Const MaxAmmoCount=500;
var float RegenTimer;


function byte BestMode()
{
	return 1;
}

simulated function float RateSelf()
{
	return -100;
}

simulated function Destroyed()
{
	Super.Destroyed();
	if( ScriptedScreen!=None )
	{
		ScriptedScreen.SetSize(256,256);
		ScriptedScreen.FallBackMaterial = None;
		ScriptedScreen.Client = None;
		Level.ObjectPool.FreeObject(ScriptedScreen);
		ScriptedScreen = None;
	}
	if( ShadedScreen!=None )
	{
		ShadedScreen.Diffuse = None;
		ShadedScreen.Opacity = None;
		ShadedScreen.SelfIllumination = None;
		ShadedScreen.SelfIlluminationMask = None;
		Level.ObjectPool.FreeObject(ShadedScreen);
		ShadedScreen = None;
		skins[3] = None;
	}
}

// Destroy this stuff when the level changes
simulated function PreTravelCleanUp()
{
	if( ScriptedScreen!=None )
	{
		ScriptedScreen.SetSize(256,256);
		ScriptedScreen.FallBackMaterial = None;
		ScriptedScreen.Client = None;
		Level.ObjectPool.FreeObject(ScriptedScreen);
		ScriptedScreen = None;
	}

	if( ShadedScreen!=None )
	{
		ShadedScreen.Diffuse = None;
		ShadedScreen.Opacity = None;
		ShadedScreen.SelfIllumination = None;
		ShadedScreen.SelfIlluminationMask = None;
		Level.ObjectPool.FreeObject(ShadedScreen);
		ShadedScreen = None;
		skins[3] = None;
	}
}

simulated function InitMaterials()
{
	if( ScriptedScreen==None )
	{
		ScriptedScreen = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
        ScriptedScreen.SetSize(256,256);
		ScriptedScreen.FallBackMaterial = ScriptedScreenBack;
		ScriptedScreen.Client = Self;
	}

	if( ShadedScreen==None )
	{
		ShadedScreen = Shader(Level.ObjectPool.AllocateObject(class'Shader'));
		ShadedScreen.Diffuse = ScriptedScreen;
		ShadedScreen.SelfIllumination = ScriptedScreen;
		skins[3] = ShadedScreen;
	}
}


simulated function Tick(float dt)
{
	local KFDoorMover LastDoorHitActor;
	local BDWheeledVehicle LastVehicleHitActor;

	if (FireMode[0].bIsFiring)
		FireModeArray = 0;
	else if (FireMode[1].bIsFiring)
		FireModeArray = 1;
	else
		bJustStarted = true;
	
	if (BDWeldFire(FireMode[FireModeArray]).LastHitActor != none
		|| BDWeldFire(FireMode[FireModeArray]).LastHitActorB != none /*&& VSize(BDWeldFire(FireMode[FireModeArray]).LastHitActor.Location - Owner.Location) <= (weaponRange * 2.5) */)
	{
		bNoTarget = false;
		LastDoorHitActor = BDWeldFire(FireMode[FireModeArray]).LastHitActor;
		
        if(LastDoorHitActor != none)
        {
			ScreenWeldPercent = (LastDoorHitActor.WeldStrength / LastDoorHitActor.MaxWeld) * 100;
		}
		
		LastVehicleHitActor = BDWeldFire(FireMode[FireModeArray]).LastHitActorB;
		
		if(LastVehicleHitActor != none)
		{
			ScreenWeldPercent = (LastVehicleHitActor.Health / LastVehicleHitActor.HealthMax) * 100;
		}
		
		if( ScriptedScreen==None )
			InitMaterials();
		ScriptedScreen.Revision++;
		if( ScriptedScreen.Revision>10 )
			ScriptedScreen.Revision = 1;

		if ( Level.Game != none && Level.Game.NumPlayers > 1 && bJustStarted && Level.TimeSeconds - LastWeldingMessageTime > WeldingMessageDelay )
		{
			if ( FireMode[0].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				{
					PlayerController(Instigator.Controller).Speech('AUTO', 0, "");
				}
			}
			else if ( FireMode[1].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				{
					PlayerController(Instigator.Controller).Speech('AUTO', 1, "");
				}
			}
		}
	}
	/*else if ((BDWeldFire(FireMode[FireModeArray]).LastHitActor == none || BDWeldFire(FireMode[FireModeArray]).LastHitActor != none)/* && VSize(BDWeldFire(FireMode[FireModeArray]).LastHitActor.Location - Owner.Location) > (weaponRange * 2.5)*/ )
	{
		if( ScriptedScreen==None )
			InitMaterials();
		ScriptedScreen.Revision++;
		if( ScriptedScreen.Revision>10 )
			ScriptedScreen.Revision = 1;
		bNoTarget = true;
		if( ClientState != WS_Hidden && Level.NetMode != NM_DedicatedServer && Instigator != none && Instigator.IsLocallyControlled() )
		{
		  PlayIdle();
		}
	}*/

	/*if (BDWeldFire(FireMode[FireModeArray]).LastHitActorB != none && VSize(BDWeldFire(FireMode[FireModeArray]).LastHitActorB.Location - Owner.Location) <= (weaponRange * 2.5) )
	{
		bNoTarget = false;
		LastVehicleHitActor = BDWeldFire(FireMode[FireModeArray]).LastHitActorB;
		
		if(LastVehicleHitActor != none)
		{
			ScreenWeldPercent = (LastVehicleHitActor.Health / LastVehicleHitActor.HealthMax) * 100;
		}
		
		//if(LastVehicleHitActor.Health < 100)
		//	LastVehicleHitActor.Health += 1;
		
		if( ScriptedScreen==None )
			InitMaterials();
		ScriptedScreen.Revision++;
		if( ScriptedScreen.Revision>10 )
			ScriptedScreen.Revision = 1;

		if ( Level.Game != none && Level.Game.NumPlayers > 1 && bJustStarted && Level.TimeSeconds - LastWeldingMessageTime > WeldingMessageDelay )
		{
			if ( FireMode[0].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				{
					PlayerController(Instigator.Controller).Speech('AUTO', 0, "");
				}
			}
			else if ( FireMode[1].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				{
					PlayerController(Instigator.Controller).Speech('AUTO', 1, "");
				}
			}
		}
	}*/
	else if (BDWeldFire(FireMode[FireModeArray]).LastHitActorB == none
		|| BDWeldFire(FireMode[FireModeArray]).LastHitActorB != none  && VSize(WeldFire(FireMode[FireModeArray]).LastHitActor.Location - Owner.Location) > (weaponRange * 2.5) && !bNoTarget )
	{
		if( ScriptedScreen==None )
			InitMaterials();
		ScriptedScreen.Revision++;
		if( ScriptedScreen.Revision>10 )
			ScriptedScreen.Revision = 1;
		bNoTarget = true;
		if( ClientState != WS_Hidden && Level.NetMode != NM_DedicatedServer && Instigator != none && Instigator.IsLocallyControlled() )
		{
		  PlayIdle();
		}
	}	
	if ( AmmoAmount(0) < FireMode[0].AmmoClass.Default.MaxAmmo)
	{
		AmmoRegenCount += (dT * AmmoRegenRate );
		ConsumeAmmo(0, -1*(int(AmmoRegenCount)));
		AmmoRegenCount -= int(AmmoRegenCount);
	}
}

simulated function float ChargeBar()
{
	return FMin(1, (AmmoAmount(0))/(FireMode[0].AmmoClass.Default.MaxAmmo));
}


simulated event RenderTexture(ScriptedTexture Tex)
{
	local int SizeX,  SizeY;

	Tex.DrawTile(0,0,Tex.USize,Tex.VSize,0,0,256,256,Texture'KillingFloorWeapons.Welder.WelderScreen',BackColor);   // Draws the tile background

	if(!bNoTarget && ScreenWeldPercent > 0 )
	{
		// Err for now go with a name in black letters
		NameColor.R=(255 - (ScreenWeldPercent * 2));
		NameColor.G=(0 + (ScreenWeldPercent * 2.55));
		NameColor.B=(20 + ScreenWeldPercent);
		NameColor.A=255;
		Tex.TextSize(ScreenWeldPercent@"%",NameFont,SizeX,SizeY); // get the size of the players name
		Tex.DrawText( (Tex.USize - SizeX) * 0.5, 85,ScreenWeldPercent@"%", NameFont, NameColor);
		Tex.TextSize("Integrity:",NameFont,SizeX,SizeY);
		Tex.DrawText( (Tex.USize - SizeX) * 0.5, 50,"Integrity:", NameFont, NameColor);
	}
	else
	{
		NameColor.R=255;
		NameColor.G=255;
		NameColor.B=255;
		NameColor.A=255;
		Tex.TextSize("-",NameFont,SizeX,SizeY); // get the size of the players name
		Tex.DrawText( (Tex.USize - SizeX) * 0.5, 85,"-", NameFont, NameColor);
		Tex.TextSize("Integrity:",NameFont,SizeX,SizeY);
		Tex.DrawText( (Tex.USize - SizeX) * 0.5, 50,"Integrity:", NameFont, NameColor);
	}
}



simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	bNoTarget =  true;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
}

/*		if (BDWeldFire(FireMode[FireModeArray]).LastHitActorB.Health < BDWeldFire(FireMode[FireModeArray]).LastHitActorB.HealthMax)
		{
			 Instigator.ReceiveLocalizedMessage(class'BDMessageGas', 1);
				if ((BDWeldFire(FireMode[FireModeArray]).LastHitActorB.Health + default.HealAmount) > BDWeldFire(FireMode[FireModeArray]).LastHitActorB.HealthMax)
				{
					bRepairing=true;
					NewHealth = (BDWeldFire(FireMode[FireModeArray]).LastHitActorB.Health + default.HealAmount) - BDWeldFire(FireMode[FireModeArray]).LastHitActorB.HealthMax;
					BDWeldFire(FireMode[FireModeArray]).LastHitActorB.Health += NewHealth;
						if ((BDWeldFire(FireMode[FireModeArray]).LastHitActorB.Health + default.HealAmount) <= BDWeldFire(FireMode[FireModeArray]).LastHitActorB.HealthMax)
						{
						bRepairing=true;
						BDWeldFire(FireMode[FireModeArray]).LastHitActorB.Health += HealAmount;
						}
				}

		
*/	
/*
//		ScreenWeldPercent = ((BDWeldFire(FireMode[FireModeArray]).LastHitActorB.WeldStrength) / //(BDWeldFire(FireMode[FireModeArray]).LastHitActorB.MaxWeld)) * 100;
		if( ScriptedScreen==None )
			InitMaterials();
		ScriptedScreen.Revision++;
		if( ScriptedScreen.Revision>10 )
			ScriptedScreen.Revision = 1;

		if ( Level.Game != none && Level.Game.NumPlayers > 1 && bJustStarted && Level.TimeSeconds - LastWeldingMessageTime > WeldingMessageDelay )
		{
			if ( FireMode[0].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				{
				    PlayerController(Instigator.Controller).Speech('AUTO', 0, "");
				}
			}
			else if ( FireMode[1].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				{
				    PlayerController(Instigator.Controller).Speech('AUTO', 1, "");
				}
			}
		}
	}
	else if (BDWeldFire(FireMode[FireModeArray]).LastHitActorB == none || BDWeldFire(FireMode[FireModeArray]).LastHitActorB != none && VSize(BDWeldFire(FireMode[FireModeArray]).LastHitActorB.Location - Owner.Location) > (weaponRange * 1.5) && !bNoTarget  )
	{
		if( ScriptedScreen==None )
			InitMaterials();
		ScriptedScreen.Revision++;
		if( ScriptedScreen.Revision>10 )
			ScriptedScreen.Revision = 1;
		bNoTarget = true;
		if( ClientState != WS_Hidden && Level.NetMode != NM_DedicatedServer && Instigator != none && Instigator.IsLocallyControlled() )
*/

defaultproperties
{
     HealAmount=2.000000
     HealPauseMax=3
     HealBoostAmount=5
     FireModeClass(0)=Class'KF_Vehicles_BD.BDWeldFire'
	 ItemName="Vehicle Welder"
     PickupClass=Class'KF_Vehicles_BD.BDWelderPickup'
}
