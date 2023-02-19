# RavenM Ravenscript Documentation


OnlinePlayer
-------------
## Static members

| Member | Description                    |
| ------------- | ------------------------------ |
| `OwnGUID`      | Gets the GUID of the current actor       |

## Static methods

| Method | Description                    |
| ------------- | ------------------------------ |
| `SendPacketToServer(data,id, reliable)`      | Sends a packet to the server       |
| `PushChatMessage(message)`   | Send a chat message as the user    |
| `PushCommandChatMessage(message,color,teamOnly,sendToAll)`   | Send a command message   |




## Details

### `SendPacketToServer(string data,int id, bool reliable)`
Sends a packet to the server.

`data` The content that will be sent

`id` The packet id which can be used to differentiate between multiple packets

`reliable` When set to true makes sure that the packet will be sent [reliably](https://partner.steamgames.com/doc/api/ISteamNetworking#EP2PSend) 


#### Example
```lua
OnlinePlayer.SendPacketToServer(Player.actor.name .. ";;" .. self.killCounter,48,true)
```
> Note: The Event GameEventsOnline.onReceivePacket(id,data) can be used to check for received packets
> Note: The Event GameEventsOnline.onSendPacket(id,data) can be used to check for send packets



