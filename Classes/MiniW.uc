//-----------------------------------------------------------
// Braindead - Mini Cooper
//-----------------------------------------------------------
class MiniW extends MiniR;

#exec OBJ LOAD FILE=..\Animations\BDVehicles.ukx
#exec OBJ LOAD FILE=..\Textures\BDVehicle_T.utx
#exec OBJ LOAD FILE=..\sounds\BDVehicles_A.uax
#exec obj LOAD FILE=..\StaticMeshes\BDVehicles_S.usx

defaultproperties
{
     Skins(0)=Combiner'BDVehicle_T.Vehicle.miniWFinal'
     Skins(3)=Texture'BDVehicle_NP.Filt69'
}
