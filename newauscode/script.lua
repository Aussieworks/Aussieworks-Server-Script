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

-- admin list
adminlist = {{"76561199240115313",PermOwner},{"76561199143631975",PermAdmin},{"76561199032157360",PermAdmin},{"76561198371768441",PermAdmin}}

-- tables
nosave = {playerdata={}} -- list that doesnt save
chatMessages = {}
-- settings
discordlink = "discord.gg/snJyn6V2Qs"
maxMessages = 150
playermaxvehicles = 1
unlockislands = true
playerdatasave = false -- do not touch. currently being worked on
tipFrequency = 120  -- in seconds
tiptimer = 0
tipstep = 1 -- dont touch



-- Player Managment
-- initalising the player
function playerint(steam_id, peer_id)
    local pn =  server.getPlayerName(peer_id)
    if playerdatasave then
        if g_savedata["playerdata"][tostring(steam_id)] == nil then
            g_savedata["playerdata"][tostring(steam_id)] = {steam_id=tostring(steam_id), peer_id=tostring(peer_id), name=tostring(pn), as=true, pvp=false}
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
            for _, sid in pairs(adminlist) do
                if tostring(sid[1]) == tostring(steam_id) then
                    g_savedata["playerdata"][tostring(steam_id)]["perms"] = sid[2]
                end
            end
            if g_savedata["playerdata"][tostring(steam_id)]["perms"] == nil then
                g_savedata["playerdata"][tostring(steam_id)]["perms"] = PermNone
            end
        end
    else
        nosave["playerdata"][tostring(steam_id)] = {steam_id=tostring(steam_id), peer_id=tostring(peer_id), name=tostring(pn), as=true, pvp=false}
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
function getPlayerdata(get, idtoggle, id) -- if idtoggle true it will try to use peer_id
    if playerdatasave then
        if idtoggle then
            local sid = getsteam_id(id)
            if get == "as" then
                return g_savedata["playerdata"][tostring(sid)]["as"]
            elseif get == "pvp" then
                return g_savedata["playerdata"][tostring(sid)]["pvp"]
            elseif get == "perms" then
                return g_savedata["playerdata"][tostring(sid)]["perms"]
            elseif get == nil then
                return g_savedata["playerdata"][tostring(sid)]
            end
        else
            if get == "as" then
                return g_savedata["playerdata"][tostring(id)]["as"]
            elseif get == "pvp" then
                return g_savedata["playerdata"][tostring(id)]["pvp"]
            elseif get == "perms" then
                return g_savedata["playerdata"][tostring(id)]["perms"]
            elseif get == nil then
                return g_savedata["playerdata"][tostring(id)]
            end
        end
    else
        if idtoggle then
            local sid = getsteam_id(id)
            if get == "as" then
                return nosave["playerdata"][tostring(sid)]["as"]
            elseif get == "pvp" then
                return nosave["playerdata"][tostring(sid)]["pvp"]
            elseif get == "perms" then
                return nosave["playerdata"][tostring(sid)]["perms"]
            elseif get == nil then
                return nosave["playerdata"][tostring(sid)]
            end
        else
            if get == "as" then
                return nosave["playerdata"][tostring(id)]["as"]
            elseif get == "pvp" then
                return nosave["playerdata"][tostring(id)]["pvp"]
            elseif get == "perms" then
                return nosave["playerdata"][tostring(id)]["perms"]
            elseif get == nil then
                return nosave["playerdata"][tostring(id)]
            end
        end
    end
end

-- function to set playerdata
function setPlayerdata(set, idtoggle, id, value) -- if idtoggle true it will try to use peer_id
    if playerdatasave then
        if idtoggle then
            local sid = getsteam_id(id)
            if set == "as" then
                g_savedata["playerdata"][tostring(sid)]["as"] = value
            elseif set == "pvp" then
                g_savedata["playerdata"][tostring(sid)]["pvp"] = value
            end
        else
            if set == "as" then
                g_savedata["playerdata"][tostring(id)]["as"] = value
            elseif set == "pvp" then
                g_savedata["playerdata"][tostring(id)]["pvp"] = value
            end
        end
    else
        if idtoggle then
            local sid = getsteam_id(id)
            if set == "as" then
                nosave["playerdata"][tostring(sid)]["as"] = value
            elseif set == "pvp" then
                nosave["playerdata"][tostring(sid)]["pvp"] = value
            end
        else
            if set == "as" then
                nosave["playerdata"][tostring(id)]["as"] = value
            elseif set == "pvp" then
                nosave["playerdata"][tostring(id)]["pvp"] = value
            end
        end
    end
end

-- player joined
function onPlayerJoin(steam_id, name, peer_id, admin, auth)
	server.announce("[Server]", name .. " joined the game")
    table.insert(chatMessages, {full_message=name .. " joined the game",pid=-1})
    server.removeAuth(peer_id)
    playerint(steam_id, peer_id)
end

-- player leave
function onPlayerLeave(steam_id, name, peer_id, admin, auth)
    server.announce("[Server]", name .. " left the game")
    table.insert(chatMessages, {full_message=name .. " left the game",pid=-1})
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
    local playerlist = server.getPlayers()
    for _, playerdata in pairs(playerlist) do
        if tostring(playerdata["id"]) == tostring(peer_id) then
            return playerdata["steam_id"]
        end
    end
end

-- geting the peer id off a steam id
function getpeer_id(steam_id)
    local playerlist = server.getPlayers()
    for _, playerdata in pairs(playerlist) do
        if tostring(playerdata["steam_id"]) == tostring(steam_id) then
            return playerdata["id"]
        end
    end
end

-- custom chat function
function logChatMessage(peer_id, full_message)
    table.insert(chatMessages, {full_message=full_message,pid=peer_id,topid=nil})
    if #chatMessages > maxMessages then
        table.remove(chatMessages, 1)
    end
end
function printChatMessages()
    for i, chat in ipairs(chatMessages) do
        if chat.pid >= 0 then
            local name = server.getPlayerName(chat.pid)
            local perms = getPlayerdata("perms", true, chat.pid)
            local wperms = ""
            if perms == PermOwner then
                wperms = "Owner"
            elseif perms == PermAdmin then
                wperms = "Admin"
            elseif perms == PermMod then
                wperms = "Mod"
            elseif perms == PermAuth then
                wperms = "Player"
            elseif perms == PermNone then
                wperms = "Player"
            end
            server.announce("["..wperms.."] "..name, chat.full_message)
        elseif chat.pid == -10 then
            server.announce(" ", chat.full_message)
        elseif chat.pid == -1 then
            if chat.topid == nil then
                server.announce("[Server]", chat.full_message)
            elseif chat.topid ~= nil then
                server.announce("[Server]", chat.full_message, chat.topid)
            end
        elseif chat.pid == -2 then
            server.announce("[Tip]", chat.full_message)
        end
    end
end
function onChatMessage(peer_id, sender_name, message)
    logChatMessage(peer_id, message)
    sendChat = true
    local wsc = "false"
    if sendChat then
        wsc = "true"
    end
    server.announce("[Server]", wsc, 0)
    table.insert(chatMessages, {full_message=wsc,pid=-1,topid=0})
end
--endregion


-- Vehicle Managment
-- vehicle spawned
function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
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
    server.setVehicleTooltip(vehicle_id, "Owner: "..peer_id.." | "..name.."\nPVP: "..pvp.." | Vehicle ID: "..vehicle_id)
    server.announce("[Server]", peer_id.." | "..name.." spawned vehicle: "..vehicle_id.." Cost: $"..string.format("%.0f",group_cost))
    table.insert(chatMessages, {full_message=peer_id.." | "..name.." spawned vehicle: "..vehicle_id.." Cost: $"..string.format("%.0f",group_cost),pid=-1})
    if peer_id ~= -1 and peer_id ~= nil then
        if g_savedata["usercreations"][tostring(group_id)] == nil then
            g_savedata["usercreations"][tostring(group_id)] = {OwnerID=peer_id, ownersteamid=getsteam_id(peer_id), Vehicleparts={}, vehicle_id=tostring(vehicle_id), cost=group_cost}
        end
        g_savedata["usercreations"][tostring(group_id)]["Vehicleparts"][tostring(vehicle_id)] = 1
        local ownersteamid = getsteam_id(peer_id)
        local vehiclespawned = 0
        for group_id, GroupData in pairs(g_savedata["usercreations"]) do
            if GroupData["ownersteamid"] == ownersteamid then
                vehiclespawned = vehiclespawned + 1
                if vehiclespawned > playermaxvehicles then
                    server.despawnVehicleGroup(tonumber(group_id), true)
                    server.notify(peer_id, "[Server]", "You can only have "..playermaxvehicles.." vehicle spawned at a time", 6)
                end
            end
        end
    end
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


-- Commands
function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four, five)
    local perms = getPlayerdata("perms", true, user_peer_id)
    sendChat = true
    
    -- shows command players run
    local playername = server.getPlayerName(user_peer_id)
    if perms == PermOwner then
        wperms = "Owner"
    elseif perms == PermAdmin then
        wperms = "Admin"
    elseif perms == PermMod then
        wperms = "Mod"
    elseif perms == PermAuth then
        wperms = "Player"
    elseif perms == PermNone then
        wperms = "Player"
    end
    server.announce("["..wperms.."] "..playername, "> "..full_message)
    table.insert(chatMessages, {full_message="> "..full_message,pid=user_peer_id})
    

-- Player
    -- player info
	if (command:lower() == "?pi") then
        if one ~= nil then
            local sid = ""
            local name = ""
            local pvp = ""
            if perms >= PermAdmin then
                local playedata = getPlayerdata(nil, true, one)
                sid = playedata["steam_id"]    
                name = playedata["name"]
                if playedata["as"] == true then
                    was = "True"
                elseif playedata["as"] == false then
                    was = "False"
                else
                    was = "Unknown"
                end
                if playedata["pvp"] == true then
                    pvp = "True"
                elseif playedata["pvp"] == false then
                    pvp = "False"
                else
                    pvp = "Unknown"
                end
                server.announce("[Server]", "Peer id: "..tostring(one).."\nName: "..name.."\nSteam id: "..tostring(sid).."\nAntisteal: "..was.."\nPVP: "..pvp, user_peer_id)
                table.insert(chatMessages, {full_message="Peer id: "..tostring(one).."\nName: "..name.."\nSteam id: "..tostring(sid).."\nAntisteal: "..was.."\nPVP: "..pvp,pid=-1,topid=user_peer_id})
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
                        table.insert(chatMessages, {full_message="Peer id: "..tostring(pid).."\nName: "..tostring(name).."\nSteam id: "..tostring(sid),pid=-1,topid=user_peer_id})
                    end
                else
                    for sid, playedata in pairs(nosave["playerdata"]) do
                        pid = getpeer_id(sid)
                        name = playedata["name"]
                        server.announce("[Server]", "Peer id: "..tostring(pid).."\nName: "..tostring(name).."\nSteam id: "..tostring(sid), user_peer_id)
                        table.insert(chatMessages, {full_message="Peer id: "..tostring(pid).."\nName: "..tostring(name).."\nSteam id: "..tostring(sid),pid=-1,topid=user_peer_id})
                    end
                end
            end
        end
    end
    
    -- teleport player to player
    if (command:lower() == "?tpp") then
        if perms >= PermAdmin then
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
        local worked = false
        if one ~= nil then
            local matrix = server.getVehiclePos(one, 0, 0, 0)
            server.setPlayerPos(user_peer_id, matrix)
            worked = true
        elseif one == nil then
            server.notify(user_peer_id, "[Server]", "You have to input the vehicle id of the vehcile you want to go to", 6)
        end
        if worked == true then
            server.notify(user_peer_id, "[Server]", "You have been teleported to vehicle: "..one, 5)
        end
    end

    -- auth command
    if (command:lower() == "?auth") then
        server.addAuth(user_peer_id)
        server.notify(user_peer_id, "[Server]", "You have been authed", 5)
    end
--endregion


-- Vehicles
    -- clear vehicle command
    if (command:lower() == "?c") or (command:lower() == "?clear") then
        local ownersteamid = getsteam_id(user_peer_id)
        local vehiclespawned = false
        for group_id, GroupData in pairs(g_savedata["usercreations"]) do
            if GroupData["ownersteamid"] == ownersteamid then
                vehiclespawned = true
                server.despawnVehicleGroup(tonumber(group_id), true)
                server.notify(user_peer_id, "[Server]", "Your vehicle/vehicles have been despawned", 5)
            end
        end
        if vehiclespawned == false then
            server.notify(user_peer_id, "[Server]", "You do not have any vehicle/vehicles spawned", 6)
        end
    end
    
    -- clear spesific players vehicle
    if (command:lower() == "?pc") or (command:lower() == "?playerclear") then
        if perms >= PermAdmin then    
            local ownersteamid = getsteam_id(one)
            local vehiclespawned = false
            for group_id, GroupData in pairs(g_savedata["usercreations"]) do
                if GroupData["ownersteamid"] == ownersteamid then
                    vehiclespawned = true
                    server.despawnVehicleGroup(tonumber(group_id), true)
                    server.notify(user_peer_id, "[Server]", "Specified player's vehicle/vehicles have been despawned", 5)
                end
            end
            if vehiclespawned == false then
                server.notify(user_peer_id, "[Server]", "Specified player dosn't have any vehicle/vehicles to despawned", 6)
            end
        end
    end

    -- clear all vehicles
    if (command:lower() == "?ca") or (command:lower() == "?clearall") then
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
        local peer_id = user_peer_id
        local worked = false
        local pvp
        local name = server.getPlayerName(peer_id)
        if getPlayerdata("pvp", true, peer_id) == true then
            setPlayerdata("pvp", true, peer_id, false)
            server.notify(user_peer_id, "[Server]", "PVP disabled", 6)
            server.announce("[Server]", peer_id.." | "..name.." Has disabled there pvp")
            table.insert(chatMessages, {full_message=peer_id.." | "..name.." Has disabled there pvp",pid=-1})
            worked = true
            pvp = "false"
        elseif getPlayerdata("pvp", true, peer_id) == false then
            setPlayerdata("pvp", true, peer_id, true)
            server.notify(user_peer_id, "[Server]", "PVP enabled", 5)
            server.announce("[Server]", peer_id.." | "..name.." Has enabled there pvp")
            table.insert(chatMessages, {full_message=peer_id.." | "..name.." Has enabled there pvp",pid=-1})
            worked = true
            pvp = "true"
        end
        if worked ~= true then
            setPlayerdata("pvp", true, peer_id, true)
            server.notify(user_peer_id, "[Server]", "PVP enabled", 5)
            server.announce("[Server]", peer_id.." | "..name.." Has enabled there pvp")
            table.insert(chatMessages, {full_message=peer_id.." | "..name.." Has enabled there pvp",pid=-1})
        end
        local ownersteamid = getsteam_id(user_peer_id)
        local vehicle_id = nil
        local name = server.getPlayerName(peer_id)
        for group_id, GroupData in pairs(g_savedata["usercreations"]) do
            if GroupData["ownersteamid"] == ownersteamid then
                vehicle_id = GroupData["vehicle_id"]
                server.setVehicleTooltip(vehicle_id, "Owner: "..peer_id.." | "..name.."\nPVP: "..pvp.." | Vehicle ID: "..vehicle_id)
                if getPlayerdata("pvp", true, peer_id) == true then
                    server.setVehicleInvulnerable(vehicle_id, false)
                elseif getPlayerdata("pvp", true, peer_id) == false then
                    server.setVehicleInvulnerable(vehicle_id, true)
                end
            end
        end
    end

    -- repair vehicles
    if (command:lower() == "?repair") then
        local ownersteamid = getsteam_id(user_peer_id)
        local vehicle_id = nil
        local worked = false
        for group_id, GroupData in pairs(g_savedata["usercreations"]) do
            if GroupData["ownersteamid"] == ownersteamid then
                vehicle_id = GroupData["vehicle_id"]
                server.resetVehicleState(vehicle_id)
                worked = true
            end
        end
        if worked == true then
            local name = server.getPlayerName(user_peer_id)
            server.notify(user_peer_id, "[Server]", "Your vehicle/vehicles has been repaired and restocked", 5)
            server.announce("[Server]", user_peer_id.." | "..name.." Has repaired and restocked their vehicle/vehicles")
            table.insert(chatMessages, {full_message=user_peer_id.." | "..name.." Has repaired and restocked their vehicle/vehicles",pid=-1})
        else
            server.notify(user_peer_id, "[Server]", "You have no vehicle/vehicles to be repaired and restocked", 6)
        end
    end


    -- anti steal command
    if (command:lower() == "?as") or (command:lower() == "?antisteal") then
        local peer_id = user_peer_id
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
                vehicle_id = GroupData["vehicle_id"]
                if getPlayerdata("as", true, peer_id) == true then
                    server.setVehicleEditable(vehicle_id,false)
                elseif getPlayerdata("as", true, peer_id) == false then
                    server.setVehicleEditable(vehicle_id, true)
                end
            end
        end
    end
--endregion

    
-- Misc
    -- lists players with pvp on
    if (command:lower() == "?pvplist") then
        server.announce("[Server]", "-=Players with pvp on=-", user_peer_id)
        table.insert(chatMessages, {full_message="-=Players with pvp on=-",pid=-1,topid=user_peer_id})
        local pid = ""
        local name = ""
        if playerdatasave then
            for sid, playedata in pairs(g_savedata["playerdata"]) do
                pid = getpeer_id(sid)
                name = playedata["name"]
                if playedata["pvp"] == true then
                    server.announce("[Server]", pid.." | "..name, user_peer_id)
                    table.insert(chatMessages, {full_message=pid.." | "..name,pid=-1,topid=user_peer_id})
                end
            end
        else
            for sid, playedata in pairs(nosave["playerdata"]) do
                pid = getpeer_id(sid)
                name = playedata["name"]
                if playedata["pvp"] == true then
                    server.announce("[Server]", pid.." | "..name, user_peer_id)
                    table.insert(chatMessages, {full_message=pid.." | "..name,pid=-1,topid=user_peer_id})
                end
            end
        end
    end

    -- uptime command
    if (command:lower() == "?ut") or (command:lower() == "?uptime") then
        server.announce("[Server]", "Uptime: "..ut, user_peer_id)
        table.insert(chatMessages, {full_message="Uptime: "..ut,pid=-1,topid=user_peer_id})
    end

    -- lists all the commands
    if (command:lower() == "?help") then
        server.announce("[Server]", "-=General Commands=-".."\nFormating: [required] {optional}".."\n|?help".."\n|lists all commands".."\n|?auth".."\n|gives you auth".."\n|?c".."\n|clears all your spawned vehciles".."\n|?disc".."\n|states our discord link".."\n|?ut".."\n|shows you the uptime of the server".."\n|?as".."\n|toggles your personal anti-steal".."\n|?pvp".."\n|toggles your pvp".."\n|?pvplist".."\n|lists all the players with pvp on".."\n|?repair".."\n|repairs all of your spawned vehicles", user_peer_id)
        table.insert(chatMessages, {full_message="-=General Commands=-".."\nFormating: [required] {optional}".."\n|?help".."\n|lists all commands".."\n|?auth".."\n|gives you auth".."\n|?c".."\n|clears all your spawned vehciles".."\n|?disc".."\n|states our discord link".."\n|?ut".."\n|shows you the uptime of the server".."\n|?as".."\n|toggles your personal anti-steal".."\n|?pvp".."\n|toggles your pvp".."\n|?pvplist".."\n|lists all the players with pvp on".."\n|repairs all of your spawned vehicles",pid=-1,topid=user_peer_id})
        if perms >= PermAdmin then
            server.announce("[Server]", "-=Admin Commands=-".."\nFormating: [required] {optional}".."\n|?ca".."\n|clears all vehciles".."\n|?kick [peer id]".."\n|kicks player with inputed id".."\n|?ban [peer id]".."\n|bans player with inputed id".."\n|?pi {peer id}".."\n|lists players, if inputed tells about player".."\n|?pc [peer id]".."\n|clears vehciles of inputed players ids", user_peer_id)
            table.insert(chatMessages, {full_message="-=Admin Commands=-".."\nFormating: [required] {optional}".."\n|?ca".."\n|clears all vehciles".."\n|?kick [peer id]".."\n|kicks player with inputed id".."\n|?ban [peer id]".."\n|bans player with inputed id".."\n|?pi {peer id}".."\n|lists players, if inputed tells about player".."\n|?pc [peer id]".."\n|clears vehciles of inputed players ids",pid=-1,topid=user_peer_id})
        end
    end
    
    --  weather command
    if (command:lower() == "?w") or (command:lower() == "?weather") then
        if perms >= PermAdmin then
            if tonumber(one) ~= fail then
                server.setWeather(one, two, three)
                server.announce("[Server]", "Weather has been set to".."\nFog: "..one.."\nRain: "..two.."\nWind: "..three)
                table.insert(chatMessages, {full_message="Weather has been set to".."\nFog: "..one.."\nRain: "..two.."\nWind: "..three,pid=-1})
            elseif one == "reset" then
                server.setWeather(0, 0, 0)
                server.announce("[Server]", "Weather has been reset")
                table.insert(chatMessages, {full_message="Weather has been reset",pid=-1})
            end
        end
    end
    
    --set money
    if (command:lower() == "?setmoney") then
        if perms >= PermAdmin then
            server.setCurrency(one)
        end
    end

    -- discord command
    if (command:lower() == "?disc") or (command:lower() == "?discord")then
        server.announce("[Server]", discordlink, user_peer_id)
        table.insert(chatMessages, {full_message=discordlink,pid=-1,topid=user_peer_id})
    end

    -- print chatMessages
    if (command:lower() == "?printchat") then
        if perms >= PermAdmin then
            printChatMessages()
        end
    end

    -- clear g_savedata
    if (command:lower() == "?clearplayerdata") then
        if perms == PermOwner then
            g_savedata["playerdata"] = nil
        end
    end
--endregion
end
--endregion


-- tip messages
function tipMessages()
    tiptimer = tiptimer + 1
    if tiptimer >= tipFrequency*60 then
        if tipstep == 1 then
            server.announce("[Tip]", "use ?help to get a list of all the available commands")
            table.insert(chatMessages, {full_message="use ?help to get a list of all the available commands",pid=-2})
            tiptimer = 0
        end
        if tipstep == 2 then
            server.announce("[Tip]", "use ?auth if you dont have permision to use a workbench")
            table.insert(chatMessages, {full_message="use ?auth if you dont have permision to use a workbench",pid=-2})
            tiptimer = 0
        end
        if tipstep == 3 then
            server.announce("[Tip]", "we have a discord server. dont forget to join. discord.gg/snJyn6V2Qs or run the command ?disc")
            table.insert(chatMessages, {full_message="we have a discord server. dont forget to join. discord.gg/snJyn6V2Qs or run the command ?disc",pid=-2})
            tiptimer = 0
        end
        if tipstep == 4 then
            server.announce("[Tip]", "use ?as or ?antisteal to toggle your personal antisteal")
            table.insert(chatMessages, {full_message="use ?as or ?antisteal to toggle your personal antisteal",pid=-2})
            tiptimer = 0
        end
        if tipstep == 5 then
            server.announce("[Tip]", "use ?pvp to toggle your personal pvp")
            table.insert(chatMessages, {full_message="use ?pvp to toggle your personal pvp",pid=-2})
            tiptimer = 0
            tipstep = 1
        end
        tipstep = tipstep + 1
    end
end
--endregion


-- Main onTick
function onTick()
    -- uptime
    uptimeTicks = server.getTimeMillisec()
    ut = formatUptime(uptimeTicks, tickDuration)
    
    -- calls functions
    tipMessages()
    
    -- custom chat
    if sendChat then
        printChatMessages()
        sendChat = false
    end

    -- removes oil and radiation
    server.clearOilSpill()
    server.clearRadiation()
end

-- on scripts reloaded
function onDestroy()
    for group_id, GroupData in pairs(g_savedata["usercreations"]) do
        server.despawnVehicleGroup(tonumber(group_id), true)
    end
end


-- on world load
function onCreate(is_world_create)
    for i = 1, maxMessages do
        table.insert(chatMessages, {full_message="",pid=-10})
    end
    server.announce("[Server]", "Vehicles despawned for script reload. Once scripts have reloaded you may respawn your vehciles")
    table.insert(chatMessages, {full_message="Vehicles despawned for script reload. Once scripts have reloaded you may respawn your vehciles",pid=-1})
    server.announce("[Server]", "Scripts reloaded")
    table.insert(chatMessages, {full_message="Scripts reloaded",pid=-1})
    if g_savedata["usercreations"] == nil then
        g_savedata["usercreations"] = {}
    end
    if unlockislands then
        server.setGameSetting("unlock_all_islands", true)
    end
    server.setGameSetting("vehicle_damage", true)
    server.setGameSetting("clear_fow", true)
    server.setGameSetting("override_weather", true)
    for _,playerdata in pairs(server.getPlayers()) do
        playerint(playerdata["steam_id"], playerdata["id"])
    end
end