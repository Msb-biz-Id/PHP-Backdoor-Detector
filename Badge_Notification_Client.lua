--// Badge Notification Client v2.0
--// Client-Side Badge Notification System
--// Beautiful UI Notifications

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Wait for RemoteEvent
local badgeAwarded = ReplicatedStorage:WaitForChild("BadgeAwarded")
local badgeRequest = ReplicatedStorage:WaitForChild("BadgeRequest")

-- Configuration
local NOTIFICATION_CONFIG = {
    -- UI Settings
    WIDTH = 350,
    HEIGHT = 80,
    CORNER_RADIUS = 12,
    PADDING = 16,
    
    -- Animation Settings
    SLIDE_DURATION = 0.5,
    FADE_DURATION = 0.3,
    DISPLAY_DURATION = 5,
    
    -- Position Settings
    POSITION_X = 0.5,  -- Center horizontally
    POSITION_Y = 0.1,  -- Top of screen
    OFFSET_Y = 0,      -- Additional Y offset
    
    -- Sound Settings
    ENABLE_SOUND = true,
    SOUND_ID = "rbxasset://sounds/electronicpingshort.wav",
    SOUND_VOLUME = 0.5,
    
    -- Visual Settings
    SHADOW_BLUR = 20,
    SHADOW_TRANSPARENCY = 0.7,
    GLOW_INTENSITY = 0.3
}

-- Rarity Colors
local RARITY_COLORS = {
    Common = Color3.fromRGB(150, 150, 150),
    Uncommon = Color3.fromRGB(100, 200, 100),
    Rare = Color3.fromRGB(100, 150, 255),
    Epic = Color3.fromRGB(200, 100, 255),
    Legendary = Color3.fromRGB(255, 215, 0)
}

-- Create notification UI
local function createNotificationUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BadgeNotifications"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    
    return screenGui
end

-- Create badge notification
local function createBadgeNotification(badgeData, screenGui)
    -- Main frame
    local notification = Instance.new("Frame")
    notification.Name = "BadgeNotification"
    notification.Size = UDim2.new(0, NOTIFICATION_CONFIG.WIDTH, 0, NOTIFICATION_CONFIG.HEIGHT)
    notification.Position = UDim2.new(NOTIFICATION_CONFIG.POSITION_X, -NOTIFICATION_CONFIG.WIDTH/2, 
                                     NOTIFICATION_CONFIG.POSITION_Y, NOTIFICATION_CONFIG.OFFSET_Y)
    notification.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    notification.BorderSizePixel = 0
    notification.ZIndex = 10
    notification.Parent = screenGui
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, NOTIFICATION_CONFIG.CORNER_RADIUS)
    corner.Parent = notification
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, NOTIFICATION_CONFIG.SHADOW_BLUR, 1, NOTIFICATION_CONFIG.SHADOW_BLUR)
    shadow.Position = UDim2.new(0, -NOTIFICATION_CONFIG.SHADOW_BLUR/2, 0, -NOTIFICATION_CONFIG.SHADOW_BLUR/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = NOTIFICATION_CONFIG.SHADOW_TRANSPARENCY
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.ZIndex = 9
    shadow.Parent = notification
    
    -- Rarity glow effect
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 4, 1, 4)
    glow.Position = UDim2.new(0, -2, 0, -2)
    glow.BackgroundColor3 = badgeData.badgeInfo.color or RARITY_COLORS[badgeData.badgeInfo.rarity] or Color3.fromRGB(255, 255, 255)
    glow.BorderSizePixel = 0
    glow.ZIndex = 8
    glow.Parent = notification
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, NOTIFICATION_CONFIG.CORNER_RADIUS + 2)
    glowCorner.Parent = glow
    
    -- Badge icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0, NOTIFICATION_CONFIG.PADDING, 0.5, -25)
    icon.BackgroundColor3 = badgeData.badgeInfo.color or RARITY_COLORS[badgeData.badgeInfo.rarity] or Color3.fromRGB(255, 255, 255)
    icon.BorderSizePixel = 0
    icon.Image = badgeData.badgeInfo.icon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    icon.ZIndex = 11
    icon.Parent = notification
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = icon
    
    -- Badge name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -80, 0, 20)
    nameLabel.Position = UDim2.new(0, 70, 0, 15)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = badgeData.badgeInfo.name or "Unknown Badge"
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 11
    nameLabel.Parent = notification
    
    -- Badge description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -80, 0, 15)
    descLabel.Position = UDim2.new(0, 70, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = badgeData.badgeInfo.description or "No description"
    descLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 11
    descLabel.Parent = notification
    
    -- Rarity label
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Name = "Rarity"
    rarityLabel.Size = UDim2.new(0, 60, 0, 15)
    rarityLabel.Position = UDim2.new(1, -70, 0, 5)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = badgeData.badgeInfo.rarity or "Common"
    rarityLabel.TextColor3 = badgeData.badgeInfo.color or RARITY_COLORS[badgeData.badgeInfo.rarity] or Color3.fromRGB(255, 255, 255)
    rarityLabel.TextScaled = true
    rarityLabel.Font = Enum.Font.Gotham
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Right
    rarityLabel.ZIndex = 11
    rarityLabel.Parent = notification
    
    -- Progress bar (for milestone badges)
    if badgeData.badgeInfo.rarity and badgeData.badgeInfo.rarity ~= "Common" then
        local progressBar = Instance.new("Frame")
        progressBar.Name = "ProgressBar"
        progressBar.Size = UDim2.new(1, -NOTIFICATION_CONFIG.PADDING*2, 0, 3)
        progressBar.Position = UDim2.new(0, NOTIFICATION_CONFIG.PADDING, 1, -8)
        progressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        progressBar.BorderSizePixel = 0
        progressBar.ZIndex = 11
        progressBar.Parent = notification
        
        local progressCorner = Instance.new("UICorner")
        progressCorner.CornerRadius = UDim.new(0, 2)
        progressCorner.Parent = progressBar
        
        local progressFill = Instance.new("Frame")
        progressFill.Name = "ProgressFill"
        progressFill.Size = UDim2.new(1, 0, 1, 0)
        progressFill.Position = UDim2.new(0, 0, 0, 0)
        progressFill.BackgroundColor3 = badgeData.badgeInfo.color or RARITY_COLORS[badgeData.badgeInfo.rarity] or Color3.fromRGB(255, 255, 255)
        progressFill.BorderSizePixel = 0
        progressFill.ZIndex = 12
        progressFill.Parent = progressBar
        
        local progressFillCorner = Instance.new("UICorner")
        progressFillCorner.CornerRadius = UDim.new(0, 2)
        progressFillCorner.Parent = progressFill
    end
    
    return notification
end

-- Animate notification
local function animateNotification(notification)
    -- Initial state (off-screen)
    notification.Position = UDim2.new(NOTIFICATION_CONFIG.POSITION_X, -NOTIFICATION_CONFIG.WIDTH/2, 
                                     NOTIFICATION_CONFIG.POSITION_Y, -NOTIFICATION_CONFIG.HEIGHT)
    notification.BackgroundTransparency = 1
    
    -- Slide in animation
    local slideIn = TweenService:Create(notification, 
        TweenInfo.new(NOTIFICATION_CONFIG.SLIDE_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Position = UDim2.new(NOTIFICATION_CONFIG.POSITION_X, -NOTIFICATION_CONFIG.WIDTH/2, 
                               NOTIFICATION_CONFIG.POSITION_Y, NOTIFICATION_CONFIG.OFFSET_Y),
            BackgroundTransparency = 0
        }
    )
    
    -- Glow animation
    local glow = notification:FindFirstChild("Glow")
    if glow then
        local glowAnimation = TweenService:Create(glow,
            TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {BackgroundTransparency = 0.5}
        )
        glowAnimation:Play()
    end
    
    -- Icon pulse animation
    local icon = notification:FindFirstChild("Icon")
    if icon then
        local iconPulse = TweenService:Create(icon,
            TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Size = UDim2.new(0, 55, 0, 55)}
        )
        iconPulse:Play()
    end
    
    -- Play sound
    if NOTIFICATION_CONFIG.ENABLE_SOUND then
        local sound = Instance.new("Sound")
        sound.SoundId = NOTIFICATION_CONFIG.SOUND_ID
        sound.Volume = NOTIFICATION_CONFIG.SOUND_VOLUME
        sound.Parent = SoundService
        sound:Play()
        
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end
    
    -- Start slide in
    slideIn:Play()
    
    -- Wait for display duration
    task.wait(NOTIFICATION_CONFIG.DISPLAY_DURATION)
    
    -- Slide out animation
    local slideOut = TweenService:Create(notification,
        TweenInfo.new(NOTIFICATION_CONFIG.SLIDE_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Position = UDim2.new(NOTIFICATION_CONFIG.POSITION_X, -NOTIFICATION_CONFIG.WIDTH/2, 
                               NOTIFICATION_CONFIG.POSITION_Y, -NOTIFICATION_CONFIG.HEIGHT),
            BackgroundTransparency = 1
        }
    )
    
    slideOut:Play()
    
    -- Destroy after animation
    slideOut.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Show badge notification
local function showBadgeNotification(badgeData)
    local screenGui = PlayerGui:FindFirstChild("BadgeNotifications")
    if not screenGui then
        screenGui = createNotificationUI()
    end
    
    local notification = createBadgeNotification(badgeData, screenGui)
    task.spawn(function()
        animateNotification(notification)
    end)
end

-- Handle badge awarded
badgeAwarded.OnClientEvent:Connect(function(badgeData)
    showBadgeNotification(badgeData)
end)

-- Badge collection UI (optional)
local function createBadgeCollectionUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BadgeCollection"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ZIndex = 5
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Badge Collection"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 6
    title.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.ZIndex = 6
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Badge grid
    local badgeGrid = Instance.new("UIGridLayout")
    badgeGrid.CellSize = UDim2.new(0, 100, 0, 120)
    badgeGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    badgeGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    badgeGrid.VerticalAlignment = Enum.VerticalAlignment.Top
    badgeGrid.SortOrder = Enum.SortOrder.LayoutOrder
    badgeGrid.Parent = mainFrame
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    return mainFrame, badgeGrid
end

-- Toggle badge collection UI
local function toggleBadgeCollection()
    local screenGui = PlayerGui:FindFirstChild("BadgeCollection")
    if not screenGui then
        local mainFrame, badgeGrid = createBadgeCollectionUI()
        screenGui = mainFrame.Parent
    end
    
    local mainFrame = screenGui:FindFirstChild("MainFrame")
    mainFrame.Visible = not mainFrame.Visible
    
    if mainFrame.Visible then
        -- Request badge data
        badgeRequest:FireServer("getBadges")
    end
end

-- Handle badge data response
badgeRequest.OnClientEvent:Connect(function(responseType, data)
    if responseType == "badgeData" then
        local screenGui = PlayerGui:FindFirstChild("BadgeCollection")
        if screenGui then
            local mainFrame = screenGui:FindFirstChild("MainFrame")
            local badgeGrid = mainFrame:FindFirstChild("UIGridLayout")
            
            -- Clear existing badges
            for _, child in ipairs(badgeGrid:GetChildren()) do
                if child:IsA("GuiObject") then
                    child:Destroy()
                end
            end
            
            -- Add badges to grid
            for _, badge in ipairs(data) do
                local badgeFrame = Instance.new("Frame")
                badgeFrame.Name = badge.id
                badgeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                badgeFrame.BorderSizePixel = 0
                badgeFrame.Parent = badgeGrid
                
                local badgeCorner = Instance.new("UICorner")
                badgeCorner.CornerRadius = UDim.new(0, 8)
                badgeCorner.Parent = badgeFrame
                
                -- Badge icon
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 60, 0, 60)
                icon.Position = UDim2.new(0.5, -30, 0, 10)
                icon.BackgroundColor3 = RARITY_COLORS[badge.rarity] or Color3.fromRGB(255, 255, 255)
                icon.BorderSizePixel = 0
                icon.Image = badge.icon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
                icon.Parent = badgeFrame
                
                local iconCorner = Instance.new("UICorner")
                iconCorner.CornerRadius = UDim.new(0, 6)
                iconCorner.Parent = icon
                
                -- Badge name
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, -10, 0, 20)
                nameLabel.Position = UDim2.new(0, 5, 0, 75)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = badge.name
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.Parent = badgeFrame
                
                -- Badge rarity
                local rarityLabel = Instance.new("TextLabel")
                rarityLabel.Size = UDim2.new(1, -10, 0, 15)
                rarityLabel.Position = UDim2.new(0, 5, 0, 95)
                rarityLabel.BackgroundTransparency = 1
                rarityLabel.Text = badge.rarity or "Common"
                rarityLabel.TextColor3 = RARITY_COLORS[badge.rarity] or Color3.fromRGB(255, 255, 255)
                rarityLabel.TextScaled = true
                rarityLabel.Font = Enum.Font.Gotham
                rarityLabel.Parent = badgeFrame
            end
        end
    end
end)

-- Keybind for badge collection (B key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.B then
        toggleBadgeCollection()
    end
end)

-- Initialize
print("[BadgeNotification] Client system initialized")
print("[BadgeNotification] Press B to open badge collection")
print("[BadgeNotification] Notifications will appear when badges are earned")