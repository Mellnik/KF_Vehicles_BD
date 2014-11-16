class TraderShotgun extends BDVisibleHullMG;


#exec OBJ LOAD FILE=..\Animations\BDVehiclesB.ukx
#exec OBJ LOAD FILE=..\Textures\BDVehicle_T.utx

defaultproperties
{
     NumMags=500
     ReloadLength=5.000000
     ReloadAnim="Reload"
     YawBone="CHR_Spine2"
     YawStartConstraint=46000.000000
     YawEndConstraint=56000.000000
     PitchBone="CHR_Spine2"
     PitchUpLimit=3000
     PitchDownLimit=61000
     WeaponFireAttachmentBone=
     GunnerAttachmentBone="CHR_RThigh"
     WeaponFireOffset=5.000000
     DualFireOffset=1.000000
     Spread=0.015000
     FireSoundClass=SoundGroup'KF_AK47Snd.AK47_Fire'
     FireSoundVolume=512.000000
     FireForce="AssaultRifleFire"
     DamageType=Class'KFMod.DamTypeAK47AssaultRifle'
     DamageMin=30
     DamageMax=40
     TraceRange=20000.000000
     Momentum=8500.000000
     ProjectileClass=Class'KFMod.BoomStickBullet'
     ShakeRotTime=1.000000
     AIInfo(0)=(aimerror=42.000000)
     InitialPrimaryAmmo=30
     Mesh=SkeletalMesh'BDVehiclesB.tradershot'
     Skins(0)=Texture'KF_Soldier_Trip_T.Uniforms.shopkeeper_diff'
}
