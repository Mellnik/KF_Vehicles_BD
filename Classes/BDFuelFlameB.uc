// The fire that gets spawned when a Fuel Can pickup is shot. This damages pawns and then dissipates.
class BDFuelFlameB extends Emitter;

var bool bFlashed;

simulated function PostBeginPlay()
{
	Super.Postbeginplay();
	NadeLight();
}
simulated function NadeLight()
{
	if ( !Level.bDropDetail && (Instigator != None)
		&& ((Level.TimeSeconds - LastRenderTime < 0.2) || (PlayerController(Instigator.Controller) != None)) )
	{
		bDynamicLight = true;
		SetTimer(35.0, false);
	}
	else Timer();
}
simulated function Timer()
{
	bDynamicLight = false;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UniformSize=True
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=240,G=122,R=15,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,A=255))
         Opacity=0.220000
         FadeOutStartTime=1.000000
         FadeInEndTime=1.000000
         MaxParticles=15
         StartLocationOffset=(Z=-4.000000)
         StartLocationRange=(X=(Min=-120.000000,Max=120.000000),Y=(Min=-120.000000,Max=120.000000))
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
         StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         Texture=Texture'BDVehicle_T.Fuel.BlueFire_01'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(Z=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(0)=SpriteEmitter'KF_Vehicles_BD.BDFuelFlameB.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         FadeIn=True
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.010000
         FadeOutStartTime=1.000000
         FadeInEndTime=1.000000
         MaxParticles=5
         StartLocationOffset=(Z=-5.000000)
         StartLocationRange=(X=(Min=-120.000000,Max=120.000000),Y=(Min=-120.000000,Max=120.000000))
         StartSizeRange=(X=(Min=65.000000,Max=150.000000),Y=(Min=65.000000,Max=150.000000),Z=(Min=65.000000,Max=65.000000))
         Texture=Texture'BDVehicle_T.Fuel.White_Flash'
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(Z=(Max=30.000000))
     End Object
     Emitters(1)=SpriteEmitter'KF_Vehicles_BD.BDFuelFlameB.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         Acceleration=(Z=100.000000)
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.750000,Color=(B=96,G=160,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Z=(Min=0.670000,Max=2.000000))
         MaxParticles=30
         StartLocationOffset=(Z=-4.000000)
         StartLocationRange=(X=(Min=-120.000000,Max=120.000000),Y=(Min=-120.000000,Max=120.000000))
         SpinsPerSecondRange=(X=(Max=0.070000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=56.000000),Y=(Min=30.000000,Max=45.000000),Z=(Min=0.000000,Max=0.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         ScaleSizeByVelocityMax=0.000000
         Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=0.750000,Max=1.250000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=25.000000,Max=45.000000))
     End Object
     Emitters(2)=SpriteEmitter'KF_Vehicles_BD.BDFuelFlameB.SpriteEmitter2'

     AutoDestroy=True
     LightType=LT_Pulse
     LightHue=30
     LightSaturation=100
     LightBrightness=500.000000
     LightRadius=8.000000
     bNoDelete=False
     RemoteRole=ROLE_SimulatedProxy
     AmbientSound=Sound'Amb_Destruction.Fire.Kessel_Fire_Small_Vehicle'
     LifeSpan=10.000000
     SoundVolume=255
     SoundRadius=100.000000
     bNotOnDedServer=False
}
