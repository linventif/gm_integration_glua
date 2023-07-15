//
// Console Commands
//

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
    ["try-config"] = function()
        gmInte.tryConfig()
    end
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