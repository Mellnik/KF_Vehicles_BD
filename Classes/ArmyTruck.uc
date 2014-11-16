//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ArmyTruck extends BDwheeledvehicle;


#exec OBJ LOAD FILE=..\Animations\BDVehicles.ukx
#exec OBJ LOAD FILE=..\Textures\BDVehicle_T.utx
#exec obj LOAD FILE=..\StaticMeshes\BDVehicles_S.usx
#exec obj load file=..\Sounds\BDVehicles_A.uax

/*

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType,optional int h)
{
	health-=damage;
	Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}
*/

defaultproperties
{
     nofuelsound=Sound'BDVehicles_A.Vehicle.nofuelsound'
     MaxFuel=1500.000000
     SteeringWheelBone="SWCentre"
     WheelSoftness=0.040000
     WheelPenScale=1.500000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=1.500000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=25.000000
     WheelSuspensionOffset=-10.000000
     WheelSuspensionMaxRenderTravel=25.000000
     FTScale=0.030000
     ChassisTorqueScale=0.700000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=8.000000),(InVal=1000000000.000000,OutVal=8.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2500.000000)))
     GearRatios(0)=-0.500000
     GearRatios(1)=0.400000
     GearRatios(2)=0.650000
     GearRatios(3)=0.850000
     GearRatios(4)=1.100000
     TransRatio=0.110000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=110.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.100000
     IdleRPM=500.000000
     EngineRPMSoundRange=10000.000000
     SteerBoneAxis=AXIS_Z
     RevMeterScale=4000.000000
     bMakeBrakeLights=True
     BrakeLightOffset(0)=(X=-173.000000,Y=73.000000,Z=30.000000)
     BrakeLightOffset(1)=(X=-173.000000,Y=-73.000000,Z=30.000000)
     PassengerWeapons(0)=(WeaponPawnClass=Class'KF_Vehicles_BD.ChrisShotgunPawn',WeaponBone="PSeat")
     PassengerWeapons(1)=(WeaponPawnClass=Class'KF_Vehicles_BD.BDPassPawn',WeaponBone="PSeat01")
     PassengerWeapons(2)=(WeaponPawnClass=Class'KF_Vehicles_BD.BDPassPawn',WeaponBone="PSeat03")
     PassengerWeapons(3)=(WeaponPawnClass=Class'KF_Vehicles_BD.ChrisShotgunPawnRear',WeaponBone="RearGunner")
     IdleSound=Sound'BDVehicles_A.PRV.PRVEng01'
     StartUpSound=Sound'BDVehicles_A.PRV.PRVStart01'
     ShutDownSound=Sound'BDVehicles_A.PRV.PRVStop01'
     StartUpForce="PRVStartUp"
     ShutDownForce="PRVShutDown"
     DestroyedVehicleMesh=StaticMesh'BDVehicles_S.ArmyDest'
     DestructionEffectClass=Class'KF_Vehicles_BD.BDVehicleDestroyedEmitter'
     DisintegrationHealth=-25.000000
     DestructionLinearMomentum=(Min=100.000000,Max=10.000000)
     DamagedEffectOffset=(X=60.000000,Y=60.000000,Z=10.000000)
     DamagedEffectAccScale=1.000000
     HeadlightCoronaOffset(0)=(X=245.542969,Y=43.732540,Z=45.548340)
     HeadlightCoronaOffset(1)=(X=245.542969,Y=-42.732540,Z=45.548340)
     HeadlightCoronaMaterial=Texture'BDVehicle_T.Headlights.FlashFlare1'
     HeadlightCoronaMaxSize=20.000000
     HeadlightProjectorMaterial=Texture'BDVehicle_T.Headlights.RVprojector'
     HeadlightProjectorOffset=(X=140.000000,Z=7.000000)
     HeadlightProjectorRotation=(Pitch=-2000)
     HeadlightProjectorScale=0.300000
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         BoneName="tire02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=34.000000
         SupportBoneName="RrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'KF_Vehicles_BD.ArmyTruck.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         BoneName="tire04"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=34.000000
         SupportBoneName="LrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'KF_Vehicles_BD.ArmyTruck.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=34.000000
         SupportBoneName="RFrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'KF_Vehicles_BD.ArmyTruck.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=34.000000
         SupportBoneName="LfrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'KF_Vehicles_BD.ArmyTruck.LFWheel'

     VehicleMass=8.000000
     bCanDoTrickJumps=True
     DrivePos=(X=159.921005,Y=34.284000,Z=125.000000)
     DriveAnim="driving"
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryPosition=(X=70.000000,Y=-60.000000,Z=10.000000)
     EntryRadius=190.000000
     FPCamPos=(X=165.000000,Y=30.000000,Z=130.000000)
     TPCamLookat=(X=200.000000,Z=150.000000)
     TPCamWorldOffset=(Z=100.000000)
     MomentumMult=2.000000
     DriverDamageMult=0.400000
     VehiclePositionString="In an Army Truck"
     VehicleNameString="Army Truck"
     ObjectiveGetOutDist=1500.000000
     FlagRotation=(Yaw=32768)
     GroundSpeed=500.000000
     HealthMax=150.000000
     Health=150
     Mesh=SkeletalMesh'BDVehicles.truckv1'
     DrawScale=0.900000
     Skins(0)=Combiner'KillingFloorTextures.VehichleShaders.armytruckhigh_cmb'
     Skins(1)=Combiner'BDVehicle_T.Vehicle.truckintcomb_fin'
     Skins(2)=Shader'BDVehicle_T.Vehicle.Windscreen_shader'
     SoundVolume=180
     CollisionRadius=175.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.300000,Z=-0.500000)
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'KF_Vehicles_BD.ArmyTruck.KParams0'

}
