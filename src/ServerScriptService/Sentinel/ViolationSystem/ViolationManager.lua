local ViolationManager = {}
ViolationManager.__index = ViolationManager
ViolationManager.Version = "1.0.0"

local PunishmentTiers = require(script.Parent.PunishmentTiers)
local EvidenceLogger = require(script.Parent.EvidenceLogger)
local WhitelistService = require(script.Parent.Parent.WhitelistService)

function ViolationManager.new(config)
    local self = setmetatable({
        Config = config,
        _playerViolations = {},
        _activePunishments = {},
        _lastViolationTimes = {}
    }, ViolationManager)
    
    return self
end

function ViolationManager:HandleViolation(player, detectorType, evidence)
    -- Skip whitelisted players
    if WhitelistService:IsWhitelisted(player) then
        EvidenceLogger:Log(player, "WhitelistBypass", {
            detector = detectorType,
            evidence = evidence
        })
        return
    end
    
    -- Initialize player violation record if needed
    if not self._playerViolations[player] then
        self._playerViolations[player] = {
            totalCount = 0,
            detectors = {},
            firstViolation = os.time()
        }
    end
    
    local playerRecord = self._playerViolations[player]
    
    -- Update violation counts
    playerRecord.totalCount = playerRecord.totalCount + 1
    playerRecord.detectors[detectorType] = (playerRecord.detectors[detectorType] or 0) + 1
    
    -- Log evidence
    EvidenceLogger:Log(player, detectorType, evidence)
    
    -- Determine punishment tier
    local punishmentTier = PunishmentTiers:DetermineTier(
        playerRecord.totalCount,
        detectorType,
        os.time() - playerRecord.firstViolation
    )
    
    -- Apply punishment if needed
    if punishmentTier then
        self:ApplyPunishment(player, punishmentTier, {
            detector = detectorType,
            violationCount = playerRecord.totalCount,
            recentViolations = self:_getRecentViolations(player)
        })
    end
    
    -- Update last violation time for cooldown tracking
    self._lastViolationTimes[player] = os.time()
end

function ViolationManager:ApplyPunishment(player, tier, context)
    -- Skip if already punished at this tier or higher
    if self._activePunishments[player] and self._activePunishments[player] >= tier.level then
        return
    end
    
    -- Execute punishment action
    local success, err = pcall(function()
        tier.action(player, context)
    end)
    
    if success then
        self._activePunishments[player] = tier.level
        EvidenceLogger:Log(player, "PunishmentApplied", {
            tier = tier.name,
            level = tier.level,
            context = context
        })
    else
        warn("[ViolationSystem] Failed to apply punishment: " .. err)
    end
end

function ViolationManager:_getRecentViolations(player)
    return self._playerViolations[player] and self._playerViolations[player].totalCount or 0
end

return ViolationManager
