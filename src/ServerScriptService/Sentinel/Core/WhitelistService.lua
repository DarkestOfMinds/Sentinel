local WhitelistService = {
    _whitelistedIds = {}
}

local WhitelistConfig = require(script.Parent.Parent.Config.Whitelist)

function WhitelistService:Initialize()
    for _, userId in ipairs(WhitelistConfig.UserIDs) do
        self._whitelistedIds[userId] = true
    end
    
    -- Optional: Load from DataStore if enabled
    if WhitelistConfig.UseCloudWhitelist then
        self:_SyncCloudWhitelist()
    end
end

function WhitelistService:IsWhitelisted(player)
    return self._whitelistedIds[player.UserId] or false
end

return WhitelistService
