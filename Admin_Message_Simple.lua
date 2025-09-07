--// Simple Admin Message System v1.0
--// Easy Setup - Discord Webhook
--// Server-Side Only

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Simple Configuration
local ADMIN_MESSAGE_CONFIG = {
    DISCORD_WEBHOOK_URL = "",  -- Add your Discord webhook URL here
    ENABLE_DISCORD_LOGS = true,
    
    -- Message Categories
    CATEGORIES = {
        "Bug Report",
        "Feature Request", 
        "Player Issue",
        "Server Problem",
        "General Question",
        "Complaint",
        "Suggestion",
        "Other"
    },
    
    -- Priority Levels
    PRIORITIES = {
        "Low",
        "Medium", 
        "High",
        "Urgent"
    },
    
    -- Settings
    MAX_MESSAGES_PER_PLAYER = 3,
    MESSAGE_COOLDOWN = 120,  -- 120 seconds
    MAX_MESSAGE_LENGTH = 500,
    MIN_MESSAGE_LENGTH = 10,
    
    -- Admin Settings
    ADMIN_USER_IDS = {  -- Add admin user IDs here
        -- Example: 123456789, 987654321
    }
}

-- Data Storage
local playerMessageCounts = {}

-- Send to Discord
local function sendToDiscord(sender, category, priority, message)
    if not ADMIN_MESSAGE_CONFIG.ENABLE_DISCORD_LOGS or ADMIN_MESSAGE_CONFIG.DISCORD_WEBHOOK_URL == "" then
        return false
    end
    
    -- Priority color mapping
    local priorityColors = {
        Low = 3447003,      -- Blue
        Medium = 16776960,  -- Yellow
        High = 16753920,    -- Orange
        Urgent = 16711680   -- Red
    }
    
    local embed = {
        {
            title = "📨 New Admin Message",
            color = priorityColors[priority] or 3447003,
            fields = {
                {
                    name = "👤 From",
                    value = sender.Name .. " (" .. sender.UserId .. ")",
                    inline = true
                },
                {
                    name = "📋 Category",
                    value = category,
                    inline = true
                },
                {
                    name = "⚡ Priority",
                    value = priority,
                    inline = true
                },
                {
                    name = "📝 Message",
                    value = message,
                    inline = false
                },
                {
                    name = "🕐 Time",
                    value = os.date("%Y-%m-%d %H:%M:%S"),
                    inline = true
                },
                {
                    name = "🆔 Server ID",
                    value = game.JobId,
                    inline = true
                }
            },
            footer = {
                text = "Simple Admin Message System v1.0"
            }
        }
    }
    
    local payload = {
        embeds = embed
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(ADMIN_MESSAGE_CONFIG.DISCORD_WEBHOOK_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("[SimpleAdminMessage] Failed to send to Discord: " .. tostring(response))
        return false
    end
    
    return true
end

-- Check if player is admin
local function isAdmin(player)
    for _, adminId in ipairs(ADMIN_MESSAGE_CONFIG.ADMIN_USER_IDS) do
        if player.UserId == adminId then
            return true
        end
    end
    return false
end

-- Process admin message
local function processAdminMessage(sender, category, priority, message)
    -- Check if sender exists
    if not sender then
        return false, "Invalid sender"
    end
    
    -- Check message length
    if #message < ADMIN_MESSAGE_CONFIG.MIN_MESSAGE_LENGTH then
        return false, "Message too short (minimum " .. ADMIN_MESSAGE_CONFIG.MIN_MESSAGE_LENGTH .. " characters)"
    end
    
    if #message > ADMIN_MESSAGE_CONFIG.MAX_MESSAGE_LENGTH then
        return false, "Message too long (maximum " .. ADMIN_MESSAGE_CONFIG.MAX_MESSAGE_LENGTH .. " characters)"
    end
    
    -- Check cooldown
    local senderData = playerMessageCounts[sender.UserId]
    if senderData and tick() - senderData.lastMessage < ADMIN_MESSAGE_CONFIG.MESSAGE_COOLDOWN then
        local remainingTime = math.ceil(ADMIN_MESSAGE_CONFIG.MESSAGE_COOLDOWN - (tick() - senderData.lastMessage))
        return false, "Please wait " .. remainingTime .. " seconds before sending another message"
    end
    
    -- Check max messages
    if senderData and senderData.count >= ADMIN_MESSAGE_CONFIG.MAX_MESSAGES_PER_PLAYER then
        return false, "You have reached the maximum number of messages"
    end
    
    -- Update sender count
    if not playerMessageCounts[sender.UserId] then
        playerMessageCounts[sender.UserId] = {count = 0, lastMessage = 0}
    end
    playerMessageCounts[sender.UserId].count = playerMessageCounts[sender.UserId].count + 1
    playerMessageCounts[sender.UserId].lastMessage = tick()
    
    -- Send to Discord
    sendToDiscord(sender, category, priority, message)
    
    -- Log to console
    print(string.format("[SimpleAdminMessage] Message: %s - %s (%s) - %s", 
        sender.Name, category, priority, message:sub(1, 50) .. "..."))
    
    return true, "Message sent to admins successfully"
end

-- Create RemoteEvents
local function createRemoteEvents()
    local messageEvent = ReplicatedStorage:FindFirstChild("SimpleAdminMessageSubmitted")
    if not messageEvent then
        messageEvent = Instance.new("RemoteEvent")
        messageEvent.Name = "SimpleAdminMessageSubmitted"
        messageEvent.Parent = ReplicatedStorage
    end
    
    local messageRequest = ReplicatedStorage:FindFirstChild("SimpleAdminMessageRequest")
    if not messageRequest then
        messageRequest = Instance.new("RemoteEvent")
        messageRequest.Name = "SimpleAdminMessageRequest"
        messageRequest.Parent = ReplicatedStorage
    end
    
    -- Handle message submission
    messageEvent.OnServerEvent:Connect(function(player, category, priority, message)
        local success, responseMessage = processAdminMessage(player, category, priority, message)
        messageEvent:FireClient(player, success, responseMessage)
    end)
    
    -- Handle requests
    messageRequest.OnServerEvent:Connect(function(player, requestType, data)
        if requestType == "getCategories" then
            messageRequest:FireClient(player, "categories", ADMIN_MESSAGE_CONFIG.CATEGORIES)
        elseif requestType == "getPriorities" then
            messageRequest:FireClient(player, "priorities", ADMIN_MESSAGE_CONFIG.PRIORITIES)
        elseif requestType == "getMessageCount" then
            local playerData = playerMessageCounts[player.UserId]
            local count = playerData and playerData.count or 0
            local remaining = ADMIN_MESSAGE_CONFIG.MAX_MESSAGES_PER_PLAYER - count
            messageRequest:FireClient(player, "messageCount", {
                sent = count,
                remaining = remaining,
                max = ADMIN_MESSAGE_CONFIG.MAX_MESSAGES_PER_PLAYER
            })
        elseif requestType == "getCooldown" then
            local playerData = playerMessageCounts[player.UserId]
            if playerData and tick() - playerData.lastMessage < ADMIN_MESSAGE_CONFIG.MESSAGE_COOLDOWN then
                local remaining = math.ceil(ADMIN_MESSAGE_CONFIG.MESSAGE_COOLDOWN - (tick() - playerData.lastMessage))
                messageRequest:FireClient(player, "cooldown", remaining)
            else
                messageRequest:FireClient(player, "cooldown", 0)
            end
        end
    end)
end

-- Admin commands
local function processAdminCommand(player, command, args)
    if not isAdmin(player) then return end
    
    if command == "messages" then
        print("[SimpleAdminMessage] Message counts:")
        for userId, data in pairs(playerMessageCounts) do
            local player = Players:GetPlayerByUserId(userId)
            if player then
                print(string.format("[SimpleAdminMessage] %s: %d messages", player.Name, data.count))
            end
        end
    elseif command == "clearmessages" then
        playerMessageCounts = {}
        print("[SimpleAdminMessage] All message counts cleared")
    end
end

-- Chat commands
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        local args = string.split(message, " ")
        local command = args[1]:lower()
        
        if command:sub(1, 1) == "/" then
            processAdminCommand(player, command:sub(2), {table.unpack(args, 2)})
        end
    end)
end)

-- Initialize
createRemoteEvents()

-- Export functions
_G.SimpleAdminMessage = {
    processAdminMessage = processAdminMessage,
    sendToDiscord = sendToDiscord,
    getMessageCounts = function() return playerMessageCounts end,
    isAdmin = isAdmin
}

print("[SimpleAdminMessage] Simple Admin Message System v1.0 loaded!")
print("[SimpleAdminMessage] Discord webhook: " .. (ADMIN_MESSAGE_CONFIG.DISCORD_WEBHOOK_URL ~= "" and "Enabled" or "Disabled"))
print("[SimpleAdminMessage] Max messages per player: " .. ADMIN_MESSAGE_CONFIG.MAX_MESSAGES_PER_PLAYER)
print("[SimpleAdminMessage] Message cooldown: " .. ADMIN_MESSAGE_CONFIG.MESSAGE_COOLDOWN .. " seconds")
print("[SimpleAdminMessage] Admin count: " .. #ADMIN_MESSAGE_CONFIG.ADMIN_USER_IDS)