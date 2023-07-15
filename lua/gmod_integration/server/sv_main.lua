// Network
util.AddNetworkString("gmIntegration")

function gmInte.removePort(ip)
    return string.Explode(":", ip)[1]
end

// Meta
local ply = FindMetaTable("Player")

function ply:gmInteGetTotalMoney()
    // if darkrp
    if DarkRP then
        return self:getDarkRPVar("money")
    end

    // else
    return 0
end

// Main Functions
function gmInte.serverExport()
    gmInte.log("Generating Token", true)
    gmInte.post(
        // Endpoint
        "",
        // Parameters
        { request = "generate" },
        // Data
        {
            name = GetHostName(),
            ip = game.GetIPAddress(),
            port = GetConVar("hostport"):GetInt(),
        },
        // onSuccess
        function( body, length, headers, code )
            if gmInte.isCodeValid(code) then
                gmInte.log("Token Generated Successfully")
                gmInte.log("Use it with the command: /server import " .. body)
            else
                gmInte.httpError(body)
            end
        end
    )
end

function gmInte.saveSetting(setting, value)
    // save this in data/gmod_integration/settings.json but first check if variable is valid
    if !gmInte.settings[setting] then
        gmInte.log("Unknown Setting")
        return
    end
    gmInte.settings[setting] = value
    file.Write("gm_integration/settings.json", util.TableToJSON(gmInte.settings))
    gmInte.log("Setting Saved")
end

function gmInte.playerConnect(data)
    if (data.bot == 1) then return end
    data.steam = util.SteamIDTo64(data.networkid)
    gmInte.simplePost("userConnect", data)
end

function gmInte.userFinishConnect(ply)
    gmInte.simplePost("userFinishConnect",
        {
            steam = ply:SteamID64(), // essential
            name = ply:Nick(), // for the syncro name
        }
    )
end

function gmInte.playerChangeName(ply, old, new)
    gmInte.simplePost("userChangeName",
        {
            steam = ply:SteamID64(),
            old = old,
            new = new,
        }
    )
end

function gmInte.playerDisconnected(ply)
    gmInte.simplePost("userDisconnect",
        {
            steam = ply:SteamID64(),
            kills = ply:Frags(),
            deaths = ply:Deaths(),
            money = ply:gmInteGetTotalMoney(),
        }
    )
end

function gmInte.serverShutDown()
    for ply, ply in pairs(player.GetAll()) do
        gmInte.playerDisconnected(ply)
    end
end

// Net Functions
local conFuncs = {
    ["version"] = function()
        gmInte.log("Version: " .. gmInte.version)
    end,
    ["export"] = function()
        gmInte.serverExport()
    end,
    ["setting"] = function(args)
        gmInte.saveSetting(args[2], args[3])
    end,
}

concommand.Add("gm_integration", function(ply, cmd, args)
    // only usable by server console and superadmins
    if ply:IsPlayer() && !ply:IsSuperAdmin() then return end

    // check if argument is valid
    if conFuncs[args[1]] then
        conFuncs[args[1]](args)
    else
        gmInte.log("Unknown Command Argument")
    end
end)

local netFuncs = {
    [0] = function(ply)
        gmInte.userFinishConnect(ply)
    end,
}

net.Receive("gmIntegration", function(len, ply)
    if !ply:IsPlayer() then return end
    local id = net.ReadUInt(8)
    local data = util.JSONToTable(net.ReadString() || "{}")
    // check if argument is valid
    if netFuncs[id] then
        netFuncs[id](ply, data)
    end
end)

//
// Hooks
//

// Server
hook.Add("ShutDown", "gmInte:Server:ShutDown", function()
    gmInte.serverShutDown(ply)
end)

// Player
gameevent.Listen("player_connect")
hook.Add("player_connect", "gmInte:Player:Connect", function(data)
    gmInte.playerConnect(data)
end)
hook.Add("PlayerDisconnected", "gmInte:Player:Disconnect", function(ply)
    gmInte.playerDisconnected(ply)
end)
hook.Add("onPlayerChangedName", "gmInte:PlayerChangeName", function(ply, old, new)
    gmInte.playerChangeName(ply, old, new)
end)