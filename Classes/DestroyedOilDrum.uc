class DestroyedOilDrum extends StaticMeshActor
    placeable;

             #exec OBJ LOAD FILE=BDVehicle_SB.usx

defaultproperties
{
     StaticMesh=StaticMesh'BDVehicle_SB.oildrumdest'
     bStatic=False
     bCollideActors=False
     bBlockActors=False
     bBlockKarma=False
}
