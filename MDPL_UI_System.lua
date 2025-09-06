--// MDPL UI System - Mobile Optimized
--// Height & Position Control for Top Center UI
--// Lightweight with Debouncing System

-- Delay untuk stealth loading
task.wait(math.random(1, 3))

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Player references
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Mobile detection
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_CONSOLE = UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled

-- Performance settings based on device
local PERFORMANCE_LEVEL = "HIGH"
if IS_MOBILE then
    PERFORMANCE_LEVEL = "MEDIUM"
    if GuiService:GetGuiInset().Y > 0 then
        PERFORMANCE_LEVEL = "LOW" -- Older mobile devices
    end
end

-- Debouncing system
local DebounceManager = {
    timers = {},
    default_delay = 0.1,
    
    -- Debounce function calls
    debounce = function(self, key, func, delay)
        delay = delay or self.default_delay
        
        if self.timers[key] then
            self.timers[key]:Disconnect()
        end
        
        self.timers[key] = task.delay(delay, function()
            func()
            self.timers[key] = nil
        end)
    end,
    
    -- Clear all debounces
    clear = function(self)
        for key, timer in pairs(self.timers) do
            if timer then
                timer:Disconnect()
            end
        end
        self.timers = {}
    end
}

-- UI Configuration
local UI_CONFIG = {
    -- Base settings
    base_height = 50,
    min_height = 30,
    max_height = 120,
    height_step = 5,
    
    -- Position settings
    center_x = 0.5,
    top_y = 0.05,
    margin = 20,
    
    -- Animation settings
    tween_duration = 0.3,
    tween_easing = Enum.EasingStyle.Quart,
    
    -- Mobile optimizations
    mobile_scale = 0.8,
    touch_padding = 10,
    
    -- Performance settings
    update_throttle = 0.016, -- ~60 FPS
    render_throttle = 0.033, -- ~30 FPS for mobile
}

-- Current UI state
local UI_STATE = {
    height = UI_CONFIG.base_height,
    position = Vector2.new(0.5, 0.05),
    visible = true,
    dragging = false,
    last_update = 0,
}

-- UI Elements
local MainFrame
local HeightSlider
local PositionButton
local CloseButton
local StatusLabel

-- Create optimized UI elements
local function createUI()
    -- Main Frame
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MDPL_UI"
    MainFrame.Size = UDim2.new(0, 300, 0, UI_STATE.height)
    MainFrame.Position = UDim2.new(UI_STATE.position.X, -150, UI_STATE.position.Y, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndex = 10
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = MainFrame
    
    -- Drop shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 9
    shadow.Parent = MainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 11
    titleBar.Parent = MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "MDPL UI Control"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 14
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 12
    titleText.Parent = titleBar
    
    -- Close button
    CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 2.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.ZIndex = 12
    CloseButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = CloseButton
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -40)
    contentArea.Position = UDim2.new(0, 10, 0, 35)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex = 11
    contentArea.Parent = MainFrame
    
    -- Height control section
    local heightSection = Instance.new("Frame")
    heightSection.Name = "HeightSection"
    heightSection.Size = UDim2.new(1, 0, 0, 60)
    heightSection.Position = UDim2.new(0, 0, 0, 0)
    heightSection.BackgroundTransparency = 1
    heightSection.Parent = contentArea
    
    -- Height label
    local heightLabel = Instance.new("TextLabel")
    heightLabel.Name = "HeightLabel"
    heightLabel.Size = UDim2.new(1, 0, 0, 20)
    heightLabel.Position = UDim2.new(0, 0, 0, 0)
    heightLabel.BackgroundTransparency = 1
    heightLabel.Text = "Height: " .. UI_STATE.height .. "px"
    heightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    heightLabel.TextSize = 12
    heightLabel.Font = Enum.Font.SourceSans
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    heightLabel.Parent = heightSection
    
    -- Height slider
    HeightSlider = Instance.new("SliderGui")
    HeightSlider.Name = "HeightSlider"
    HeightSlider.Size = UDim2.new(1, 0, 0, 20)
    HeightSlider.Position = UDim2.new(0, 0, 0, 25)
    HeightSlider.Parent = heightSection
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, 0, 0, 4)
    sliderTrack.Position = UDim2.new(0, 0, 0.5, -2)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = HeightSlider
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = "Handle"
    sliderHandle.Size = UDim2.new(0, 16, 0, 16)
    sliderHandle.Position = UDim2.new(0.5, -8, 0.5, -8)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Parent = HeightSlider
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 8)
    handleCorner.Parent = sliderHandle
    
    -- Position control section
    local positionSection = Instance.new("Frame")
    positionSection.Name = "PositionSection"
    positionSection.Size = UDim2.new(1, 0, 0, 40)
    positionSection.Position = UDim2.new(0, 0, 0, 70)
    positionSection.BackgroundTransparency = 1
    positionSection.Parent = contentArea
    
    -- Position button
    PositionButton = Instance.new("TextButton")
    PositionButton.Name = "PositionButton"
    PositionButton.Size = UDim2.new(0.6, 0, 0, 30)
    PositionButton.Position = UDim2.new(0, 0, 0, 0)
    PositionButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    PositionButton.BorderSizePixel = 0
    PositionButton.Text = "Reset Position"
    PositionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PositionButton.TextSize = 12
    PositionButton.Font = Enum.Font.SourceSansBold
    PositionButton.Parent = positionSection
    
    local posCorner = Instance.new("UICorner")
    posCorner.CornerRadius = UDim.new(0, 6)
    posCorner.Parent = PositionButton
    
    -- Status label
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(0.35, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0.65, 0, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Active"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.SourceSansBold
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    StatusLabel.Parent = positionSection
    
    -- Mobile optimizations
    if IS_MOBILE then
        MainFrame.Size = UDim2.new(0, 300 * UI_CONFIG.mobile_scale, 0, UI_STATE.height * UI_CONFIG.mobile_scale)
        titleText.TextSize = 12
        heightLabel.TextSize = 10
        PositionButton.TextSize = 10
        StatusLabel.TextSize = 10
    end
    
    -- Add to screen
    MainFrame.Parent = PlayerGui
    
    return MainFrame
end

-- Optimized UI update with throttling
local function updateUI()
    local currentTime = tick()
    
    -- Throttle updates based on performance level
    local throttleTime = UI_CONFIG.update_throttle
    if PERFORMANCE_LEVEL == "LOW" then
        throttleTime = UI_CONFIG.render_throttle
    end
    
    if currentTime - UI_STATE.last_update < throttleTime then
        return
    end
    
    UI_STATE.last_update = currentTime
    
    -- Update height display
    if HeightSlider and HeightSlider.Parent then
        local heightLabel = HeightSlider.Parent:FindFirstChild("HeightLabel")
        if heightLabel then
            heightLabel.Text = "Height: " .. UI_STATE.height .. "px"
        end
    end
    
    -- Update status
    if StatusLabel then
        StatusLabel.Text = UI_STATE.visible and "Active" or "Hidden"
        StatusLabel.TextColor3 = UI_STATE.visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    end
end

-- Smooth height adjustment with tweening
local function adjustHeight(newHeight)
    newHeight = math.clamp(newHeight, UI_CONFIG.min_height, UI_CONFIG.max_height)
    
    if UI_STATE.height == newHeight then return end
    
    UI_STATE.height = newHeight
    
    if MainFrame then
        local tweenInfo = TweenInfo.new(
            UI_CONFIG.tween_duration,
            UI_CONFIG.tween_easing,
            Enum.EasingDirection.Out
        )
        
        local tween = TweenService:Create(
            MainFrame,
            tweenInfo,
            {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, newHeight)}
        )
        
        tween:Play()
    end
    
    -- Debounced update
    DebounceManager:debounce("height_update", function()
        updateUI()
    end, 0.1)
end

-- Reset position to top center
local function resetPosition()
    UI_STATE.position = Vector2.new(UI_CONFIG.center_x, UI_CONFIG.top_y)
    
    if MainFrame then
        local tweenInfo = TweenInfo.new(
            UI_CONFIG.tween_duration,
            UI_CONFIG.tween_easing,
            Enum.EasingDirection.Out
        )
        
        local tween = TweenService:Create(
            MainFrame,
            tweenInfo,
            {Position = UDim2.new(UI_CONFIG.center_x, -MainFrame.Size.X.Offset/2, UI_CONFIG.top_y, 0)}
        )
        
        tween:Play()
    end
end

-- Toggle visibility
local function toggleVisibility()
    UI_STATE.visible = not UI_STATE.visible
    
    if MainFrame then
        MainFrame.Visible = UI_STATE.visible
    end
    
    updateUI()
end

-- Setup slider functionality
local function setupSlider()
    if not HeightSlider then return end
    
    local sliderTrack = HeightSlider:FindFirstChild("Track")
    local sliderFill = sliderTrack and sliderTrack:FindFirstChild("Fill")
    local sliderHandle = HeightSlider:FindFirstChild("Handle")
    
    if not (sliderTrack and sliderFill and sliderHandle) then return end
    
    local function updateSlider(value)
        local normalizedValue = (value - UI_CONFIG.min_height) / (UI_CONFIG.max_height - UI_CONFIG.min_height)
        normalizedValue = math.clamp(normalizedValue, 0, 1)
        
        sliderFill.Size = UDim2.new(normalizedValue, 0, 1, 0)
        sliderHandle.Position = UDim2.new(normalizedValue, -8, 0.5, -8)
    end
    
    -- Initialize slider
    updateSlider(UI_STATE.height)
    
    -- Handle input
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = HeightSlider.AbsolutePosition
            local sliderSize = HeightSlider.AbsoluteSize
            
            local relativeX = (mousePos.X - sliderPos.X) / sliderSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            local newHeight = UI_CONFIG.min_height + (relativeX * (UI_CONFIG.max_height - UI_CONFIG.min_height))
            newHeight = math.floor(newHeight / UI_CONFIG.height_step) * UI_CONFIG.height_step
            
            adjustHeight(newHeight)
        end
    end
    
    HeightSlider.InputBegan:Connect(onInput)
end

-- Setup button functionality
local function setupButtons()
    -- Close button
    if CloseButton then
        CloseButton.MouseButton1Click:Connect(function()
            DebounceManager:debounce("close_ui", function()
                toggleVisibility()
            end, 0.2)
        end)
    end
    
    -- Position button
    if PositionButton then
        PositionButton.MouseButton1Click:Connect(function()
            DebounceManager:debounce("reset_position", function()
                resetPosition()
            end, 0.2)
        end)
    end
end

-- Setup keyboard shortcuts
local function setupKeyboardShortcuts()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local key = input.KeyCode
        
        -- Toggle UI with F1
        if key == Enum.KeyCode.F1 then
            DebounceManager:debounce("toggle_ui", function()
                toggleVisibility()
            end, 0.1)
        end
        
        -- Reset position with F2
        if key == Enum.KeyCode.F2 then
            DebounceManager:debounce("reset_pos", function()
                resetPosition()
            end, 0.1)
        end
        
        -- Height adjustments with arrow keys
        if key == Enum.KeyCode.Up then
            DebounceManager:debounce("height_up", function()
                adjustHeight(UI_STATE.height + UI_CONFIG.height_step)
            end, 0.05)
        elseif key == Enum.KeyCode.Down then
            DebounceManager:debounce("height_down", function()
                adjustHeight(UI_STATE.height - UI_CONFIG.height_step)
            end, 0.05)
        end
    end)
end

-- Performance monitoring
local function setupPerformanceMonitoring()
    if PERFORMANCE_LEVEL == "LOW" then
        -- Reduce update frequency for low-end devices
        task.spawn(function()
            while true do
                updateUI()
                task.wait(UI_CONFIG.render_throttle)
            end
        end)
    else
        -- Normal update frequency
        RunService.Heartbeat:Connect(updateUI)
    end
end

-- Cleanup function
local function cleanup()
    if MainFrame then
        MainFrame:Destroy()
    end
    DebounceManager:clear()
end

-- Initialize UI system
local function initialize()
    print("[MDPL UI] Initializing...")
    print("[MDPL UI] Device: " .. (IS_MOBILE and "Mobile" or "Desktop"))
    print("[MDPL UI] Performance Level: " .. PERFORMANCE_LEVEL)
    
    -- Create UI
    createUI()
    
    -- Setup functionality
    setupSlider()
    setupButtons()
    setupKeyboardShortcuts()
    setupPerformanceMonitoring()
    
    -- Initial update
    updateUI()
    
    print("[MDPL UI] System initialized successfully!")
    print("[MDPL UI] Controls:")
    print("  F1 - Toggle UI")
    print("  F2 - Reset Position")
    print("  ↑/↓ - Adjust Height")
    print("  Slider - Fine Height Control")
    print("  Reset Button - Center Position")
end

-- Cleanup on player leaving
LocalPlayer.CharacterRemoving:Connect(cleanup)

-- Start the system
initialize()

-- Export for external access
_G.MDPL_UI = {
    adjustHeight = adjustHeight,
    resetPosition = resetPosition,
    toggleVisibility = toggleVisibility,
    getState = function() return UI_STATE end,
    cleanup = cleanup
}