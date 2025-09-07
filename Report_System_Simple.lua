--// Simple Report System v1.0
--// Easy Setup - Discord Webhook
--// Server-Side Only

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Simple Configuration
local REPORT_CONFIG = {
    DISCORD_WEBHOOK_URL = "",  -- Add your Discord webhook URL here
    ENABLE_DISCORD_LOGS = true,
    
    -- Report Categories
    CATEGORIES = {
        "Cheating/Hacking",
        "Harassment/Bullying", 
        "Inappropriate Content",
        "Spam/Advertising",
        "Exploiting/Glitching",
        "Scamming",
        "Other"
    },
    
    -- Settings
    MAX_REPORTS_PER_PLAYER = 3,
    REPORT_COOLDOWN = 60,  -- 60 seconds
    AUTO_KICK_THRESHOLD = 5
}

-- Data Storage
local playerReportCounts = {}

-- Send to Discord
local function sendToDiscord(reporter, reported, category, description)
    if not REPORT_CONFIG.ENABLE_DISCORD_LOGS or REPORT_CONFIG.DISCORD_WEBHOOK_URL == "" then
        return false
    end
    
    local embed = {
        {
            title = "🚨 New Report Received",
            color = 16711680, -- Red color
            fields = {
                {
                    name = "👤 Reporter",
                    value = reporter.Name .. " (" .. reporter.UserId .. ")",
                    inline = true
                },
                {
                    name = "🎯 Reported Player", 
                    value = reported.Name .. " (" .. reported.UserId .. ")",
                    inline = true
                },
                {
                    name = "📋 Category",
                    value = category,
                    inline = true
                },
                {
                    name = "📝 Description",
                    value = description or "No description provided",
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
                text = "Simple Report System v1.0"
            }
        }
    }
    
    local payload = {
        embeds = embed
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(REPORT_CONFIG.DISCORD_WEBHOOK_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("[SimpleReport] Failed to send to Discord: " .. tostring(response))
        return false
    end
    
    return true
end

-- Process report
local function processReport(reporter, reportedPlayer, category, description)
    -- Check if players exist
    if not reporter or not reportedPlayer then
        return false, "Invalid player"
    end
    
    -- Check cooldown
    local reporterData = playerReportCounts[reporter.UserId]
    if reporterData and tick() - reporterData.lastReport < REPORT_CONFIG.REPORT_COOLDOWN then
        return false, "Please wait before submitting another report"
    end
    
    -- Check max reports
    if reporterData and reporterData.count >= REPORT_CONFIG.MAX_REPORTS_PER_PLAYER then
        return false, "You have reached the maximum number of reports"
    end
    
    -- Update reporter count
    if not playerReportCounts[reporter.UserId] then
        playerReportCounts[reporter.UserId] = {count = 0, lastReport = 0}
    end
    playerReportCounts[reporter.UserId].count = playerReportCounts[reporter.UserId].count + 1
    playerReportCounts[reporter.UserId].lastReport = tick()
    
    -- Update reported count
    if not playerReportCounts[reportedPlayer.UserId] then
        playerReportCounts[reportedPlayer.UserId] = {count = 0, lastReport = 0}
    end
    playerReportCounts[reportedPlayer.UserId].count = playerReportCounts[reportedPlayer.UserId].count + 1
    
    -- Send to Discord
    sendToDiscord(reporter, reportedPlayer, category, description)
    
    -- Log to console
    print(string.format("[SimpleReport] Report: %s reported %s for %s", 
        reporter.Name, reportedPlayer.Name, category))
    
    -- Check for auto kick
    if playerReportCounts[reportedPlayer.UserId].count >= REPORT_CONFIG.AUTO_KICK_THRESHOLD then
        reportedPlayer:Kick("You have been reported multiple times")
    end
    
    return true, "Report submitted successfully"
end

-- Create RemoteEvents
local function createRemoteEvents()
    local reportEvent = ReplicatedStorage:FindFirstChild("SimpleReportSubmitted")
    if not reportEvent then
        reportEvent = Instance.new("RemoteEvent")
        reportEvent.Name = "SimpleReportSubmitted"
        reportEvent.Parent = ReplicatedStorage
    end
    
    local reportRequest = ReplicatedStorage:FindFirstChild("SimpleReportRequest")
    if not reportRequest then
        reportRequest = Instance.new("RemoteEvent")
        reportRequest.Name = "SimpleReportRequest"
        reportRequest.Parent = ReplicatedStorage
    end
    
    -- Handle report submission
    reportEvent.OnServerEvent:Connect(function(player, reportedPlayerName, category, description)
        local reportedPlayer = Players:FindFirstChild(reportedPlayerName)
        if not reportedPlayer then
            reportEvent:FireClient(player, false, "Player not found")
            return
        end
        
        local success, message = processReport(player, reportedPlayer, category, description)
        reportEvent:FireClient(player, success, message)
    end)
    
    -- Handle requests
    reportRequest.OnServerEvent:Connect(function(player, requestType, data)
        if requestType == "getCategories" then
            reportRequest:FireClient(player, "categories", REPORT_CONFIG.CATEGORIES)
        elseif requestType == "getPlayerList" then
            local playerList = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    table.insert(playerList, p.Name)
                end
            end
            reportRequest:FireClient(player, "playerList", playerList)
        end
    end)
end

-- Admin commands
local function processAdminCommand(player, command, args)
    -- Add your admin check here
    local isAdmin = false
    
    if not isAdmin then return end
    
    if command == "reports" then
        print("[SimpleReport] Report counts:")
        for userId, data in pairs(playerReportCounts) do
            local player = Players:GetPlayerByUserId(userId)
            if player then
                print(string.format("[SimpleReport] %s: %d reports", player.Name, data.count))
            end
        end
    elseif command == "clearreports" then
        playerReportCounts = {}
        print("[SimpleReport] All report counts cleared")
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
_G.SimpleReport = {
    processReport = processReport,
    sendToDiscord = sendToDiscord,
    getReportCounts = function() return playerReportCounts end
}

print("[SimpleReport] Simple Report System v1.0 loaded!")
print("[SimpleReport] Discord webhook: " .. (REPORT_CONFIG.DISCORD_WEBHOOK_URL ~= "" and "Enabled" or "Disabled"))
print("[SimpleReport] Max reports per player: " .. REPORT_CONFIG.MAX_REPORTS_PER_PLAYER)
print("[SimpleReport] Report cooldown: " .. REPORT_CONFIG.REPORT_COOLDOWN .. " seconds")