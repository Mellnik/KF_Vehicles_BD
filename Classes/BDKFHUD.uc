Class BDKFHUD extends HUDKillingFloor;

var()   SpriteWidget			MyFlameIcon;
var()   NumericWidget           FuelDigits;

simulated function SetHUDAlpha()
{
super.SetHUDAlpha();

    MyFlameIcon.Tints[0].A = KFHUDAlpha;
    MyFlameIcon.Tints[1].A = KFHUDAlpha;

	FuelDigits.Tints[0].A = KFHUDAlpha;
	FuelDigits.Tints[1].A = KFHUDAlpha;
}

simulated function UpdateHud()
{
	FuelDigits.Value = CurClipsPrimary;

	if ( BDFuelCan_Weapon(PawnOwner.Weapon) != none )
	{
		FuelDigits.Value += KFWeapon(PawnOwner.Weapon).MagAmmoRemaining;
	}
	super.updatehud();
}




simulated function DrawHudPassA (Canvas C)
{
	local KFHumanPawn KFHPawn;
	local Material TempMaterial;
	local int i;
	local float TempX, TempY, TempSize;

	KFHPawn = KFHumanPawn(PawnOwner);

	DrawDoorHealthBars(C);

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, HealthBG);
	}

	DrawSpriteWidget(C, HealthIcon);
	DrawNumericWidget(C, HealthDigits, DigitsSmall);

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, ArmorBG);
	}

	DrawSpriteWidget(C, ArmorIcon);
	DrawNumericWidget(C, ArmorDigits, DigitsSmall);

	if ( KFHPawn != none )
	{
		C.SetPos(C.ClipX * WeightBG.PosX, C.ClipY * WeightBG.PosY);

		if ( !bLightHud )
		{
			C.DrawTile(WeightBG.WidgetTexture, WeightBG.WidgetTexture.MaterialUSize() * WeightBG.TextureScale * 1.5 * HudCanvasScale * ResScaleX * HudScale, WeightBG.WidgetTexture.MaterialVSize() * WeightBG.TextureScale * HudCanvasScale * ResScaleY * HudScale, 0, 0, WeightBG.WidgetTexture.MaterialUSize(), WeightBG.WidgetTexture.MaterialVSize());
		}

		DrawSpriteWidget(C, WeightIcon);

		C.Font = LoadSmallFontStatic(5);
		C.FontScaleX = C.ClipX / 1024.0;
		C.FontScaleY = C.FontScaleX;
		C.SetPos(C.ClipX * WeightDigits.PosX, C.ClipY * WeightDigits.PosY);
		C.DrawColor = WeightDigits.Tints[0];
		C.DrawText(int(KFHPawn.CurrentWeight)$"/"$int(KFHPawn.MaxCarryWeight));
		C.FontScaleX = 1;
		C.FontScaleY = 1;
	}

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, GrenadeBG);
	}

	DrawSpriteWidget(C, GrenadeIcon);
	DrawNumericWidget(C, GrenadeDigits, DigitsSmall);

	if ( PawnOwner != none && PawnOwner.Weapon != none )
	{
		if ( Syringe(PawnOwner.Weapon) != none )
		{
			if ( !bLightHud )
			{
				DrawSpriteWidget(C, SyringeBG);
			}

			DrawSpriteWidget(C, SyringeIcon);
			DrawNumericWidget(C, SyringeDigits, DigitsSmall);
		}
		else
		{
			if ( bDisplayQuickSyringe )
			{
				TempSize = Level.TimeSeconds - QuickSyringeStartTime;
				if ( TempSize < QuickSyringeDisplayTime )
				{
					if ( TempSize < QuickSyringeFadeInTime )
					{
						QuickSyringeBG.Tints[0].A = int((TempSize / QuickSyringeFadeInTime) * 255.0);
						QuickSyringeBG.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A = QuickSyringeBG.Tints[0].A;
					}
					else if ( TempSize > QuickSyringeDisplayTime - QuickSyringeFadeOutTime )
					{
						QuickSyringeBG.Tints[0].A = int((1.0 - ((TempSize - (QuickSyringeDisplayTime - QuickSyringeFadeOutTime)) / QuickSyringeFadeOutTime)) * 255.0);
						QuickSyringeBG.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A = QuickSyringeBG.Tints[0].A;
					}
					else
					{
						QuickSyringeBG.Tints[0].A = 255;
						QuickSyringeBG.Tints[1].A = 255;
						QuickSyringeIcon.Tints[0].A = 255;
						QuickSyringeIcon.Tints[1].A = 255;
						QuickSyringeDigits.Tints[0].A = 255;
						QuickSyringeDigits.Tints[1].A = 255;
					}

					if ( !bLightHud )
					{
						DrawSpriteWidget(C, QuickSyringeBG);
					}

					DrawSpriteWidget(C, QuickSyringeIcon);
					DrawNumericWidget(C, QuickSyringeDigits, DigitsSmall);
				}
				else
				{
					bDisplayQuickSyringe = false;
				}
			}

			if ( BDWelder(PawnOwner.Weapon) != none )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, WelderBG);
				}

				DrawSpriteWidget(C, WelderIcon);
				DrawNumericWidget(C, WelderDigits, DigitsSmall);
			}

			else if( BDFuelCan_Weapon(PawnOwner.Weapon) != none )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, ClipsBG);
				}
				DrawSpriteWidget(C, MyFlameIcon);
				DrawNumericWidget(C, FuelDigits, DigitsSmall);
			}
				
			else if ( PawnOwner.Weapon.GetAmmoClass(0) != none )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, ClipsBG);
				}

				DrawNumericWidget(C, ClipsDigits, DigitsSmall);

				if ( LAW(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, LawRocketIcon);
				}
				else if ( Crossbow(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, ArrowheadIcon);
				}

				else
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, BulletsInClipBG);
					}

					DrawNumericWidget(C, BulletsInClipDigits, DigitsSmall);

					if ( Flamethrower(PawnOwner.Weapon) != none )
					{
						DrawSpriteWidget(C, FlameIcon);
						DrawSpriteWidget(C, FlameTankIcon);
					}
				    else if ( Shotgun(PawnOwner.Weapon) != none || BoomStick(PawnOwner.Weapon) != none || Winchester(PawnOwner.Weapon) != none )
				    {
					    DrawSpriteWidget(C, SingleBulletIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
				    }
					else
					{
						DrawSpriteWidget(C, ClipsIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
					}
				}

				if ( KFWeapon(PawnOwner.Weapon) != none && KFWeapon(PawnOwner.Weapon).bTorchEnabled )
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, FlashlightBG);
					}

					DrawNumericWidget(C, FlashlightDigits, DigitsSmall);

					if ( KFWeapon(PawnOwner.Weapon).FlashLight != none && KFWeapon(PawnOwner.Weapon).FlashLight.bHasLight )
					{
						DrawSpriteWidget(C, FlashlightIcon);
					}
					else
					{
						DrawSpriteWidget(C, FlashlightOffIcon);
					}
				}
			}
		}
	}

	if ( KFPRI != none && KFPRI.ClientVeteranSkill != none )
	{
		KFPRI.ClientVeteranSkill.Static.SpecialHUDInfo(KFPRI, C);
	}

	if ( KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo) == none || KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo).bHUDShowCash )
	{
		DrawSpriteWidget(C, CashIcon);
		DrawNumericWidget(C, CashDigits, DigitsBig);
	}

	if ( KFPRI != none && KFPRI.ClientVeteranSkill != none && KFPRI.ClientVeteranSkill.default.OnHUDIcon != none )
	{
		TempMaterial = KFPRI.ClientVeteranSkill.default.OnHUDIcon;

		TempSize = 36 * VeterancyMatScaleFactor * 1.4;
		TempX = C.ClipX * 0.007;
		TempY = C.ClipY * 0.93 - TempSize;

		C.SetPos(TempX, TempY);
		C.DrawTile(TempMaterial, TempSize, TempSize, 0, 0, TempMaterial.MaterialUSize(), TempMaterial.MaterialVSize());

		TempX += (TempSize - VetStarSize);
		TempY += (TempSize - (2.0 * VetStarSize));

		for ( i = 0; i < KFPRI.ClientVeteranSkillLevel; i++ )
		{
			C.SetPos(TempX, TempY);
			C.DrawTile(VetStarMaterial, VetStarSize, VetStarSize, 0, 0, VetStarMaterial.MaterialUSize(), VetStarMaterial.MaterialVSize());

			TempY -= VetStarSize;
		}
	}

	if ( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
	{
		if ( !bUsingVOIP && PlayerOwner != None && PlayerOwner.ActiveRoom != None &&
			 PlayerOwner.ActiveRoom.GetTitle() == "Team" )
		{
			bUsingVOIP = true;
			PlayerOwner.NotifySpeakingInTeamChannel();
		}

		DisplayVoiceGain(C);
	}
	else
	{
		bUsingVOIP = false;
	}

	if ( bDisplayInventory || bInventoryFadingOut )
	{
		DrawInventory(C);
	}
}

defaultproperties
{
     MyFlameIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Flame',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.220000,PosX=0.850000,PosY=0.943000,ScaleMode=SM_Right,Scale=0.900000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FuelDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.872000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
}
