local EvidenceLogger = {}
EvidenceLogger.__index = EvidenceLogger

function EvidenceLogger.new()
    local self = setmetatable({
        _logs = {},
        _maxLogsPerPlayer = 20,
        _dataStoreEnabled = false
    }, EvidenceLogger)
    
    return self
end

function EvidenceLogger:Log(player, eventType, data)
    local logEntry = {
        timestamp = os.time(),
        event = eventType,
        player = {
            userId = player.UserId,
            name = player.Name,
            accountAge = player.AccountAge
        },
        data = data,
        server = {
            jobId = game.JobId,
            placeId = game.PlaceId,
            time = os.date("%X")
        }
    }
    
    if not self._logs[player] then
        self._logs[player] = {}
    end
    
    table.insert(self._logs[player], 1, logEntry)
    
    if #self._logs[player] > self._maxLogsPerPlayer then
        table.remove(self._logs[player])
    end
    
    -- Optional: Save to DataStore
    if self._dataStoreEnabled then
        self:_saveToDataStore(player, logEntry)
    end
    
    -- Output to server console
    warn(string.format(
        "[AC Log] %s - %s: %s",
        player.Name,
        eventType,
        game:GetService("HttpService"):JSONEncode(data)
    ))
end

function EvidenceLogger:_saveToDataStore(player, logEntry)
    -- Implement your DataStore saving logic here
end

function EvidenceLogger:GetPlayerLogs(player)
    return self._logs[player] or {}
end

return EvidenceLogger.new()
