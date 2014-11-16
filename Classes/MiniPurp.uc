//-----------------------------------------------------------
// Braindead - Mini Cooper - Purple Mini skin by Arramus
//-----------------------------------------------------------
class MiniPurp extends MiniR;

#exec OBJ LOAD FILE=..\Animations\BDVehicles.ukx
#exec OBJ LOAD FILE=..\Textures\BDVehicle_T.utx
#exec OBJ LOAD FILE=..\sounds\BDVehicles_A.uax
#exec obj LOAD FILE=..\StaticMeshes\BDVehicles_S.usx

defaultproperties
{
     Skins(0)=Combiner'BDVehicle_T.Vehicle.miniPFinal'
     Skins(2)=Texture'BDVehicle_T.Vehicle.miniinteriorPkUV'
     Skins(3)=Texture'BDVehicle_NP.Arr73'
}
