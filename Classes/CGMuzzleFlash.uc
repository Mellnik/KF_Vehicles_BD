class CGMuzzleFlash extends MuzzleFlash1stKar;


simulated function Trigger(Actor Other, Pawn EventInstigator)
{
	Emitters[0].SpawnParticle(1);
	Emitters[1].SpawnParticle(1);
	Emitters[2].SpawnParticle(1);
	Emitters[3].SpawnParticle(1);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter22
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=187,G=252,R=255,A=255))
         FadeOutStartTime=0.046740
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=0.437000,Max=0.573000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.820000)
         StartSizeRange=(X=(Min=35.518997,Max=50.999001))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'BDVehicle_T.Muzzle.Muzzle1'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         SubdivisionScale(0)=0.900000
         SubdivisionScale(1)=0.100000
         SubdivisionScale(2)=0.001000
         LifetimeRange=(Min=0.057000,Max=0.057000)
         StartVelocityRange=(X=(Min=1621.162964,Max=1621.162964))
     End Object
     Emitters(0)=SpriteEmitter'KF_Vehicles_BD.CGMuzzleFlash.SpriteEmitter22'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter20
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         ColorMultiplierRange=(X=(Min=0.760000,Max=0.760000),Y=(Min=0.692000,Max=0.760000),Z=(Min=0.638000,Max=0.638000))
         FadeOutStartTime=0.037050
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=0.387000,Max=0.495000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.370000,RelativeSize=0.757000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=40.122002,Max=40.122002))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'BDVehicle_T.Muzzle.Muzzle1'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         SubdivisionScale(0)=0.900000
         SubdivisionScale(1)=0.100000
         SubdivisionScale(2)=0.001000
         LifetimeRange=(Min=0.057000,Max=0.057000)
         StartVelocityRange=(X=(Min=3168.000000,Max=3168.000000))
     End Object
     Emitters(1)=SpriteEmitter'KF_Vehicles_BD.CGMuzzleFlash.SpriteEmitter20'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter21
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         ColorMultiplierRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.800000,Max=0.900000),Z=(Min=0.704000,Max=0.704000))
         FadeOutStartTime=0.003120
         CoordinateSystem=PTCS_Relative
         MaxParticles=9
         StartLocationRange=(Y=(Min=-7.535000,Max=7.535000),Z=(Min=-7.535000,Max=7.535000))
         SpinsPerSecondRange=(X=(Min=0.025000,Max=0.035000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.280000,RelativeSize=1.126000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.870000)
         StartSizeRange=(X=(Min=20.900000,Max=23.318001))
         InitialParticlesPerSecond=450.179993
         Texture=Texture'BDVehicle_T.Muzzle.Muzzle1'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         SubdivisionScale(0)=0.900000
         SubdivisionScale(1)=0.100000
         SubdivisionScale(2)=0.001000
         LifetimeRange=(Min=0.052000,Max=0.052000)
         StartVelocityRange=(X=(Min=5672.000000,Max=5672.000000))
     End Object
     Emitters(2)=SpriteEmitter'KF_Vehicles_BD.CGMuzzleFlash.SpriteEmitter21'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         ColorScale(0)=(Color=(A=255))
         ColorScale(1)=(RelativeTime=0.375000,Color=(B=30,G=30,R=30,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(A=255))
         FadeOutStartTime=0.161000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationRange=(X=(Min=90.421997,Max=257.404999))
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.600000)
         StartSizeRange=(X=(Min=25.680000,Max=45.110001))
         InitialParticlesPerSecond=102.010002
         Texture=Texture'BDVehicle_T.Muzzle.MuzzleSmoke1'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         SubdivisionScale(0)=0.900000
         SubdivisionScale(1)=0.100000
         LifetimeRange=(Min=0.161000,Max=0.161000)
         StartVelocityRange=(X=(Min=278.571014,Max=1059.355957),Y=(Min=-120.000000,Max=120.000000),Z=(Min=-120.000000,Max=120.000000))
         VelocityLossRange=(X=(Min=14.000000,Max=14.000000))
     End Object
     Emitters(3)=SpriteEmitter'KF_Vehicles_BD.CGMuzzleFlash.SpriteEmitter0'

}
