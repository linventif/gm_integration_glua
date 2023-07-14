// Network
util.AddNetworkString("gmIntegration")

function gmInte.removePort(ip)
    return string.Explode(":", ip)[1]
end

// Main Functions
function gmInte.userFinishConnect(ply)
    gmInte.log("Player " .. ply:Nick() .. " finished connecting", true)
    gmInte.post(
        "",
        { request = "userFinishConnect" },
        {
            steam = ply:SteamID64(), // essential
            name = ply:Nick(), // for the syncro name
            ip = gmInte.removePort(ply:IPAddress()), // for the trust system
        },
        function( body, length, headers, code )
            //
        end
    )
end

// Player change name (darkrp only)
hook.Add("onPlayerChangedName", "gmInte:PlayerChangeName", function(ply, old, new)
    print("fefe " .. ply:Nick() .. " fefe name to " .. new)
    gmInte.log("Player " .. ply:Nick() .. " changed name to " .. new, true)
    gmInte.post(
        "",
        { request = "userChangeName" },
        {
            steam = ply:SteamID64(),
            name = new,
        },
        function( body, length, headers, code )
            //
        end
    )
end)

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