-- g_savedata table that persists between game sessions
g_savedata = {}

-- perm numbers
PermNone = 0
PermAuth = 1
PermMod = 2
PermAdmin = 3
PermOwner = 4

-- admin list
adminlist = {{"76561199240115313",PermOwner},{"76561199143631975",PermAdmin},{"76561199032157360",PermAdmin},{"76561198371768441",PermAdmin}}

-- list that doesnt save
nosave = {playerdata={}}
last_ms = 0
last_tps = 0

-- initalising the player
function playerint(steam_id, peer_id)
    local pn =  server.getPlayerName(peer_id)
    nosave["playerdata"][tostring(peer_id)] = {steam_id=tostring(steam_id), name=tostring(pn), ui=true, as=true, pvp=false}
    for _, sid in pairs(adminlist) do
        if tostring(sid[1]) == tostring(steam_id) then
            nosave["playerdata"][tostring(peer_id)]["perms"] = sid[2]
        end
    end
end

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

-- player joined
function onPlayerJoin(steam_id, name, peer_id, admin, auth)
	server.announce("[Server]", name .. " joined the game")
    server.removeAuth(peer_id)
    playerint(steam_id, peer_id)
end

-- player leave
function onPlayerLeave(steam_id, name, peer_id, admin, auth)
    server.announce("[Server]", name .. " left the game")
    local ownersteamid = getsteam_id(peer_id)
        local vehiclespawned = false
        for group_id, GroupData in pairs(g_savedata["usercreations"]) do
            if GroupData["ownersteamid"] == ownersteamid then
                vehiclespawned = true
                server.despawnVehicleGroup(tonumber(group_id), true)
            end
        end
end

-- vehicle spawned
function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
    local pvp = ""
    if nosave["playerdata"][tostring(peer_id)]["as"] == true then
        server.setVehicleEditable(vehicle_id, false)
    elseif nosave["playerdata"][tostring(peer_id)]["as"] == false then
        server.setVehicleEditable(vehicle_id, true)
    end
    if nosave["playerdata"][tostring(peer_id)]["pvp"] == true then
        server.setVehicleInvulnerable(vehicle_id, false)
        pvp = "true"
    elseif nosave["playerdata"][tostring(peer_id)]["pvp"] == false then
        server.setVehicleInvulnerable(vehicle_id, true)
        pvp = "false"
    end
    local name = server.getPlayerName(peer_id)
    server.setVehicleTooltip(vehicle_id, "Owner: "..peer_id.." | "..name.."\nPVP: "..pvp.." | Vehicle ID: "..vehicle_id)
    server.announce("[Server]", peer_id.." | "..name.." spawned vehicle: "..vehicle_id.." Cost: "..string.format("%.0f",group_cost))
    if peer_id ~= -1 and peer_id ~= nil then
         if g_savedata["usercreations"][tostring(group_id)] == nil then
            g_savedata["usercreations"][tostring(group_id)] = {OwnerID=peer_id, ownersteamid = getsteam_id(peer_id), Vehicleparts={}, vehicle_id=tostring(vehicle_id)}
         end
        g_savedata["usercreations"][tostring(group_id)]["Vehicleparts"][tostring(vehicle_id)] = 1     
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

-- geting the steam id
function getsteam_id(peer_id)
    local playerlist = server.getPlayers()
    for _, playerdata in pairs(playerlist) do
        if tostring(playerdata["id"]) == tostring(peer_id) then
            return playerdata["steam_id"]
        end
    end
end

-- tps
TPS=0
TPSList={}
TPSDivisor=0
TpsHistoryLength=20
LastMS=server.getTimeMillisec()

for X =1,TpsHistoryLength,1 do
    TPSDivisor=TPSDivisor + X
    table.insert(TPSList,0)
end
TPSDivisor=1/TPSDivisor

function ComputeTPS()
    local CurrentTPS=(1000 / (server.getTimeMillisec() - LastMS)) * 5

    for X,Y in pairs(TPSList) do
        TPSList[X]=TPSList[X + 1]
    end
    TPSList[TpsHistoryLength]=CurrentTPS

    TPS=0
    for X =1,TpsHistoryLength,1 do
        TPS=TPS + (TPSList[X] * (TPSDivisor * X))
    end
    
    TPS=(math.floor(TPS * 10) / 10) / 5
    LastMS=server.getTimeMillisec()
end


-- commands
function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four, five)
    local perms = nosave["playerdata"][tostring(user_peer_id)]["perms"]
    
    -- shows command players run
    local playername = server.getPlayerName(user_peer_id)
    server.announce(playername, "> "..full_message)
    
    -- lists all the commands
    if (command:lower() == "?help") then
        server. announce("[Server]", "-=General Commands=-".."\n| ?help| lists all commands".."\n| ?c      | clears all your spawned vehciles".."\n| ?disc | states our discord link".."\n| ?ut    | shows you the uptime of the server".."\n| ?as    | toggles your personal anti-steal".."\n| ?ui    | toggles your ui".."\n| ?pvp | toggles your pvp", user_peer_id)
        if perms >= PermAdmin then
            server. announce("[Server]", "-=Admin Commands=-".."\n| ?ca    | clears all vehciles".."\n| ?kick | kicks player with inputed id".."\n| ?ban | bans player with inputed id".."\n| ?pi     | lists players, if inputed tells about player".."\n| ?pc    | clears vehciles of inputed players ids", user_peer_id)
        end
    end

    -- player info
	if (command:lower() == "?pi") then
        if one ~= nil then
            local sid = ""
            local name = ""
            local wui = ""
            local pvp = ""
            if perms >= PermAdmin then
                local playedata = nosave["playerdata"][tostring(one)]
                sid = playedata["steam_id"]    
                name = playedata["name"]
                if playedata["ui"] == true then
                    wui = "True"
                elseif playedata["ui"] == false then
                    wui = "False"
                else
                    wui = "Unknown"
                end
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
                server.announce("[Server]", "Peer id: "..tostring(one).."\nName: "..name.."\nSteam id: "..tostring(sid).."\nUI: "..wui.."\nAntisteal: "..was.."\nPVP: "..pvp, user_peer_id)
            end
        else
		    local pid = ""
            local sid = ""
            local name = ""
            if perms >= PermAdmin then
                for pid, playedata in pairs(nosave["playerdata"]) do
                    sid = playedata["steam_id"]
                    name = playedata["name"]
                    server.announce("[Server]", "Peer id: "..tostring(pid).."\nName: "..tostring(name).."\nSteam id: "..tostring(sid), user_peer_id)
                end
            end
        end
    end

    -- discord command
    if (command:lower() == "?disc") then
        server.announce("[Server]", "discord.gg/snJyn6V2Qs", user_peer_id)
    elseif (command == "?discord") then
        server.announce("[Server]", "discord.gg/snJyn6V2Qs", user_peer_id)
    end
    
    -- clear vehicle command
    if (command:lower() == "?c") then
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
    elseif (command:lower() == "?clear") then
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
    if (command:lower() == "?pc") then
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
    elseif (command:lower() == "?playerclear") then
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
    if (command:lower() == "?ca") then
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
    elseif (command:lower() == "?clearall") then
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
        if nosave["playerdata"][tostring(peer_id)]["pvp"] == true then
            nosave["playerdata"][tostring(peer_id)]["pvp"] = false
            server.notify(user_peer_id, "[Server]", "PVP disabled", 6)
            server.announce("[Server]", peer_id.." | "..name.." Has disabled there pvp")
            worked = true
            pvp = "false"
        elseif nosave["playerdata"][tostring(peer_id)]["pvp"] == false then
            nosave["playerdata"][tostring(peer_id)]["pvp"] = true
            server.notify(user_peer_id, "[Server]", "PVP enabled", 5)
            server.announce("[Server]", peer_id.." | "..name.." Has enabled there pvp")
            worked = true
            pvp = "true"
        end
        if worked ~= true then
            nosave["playerdata"][tostring(peer_id)]["pvp"] = true
            server.notify(user_peer_id, "[Server]", "PVP enabled", 5)
            server.announce("[Server]", peer_id.." | "..name.." Has enabled there pvp")
        end
        local ownersteamid = getsteam_id(user_peer_id)
        local vehicle_id = nil
        local name = server.getPlayerName(peer_id)
        for group_id, GroupData in pairs(g_savedata["usercreations"]) do
            if GroupData["ownersteamid"] == ownersteamid then
                vehicle_id = GroupData["vehicle_id"]
                server.setVehicleTooltip(vehicle_id, "Owner: "..peer_id.." | "..name.."\nPVP: "..pvp.." | Vehicle ID: "..vehicle_id)
                if nosave["playerdata"][tostring(peer_id)]["pvp"] == true then
                    server.setVehicleInvulnerable(vehicle_id, false)
                elseif nosave["playerdata"][tostring(peer_id)]["pvp"] == false then
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
        else
            server.notify(user_peer_id, "[Server]", "You have no vehicle/vehicles to be repaired and restocked", 6)
        end
    end

    --teleport player to vehicle
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

    -- uptime command
    if (command:lower() == "?ut") then
        local ut = formatUptime(uptimeTicks, tickDuration)
        server.announce("[Server]", "Uptime: "..ut, user_peer_id)
    elseif (command == "?uptime") then
        local ut = formatUptime(uptimeTicks, tickDuration)
        server.announce("[Server]", "Uptime: "..ut, user_peer_id)
    end

    -- anti steal command
    if (command:lower() == "?as") then
        local peer_id = user_peer_id
        local worked = false
        if nosave["playerdata"][tostring(peer_id)]["as"] == true then
            nosave["playerdata"][tostring(peer_id)]["as"] = false
            server.notify(user_peer_id, "[Server]", "Anti-steal disabled", 6)
            worked = true
        elseif nosave["playerdata"][tostring(peer_id)]["as"] == false then
            nosave["playerdata"][tostring(peer_id)]["as"] = true
            server.notify(user_peer_id, "[Server]", "Anti-steal enabled", 5)
            worked = true
        end
        if worked ~= true then
            nosave["playerdata"][tostring(peer_id)]["as"] = true
            server.notify(user_peer_id, "[Server]", "Anti-steal enabled", 5)
        end
    elseif (command:lower() == "?antisteal") then
        local peer_id = user_peer_id
        local worked = false
        if nosave["playerdata"][tostring(peer_id)]["as"] == true then
            nosave["playerdata"][tostring(peer_id)]["as"] = false
            server.notify(user_peer_id, "[Server]", "Anti-steal disabled", 6)
            worked = true
        elseif nosave["playerdata"][tostring(peer_id)]["as"] == false then
            nosave["playerdata"][tostring(peer_id)]["as"] = true
            server.notify(user_peer_id, "[Server]", "Anti-steal enabled", 5)
            worked = true
        end
        if worked ~= true then
            nosave["playerdata"][tostring(peer_id)]["as"] = true
            server.notify(user_peer_id, "[Server]", "Anti-steal enabled", 5)
        end
    end
    
    -- ui command
    if (command:lower() == "?ui") then
        local peer_id = user_peer_id
        local worked = false
        if nosave["playerdata"][tostring(peer_id)]["ui"] == false then
            nosave["playerdata"][tostring(peer_id)]["ui"] = true
            server.notify(user_peer_id, "[WIP]", "UI enabled", 5)
            worked = true
        elseif nosave["playerdata"][tostring(peer_id)]["ui"] == true then
            nosave["playerdata"][tostring(peer_id)]["ui"] = false
            server.notify(user_peer_id, "[WIP]", "UI disabled", 6)
            worked = true
        end
        if worked ~= true then
            nosave["playerdata"][tostring(peer_id)]["ui"] = true
            server.notify(user_peer_id, "[WIP]", "UI enabled", 5)
        end
    end
    
    -- ui function 
    function onTick()
        local ut = formatUptime(uptimeTicks, tickDuration)
        ComputeTPS()
        for _,X in pairs(server.getPlayers()) do
            local peer_id=X.id 
            local pas = ""
            local pvp = ""
            local CTPS = ""
            if TPS >= 60 then
                CTPS = "60"
            else
                CTPS = string.format("%.0f",TPS)
            end
            if nosave["playerdata"][tostring(peer_id)]["as"] == true then
                pas = "True"
            elseif nosave["playerdata"][tostring(peer_id)]["as"] == false then
                pas = "False"
            else
                pas = "Unknown"
            end
            if nosave["playerdata"][tostring(peer_id)]["pvp"] == true then
                pvp = "True"
            elseif nosave["playerdata"][tostring(peer_id)]["pvp"] == false then
                pvp = "False"
            else
                pvp = "Unknown"
            end
            server.setPopupScreen(peer_id, 1, "ui", nosave["playerdata"][tostring(peer_id)]["ui"], "-=Uptime=-".."\n"..ut.."\n-=Antisteal=-".."\n"..pas.."\n-=PVP=-".."\n"..pvp.."\n-=TPS=-".."\n"..CTPS, -0.905, 0.8)
        end
    end

    -- auth command
    if (command:lower() == "?auth") then
        server.addAuth(user_peer_id)
        server.notify(user_peer_id, "[Server]", "You have been authed", 5)
    end
    
    --  weather command
    if (command:lower() == "?w") then
        if perms >= PermAdmin then
            if tonumber(one) ~= fail then
                server.setWeather(one, two, three)
                server.announce("[Server]", "Weather has been set to".."\nFog: "..one.."\nRain: "..two.."\nWind: "..three)
            elseif one == "reset" then
                server.setWeather(0, 0, 0)
                server.announce("[Server]", "Weather has been reset")
            end
        end
    end
end



-- tip messages
if 1 == 1 then
    local timer = 0
    local step = 1
    function onTick()
        timer = timer + 1
        if timer >= 90*60 then
            if step == 1 then
                server.announce("[Tip]", "use ?help to get a list of all the available commands")
                timer = 0
            end
            if step == 2 then
                server.announce("[Tip]", "use ?auth if you dont have permision to use a workbench")
                timer = 0
            end
            if step == 3 then
                server.announce("[Tip]", "we have a discord server. dont forget to join. discord.gg/snJyn6V2Qs or run the command ?disc")
                timer = 0
            end
            if step == 4 then
                server.announce("[Tip]", "use ?as or ?antisteal to toggle your personal antisteal")
                timer = 0
            end
            if step == 5 then
                server.announce("[Tip]", "use ?pvp to toggle your personal pvp")
                timer = 0
                step = 1
            end
            step = step + 1
        end
    end
end

-- on scripts reloaded
function onDestroy()
    server.cleanVehicles()
    server.announce("[Server]", "Vehicles despawned for script reload. Once scripts have reloaded you may respawn your vehciles")
end

-- on world load
function onCreate(is_world_create)
    server.announce("[Server]", "Scripts reloaded")
    if g_savedata["usercreations"] == nil then
        g_savedata["usercreations"] = {}
    end
    for _,playerdata in pairs(server.getPlayers()) do
        playerint(playerdata["steam_id"], playerdata["id"])
    end
end