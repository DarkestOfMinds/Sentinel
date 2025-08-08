local ModuleManager = {
    _loadedModules = {}
}

local Config = require(script.Parent.Parent.Config.Modules)

function ModuleManager:LoadEnabledModules()
    if Config.Movement.Enabled then
        table.insert(self._loadedModules, {
            Name = "Speed",
            Module = require(script.Parent.Parent.Detectors.Movement.Speed)})
    end

    if Config.AI.Enabled then
        table.insert(self._loadedModules, {
            Name = "BehaviorEngine",
            Module = require(script.Parent.Parent.AI.BehaviorEngine)
        })
    end
end

function ModuleManager:GetLoadedModuleCount()
    return #self._loadedModules
end

return ModuleManager
