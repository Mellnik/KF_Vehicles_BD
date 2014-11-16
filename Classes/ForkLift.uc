//-----------------------------------------------------------
// Braindead - ForkLift
//-----------------------------------------------------------
class ForkLift extends BDWheeledvehicle;

Var sound        forks;

#exec OBJ LOAD FILE=..\Animations\BDVehiclesB.ukx
#exec OBJ LOAD FILE=..\Textures\Foundry_T.UTX
#exec OBJ LOAD FILE=..\sounds\BDVehicles_A.uax
#exec obj LOAD FILE=..\StaticMeshes\BDVehicles_S.usx

//-----------------------------------------------------------
//  VehicleFire
//-----------------------------------------------------------
function VehicleFire(bool bWasAltFire)
{

             PlayAnim('ForksUp');

            PlaySound(Forks, SLOT_None, 2.0,,,, False);
//            bWeaponIsAltFiring = True;
//            ClientPlayForceFeedback(ArmExtendForce);

		Super.VehicleFire(bWasAltFire);
}

//-----------------------------------------------------------
//  VehicleCeaseFire
//-----------------------------------------------------------
function VehicleCeaseFire(bool bWasAltFire)
{

             PlayAnim('ForksDown');

            PlaySound(Forks, SLOT_None, 2.0,,,, False);

		Super.VehicleCeaseFire(bWasAltFire);

}

//-----------------------------------------------------------
//  ClientVehicleCeaseFire
//-----------------------------------------------------------
function ClientVehicleCeaseFire(bool bWasAltFire)
{
	//avoid sending altfire to weapon
	if (bWasAltFire)
		Super(Vehicle).ClientVehicleCeaseFire(bWasAltFire);
		Super.ClientVehicleCeaseFire(bWasAltFire);
}


/*
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType,optional int h)
{
	if(instigatedby!=self)health-=damage;
	Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}
*/
function AltFire(optional float F)
{
}

simulated exec function ToggleIronSights()
{

	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

//	bWeaponIsAltFiring = true;
////	PC.ToggleZoom();
	PC.ToggleBehindView();
}

defaultproperties
{
     forks=Sound'BDVehicles_A.Hydraulics.Hydraulic02'
     Fuel=5000000000.000000
     MaxFuel=5000000000.000000
     FuelGaugeTex=None
     FuelPointer=None
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
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2800.000000)))
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
     BrakeLightOffset(0)=(X=-100.000000,Y=-43.000000,Z=22.000000)
     BrakeLightOffset(1)=(X=-100.000000,Y=43.000000,Z=22.000000)
     BrakeLightMaterial=Texture'BDVehicle_T.Headlights.FlashFlare1'
     IdleSound=Sound'BDVehicles_A.HoverTank.HoverTankIdle'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'BDVehicle_SB.FLDestroyed'
     DestructionEffectClass=Class'KF_Vehicles_BD.BDVehicleDestroyedEmitter'
     DisintegrationHealth=-25.000000
     DestructionLinearMomentum=(Min=100.000000,Max=10.000000)
     DamagedEffectOffset=(X=60.000000,Y=60.000000,Z=10.000000)
     DamagedEffectAccScale=1.000000
     HeadlightCoronaOffset(0)=(X=140.542969,Y=48.732540,Z=31.000000)
     HeadlightCoronaOffset(1)=(X=140.542969,Y=-48.732540,Z=31.000000)
     HeadlightCoronaMaxSize=20.000000
     HeadlightProjectorOffset=(X=90.000000,Z=7.000000)
     HeadlightProjectorRotation=(Pitch=-2000)
     HeadlightProjectorScale=0.300000
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         SteerType=VST_Inverted
         BoneName="RearRTire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=7.000000)
         WheelRadius=22.000000
         SupportBoneName="RrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'KF_Vehicles_BD.ForkLift.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         SteerType=VST_Inverted
         BoneName="RearLTire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-7.000000)
         WheelRadius=22.000000
         SupportBoneName="LrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'KF_Vehicles_BD.ForkLift.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         BoneName="FrontRTire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=7.000000)
         WheelRadius=22.000000
         SupportBoneName="RFrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'KF_Vehicles_BD.ForkLift.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         BoneName="FrontLTire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-7.000000)
         WheelRadius=22.000000
         SupportBoneName="LfrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'KF_Vehicles_BD.ForkLift.LFWheel'

     VehicleMass=3.000000
     bCanDoTrickJumps=True
     bHasHandbrake=True
     bSeparateTurretFocus=True
     DrivePos=(X=-45.000000,Z=118.000000)
     DriveRot=(Pitch=2000)
     DriveAnim="driving"
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryRadius=160.000000
     FPCamPos=(X=-45.000000,Z=123.000000)
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     VehiclePositionString="On a ForkLift"
     VehicleNameString="ForkLift"
     MaxDesireability=0.400000
     ObjectiveGetOutDist=1500.000000
     GroundSpeed=600.000000
     Mesh=SkeletalMesh'BDVehiclesB.fl'
     Skins(0)=Combiner'Foundry_T.Forklift_CMB'
     Skins(1)=Combiner'Foundry_T.Forklift_CMB'
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
         KMaxSpeed=500.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'KF_Vehicles_BD.ForkLift.KParams0'

}
