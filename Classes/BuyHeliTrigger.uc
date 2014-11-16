//=============================================================================
// UseTrigger: if a player stands within proximity of this trigger, and hits Use, 
// it will send Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class BuyHeliTrigger extends UseTrigger;

//var() localized string Message;
//var() float     helicost;

function bool SelfTriggered()
{
	return true;
}

function UsedBy( Pawn user )
{

//	local Pawn EventInstigator;
//	local KFPlayerReplicationInfo PRI;

//	PRI = KFPlayerReplicationInfo(EventInstigator.PlayerReplicationInfo);

//    if ( EventInstigator != none && PRI.Score < helicost )
//		{
//		PlayerController(EventInstigator.controller).Speech('Support', 2, "");
//            PlayerController(EventInstigator.Controller).ReceiveLocalizedMessage(class'BDMessageGas', 3);
//		return;
//		}
//	else
//		{
	TriggerEvent(Event, self, user);

//		}

}

function Touch( Actor Other )
{
//	local Pawn EventInstigator
//	local KFPlayerReplicationInfo PRI;
	
//	PRI = KFPlayerReplicationInfo(EventInstigator.PlayerReplicationInfo);


	if ( Pawn(Other) != None )
	{
	    // Send a string message to the toucher.
	    if( Message != "" )
		    Pawn(Other).ClientMessage( Message );

		if ( AIController(Pawn(Other).Controller) != None )
			UsedBy(Pawn(Other));
	}
}

defaultproperties
{
}
