class BDMatch_Flame extends Emitter;

//-----------------------------------------------------------
// function
//-----------------------------------------------------------

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeIn=True
         UniformSize=True
         Acceleration=(X=5.000000,Y=5.000000,Z=10.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.140000
         FadeOutStartTime=0.400000
         FadeInEndTime=0.400000
         MaxParticles=1
         StartSizeRange=(X=(Min=4.000000,Max=4.000000),Y=(Min=4.000000,Max=4.000000),Z=(Min=4.000000,Max=4.000000))
         Texture=Texture'BDVehicle_T.Fuel.MatchFlameb'
         LifetimeRange=(Min=0.400000,Max=0.400000)
         StartVelocityRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Min=10.000000,Max=10.000000))
     End Object
     Emitters(0)=SpriteEmitter'KF_Vehicles_BD.BDMatch_Flame.SpriteEmitter1'

     AutoDestroy=True
     bNoDelete=False
     LifeSpan=3.000000
}
