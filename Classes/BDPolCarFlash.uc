class BDPolCarFlash extends Emitter;

//-----------------------------------------------------------
// function
//-----------------------------------------------------------

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         UseSizeScale=True
         UniformSize=True
         ColorScale(0)=(RelativeTime=0.020000,Color=(B=128))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255))
         ColorScaleRepeats=0.010000
         FadeOutStartTime=0.020000
         FadeInEndTime=0.010000
         MaxParticles=1
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'BDVehicle_T.Headlights.GUP-PoliceLightFlare'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.200000,Max=0.200000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'KF_Vehicles_BD.BDPolCarFlash.SpriteEmitter1'

     bNoDelete=False
     bDetailAttachment=True
     RemoteRole=ROLE_SimulatedProxy
     DrawScale=0.500000
     bHardAttach=True
     bNotOnDedServer=False
}
