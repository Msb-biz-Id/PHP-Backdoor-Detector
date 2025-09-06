--// MDLP UI - Mobile Quick Setup
--// Simplified version for easy mobile installation
--// Just copy-paste and execute!

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Mobile detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Simple debounce
local lastClick = 0
local function debounce(delay)
    delay = delay or 0.3
    if tick() - lastClick < delay then return false end
    lastClick = tick()
    return true
end

-- Mobile config
local config = {
    width = isMobile and 320 or 380,
    height = isMobile and 220 or 280,
    cornerRadius = 8,
    padding = 12,
    fontSize = isMobile and 11 or 13,
    animationSpeed = 0.2
}

-- Position control
local position = {
    currentY = 20,
    currentHeight = config.height,
    snapPositions = {10, 20, 40, 60, 80, 100},
    currentSnapIndex = 2
}

-- Theme
local theme = {
    primary = Color3.fromRGB(20, 20, 20),
    secondary = Color3.fromRGB(30, 30, 30),
    accent = Color3.fromRGB(0, 162, 255),
    text = Color3.fromRGB(255, 255, 255),
    success = Color3.fromRGB(46, 204, 113),
    warning = Color3.fromRGB(241, 196, 15),
    error = Color3.fromRGB(231, 76, 60)
}

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MDLP_Mobile_Quick"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = isMobile
screenGui.Parent = PlayerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, config.width, 0, position.currentHeight)
mainFrame.Position = UDim2.new(0.5, -config.width/2, 0, position.currentY)
mainFrame.BackgroundColor3 = theme.primary
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, config.cornerRadius)
corner.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = theme.secondary
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, config.cornerRadius)
headerCorner.Parent = header

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MDLP " .. (isMobile and "Mobile" or "PC")
title.TextColor3 = theme.text
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = config.fontSize
title.ZIndex = 3
title.Parent = header

-- Position controls
local upBtn = Instance.new("TextButton")
upBtn.Name = "UpBtn"
upBtn.Size = UDim2.new(0, 25, 0, 25)
upBtn.Position = UDim2.new(1, -70, 0.5, -12)
upBtn.BackgroundColor3 = theme.accent
upBtn.BorderSizePixel = 0
upBtn.Text = "▲"
upBtn.TextColor3 = Color3.new(1, 1, 1)
upBtn.TextScaled = true
upBtn.Font = Enum.Font.Gotham
upBtn.ZIndex = 3
upBtn.Parent = header

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 4)
upCorner.Parent = upBtn

local downBtn = Instance.new("TextButton")
downBtn.Name = "DownBtn"
downBtn.Size = UDim2.new(0, 25, 0, 25)
downBtn.Position = UDim2.new(1, -40, 0.5, -12)
downBtn.BackgroundColor3 = theme.accent
downBtn.BorderSizePixel = 0
downBtn.Text = "▼"
downBtn.TextColor3 = Color3.new(1, 1, 1)
downBtn.TextScaled = true
downBtn.Font = Enum.Font.Gotham
downBtn.ZIndex = 3
downBtn.Parent = header

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 4)
downCorner.Parent = downBtn

-- Content
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -config.padding*2, 1, -50)
content.Position = UDim2.new(0, config.padding, 0, 45)
content.BackgroundTransparency = 1
content.ZIndex = 2
content.Parent = mainFrame

-- Status
local status = Instance.new("Frame")
status.Name = "Status"
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 0, 0)
status.BackgroundColor3 = theme.secondary
status.BorderSizePixel = 0
status.ZIndex = 2
status.Parent = content

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = status

-- Status grid
local statusGrid = Instance.new("UIGridLayout")
statusGrid.CellSize = UDim2.new(0, 60, 1, -6)
statusGrid.CellPadding = UDim2.new(0, 3, 0, 3)
statusGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
statusGrid.VerticalAlignment = Enum.VerticalAlignment.Center
statusGrid.SortOrder = Enum.SortOrder.LayoutOrder
statusGrid.Parent = status

-- Status indicators
local function createStatus(name, color, text, order)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.LayoutOrder = order
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = status
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 4)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextSize = config.fontSize
    label.Parent = frame
    
    return frame, label
end

local pingFrame, pingText = createStatus("Ping", theme.success, "45ms", 1)
local fpsFrame, fpsText = createStatus("FPS", theme.accent, "60", 2)
local memFrame, memText = createStatus("RAM", theme.warning, "2.1GB", 3)

-- Controls
local controls = Instance.new("Frame")
controls.Name = "Controls"
controls.Size = UDim2.new(1, 0, 1, -35)
controls.Position = UDim2.new(0, 0, 0, 35)
controls.BackgroundTransparency = 1
controls.ZIndex = 2
controls.Parent = content

local controlGrid = Instance.new("UIGridLayout")
controlGrid.CellSize = UDim2.new(0.5, -5, 0, 30)
controlGrid.CellPadding = UDim2.new(0, 3, 0, 5)
controlGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
controlGrid.VerticalAlignment = Enum.VerticalAlignment.Top
controlGrid.SortOrder = Enum.SortOrder.LayoutOrder
controlGrid.Parent = controls

-- Control buttons
local function createButton(name, text, color, order, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.LayoutOrder = order
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.TextSize = config.fontSize
    btn.ZIndex = 3
    btn.Parent = controls
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        if debounce() and callback then
            callback()
        end
    end)
    
    return btn
end

-- Animation
local function animate(obj, prop, val, dur)
    local tween = TweenService:Create(obj, TweenInfo.new(dur or config.animationSpeed, Enum.EasingStyle.Quad), {[prop] = val})
    tween:Play()
    return tween
end

-- Position functions
local function moveUp()
    if position.currentSnapIndex > 1 then
        position.currentSnapIndex = position.currentSnapIndex - 1
        position.currentY = position.snapPositions[position.currentSnapIndex]
        animate(mainFrame, "Position", UDim2.new(0.5, -config.width/2, 0, position.currentY))
    end
end

local function moveDown()
    if position.currentSnapIndex < #position.snapPositions then
        position.currentSnapIndex = position.currentSnapIndex + 1
        position.currentY = position.snapPositions[position.currentSnapIndex]
        animate(mainFrame, "Position", UDim2.new(0.5, -config.width/2, 0, position.currentY))
    end
end

-- Setup buttons
upBtn.MouseButton1Click:Connect(function() if debounce() then moveUp() end end)
downBtn.MouseButton1Click:Connect(function() if debounce() then moveDown() end end)

createButton("OptBtn", "Optimize", theme.success, 1, function()
    print("Optimization started...")
end)

createButton("SetBtn", "Settings", theme.accent, 2, function()
    print("Settings opened...")
end)

createButton("InfoBtn", "Info", theme.warning, 3, function()
    print("Info panel opened...")
end)

createButton("CloseBtn", "Close", theme.error, 4, function()
    animate(mainFrame, "Size", UDim2.new(0, 0, 0, 0), 0.3)
    task.wait(0.3)
    screenGui:Destroy()
end)

-- Performance update
task.spawn(function()
    while screenGui.Parent do
        local ping = math.random(20, 80)
        local fps = math.random(45, 60)
        local mem = math.random(1800, 2500)
        
        pingText.Text = ping .. "ms"
        fpsText.Text = fps
        memText.Text = string.format("%.1fGB", mem/1000)
        
        pingFrame.BackgroundColor3 = ping < 50 and theme.success or ping < 100 and theme.warning or theme.error
        fpsFrame.BackgroundColor3 = fps > 50 and theme.success or fps > 30 and theme.warning or theme.error
        memFrame.BackgroundColor3 = mem < 2000 and theme.success or mem < 3000 and theme.warning or theme.error
        
        task.wait(1)
    end
end)

-- Initial animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
animate(mainFrame, "Size", UDim2.new(0, config.width, 0, position.currentHeight), 0.5)

print("MDLP Mobile UI Quick Setup loaded!")
print("Platform: " .. (isMobile and "Mobile" or "PC"))
print("Position: Y=" .. position.currentY .. ", Height=" .. position.currentHeight)

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    if screenGui then screenGui:Destroy() end
end)