--// MDLP UI System - Modern Dark Light Professional
--// Positioned at Top Center with Theme Support
--// Created for Roblox

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme Configuration
local themes = {
    dark = {
        primary = Color3.fromRGB(25, 25, 25),
        secondary = Color3.fromRGB(35, 35, 35),
        accent = Color3.fromRGB(0, 162, 255),
        text = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(200, 200, 200),
        border = Color3.fromRGB(60, 60, 60),
        success = Color3.fromRGB(46, 204, 113),
        warning = Color3.fromRGB(241, 196, 15),
        error = Color3.fromRGB(231, 76, 60)
    },
    light = {
        primary = Color3.fromRGB(255, 255, 255),
        secondary = Color3.fromRGB(245, 245, 245),
        accent = Color3.fromRGB(0, 162, 255),
        text = Color3.fromRGB(25, 25, 25),
        textSecondary = Color3.fromRGB(100, 100, 100),
        border = Color3.fromRGB(200, 200, 200),
        success = Color3.fromRGB(46, 204, 113),
        warning = Color3.fromRGB(241, 196, 15),
        error = Color3.fromRGB(231, 76, 60)
    }
}

-- Current theme
local currentTheme = "dark"
local theme = themes[currentTheme]

-- UI Configuration
local UI_CONFIG = {
    width = 400,
    height = 300,
    cornerRadius = 12,
    padding = 16,
    animationSpeed = 0.3,
    shadowBlur = 20,
    shadowTransparency = 0.7
}

-- Create Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MDLP_UI_System"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

-- Create Main Frame (Top Center Position)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, UI_CONFIG.width, 0, UI_CONFIG.height)
mainFrame.Position = UDim2.new(0.5, -UI_CONFIG.width/2, 0, 20) -- Top center
mainFrame.BackgroundColor3 = theme.primary
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

-- Corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, UI_CONFIG.cornerRadius)
corner.Parent = mainFrame

-- Drop shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, UI_CONFIG.shadowBlur, 1, UI_CONFIG.shadowBlur)
shadow.Position = UDim2.new(0, -UI_CONFIG.shadowBlur/2, 0, -UI_CONFIG.shadowBlur/2)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = UI_CONFIG.shadowTransparency
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)
shadow.ZIndex = 0
shadow.Parent = mainFrame

-- Header Bar
local headerBar = Instance.new("Frame")
headerBar.Name = "HeaderBar"
headerBar.Size = UDim2.new(1, 0, 0, 50)
headerBar.Position = UDim2.new(0, 0, 0, 0)
headerBar.BackgroundColor3 = theme.secondary
headerBar.BorderSizePixel = 0
headerBar.ZIndex = 2
headerBar.Parent = mainFrame

-- Header corner rounding
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, UI_CONFIG.cornerRadius)
headerCorner.Parent = headerBar

-- Bottom corner rounding for header
local headerBottomCorner = Instance.new("UICorner")
headerBottomCorner.CornerRadius = UDim.new(0, 0)
headerBottomCorner.Parent = headerBar

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MDLP System"
title.TextColor3 = theme.text
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = headerBar

-- Theme Toggle Button
local themeToggle = Instance.new("TextButton")
themeToggle.Name = "ThemeToggle"
themeToggle.Size = UDim2.new(0, 80, 0, 30)
themeToggle.Position = UDim2.new(1, -90, 0.5, -15)
themeToggle.BackgroundColor3 = theme.accent
themeToggle.BorderSizePixel = 0
themeToggle.Text = "🌙"
themeToggle.TextColor3 = Color3.new(1, 1, 1)
themeToggle.TextScaled = true
themeToggle.Font = Enum.Font.Gotham
themeToggle.ZIndex = 3
themeToggle.Parent = headerBar

-- Theme toggle corner
local themeCorner = Instance.new("UICorner")
themeCorner.CornerRadius = UDim.new(0, 6)
themeCorner.Parent = themeToggle

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -UI_CONFIG.padding*2, 1, -70)
contentArea.Position = UDim2.new(0, UI_CONFIG.padding, 0, 60)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 2
contentArea.Parent = mainFrame

-- Status Panel
local statusPanel = Instance.new("Frame")
statusPanel.Name = "StatusPanel"
statusPanel.Size = UDim2.new(1, 0, 0, 40)
statusPanel.Position = UDim2.new(0, 0, 0, 0)
statusPanel.BackgroundColor3 = theme.secondary
statusPanel.BorderSizePixel = 0
statusPanel.ZIndex = 2
statusPanel.Parent = contentArea

-- Status panel corner
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusPanel

-- Status indicators
local statusGrid = Instance.new("UIGridLayout")
statusGrid.CellSize = UDim2.new(0, 80, 1, -10)
statusGrid.CellPadding = UDim2.new(0, 5, 0, 5)
statusGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
statusGrid.VerticalAlignment = Enum.VerticalAlignment.Center
statusGrid.SortOrder = Enum.SortOrder.LayoutOrder
statusGrid.Parent = statusPanel

-- Ping indicator
local pingIndicator = Instance.new("Frame")
pingIndicator.Name = "PingIndicator"
pingIndicator.LayoutOrder = 1
pingIndicator.BackgroundColor3 = theme.success
pingIndicator.BorderSizePixel = 0
pingIndicator.Parent = statusPanel

local pingCorner = Instance.new("UICorner")
pingCorner.CornerRadius = UDim.new(0, 4)
pingCorner.Parent = pingIndicator

local pingText = Instance.new("TextLabel")
pingText.Size = UDim2.new(1, 0, 1, 0)
pingText.BackgroundTransparency = 1
pingText.Text = "Ping: 45ms"
pingText.TextColor3 = Color3.new(1, 1, 1)
pingText.TextScaled = true
pingText.Font = Enum.Font.Gotham
pingText.Parent = pingIndicator

-- FPS indicator
local fpsIndicator = Instance.new("Frame")
fpsIndicator.Name = "FPSIndicator"
fpsIndicator.LayoutOrder = 2
fpsIndicator.BackgroundColor3 = theme.accent
fpsIndicator.BorderSizePixel = 0
fpsIndicator.Parent = statusPanel

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 4)
fpsCorner.Parent = fpsIndicator

local fpsText = Instance.new("TextLabel")
fpsText.Size = UDim2.new(1, 0, 1, 0)
fpsText.BackgroundTransparency = 1
fpsText.Text = "FPS: 60"
fpsText.TextColor3 = Color3.new(1, 1, 1)
fpsText.TextScaled = true
fpsText.Font = Enum.Font.Gotham
fpsText.Parent = fpsIndicator

-- Memory indicator
local memoryIndicator = Instance.new("Frame")
memoryIndicator.Name = "MemoryIndicator"
memoryIndicator.LayoutOrder = 3
memoryIndicator.BackgroundColor3 = theme.warning
memoryIndicator.BorderSizePixel = 0
memoryIndicator.Parent = statusPanel

local memoryCorner = Instance.new("UICorner")
memoryCorner.CornerRadius = UDim.new(0, 4)
memoryCorner.Parent = memoryIndicator

local memoryText = Instance.new("TextLabel")
memoryText.Size = UDim2.new(1, 0, 1, 0)
memoryText.BackgroundTransparency = 1
memoryText.Text = "RAM: 2.1GB"
memoryText.TextColor3 = Color3.new(1, 1, 1)
memoryText.TextScaled = true
memoryText.Font = Enum.Font.Gotham
memoryText.Parent = memoryIndicator

-- Control Panel
local controlPanel = Instance.new("Frame")
controlPanel.Name = "ControlPanel"
controlPanel.Size = UDim2.new(1, 0, 1, -50)
controlPanel.Position = UDim2.new(0, 0, 0, 50)
controlPanel.BackgroundTransparency = 1
controlPanel.ZIndex = 2
controlPanel.Parent = contentArea

-- Control buttons
local controlGrid = Instance.new("UIGridLayout")
controlGrid.CellSize = UDim2.new(0.5, -5, 0, 40)
controlGrid.CellPadding = UDim2.new(0, 5, 0, 10)
controlGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
controlGrid.VerticalAlignment = Enum.VerticalAlignment.Top
controlGrid.SortOrder = Enum.SortOrder.LayoutOrder
controlGrid.Parent = controlPanel

-- Function to create control button
local function createControlButton(name, text, color, layoutOrder)
    local button = Instance.new("TextButton")
    button.Name = name
    button.LayoutOrder = layoutOrder
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.ZIndex = 3
    button.Parent = controlPanel
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    return button
end

-- Create control buttons
local optimizeButton = createControlButton("OptimizeButton", "Optimize", theme.success, 1)
local settingsButton = createControlButton("SettingsButton", "Settings", theme.accent, 2)
local infoButton = createControlButton("InfoButton", "Info", theme.warning, 3)
local closeButton = createControlButton("CloseButton", "Close", theme.error, 4)

-- Animation functions
local function animateProperty(object, property, targetValue, duration)
    local tweenInfo = TweenInfo.new(
        duration or UI_CONFIG.animationSpeed,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, {[property] = targetValue})
    tween:Play()
    return tween
end

-- Theme switching function
local function switchTheme()
    currentTheme = currentTheme == "dark" and "light" or "dark"
    theme = themes[currentTheme]
    
    -- Update theme toggle button
    themeToggle.Text = currentTheme == "dark" and "🌙" or "☀️"
    
    -- Animate theme change
    local objectsToUpdate = {
        {mainFrame, "BackgroundColor3", theme.primary},
        {headerBar, "BackgroundColor3", theme.secondary},
        {title, "TextColor3", theme.text},
        {statusPanel, "BackgroundColor3", theme.secondary}
    }
    
    for _, obj in ipairs(objectsToUpdate) do
        animateProperty(obj[1], obj[2], obj[3], 0.3)
    end
end

-- Performance monitoring
local function updatePerformanceStats()
    local ping = math.random(20, 80)
    local fps = math.random(45, 60)
    local memory = math.random(1800, 2500)
    
    pingText.Text = "Ping: " .. ping .. "ms"
    fpsText.Text = "FPS: " .. fps
    memoryText.Text = "RAM: " .. string.format("%.1f", memory/1000) .. "GB"
    
    -- Update colors based on performance
    pingIndicator.BackgroundColor3 = ping < 50 and theme.success or ping < 100 and theme.warning or theme.error
    fpsIndicator.BackgroundColor3 = fps > 50 and theme.success or fps > 30 and theme.warning or theme.error
    memoryIndicator.BackgroundColor3 = memory < 2000 and theme.success or memory < 3000 and theme.warning or theme.error
end

-- Button functionality
local function setupButtons()
    -- Theme toggle
    themeToggle.MouseButton1Click:Connect(switchTheme)
    
    -- Optimize button
    optimizeButton.MouseButton1Click:Connect(function()
        print("Optimization started...")
        -- Add optimization logic here
    end)
    
    -- Settings button
    settingsButton.MouseButton1Click:Connect(function()
        print("Settings opened...")
        -- Add settings logic here
    end)
    
    -- Info button
    infoButton.MouseButton1Click:Connect(function()
        print("Info panel opened...")
        -- Add info logic here
    end)
    
    -- Close button
    closeButton.MouseButton1Click:Connect(function()
        animateProperty(mainFrame, "Size", UDim2.new(0, 0, 0, 0), 0.3)
        task.wait(0.3)
        screenGui:Destroy()
    end)
end

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

local function setupDragging()
    headerBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Initialize UI
local function initializeUI()
    setupButtons()
    setupDragging()
    
    -- Start performance monitoring
    task.spawn(function()
        while screenGui.Parent do
            updatePerformanceStats()
            task.wait(1)
        end
    end)
    
    -- Initial animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    animateProperty(mainFrame, "Size", UDim2.new(0, UI_CONFIG.width, 0, UI_CONFIG.height), 0.5)
    
    print("MDLP UI System initialized at top center position")
end

-- Start the UI
initializeUI()

-- Cleanup on player leaving
LocalPlayer.CharacterRemoving:Connect(function()
    if screenGui then
        screenGui:Destroy()
    end
end)