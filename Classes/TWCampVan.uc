//-----------------------------------------------------------
// Braindead - TW Camper Van
//-----------------------------------------------------------
class TWCampVan extends BDWheeledvehicle;

#exec OBJ LOAD FILE=..\Animations\BDVehicles.ukx
#exec OBJ LOAD FILE=..\Textures\KillingFloorTextures.utx
#exec OBJ LOAD FILE=..\sounds\BDVehicles_A.uax
#exec obj LOAD FILE=..\StaticMeshes\BDVehicles_S.usx

defaultproperties
{
     nofuelsound=Sound'BDVehicles_A.Vehicle.nofuelsound'
     Fuel=800.000000
     SteeringWheelBone="SWCentre"
     WheelSoftness=0.025000
     WheelPenScale=1.200000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=1.350000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=15.000000
     WheelSuspensionMaxRenderTravel=15.000000
     FTScale=0.030000
     ChassisTorqueScale=0.400000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=1000000000.000000,OutVal=11.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1800.000000,OutVal=11.000000),(InVal=3000.000000)))
     GearRatios(0)=-0.500000
     GearRatios(1)=0.400000
     GearRatios(2)=0.650000
     GearRatios(3)=0.850000
     GearRatios(4)=1.100000
     TransRatio=0.150000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=160.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.100000
     IdleRPM=500.000000
     EngineRPMSoundRange=9000.000000
     RevMeterScale=4000.000000
     bMakeBrakeLights=True
     BrakeLightOffset(0)=(X=-182.000000,Y=-49.000000,Z=35.000000)
     BrakeLightOffset(1)=(X=-182.000000,Y=49.000000,Z=35.000000)
     BrakeLightMaterial=Texture'BDVehicle_T.Headlights.FlashFlare1'
     PassengerWeapons(0)=(WeaponPawnClass=Class'KF_Vehicles_BD.PoliceAK47PawnR',WeaponBone="PSeat")
     PassengerWeapons(1)=(WeaponPawnClass=Class'KF_Vehicles_BD.ChrisShotgunPawnR',WeaponBone="PSeat01")
     PassengerWeapons(2)=(WeaponPawnClass=Class'KF_Vehicles_BD.PoliceAK47Pawn',WeaponBone="PSeat02")
     PassengerWeapons(3)=(WeaponPawnClass=Class'KF_Vehicles_BD.ChrisShotgunPawn',WeaponBone="PSeat03")
     PassengerWeapons(4)=(WeaponPawnClass=Class'KF_Vehicles_BD.ChrisShotgunPawnR',WeaponBone="PSeat04")
     IdleSound=Sound'BDVehicles_A.RV.RVEng01'
     StartUpSound=Sound'BDVehicles_A.Vehicle.auto_car_start'
     ShutDownSound=Sound'BDVehicles_A.RV.RVStop01'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'BDVehicles_S.TWMeshDest'
     DestructionEffectClass=Class'KF_Vehicles_BD.BDVehicleDestroyedEmitter'
     DisintegrationHealth=-25.000000
     DestructionLinearMomentum=(Min=100.000000,Max=10.000000)
     DamagedEffectOffset=(X=60.000000,Y=60.000000,Z=10.000000)
     DamagedEffectAccScale=1.000000
     HeadlightCoronaOffset(0)=(X=143.000000,Y=45.000000,Z=45.000000)
     HeadlightCoronaOffset(1)=(X=143.000000,Y=-45.000000,Z=45.000000)
     HeadlightCoronaMaterial=Texture'BDVehicle_T.Headlights.FlashFlare1'
     HeadlightCoronaMaxSize=20.000000
     HeadlightProjectorMaterial=Texture'BDVehicle_T.Headlights.RVprojector'
     HeadlightProjectorOffset=(X=90.000000,Z=7.000000)
     HeadlightProjectorRotation=(Pitch=-2000)
     HeadlightProjectorScale=0.300000
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=7.000000)
         WheelRadius=27.000000
         SupportBoneName="RrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'KF_Vehicles_BD.TWCampVan.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire04"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-7.000000)
         WheelRadius=27.000000
         SupportBoneName="LrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'KF_Vehicles_BD.TWCampVan.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=7.000000)
         WheelRadius=27.000000
         SupportBoneName="RFrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'KF_Vehicles_BD.TWCampVan.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-7.000000)
         WheelRadius=27.000000
         SupportBoneName="LfrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'KF_Vehicles_BD.TWCampVan.LFWheel'

     VehicleMass=3.000000
     bCanDoTrickJumps=True
     bHasHandbrake=True
     bSeparateTurretFocus=True
     DrivePos=(X=68.000000,Y=-26.000000,Z=115.000000)
     DriveRot=(Pitch=2000)
     DriveAnim="driving"
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryRadius=160.000000
     FPCamPos=(X=71.000000,Y=-26.000000,Z=123.000000)
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     VehiclePositionString="in a camper van"
     VehicleNameString="TW Camper"
     MaxDesireability=0.400000
     ObjectiveGetOutDist=1500.000000
     GroundSpeed=600.000000
     Mesh=SkeletalMesh'BDVehicles.TWCamper'
     Skins(0)=Combiner'BDVehicle_T.Vehicle.TWBlueFinal'
     Skins(1)=Combiner'BDVehicle_T.Vehicle.TWBlueFinal'
     SoundVolume=180
     CollisionRadius=100.000000
     CollisionHeight=40.000000
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
     KParams=KarmaParamsRBFull'KF_Vehicles_BD.TWCampVan.KParams0'

}
