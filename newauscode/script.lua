-- g_savedata table that persists between game sessions
g_savedata = {
	playerdata={},
	usercreations={}
}

-- perm numbers
PermNone = 0
PermAuth = 1
PermMod = 2
PermAdmin = 3
PermOwner = 4

-- admin list. formating: adminlist = {{"76561199240115313",PermOwner},{"76561199143631975",PermAdmin}}
adminlist = {}

-- tables
nosave = {playerdata={}} -- list that doesnt save
chatMessages = {}
hiddencommands = {{"?msg",true},{"?warn",true},{"?pi",true},{"?pc",true},{"?forcepvp",true},{"?forceas",true},{"?forcerepair",true}} -- list of commands to dont want to show to everyone in chat
-- settings
discordlink = "discord.gg/snJyn6V2Qs"
maxMessages = 250
playermaxvehicles = 1
unlockislands = true
playerdatasave = true
despawnonreload = false
customchat = true
subbodylimiting = true
maxsubbodys = 15
voxellimiting = true
voxellimit = 20000
limitingbypass = false
limitingbypassperm = PermOwner
warnactionthreashold = 3
warnaction = "kick" -- can be "kick" or "ban"
testingwarning = true -- used to tell players that the scripts are in development and their might be frequent script reloads
tipFrequency = 120  -- in seconds
debug_enabled = false
-- dont touch
tiptimer = 0
uitimer = 0
tipstep = 1
TIME = server.getTimeMillisec()
TICKS = 0
TPS = 0
scriptversion = "v1.6.1-Testing"



-- Player Managment
-- initalising the player
function playerint(steam_id, peer_id)
	local pn = server.getPlayerName(peer_id)
	pn = friendlystring(pn)
	if playerdatasave then
		if g_savedata["playerdata"][tostring(steam_id)] == nil then
			g_savedata["playerdata"][tostring(steam_id)] = {steam_id=tostring(steam_id), peer_id=tostring(peer_id), name=tostring(pn), as=true, pvp=false, ui=true, warns=0}
			for _, sid in pairs(adminlist) do
				if tostring(sid[1]) == tostring(steam_id) then
					g_savedata["playerdata"][tostring(steam_id)]["perms"] = sid[2]
				end
			end
			if g_savedata["playerdata"][tostring(steam_id)]["perms"] == nil then
				g_savedata["playerdata"][tostring(steam_id)]["perms"] = PermNone
			end
		elseif g_savedata["playerdata"][tostring(steam_id)] ~= nil then
			g_savedata["playerdata"][tostring(steam_id)]["peer_id"] = peer_id
			g_savedata["playerdata"][tostring(steam_id)]["name"] = pn
			if g_savedata["playerdata"][tostring(steam_id)]["as"] == nil then
				g_savedata["playerdata"][tostring(steam_id)]["as"] = true
			else
				g_savedata["playerdata"][tostring(steam_id)]["as"] = g_savedata["playerdata"][tostring(steam_id)]["as"]
			end
			if g_savedata["playerdata"][tostring(steam_id)]["pvp"] == nil then
				g_savedata["playerdata"][tostring(steam_id)]["pvp"] = false
			else
				g_savedata["playerdata"][tostring(steam_id)]["pvp"] = g_savedata["playerdata"][tostring(steam_id)]["pvp"]
			end
			if g_savedata["playerdata"][tostring(steam_id)]["ui"] == nil then
				g_savedata["playerdata"][tostring(steam_id)]["ui"] = true
			else
				g_savedata["playerdata"][tostring(steam_id)]["ui"] = g_savedata["playerdata"][tostring(steam_id)]["ui"]
			end
			if g_savedata["playerdata"][tostring(steam_id)]["warns"] == nil then
				g_savedata["playerdata"][tostring(steam_id)]["warns"] = "0"
			else
				g_savedata["playerdata"][tostring(steam_id)]["warns"] = tostring(g_savedata["playerdata"][tostring(steam_id)]["warns"])
			end
			for _, sid in pairs(adminlist) do
				if tostring(sid[1]) == tostring(steam_id) then
					g_savedata["playerdata"][tostring(steam_id)]["perms"] = sid[2]
				end
			end
			if g_savedata["playerdata"][tostring(steam_id)]["perms"] == nil then
				g_savedata["playerdata"][tostring(steam_id)]["perms"] = PermNone
			end
		end
	end
	if playerdatasave == false then
		nosave["playerdata"][tostring(steam_id)] = {steam_id=tostring(steam_id), peer_id=peer_id, name=tostring(pn), as=true, pvp=false, ui=true, warns=0}
		for _, sid in pairs(adminlist) do
			if tostring(sid[1]) == tostring(steam_id) then
				nosave["playerdata"][tostring(steam_id)]["perms"] = sid[2]
			end
		end
		if nosave["playerdata"][tostring(steam_id)]["perms"] == nil then
			nosave["playerdata"][tostring(steam_id)]["perms"] = PermNone
		end
	end
end

-- function to get playerdata
function getPlayerdata(get, idtoggle, id)
    local playerdata = nil

    if playerdatasave then
        if idtoggle then
            local sid = getsteam_id(id)
            if sid == nil then
                return nil
            end
            playerdata = g_savedata["playerdata"][tostring(sid)]
        else
            playerdata = g_savedata["playerdata"][tostring(id)]
        end
    else
        if idtoggle then
            local sid = getsteam_id(id)
            if sid == nil then
                return nil
            end
            playerdata = nosave["playerdata"][tostring(sid)]
        else
            playerdata = nosave["playerdata"][tostring(id)]
        end
    end

    if playerdata == nil then
        return nil
    end

    if get ~= nil then
        return playerdata[get]
    else
        return playerdata
    end
end

-- function to set playerdata
function setPlayerdata(set, idtoggle, id, value) -- if idtoggle true it will try to use peer_id
	if playerdatasave then
		if idtoggle then
			local sid = getsteam_id(id)
			if set ~= nil then
				g_savedata["playerdata"][tostring(sid)][set] = value
			end
		else
			if set ~= nil then
				g_savedata["playerdata"][tostring(id)][set] = value
			end
		end
	elseif not playerdatasave then
		if idtoggle then
			local sid = getsteam_id(id)
			if set ~= nil then
				nosave["playerdata"][tostring(sid)][set] = value
			end
		else
			if set ~= nil then
				nosave["playerdata"][tostring(id)][set] = value
			end
		end
	end
end

-- player joined
function onPlayerJoin(steam_id, name, peer_id, admin, auth)
	server.announce("[Server]", peer_id.." | "..name.." joined the game")
	table.insert(chatMessages, {full_message=peer_id.." | "..name.." joined the game",name="[Server]"})
	server.setPopupScreen(peer_id, 1, "auth", true, "You are not authed. type ?auth in chat to get authed", 0, 0)
	if testingwarning then
		server.announce("[AusCode]", "Script is being worked on and there will be many script reloads", peer_id)
		table.insert(chatMessages, {full_message="Script is being worked on and there will be many script reloads",name="[AusCode]",topid=peer_id})
	end
	server.removeAuth(peer_id)
	sendChat = true
	playerint(steam_id, peer_id)
	if getPlayerdata("ui", true, peer_id) == true then
		setPlayerdata("ui", true, peer_id, false)
		setPlayerdata("ui", true, peer_id, true)
	end
end

-- player leave
function onPlayerLeave(steam_id, name, peer_id, admin, auth)
	server.announce("[Server]", peer_id.." | "..name.." left the game")
	table.insert(chatMessages, {full_message=peer_id.." | "..name.." left the game",name="[Server]"})
	local ownersteamid = getsteam_id(peer_id)
	local vehiclespawned = false
	for group_id, GroupData in pairs(g_savedata["usercreations"]) do
		if GroupData["ownersteamid"] == ownersteamid then
			vehiclespawned = true
			server.despawnVehicleGroup(tonumber(group_id), true)
		end
	end
end

-- geting the steam id off a peer id
function getsteam_id(peer_id)
	if playerdatasave then
		for _, playerdata in pairs(g_savedata["playerdata"]) do
			if tostring(playerdata["peer_id"]) == tostring(peer_id) then
				return playerdata["steam_id"]
			end
		end
	else
		for _, playerdata in pairs(nosave["playerdata"]) do
			if tostring(playerdata["peer_id"]) == tostring(peer_id) then
				return playerdata["steam_id"]
			end
		end
	end
end

-- geting the peer id off a steam id
function getpeer_id(steam_id)
	if playerdatasave then
		for _, playerdata in pairs(g_savedata["playerdata"]) do
			if tostring(playerdata["steam_id"]) == tostring(steam_id) then
				return playerdata["peer_id"]
			end
		end
	else
		for _, playerdata in pairs(nosave["playerdata"]) do
			if tostring(playerdata["steam_id"]) == tostring(steam_id) then
				return playerdata["peer_id"]
			end
		end
	end
end

-- custom chat function
if customchat then	
	function logChatMessage(name, full_message)
		table.insert(chatMessages, {full_message=full_message,name=name,topid=nil})
		for _, chat in pairs(chatMessages) do
			if countitems(chatMessages) > maxMessages then
				table.remove(chatMessages, 1)
			end
		end
	end
	function printChatMessages()
		for _, chat in ipairs(chatMessages) do
			if chat.topid == nil then
				server.announce(chat.name, chat.full_message)
			else
				server.announce(chat.name, chat.full_message, chat.topid)
			end
		end
	end
	function onChatMessage(peer_id, sender_name, message)
		local perms = getPlayerdata("perms", true, peer_id)
		local name = ""
		if perms == PermOwner then
			name = "[Owner] "..sender_name
		elseif perms == PermAdmin then
			name = "[Admin] "..sender_name
		elseif perms == PermMod then
			name = "[Mod] "..sender_name
		elseif perms == PermAuth then
			name = "[Player] "..sender_name
		elseif perms == PermNone then
			name = "[Player] "..sender_name
		end
		logChatMessage(name, message)
		sendChat = true
		if debug_enabled then
			server.announce("[Debug]", tostring(sendChat))
			table.insert(chatMessages, {full_message=tostring(sendChat),name="[Debug]"})
		end
	end
end
--endregion


-- Vehicle Managment
-- vehicle spawned
function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
	if peer_id ~= -1 then
		local pvp = ""
		if getPlayerdata("as", true, peer_id) == true then
			server.setVehicleEditable(vehicle_id, false)
		elseif getPlayerdata("as", true, peer_id) == false then
			server.setVehicleEditable(vehicle_id, true)
		end
		if getPlayerdata("pvp", true, peer_id) == true then
			server.setVehicleInvulnerable(vehicle_id, false)
			pvp = "true"
		elseif getPlayerdata("pvp", true, peer_id) == false then
			server.setVehicleInvulnerable(vehicle_id, true)
			pvp = "false"
		end
		local name = server.getPlayerName(peer_id)
		server.setVehicleTooltip(vehicle_id, "Owner: "..peer_id.." | "..name.."\nPVP: "..pvp.." | Group ID: "..group_id)
		if peer_id ~= -1 and peer_id ~= nil then
			if g_savedata["usercreations"][tostring(group_id)] == nil then
				g_savedata["usercreations"][tostring(group_id)] = {OwnerID=peer_id, ownersteamid=getsteam_id(peer_id), Vehicleparts={}, cost=group_cost}
			end
			g_savedata["usercreations"][tostring(group_id)]["Vehicleparts"][tostring(vehicle_id)] = 1
			local ownersteamid = getsteam_id(peer_id)
			local vehiclespawned = 0
			local despawned = false
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if GroupData["ownersteamid"] == ownersteamid then
					vehiclespawned = vehiclespawned + 1
					if vehiclespawned > playermaxvehicles then
						despawned = true
						server.despawnVehicleGroup(tonumber(group_id), true)
						server.notify(peer_id, "[Server]", "You can only have "..playermaxvehicles.." vehicle spawned at a time", 6)
					end
				end
			end

		end
	end
end

-- on vehicle spawn 
function onGroupSpawn(group_id, peer_id, x, y, z, group_cost)
	if peer_id > 0 then
		loop(1.5,
		function(id)
			local groupdata, is_success = server.getVehicleGroup(group_id)
			if is_success then
				local despawned = checklimmiting(group_id, peer_id)
				if not despawned then
					if g_savedata["usercreations"][tostring(group_id)] ~= nil then
						local name = server.getPlayerName(peer_id)
						server.announce("[Server]", peer_id.." | "..name.." spawned vehicle group: "..group_id.." Cost: $"..string.format("%.0f",group_cost))
						table.insert(chatMessages, {full_message=peer_id.." | "..name.." spawned vehicle group: "..group_id.." Cost: $"..string.format("%.0f",group_cost),name="[Server]"})
						removeLoop(id)
					end
				end
			end
		end
		)
	end
end

-- check limiting
function checklimmiting(group_id, peer_id)
	local bypassperms = 0
	if limitingbypass then
		bypassperms = getPlayerdata("perms", true, peer_id)
	end
	if bypassperms < limitingbypassperm then
		if voxellimiting then
			local name = getPlayerdata("name", true, peer_id)
			local voxel_count = calculateVoxels(group_id)
			if voxel_count > voxellimit then
				server.despawnVehicleGroup(tonumber(group_id), true)
				server.announce("[Server]", peer_id.." | "..name.."'s vehicle group: "..group_id.." has been despawned for exceeded block limit "..voxel_count.."/"..voxellimit)
				table.insert(chatMessages, {full_message=peer_id.." | "..name.."'s vehicle group: "..group_id.." has been despawned for exceeded block limit "..voxel_count.."/"..voxellimit,name="[Server]"})
				return true
			end
			if debug_enabled then
				server.announce("[AusCode]", voxel_count)
				table.insert(chatMessages, {full_message=tostring(voxel_count),name="[AusCode]"})
			end
		end	
		if subbodylimiting then
			local subbodys = server.getVehicleGroup(group_id)
			if #subbodys > maxsubbodys then
				if debug_enabled then
					server.announce("[Server]", #subbodys)
					table.insert(chatMessages, {full_message=#subbodys,name="[Server]"})
				end
				name = server.getPlayerName(peer_id)
				server.announce("[Server]", peer_id.." | "..name.."'s vehicle group: "..group_id.." has been despawned for exceeded subbody limit "..#subbodys.."/"..maxsubbodys)
				table.insert(chatMessages, {full_message=peer_id.." | "..name.."'s vehicle group: "..group_id.." has been despawned for exceeded subbody limit "..#subbodys.."/"..maxsubbodys,name="[Server]"})
				server.despawnVehicleGroup(tonumber(group_id), true)
				return true
			end
		end
	end
end

-- calculate voxels
function calculateVoxels(group_id)
	local voxel_count = 0
	local group = tostring(group_id)
	for group_id, GroupData in pairs(g_savedata["usercreations"]) do
		if group_id == group then
			for vehicle_id, _ in pairs(GroupData["Vehicleparts"]) do
				local vehicle_components, is_success = server.getVehicleComponents(vehicle_id)
				if is_success then
					voxel_count = vehicle_components["voxels"] + voxel_count
				end
			end
		end
	end
	return voxel_count
end

-- vehicle despawned
function onVehicleDespawn(vehicle_id, peer_id)
	local groupid = -1
	for group_id, GroupData in pairs(g_savedata["usercreations"]) do
		if GroupData["Vehicleparts"][tostring(vehicle_id)] ~= nil then
			groupid = group_id
			break
		end
	end
	if groupid ~= -1 then
		g_savedata["usercreations"][tostring(groupid)]["Vehicleparts"][tostring(vehicle_id)] = nil
		if countitems(g_savedata["usercreations"][tostring(groupid)]["Vehicleparts"]) == 0 then
			onGroupDespawn(groupid, g_savedata["usercreations"][tostring(groupid)]["OwnerID"])
		end
	end
end

-- remove vehcile off list
function onGroupDespawn(group_id, peer_id)
	local m = server.getCurrency()
	local nm = m + g_savedata["usercreations"][tostring(group_id)]["cost"]
	server.setCurrency(nm)
	g_savedata["usercreations"][tostring(group_id)] = nil
end

-- count stuffs
function countitems(list)
	local number = 0
	for _, item in pairs(list) do
		if item ~= nil then
			number = number + 1
		end
	end
	return number
end
--endregion

-- Misc
-- Function to format runtime in days, hours, minutes, and seconds
function formatUptime(uptimeTicks, tickDuration)
	uptimeTicks = server.getTimeMillisec()
	tickDuration = 1000
	local totalSeconds = math.floor(uptimeTicks / tickDuration)
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local seconds = totalSeconds % 60
	return string.format("%02dh %02dm %02ds", hours, minutes, seconds)
end

-- removes characters that brake things
function friendlystring(String)
	return string.gsub(String, "[<]", "")
end
--endregion

-- Commands
function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four, five)
	local perms = getPlayerdata("perms", true, user_peer_id)
	local commandfound = false
	sendChat = true
	
	-- shows command players run
	local playername = server.getPlayerName(user_peer_id)
	local name = ""
	if perms == PermOwner then
		name = "[Owner] "..playername
	elseif perms == PermAdmin then
		name = "[Admin] "..playername
	elseif perms == PermMod then
		name = "[Mod] "..playername
	elseif perms == PermAuth then
		name = "[Player] "..playername
	elseif perms == PermNone then
		name = "[Player] "..playername
	end
	if not customchat then
		name = playername
	end
	
	local hidecommand = false
	for c, commanddata in pairs(hiddencommands) do
		if command:lower() == commanddata[1] then
			if commanddata[2] then
				hidecommand = true
			end
		end
	end
	if not hidecommand then
		server.announce(name, "> "..full_message)
		table.insert(chatMessages, {full_message="> "..full_message,name=name})
	end


-- Player
	-- player info
	if (command:lower() == "?pi") then
		commandfound = true
		if one ~= nil then
			local sid = "Unknown"
			local name = "Unknown"
			local pvp = "Unknown"
			local was = "Unknown"
			local wui = "Unknown"
			if perms >= PermAdmin then
				local playerdata = getPlayerdata(nil, true, one)
				sid = playerdata["steam_id"]    
				name = playerdata["name"]
				local warns = playerdata["warns"]
				if playerdata["as"] ~= nil then
					was = tostring(playerdata["as"])
				end
				if playerdata["pvp"] ~= nil then
					pvp = tostring(playerdata["pvp"])
				end
				if playerdata["ui"] ~= nil then
					wui = tostring(playerdata["ui"])
				end
				server.announce("[Server]", "Peer id: "..tostring(one).."\nName: "..name.."\nSteam id: "..tostring(sid).."\nAntisteal: "..was.."\nPVP: "..pvp.."\nUI: "..wui.."\nWarns: "..warns, user_peer_id)
				table.insert(chatMessages, {full_message="Peer id: "..tostring(one).."\nName: "..name.."\nSteam id: "..tostring(sid).."\nAntisteal: "..was.."\nPVP: "..pvp.."\nUI: "..wui.."\nWarns: "..warns,name="[Server]",topid=user_peer_id})
			end
		else
			local pid = ""
			local sid = ""
			local name = ""
			if perms >= PermAdmin then
				if playerdatasave then
					for sid, playedata in pairs(g_savedata["playerdata"]) do
						pid = getpeer_id(sid)
						name = playedata["name"]
						server.announce("[Server]", "Peer id: "..tostring(pid).."\nName: "..tostring(name).."\nSteam id: "..tostring(sid), user_peer_id)
						table.insert(chatMessages, {full_message="Peer id: "..tostring(pid).."\nName: "..tostring(name).."\nSteam id: "..tostring(sid),name="[Server]",topid=user_peer_id})
					end
				else
					for sid, playedata in pairs(nosave["playerdata"]) do
						pid = getpeer_id(sid)
						name = playedata["name"]
						server.announce("[Server]", "Peer id: "..pid.."\nName: "..tostring(name).."\nSteam id: "..tostring(sid), user_peer_id)
						table.insert(chatMessages, {full_message="Peer id: "..pid.."\nName: "..tostring(name).."\nSteam id: "..tostring(sid),name="[Server]",topid=user_peer_id})
					end
				end
			end
		end
	end
	
	-- teleport player to player
	if (command:lower() == "?tpp") then
		commandfound = true
		if perms >= PermMod then
			if two == nil then
				local m1 = server.getPlayerPos(one)
				server.setPlayerPos(user_peer_id, m1)
			elseif two ~= nil then
				local m1 = server.getPlayerPos(two)
				server.setPlayerPos(one, m1)
			end
		end
	end
	
	-- teleport player to vehicle
	if (command:lower() == "?tpv") then
		commandfound = true
		local worked = false
		if one ~= nil then
			local parts = server.getVehicleGroup(one)
			local vmatrix = server.getVehiclePos(parts[1], 0, 0, 0)
			local x,y,z = matrix.position(vmatrix)
			server.setPlayerPos(user_peer_id, matrix.translation(x,y+10,z))
			worked = true
		elseif one == nil then
			server.notify(user_peer_id, "[Server]", "You have to input the vehicles group id of the vehcile you want to go to", 6)
		end
		if worked == true then
			server.notify(user_peer_id, "[Server]", "You have been teleported to vehicle group: "..one, 5)
		end
	end

	-- auth command
	if (command:lower() == "?auth") then
		commandfound = true
		if not is_auth then
			server.addAuth(user_peer_id)
			server.notify(user_peer_id, "[Server]", "You have been authed", 5)
			server.removePopup(user_peer_id, 1)
		else
			server.notify(user_peer_id, "[Server]", "You are already authed", 6)
			server.removePopup(user_peer_id, 1)
		end
	end

	if (command:lower() == "?warn") then
		commandfound = true
		if perms >= PermMod then
			server.removeAuth(one)
			local reason = full_message:gsub("^%?warn%s*", ""):gsub("^%?", ""):gsub(one, "") -- removes ?warn and varible one from full_message
			server.notify(one, "[Warn]", "You have been warned".."\nReason: "..reason, 6)
			local ownersteamid = getsteam_id(one)
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if GroupData["ownersteamid"] == ownersteamid then
					server.despawnVehicleGroup(tonumber(group_id), true)
				end
			end
			local warns = tonumber(getPlayerdata("warns", true, one)) + 1
			if warns >= warnactionthreashold then
				setPlayerdata("warns", true, one, tostring(0))
				if warnaction == "kick" then
					local name = getPlayerdata("name", true, one)
					server.announce("[Server]", one.." | "..name.." has been kick for reaching the warning threashold")
					table.insert(chatMessages, {full_message=one.." | "..name.." has been kick for reaching the warning threashold",name="[Server]"})
					server.kick(one)
				elseif warnaction == "ban" then
					local name = getPlayerdata("name", true, one)
					server.announce("[Server]", one.." | "..name.." has been banned for reaching the warning threashold")
					table.insert(chatMessages, {full_message=one.." | "..name.." has been banned for reaching the warning threashold",name="[Server]"})
					server.ban(one)
				end
			elseif warns < warnactionthreashold then
				setPlayerdata("warns", true, one, tostring(warns))
			end
		end
	end
--endregion


-- Vehicles
	-- clear vehicle command
	if (command:lower() == "?c") or (command:lower() == "?clear") then
		commandfound = true
		local ownersteamid = getsteam_id(user_peer_id)
		local vehiclespawned = false
		for group_id, GroupData in pairs(g_savedata["usercreations"]) do
			if GroupData["ownersteamid"] == ownersteamid then
				vehiclespawned = true
				server.despawnVehicleGroup(tonumber(group_id), true)
				server.notify(user_peer_id, "[Server]", "Your vehicle/s have been despawned", 5)
			end
		end
		if vehiclespawned == false then
			server.notify(user_peer_id, "[Server]", "You do not have any vehicle/s spawned", 6)
		end
	end
	
	-- clear spesific players vehicle
	if (command:lower() == "?pc") or (command:lower() == "?playerclear") then
		commandfound = true
		if perms >= PermAdmin then    
			local ownersteamid = getsteam_id(one)
			local vehiclespawned = false
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if GroupData["ownersteamid"] == ownersteamid then
					vehiclespawned = true
					server.despawnVehicleGroup(tonumber(group_id), true)
					server.notify(user_peer_id, "[Server]", "Specified player's vehicle/s have been despawned", 5)
				end
			end
			if vehiclespawned == false then
				server.notify(user_peer_id, "[Server]", "Specified player dosn't have any vehicle/s to despawned", 6)
			end
		end
	end

	-- clear all vehicles
	if (command:lower() == "?ca") or (command:lower() == "?clearall") then
		commandfound = true
		if perms >= PermAdmin then
			local vehiclespawned = false
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do 
				vehiclespawned = true
				server.despawnVehicleGroup(tonumber(group_id), true)
			end
			if vehiclespawned == true then
				server.notify(user_peer_id, "[Server]", "All vehicles have been despawned", 5)
			end
			if vehiclespawned == false then
				server.notify(user_peer_id, "[Server]", "There are no vehicles to despawn", 6)
			end
		end
	end

	-- pvp command
	if (command:lower() == "?pvp") then
		commandfound = true
		local peer_id = user_peer_id
		local worked = false
		local pvp
		local name = server.getPlayerName(peer_id)
		if getPlayerdata("pvp", true, peer_id) == true then
			setPlayerdata("pvp", true, peer_id, false)
			server.notify(user_peer_id, "[Server]", "PVP disabled", 6)
			server.announce("[Server]", peer_id.." | "..name.." Has disabled there pvp")
			table.insert(chatMessages, {full_message=peer_id.." | "..name.." has disabled their pvp",name="[Server]"})
			worked = true
			pvp = "false"
		elseif getPlayerdata("pvp", true, peer_id) == false then
			setPlayerdata("pvp", true, peer_id, true)
			server.notify(user_peer_id, "[Server]", "PVP enabled", 5)
			server.announce("[Server]", peer_id.." | "..name.." Has enabled there pvp")
			table.insert(chatMessages, {full_message=peer_id.." | "..name.." has enabled their pvp",name="[Server]"})
			worked = true
			pvp = "true"
		end
		if worked ~= true then
			setPlayerdata("pvp", true, peer_id, true)
			server.notify(user_peer_id, "[Server]", "PVP enabled", 5)
			server.announce("[Server]", peer_id.." | "..name.." Has enabled there pvp")
			table.insert(chatMessages, {full_message=peer_id.." | "..name.." has enabled their pvp",name="[Server]"})
		end
		local ownersteamid = getsteam_id(user_peer_id)
		local vehicle_id = nil
		local name = server.getPlayerName(peer_id)
		for group_id, GroupData in pairs(g_savedata["usercreations"]) do
			if GroupData["ownersteamid"] == ownersteamid then
				for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
					server.setVehicleTooltip(vehicle_id, "Owner: "..peer_id.." | "..name.."\nPVP: "..pvp.." | Group ID: "..group_id)
					if getPlayerdata("pvp", true, peer_id) == true then
						server.setVehicleInvulnerable(vehicle_id, false)
					elseif getPlayerdata("pvp", true, peer_id) == false then
						server.setVehicleInvulnerable(vehicle_id, true)
					end
				end
			end
		end
	end

	-- force pvp
	if (command:lower() == "?forcepvp") then
		commandfound = true
		if perms >= PermAdmin then
			local pvp
			local name = server.getPlayerName(one)
			if two == nil then
				if getPlayerdata("pvp", true, one) == true then
					setPlayerdata("pvp", true, one, false)
					server.notify(one, "[Server]", "PVP disabled", 6)
					server.announce("[Server]", one.." | "..name.." has disabled there pvp")
					table.insert(chatMessages, {full_message=one.." | "..name.." has disabled their pvp",name="[Server]"})
					pvp = "false"
				elseif getPlayerdata("pvp", true, one) == false then
					setPlayerdata("pvp", true, one, true)
					server.notify(one, "[Server]", "PVP enabled", 5)
					server.announce("[Server]", one.." | "..name.." has enabled there pvp")
					table.insert(chatMessages, {full_message=one.." | "..name.." has enabled their pvp",name="[Server]"})
					pvp = "true"
				end
			else
				if two:lower() == "true" then
					setPlayerdata("pvp", true, one, true)
					server.notify(one, "[Server]", "PVP enabled", 5)
					server.announce("[Server]", one.." | "..name.." has enabled there pvp")
					table.insert(chatMessages, {full_message=one.." | "..name.." has enabled their pvp",name="[Server]"})
					pvp = "true"
				elseif two:lower() == "false" then
					setPlayerdata("pvp", true, one, false)
					server.notify(one, "[Server]", "PVP disabled", 6)
					server.announce("[Server]", one.." | "..name.." has disabled there pvp")
					table.insert(chatMessages, {full_message=one.." | "..name.." has disabled their pvp",name="[Server]"})
					pvp = "false"
				end
			end
			local ownersteamid = getsteam_id(one)
			local vehicle_id = nil
			local name = server.getPlayerName(one)
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if GroupData["ownersteamid"] == ownersteamid then
					for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
						server.setVehicleTooltip(vehicle_id, "Owner: "..one.." | "..name.."\nPVP: "..pvp.." | Group ID: "..group_id)
						if getPlayerdata("pvp", true, one) == true then
							server.setVehicleInvulnerable(vehicle_id, false)
						elseif getPlayerdata("pvp", true, one) == false then
							server.setVehicleInvulnerable(vehicle_id, true)
						end
					end
				end
			end
		end
	end

	-- repair vehicles
	if (command:lower() == "?repair") then
		commandfound = true
		local ownersteamid = getsteam_id(user_peer_id)
		local vehicle_id = nil
		local worked = false
		for group_id, GroupData in pairs(g_savedata["usercreations"]) do
			if GroupData["ownersteamid"] == ownersteamid then
				for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
					server.resetVehicleState(vehicle_id)
					worked = true
				end
			end
		end
		if worked == true then
			local name = server.getPlayerName(user_peer_id)
			server.notify(user_peer_id, "[Server]", "Your vehicle/s has been repaired and restocked", 5)
			server.announce("[Server]", user_peer_id.." | "..name.." has repaired and restocked their vehicle/s")
			table.insert(chatMessages, {full_message=user_peer_id.." | "..name.." has repaired and restocked their vehicle/s",name="[Server]"})
		else
			server.notify(user_peer_id, "[Server]", "You have no vehicle/s to be repaired and restocked", 6)
		end
	end

	-- forces inputed peer ids vehicles to be repaired
	if (command:lower() == "?forcerepair") then
		commandfound = true
		if perms >= PermAdmin then
			if one ~= nil then
				local ownersteamid = getsteam_id(one)
				local vehicle_id = nil
				local worked = false
				for group_id, GroupData in pairs(g_savedata["usercreations"]) do
					if GroupData["ownersteamid"] == ownersteamid then
						for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
							server.resetVehicleState(vehicle_id)
							worked = true
						end
					end
				end
				if worked == true then
					local name = server.getPlayerName(one)
					server.notify(one, "[Server]", "Your vehicle/s has been repaired and restocked", 5)
					server.announce("[Server]", one.." | "..name.." has repaired and restocked their vehicle/s")
					table.insert(chatMessages, {full_message=one.." | "..name.." has repaired and restocked their vehicle/s",name="[Server]"})
				else
					server.notify(one, "[Server]", "You have no vehicle/s to be repaired and restocked", 6)
				end
			end
		end
	end

	-- flip vehicles command
	if (command:lower() == "?flip") then
		commandfound = true
		local ownersteamid = getsteam_id(user_peer_id)
		local worked = false
		for group_id, GroupData in pairs(g_savedata["usercreations"]) do
			if GroupData["ownersteamid"] == ownersteamid then
				for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
					worked = true
					VehicleMatrix = server.getVehiclePos(tonumber(vehicle_id))
					x,y,z = matrix.position(VehicleMatrix)
					server.setVehiclePos(tonumber(vehicle_id), matrix.translation(x,y+1,z))
					server.notify(user_peer_id, "[Server]", "Unflipped vehicle/s", 5)
				end
			end
		end
		if not worked then
			server.notify(user_peer_id, "[Server]", "No vehicle/s to unflipped", 6)
		end
	end

	if (command:lower() == "?forceflip") then
		commandfound = true
		if perms >= PermMod then
			local ownersteamid = getsteam_id(one)
			local worked = false
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if GroupData["ownersteamid"] == ownersteamid then
					for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
						worked = true
						VehicleMatrix = server.getVehiclePos(tonumber(vehicle_id))
						x,y,z = matrix.position(VehicleMatrix)
						server.setVehiclePos(tonumber(vehicle_id), matrix.translation(x,y+1,z))
						server.notify(user_peer_id, "[Server]", "Unflipped vehicle/s", 5)
						server.notify(one, "[Server]", "Unflipped vehicle/s", 5)
					end
				end
			end
			if not worked then
				server.notify(user_peer_id, "[Server]", "No vehicle/s to unflipped", 6)
			end
		end
	end

	-- anti steal command
	if (command:lower() == "?as") or (command:lower() == "?antisteal") then
		commandfound = true
		local worked = false
		if getPlayerdata("as", true, user_peer_id) == true then
			setPlayerdata("as", true, user_peer_id, false)
			server.notify(user_peer_id, "[Server]", "Anti-steal disabled", 6)
			worked = true
		elseif getPlayerdata("as", true, user_peer_id) == false then
			setPlayerdata("as", true, user_peer_id, true)
			server.notify(user_peer_id, "[Server]", "Anti-steal enabled", 5)
			worked = true
		end
		if worked ~= true then
			setPlayerdata("as", true, user_peer_id, true)
			server.notify(user_peer_id, "[Server]", "Anti-steal enabled", 5)
		end
		local ownersteamid = getsteam_id(user_peer_id)
		local vehicle_id = nil
		for group_id, GroupData in pairs(g_savedata["usercreations"]) do
			if GroupData["ownersteamid"] == ownersteamid then
				for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
					if getPlayerdata("as", true, user_peer_id) == true then
						server.setVehicleEditable(vehicle_id,false)
					elseif getPlayerdata("as", true, user_peer_id) == false then
						server.setVehicleEditable(vehicle_id, true)
					end
				end
			end
		end
	end

	-- force antisteal
	if (command:lower() == "?forceas") or (command:lower() == "?forceantisteal")then
		commandfound = true
		if perms >= PermAdmin then
			if two == nil then
				if getPlayerdata("as", true, one) == true then
					setPlayerdata("as", true, one, false)
					server.notify(one, "[Server]", "Anti-steal disabled", 6)
					worked = true
				elseif getPlayerdata("as", true, one) == false then
					setPlayerdata("as", true, one, true)
					server.notify(one, "[Server]", "Anti-steal enabled", 5)
					worked = true
				end
				if worked ~= true then
					setPlayerdata("as", true, one, true)
					server.notify(one, "[Server]", "Anti-steal enabled", 5)
				end
			else
				if two:lower() == "true" then
					setPlayerdata("as", true, one, true)
					server.notify(one, "[Server]", "Anti-steal enabled", 5)
				elseif two:lower() == "false" then
					setPlayerdata("as", true, one, false)
					server.notify(one, "[Server]", "Anti-steal disabled", 6)
				end
			end
			local ownersteamid = getsteam_id(one)
			local vehicle_id = nil
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if GroupData["ownersteamid"] == ownersteamid then
					for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
						if getPlayerdata("as", true, one) == true then
							server.setVehicleEditable(vehicle_id,false)
						elseif getPlayerdata("as", true, one) == false then
							server.setVehicleEditable(vehicle_id, true)
						end
					end
				end
			end
		end
	end
--endregion

	
-- Misc
	-- lists players with pvp on
	if (command:lower() == "?pvplist") then
		commandfound = true
		server.announce("[Server]", "-=Players with pvp on=-", user_peer_id)
		table.insert(chatMessages, {full_message="-=Players with pvp on=-",name="[Server]",topid=user_peer_id})
		local pid = ""
		local name = ""
		for _, playerdata in pairs(server.getPlayers()) do
			if playerdatasave then
				if getPlayerdata("pvp", true, playerdata["id"]) then
					local name = getPlayerdata("name", true, playerdata["id"])
					pid = playerdata["id"]
					server.announce("[Server]", pid.." | "..name, user_peer_id)
					table.insert(chatMessages, {full_message=pid.." | "..name,name="[Server]",topid=user_peer_id})
				end
			end
		end
	end

	-- ui command
	if (command:lower() == "?ui") then
		commandfound = true
		if getPlayerdata("ui", true, user_peer_id) then
			setPlayerdata("ui", true, user_peer_id, false)
			server.notify(user_peer_id, "[Server]", "UI disabled", 6)
			server.removePopup(user_peer_id, 0)
		elseif not getPlayerdata("ui", true, user_peer_id) then
			setPlayerdata("ui", true, user_peer_id, true)
			server.notify(user_peer_id, "[Server]", "UI enabled", 5)
		end
	end

	-- uptime command
	if (command:lower() == "?ut") or (command:lower() == "?uptime") then
		commandfound = true
		server.announce("[Server]", "Uptime: "..ut, user_peer_id)
		table.insert(chatMessages, {full_message="Uptime: "..ut,name="[Server]",topid=user_peer_id})
	end

	-- lists all the commands
	if (command:lower() == "?help") then
		commandfound = true
		server.announce("[Server]", "-=General Commands=-".."\nFormating: [required] {optional}".."\n|?help".."\n|lists all commands".."\n|?auth".."\n|gives you auth".."\n|?c".."\n|clears all your spawned vehciles".."\n|?disc".."\n|states our discord link".."\n|?ui".."\n|toggles your ui".."\n|?ver".."\n|show script version and current settings to staff".."\n|?ut".."\n|shows you the uptime of the server".."\n|?as".."\n|toggles your personal anti-steal".."\n|?pvp".."\n|toggles your pvp".."\n|?pvplist".."\n|lists all the players with pvp on".."\n|?repair".."\n|repairs all of your spawned vehicles".."\n|?tpv [group_id]".."\n|teleports you to inputed vehicle group", user_peer_id)
		table.insert(chatMessages, {full_message="-=General Commands=-".."\nFormating: [required] {optional}".."\n|?help".."\n|lists all commands".."\n|?auth".."\n|gives you auth".."\n|?c".."\n|clears all your spawned vehciles".."\n|?disc".."\n|states our discord link".."\n|?ui".."\n|toggles your ui".."\n|?ver".."\n|show script version and current settings to staff".."\n|?ut".."\n|shows you the uptime of the server".."\n|?as".."\n|toggles your personal anti-steal".."\n|?pvp".."\n|toggles your pvp".."\n|?pvplist".."\n|lists all the players with pvp on".."\n|?repair".."\n|repairs all of your spawned vehicles".."\n|?tpv [group_id]".."\n|teleports you to inputed vehicle group",name="[Server]",topid=user_peer_id})
		if perms >= PermMod then
			server.announce("[Server]", "-=Admin Commands=-".."\nFormating: [required] {optional}".."\n|?ca".."\n|clears all vehciles".."\n|?kick [peer id]".."\n|kicks player with inputed id".."\n|?ban [peer id]".."\n|bans player with inputed id".."\n|?pi {peer id}".."\n|lists players, if inputed tells about player".."\n|?pc [peer id]".."\n|clears vehciles of inputed players ids".."\n|?forceas [peer_id] {true/false}".."\n|toggles as for inputed peer id".."\n|?forcepvp [peer_id] {true/false}".."\n|toggles pvp for inputed peer id".."\n|?clearchat".."\n|clears chat", user_peer_id)
			table.insert(chatMessages, {full_message="-=Admin Commands=-".."\nFormating: [required] {optional}".."\n|?ca".."\n|clears all vehciles".."\n|?kick [peer id]".."\n|kicks player with inputed id".."\n|?ban [peer id]".."\n|bans player with inputed id".."\n|?pi {peer id}".."\n|lists players, if inputed tells about player".."\n|?pc [peer id]".."\n|clears vehciles of inputed players ids".."\n|?forceas [peer_id] {true/false}".."\n|toggles as for inputed peer id".."\n|?forcepvp [peer_id] {true/false}".."\n|toggles pvp for inputed peer id",name="[Server]",topid=user_peer_id})
		end
	end
	
	--  weather command
	if (command:lower() == "?w") or (command:lower() == "?weather") then
		commandfound = true
		if perms >= PermAdmin then
			if tonumber(one) ~= fail then
				server.setWeather(one, two, three)
				server.announce("[Server]", "Weather has been set to".."\nFog: "..one.."\nRain: "..two.."\nWind: "..three)
				table.insert(chatMessages, {full_message="Weather has been set to".."\nFog: "..one.."\nRain: "..two.."\nWind: "..three,name="[Server]"})
			elseif one == "reset" then
				server.setWeather(0, 0, 0)
				server.announce("[Server]", "Weather has been reset")
				table.insert(chatMessages, {full_message="Weather has been reset",name="[Server]"})
			end
		end
	end
	
	--set money
	if (command:lower() == "?setmoney") then
		commandfound = true
		if perms >= PermAdmin then
			server.setCurrency(one)
			server.announce("[Server]", "Money has been set to: $"..one)
			table.insert(chatMessages, {full_message="Money has been set to: $"..one,name="[Server]"})
		end
	end

	-- discord command
	if (command:lower() == "?disc") or (command:lower() == "?discord")then
		commandfound = true
		server.announce("[Server]", discordlink, user_peer_id)
		table.insert(chatMessages, {full_message=discordlink,name="[Server]",topid=user_peer_id})
	end

	-- print chatMessages
	if (command:lower() == "?printchat") then
		commandfound = true
		if perms >= PermAdmin then
			printChatMessages()
		end
	end

	-- clear chat
	if (command:lower() ==  "?clearchat") then
		commandfound = true
		if perms >= PermMod then
			for i = 1, maxMessages - 1 do
				server.announce("", "")
				table.insert(chatMessages, {full_message="",name=" "})
			end
			local name = getPlayerdata("name", true, user_peer_id)
			server.announce("[Chat]", "Chat Cleared By: "..name)
			table.insert(chatMessages, {full_message="Chat Cleared By: "..name,name="[Chat]"})
		end
	end

	-- private message another player
	if (command:lower() == "?msg") then
		commandfound = true
		if one ~= nil then
			local message = full_message:gsub("^%?msg%s*", ""):gsub("^%?", ""):gsub(one, "")
			local sendername = getPlayerdata("name", true, user_peer_id)
			local toname =	getPlayerdata("name", true, one)
			server.announce("[Msg] From ->"..sendername, message, one)
			table.insert(chatMessages, {full_message=message,name="[Msg] From "..sendername,topid=one})
			server.announce("[Msg] To ->"..toname, message, user_peer_id)
			table.insert(chatMessages, {full_message=message,name="[Msg] To "..toname,topid=user_peer_id})
		else
			server.announce("[Msg]", "Please input a peer id to send to", user_peer_id)
			table.insert(chatMessages, {full_message="Please input a peer id to send to",name="[Msg]",topid=user_peer_id})
		end
	end

	-- displays script version and other info
	if (command:lower() == "?ver") or (command:lower() == "?version") then
		commandfound = true
		server.announce("[AusCode]", "|AusCode version: "..scriptversion, user_peer_id)
		table.insert(chatMessages, {full_message="|AusCode version: "..scriptversion,name="[AusCode]",topid=user_peer_id})
		if perms >= PermMod then
			server.announce("[AusCode]", "|Script info: ".."\n|Playerdatasave: "..tostring(playerdatasave).."\n|Customchat: "..tostring(customchat).."\n|Despawnonreload: "..tostring(despawnonreload).."\n|Playermaxvehicles: "..tostring(playermaxvehicles).."\n|Subbodylimiting: "..tostring(subbodylimiting).."\n|Maxsubbodys: "..tostring(maxsubbodys).."\n|Voxellimiting: "..tostring(voxellimiting).."\n|Voxellimit: "..voxellimit.."\n|Warnthreashold: "..tostring(warnactionthreashold).."\n|Warnaction: "..tostring(warnaction).."\n|uptime: "..ut, user_peer_id)
			table.insert(chatMessages, {full_message="|Script info: ".."\n|Playerdatasave: "..tostring(playerdatasave).."\n|Customchat: "..tostring(customchat).."\n|Despawnonreload: "..tostring(despawnonreload).."\n|Playermaxvehicles: "..tostring(playermaxvehicles).."\n|Subbodylimiting: "..tostring(subbodylimiting).."\n|Maxsubbodys: "..tostring(maxsubbodys).."\n|Voxellimiting: "..tostring(voxellimiting).."\n|Voxellimit: "..voxellimit.."\n|Warnthreashold: "..tostring(warnactionthreashold).."\n|Warnaction: "..tostring(warnaction).."\n|uptime: "..ut,name="[AusCode]",topid=user_peer_id})
		end
	end

	-- used to fix my silly mistakes with deleting parts of g_savedata...
	if (command:lower() == "?repairgsave") then
		commandfound = true
		if perms >= PermOwner then
			g_savedata = {playerdata={}, usercreations={}}
			server.announce("[AusCode]", "Scripts require reloading after using this command")
			table.insert(chatMessages, {full_message="Scripts require reloading after using this command",name="[AusCode]"})
		end
	end

	if (command:lower() == "?test") then
		commandfound = true
		if perms >= PermOwner then
		end
	end

	if (command:lower() == "?tps") then
		commandfound = true
		server.announce("[Server]", "TPS: "..string.format("%.0f",TPS))
		table.insert(chatMessages, {full_message="TPS: "..string.format("%.0f",TPS),name="[Server]"})
	end

	if (command:lower() == "?rules") then
		commandfound = true
		server.announce("[Server]", "-=RULES=-\n1.Common sense rules apply\n2.No flares / radiation / emp\n3.Move vehicles out of the hanger if there are other people trying to spawn things\n4.Staff can and will take action acording to their judgement\n5.Despawn your vehicles after use\n6.Dont be mean to others", user_peer_id)
		table.insert(chatMessages, {full_message="-=RULES=-\n1.Common sense rules apply\n2.No flares / radiation / emp\n3.Move vehicles out of the hanger if there are other people trying to spawn things\n4.Staff can and will take action acording to their judgement\n5.Despawn your vehicles after use\n6.Dont be mean to others",name="[Server]",topid=user_peer_id})
	end
--endregion

	-- checks if user has inputed a correct command
	if not commandfound then
		server.notify(user_peer_id, "[Server]", "Command not found. try using ?help for a list of commands", 6)
	end
end
--endregion

--Misc functions
-- tip messages
function tipMessages()
	local playercount = countitems(server.getPlayers()) - 1
	if playercount >= 1 then
		tiptimer = tiptimer + 1
		if tiptimer >= tipFrequency*60 then
			if tipstep == 1 then
				server.announce("[Tip]", "use ?help to get a list of all the available commands")
				table.insert(chatMessages, {full_message="use ?help to get a list of all the available commands",name="[Tip]"})
				tiptimer = 0
			end
			if tipstep == 2 then
				server.announce("[Tip]", "use ?auth if you dont have permision to use a workbench")
				table.insert(chatMessages, {full_message="use ?auth if you dont have permision to use a workbench",name="[Tip]"})
				tiptimer = 0
			end
			if tipstep == 3 then
				server.announce("[Tip]", "we have a discord server. dont forget to join. discord.gg/snJyn6V2Qs or run the command ?disc")
				table.insert(chatMessages, {full_message="we have a discord server. dont forget to join. discord.gg/snJyn6V2Qs or run the command ?disc",name="[Tip]"})
				tiptimer = 0
			end
			if tipstep == 4 then
				server.announce("[Tip]", "use ?as or ?antisteal to toggle your personal antisteal")
				table.insert(chatMessages, {full_message="use ?as or ?antisteal to toggle your personal antisteal",name="[Tip]"})
				tiptimer = 0
			end
			if tipstep == 5 then
				server.announce("[Tip]", "use ?pvp to toggle your personal pvp")
				table.insert(chatMessages, {full_message="use ?pvp to toggle your personal pvp",name="[Tip]"})
				tiptimer = 0
			end
			if tipstep == 6 then
				server.announce("[Tip]", "use ?ui to toggle your personal ui")
				table.insert(chatMessages, {full_message="use ?ui to toggle your personal ui",name="[Tip]"})
				tiptimer = 0
				tipstep = 1
			end
			tipstep = tipstep + 1
		end
	end
end
--endregion


-- Main onTick
function onTick(game_ticks)
	-- uptime
	uptimeTicks = server.getTimeMillisec()
	ut = formatUptime(uptimeTicks, tickDuration)
	
	-- calls functions
	tipMessages()
	updateTPS(game_ticks)
	updateUI()
	loopManager()
	
	-- custom chat
	if customchat then
		if sendChat then
			printChatMessages()
			sendChat = false
		end
	end

	-- removes oil and radiation
	server.clearOilSpill()
	server.clearRadiation()
end

-- tps function
function updateTPS(game_ticks)
    local tempo = server.getTimeMillisec()

    if tempo - TIME < 1996 then
        TICKS = TICKS + (game_ticks * 0.49875)
    else
        -- TICKS remains the same
    end

    if tempo - TIME >= 1996 then
        TPS = TICKS
        TIME = tempo
        TICKS = 0
    end
end

-- ui function. displays tps uptime and players as and pvp
function updateUI()
	if (countitems(server.getPlayers()) - 1) >= 1 then
		if uitimer >= 60 then
			local ut = formatUptime(uptimeTicks, tickDuration)
			local TPS = string.format("%.0f",TPS)
			for _,X in pairs(server.getPlayers()) do
				if X.id > 0 then
					local peer_id=X.id
					local pvp = tostring(getPlayerdata("pvp", true, X.id)) or "unknown"
					local pas = tostring(getPlayerdata("as", true, X.id)) or "unknown"
					server.setPopupScreen(peer_id, 0, "ui", getPlayerdata("ui", true, X.id), "-=Uptime=-".."\n"..ut.."\n-=Antisteal=-".."\n"..pas.."\n-=PVP=-".."\n"..pvp.."\n-=TPS=-".."\n"..TPS, -0.905, 0.8)
				end
			end
			uitimer = 0
		end
		uitimer = uitimer + 1
	end
end

--region Loop Manager
local loops = {}
function loop(time, func)
    local id = #loops + 1

    loops[id] = {
        callback = func,
        time = time,
        creationTime = server.getTimeMillisec(),
        id = id,
        paused = false
    }

    return {
        properties = loops[id],

        edit = function(self, newTime)
            self.properties.time = newTime
        end,

        call = function(self)
            self.properties.callback()
        end,

        remove = function(self)
            loops[id] = nil
            self = nil
        end,

        setPaused = function(self, state)
            self.paused = state
        end,

        id = id
    }
end

function removeLoop(id)
    loops[id] = nil
end

function loopManager()
    local timeNow = server.getTimeMillisec()
    for _, v in pairs(loops) do
        if timeNow >= v.creationTime + (v.time * 1000) and not v.paused then
            v.callback(v.id)
            v.creationTime = timeNow
        end
    end
end
--endregion

-- on world load / scripts reloaded
function onCreate(is_world_create)
	for i = 1, maxMessages do
		table.insert(chatMessages, {full_message="",name=" "})
	end
	server.announce("[AusCode]", "AusCode reloaded")
	table.insert(chatMessages, {full_message="AusCode reloaded",name="[AusCode]"})
	if unlockislands then
		server.setGameSetting("unlock_all_islands", true)
	end
	server.setGameSetting("vehicle_damage", true)
	server.setGameSetting("clear_fow", true)
	server.setGameSetting("override_weather", true)
	for _,playerdata in pairs(server.getPlayers()) do
		playerint(playerdata["steam_id"], playerdata["id"])
	end
	if despawnonreload then
		server.announce("[Server]", "Vehicles despawned for script reload. Once scripts have reloaded you may respawn your vehicles")
		table.insert(chatMessages, {full_message="Vehicles despawned for script reload. Once scripts have reloaded you may respawn your vehciles",name="[Server]"})
		for group_id, GroupData in pairs(g_savedata["usercreations"]) do
			server.despawnVehicleGroup(tonumber(group_id), true)
		end
	end
	if is_world_create then
		-- g_savedata table that persists between game sessions
		g_savedata = {
			playerdata={},
			usercreations={}
		}
	end
	if customchat then
		sendChat = true
	end
end
--endregion
