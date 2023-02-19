-- Register the behaviour
behaviour("ArmsRaceScript")

function ArmsRaceScript:Start()
	self.allGear = {}
	self.allBigGear = {}
	self.allPrimary = {}
	self.allSecondary = {}
   	self.allWeapons = WeaponManager.allWeapons
   	for index,weaponentry in ipairs(self.allWeapons) do 
	   	if weaponentry.slot == WeaponSlot.Primary then
			   table.insert(self.allPrimary, weaponentry)
	   	end
	   	if weaponentry.slot == WeaponSlot.LargeGear then
			   table.insert(self.allBigGear, weaponentry)
	   	end
	   	if weaponentry.slot == WeaponSlot.Gear then
			   table.insert(self.allGear, weaponentry)
	   	end
	   	if weaponentry.slot == WeaponSlot.Secondary then
			   table.insert(self.allSecondary, weaponentry)
	   	end
   

   	end
	self.text = self.targets.text.GetComponent(Text)
	self.leaderBoardCanvas = self.targets.canvas.GetComponent(Canvas)
	self.leaderBoardCanvas.enabled = false
	self.initSpawn = false
	self.playerCounterTracker = {}
	self.counter = 1
	self.killCounter = 0
	self.amountOfKillsRequired = self.script.mutator.GetConfigurationInt("amountOfKillsRequired")
	self.maxRank = self.script.mutator.GetConfigurationInt("maxRank")
	if(self.maxRank < 0) then
		self.maxRank = 20
		Lobby.SendServerMessage("Max Rank can not be under 0",Color.red)
	end
	if(self.amountOfKillsRequired < 0) then
		self.amountOfKillsRequired = 1
		Lobby.SendServerMessage("Amount Of Kills Required can not be under 0",Color.red)
	end
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	GameEvents.onActorDied.AddListener(self,"onActorDied")
	self.version = self.script.mutator.GetConfigurationDropdown("version")
	print("Is Host " .. tostring(Lobby.isHost))
   	-- Multiplayer part
	PlayerHud.hudGameModeEnabled = false
   	GameEventsOnline.onReceivePacket.AddListener(self,"onReceivePacket")
	--GameEventsOnline.onSendPacket.AddListener(self,"onSendPacket")
	-- Update the text by sending packet with all of the states when a players kills another

end
function ArmsRaceScript:SendChatMessageAnnoucement(message)
	Lobby.SendServerMessage(message,Color.yellow)
end
function ArmsRaceScript:tableContains(table,value)
	for _,y in ipairs(table) do
		if(y == value) then
			return true
		end
	end
	return false
end
function ArmsRaceScript:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
function ArmsRaceScript:tableContains1(table,value)
	for _,y in ipairs(table) do
		if(y[1] == value) then
			return true
		end
	end
	return false
end
function ArmsRaceScript:splitString(inputstr, sep)
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end
function ArmsRaceScript:onSendPacket(id,data)
	print("ArmsRace -> onSendPacket " .. id .. " " .. data)
	-- self.text.text = "Data: " .. tostring(data) .. "\nPacket Type: " .. tostring(id)
end
function ArmsRaceScript:onActorDied(actor,source,isSilent) 
	if(self:tableContains(Lobby.players,actor) and source == Player.actor) then
		--print("Player " .. actor.name .. " died") -- Error?
		self.killCounter = self.killCounter + 1
		if((self.killCounter % self.amountOfKillsRequired) == 0) then
			if(Lobby.isHost) then
				self:onHostKill()
			else
				self:onClientKill()
			end	
		end
	end
end
function ArmsRaceScript:onActorSpawn(actor)
	-- Init
	if(self:tableContains(Lobby.players,actor)) then
		if(not self:tableContains1(self.playerCounterTracker, actor) and Lobby.isHost) then
			table.insert(self.playerCounterTracker, {actor,1})
			self.text.text = self.text.text .. actor.name .. " : 1" .. "\n"
			self:SendCurrentStatesTextPacket()
		end
	else
		-- Actor is bot
		actor.Deactivate()
		Lobby.SendServerMessage("Deactived bot " .. tostring(actor.name),Color.blue)

	end
	if(not self.initSpawn and actor == Player.actor) then
		self.script.StartCoroutine(self:ChangeToRandomWeapon())
		self:SendCurrentStatesTextPacket()
		self.initSpawn = true
	end
end
function ArmsRaceScript:findCounterForPlayer(table,playerName)
	for index, value in pairs(tab) do
        if value[1].name == playerName then
            return value[2]
        end
    end
end
function ArmsRaceScript:onReceivePacket(id,data)
	if(id == 48 and Lobby.isHost) then
		local dataSplit = self:splitString(data,";;")
		local player = dataSplit[1]
		local counter = dataSplit[2]
	
		print("Got new state -> " .. tostring(player) .. " counter " .. tostring(counter))
		self:UpdateStatesText(player,counter)
		return
	end
	if(id == 49 and not Lobby.isHost) then
		self.text.text = data
		-- This is not a good idea, the data should be 
		for i,y in ipairs(self:splitString(self.text.text, "\r\n")) do
			local playerdata = self:splitString(y, ":")
			local actor = OnlinePlayer.GetPlayerFromName(playerdata[1])
			if(actor ~= nil) then
				-- Set Nametags
				OnlinePlayer.SetNameTagForActor(actor,playerdata[1] .. " <color=yellow>[" .. tostring(playerdata[2]) .. "]</color>")
			end
		end
		print("Updated client text")
		return
	end
	if(id == 50) then
		if(data == Player.actor.name) then
			print("Received to get random weapon")
			self.script.StartCoroutine(self:ChangeToRandomWeapon())
		end
		return
	end

end
function ArmsRaceScript:UpdateStatesText(player,counter)
	self.text.text = ""
	for i,y in ipairs(self.playerCounterTracker) do
		local currentCounter = y[2]
		if(y[1].name == player) then
			print("Updated stat for " .. tostring(y[1].name) .. " from " .. tostring(currentCounter) .. " to " .. tostring(counter))
			y[2] = counter
		end
		local actor = OnlinePlayer.GetPlayerFromName(player)
		if(actor ~= nil) then
			-- Set Nametags
			OnlinePlayer.SetNameTagForActor(actor,player .. " <color=yellow>[" .. tostring(counter) .. "]</color>")
		end
		self.text.text = self.text.text .. y[1].name .. ":" .. tostring(y[2]) .. "\n"
	end
	self:SendRandomWeaponPacket(player)
	self:SendCurrentStatesTextPacket()
	if(tonumber(counter) >= self.maxRank) then
		Lobby.SendServerMessage("----Game End----",Color.yellow)
		Lobby.SendServerMessage("Player " .. player .. " has won the game!",Color.green)
		for i,y in ipairs(Lobby.players) do
			if(y.name ~= player) then
				y.KillSilently()
			end
		end
		Lobby.SendServerMessage("----------------",Color.yellow)
		return
	end
	if((counter % 10) == 0) then
		self:SendChatMessageAnnoucement("Player " .. player .. " is already at level " .. tostring(counter) .. "!")
	end
end
function ArmsRaceScript:ChangeToRandomWeapon()
	return function()
	coroutine.yield(WaitForSeconds(0.15))
	Player.actor.ResupplyAmmo()
	if(self.version == 0) then
		Player.actor.EquipNewWeaponEntry(self.allPrimary[Mathf.RoundToInt(Random.Range(1, self:tablelength(self.allPrimary)))], 0, true)
	end
	if(self.version == 1) then
		Player.actor.EquipNewWeaponEntry(self.allSecondary[Mathf.RoundToInt(Random.Range(1, self:tablelength(self.allSecondary)))], 1, true)
	end
	if(self.version == 2) then
		Player.actor.EquipNewWeaponEntry(self.allGear[Mathf.RoundToInt(Random.Range(1, self:tablelength(self.allGear)))], 2, true)
	end
	if(self.version == 3) then
		Player.actor.EquipNewWeaponEntry(self.allBigGear[Mathf.RoundToInt(Random.Range(1, self:tablelength(self.allBigGear)))], 3, true)
	end
	for i = 0,4,1 do
		if(self.version ~= i) then
			Player.actor.RemoveWeapon(i)
		end
	end
end
end
function ArmsRaceScript:SendCurrentCounterPacket()
	--												Data                      ID Reliable
	OnlinePlayer.SendPacketToServer(Player.actor.name .. ";;" .. self.counter,48,true)
end
function ArmsRaceScript:SendRandomWeaponPacket(actorName)
	if(not Lobby.isHost) then
		return
	end
	OnlinePlayer.SendPacketToServer(actorName,50,true)

end
function ArmsRaceScript:SendCurrentStatesTextPacket()
	if(Lobby.isHost) then
		--									Data       ID Reliable
		OnlinePlayer.SendPacketToServer(self.text.text,49,true)
	end
end
function ArmsRaceScript:onHostKill()
	self.counter = self.counter + 1
	print("onHostKill")
	-- The reason why we have to do this manually is because send packets from the server won't go through the onReceiveFunction
	self.script.StartCoroutine(self:ChangeToRandomWeapon())
	self:UpdateStatesText(Player.actor.name,self.counter)
end
function ArmsRaceScript:onClientKill()
	self.counter = self.counter + 1
	print("onClientKill")
	self:SendCurrentCounterPacket()
end
function ArmsRaceScript:Update()
	if(Input.GetKeyBindButton(KeyBinds.Scoreboard)) then
		self.leaderBoardCanvas.enabled = true
	else
		self.leaderBoardCanvas.enabled = false
	end
end
