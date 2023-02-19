# RavenM Ravenscript Documentation


Lobby
-------------
## Static members

| Member | Description                    |
| ------------- | ------------------------------ |
| `isHost`      |    |
| `isClient`      |    |
| `players`      |   Returns all of the current players |
## Static methods

| Method | Description                    |
| ------------- | ------------------------------ |
| `SendServerMessage(message,color)`      | Sends a message as the server      |
| `GetNetworkPrefabByHash(hash)`   | Gets a registered network prefab by hash (host only)   |
| `AddNetworkPrefab(gameObject)`   | Add a Game Object to the network prefabs list (host only)   |
| `PushNetworkPrefabs()`   | Send the network prefabs list to the clients (host only)   |
| `RemoveNetworkPrefab(gameObject)`   | Remove a Game Object from the network prefabs list (host only)   |

## Details
Instantiating a Game Object in RavenM works like it would normally, but the difference is that you have to register the prefab you want to spawn beforehand

`GameObjectM.Instantiate` is also used instead of `GameObject.Instantiate`

### `AddNetworkPrefab(GameObject gameObject)`


`gameObject` The game object to register


#### Example
```lua
function Script:Start()
  self.cube = self.targets.cube
  -- All spawnable prefabs have to be added here beforehand
  Lobby.AddNetworkPrefab(self.cube)
  Lobby.PushNetworkPrefabs() 
end
function Script:Update()
  if(Input.GetKeyDown(KeyCode.K)) then -- Example Code
    local gameObject = GameObjectM.Instantiate(self.cube,Player.actor.position,Quaternion.identity)
  end
end
```
## Events

`GameEventsOnline.onPlayerJoin` invoked when a player joins the game

`GameEventsOnline.onPlayerDisconnect` invoked when a player leaves the game

`GameEventsOnline.onReceiveChatMessage` invoked when a chat message was received

```lua
function Script:onPlayerJoin(actor)
	print(actor.name .. " joined the game")
end
function Script:onPlayerDisconnect(actor)
	print(actor.name .. " has left the server")
end
function Script:onReceiveChatMessage(actor,message)
  print(actor.name .. " : " .. tostring(message))
end

```
> Note: Like any other event you have to register it beforehand 
> ```GameEventsOnline.onPlayerJoin.AddListener(self,"onPlayerJoin")```





