--// Roblox Admin Message System - Server Script
--// Handles Discord webhook and admin messaging

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Configuration
local DISCORD_WEBHOOK_URL = "YOUR_DISCORD_WEBHOOK_URL_HERE" -- Replace with your webhook URL
local ADMIN_USER_ID = 123456789 -- Replace with admin's UserId
local WEBHOOK_ENABLED = true -- Set to false to disable Discord webhook

-- Variables
local messageHistory = {}
local adminPlayer = nil

-- Create RemoteEvents
local function createRemoteEvents()
    local folder = ReplicatedStorage:FindFirstChild("AdminMessageEvents")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "AdminMessageEvents"
        folder.Parent = ReplicatedStorage
    end
    
    local events = {}
    local eventNames = {"SendMessageToAdmin", "SendToDiscord", "GetMessageHistory"}
    
    for _, name in ipairs(eventNames) do
        local event = folder:FindFirstChild(name)
        if not event then
            event = Instance.new("RemoteEvent")
            event.Name = name
            event.Parent = folder
        end
        events[name] = event
    end
    
    return events
end

-- Get RemoteEvents
local events = createRemoteEvents()

-- Find admin player
local function findAdminPlayer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.UserId == ADMIN_USER_ID then
            adminPlayer = player
            return player
        end
    end
    return nil
end

-- Send message to Discord webhook
local function sendToDiscordWebhook(message, playerName, playerId)
    if not WEBHOOK_ENABLED or DISCORD_WEBHOOK_URL == "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        return false, "Discord webhook not configured"
    end
    
    local success, result = pcall(function()
        local webhookData = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "📨 Admin Message",
                ["description"] = message,
                ["color"] = 3447003, -- Blue color
                ["fields"] = {
                    {
                        ["name"] = "👤 Player",
                        ["value"] = playerName .. " (ID: " .. playerId .. ")",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🎮 Game",
                        ["value"] = game.Name,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🕐 Time",
                        ["value"] = os.date("%Y-%m-%d %H:%M:%S"),
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = "Roblox Admin Message System"
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
        local jsonData = HttpService:JSONEncode(webhookData)
        local response = HttpService:PostAsync(DISCORD_WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
        
        return response
    end)
    
    if success then
        print("✅ Discord webhook sent successfully")
        return true, "Message sent to Discord"
    else
        print("❌ Discord webhook failed: " .. tostring(result))
        return false, "Failed to send to Discord: " .. tostring(result)
    end
end

-- Send message to admin player
local function sendToAdminPlayer(message, playerName, playerId)
    local admin = findAdminPlayer()
    if not admin then
        return false, "Admin not found in game"
    end
    
    local success, result = pcall(function()
        -- Create admin notification GUI
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AdminNotification"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = admin:WaitForChild("PlayerGui")
        
        -- Main frame
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 400, 0, 200)
        mainFrame.Position = UDim2.new(0.5, -200, 0, 50)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        -- Corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = mainFrame
        
        -- Title
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -20, 0, 40)
        title.Position = UDim2.new(0, 10, 0, 10)
        title.BackgroundTransparency = 1
        title.Text = "📨 New Admin Message"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextScaled = true
        title.Font = Enum.Font.GothamBold
        title.Parent = mainFrame
        
        -- Player info
        local playerInfo = Instance.new("TextLabel")
        playerInfo.Name = "PlayerInfo"
        playerInfo.Size = UDim2.new(1, -20, 0, 25)
        playerInfo.Position = UDim2.new(0, 10, 0, 50)
        playerInfo.BackgroundTransparency = 1
        playerInfo.Text = "From: " .. playerName .. " (ID: " .. playerId .. ")"
        playerInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        playerInfo.TextScaled = true
        playerInfo.Font = Enum.Font.Gotham
        playerInfo.Parent = mainFrame
        
        -- Message
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Name = "Message"
        messageLabel.Size = UDim2.new(1, -20, 0, 80)
        messageLabel.Position = UDim2.new(0, 10, 0, 80)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = message
        messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        messageLabel.TextScaled = true
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextWrapped = true
        messageLabel.Parent = mainFrame
        
        -- Close button
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0, 100, 0, 30)
        closeButton.Position = UDim2.new(0.5, -50, 1, -40)
        closeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        closeButton.BorderSizePixel = 0
        closeButton.Text = "Close"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextScaled = true
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = mainFrame
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 8)
        closeCorner.Parent = closeButton
        
        -- Close button functionality
        closeButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)
        
        -- Auto close after 30 seconds
        task.wait(30)
        if screenGui.Parent then
            screenGui:Destroy()
        end
        
        return true
    end)
    
    if success then
        print("✅ Admin notification sent to: " .. admin.Name)
        return true, "Message sent to admin"
    else
        print("❌ Failed to send admin notification: " .. tostring(result))
        return false, "Failed to send to admin: " .. tostring(result)
    end
end

-- Handle remote events
events.SendMessageToAdmin.OnServerEvent:Connect(function(player, message, playerName, playerId)
    print("📨 Admin message from " .. playerName .. ": " .. message)
    
    -- Add to history
    table.insert(messageHistory, {
        message = message,
        playerName = playerName,
        playerId = playerId,
        timestamp = os.time(),
        type = "admin"
    })
    
    -- Send to admin player
    local success, result = sendToAdminPlayer(message, playerName, playerId)
    
    -- Send response back to client
    events.SendMessageToAdmin:FireClient(player, success, result)
end)

events.SendToDiscord.OnServerEvent:Connect(function(player, message, playerName, playerId)
    print("💬 Discord message from " .. playerName .. ": " .. message)
    
    -- Add to history
    table.insert(messageHistory, {
        message = message,
        playerName = playerName,
        playerId = playerId,
        timestamp = os.time(),
        type = "discord"
    })
    
    -- Send to Discord webhook
    local success, result = sendToDiscordWebhook(message, playerName, playerId)
    
    -- Send response back to client
    events.SendToDiscord:FireClient(player, success, result)
end)

events.GetMessageHistory.OnServerEvent:Connect(function(player)
    -- Only admin can get message history
    if player.UserId == ADMIN_USER_ID then
        events.GetMessageHistory:FireClient(player, messageHistory)
    end
end)

-- Player added event
Players.PlayerAdded:Connect(function(player)
    if player.UserId == ADMIN_USER_ID then
        adminPlayer = player
        print("👑 Admin joined: " .. player.Name)
    end
end)

-- Player removing event
Players.PlayerRemoving:Connect(function(player)
    if player.UserId == ADMIN_USER_ID then
        adminPlayer = nil
        print("👑 Admin left: " .. player.Name)
    end
end)

-- Initialize
print("📨 Admin Message System - Server loaded!")
print("Configuration:")
print("  Discord Webhook: " .. (WEBHOOK_ENABLED and "Enabled" or "Disabled"))
print("  Admin User ID: " .. ADMIN_USER_ID)
print("  Webhook URL: " .. (DISCORD_WEBHOOK_URL ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and "Configured" or "Not configured"))

-- Check if admin is already in game
findAdminPlayer()
if adminPlayer then
    print("👑 Admin found: " .. adminPlayer.Name)
end