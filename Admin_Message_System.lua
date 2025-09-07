--// Admin Message System v2.0
--// Discord Webhook Integration
--// Center Top UI with Open/Close
--// Server-Side Message Handling

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Configuration
local ADMIN_MESSAGE_CONFIG = {
    -- Discord Webhook Settings
    DISCORD_WEBHOOK_URL = "",  -- Add your Discord webhook URL here
    ENABLE_DISCORD_LOGS = true,
    
    -- Message Categories
    MESSAGE_CATEGORIES = {
        "Bug Report",
        "Feature Request", 
        "Player Issue",
        "Server Problem",
        "General Question",
        "Complaint",
        "Suggestion",
        "Other"
    },
    
    -- UI Settings
    MENU_POSITION = "CenterTop",  -- CenterTop, TopLeft, TopRight
    MENU_SIZE = {width = 400, height = 500},
    BUTTON_SIZE = {width = 100, height = 35},
    
    -- Message Settings
    MAX_MESSAGES_PER_PLAYER = 3,  -- Max messages per player per session
    MESSAGE_COOLDOWN = 120,       -- Cooldown between messages (seconds)
    MAX_MESSAGE_LENGTH = 500,     -- Maximum message length
    MIN_MESSAGE_LENGTH = 10,      -- Minimum message length
    
    -- Priority Settings
    ENABLE_PRIORITY_SYSTEM = true,
    PRIORITY_LEVELS = {
        "Low",
        "Medium", 
        "High",
        "Urgent"
    },
    
    -- Data Storage
    ENABLE_DATA_STORAGE = true,
    SAVE_MESSAGES_TO_DISCORD = true,
    SAVE_MESSAGES_TO_DATABASE = true,
    
    -- Admin Settings
    ADMIN_USER_IDS = {  -- Add admin user IDs here
        -- Example: 123456789, 987654321
    },
    
    -- Notification Settings
    NOTIFY_ADMINS_ONLINE = true,
    NOTIFY_ADMINS_DISCORD = true
}

-- Data Storage
local messageData = {}
local playerMessageCounts = {}
local messageDataStore = DataStoreService:GetDataStore("AdminMessageSystem_Data")

-- Message Data Structure
local function createMessageData()
    return {
        messages = {},
        totalMessages = 0,
        lastMessage = 0
    }
end

-- Load message data
local function loadMessageData()
    local success, data = pcall(function()
        return messageDataStore:GetAsync("message_data")
    end)
    
    if success and data then
        messageData = data
    else
        messageData = createMessageData()
    end
end

-- Save message data
local function saveMessageData()
    local success, error = pcall(function()
        messageDataStore:SetAsync("message_data", messageData)
    end)
    
    if not success then
        warn("[AdminMessage] Failed to save message data: " .. tostring(error))
    end
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

-- Get online admins
local function getOnlineAdmins()
    local onlineAdmins = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if isAdmin(player) then
            table.insert(onlineAdmins, player)
        end
    end
    return onlineAdmins
end

-- Send message to Discord
local function sendToDiscord(messageData)
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
            color = priorityColors[messageData.priority] or 3447003,
            fields = {
                {
                    name = "👤 From",
                    value = messageData.senderName .. " (" .. messageData.senderId .. ")",
                    inline = true
                },
                {
                    name = "📋 Category",
                    value = messageData.category,
                    inline = true
                },
                {
                    name = "⚡ Priority",
                    value = messageData.priority,
                    inline = true
                },
                {
                    name = "📝 Message",
                    value = messageData.message,
                    inline = false
                },
                {
                    name = "🕐 Time",
                    value = messageData.timestamp,
                    inline = true
                },
                {
                    name = "🆔 Server ID",
                    value = game.JobId,
                    inline = true
                }
            },
            footer = {
                text = "Admin Message System v2.0"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    local payload = {
        embeds = embed
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(ADMIN_MESSAGE_CONFIG.DISCORD_WEBHOOK_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("[AdminMessage] Failed to send to Discord: " .. tostring(response))
        return false
    end
    
    return true
end

-- Notify online admins
local function notifyOnlineAdmins(messageData)
    if not ADMIN_MESSAGE_CONFIG.NOTIFY_ADMINS_ONLINE then return end
    
    local onlineAdmins = getOnlineAdmins()
    for _, admin in ipairs(onlineAdmins) do
        local remoteEvent = ReplicatedStorage:FindFirstChild("AdminNotification")
        if remoteEvent then
            remoteEvent:FireClient(admin, {
                type = "new_message",
                sender = messageData.senderName,
                category = messageData.category,
                priority = messageData.priority,
                message = messageData.message
            })
        end
    end
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
    
    -- Create message data
    local messageInfo = {
        id = HttpService:GenerateGUID(false),
        senderId = sender.UserId,
        senderName = sender.Name,
        category = category,
        priority = priority,
        message = message,
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        serverId = game.JobId,
        processed = false,
        adminResponse = nil
    }
    
    -- Add to message data
    table.insert(messageData.messages, messageInfo)
    messageData.totalMessages = messageData.totalMessages + 1
    
    -- Update player message count
    if not playerMessageCounts[sender.UserId] then
        playerMessageCounts[sender.UserId] = {count = 0, lastMessage = 0}
    end
    playerMessageCounts[sender.UserId].count = playerMessageCounts[sender.UserId].count + 1
    playerMessageCounts[sender.UserId].lastMessage = tick()
    
    -- Save to database
    if ADMIN_MESSAGE_CONFIG.SAVE_MESSAGES_TO_DATABASE then
        saveMessageData()
    end
    
    -- Send to Discord
    if ADMIN_MESSAGE_CONFIG.SAVE_MESSAGES_TO_DISCORD then
        sendToDiscord(messageInfo)
    end
    
    -- Notify online admins
    notifyOnlineAdmins(messageInfo)
    
    -- Log to console
    print(string.format("[AdminMessage] Message received: %s - %s (%s) - %s", 
        sender.Name, category, priority, message:sub(1, 50) .. "..."))
    
    return true, "Message sent to admins successfully"
end

-- Create RemoteEvents
local function createRemoteEvents()
    local messageEvent = ReplicatedStorage:FindFirstChild("AdminMessageSubmitted")
    if not messageEvent then
        messageEvent = Instance.new("RemoteEvent")
        messageEvent.Name = "AdminMessageSubmitted"
        messageEvent.Parent = ReplicatedStorage
    end
    
    local messageRequest = ReplicatedStorage:FindFirstChild("AdminMessageRequest")
    if not messageRequest then
        messageRequest = Instance.new("RemoteEvent")
        messageRequest.Name = "AdminMessageRequest"
        messageRequest.Parent = ReplicatedStorage
    end
    
    local adminNotification = ReplicatedStorage:FindFirstChild("AdminNotification")
    if not adminNotification then
        adminNotification = Instance.new("RemoteEvent")
        adminNotification.Name = "AdminNotification"
        adminNotification.Parent = ReplicatedStorage
    end
    
    -- Handle message submission
    messageEvent.OnServerEvent:Connect(function(player, category, priority, message)
        local success, responseMessage = processAdminMessage(player, category, priority, message)
        messageEvent:FireClient(player, success, responseMessage)
    end)
    
    -- Handle message requests
    messageRequest.OnServerEvent:Connect(function(player, requestType, data)
        if requestType == "getCategories" then
            messageRequest:FireClient(player, "categories", ADMIN_MESSAGE_CONFIG.MESSAGE_CATEGORIES)
        elseif requestType == "getPriorities" then
            messageRequest:FireClient(player, "priorities", ADMIN_MESSAGE_CONFIG.PRIORITY_LEVELS)
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
        print(string.format("[AdminMessage] Total messages: %d", messageData.totalMessages))
        for i, msg in ipairs(messageData.messages) do
            if i <= 10 then -- Show last 10 messages
                print(string.format("[AdminMessage] %d. %s - %s (%s): %s", 
                    i, msg.senderName, msg.category, msg.priority, msg.message:sub(1, 50) .. "..."))
            end
        end
    elseif command == "clearmessages" then
        messageData = createMessageData()
        saveMessageData()
        print("[AdminMessage] All messages cleared")
    elseif command == "respond" and args[1] and args[2] then
        local messageId = args[1]
        local response = table.concat(args, " ", 2)
        
        for _, msg in ipairs(messageData.messages) do
            if msg.id == messageId then
                msg.adminResponse = response
                msg.processed = true
                saveMessageData()
                print(string.format("[AdminMessage] Response sent to %s", msg.senderName))
                break
            end
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
loadMessageData()
createRemoteEvents()

-- Export functions
_G.AdminMessageSystem = {
    processAdminMessage = processAdminMessage,
    sendToDiscord = sendToDiscord,
    getMessageData = function() return messageData end,
    getPlayerMessageCounts = function() return playerMessageCounts end,
    isAdmin = isAdmin,
    getOnlineAdmins = getOnlineAdmins
}

print("[AdminMessage] Admin Message System v2.0 initialized")
print("[AdminMessage] Discord webhook: " .. (ADMIN_MESSAGE_CONFIG.DISCORD_WEBHOOK_URL ~= "" and "Enabled" or "Disabled"))
print("[AdminMessage] Max messages per player: " .. ADMIN_MESSAGE_CONFIG.MAX_MESSAGES_PER_PLAYER)
print("[AdminMessage] Message cooldown: " .. ADMIN_MESSAGE_CONFIG.MESSAGE_COOLDOWN .. " seconds")
print("[AdminMessage] Admin count: " .. #ADMIN_MESSAGE_CONFIG.ADMIN_USER_IDS)