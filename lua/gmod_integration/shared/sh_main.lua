// Functions
function gmInte.log(msg)
    //format: [2021-08-01 00:00:00] [INFO] msg
	print("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] [Garry's Mod Integration] " .. msg)
end

// Load Config
if (SERVER) then
    // check if config exists, if not, create it
    if (!file.Exists("gmInte/config.json", "DATA")) then
        file.Write("gmInte/config.json", util.TableToJSON(gmInte.config))
    end
    // if custom config exists, use it, else use default config
    if (gmInte.config.id == "") then
        gmInte.config = util.JSONToTable(file.Read("gmInte/config.json", "DATA"))
    end
elseif (CLIENT) then
    //
end