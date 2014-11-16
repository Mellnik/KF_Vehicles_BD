class Passenger_Police_AK47R extends BDVisibleHullMG;


#exec OBJ LOAD FILE=..\Animations\BDVehiclesB.ukx
#exec OBJ LOAD FILE=..\Textures\BDVehicle_T.utx

defaultproperties
{
     NumMags=500
     ReloadLength=3.000000
     ReloadAnim="AKReload"
     YawBone="CHR_Spine3"
     YawStartConstraint=9000.000000
     YawEndConstraint=16000.000000
     PitchBone="CHR_Spine3"
     PitchUpLimit=3000
     PitchDownLimit=61000
     WeaponFireAttachmentBone="Bone01"
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
     Mesh=SkeletalMesh'BDVehiclesB.PolPassAK'
     Skins(0)=Combiner'KF_Soldier_Trip_T.Uniforms.british_riot_police_cmb'
     Skins(1)=FinalBlend'KF_Soldier_Trip_T.Uniforms.british_riot_police_fb'
     Skins(2)=Texture'KF_Weapons3rd2_Trip_T.Rifles.AK47_3rd'
     Skins(4)=Combiner'KF_Soldier_Trip_T.Uniforms.british_riot_police_cmb'
}
