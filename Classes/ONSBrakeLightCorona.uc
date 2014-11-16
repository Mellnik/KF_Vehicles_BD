class ONSBrakelightCorona extends Light;

simulated function UpdateBrakelightState(float Brake, int Gear)
{
	if(Brake > 0.01f)
	{
		bCorona = true;
		LightHue = 255;
		LightSaturation = 48;
	}
	else if(Gear == 0)
	{
		bCorona = true;
		LightHue = 255;
		LightSaturation = 255;
	}
	else
	{
		bCorona = false;
	}
}

defaultproperties
{
     MaxCoronaSize=15.000000
     CoronaRotation=10.000000
     LightType=LT_None
     LightHue=255
     LightSaturation=175
     LightBrightness=0.000000
     LightPeriod=0
     LightCone=0
     DrawType=DT_None
     bCorona=True
     bDirectionalCorona=True
     bStatic=False
     bHidden=False
     bNoDelete=False
     bDetailAttachment=True
     bNetInitialRotation=True
     RemoteRole=ROLE_None
     DrawScale=0.300000
     bUnlit=True
     bMovable=True
     bHardAttach=True
}
