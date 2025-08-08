local NoclipDetector = {}
NoclipDetector.__index = NoclipDetector

function NoclipDetector.new(config)
    local self = setmetatable({
        Config = config,
        _raycastParams = RaycastParams.new(),
        _playerStates = {}
    }, NoclipDetector)
    
    self._raycastParams.FilterDescendantsInstances = {workspace.Terrain}
    self._raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    return self
end

function NoclipDetector:MonitorPlayer(player)
    self._playerStates[player] = {
        lastRaycast = nil,
        violationCount = 0
    }
    
    coroutine.wrap(function()
        while player and player.Parent do
            self:_CheckPlayer(player)
            task.wait(0.5) -- Less frequent checks due to raycast cost
        end
        self._playerStates[player] = nil
    end)()
end

function NoclipDetector:_CheckPlayer(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return
    end
    
    local state = self._playerStates[player]
    local rayOrigin = rootPart.Position
    local rayDirection = Vector3.new(0, -self.Config.RaycastDistance, 0)
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, self._raycastParams)
    
    if not raycastResult and humanoid.FloorMaterial == Enum.Material.Air then
        state.violationCount = state.violationCount + 1
        
        if state.violationCount >= self.Config.MaxViolations then
            self:_HandleViolation(player, "Noclip", {
                position = rootPart.Position,
                floorMaterial = humanoid.FloorMaterial
            })
        end
    else
        state.violationCount = math.max(0, state.violationCount - 1)
    end
end

function NoclipDetector:_HandleViolation(player, type, evidence)
    warn(string.format(
        "[NoclipDetector] %s (%d) violated %s",
        player.Name,
        player.UserId,
        type
    ))
end

return NoclipDetector
