--// Server UI Script - Position & Height Display (OPTIMIZED)
--// Menampilkan posisi dan ketinggian semua player
--// High Performance dengan Debouncing & Caching

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Pre-calculate common values
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local string_format = string.format
local tick = tick
local wait = task.wait

-- Configuration
local CONFIG = {
    -- UI Settings
    ui_width = 280,
    ui_height = 350,
    max_players_display = 8,
    update_interval = 0.15, -- Reduced from 0.1 for better performance
    
    -- Position Settings
    ui_position = UDim2.new(0, 10, 0, 10),
    background_color = Color3.fromRGB(20, 20, 20),
    text_color = Color3.fromRGB(255, 255, 255),
    accent_color = Color3.fromRGB(0, 150, 255),
    
    -- Performance Settings
    enable_optimization = true,
    max_distance = 2000,
    enable_height_tracking = true,
    enable_velocity_tracking = true,
    enable_caching = true,
    cache_duration = 0.5,
    
    -- Mobile Optimization
    mobile_scale = 0.85,
    mobile_width = 250,
    mobile_height = 300,
}

-- Data storage with caching
local player_data = {}
local ui_elements = {}
local last_update = 0
local update_queue = {}
local cache_data = {}

-- Debouncing system
local DebounceManager = {
    timers = {},
    
    debounce = function(self, key, func, delay)
        delay = delay or 0.1
        if self.timers[key] then
            self.timers[key]:Disconnect()
        end
        self.timers[key] = task.delay(delay, function()
            func()
            self.timers[key] = nil
        end)
    end,
    
    clear = function(self)
        for key, timer in pairs(self.timers) do
            if timer then timer:Disconnect() end
        end
        self.timers = {}
    end
}

-- Mobile detection
local function isMobile(player)
    local player_gui = player:FindFirstChild("PlayerGui")
    if not player_gui then return false end
    
    -- Check for mobile-specific services
    local touch_gui = player_gui:FindFirstChild("TouchGui")
    return touch_gui ~= nil
end

-- Optimized player data retrieval with caching
local function getPlayerData(player)
    local current_time = tick()
    
    -- Check cache first
    if CONFIG.enable_caching and cache_data[player] then
        local cached_data = cache_data[player]
        if current_time - cached_data.cache_time < CONFIG.cache_duration then
            return cached_data.data
        end
    end
    
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
    local velocity = rootPart.Velocity
    local speed = velocity.Magnitude
    
    local data = {
        name = player.Name,
        display_name = player.DisplayName,
        position = position,
        height = height,
        velocity = velocity,
        speed = speed,
        health = humanoid.Health,
        max_health = humanoid.MaxHealth,
        last_update = current_time
    }
    
    -- Cache the data
    if CONFIG.enable_caching then
        cache_data[player] = {
            data = data,
            cache_time = current_time
        }
    end
    
    return data
end

-- Create optimized UI for a player
local function createPlayerUI(player)
    local player_gui = player:WaitForChild("PlayerGui")
    local is_mobile = isMobile(player)
    
    -- Adjust size for mobile
    local ui_width = is_mobile and CONFIG.mobile_width or CONFIG.ui_width
    local ui_height = is_mobile and CONFIG.mobile_height or CONFIG.ui_height
    
    -- Main Frame
    local main_frame = Instance.new("Frame")
    main_frame.Name = "PositionUI_Main"
    main_frame.Size = UDim2.new(0, ui_width, 0, ui_height)
    main_frame.Position = CONFIG.ui_position
    main_frame.BackgroundColor3 = CONFIG.background_color
    main_frame.BorderSizePixel = 0
    main_frame.ZIndex = 10
    main_frame.Parent = player_gui
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = main_frame
    
    -- Title bar
    local title_bar = Instance.new("Frame")
    title_bar.Name = "TitleBar"
    title_bar.Size = UDim2.new(1, 0, 0, 30)
    title_bar.Position = UDim2.new(0, 0, 0, 0)
    title_bar.BackgroundColor3 = CONFIG.accent_color
    title_bar.BorderSizePixel = 0
    title_bar.ZIndex = 11
    title_bar.Parent = main_frame
    
    local title_corner = Instance.new("UICorner")
    title_corner.CornerRadius = UDim.new(0, 6)
    title_corner.Parent = title_bar
    
    -- Title text
    local title_text = Instance.new("TextLabel")
    title_text.Name = "Title"
    title_text.Size = UDim2.new(1, -50, 1, 0)
    title_text.Position = UDim2.new(0, 8, 0, 0)
    title_text.BackgroundTransparency = 1
    title_text.Text = "Position Tracker"
    title_text.TextColor3 = Color3.fromRGB(255, 255, 255)
    title_text.TextSize = is_mobile and 11 or 12
    title_text.Font = Enum.Font.SourceSansBold
    title_text.TextXAlignment = Enum.TextXAlignment.Left
    title_text.ZIndex = 12
    title_text.Parent = title_bar
    
    -- Toggle button
    local toggle_button = Instance.new("TextButton")
    toggle_button.Name = "ToggleButton"
    toggle_button.Size = UDim2.new(0, 22, 0, 22)
    toggle_button.Position = UDim2.new(1, -25, 0, 4)
    toggle_button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle_button.BorderSizePixel = 0
    toggle_button.Text = "−"
    toggle_button.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle_button.TextSize = 14
    toggle_button.Font = Enum.Font.SourceSansBold
    toggle_button.ZIndex = 12
    toggle_button.Parent = title_bar
    
    local toggle_corner = Instance.new("UICorner")
    toggle_corner.CornerRadius = UDim.new(0, 3)
    toggle_corner.Parent = toggle_button
    
    -- Content area
    local content_area = Instance.new("ScrollingFrame")
    content_area.Name = "ContentArea"
    content_area.Size = UDim2.new(1, -8, 1, -40)
    content_area.Position = UDim2.new(0, 4, 0, 35)
    content_area.BackgroundTransparency = 1
    content_area.BorderSizePixel = 0
    content_area.ScrollBarThickness = 4
    content_area.ScrollBarImageColor3 = CONFIG.accent_color
    content_area.ZIndex = 11
    content_area.Parent = main_frame
    
    -- Player list
    local player_list = Instance.new("Frame")
    player_list.Name = "PlayerList"
    player_list.Size = UDim2.new(1, 0, 0, 0)
    player_list.Position = UDim2.new(0, 0, 0, 0)
    player_list.BackgroundTransparency = 1
    player_list.Parent = content_area
    
    -- Status label
    local status_label = Instance.new("TextLabel")
    status_label.Name = "StatusLabel"
    status_label.Size = UDim2.new(1, 0, 0, 18)
    status_label.Position = UDim2.new(0, 0, 1, -20)
    status_label.BackgroundTransparency = 1
    status_label.Text = "Loading..."
    status_label.TextColor3 = Color3.fromRGB(150, 150, 150)
    status_label.TextSize = 9
    status_label.Font = Enum.Font.SourceSans
    status_label.TextXAlignment = Enum.TextXAlignment.Center
    status_label.ZIndex = 11
    status_label.Parent = main_frame
    
    -- Store UI elements
    ui_elements[player] = {
        main_frame = main_frame,
        content_area = content_area,
        player_list = player_list,
        status_label = status_label,
        toggle_button = toggle_button,
        is_minimized = false,
        is_mobile = is_mobile
    }
    
    -- Toggle functionality with debouncing
    toggle_button.MouseButton1Click:Connect(function()
        DebounceManager:debounce("toggle_" .. player.UserId, function()
            local ui_data = ui_elements[player]
            if not ui_data then return end
            
            ui_data.is_minimized = not ui_data.is_minimized
            
            if ui_data.is_minimized then
                local tween = TweenService:Create(
                    main_frame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quart),
                    {Size = UDim2.new(0, ui_width, 0, 30)}
                )
                tween:Play()
                toggle_button.Text = "+"
                content_area.Visible = false
            else
                local tween = TweenService:Create(
                    main_frame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quart),
                    {Size = UDim2.new(0, ui_width, 0, ui_height)}
                )
                tween:Play()
                toggle_button.Text = "−"
                content_area.Visible = true
            end
        end, 0.1)
    end)
    
    return main_frame
end

-- Create optimized player info frame
local function createPlayerInfoFrame(player_data, index, is_mobile)
    local frame = Instance.new("Frame")
    frame.Name = "PlayerInfo_" .. player_data.name
    frame.Size = UDim2.new(1, -4, 0, is_mobile and 50 or 55)
    frame.Position = UDim2.new(0, 2, 0, (index - 1) * (is_mobile and 55 or 60))
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Parent = ui_elements[player_data.name] and ui_elements[player_data.name].player_list
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    -- Player name
    local name_label = Instance.new("TextLabel")
    name_label.Name = "PlayerName"
    name_label.Size = UDim2.new(1, -8, 0, 16)
    name_label.Position = UDim2.new(0, 4, 0, 4)
    name_label.BackgroundTransparency = 1
    name_label.Text = player_data.display_name or player_data.name
    name_label.TextColor3 = CONFIG.text_color
    name_label.TextSize = is_mobile and 10 or 11
    name_label.Font = Enum.Font.SourceSansBold
    name_label.TextXAlignment = Enum.TextXAlignment.Left
    name_label.Parent = frame
    
    -- Position info (compact)
    local pos_label = Instance.new("TextLabel")
    pos_label.Name = "Position"
    pos_label.Size = UDim2.new(1, -8, 0, 12)
    pos_label.Position = UDim2.new(0, 4, 0, 22)
    pos_label.BackgroundTransparency = 1
    pos_label.Text = string_format("Pos: %.0f, %.0f, %.0f", 
        player_data.position.X, player_data.position.Y, player_data.position.Z)
    pos_label.TextColor3 = Color3.fromRGB(200, 200, 200)
    pos_label.TextSize = is_mobile and 8 or 9
    pos_label.Font = Enum.Font.SourceSans
    pos_label.TextXAlignment = Enum.TextXAlignment.Left
    pos_label.Parent = frame
    
    -- Height info (highlighted)
    local height_label = Instance.new("TextLabel")
    height_label.Name = "Height"
    height_label.Size = UDim2.new(0.6, -4, 0, 12)
    height_label.Position = UDim2.new(0, 4, 0, 36)
    height_label.BackgroundTransparency = 1
    height_label.Text = string_format("Height: %.1f", player_data.height)
    height_label.TextColor3 = Color3.fromRGB(0, 255, 150)
    height_label.TextSize = is_mobile and 8 or 9
    height_label.Font = Enum.Font.SourceSansBold
    height_label.TextXAlignment = Enum.TextXAlignment.Left
    height_label.Parent = frame
    
    -- Speed info
    local speed_label = Instance.new("TextLabel")
    speed_label.Name = "Speed"
    speed_label.Size = UDim2.new(0.4, -4, 0, 12)
    speed_label.Position = UDim2.new(0.6, 0, 0, 36)
    speed_label.BackgroundTransparency = 1
    speed_label.Text = string_format("Speed: %.0f", player_data.speed)
    speed_label.TextColor3 = Color3.fromRGB(255, 200, 0)
    speed_label.TextSize = is_mobile and 8 or 9
    speed_label.Font = Enum.Font.SourceSans
    speed_label.TextXAlignment = Enum.TextXAlignment.Right
    speed_label.Parent = frame
    
    return frame
end

-- Optimized UI update with throttling
local function updateAllUIs()
    local current_time = tick()
    
    -- Throttle updates
    if current_time - last_update < CONFIG.update_interval then
        return
    end
    
    last_update = current_time
    
    -- Get all player data with optimization
    local all_players = Players:GetPlayers()
    local valid_players = {}
    
    for _, player in ipairs(all_players) do
        local data = getPlayerData(player)
        if data then
            player_data[player] = data
            table.insert(valid_players, data)
        end
    end
    
    -- Sort by height (highest first) - optimized
    table.sort(valid_players, function(a, b)
        return a.height > b.height
    end)
    
    -- Limit display count
    local display_players = {}
    local max_display = math_min(#valid_players, CONFIG.max_players_display)
    for i = 1, max_display do
        display_players[i] = valid_players[i]
    end
    
    -- Update UI for each player with debouncing
    for _, player in ipairs(all_players) do
        local ui_data = ui_elements[player]
        if ui_data and not ui_data.is_minimized then
            DebounceManager:debounce("update_ui_" .. player.UserId, function()
                -- Clear existing player info efficiently
                local children = ui_data.player_list:GetChildren()
                for i = #children, 1, -1 do
                    local child = children[i]
                    if child:IsA("Frame") and child.Name:find("PlayerInfo_") then
                        child:Destroy()
                    end
                end
                
                -- Create new player info frames
                for i, data in ipairs(display_players) do
                    createPlayerInfoFrame(data, i, ui_data.is_mobile)
                end
                
                -- Update status
                ui_data.status_label.Text = string_format("Tracking %d players", #display_players)
                
                -- Update content area size
                local item_height = ui_data.is_mobile and 55 or 60
                ui_data.content_area.CanvasSize = UDim2.new(0, 0, 0, #display_players * item_height)
            end, 0.05)
        end
    end
end

-- Player joined with optimization
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Reduced wait time
        createPlayerUI(player)
    end)
    
    if player.Character then
        createPlayerUI(player)
    end
end

-- Player leaving with cleanup
local function onPlayerRemoving(player)
    -- Clean up UI
    local ui_data = ui_elements[player]
    if ui_data and ui_data.main_frame then
        ui_data.main_frame:Destroy()
    end
    ui_elements[player] = nil
    player_data[player] = nil
    cache_data[player] = nil
    
    -- Clear debounce timers
    DebounceManager:debounce("update_ui_" .. player.UserId, function() end, 0)
end

-- Initialize with error handling
local function initialize()
    print("[Server Position UI] Initializing optimized version...")
    
    -- Connect events
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    -- Create UI for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end
    
    -- Start optimized update loop
    task.spawn(function()
        while true do
            updateAllUIs()
            wait(CONFIG.update_interval)
        end
    end)
    
    print("[Server Position UI] Optimized system initialized!")
    print("[Server Position UI] Performance level: " .. (CONFIG.enable_optimization and "HIGH" or "NORMAL"))
    print("[Server Position UI] Caching: " .. (CONFIG.enable_caching and "ENABLED" or "DISABLED"))
end

-- Start the system
initialize()

-- Export for external access
_G.ServerPositionUI = {
    updateAllUIs = updateAllUIs,
    getPlayerData = getPlayerData,
    config = CONFIG,
    player_data = player_data,
    cleanup = function()
        DebounceManager:clear()
        for player, ui_data in pairs(ui_elements) do
            if ui_data.main_frame then
                ui_data.main_frame:Destroy()
            end
        end
        ui_elements = {}
        player_data = {}
        cache_data = {}
    end
}