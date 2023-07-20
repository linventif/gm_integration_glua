//
// Functions
//

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

// Main
function gmInte.removePort(ip)
    return string.Explode(":", ip)[1]
end

function gmInte.plyValid(ply)
    return ply:IsValid() && ply:IsPlayer() && !ply:IsBot()
end

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
    // save this in data/gmod_integration/setting.json but first check if variable is valid
    if !gmInte.config[setting] then
        gmInte.log("Unknown Setting")
        return
    end
    gmInte.config[setting] = value
    file.Write("gm_integration/config.json", util.TableToJSON(gmInte.config, true))
    gmInte.log("Setting Saved")
end

function gmInte.playerConnect(data)
    if (data.bot == 1) then return end
    data.steam = util.SteamIDTo64(data.networkid)
    gmInte.simplePost("userConnect", data)
end

function gmInte.userFinishConnect(ply)
    if (!gmInte.plyValid(ply)) then return end
    gmInte.simplePost("userFinishConnect",
        {
            steam = ply:SteamID64(), // essential
            name = ply:Nick(), // for the syncro name
        }
    )
end

function gmInte.playerChangeName(ply, old, new)
    if (!gmInte.plyValid(ply)) then return end
    gmInte.simplePost("userChangeName",
        {
            steam = ply:SteamID64(),
            old = old,
            new = new,
        }
    )
end

function gmInte.playerDisconnected(ply)
    if (!gmInte.plyValid(ply)) then return end
    gmInte.simplePost("userDisconnect",
        {
            steam = ply:SteamID64(),
            kills = ply:Frags() || 0,
            deaths = ply:Deaths() || 0,
            money = ply:gmInteGetTotalMoney(),
            rank = ply:GetUserGroup() || "user",
        }
    )
end

function gmInte.tryConfig()
    gmInte.simplePost("tryConfig", {},
    function( body, length, headers, code)
        gmInte.log("GG you are authorized, the link discord guild is: " .. body)
    end)
end

function gmInte.serverShutDown()
    for ply, ply in pairs(player.GetAll()) do
        gmInte.playerDisconnected(ply)
    end
end