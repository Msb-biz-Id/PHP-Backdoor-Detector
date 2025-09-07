--// Anti-Cheat Server System v3.0
--// Auto Detection & Kick System
--// Comprehensive Cheat Protection
--// Server-Side Only

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")

-- Configuration
local ANTI_CHEAT_CONFIG = {
    -- Detection Settings
    MAX_SPEED = 50,                    -- Maximum allowed speed (studs/second)
    MAX_JUMP_POWER = 100,              -- Maximum jump power
    MAX_HEALTH = 200,                  -- Maximum health
    MAX_WALKSPEED = 30,                -- Maximum walkspeed
    FLY_DETECTION_HEIGHT = 20,         -- Height threshold for fly detection
    TELEPORT_DISTANCE = 100,           -- Maximum teleport distance
    NOCLIP_DETECTION = true,           -- Enable noclip detection
    
    -- Timing Settings
    CHECK_INTERVAL = 0.1,              -- How often to check (seconds)
    VIOLATION_COOLDOWN = 5,            -- Cooldown between violations
    KICK_DELAY = 2,                    -- Delay before kicking
    
    -- Violation Limits
    MAX_VIOLATIONS = 3,                -- Max violations before kick
    VIOLATION_RESET_TIME = 60,         -- Time to reset violations (seconds)
    
    -- Logging
    LOG_VIOLATIONS = true,             -- Log violations to console
    LOG_TO_DISCORD = false,            -- Log to Discord webhook
    DISCORD_WEBHOOK = "",              -- Discord webhook URL
    
    -- Whitelist
    ENABLE_WHITELIST = true,           -- Enable whitelist system
    WHITELIST_IDS = {                  -- Whitelisted user IDs
        -- Add trusted user IDs here
    },
    
    -- Auto Ban System
    ENABLE_AUTO_BAN = false,           -- Enable automatic banning
    BAN_DURATION = 24,                 -- Ban duration in hours
    BAN_REASON = "Cheating detected by Anti-Cheat System"
}

-- Data Storage
local playerData = {}
local violationLogs = {}
local bannedPlayers = {}

-- Load banned players from DataStore
local bannedDataStore = DataStoreService:GetDataStore("AntiCheat_BannedPlayers")

-- Load banned players on startup
task.spawn(function()
    local success, data = pcall(function()
        return bannedDataStore:GetAsync("banned_list") or {}
    end)
    
    if success and data then
        bannedPlayers = data
        print("[AntiCheat] Loaded " .. #bannedPlayers .. " banned players")
    end
end)

-- Violation Types
local VIOLATION_TYPES = {
    SPEED_HACK = "Speed Hack",
    FLY_HACK = "Fly Hack", 
    TELEPORT_HACK = "Teleport Hack",
    NOCLIP_HACK = "Noclip Hack",
    JUMP_HACK = "Jump Power Hack",
    HEALTH_HACK = "Health Hack",
    WALKSPEED_HACK = "Walkspeed Hack",
    SCRIPT_INJECTION = "Script Injection",
    REMOTE_EXPLOIT = "Remote Exploit",
    ANTI_AFK = "Anti-AFK"
}

-- Player Data Structure
local function createPlayerData(player)
    playerData[player.UserId] = {
        lastPosition = Vector3.new(0, 0, 0),
        lastCheck = tick(),
        violations = {},
        violationCount = 0,
        lastViolation = 0,
        isWhitelisted = false,
        lastMovement = tick(),
        suspiciousActivity = 0,
        kickPending = false
    }
end

-- Check if player is whitelisted
local function isWhitelisted(player)
    if not ANTI_CHEAT_CONFIG.ENABLE_WHITELIST then
        return false
    end
    
    for _, whitelistId in ipairs(ANTI_CHEAT_CONFIG.WHITELIST_IDS) do
        if player.UserId == whitelistId then
            return true
        end
    end
    
    return false
end

-- Log violation
local function logViolation(player, violationType, details)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logEntry = {
        player = player.Name,
        userId = player.UserId,
        violation = violationType,
        details = details,
        timestamp = timestamp,
        server = game.JobId
    }
    
    -- Add to violation logs
    table.insert(violationLogs, logEntry)
    
    -- Console logging
    if ANTI_CHEAT_CONFIG.LOG_VIOLATIONS then
        print(string.format("[AntiCheat] %s - %s (%d): %s - %s", 
            timestamp, player.Name, player.UserId, violationType, details))
    end
    
    -- Discord logging
    if ANTI_CHEAT_CONFIG.LOG_TO_DISCORD and ANTI_CHEAT_CONFIG.DISCORD_WEBHOOK ~= "" then
        task.spawn(function()
            local success, response = pcall(function()
                return HttpService:PostAsync(ANTI_CHEAT_CONFIG.DISCORD_WEBHOOK, HttpService:JSONEncode({
                    content = string.format("🚨 **Anti-Cheat Alert**\n**Player:** %s (%d)\n**Violation:** %s\n**Details:** %s\n**Server:** %s\n**Time:** %s", 
                        player.Name, player.UserId, violationType, details, game.JobId, timestamp)
                }), Enum.HttpContentType.ApplicationJson)
            end)
            
            if not success then
                warn("[AntiCheat] Failed to send Discord notification: " .. tostring(response))
            end
        end)
    end
end

-- Add violation to player
local function addViolation(player, violationType, details)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Check cooldown
    if tick() - data.lastViolation < ANTI_CHEAT_CONFIG.VIOLATION_COOLDOWN then
        return
    end
    
    data.lastViolation = tick()
    data.violationCount = data.violationCount + 1
    data.suspiciousActivity = data.suspiciousActivity + 1
    
    -- Add violation to list
    table.insert(data.violations, {
        type = violationType,
        details = details,
        timestamp = tick()
    })
    
    -- Log violation
    logViolation(player, violationType, details)
    
    -- Check if should kick
    if data.violationCount >= ANTI_CHEAT_CONFIG.MAX_VIOLATIONS then
        kickPlayer(player, "Multiple violations detected")
    end
end

-- Kick player
local function kickPlayer(player, reason)
    local data = playerData[player.UserId]
    if not data or data.kickPending then return end
    
    data.kickPending = true
    
    -- Log kick
    logViolation(player, "KICK", reason)
    
    -- Auto ban if enabled
    if ANTI_CHEAT_CONFIG.ENABLE_AUTO_BAN then
        banPlayer(player, ANTI_CHEAT_CONFIG.BAN_DURATION, ANTI_CHEAT_CONFIG.BAN_REASON)
    end
    
    -- Kick after delay
    task.wait(ANTI_CHEAT_CONFIG.KICK_DELAY)
    
    if player.Parent then
        player:Kick(string.format("Anti-Cheat: %s", reason))
    end
end

-- Ban player
local function banPlayer(player, duration, reason)
    local banData = {
        userId = player.UserId,
        username = player.Name,
        reason = reason,
        duration = duration,
        bannedAt = tick(),
        bannedBy = "Anti-Cheat System"
    }
    
    -- Add to banned list
    table.insert(bannedPlayers, banData)
    
    -- Save to DataStore
    task.spawn(function()
        local success, error = pcall(function()
            bannedDataStore:SetAsync("banned_list", bannedPlayers)
        end)
        
        if not success then
            warn("[AntiCheat] Failed to save ban data: " .. tostring(error))
        end
    end)
    
    logViolation(player, "BAN", string.format("Duration: %d hours, Reason: %s", duration, reason))
end

-- Check if player is banned
local function isPlayerBanned(player)
    for _, banData in ipairs(bannedPlayers) do
        if banData.userId == player.UserId then
            -- Check if ban is still active
            if tick() - banData.bannedAt < (banData.duration * 3600) then
                return true, banData
            end
        end
    end
    return false
end

-- Speed hack detection
local function checkSpeedHack(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    local data = playerData[player.UserId]
    if not data then return end
    
    local currentPosition = character.HumanoidRootPart.Position
    local distance = (currentPosition - data.lastPosition).Magnitude
    local timeDelta = tick() - data.lastCheck
    
    if timeDelta > 0 then
        local speed = distance / timeDelta
        
        if speed > ANTI_CHEAT_CONFIG.MAX_SPEED then
            addViolation(player, VIOLATION_TYPES.SPEED_HACK, 
                string.format("Speed: %.2f studs/sec (Max: %d)", speed, ANTI_CHEAT_CONFIG.MAX_SPEED))
        end
    end
    
    data.lastPosition = currentPosition
    data.lastCheck = tick()
end

-- Fly hack detection
local function checkFlyHack(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    local rootPart = character.HumanoidRootPart
    
    -- Check if player is above ground without jumping
    local raycast = workspace:Raycast(rootPart.Position, Vector3.new(0, -ANTI_CHEAT_CONFIG.FLY_DETECTION_HEIGHT, 0))
    
    if not raycast and humanoid.JumpPower <= ANTI_CHEAT_CONFIG.MAX_JUMP_POWER then
        -- Check if player has been in air for too long
        local data = playerData[player.UserId]
        if data then
            if not data.inAir then
                data.inAir = true
                data.airTime = tick()
            elseif tick() - data.airTime > 3 then -- 3 seconds in air
                addViolation(player, VIOLATION_TYPES.FLY_HACK, 
                    "Player in air for extended period without jumping")
            end
        end
    else
        local data = playerData[player.UserId]
        if data then
            data.inAir = false
        end
    end
end

-- Teleport hack detection
local function checkTeleportHack(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local data = playerData[player.UserId]
    if not data then return end
    
    local currentPosition = character.HumanoidRootPart.Position
    local distance = (currentPosition - data.lastPosition).Magnitude
    
    if distance > ANTI_CHEAT_CONFIG.TELEPORT_DISTANCE then
        addViolation(player, VIOLATION_TYPES.TELEPORT_HACK, 
            string.format("Teleported %.2f studs (Max: %d)", distance, ANTI_CHEAT_CONFIG.TELEPORT_DISTANCE))
    end
end

-- Noclip detection
local function checkNoclipHack(player)
    if not ANTI_CHEAT_CONFIG.NOCLIP_DETECTION then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local raycast = workspace:Raycast(rootPart.Position, rootPart.CFrame.LookVector * 5)
    
    -- Check if player is inside walls
    if raycast and raycast.Distance < 2 then
        local data = playerData[player.UserId]
        if data then
            if not data.insideWall then
                data.insideWall = true
                data.wallTime = tick()
            elseif tick() - data.wallTime > 2 then -- 2 seconds inside wall
                addViolation(player, VIOLATION_TYPES.NOCLIP_HACK, 
                    "Player detected inside walls")
            end
        end
    else
        local data = playerData[player.UserId]
        if data then
            data.insideWall = false
        end
    end
end

-- Jump power hack detection
local function checkJumpHack(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    
    if humanoid.JumpPower > ANTI_CHEAT_CONFIG.MAX_JUMP_POWER then
        addViolation(player, VIOLATION_TYPES.JUMP_HACK, 
            string.format("Jump Power: %.2f (Max: %d)", humanoid.JumpPower, ANTI_CHEAT_CONFIG.MAX_JUMP_POWER))
    end
end

-- Health hack detection
local function checkHealthHack(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    
    if humanoid.MaxHealth > ANTI_CHEAT_CONFIG.MAX_HEALTH then
        addViolation(player, VIOLATION_TYPES.HEALTH_HACK, 
            string.format("Max Health: %.2f (Max: %d)", humanoid.MaxHealth, ANTI_CHEAT_CONFIG.MAX_HEALTH))
    end
end

-- Walkspeed hack detection
local function checkWalkspeedHack(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    
    if humanoid.WalkSpeed > ANTI_CHEAT_CONFIG.MAX_WALKSPEED then
        addViolation(player, VIOLATION_TYPES.WALKSPEED_HACK, 
            string.format("WalkSpeed: %.2f (Max: %d)", humanoid.WalkSpeed, ANTI_CHEAT_CONFIG.MAX_WALKSPEED))
    end
end

-- Script injection detection
local function checkScriptInjection(player)
    -- Check for suspicious scripts in player's character
    local character = player.Character
    if not character then return end
    
    local suspiciousScripts = character:GetDescendants()
    for _, script in ipairs(suspiciousScripts) do
        if script:IsA("LocalScript") and script.Name ~= "Animate" and script.Name ~= "Health" then
            addViolation(player, VIOLATION_TYPES.SCRIPT_INJECTION, 
                "Suspicious script found: " .. script.Name)
        end
    end
end

-- Remote exploit detection
local function checkRemoteExploits(player)
    -- This would require setting up remote events to monitor
    -- For now, we'll just log that this check exists
    local data = playerData[player.UserId]
    if data and data.suspiciousActivity > 5 then
        addViolation(player, VIOLATION_TYPES.REMOTE_EXPLOIT, 
            "High suspicious activity detected")
    end
end

-- Anti-AFK detection
local function checkAntiAFK(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        
        -- Check if player is moving (not AFK)
        if humanoid.MoveDirection.Magnitude > 0 then
            data.lastMovement = tick()
        end
        
        -- Check for suspicious movement patterns
        if tick() - data.lastMovement > 300 then -- 5 minutes no movement
            -- Player might be using anti-AFK
            addViolation(player, VIOLATION_TYPES.ANTI_AFK, 
                "Player appears to be using anti-AFK")
        end
    end
end

-- Main detection loop
local function runDetectionLoop()
    for _, player in ipairs(Players:GetPlayers()) do
        -- Skip if whitelisted
        if isWhitelisted(player) then
            local data = playerData[player.UserId]
            if data then
                data.isWhitelisted = true
            end
            continue
        end
        
        -- Check if banned
        local isBanned, banData = isPlayerBanned(player)
        if isBanned then
            player:Kick(string.format("You are banned. Reason: %s. Duration: %d hours", 
                banData.reason, banData.duration))
            continue
        end
        
        -- Run all detection checks
        checkSpeedHack(player)
        checkFlyHack(player)
        checkTeleportHack(player)
        checkNoclipHack(player)
        checkJumpHack(player)
        checkHealthHack(player)
        checkWalkspeedHack(player)
        checkScriptInjection(player)
        checkRemoteExploits(player)
        checkAntiAFK(player)
    end
end

-- Player joining
Players.PlayerAdded:Connect(function(player)
    -- Check if banned
    local isBanned, banData = isPlayerBanned(player)
    if isBanned then
        player:Kick(string.format("You are banned. Reason: %s. Duration: %d hours", 
            banData.reason, banData.duration))
        return
    end
    
    -- Create player data
    createPlayerData(player)
    
    -- Wait for character
    player.CharacterAdded:Connect(function(character)
        local data = playerData[player.UserId]
        if data then
            data.lastPosition = character.HumanoidRootPart.Position
            data.lastCheck = tick()
        end
    end)
    
    print("[AntiCheat] Player joined: " .. player.Name .. " (" .. player.UserId .. ")")
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
    -- Clean up player data
    playerData[player.UserId] = nil
    
    print("[AntiCheat] Player left: " .. player.Name .. " (" .. player.UserId .. ")")
end)

-- Violation reset loop
task.spawn(function()
    while true do
        task.wait(ANTI_CHEAT_CONFIG.VIOLATION_RESET_TIME)
        
        for userId, data in pairs(playerData) do
            if tick() - data.lastViolation > ANTI_CHEAT_CONFIG.VIOLATION_RESET_TIME then
                data.violationCount = 0
                data.suspiciousActivity = 0
            end
        end
    end
end)

-- Start detection loop
task.spawn(function()
    while true do
        runDetectionLoop()
        task.wait(ANTI_CHEAT_CONFIG.CHECK_INTERVAL)
    end
end)

-- Admin commands (optional)
local function processAdminCommand(player, command, args)
    if not isWhitelisted(player) then return end
    
    if command == "kick" and args[1] then
        local targetPlayer = Players:FindFirstChild(args[1])
        if targetPlayer then
            kickPlayer(targetPlayer, "Kicked by admin: " .. player.Name)
        end
    elseif command == "ban" and args[1] and args[2] then
        local targetPlayer = Players:FindFirstChild(args[1])
        local duration = tonumber(args[2])
        if targetPlayer and duration then
            banPlayer(targetPlayer, duration, "Banned by admin: " .. player.Name)
        end
    elseif command == "violations" and args[1] then
        local targetPlayer = Players:FindFirstChild(args[1])
        if targetPlayer and playerData[targetPlayer.UserId] then
            local data = playerData[targetPlayer.UserId]
            print(string.format("[AntiCheat] Violations for %s: %d", targetPlayer.Name, data.violationCount))
        end
    end
end

-- Chat command processing
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        local args = string.split(message, " ")
        local command = args[1]:lower()
        
        if command:sub(1, 1) == "/" then
            processAdminCommand(player, command:sub(2), {table.unpack(args, 2)})
        end
    end)
end)

-- Initialize system
print("[AntiCheat] Anti-Cheat System v3.0 initialized")
print("[AntiCheat] Detection interval: " .. ANTI_CHEAT_CONFIG.CHECK_INTERVAL .. " seconds")
print("[AntiCheat] Max violations before kick: " .. ANTI_CHEAT_CONFIG.MAX_VIOLATIONS)
print("[AntiCheat] Whitelist enabled: " .. tostring(ANTI_CHEAT_CONFIG.ENABLE_WHITELIST))
print("[AntiCheat] Auto-ban enabled: " .. tostring(ANTI_CHEAT_CONFIG.ENABLE_AUTO_BAN))

-- Export functions for external use
_G.AntiCheat = {
    kickPlayer = kickPlayer,
    banPlayer = banPlayer,
    addViolation = addViolation,
    isWhitelisted = isWhitelisted,
    getPlayerData = function(player) return playerData[player.UserId] end,
    getViolationLogs = function() return violationLogs end,
    getBannedPlayers = function() return bannedPlayers end
}