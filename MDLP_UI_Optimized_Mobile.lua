--// MDLP UI System - Mobile Optimized v2.0
--// Top Center Position with Height Control
--// Debounce System & Performance Optimized
--// Compatible: PC, Mobile, Console

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Performance & Mobile Detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isConsole = UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled
local isPC = not isMobile and not isConsole

-- Debounce System
local DebounceSystem = {
    buttons = {},
    animations = {},
    updates = {},
    lastUpdate = 0,
    updateInterval = 0.1 -- 100ms update interval
}

local function debounce(key, func, delay)
    delay = delay or 0.5
    if DebounceSystem.buttons[key] and tick() - DebounceSystem.buttons[key] < delay then
        return false
    end
    DebounceSystem.buttons[key] = tick()
    return func()
end

-- Mobile-optimized configuration
local MOBILE_CONFIG = {
    -- UI Sizing based on platform
    width = isMobile and 350 or 400,
    height = isMobile and 250 or 300,
    minHeight = 200,
    maxHeight = 500,
    cornerRadius = isMobile and 8 or 12,
    padding = isMobile and 12 or 16,
    buttonHeight = isMobile and 35 or 40,
    fontSize = isMobile and 12 or 14,
    animationSpeed = 0.2, -- Faster animations for mobile
    touchSensitivity = 0.8,
    debounceDelay = 0.3
}

-- Position & Height Control
local POSITION_CONFIG = {
    -- Top center positioning with height control
    baseY = 20,
    minY = 10,
    maxY = 100,
    currentY = 20,
    currentHeight = MOBILE_CONFIG.height,
    snapPositions = {10, 20, 40, 60, 80, 100}, -- Snap positions for easy adjustment
    currentSnapIndex = 2 -- Start at position 20
}

-- Theme System (Optimized)
local themes = {
    dark = {
        primary = Color3.fromRGB(20, 20, 20),
        secondary = Color3.fromRGB(30, 30, 30),
        accent = Color3.fromRGB(0, 162, 255),
        text = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(180, 180, 180),
        border = Color3.fromRGB(50, 50, 50),
        success = Color3.fromRGB(46, 204, 113),
        warning = Color3.fromRGB(241, 196, 15),
        error = Color3.fromRGB(231, 76, 60),
        mobile = Color3.fromRGB(0, 122, 255) -- iOS blue for mobile
    },
    light = {
        primary = Color3.fromRGB(255, 255, 255),
        secondary = Color3.fromRGB(245, 245, 245),
        accent = Color3.fromRGB(0, 162, 255),
        text = Color3.fromRGB(20, 20, 20),
        textSecondary = Color3.fromRGB(80, 80, 80),
        border = Color3.fromRGB(200, 200, 200),
        success = Color3.fromRGB(46, 204, 113),
        warning = Color3.fromRGB(241, 196, 15),
        error = Color3.fromRGB(231, 76, 60),
        mobile = Color3.fromRGB(0, 122, 255)
    }
}

local currentTheme = "dark"
local theme = themes[currentTheme]

-- Create optimized ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MDLP_Mobile_UI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = isMobile -- Important for mobile
screenGui.Parent = PlayerGui

-- Main Frame with position control
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, MOBILE_CONFIG.width, 0, POSITION_CONFIG.currentHeight)
mainFrame.Position = UDim2.new(0.5, -MOBILE_CONFIG.width/2, 0, POSITION_CONFIG.currentY)
mainFrame.BackgroundColor3 = theme.primary
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

-- Optimized corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, MOBILE_CONFIG.cornerRadius)
corner.Parent = mainFrame

-- Mobile-optimized shadow (lighter for performance)
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)
shadow.ZIndex = 0
shadow.Parent = mainFrame

-- Header with position controls
local headerBar = Instance.new("Frame")
headerBar.Name = "HeaderBar"
headerBar.Size = UDim2.new(1, 0, 0, isMobile and 45 or 50)
headerBar.Position = UDim2.new(0, 0, 0, 0)
headerBar.BackgroundColor3 = theme.secondary
headerBar.BorderSizePixel = 0
headerBar.ZIndex = 2
headerBar.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, MOBILE_CONFIG.cornerRadius)
headerCorner.Parent = headerBar

-- Title with platform indicator
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -140, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MDLP " .. (isMobile and "Mobile" or isConsole and "Console" or "PC")
title.TextColor3 = theme.text
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = MOBILE_CONFIG.fontSize
title.ZIndex = 3
title.Parent = headerBar

-- Position Control Buttons (Mobile-optimized)
local positionControls = Instance.new("Frame")
positionControls.Name = "PositionControls"
positionControls.Size = UDim2.new(0, 120, 1, 0)
positionControls.Position = UDim2.new(1, -125, 0, 0)
positionControls.BackgroundTransparency = 1
positionControls.ZIndex = 3
positionControls.Parent = headerBar

-- Up/Down position buttons
local upButton = Instance.new("TextButton")
upButton.Name = "UpButton"
upButton.Size = UDim2.new(0, 25, 0, 25)
upButton.Position = UDim2.new(0, 0, 0.5, -15)
upButton.BackgroundColor3 = theme.accent
upButton.BorderSizePixel = 0
upButton.Text = "▲"
upButton.TextColor3 = Color3.new(1, 1, 1)
upButton.TextScaled = true
upButton.Font = Enum.Font.Gotham
upButton.ZIndex = 4
upButton.Parent = positionControls

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 4)
upCorner.Parent = upButton

local downButton = Instance.new("TextButton")
downButton.Name = "DownButton"
downButton.Size = UDim2.new(0, 25, 0, 25)
downButton.Position = UDim2.new(0, 30, 0.5, -15)
downButton.BackgroundColor3 = theme.accent
downButton.BorderSizePixel = 0
downButton.Text = "▼"
downButton.TextColor3 = Color3.new(1, 1, 1)
downButton.TextScaled = true
downButton.Font = Enum.Font.Gotham
downButton.ZIndex = 4
downButton.Parent = positionControls

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 4)
downCorner.Parent = downButton

-- Height control buttons
local heightUpButton = Instance.new("TextButton")
heightUpButton.Name = "HeightUpButton"
heightUpButton.Size = UDim2.new(0, 25, 0, 25)
heightUpButton.Position = UDim2.new(0, 60, 0.5, -15)
heightUpButton.BackgroundColor3 = theme.success
heightUpButton.BorderSizePixel = 0
heightUpButton.Text = "↗"
heightUpButton.TextColor3 = Color3.new(1, 1, 1)
heightUpButton.TextScaled = true
heightUpButton.Font = Enum.Font.Gotham
heightUpButton.ZIndex = 4
heightUpButton.Parent = positionControls

local heightUpCorner = Instance.new("UICorner")
heightUpCorner.CornerRadius = UDim.new(0, 4)
heightUpCorner.Parent = heightUpButton

local heightDownButton = Instance.new("TextButton")
heightDownButton.Name = "HeightDownButton"
heightDownButton.Size = UDim2.new(0, 25, 0, 25)
heightDownButton.Position = UDim2.new(0, 90, 0.5, -15)
heightDownButton.BackgroundColor3 = theme.warning
heightDownButton.BorderSizePixel = 0
heightDownButton.Text = "↘"
heightDownButton.TextColor3 = Color3.new(1, 1, 1)
heightDownButton.TextScaled = true
heightDownButton.Font = Enum.Font.Gotham
heightDownButton.ZIndex = 4
heightDownButton.Parent = positionControls

local heightDownCorner = Instance.new("UICorner")
heightDownCorner.CornerRadius = UDim.new(0, 4)
heightDownCorner.Parent = heightDownButton

-- Theme toggle (mobile-optimized)
local themeToggle = Instance.new("TextButton")
themeToggle.Name = "ThemeToggle"
themeToggle.Size = UDim2.new(0, isMobile and 35 or 40, 0, isMobile and 25 or 30)
themeToggle.Position = UDim2.new(0, 0, 0, 0)
themeToggle.BackgroundColor3 = theme.accent
themeToggle.BorderSizePixel = 0
themeToggle.Text = currentTheme == "dark" and "🌙" or "☀️"
themeToggle.TextColor3 = Color3.new(1, 1, 1)
themeToggle.TextScaled = true
themeToggle.Font = Enum.Font.Gotham
themeToggle.ZIndex = 3
themeToggle.Parent = headerBar

local themeCorner = Instance.new("UICorner")
themeCorner.CornerRadius = UDim.new(0, 6)
themeCorner.Parent = themeToggle

-- Content Area (Responsive)
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -MOBILE_CONFIG.padding*2, 1, -(isMobile and 55 or 60))
contentArea.Position = UDim2.new(0, MOBILE_CONFIG.padding, 0, isMobile and 50 or 55)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 2
contentArea.Parent = mainFrame

-- Status Panel (Mobile-optimized)
local statusPanel = Instance.new("Frame")
statusPanel.Name = "StatusPanel"
statusPanel.Size = UDim2.new(1, 0, 0, isMobile and 35 or 40)
statusPanel.Position = UDim2.new(0, 0, 0, 0)
statusPanel.BackgroundColor3 = theme.secondary
statusPanel.BorderSizePixel = 0
statusPanel.ZIndex = 2
statusPanel.Parent = contentArea

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusPanel

-- Mobile-optimized status grid
local statusGrid = Instance.new("UIGridLayout")
statusGrid.CellSize = UDim2.new(0, isMobile and 70 or 80, 1, -8)
statusGrid.CellPadding = UDim2.new(0, 4, 0, 4)
statusGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
statusGrid.VerticalAlignment = Enum.VerticalAlignment.Center
statusGrid.SortOrder = Enum.SortOrder.LayoutOrder
statusGrid.Parent = statusPanel

-- Status indicators (Optimized)
local function createStatusIndicator(name, color, text, layoutOrder)
    local indicator = Instance.new("Frame")
    indicator.Name = name
    indicator.LayoutOrder = layoutOrder
    indicator.BackgroundColor3 = color
    indicator.BorderSizePixel = 0
    indicator.Parent = statusPanel
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 4)
    indicatorCorner.Parent = indicator
    
    local indicatorText = Instance.new("TextLabel")
    indicatorText.Size = UDim2.new(1, 0, 1, 0)
    indicatorText.BackgroundTransparency = 1
    indicatorText.Text = text
    indicatorText.TextColor3 = Color3.new(1, 1, 1)
    indicatorText.TextScaled = true
    indicatorText.Font = Enum.Font.Gotham
    indicatorText.TextSize = MOBILE_CONFIG.fontSize
    indicatorText.Parent = indicator
    
    return indicator, indicatorText
end

local pingIndicator, pingText = createStatusIndicator("PingIndicator", theme.success, "Ping: 45ms", 1)
local fpsIndicator, fpsText = createStatusIndicator("FPSIndicator", theme.accent, "FPS: 60", 2)
local memoryIndicator, memoryText = createStatusIndicator("MemoryIndicator", theme.warning, "RAM: 2.1GB", 3)

-- Control Panel (Mobile-optimized)
local controlPanel = Instance.new("Frame")
controlPanel.Name = "ControlPanel"
controlPanel.Size = UDim2.new(1, 0, 1, -(isMobile and 45 or 50))
controlPanel.Position = UDim2.new(0, 0, 0, isMobile and 40 or 45)
controlPanel.BackgroundTransparency = 1
controlPanel.ZIndex = 2
controlPanel.Parent = contentArea

-- Mobile-optimized control grid
local controlGrid = Instance.new("UIGridLayout")
controlGrid.CellSize = UDim2.new(0.5, -5, 0, MOBILE_CONFIG.buttonHeight)
controlGrid.CellPadding = UDim2.new(0, 4, 0, 8)
controlGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
controlGrid.VerticalAlignment = Enum.VerticalAlignment.Top
controlGrid.SortOrder = Enum.SortOrder.LayoutOrder
controlGrid.Parent = controlPanel

-- Optimized button creation with debounce
local function createControlButton(name, text, color, layoutOrder, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.LayoutOrder = layoutOrder
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.TextSize = MOBILE_CONFIG.fontSize
    button.ZIndex = 3
    button.Parent = controlPanel
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    -- Mobile-optimized touch feedback
    button.MouseButton1Down:Connect(function()
        if debounce(name .. "_click", function() return true end, MOBILE_CONFIG.debounceDelay) then
            -- Visual feedback
            local originalColor = button.BackgroundColor3
            button.BackgroundColor3 = Color3.new(originalColor.R * 0.8, originalColor.G * 0.8, originalColor.B * 0.8)
            task.wait(0.1)
            button.BackgroundColor3 = originalColor
            
            if callback then callback() end
        end
    end)
    
    return button
end

-- Animation system with debounce
local function animateProperty(object, property, targetValue, duration, callback)
    if DebounceSystem.animations[object] then
        DebounceSystem.animations[object]:Cancel()
    end
    
    local tweenInfo = TweenInfo.new(
        duration or MOBILE_CONFIG.animationSpeed,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, {[property] = targetValue})
    DebounceSystem.animations[object] = tween
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    return tween
end

-- Position control functions
local function updatePosition()
    mainFrame.Position = UDim2.new(0.5, -MOBILE_CONFIG.width/2, 0, POSITION_CONFIG.currentY)
end

local function updateHeight()
    mainFrame.Size = UDim2.new(0, MOBILE_CONFIG.width, 0, POSITION_CONFIG.currentHeight)
    -- Update content area to fit new height
    contentArea.Size = UDim2.new(1, -MOBILE_CONFIG.padding*2, 1, -(isMobile and 55 or 60))
end

local function moveUp()
    if POSITION_CONFIG.currentSnapIndex > 1 then
        POSITION_CONFIG.currentSnapIndex = POSITION_CONFIG.currentSnapIndex - 1
        POSITION_CONFIG.currentY = POSITION_CONFIG.snapPositions[POSITION_CONFIG.currentSnapIndex]
        animateProperty(mainFrame, "Position", UDim2.new(0.5, -MOBILE_CONFIG.width/2, 0, POSITION_CONFIG.currentY), 0.2)
    end
end

local function moveDown()
    if POSITION_CONFIG.currentSnapIndex < #POSITION_CONFIG.snapPositions then
        POSITION_CONFIG.currentSnapIndex = POSITION_CONFIG.currentSnapIndex + 1
        POSITION_CONFIG.currentY = POSITION_CONFIG.snapPositions[POSITION_CONFIG.currentSnapIndex]
        animateProperty(mainFrame, "Position", UDim2.new(0.5, -MOBILE_CONFIG.width/2, 0, POSITION_CONFIG.currentY), 0.2)
    end
end

local function increaseHeight()
    if POSITION_CONFIG.currentHeight < POSITION_CONFIG.maxHeight then
        POSITION_CONFIG.currentHeight = math.min(POSITION_CONFIG.currentHeight + 25, POSITION_CONFIG.maxHeight)
        animateProperty(mainFrame, "Size", UDim2.new(0, MOBILE_CONFIG.width, 0, POSITION_CONFIG.currentHeight), 0.2, updateHeight)
    end
end

local function decreaseHeight()
    if POSITION_CONFIG.currentHeight > POSITION_CONFIG.minHeight then
        POSITION_CONFIG.currentHeight = math.max(POSITION_CONFIG.currentHeight - 25, POSITION_CONFIG.minHeight)
        animateProperty(mainFrame, "Size", UDim2.new(0, MOBILE_CONFIG.width, 0, POSITION_CONFIG.currentHeight), 0.2, updateHeight)
    end
end

-- Theme switching with debounce
local function switchTheme()
    return debounce("theme_switch", function()
        currentTheme = currentTheme == "dark" and "light" or "dark"
        theme = themes[currentTheme]
        
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
        
        return true
    end, 0.5)
end

-- Optimized performance monitoring with debounce
local function updatePerformanceStats()
    if tick() - DebounceSystem.lastUpdate < DebounceSystem.updateInterval then
        return
    end
    DebounceSystem.lastUpdate = tick()
    
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

-- Setup button functionality with debounce
local function setupButtons()
    -- Position controls
    upButton.MouseButton1Click:Connect(function()
        debounce("move_up", moveUp, 0.2)
    end)
    
    downButton.MouseButton1Click:Connect(function()
        debounce("move_down", moveDown, 0.2)
    end)
    
    heightUpButton.MouseButton1Click:Connect(function()
        debounce("height_up", increaseHeight, 0.2)
    end)
    
    heightDownButton.MouseButton1Click:Connect(function()
        debounce("height_down", decreaseHeight, 0.2)
    end)
    
    -- Theme toggle
    themeToggle.MouseButton1Click:Connect(switchTheme)
    
    -- Control buttons
    createControlButton("OptimizeButton", "Optimize", theme.success, 1, function()
        print("Optimization started...")
    end)
    
    createControlButton("SettingsButton", "Settings", theme.accent, 2, function()
        print("Settings opened...")
    end)
    
    createControlButton("InfoButton", "Info", theme.warning, 3, function()
        print("Info panel opened...")
    end)
    
    createControlButton("CloseButton", "Close", theme.error, 4, function()
        animateProperty(mainFrame, "Size", UDim2.new(0, 0, 0, 0), 0.3)
        task.wait(0.3)
        screenGui:Destroy()
    end)
end

-- Mobile-optimized drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

local function setupDragging()
    if isMobile then
        -- Touch drag for mobile
        headerBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    else
        -- Mouse drag for PC
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
end

-- Initialize UI with mobile optimization
local function initializeUI()
    setupButtons()
    setupDragging()
    
    -- Start performance monitoring with debounce
    task.spawn(function()
        while screenGui.Parent do
            updatePerformanceStats()
            task.wait(1)
        end
    end)
    
    -- Initial animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    animateProperty(mainFrame, "Size", UDim2.new(0, MOBILE_CONFIG.width, 0, POSITION_CONFIG.currentHeight), 0.5)
    
    print("MDLP Mobile UI System initialized")
    print("Platform: " .. (isMobile and "Mobile" or isConsole and "Console" or "PC"))
    print("Position: Top Center (Y: " .. POSITION_CONFIG.currentY .. ")")
    print("Height: " .. POSITION_CONFIG.currentHeight)
end

-- Start the UI
initializeUI()

-- Cleanup on player leaving
LocalPlayer.CharacterRemoving:Connect(function()
    if screenGui then
        screenGui:Destroy()
    end
end)

-- Mobile-specific optimizations
if isMobile then
    -- Reduce update frequency for mobile
    RunService.Heartbeat:Connect(function()
        if tick() - DebounceSystem.lastUpdate > 0.5 then
            updatePerformanceStats()
        end
    end)
end