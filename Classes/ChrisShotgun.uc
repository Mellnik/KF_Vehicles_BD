class ChrisShotgun extends BDVisibleHullMG;


#exec OBJ LOAD FILE=..\Animations\BDVehiclesB.ukx
#exec OBJ LOAD FILE=..\Textures\BDVehicle_T.utx

defaultproperties
{
     NumMags=500
     ReloadLength=10.000000
     ReloadAnim="SGReload"
     YawBone="CHR_Spine3"
     YawStartConstraint=46000.000000
     YawEndConstraint=56000.000000
     PitchBone="CHR_Spine3"
     PitchUpLimit=3000
     PitchDownLimit=61000
     WeaponFireAttachmentBone="Bone01"
     GunnerAttachmentBone="CHR_RThigh"
     WeaponFireOffset=5.000000
     DualFireOffset=1.000000
     Spread=0.015000
     FireInterval=0.800000
     FireSoundClass=Sound'KF_PumpSGSnd.SGBase.SG_FireST1'
     FireSoundVolume=512.000000
     FireForce="AssaultRifleFire"
     DamageType=Class'KFMod.DamTypeShotgun'
     DamageMin=30
     DamageMax=35
     TraceRange=20000.000000
     Momentum=8500.000000
     ProjectileClass=Class'KFMod.ShotgunBullet'
     ShakeRotTime=1.000000
     AIInfo(0)=(aimerror=42.000000)
     InitialPrimaryAmmo=8
     Mesh=SkeletalMesh'BDVehiclesB.ChrisRShotty'
     Skins(0)=Combiner'KF_Soldier_Trip_T.Uniforms.brit_soldier_I_cmb'
     Skins(1)=Texture'KF_Soldier_Trip_T.heads.chris_head_diff'
     Skins(2)=Texture'KF_Weapons3rd_Trip_T.Shotguns.CombatShotgun_3rd'
}
