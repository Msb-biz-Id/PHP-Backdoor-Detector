--// MDPL UI System - Quick Start Version
--// Minimal setup untuk testing cepat
--// Mobile Optimized dengan Debouncing

-- Stealth delay
task.wait(math.random(1, 2))

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Mobile detection
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Debouncing
local debounce_timers = {}

local function debounce(key, func, delay)
    delay = delay or 0.1
    if debounce_timers[key] then
        debounce_timers[key]:Disconnect()
    end
    debounce_timers[key] = task.delay(delay, function()
        func()
        debounce_timers[key] = nil
    end)
end

-- UI State
local UI_STATE = {
    height = 50,
    visible = true,
    position = Vector2.new(0.5, 0.05)
}

-- Create simple UI
local function createSimpleUI()
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MDPL_Quick_UI"
    MainFrame.Size = UDim2.new(0, 250, 0, UI_STATE.height)
    MainFrame.Position = UDim2.new(UI_STATE.position.X, -125, UI_STATE.position.Y, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndex = 10
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = MainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "MDPL Quick Control"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 12
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = MainFrame
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = MainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 3)
    closeCorner.Parent = closeBtn
    
    -- Height label
    local heightLabel = Instance.new("TextLabel")
    heightLabel.Size = UDim2.new(1, -20, 0, 20)
    heightLabel.Position = UDim2.new(0, 10, 0, 30)
    heightLabel.BackgroundTransparency = 1
    heightLabel.Text = "Height: " .. UI_STATE.height .. "px"
    heightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    heightLabel.TextSize = 10
    heightLabel.Font = Enum.Font.SourceSans
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    heightLabel.Parent = MainFrame
    
    -- Height buttons
    local heightUp = Instance.new("TextButton")
    heightUp.Size = UDim2.new(0, 30, 0, 20)
    heightUp.Position = UDim2.new(0, 10, 0, 50)
    heightUp.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    heightUp.BorderSizePixel = 0
    heightUp.Text = "+"
    heightUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    heightUp.TextSize = 12
    heightUp.Font = Enum.Font.SourceSansBold
    heightUp.Parent = MainFrame
    
    local heightDown = Instance.new("TextButton")
    heightDown.Size = UDim2.new(0, 30, 0, 20)
    heightDown.Position = UDim2.new(0, 50, 0, 50)
    heightDown.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    heightDown.BorderSizePixel = 0
    heightDown.Text = "-"
    heightDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    heightDown.TextSize = 12
    heightDown.Font = Enum.Font.SourceSansBold
    heightDown.Parent = MainFrame
    
    -- Reset button
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 60, 0, 20)
    resetBtn.Position = UDim2.new(0, 90, 0, 50)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    resetBtn.BorderSizePixel = 0
    resetBtn.Text = "Reset"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.TextSize = 10
    resetBtn.Font = Enum.Font.SourceSansBold
    resetBtn.Parent = MainFrame
    
    -- Add corners to buttons
    local function addCorner(obj)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 3)
        c.Parent = obj
    end
    
    addCorner(heightUp)
    addCorner(heightDown)
    addCorner(resetBtn)
    
    -- Mobile scaling
    if IS_MOBILE then
        MainFrame.Size = UDim2.new(0, 200, 0, UI_STATE.height * 0.8)
        title.TextSize = 10
        heightLabel.TextSize = 9
        heightUp.TextSize = 10
        heightDown.TextSize = 10
        resetBtn.TextSize = 9
    end
    
    -- Functions
    local function updateHeight()
        heightLabel.Text = "Height: " .. UI_STATE.height .. "px"
        local tween = TweenService:Create(
            MainFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart),
            {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, UI_STATE.height)}
        )
        tween:Play()
    end
    
    local function adjustHeight(delta)
        UI_STATE.height = math.clamp(UI_STATE.height + delta, 30, 120)
        debounce("height_update", updateHeight, 0.1)
    end
    
    local function resetPosition()
        UI_STATE.position = Vector2.new(0.5, 0.05)
        local tween = TweenService:Create(
            MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart),
            {Position = UDim2.new(0.5, -MainFrame.Size.X.Offset/2, 0.05, 0)}
        )
        tween:Play()
    end
    
    local function toggleVisibility()
        UI_STATE.visible = not UI_STATE.visible
        MainFrame.Visible = UI_STATE.visible
    end
    
    -- Button connections
    closeBtn.MouseButton1Click:Connect(function()
        debounce("close", toggleVisibility, 0.2)
    end)
    
    heightUp.MouseButton1Click:Connect(function()
        debounce("height_up", function() adjustHeight(5) end, 0.05)
    end)
    
    heightDown.MouseButton1Click:Connect(function()
        debounce("height_down", function() adjustHeight(-5) end, 0.05)
    end)
    
    resetBtn.MouseButton1Click:Connect(function()
        debounce("reset", resetPosition, 0.2)
    end)
    
    -- Keyboard shortcuts
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local key = input.KeyCode
        if key == Enum.KeyCode.F1 then
            debounce("toggle", toggleVisibility, 0.1)
        elseif key == Enum.KeyCode.F2 then
            debounce("reset_pos", resetPosition, 0.1)
        elseif key == Enum.KeyCode.Up then
            debounce("height_up_kb", function() adjustHeight(5) end, 0.05)
        elseif key == Enum.KeyCode.Down then
            debounce("height_down_kb", function() adjustHeight(-5) end, 0.05)
        end
    end)
    
    MainFrame.Parent = PlayerGui
    
    -- Export functions
    _G.MDPL_Quick = {
        adjustHeight = adjustHeight,
        resetPosition = resetPosition,
        toggleVisibility = toggleVisibility,
        getState = function() return UI_STATE end
    }
    
    print("[MDPL Quick] UI loaded successfully!")
    print("Controls: F1=Toggle, F2=Reset, ↑/↓=Height")
    
    return MainFrame
end

-- Initialize
createSimpleUI()

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    for _, timer in pairs(debounce_timers) do
        if timer then timer:Disconnect() end
    end
end)