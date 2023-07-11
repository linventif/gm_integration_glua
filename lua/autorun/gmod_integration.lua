// Prevent the user from using a static version of the addon
if SERVER then
    if !file.Exists("steam_cache/content/4000/2882747990", "BASE_PATH") then
        timer.Simple(5, function()
            print([[
                // -- // -- // -- // -- // -- // -- // -- // -- // -- //
                // Please don't use a static version of Gmod Integration.
                // -- // -- // -- // -- // -- // -- // -- // -- // -- //
                // Please use the workshop version : https://gmod-integration.com/workshop
                // If you don't use the workshop version, you will not receive any update and you will not be able to use new features or bug fixes.
                // If you need help, please contact us : https://gmod-integration.com/discord
                // -- // -- // -- // -- // -- // -- // -- // -- // -- //
            ]])
        end)
    end
end

// Variables
gmInte = gmInte || {}
gmInte.version = "0.1.0"
gmInte.config = gmInte.config || {}

// Include all Shared files
include("gmod_integration/sh_config.lua")
include("gmod_integration/shared/sh_main.lua")
include("gmod_integration/shared/sh_languages.lua")

if SERVER then
    // Send all Shared files to the Client
    AddCSLuaFile("gmod_integration/sh_config.lua")
    AddCSLuaFile("gmod_integration/shared/sh_main.lua")
    AddCSLuaFile("gmod_integration/shared/sh_languages.lua")

    // Send all Client files to the Client
    AddCSLuaFile("gmod_integration/client/cl_main.lua")

    // Include all Server files
    include("gmod_integration/sv_config.lua")
    include("gmod_integration/server/sv_http.lua")
    include("gmod_integration/server/sv_main.lua")
elseif CLIENT then
    // Include all Client files
    include("gmod_integration/client/cl_main.lua")
end
