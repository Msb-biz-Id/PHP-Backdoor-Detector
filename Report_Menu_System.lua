--// Report Menu System v2.0
--// Discord Webhook Integration
--// Top Left Corner UI
--// Server-Side Report Handling

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Configuration
local REPORT_CONFIG = {
    -- Discord Webhook Settings
    DISCORD_WEBHOOK_URL = "",  -- Add your Discord webhook URL here
    ENABLE_DISCORD_LOGS = true,
    
    -- Report Categories
    REPORT_CATEGORIES = {
        "Cheating/Hacking",
        "Harassment/Bullying", 
        "Inappropriate Content",
        "Spam/Advertising",
        "Exploiting/Glitching",
        "Scamming",
        "Other"
    },
    
    -- UI Settings
    MENU_POSITION = "TopLeft",  -- TopLeft, TopRight, BottomLeft, BottomRight
    MENU_SIZE = {width = 300, height = 400},
    BUTTON_SIZE = {width = 80, height = 30},
    
    -- Report Settings
    MAX_REPORTS_PER_PLAYER = 5,  -- Max reports per player per session
    REPORT_COOLDOWN = 60,        -- Cooldown between reports (seconds)
    AUTO_KICK_ON_REPORTS = false, -- Auto kick player after X reports
    KICK_THRESHOLD = 10,         -- Number of reports before auto kick
    
    -- Data Storage
    ENABLE_DATA_STORAGE = true,
    SAVE_REPORTS_TO_DISCORD = true,
    SAVE_REPORTS_TO_DATABASE = true
}

-- Data Storage
local reportData = {}
local playerReportCounts = {}
local reportDataStore = DataStoreService:GetDataStore("ReportSystem_Data")

-- Report Data Structure
local function createReportData()
    return {
        reports = {},
        totalReports = 0,
        lastReport = 0
    }
end

-- Load report data
local function loadReportData()
    local success, data = pcall(function()
        return reportDataStore:GetAsync("report_data")
    end)
    
    if success and data then
        reportData = data
    else
        reportData = createReportData()
    end
end

-- Save report data
local function saveReportData()
    local success, error = pcall(function()
        reportDataStore:SetAsync("report_data", reportData)
    end)
    
    if not success then
        warn("[ReportSystem] Failed to save report data: " .. tostring(error))
    end
end

-- Send report to Discord
local function sendToDiscord(reportData)
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
                    value = reportData.reporterName .. " (" .. reportData.reporterId .. ")",
                    inline = true
                },
                {
                    name = "🎯 Reported Player", 
                    value = reportData.reportedName .. " (" .. reportData.reportedId .. ")",
                    inline = true
                },
                {
                    name = "📋 Category",
                    value = reportData.category,
                    inline = true
                },
                {
                    name = "📝 Description",
                    value = reportData.description or "No description provided",
                    inline = false
                },
                {
                    name = "🕐 Time",
                    value = reportData.timestamp,
                    inline = true
                },
                {
                    name = "🆔 Server ID",
                    value = game.JobId,
                    inline = true
                }
            },
            footer = {
                text = "Report System v2.0"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    local payload = {
        embeds = embed
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(REPORT_CONFIG.DISCORD_WEBHOOK_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("[ReportSystem] Failed to send to Discord: " .. tostring(response))
        return false
    end
    
    return true
end

-- Process report
local function processReport(reporter, reportedPlayer, category, description)
    -- Check if reporter exists
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
    
    -- Create report data
    local report = {
        id = HttpService:GenerateGUID(false),
        reporterId = reporter.UserId,
        reporterName = reporter.Name,
        reportedId = reportedPlayer.UserId,
        reportedName = reportedPlayer.Name,
        category = category,
        description = description or "",
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        serverId = game.JobId,
        processed = false
    }
    
    -- Add to report data
    table.insert(reportData.reports, report)
    reportData.totalReports = reportData.totalReports + 1
    
    -- Update player report count
    if not playerReportCounts[reporter.UserId] then
        playerReportCounts[reporter.UserId] = {count = 0, lastReport = 0}
    end
    playerReportCounts[reporter.UserId].count = playerReportCounts[reporter.UserId].count + 1
    playerReportCounts[reporter.UserId].lastReport = tick()
    
    -- Save to database
    if REPORT_CONFIG.SAVE_REPORTS_TO_DATABASE then
        saveReportData()
    end
    
    -- Send to Discord
    if REPORT_CONFIG.SAVE_REPORTS_TO_DISCORD then
        sendToDiscord(report)
    end
    
    -- Log to console
    print(string.format("[ReportSystem] Report submitted: %s reported %s for %s", 
        reporter.Name, reportedPlayer.Name, category))
    
    -- Check for auto kick
    if REPORT_CONFIG.AUTO_KICK_ON_REPORTS then
        local reportedData = playerReportCounts[reportedPlayer.UserId]
        if reportedData and reportedData.count >= REPORT_CONFIG.KICK_THRESHOLD then
            reportedPlayer:Kick("You have been reported multiple times")
        end
    end
    
    return true, "Report submitted successfully"
end

-- Create RemoteEvents
local function createRemoteEvents()
    local reportEvent = ReplicatedStorage:FindFirstChild("ReportSubmitted")
    if not reportEvent then
        reportEvent = Instance.new("RemoteEvent")
        reportEvent.Name = "ReportSubmitted"
        reportEvent.Parent = ReplicatedStorage
    end
    
    local reportRequest = ReplicatedStorage:FindFirstChild("ReportRequest")
    if not reportRequest then
        reportRequest = Instance.new("RemoteEvent")
        reportRequest.Name = "ReportRequest"
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
    
    -- Handle report requests
    reportRequest.OnServerEvent:Connect(function(player, requestType, data)
        if requestType == "getCategories" then
            reportRequest:FireClient(player, "categories", REPORT_CONFIG.REPORT_CATEGORIES)
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
    -- Check if player is admin (you can customize this)
    local isAdmin = false -- Add your admin check here
    
    if not isAdmin then return end
    
    if command == "reports" then
        print(string.format("[ReportSystem] Total reports: %d", reportData.totalReports))
        for i, report in ipairs(reportData.reports) do
            if i <= 10 then -- Show last 10 reports
                print(string.format("[ReportSystem] %d. %s reported %s for %s", 
                    i, report.reporterName, report.reportedName, report.category))
            end
        end
    elseif command == "clearreports" then
        reportData = createReportData()
        saveReportData()
        print("[ReportSystem] All reports cleared")
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
loadReportData()
createRemoteEvents()

-- Export functions
_G.ReportSystem = {
    processReport = processReport,
    sendToDiscord = sendToDiscord,
    getReportData = function() return reportData end,
    getPlayerReportCounts = function() return playerReportCounts end
}

print("[ReportSystem] Report System v2.0 initialized")
print("[ReportSystem] Discord webhook: " .. (REPORT_CONFIG.DISCORD_WEBHOOK_URL ~= "" and "Enabled" or "Disabled"))
print("[ReportSystem] Max reports per player: " .. REPORT_CONFIG.MAX_REPORTS_PER_PLAYER)
print("[ReportSystem] Report cooldown: " .. REPORT_CONFIG.REPORT_COOLDOWN .. " seconds")