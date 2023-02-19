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
| `SetNameTagForActor(actor,newTag)`   | Change the name tag of a player (client side only)   |
| `ResetNameTags()`   | Resets all of the name tags to the original (client side only)   |
| `GetPlayerFromName(name)`   | Return the actor of a player by name   |

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

## Events

`GameEventsOnline.onReceivePacket` invoked when a packet is received

`GameEventsOnline.onSendPacket` invoked when a packet is sent

```lua
function Script:onReceivePacket(id,data)
	print(id .. " -> " .. tostring(data))
end
function Script:onSendPacket(id,data)
	print(id .. " -> " .. tostring(data))
end

```
> Note: Like any other event you have to register it beforehand 
> ```GameEventsOnline.onReceivePacket.AddListener(self,"onReceivePacket")```



