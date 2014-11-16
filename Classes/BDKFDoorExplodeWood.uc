class BDKFDoorExplodeWood extends KFDoorExplode;

             #exec OBJ LOAD FILE=KFWeaponSound.uax

var() array<Sound> ImpactSounds;

simulated function PostBeginPlay()
{
	local vector MinVel, MaxVel;

	Super.PostBeginPlay();

	if(Emitters.Length>0)
	{
		MinVel.X = Emitters[0].StartVelocityRange.X.Min;
		MinVel.Y = Emitters[0].StartVelocityRange.Y.Min;
		MinVel.Z = Emitters[0].StartVelocityRange.Z.Min;

		MaxVel.X = Emitters[0].StartVelocityRange.X.Max;
		MaxVel.Y = Emitters[0].StartVelocityRange.Y.Max;
		MaxVel.Z = Emitters[0].StartVelocityRange.Z.Max;

		MinVel = MinVel >> Rotation;
		MaxVel = MaxVel >> Rotation;

		Emitters[0].StartVelocityRange.X.Min = MinVel.X;
		Emitters[0].StartVelocityRange.Y.Min = MinVel.Y;
		Emitters[0].StartVelocityRange.Z.Min = MinVel.Z;

		Emitters[0].StartVelocityRange.X.Max = MaxVel.X;
		Emitters[0].StartVelocityRange.Y.Max = MaxVel.Y;
		Emitters[0].StartVelocityRange.Z.Max = MaxVel.Z;
	}
	// Ok, now let's do the same for Emitter 1
	if(Emitters.Length>1)
	{
		MinVel.X = Emitters[1].StartVelocityRange.X.Min;
		MinVel.Y = Emitters[1].StartVelocityRange.Y.Min;
		MinVel.Z = Emitters[1].StartVelocityRange.Z.Min;

		MaxVel.X = Emitters[1].StartVelocityRange.X.Max;
		MaxVel.Y = Emitters[1].StartVelocityRange.Y.Max;
		MaxVel.Z = Emitters[1].StartVelocityRange.Z.Max;

		MinVel = MinVel >> Rotation;
		MaxVel = MaxVel >> Rotation;

		Emitters[1].StartVelocityRange.X.Min = MinVel.X;
		Emitters[1].StartVelocityRange.Y.Min = MinVel.Y;
		Emitters[1].StartVelocityRange.Z.Min = MinVel.Z;

		Emitters[1].StartVelocityRange.X.Max = MaxVel.X;
		Emitters[1].StartVelocityRange.Y.Max = MaxVel.Y;
		Emitters[1].StartVelocityRange.Z.Max = MaxVel.Z;
	}
	if( ImpactSounds.Length>0 )
		PlaySound(ImpactSounds[Rand(ImpactSounds.Length)]);
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter95
         StaticMesh=StaticMesh'BDVehicle_SB.BoardA'
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-1500.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         FadeOutStartTime=3.000000
         MaxParticles=2
         StartLocationRange=(Z=(Max=128.000000))
         SpinsPerSecondRange=(Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Max=1.000000),Z=(Max=1.000000))
         InitialParticlesPerSecond=5000.000000
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=500.000000,Max=500.000000))
     End Object
     Emitters(0)=MeshEmitter'KF_Vehicles_BD.BDKFDoorExplodeWood.MeshEmitter95'

     Begin Object Class=MeshEmitter Name=MeshEmitter96
         StaticMesh=StaticMesh'BDVehicle_SB.BoardB'
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-1500.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         FadeOutStartTime=3.000000
         MaxParticles=2
         StartLocationRange=(Z=(Max=128.000000))
         SpinsPerSecondRange=(Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Max=1.000000),Z=(Max=1.000000))
         InitialParticlesPerSecond=5000.000000
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=500.000000,Max=500.000000))
     End Object
     Emitters(1)=MeshEmitter'KF_Vehicles_BD.BDKFDoorExplodeWood.MeshEmitter96'

     Begin Object Class=MeshEmitter Name=MeshEmitter97
         StaticMesh=StaticMesh'BDVehicle_SB.BoardC'
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-1500.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         FadeOutStartTime=3.000000
         MaxParticles=2
         StartLocationRange=(Z=(Max=128.000000))
         SpinsPerSecondRange=(Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Max=1.000000),Z=(Max=1.000000))
         InitialParticlesPerSecond=5000.000000
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=500.000000,Max=500.000000))
     End Object
     Emitters(2)=MeshEmitter'KF_Vehicles_BD.BDKFDoorExplodeWood.MeshEmitter97'

}
