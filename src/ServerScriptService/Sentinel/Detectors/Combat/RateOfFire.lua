local RateOfFireDetector = {}
RateOfFireDetector.__index = RateOfFireDetector

function RateOfFireDetector.new(config)
    local self = setmetatable({
        Config = config,
        _weaponStats = {},
        _playerActions = {}
    }, RateOfFireDetector)
    
    -- Predefined weapon fire rates (can be extended)
    self._weaponStats = {
        Pistol = {maxRPM = 400, burstWindow = 0.2},
        Rifle = {maxRPM = 900, burstWindow = 0.1},
        Shotgun = {maxRPM = 60, burstWindow = 0.5}
    }
    
    return self
end

function RateOfFireDetector:RegisterWeapon(weaponName, stats)
    self._weaponStats[weaponName] = stats
end

function RateOfFireDetector:TrackPlayerAction(player, weaponType, timestamp)
    if not self._playerActions[player] then
        self._playerActions[player] = {}
    end
    
    local actions = self._playerActions[player]
    table.insert(actions, {
        weaponType = weaponType,
        timestamp = timestamp or os.clock()
    })
    
    for i = #actions, 1, -1 do
        if os.clock() - actions[i].timestamp > 5 then
            table.remove(actions, i)
        end
    end
    
    self:_AnalyzePattern(player, weaponType)
end

function RateOfFireDetector:_AnalyzePattern(player, weaponType)
    local weaponStats = self._weaponStats[weaponType]
    if not weaponStats then return end
    
    local actions = self._playerActions[player] or {}
    local relevantActions = {}
    
    local now = os.clock()
    for _, action in ipairs(actions) do
        if action.weaponType == weaponType and now - action.timestamp < weaponStats.burstWindow then
            table.insert(relevantActions, action)
        end
    end
    
    if #relevantActions > weaponStats.maxRPM * (weaponStats.burstWindow / 60) then
        self:_HandleViolation(player, "RateOfFire", {
            weaponType = weaponType,
            actionsInWindow = #relevantActions,
            maxAllowed = math.ceil(weaponStats.maxRPM * (weaponStats.burstWindow / 60))
        })
    end
end

return RateOfFireDetector
