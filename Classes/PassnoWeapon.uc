class PassnoWeapon extends BDWeapon;

#exec OBJ LOAD FILE=..\Animations\BDVehicles.ukx

defaultproperties
{
     PitchUpLimit=6000
     PitchDownLimit=59500
     WeaponFireAttachmentBone="Camera"
     GunnerAttachmentBone="Seat"
     WeaponFireOffset=200.000000
     RotationsPerSecond=2.000000
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.100000)
     Mesh=SkeletalMesh'BDVehicles.PSeat'
     Skins(0)=Texture'BDVehicle_T.HUD.INVIS'
}
