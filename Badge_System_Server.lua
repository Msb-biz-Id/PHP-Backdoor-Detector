--// Badge System Server v2.0
--// Automatic Badge Awarding System
--// Server-Side Badge Management

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Configuration
local BADGE_CONFIG = {
    -- Badge Settings
    ENABLE_BADGES = true,                    -- Enable badge system
    AUTO_AWARD_WELCOME = true,               -- Auto award welcome badge
    AUTO_AWARD_MILESTONE = true,             -- Auto award milestone badges
    AUTO_AWARD_SPECIAL = true,               -- Auto award special badges
    
    -- Timing Settings
    BADGE_DELAY = 2,                         -- Delay before awarding badge (seconds)
    NOTIFICATION_DURATION = 5,               -- Badge notification duration
    CHECK_INTERVAL = 1,                      -- Check interval for conditions
    
    -- Badge Types
    WELCOME_BADGES = {
        "First_Join",                        -- First time joining
        "Welcome_Back",                      -- Returning player
        "Newcomer"                           -- New player
    },
    
    MILESTONE_BADGES = {
        {name = "Level_5", condition = "level", value = 5},
        {name = "Level_10", condition = "level", value = 10},
        {name = "Level_25", condition = "level", value = 25},
        {name = "Level_50", condition = "level", value = 50},
        {name = "Playtime_1H", condition = "playtime", value = 3600},      -- 1 hour
        {name = "Playtime_5H", condition = "playtime", value = 18000},     -- 5 hours
        {name = "Playtime_24H", condition = "playtime", value = 86400},    -- 24 hours
        {name = "Join_Count_10", condition = "joins", value = 10},
        {name = "Join_Count_50", condition = "joins", value = 50},
        {name = "Join_Count_100", condition = "joins", value = 100}
    },
    
    SPECIAL_BADGES = {
        {name = "VIP", condition = "vip", value = true},
        {name = "Admin", condition = "admin", value = true},
        {name = "Beta_Tester", condition = "beta", value = true},
        {name = "Early_Supporter", condition = "early", value = true}
    },
    
    -- Badge Data
    BADGE_DATA = {
        -- Welcome Badges
        ["First_Join"] = {
            name = "First Join",
            description = "Welcome to our server!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Common",
            color = Color3.fromRGB(100, 200, 100)
        },
        ["Welcome_Back"] = {
            name = "Welcome Back",
            description = "Thanks for returning!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Common",
            color = Color3.fromRGB(100, 150, 200)
        },
        ["Newcomer"] = {
            name = "Newcomer",
            description = "You're new here!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Common",
            color = Color3.fromRGB(200, 150, 100)
        },
        
        -- Milestone Badges
        ["Level_5"] = {
            name = "Level 5",
            description = "Reached level 5!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Uncommon",
            color = Color3.fromRGB(150, 200, 100)
        },
        ["Level_10"] = {
            name = "Level 10",
            description = "Reached level 10!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Uncommon",
            color = Color3.fromRGB(100, 200, 150)
        },
        ["Level_25"] = {
            name = "Level 25",
            description = "Reached level 25!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Rare",
            color = Color3.fromRGB(200, 100, 150)
        },
        ["Level_50"] = {
            name = "Level 50",
            description = "Reached level 50!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Epic",
            color = Color3.fromRGB(150, 100, 200)
        },
        ["Playtime_1H"] = {
            name = "1 Hour Player",
            description = "Played for 1 hour!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Uncommon",
            color = Color3.fromRGB(100, 150, 200)
        },
        ["Playtime_5H"] = {
            name = "5 Hour Player",
            description = "Played for 5 hours!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Rare",
            color = Color3.fromRGB(200, 150, 100)
        },
        ["Playtime_24H"] = {
            name = "24 Hour Player",
            description = "Played for 24 hours!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Epic",
            color = Color3.fromRGB(200, 100, 100)
        },
        ["Join_Count_10"] = {
            name = "Regular Visitor",
            description = "Joined 10 times!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Uncommon",
            color = Color3.fromRGB(150, 200, 150)
        },
        ["Join_Count_50"] = {
            name = "Frequent Visitor",
            description = "Joined 50 times!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Rare",
            color = Color3.fromRGB(200, 200, 100)
        },
        ["Join_Count_100"] = {
            name = "Loyal Player",
            description = "Joined 100 times!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Legendary",
            color = Color3.fromRGB(255, 215, 0)
        },
        
        -- Special Badges
        ["VIP"] = {
            name = "VIP Member",
            description = "You are a VIP!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Epic",
            color = Color3.fromRGB(255, 215, 0)
        },
        ["Admin"] = {
            name = "Administrator",
            description = "You are an admin!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Legendary",
            color = Color3.fromRGB(255, 100, 100)
        },
        ["Beta_Tester"] = {
            name = "Beta Tester",
            description = "Thanks for testing!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Rare",
            color = Color3.fromRGB(100, 255, 100)
        },
        ["Early_Supporter"] = {
            name = "Early Supporter",
            description = "Thanks for early support!",
            icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            rarity = "Epic",
            color = Color3.fromRGB(255, 150, 100)
        }
    }
}

-- Data Storage
local playerData = {}
local badgeDataStore = DataStoreService:GetDataStore("BadgeSystem_PlayerData")

-- Player Data Structure
local function createPlayerData(player)
    playerData[player.UserId] = {
        userId = player.UserId,
        username = player.Name,
        joinCount = 0,
        totalPlaytime = 0,
        level = 1,
        badges = {},
        lastJoin = tick(),
        firstJoin = tick(),
        isVip = false,
        isAdmin = false,
        isBeta = false,
        isEarly = false
    }
end

-- Load player data from DataStore
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

-- Save player data to DataStore
local function savePlayerData(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    local success, error = pcall(function()
        badgeDataStore:SetAsync(tostring(player.UserId), data)
    end)
    
    if not success then
        warn("[BadgeSystem] Failed to save data for " .. player.Name .. ": " .. tostring(error))
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

-- Award badge to player
local function awardBadge(player, badgeId, reason)
    if hasBadge(player, badgeId) then return false end
    
    local data = playerData[player.UserId]
    if not data then return false end
    
    local badgeInfo = BADGE_CONFIG.BADGE_DATA[badgeId]
    if not badgeInfo then return false end
    
    -- Add badge to player
    table.insert(data.badges, {
        id = badgeId,
        name = badgeInfo.name,
        description = badgeInfo.description,
        awardedAt = tick(),
        reason = reason or "Automatic award"
    })
    
    -- Save data
    savePlayerData(player)
    
    -- Send notification to client
    local remoteEvent = ReplicatedStorage:FindFirstChild("BadgeAwarded")
    if remoteEvent then
        remoteEvent:FireClient(player, {
            badgeId = badgeId,
            badgeInfo = badgeInfo,
            reason = reason
        })
    end
    
    -- Log badge award
    print(string.format("[BadgeSystem] %s (%d) earned badge: %s - %s", 
        player.Name, player.UserId, badgeInfo.name, reason or "Automatic award"))
    
    return true
end

-- Check welcome badges
local function checkWelcomeBadges(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- First Join Badge
    if data.joinCount == 1 then
        awardBadge(player, "First_Join", "First time joining the server")
    end
    
    -- Welcome Back Badge
    if data.joinCount > 1 then
        awardBadge(player, "Welcome_Back", "Returning player")
    end
    
    -- Newcomer Badge (less than 7 days since first join)
    if tick() - data.firstJoin < 604800 then -- 7 days
        awardBadge(player, "Newcomer", "New player")
    end
end

-- Check milestone badges
local function checkMilestoneBadges(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    for _, milestone in ipairs(BADGE_CONFIG.MILESTONE_BADGES) do
        local shouldAward = false
        local reason = ""
        
        if milestone.condition == "level" and data.level >= milestone.value then
            shouldAward = true
            reason = string.format("Reached level %d", milestone.value)
        elseif milestone.condition == "playtime" and data.totalPlaytime >= milestone.value then
            shouldAward = true
            reason = string.format("Played for %d seconds", milestone.value)
        elseif milestone.condition == "joins" and data.joinCount >= milestone.value then
            shouldAward = true
            reason = string.format("Joined %d times", milestone.value)
        end
        
        if shouldAward then
            awardBadge(player, milestone.name, reason)
        end
    end
end

-- Check special badges
local function checkSpecialBadges(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    for _, special in ipairs(BADGE_CONFIG.SPECIAL_BADGES) do
        local shouldAward = false
        local reason = ""
        
        if special.condition == "vip" and data.isVip then
            shouldAward = true
            reason = "VIP member"
        elseif special.condition == "admin" and data.isAdmin then
            shouldAward = true
            reason = "Administrator"
        elseif special.condition == "beta" and data.isBeta then
            shouldAward = true
            reason = "Beta tester"
        elseif special.condition == "early" and data.isEarly then
            shouldAward = true
            reason = "Early supporter"
        end
        
        if shouldAward then
            awardBadge(player, special.name, reason)
        end
    end
end

-- Update player level (example function)
local function updatePlayerLevel(player, newLevel)
    local data = playerData[player.UserId]
    if not data then return end
    
    data.level = newLevel
    savePlayerData(player)
    
    -- Check for level milestone badges
    checkMilestoneBadges(player)
end

-- Update player playtime (example function)
local function updatePlayerPlaytime(player, additionalTime)
    local data = playerData[player.UserId]
    if not data then return end
    
    data.totalPlaytime = data.totalPlaytime + additionalTime
    savePlayerData(player)
    
    -- Check for playtime milestone badges
    checkMilestoneBadges(player)
end

-- Set player special status
local function setPlayerSpecialStatus(player, status, value)
    local data = playerData[player.UserId]
    if not data then return end
    
    if status == "vip" then
        data.isVip = value
    elseif status == "admin" then
        data.isAdmin = value
    elseif status == "beta" then
        data.isBeta = value
    elseif status == "early" then
        data.isEarly = value
    end
    
    savePlayerData(player)
    
    -- Check for special badges
    checkSpecialBadges(player)
end

-- Create RemoteEvent for client communication
local function createRemoteEvents()
    local badgeAwarded = ReplicatedStorage:FindFirstChild("BadgeAwarded")
    if not badgeAwarded then
        badgeAwarded = Instance.new("RemoteEvent")
        badgeAwarded.Name = "BadgeAwarded"
        badgeAwarded.Parent = ReplicatedStorage
    end
    
    local badgeRequest = ReplicatedStorage:FindFirstChild("BadgeRequest")
    if not badgeRequest then
        badgeRequest = Instance.new("RemoteEvent")
        badgeRequest.Name = "BadgeRequest"
        badgeRequest.Parent = ReplicatedStorage
    end
    
    -- Handle badge requests from client
    badgeRequest.OnServerEvent:Connect(function(player, requestType, data)
        if requestType == "getBadges" then
            local playerData = playerData[player.UserId]
            if playerData then
                badgeRequest:FireClient(player, "badgeData", playerData.badges)
            end
        elseif requestType == "getStats" then
            local playerData = playerData[player.UserId]
            if playerData then
                badgeRequest:FireClient(player, "playerStats", {
                    joinCount = playerData.joinCount,
                    totalPlaytime = playerData.totalPlaytime,
                    level = playerData.level,
                    badgeCount = #playerData.badges
                })
            end
        end
    end)
end

-- Player joining
Players.PlayerAdded:Connect(function(player)
    -- Load player data
    loadPlayerData(player)
    
    -- Wait for character
    player.CharacterAdded:Connect(function(character)
        -- Wait a bit for character to load
        task.wait(BADGE_CONFIG.BADGE_DELAY)
        
        -- Check for badges
        if BADGE_CONFIG.ENABLE_BADGES then
            if BADGE_CONFIG.AUTO_AWARD_WELCOME then
                checkWelcomeBadges(player)
            end
            
            if BADGE_CONFIG.AUTO_AWARD_MILESTONE then
                checkMilestoneBadges(player)
            end
            
            if BADGE_CONFIG.AUTO_AWARD_SPECIAL then
                checkSpecialBadges(player)
            end
        end
    end)
    
    print("[BadgeSystem] Player joined: " .. player.Name .. " (Join #" .. playerData[player.UserId].joinCount .. ")")
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
    -- Save player data
    savePlayerData(player)
    
    print("[BadgeSystem] Player left: " .. player.Name)
end)

-- Playtime tracking
task.spawn(function()
    while true do
        task.wait(BADGE_CONFIG.CHECK_INTERVAL)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and playerData[player.UserId] then
                updatePlayerPlaytime(player, BADGE_CONFIG.CHECK_INTERVAL)
            end
        end
    end
end)

-- Create remote events
createRemoteEvents()

-- Export functions for external use
_G.BadgeSystem = {
    awardBadge = awardBadge,
    hasBadge = hasBadge,
    updatePlayerLevel = updatePlayerLevel,
    updatePlayerPlaytime = updatePlayerPlaytime,
    setPlayerSpecialStatus = setPlayerSpecialStatus,
    getPlayerData = function(player) return playerData[player.UserId] end,
    getBadgeData = function(badgeId) return BADGE_CONFIG.BADGE_DATA[badgeId] end
}

-- Initialize system
print("[BadgeSystem] Badge System v2.0 initialized")
print("[BadgeSystem] Auto award welcome: " .. tostring(BADGE_CONFIG.AUTO_AWARD_WELCOME))
print("[BadgeSystem] Auto award milestone: " .. tostring(BADGE_CONFIG.AUTO_AWARD_MILESTONE))
print("[BadgeSystem] Auto award special: " .. tostring(BADGE_CONFIG.AUTO_AWARD_SPECIAL))
print("[BadgeSystem] Badge delay: " .. BADGE_CONFIG.BADGE_DELAY .. " seconds")