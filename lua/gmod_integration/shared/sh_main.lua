// Functions
function gmInte.log(msg, debug)
    if (debug && !gmInte.config.debug) then return end
    //format: [2021-08-01 00:00:00] [INFO] msg
	print("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] [Garry's Mod Integration] " .. msg)
end

// Load Config
if (SERVER) then
    // check if config exists, if not, create it
    if (!file.Exists("gm_integration", "DATA") || !file.Exists("gm_integration/config.json", "DATA")) then
        // create directory
        file.CreateDir("gm_integration")
        file.Write("gm_integration/config.json", util.TableToJSON(gmInte.config, true))
    end
    // if custom config exists, use it, else use default config
    if (gmInte.config.id == "") then
        gmInte.config = util.JSONToTable(file.Read("gm_integration/config.json", "DATA"))
    end
elseif (CLIENT) then
    //
end