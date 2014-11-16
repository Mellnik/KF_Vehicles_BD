//-----------------------------------------------------------
// Braindead - TW Hippy Camper Van - Texture by Arramus
//-----------------------------------------------------------
class TWHippieCampVan extends TWCampVan;

#exec OBJ LOAD FILE=..\Animations\BDVehicles.ukx
#exec OBJ LOAD FILE=..\Textures\KillingFloorTextures.utx
#exec OBJ LOAD FILE=..\sounds\BDVehicles_A.uax
#exec obj LOAD FILE=..\StaticMeshes\BDVehicles_S.usx

defaultproperties
{
     Skins(0)=Combiner'BDVehicle_T.Vehicle.TWHipFinal'
     Skins(1)=Combiner'BDVehicle_T.Vehicle.TWHipFinal'
}
