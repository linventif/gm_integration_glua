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