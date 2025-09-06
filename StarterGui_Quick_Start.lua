--// StarterGui Position UI - Quick Start
--// UI otomatis muncul untuk semua player
--// Minimal setup dengan performance

-- Delay untuk stealth
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

-- Configuration
local CONFIG = {
    ui_width = IS_MOBILE and 250 or 300,
    ui_height = IS_MOBILE and 300 or 350,
    max_players = IS_MOBILE and 5 or 7,
    update_interval = 0.2,
    ui_position = UDim2.new(0, 10, 0, 10),
}

-- Data storage
local player_data = {}
local ui_elements = {}
local last_update = 0
local is_visible = true

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

-- Get player data
local function getPlayerData(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local rootPart = player.Character.HumanoidRootPart
    local humanoid = player.Character:FindFirstChild("Humanoid")
    
    if not rootPart or not humanoid then
        return nil
    end
    
    local position = rootPart.Position
    local height = position.Y
    local speed = rootPart.Velocity.Magnitude
    
    return {
        name = player.Name,
        display_name = player.DisplayName,
        position = position,
        height = height,
        speed = speed,
        health = humanoid.Health,
        max_health = humanoid.MaxHealth
    }
end

-- Create UI
local function createUI()
    -- Main Frame
    local main_frame = Instance.new("Frame")
    main_frame.Name = "PositionUI_Quick"
    main_frame.Size = UDim2.new(0, CONFIG.ui_width, 0, CONFIG.ui_height)
    main_frame.Position = CONFIG.ui_position
    main_frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main_frame.BorderSizePixel = 0
    main_frame.Active = true
    main_frame.Draggable = true
    main_frame.ZIndex = 10
    main_frame.Parent = PlayerGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = main_frame
    
    -- Title
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    title.BorderSizePixel = 0
    title.Parent = main_frame
    
    local title_corner = Instance.new("UICorner")
    title_corner.CornerRadius = UDim.new(0, 6)
    title_corner.Parent = title
    
    local title_text = Instance.new("TextLabel")
    title_text.Size = UDim2.new(1, -30, 1, 0)
    title_text.Position = UDim2.new(0, 5, 0, 0)
    title_text.BackgroundTransparency = 1
    title_text.Text = "Position Tracker"
    title_text.TextColor3 = Color3.fromRGB(255, 255, 255)
    title_text.TextSize = IS_MOBILE and 10 or 11
    title_text.Font = Enum.Font.SourceSansBold
    title_text.TextXAlignment = Enum.TextXAlignment.Left
    title_text.Parent = title
    
    -- Toggle button
    local toggle_btn = Instance.new("TextButton")
    toggle_btn.Size = UDim2.new(0, 20, 0, 20)
    toggle_btn.Position = UDim2.new(1, -25, 0, 5)
    toggle_btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle_btn.BorderSizePixel = 0
    toggle_btn.Text = "−"
    toggle_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle_btn.TextSize = 12
    toggle_btn.Font = Enum.Font.SourceSansBold
    toggle_btn.Parent = title
    
    local toggle_corner = Instance.new("UICorner")
    toggle_corner.CornerRadius = UDim.new(0, 3)
    toggle_corner.Parent = toggle_btn
    
    -- Content area
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -8, 1, -40)
    content.Position = UDim2.new(0, 4, 0, 35)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    content.Parent = main_frame
    
    -- Player list
    local player_list = Instance.new("Frame")
    player_list.Size = UDim2.new(1, 0, 0, 0)
    player_list.Position = UDim2.new(0, 0, 0, 0)
    player_list.BackgroundTransparency = 1
    player_list.Parent = content
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 15)
    status.Position = UDim2.new(0, 0, 1, -18)
    status.BackgroundTransparency = 1
    status.Text = "Loading..."
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextSize = 8
    status.Font = Enum.Font.SourceSans
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Parent = main_frame
    
    -- Store UI elements
    ui_elements = {
        main_frame = main_frame,
        content = content,
        player_list = player_list,
        status = status,
        toggle_btn = toggle_btn,
        minimized = false
    }
    
    -- Toggle functionality
    toggle_btn.MouseButton1Click:Connect(function()
        debounce("toggle", function()
            ui_elements.minimized = not ui_elements.minimized
            
            if ui_elements.minimized then
                local tween = TweenService:Create(
                    main_frame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quart),
                    {Size = UDim2.new(0, CONFIG.ui_width, 0, 30)}
                )
                tween:Play()
                toggle_btn.Text = "+"
                content.Visible = false
            else
                local tween = TweenService:Create(
                    main_frame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quart),
                    {Size = UDim2.new(0, CONFIG.ui_width, 0, CONFIG.ui_height)}
                )
                tween:Play()
                toggle_btn.Text = "−"
                content.Visible = true
            end
        end, 0.1)
    end)
    
    return main_frame
end

-- Create player info frame
local function createPlayerInfo(data, index)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 40)
    frame.Position = UDim2.new(0, 2, 0, (index - 1) * 45)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = ui_elements.player_list
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    -- Name
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -8, 0, 14)
    name.Position = UDim2.new(0, 4, 0, 4)
    name.BackgroundTransparency = 1
    name.Text = data.display_name or data.name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextSize = IS_MOBILE and 9 or 10
    name.Font = Enum.Font.SourceSansBold
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = frame
    
    -- Position
    local pos = Instance.new("TextLabel")
    pos.Size = UDim2.new(1, -8, 0, 12)
    pos.Position = UDim2.new(0, 4, 0, 20)
    pos.BackgroundTransparency = 1
    pos.Text = string.format("Pos: %.0f, %.0f, %.0f", data.position.X, data.position.Y, data.position.Z)
    pos.TextColor3 = Color3.fromRGB(200, 200, 200)
    pos.TextSize = IS_MOBILE and 7 or 8
    pos.Font = Enum.Font.SourceSans
    pos.TextXAlignment = Enum.TextXAlignment.Left
    pos.Parent = frame
    
    -- Height
    local height = Instance.new("TextLabel")
    height.Size = UDim2.new(0.6, -4, 0, 12)
    height.Position = UDim2.new(0, 4, 0, 32)
    height.BackgroundTransparency = 1
    height.Text = string.format("Height: %.1f", data.height)
    height.TextColor3 = Color3.fromRGB(0, 255, 150)
    height.TextSize = IS_MOBILE and 7 or 8
    height.Font = Enum.Font.SourceSansBold
    height.TextXAlignment = Enum.TextXAlignment.Left
    height.Parent = frame
    
    -- Speed
    local speed = Instance.new("TextLabel")
    speed.Size = UDim2.new(0.4, -4, 0, 12)
    speed.Position = UDim2.new(0.6, 0, 0, 32)
    speed.BackgroundTransparency = 1
    speed.Text = string.format("Speed: %.0f", data.speed)
    speed.TextColor3 = Color3.fromRGB(255, 200, 0)
    speed.TextSize = IS_MOBILE and 7 or 8
    speed.Font = Enum.Font.SourceSans
    speed.TextXAlignment = Enum.TextXAlignment.Right
    speed.Parent = frame
    
    return frame
end

-- Update UI
local function updateUI()
    local current_time = tick()
    
    if current_time - last_update < CONFIG.update_interval then
        return
    end
    
    last_update = current_time
    
    -- Get player data
    local all_players = Players:GetPlayers()
    local valid_players = {}
    
    for _, player in ipairs(all_players) do
        local data = getPlayerData(player)
        if data then
            player_data[player] = data
            table.insert(valid_players, data)
        end
    end
    
    -- Sort by height
    table.sort(valid_players, function(a, b)
        return a.height > b.height
    end)
    
    -- Limit display
    local display_players = {}
    for i = 1, math.min(#valid_players, CONFIG.max_players) do
        display_players[i] = valid_players[i]
    end
    
    -- Update UI
    if ui_elements.player_list then
        -- Clear existing
        for _, child in ipairs(ui_elements.player_list:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Create new
        for i, data in ipairs(display_players) do
            createPlayerInfo(data, i)
        end
        
        -- Update status
        ui_elements.status.Text = string.format("Tracking %d players", #display_players)
        ui_elements.content.CanvasSize = UDim2.new(0, 0, 0, #display_players * 45)
    end
end

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode
    if key == Enum.KeyCode.F1 then
        debounce("toggle_visibility", function()
            is_visible = not is_visible
            if ui_elements.main_frame then
                ui_elements.main_frame.Visible = is_visible
            end
        end, 0.1)
    elseif key == Enum.KeyCode.F2 then
        debounce("reset_position", function()
            if ui_elements.main_frame then
                local tween = TweenService:Create(
                    ui_elements.main_frame,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quart),
                    {Position = CONFIG.ui_position}
                )
                tween:Play()
            end
        end, 0.1)
    end
end)

-- Initialize
local function initialize()
    print("[StarterGui Position UI] Quick Start initializing...")
    print("[StarterGui Position UI] Device: " .. (IS_MOBILE and "Mobile" or "Desktop"))
    
    -- Create UI
    createUI()
    
    -- Start update loop
    task.spawn(function()
        while true do
            updateUI()
            wait(CONFIG.update_interval)
        end
    end)
    
    print("[StarterGui Position UI] Quick Start ready!")
    print("Controls: F1=Toggle, F2=Reset, Drag=Move")
end

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    if ui_elements.main_frame then
        ui_elements.main_frame:Destroy()
    end
    for _, timer in pairs(debounce_timers) do
        if timer then timer:Disconnect() end
    end
end)

-- Start
initialize()

-- Export
_G.StarterGuiPositionUI_Quick = {
    updateUI = updateUI,
    getPlayerData = getPlayerData,
    config = CONFIG,
    toggleVisibility = function()
        is_visible = not is_visible
        if ui_elements.main_frame then
            ui_elements.main_frame.Visible = is_visible
        end
    end
}