class BDMessageGas extends LocalMessage;

const MaxMSGs=5;
var localized string KillString[MaxMSGs];
var name KillSound[MaxMSGs];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return default.KillString[Min(Switch,MaxMSGs-1)];
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if ( default.KillSound[Min(Switch,MaxMSGs-1)] != '' )
		P.PlayRewardAnnouncement(default.KillSound[Min(Switch,MaxMSGs-1)],1,true);
}

defaultproperties
{
     KillString(0)="Vehicle is full, you're wasting gas..."
     KillString(1)="Refueling..."
     KillString(2)="Out of petrol... buy fuel at the trader or find some"
     KillString(3)="You do not have enough cash to buy this vehicle!"
     KillString(4)="Overheated!"
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(B=0,G=0)
     PosY=0.242000
     FontSize=1
}
