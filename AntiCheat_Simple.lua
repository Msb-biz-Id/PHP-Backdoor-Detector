--// Simple Anti-Cheat System v1.0
--// Easy Setup - Auto Kick Cheaters
--// Server-Side Only

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Simple Configuration
local CONFIG = {
    MAX_SPEED = 50,                 -- Maximum speed
    MAX_JUMP = 100,                 -- Maximum jump power
    MAX_HEALTH = 200,               -- Maximum health
    MAX_WALKSPEED = 30,             -- Maximum walkspeed
    CHECK_INTERVAL = 0.2,           -- Check every 200ms
    MAX_VIOLATIONS = 3,             -- Max violations before kick
    KICK_DELAY = 2                  -- Delay before kick
}

-- Player data storage
local playerData = {}

-- Create player data
local function createPlayerData(player)
    playerData[player.UserId] = {
        violations = 0,
        lastPosition = Vector3.new(0, 0, 0),
        lastCheck = tick()
    }
end

-- Add violation
local function addViolation(player, reason)
    local data = playerData[player.UserId]
    if not data then return end
    
    data.violations = data.violations + 1
    
    print(string.format("[AntiCheat] %s (%d): %s (Violations: %d/%d)", 
        player.Name, player.UserId, reason, data.violations, CONFIG.MAX_VIOLATIONS))
    
    if data.violations >= CONFIG.MAX_VIOLATIONS then
        task.wait(CONFIG.KICK_DELAY)
        player:Kick("Anti-Cheat: " .. reason)
    end
end

-- Check speed hack
local function checkSpeed(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local data = playerData[player.UserId]
    if not data then return end
    
    local currentPos = character.HumanoidRootPart.Position
    local distance = (currentPos - data.lastPosition).Magnitude
    local timeDelta = tick() - data.lastCheck
    
    if timeDelta > 0 then
        local speed = distance / timeDelta
        
        if speed > CONFIG.MAX_SPEED then
            addViolation(player, string.format("Speed Hack (%.1f studs/sec)", speed))
        end
    end
    
    data.lastPosition = currentPos
    data.lastCheck = tick()
end

-- Check stat hacks
local function checkStats(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    
    -- Check jump power
    if humanoid.JumpPower > CONFIG.MAX_JUMP then
        addViolation(player, string.format("Jump Hack (%.1f)", humanoid.JumpPower))
    end
    
    -- Check health
    if humanoid.MaxHealth > CONFIG.MAX_HEALTH then
        addViolation(player, string.format("Health Hack (%.1f)", humanoid.MaxHealth))
    end
    
    -- Check walkspeed
    if humanoid.WalkSpeed > CONFIG.MAX_WALKSPEED then
        addViolation(player, string.format("WalkSpeed Hack (%.1f)", humanoid.WalkSpeed))
    end
end

-- Check fly hack
local function checkFly(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local raycast = workspace:Raycast(rootPart.Position, Vector3.new(0, -20, 0))
    
    -- If no ground below and not jumping
    if not raycast and character.Humanoid.JumpPower <= CONFIG.MAX_JUMP then
        local data = playerData[player.UserId]
        if data then
            if not data.inAir then
                data.inAir = true
                data.airTime = tick()
            elseif tick() - data.airTime > 3 then
                addViolation(player, "Fly Hack")
            end
        end
    else
        local data = playerData[player.UserId]
        if data then
            data.inAir = false
        end
    end
end

-- Main detection loop
local function runChecks()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            checkSpeed(player)
            checkStats(player)
            checkFly(player)
        end
    end
end

-- Player joining
Players.PlayerAdded:Connect(function(player)
    createPlayerData(player)
    
    player.CharacterAdded:Connect(function(character)
        local data = playerData[player.UserId]
        if data and character:FindFirstChild("HumanoidRootPart") then
            data.lastPosition = character.HumanoidRootPart.Position
            data.lastCheck = tick()
        end
    end)
    
    print("[AntiCheat] Player joined: " .. player.Name)
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
    playerData[player.UserId] = nil
    print("[AntiCheat] Player left: " .. player.Name)
end)

-- Start detection
task.spawn(function()
    while true do
        runChecks()
        task.wait(CONFIG.CHECK_INTERVAL)
    end
end)

print("[AntiCheat] Simple Anti-Cheat System loaded!")
print("[AntiCheat] Max violations: " .. CONFIG.MAX_VIOLATIONS)
print("[AntiCheat] Check interval: " .. CONFIG.CHECK_INTERVAL .. " seconds")