--// Roblox System Sync Emote v2.0
--// Command: /sync
--// Features: Multi-player emote synchronization, GUI menu, custom emotes

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local SYNC_COMMAND = "/sync"
local SYNC_DISTANCE = 50 -- Maximum distance for sync
local SYNC_DURATION = 10 -- How long sync lasts
local MENU_DURATION = 15 -- How long menu stays open

-- Emote data
local EMOTES = {
    {
        Name = "Dance",
        Id = "rbxassetid://507771019",
        Description = "Classic dance move"
    },
    {
        Name = "Cheer",
        Id = "rbxassetid://507770677",
        Description = "Wave and cheer"
    },
    {
        Name = "Laugh",
        Id = "rbxassetid://507770818",
        Description = "Laughing animation"
    },
    {
        Name = "Wave",
        Id = "rbxassetid://507770239",
        Description = "Friendly wave"
    },
    {
        Name = "Point",
        Id = "rbxassetid://507770451",
        Description = "Pointing gesture"
    },
    {
        Name = "Clap",
        Id = "rbxassetid://507770715",
        Description = "Applauding"
    },
    {
        Name = "Salute",
        Id = "rbxassetid://507770370",
        Description = "Military salute"
    },
    {
        Name = "Bow",
        Id = "rbxassetid://507770677",
        Description = "Polite bow"
    },
    {
        Name = "Sit",
        Id = "rbxassetid://507770239",
        Description = "Sitting down"
    },
    {
        Name = "Sleep",
        Id = "rbxassetid://507770677",
        Description = "Sleeping pose"
    }
}

-- Variables
local syncMenu = nil
local isMenuOpen = false
local currentSyncGroup = {}
local syncStartTime = 0
local isSyncing = false

-- Create RemoteEvents for synchronization
local function createRemoteEvents()
    local folder = Instance.new("Folder")
    folder.Name = "SyncEmoteEvents"
    folder.Parent = ReplicatedStorage
    
    local startSyncEvent = Instance.new("RemoteEvent")
    startSyncEvent.Name = "StartSync"
    startSyncEvent.Parent = folder
    
    local joinSyncEvent = Instance.new("RemoteEvent")
    joinSyncEvent.Name = "JoinSync"
    joinSyncEvent.Parent = folder
    
    local stopSyncEvent = Instance.new("RemoteEvent")
    stopSyncEvent.Name = "StopSync"
    stopSyncEvent.Parent = folder
    
    return startSyncEvent, joinSyncEvent, stopSyncEvent
end

-- Get or create RemoteEvents
local startSyncEvent, joinSyncEvent, stopSyncEvent = createRemoteEvents()

-- Create sync menu GUI
local function createSyncMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SyncEmoteMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎭 Sync Emote System"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    -- Scrolling frame for emotes
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "EmoteList"
    scrollFrame.Size = UDim2.new(1, -20, 1, -80)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.Parent = mainFrame
    
    -- Create emote buttons
    for i, emote in ipairs(EMOTES) do
        local emoteButton = Instance.new("TextButton")
        emoteButton.Name = "Emote_" .. i
        emoteButton.Size = UDim2.new(1, 0, 0, 60)
        emoteButton.Position = UDim2.new(0, 0, 0, (i - 1) * 65)
        emoteButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        emoteButton.BorderSizePixel = 0
        emoteButton.Text = ""
        emoteButton.Parent = scrollFrame
        
        local emoteCorner = Instance.new("UICorner")
        emoteCorner.CornerRadius = UDim.new(0, 8)
        emoteCorner.Parent = emoteButton
        
        -- Emote icon
        local emoteIcon = Instance.new("TextLabel")
        emoteIcon.Name = "Icon"
        emoteIcon.Size = UDim2.new(0, 40, 1, -10)
        emoteIcon.Position = UDim2.new(0, 10, 0, 5)
        emoteIcon.BackgroundTransparency = 1
        emoteIcon.Text = "🎭"
        emoteIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        emoteIcon.TextScaled = true
        emoteIcon.Font = Enum.Font.Gotham
        emoteIcon.Parent = emoteButton
        
        -- Emote name
        local emoteName = Instance.new("TextLabel")
        emoteName.Name = "Name"
        emoteName.Size = UDim2.new(1, -60, 0, 25)
        emoteName.Position = UDim2.new(0, 60, 0, 5)
        emoteName.BackgroundTransparency = 1
        emoteName.Text = emote.Name
        emoteName.TextColor3 = Color3.fromRGB(255, 255, 255)
        emoteName.TextScaled = true
        emoteName.TextXAlignment = Enum.TextXAlignment.Left
        emoteName.Font = Enum.Font.GothamBold
        emoteName.Parent = emoteButton
        
        -- Emote description
        local emoteDesc = Instance.new("TextLabel")
        emoteDesc.Name = "Description"
        emoteDesc.Size = UDim2.new(1, -60, 0, 20)
        emoteDesc.Position = UDim2.new(0, 60, 0, 30)
        emoteDesc.BackgroundTransparency = 1
        emoteDesc.Text = emote.Description
        emoteDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
        emoteDesc.TextScaled = true
        emoteDesc.TextXAlignment = Enum.TextXAlignment.Left
        emoteDesc.Font = Enum.Font.Gotham
        emoteDesc.Parent = emoteButton
        
        -- Hover effect
        emoteButton.MouseEnter:Connect(function()
            local tween = TweenService:Create(emoteButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            })
            tween:Play()
        end)
        
        emoteButton.MouseLeave:Connect(function()
            local tween = TweenService:Create(emoteButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            })
            tween:Play()
        end)
        
        -- Click to select emote
        emoteButton.MouseButton1Click:Connect(function()
            selectEmote(emote)
        end)
    end
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #EMOTES * 65)
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 1, -40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Select an emote to sync with nearby players"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        closeSyncMenu()
    end)
    
    return screenGui
end

-- Show sync menu
local function showSyncMenu()
    if isMenuOpen then return end
    
    isMenuOpen = true
    syncMenu = createSyncMenu()
    
    -- Animate in
    local mainFrame = syncMenu.MainFrame
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 400, 0, 500),
        Position = UDim2.new(0.5, -200, 0.5, -250)
    })
    tween:Play()
    
    -- Auto close after duration
    task.wait(MENU_DURATION)
    if isMenuOpen then
        closeSyncMenu()
    end
end

-- Close sync menu
local function closeSyncMenu()
    if not isMenuOpen or not syncMenu then return end
    
    isMenuOpen = false
    
    -- Animate out
    local mainFrame = syncMenu.MainFrame
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        if syncMenu then
            syncMenu:Destroy()
            syncMenu = nil
        end
    end)
end

-- Get nearby players
local function getNearbyPlayers()
    local nearbyPlayers = {}
    local character = LocalPlayer.Character
    
    if not character then return nearbyPlayers end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nearbyPlayers end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRootPart then
                local distance = (humanoidRootPart.Position - targetRootPart.Position).Magnitude
                if distance <= SYNC_DISTANCE then
                    table.insert(nearbyPlayers, player)
                end
            end
        end
    end
    
    return nearbyPlayers
end

-- Start sync with selected emote
local function selectEmote(emote)
    local nearbyPlayers = getNearbyPlayers()
    
    if #nearbyPlayers == 0 then
        -- No nearby players, just play emote locally
        Humanoid:LoadAnimation(emote.Id):Play()
        print("No nearby players found. Playing emote locally.")
        closeSyncMenu()
        return
    end
    
    -- Start sync with nearby players
    currentSyncGroup = {LocalPlayer}
    syncStartTime = tick()
    isSyncing = true
    
    -- Play emote locally
    Humanoid:LoadAnimation(emote.Id):Play()
    
    -- Send sync request to nearby players
    for _, player in ipairs(nearbyPlayers) do
        joinSyncEvent:FireServer(player, emote.Id, SYNC_DURATION)
        table.insert(currentSyncGroup, player)
    end
    
    -- Update status
    if syncMenu and syncMenu.MainFrame.Status then
        syncMenu.MainFrame.Status.Text = "Syncing with " .. (#nearbyPlayers) .. " players..."
    end
    
    print("Started sync with " .. (#nearbyPlayers) .. " players using " .. emote.Name)
    closeSyncMenu()
    
    -- Auto stop sync after duration
    task.wait(SYNC_DURATION)
    stopSync()
end

-- Stop sync
local function stopSync()
    if not isSyncing then return end
    
    isSyncing = false
    currentSyncGroup = {}
    
    -- Stop local emote
    Humanoid:StopAllAnimations()
    
    -- Notify other players to stop
    stopSyncEvent:FireServer()
    
    print("Sync stopped")
end

-- Handle chat commands
local function onChatted(player, message)
    if player == LocalPlayer and message:lower() == SYNC_COMMAND then
        showSyncMenu()
    end
end

-- Handle remote events
startSyncEvent.OnClientEvent:Connect(function(emoteId, duration)
    if not isSyncing then
        isSyncing = true
        syncStartTime = tick()
        Humanoid:LoadAnimation(emoteId):Play()
        
        -- Auto stop after duration
        task.wait(duration)
        if isSyncing then
            stopSync()
        end
    end
end)

joinSyncEvent.OnClientEvent:Connect(function(emoteId, duration)
    if not isSyncing then
        isSyncing = true
        syncStartTime = tick()
        Humanoid:LoadAnimation(emoteId):Play()
        
        -- Auto stop after duration
        task.wait(duration)
        if isSyncing then
            stopSync()
        end
    end
end)

stopSyncEvent.OnClientEvent:Connect(function()
    stopSync()
end)

-- Keyboard shortcut (F1 key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        showSyncMenu()
    end
end)

-- Connect chat event
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        onChatted(player, message)
    end)
end)

-- Connect for existing players
for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(message)
        onChatted(player, message)
    end)
end

-- Cleanup on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    
    -- Close menu if open
    if isMenuOpen then
        closeSyncMenu()
    end
    
    -- Stop any ongoing sync
    stopSync()
end)

-- Initialize
print("🎭 Sync Emote System loaded!")
print("Commands:")
print("  /sync - Open sync menu")
print("  F1 - Open sync menu (keyboard shortcut)")
print("  Click emote buttons to sync with nearby players")

-- Show initial help
task.wait(2)
print("💡 Tip: Get close to other players and use /sync to start synchronized emotes!")