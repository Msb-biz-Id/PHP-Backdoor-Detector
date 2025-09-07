--// Simple Badge System v1.0
--// Easy Setup - Auto Award Badges
--// Server-Side Only

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Simple Configuration
local BADGE_CONFIG = {
    ENABLE_BADGES = true,                    -- Enable badge system
    BADGE_DELAY = 3,                        -- Delay before awarding (seconds)
    AUTO_WELCOME = true,                    -- Auto award welcome badges
    AUTO_MILESTONE = true,                  -- Auto award milestone badges
    
    -- Badge Types
    BADGES = {
        -- Welcome Badges
        ["First_Join"] = {
            name = "First Join",
            description = "Welcome to our server!",
            color = Color3.fromRGB(100, 200, 100),
            rarity = "Common"
        },
        ["Welcome_Back"] = {
            name = "Welcome Back", 
            description = "Thanks for returning!",
            color = Color3.fromRGB(100, 150, 200),
            rarity = "Common"
        },
        
        -- Milestone Badges
        ["Level_5"] = {
            name = "Level 5",
            description = "Reached level 5!",
            color = Color3.fromRGB(150, 200, 100),
            rarity = "Uncommon"
        },
        ["Level_10"] = {
            name = "Level 10",
            description = "Reached level 10!",
            color = Color3.fromRGB(100, 200, 150),
            rarity = "Uncommon"
        },
        ["Playtime_1H"] = {
            name = "1 Hour Player",
            description = "Played for 1 hour!",
            color = Color3.fromRGB(100, 150, 200),
            rarity = "Uncommon"
        },
        ["Join_Count_10"] = {
            name = "Regular Visitor",
            description = "Joined 10 times!",
            color = Color3.fromRGB(150, 200, 150),
            rarity = "Uncommon"
        }
    }
}

-- Data Storage
local playerData = {}
local badgeDataStore = DataStoreService:GetDataStore("SimpleBadgeSystem")

-- Create player data
local function createPlayerData(player)
    playerData[player.UserId] = {
        userId = player.UserId,
        username = player.Name,
        joinCount = 0,
        totalPlaytime = 0,
        level = 1,
        badges = {},
        lastJoin = tick(),
        firstJoin = tick()
    }
end

-- Load player data
local function loadPlayerData(player)
    local success, data = pcall(function()
        return badgeDataStore:GetAsync(tostring(player.UserId))
    end)
    
    if success and data then
        playerData[player.UserId] = data
        playerData[player.UserId].lastJoin = tick()
        playerData[player.UserId].joinCount = (playerData[player.UserId].joinCount or 0) + 1
    else
        createPlayerData(player)
        playerData[player.UserId].firstJoin = tick()
        playerData[player.UserId].joinCount = 1
    end
end

-- Save player data
local function savePlayerData(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    local success, error = pcall(function()
        badgeDataStore:SetAsync(tostring(player.UserId), data)
    end)
    
    if not success then
        warn("[SimpleBadge] Failed to save data: " .. tostring(error))
    end
end

-- Check if player has badge
local function hasBadge(player, badgeId)
    local data = playerData[player.UserId]
    if not data then return false end
    
    for _, badge in ipairs(data.badges) do
        if badge.id == badgeId then
            return true
        end
    end
    
    return false
end

-- Award badge
local function awardBadge(player, badgeId, reason)
    if hasBadge(player, badgeId) then return false end
    
    local data = playerData[player.UserId]
    if not data then return false end
    
    local badgeInfo = BADGE_CONFIG.BADGES[badgeId]
    if not badgeInfo then return false end
    
    -- Add badge
    table.insert(data.badges, {
        id = badgeId,
        name = badgeInfo.name,
        description = badgeInfo.description,
        awardedAt = tick(),
        reason = reason or "Automatic award"
    })
    
    -- Save data
    savePlayerData(player)
    
    -- Log
    print(string.format("[SimpleBadge] %s (%d) earned: %s - %s", 
        player.Name, player.UserId, badgeInfo.name, reason or "Automatic award"))
    
    return true
end

-- Check welcome badges
local function checkWelcomeBadges(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- First Join
    if data.joinCount == 1 then
        awardBadge(player, "First_Join", "First time joining")
    end
    
    -- Welcome Back
    if data.joinCount > 1 then
        awardBadge(player, "Welcome_Back", "Returning player")
    end
end

-- Check milestone badges
local function checkMilestoneBadges(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Level badges
    if data.level >= 5 then
        awardBadge(player, "Level_5", "Reached level 5")
    end
    
    if data.level >= 10 then
        awardBadge(player, "Level_10", "Reached level 10")
    end
    
    -- Playtime badges
    if data.totalPlaytime >= 3600 then -- 1 hour
        awardBadge(player, "Playtime_1H", "Played for 1 hour")
    end
    
    -- Join count badges
    if data.joinCount >= 10 then
        awardBadge(player, "Join_Count_10", "Joined 10 times")
    end
end

-- Update player level (example)
local function updatePlayerLevel(player, newLevel)
    local data = playerData[player.UserId]
    if not data then return end
    
    data.level = newLevel
    savePlayerData(player)
    checkMilestoneBadges(player)
end

-- Update playtime (example)
local function updatePlayerPlaytime(player, additionalTime)
    local data = playerData[player.UserId]
    if not data then return end
    
    data.totalPlaytime = data.totalPlaytime + additionalTime
    savePlayerData(player)
    checkMilestoneBadges(player)
end

-- Player joining
Players.PlayerAdded:Connect(function(player)
    loadPlayerData(player)
    
    player.CharacterAdded:Connect(function(character)
        task.wait(BADGE_CONFIG.BADGE_DELAY)
        
        if BADGE_CONFIG.ENABLE_BADGES then
            if BADGE_CONFIG.AUTO_WELCOME then
                checkWelcomeBadges(player)
            end
            
            if BADGE_CONFIG.AUTO_MILESTONE then
                checkMilestoneBadges(player)
            end
        end
    end)
    
    print("[SimpleBadge] Player joined: " .. player.Name .. " (Join #" .. playerData[player.UserId].joinCount .. ")")
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
    savePlayerData(player)
    print("[SimpleBadge] Player left: " .. player.Name)
end)

-- Playtime tracking
task.spawn(function()
    while true do
        task.wait(1)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and playerData[player.UserId] then
                updatePlayerPlaytime(player, 1)
            end
        end
    end
end)

-- Export functions
_G.SimpleBadge = {
    awardBadge = awardBadge,
    hasBadge = hasBadge,
    updatePlayerLevel = updatePlayerLevel,
    updatePlayerPlaytime = updatePlayerPlaytime,
    getPlayerData = function(player) return playerData[player.UserId] end
}

print("[SimpleBadge] Simple Badge System loaded!")
print("[SimpleBadge] Auto welcome: " .. tostring(BADGE_CONFIG.AUTO_WELCOME))
print("[SimpleBadge] Auto milestone: " .. tostring(BADGE_CONFIG.AUTO_MILESTONE))