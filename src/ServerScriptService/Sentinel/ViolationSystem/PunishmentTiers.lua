local PunishmentTiers = {}
PunishmentTiers.__index = PunishmentTiers

function PunishmentTiers.new()
    local self = setmetatable({
        Tiers = {
            {
                name = "Warning",
                level = 1,
                threshold = 1, -- Violations needed
                action = function(player, context)
                    local message = string.format(
                        "Anti-Cheat Warning: Suspicious activity detected (%s)",
                        context.detector
                    )
                    
                    -- Could use RemoteEvent to send to client UI
                    warn(string.format(
                        "[AC] Warning issued to %s (%d) for %s",
                        player.Name,
                        player.UserId,
                        context.detector
                    ))
                end
            },
            {
                name = "Kick",
                level = 2,
                threshold = 3, -- Violations needed
                action = function(player, context)
                    player:Kick(string.format(
                        "Anti-Cheat Violation: %d offenses detected",
                        context.violationCount
                    ))
                end
            },
            {
                name = "TempBan",
                level = 3,
                threshold = 5, -- Violations needed
                action = function(player, context)
                    -- Implement your temp ban system here
                    -- Example using DataStore:
                    local DataStoreService = game:GetService("DataStoreService")
                    local banStore = DataStoreService:GetDataStore("SentinelBans")
                    
                    local banDuration = 3600 -- 1 hour in seconds
                    banStore:SetAsync(
                        tostring(player.UserId),
                        {
                            until = os.time() + banDuration,
                            reason = "Multiple AC violations",
                            violations = context.violationCount
                        }
                    )
                    
                    player:Kick(string.format(
                        "Temporary Ban: %d minutes for cheating",
                        banDuration / 60
                    ))
                end
            },
            {
                name = "Permaban",
                level = 4,
                threshold = 10, -- Violations needed
                action = function(player, context)
                    -- Permanent ban implementation
                    -- Could write to your database or use DataStore
                    warn(string.format(
                        "[AC] PERMABAN issued to %s (%d)",
                        player.Name,
                        player.UserId
                    ))
                    
                    player:Kick("Permanently banned for cheating")
                end
            }
        }
    }, PunishmentTiers)
    
    return self
end

function PunishmentTiers:DetermineTier(violationCount, detectorType, timeSinceFirstViolation)
    -- Sort tiers by level (highest first)
    table.sort(self.Tiers, function(a, b)
        return a.level > b.level
    end)
    
    -- Find the highest applicable tier
    for _, tier in ipairs(self.Tiers) do
        if violationCount >= tier.threshold then
            -- Additional checks can go here (For example: certain detectors might trigger higher tiers)
            return tier
        end
    end
    
    return nil
end

return PunishmentTiers.new()
