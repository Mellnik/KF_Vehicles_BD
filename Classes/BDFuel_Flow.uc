class BDFuel_Flow extends Emitter;

//=====================================================================================================
//=====================================================================================================
//==
//==        D E F A U L T P R O P E R T I E S
//==
//=====================================================================================================
//=====================================================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         FadeIn=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=-250.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=1.000000
         FadeInEndTime=0.260000
         MaxParticles=100
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=30.000000)
         SizeScaleRepeats=1.000000
         StartSizeRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'BDVehicle_T.Fuel.FuelSpill'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
     End Object
     Emitters(0)=SpriteEmitter'KF_Vehicles_BD.BDFuel_Flow.SpriteEmitter1'

     AutoDestroy=True
     bNoDelete=False
}
