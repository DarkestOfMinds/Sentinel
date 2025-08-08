local SpeedDetector = {}
SpeedDetector.__index = SpeedDetector
SpeedDetector.Version = "1.0.0"

function SpeedDetector.new(config)
    local self = setmetatable({
        Config = config,
        _playerData = {},
        _violations = {}
    }, SpeedDetector)
    
    return self
end

function SpeedDetector:StartMonitoring(player)
    self._playerData[player] = {
        lastPosition = nil,
        lastCheck = os.clock(),
        violationCount = 0
    }
    
    coroutine.wrap(function()
        while player and player.Parent do
            self:_CheckPlayer(player)
            -- Randomized check interval to prevent pattern recognition
            task.wait(0.3 + math.random() * 0.4)
        end
        self._playerData[player] = nil
    end)()
end

function SpeedDetector:_CheckPlayer(player)
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local data = self._playerData[player]
    local currentPosition = humanoidRootPart.Position
    
    if data.lastPosition then
        local distance = (currentPosition - data.lastPosition).Magnitude
        local timeDelta = os.clock() - data.lastCheck
        local speed = distance / timeDelta
        
        -- Account for potential lag spikes
        if timeDelta < 1 and speed > self.Config.MaxSpeed then
            data.violationCount = data.violationCount + 1
            
            if data.violationCount >= self.Config.MaxViolations then
                self:_HandleViolation(player, "Speedhack", {
                    speed = speed,
                    allowedSpeed = self.Config.MaxSpeed
                })
            end
        else
            data.violationCount = math.max(0, data.violationCount - 0.5)
        end
    end
    
    data.lastPosition = currentPosition
    data.lastCheck = os.clock()
end

function SpeedDetector:_HandleViolation(player, type, evidence)
    warn(string.format(
        "[SpeedDetector] %s (%d) violated %s (Evidence: %s)",
        player.Name,
        player.UserId,
        type,
        game:GetService("HttpService"):JSONEncode(evidence)
    ))
end

return SpeedDetector
