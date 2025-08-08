local Sentinel = {}
local Logger = require(script.Parent.Logger)
local ModuleManager = require(script.Parent.ModuleManager)

function Sentinel:Start()
    Logger:Log("Initializing Sentinel Anti-Cheat")
    
    -- Load configuration and modules
    ModuleManager:LoadEnabledModules()
    
    Logger:Log(string.format(
        "Sentinel active | %d detectors loaded",
        ModuleManager:GetLoadedModuleCount()
    ))
end

return Sentinel
