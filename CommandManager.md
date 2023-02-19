# RavenM Ravenscript Documentation


CommandManager
-------------

## Static methods

| Method | Description                    |
| ------------- | ------------------------------ |
| `AddCustomCommand(commandName, arg1Type, global, hostOnly)`      | Add a custom command      |
| `AddCustomCommand(commandName, arg1Type, arg2Type, global, hostOnly)`   | Add a custom command   |
| `AddCustomCommand(commandName, arg1Type, arg2Type, arg3Type, global, hostOnly)`   | Add a custom command   |
| `GetActorByName(name)`   | Find an actor by name   |



## Details

### `AddCustomCommand(string commandName,string argType,bool global, bool hostOnly)`

`commandName` The name of the command that can be executed by doing /[commandName]

`argType` The argument type. This can be string, int, float or bool

`global` Determines if the command involves other clients. If set to false then the command is local only

`hostOnly` Determines if the command is host only
#### Example
```lua
-- In the Start Function
-- If the argType is null then it's a command without any arguments
CommandManager.AddCustomCommand("currentScore","null",false,false)

-- The command would be used like this: /tp Name1 Name2
CommandManager.AddCustomCommand("tp","string","string",true,true)

```
## Events

`GameEventsOnline.onReceiveCommand` can be used to check for received commands

```lua
function Script:onReceiveCommand(actor,message,flags)
  local hasPermission = flags[1]
  local hasRequiredArgs = flags[2]
  local isGlobal = flags[3] -- Is false when the command was sent to you
  ...
end
```
> Note: Like any other event you have to register it beforehand 
> ```GameEventsOnline.onReceiveCommand.AddListener(self,"onReceiveCommand")```



