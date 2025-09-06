--// Server UI Script - Position & Height Display
--// Menampilkan posisi dan ketinggian semua player
--// Optimized untuk server performance

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local CONFIG = {
    -- UI Settings
    ui_width = 300,
    ui_height = 400,
    max_players_display = 10,
    update_interval = 0.1, -- Update every 0.1 seconds
    
    -- Position Settings
    ui_position = UDim2.new(0, 10, 0, 10), -- Top left corner
    background_color = Color3.fromRGB(20, 20, 20),
    text_color = Color3.fromRGB(255, 255, 255),
    accent_color = Color3.fromRGB(0, 150, 255),
    
    -- Performance Settings
    enable_optimization = true,
    max_distance = 1000, -- Only show players within this distance
    enable_height_tracking = true,
    enable_velocity_tracking = true,
}

-- Data storage
local player_data = {}
local ui_elements = {}
local last_update = 0

-- Create RemoteEvents for client communication
local function createRemoteEvents()
    local folder = Instance.new("Folder")
    folder.Name = "PositionUI_Remotes"
    folder.Parent = ReplicatedStorage
    
    local update_event = Instance.new("RemoteEvent")
    update_event.Name = "UpdatePositionData"
    update_event.Parent = folder
    
    local toggle_event = Instance.new("RemoteEvent")
    toggle_event.Name = "TogglePositionUI"
    toggle_event.Parent = folder
    
    return update_event, toggle_event
end

-- Get player position and height data
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
    local velocity = rootPart.Velocity
    local speed = velocity.Magnitude
    
    return {
        name = player.Name,
        display_name = player.DisplayName,
        position = position,
        height = height,
        velocity = velocity,
        speed = speed,
        health = humanoid.Health,
        max_health = humanoid.MaxHealth,
        last_update = tick()
    }
end

-- Create UI for a player
local function createPlayerUI(player)
    local player_gui = player:WaitForChild("PlayerGui")
    
    -- Main Frame
    local main_frame = Instance.new("Frame")
    main_frame.Name = "PositionUI_Main"
    main_frame.Size = UDim2.new(0, CONFIG.ui_width, 0, CONFIG.ui_height)
    main_frame.Position = CONFIG.ui_position
    main_frame.BackgroundColor3 = CONFIG.background_color
    main_frame.BorderSizePixel = 0
    main_frame.ZIndex = 10
    main_frame.Parent = player_gui
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main_frame
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 9
    shadow.Parent = main_frame
    
    -- Title bar
    local title_bar = Instance.new("Frame")
    title_bar.Name = "TitleBar"
    title_bar.Size = UDim2.new(1, 0, 0, 35)
    title_bar.Position = UDim2.new(0, 0, 0, 0)
    title_bar.BackgroundColor3 = CONFIG.accent_color
    title_bar.BorderSizePixel = 0
    title_bar.ZIndex = 11
    title_bar.Parent = main_frame
    
    local title_corner = Instance.new("UICorner")
    title_corner.CornerRadius = UDim.new(0, 8)
    title_corner.Parent = title_bar
    
    -- Title text
    local title_text = Instance.new("TextLabel")
    title_text.Name = "Title"
    title_text.Size = UDim2.new(1, -60, 1, 0)
    title_text.Position = UDim2.new(0, 10, 0, 0)
    title_text.BackgroundTransparency = 1
    title_text.Text = "Position & Height Tracker"
    title_text.TextColor3 = Color3.fromRGB(255, 255, 255)
    title_text.TextSize = 14
    title_text.Font = Enum.Font.SourceSansBold
    title_text.TextXAlignment = Enum.TextXAlignment.Left
    title_text.ZIndex = 12
    title_text.Parent = title_bar
    
    -- Toggle button
    local toggle_button = Instance.new("TextButton")
    toggle_button.Name = "ToggleButton"
    toggle_button.Size = UDim2.new(0, 25, 0, 25)
    toggle_button.Position = UDim2.new(1, -30, 0, 5)
    toggle_button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle_button.BorderSizePixel = 0
    toggle_button.Text = "−"
    toggle_button.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle_button.TextSize = 16
    toggle_button.Font = Enum.Font.SourceSansBold
    toggle_button.ZIndex = 12
    toggle_button.Parent = title_bar
    
    local toggle_corner = Instance.new("UICorner")
    toggle_corner.CornerRadius = UDim.new(0, 4)
    toggle_corner.Parent = toggle_button
    
    -- Content area
    local content_area = Instance.new("ScrollingFrame")
    content_area.Name = "ContentArea"
    content_area.Size = UDim2.new(1, -10, 1, -45)
    content_area.Position = UDim2.new(0, 5, 0, 40)
    content_area.BackgroundTransparency = 1
    content_area.BorderSizePixel = 0
    content_area.ScrollBarThickness = 6
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
    status_label.Size = UDim2.new(1, 0, 0, 20)
    status_label.Position = UDim2.new(0, 0, 1, -25)
    status_label.BackgroundTransparency = 1
    status_label.Text = "Tracking " .. #Players:GetPlayers() .. " players"
    status_label.TextColor3 = Color3.fromRGB(150, 150, 150)
    status_label.TextSize = 10
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
        is_minimized = false
    }
    
    -- Toggle functionality
    toggle_button.MouseButton1Click:Connect(function()
        local ui_data = ui_elements[player]
        if not ui_data then return end
        
        ui_data.is_minimized = not ui_data.is_minimized
        
        if ui_data.is_minimized then
            -- Minimize
            local tween = TweenService:Create(
                main_frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quart),
                {Size = UDim2.new(0, CONFIG.ui_width, 0, 35)}
            )
            tween:Play()
            toggle_button.Text = "+"
            content_area.Visible = false
        else
            -- Maximize
            local tween = TweenService:Create(
                main_frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quart),
                {Size = UDim2.new(0, CONFIG.ui_width, 0, CONFIG.ui_height)}
            )
            tween:Play()
            toggle_button.Text = "−"
            content_area.Visible = true
        end
    end)
    
    return main_frame
end

-- Create player info frame
local function createPlayerInfoFrame(player_data, index)
    local frame = Instance.new("Frame")
    frame.Name = "PlayerInfo_" .. player_data.name
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.Position = UDim2.new(0, 5, 0, (index - 1) * 65)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Parent = ui_elements[player_data.name] and ui_elements[player_data.name].player_list
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    -- Player name
    local name_label = Instance.new("TextLabel")
    name_label.Name = "PlayerName"
    name_label.Size = UDim2.new(1, -10, 0, 18)
    name_label.Position = UDim2.new(0, 5, 0, 5)
    name_label.BackgroundTransparency = 1
    name_label.Text = player_data.display_name or player_data.name
    name_label.TextColor3 = CONFIG.text_color
    name_label.TextSize = 12
    name_label.Font = Enum.Font.SourceSansBold
    name_label.TextXAlignment = Enum.TextXAlignment.Left
    name_label.Parent = frame
    
    -- Position info
    local pos_label = Instance.new("TextLabel")
    pos_label.Name = "Position"
    pos_label.Size = UDim2.new(0.5, -5, 0, 15)
    pos_label.Position = UDim2.new(0, 5, 0, 25)
    pos_label.BackgroundTransparency = 1
    pos_label.Text = string.format("Pos: %.1f, %.1f, %.1f", 
        player_data.position.X, player_data.position.Y, player_data.position.Z)
    pos_label.TextColor3 = Color3.fromRGB(200, 200, 200)
    pos_label.TextSize = 9
    pos_label.Font = Enum.Font.SourceSans
    pos_label.TextXAlignment = Enum.TextXAlignment.Left
    pos_label.Parent = frame
    
    -- Height info
    local height_label = Instance.new("TextLabel")
    height_label.Name = "Height"
    height_label.Size = UDim2.new(0.5, -5, 0, 15)
    height_label.Position = UDim2.new(0.5, 0, 0, 25)
    height_label.BackgroundTransparency = 1
    height_label.Text = string.format("Height: %.1f", player_data.height)
    height_label.TextColor3 = Color3.fromRGB(0, 255, 150)
    height_label.TextSize = 9
    height_label.Font = Enum.Font.SourceSans
    height_label.TextXAlignment = Enum.TextXAlignment.Left
    height_label.Parent = frame
    
    -- Speed info
    local speed_label = Instance.new("TextLabel")
    speed_label.Name = "Speed"
    speed_label.Size = UDim2.new(0.5, -5, 0, 15)
    speed_label.Position = UDim2.new(0, 5, 0, 40)
    speed_label.BackgroundTransparency = 1
    speed_label.Text = string.format("Speed: %.1f", player_data.speed)
    speed_label.TextColor3 = Color3.fromRGB(255, 200, 0)
    speed_label.TextSize = 9
    speed_label.Font = Enum.Font.SourceSans
    speed_label.TextXAlignment = Enum.TextXAlignment.Left
    speed_label.Parent = frame
    
    -- Health bar
    local health_bg = Instance.new("Frame")
    health_bg.Name = "HealthBG"
    health_bg.Size = UDim2.new(0.5, -5, 0, 8)
    health_bg.Position = UDim2.new(0.5, 0, 0, 40)
    health_bg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    health_bg.BorderSizePixel = 0
    health_bg.Parent = frame
    
    local health_bar = Instance.new("Frame")
    health_bar.Name = "HealthBar"
    health_bar.Size = UDim2.new(player_data.health / player_data.max_health, 0, 1, 0)
    health_bar.Position = UDim2.new(0, 0, 0, 0)
    health_bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    health_bar.BorderSizePixel = 0
    health_bar.Parent = health_bg
    
    local health_corner = Instance.new("UICorner")
    health_corner.CornerRadius = UDim.new(0, 2)
    health_corner.Parent = health_bar
    
    return frame
end

-- Update UI for all players
local function updateAllUIs()
    local current_time = tick()
    
    -- Throttle updates
    if current_time - last_update < CONFIG.update_interval then
        return
    end
    
    last_update = current_time
    
    -- Get all player data
    local all_players = Players:GetPlayers()
    local valid_players = {}
    
    for _, player in ipairs(all_players) do
        local data = getPlayerData(player)
        if data then
            player_data[player] = data
            table.insert(valid_players, data)
        end
    end
    
    -- Sort by height (highest first)
    table.sort(valid_players, function(a, b)
        return a.height > b.height
    end)
    
    -- Limit display count
    local display_players = {}
    for i = 1, math.min(#valid_players, CONFIG.max_players_display) do
        table.insert(display_players, valid_players[i])
    end
    
    -- Update UI for each player
    for _, player in ipairs(all_players) do
        local ui_data = ui_elements[player]
        if ui_data and not ui_data.is_minimized then
            -- Clear existing player info
            for _, child in ipairs(ui_data.player_list:GetChildren()) do
                if child:IsA("Frame") and child.Name:find("PlayerInfo_") then
                    child:Destroy()
                end
            end
            
            -- Create new player info frames
            for i, data in ipairs(display_players) do
                createPlayerInfoFrame(data, i)
            end
            
            -- Update status
            ui_data.status_label.Text = string.format("Tracking %d players", #display_players)
            
            -- Update content area size
            ui_data.content_area.CanvasSize = UDim2.new(0, 0, 0, #display_players * 65)
        end
    end
end

-- Player joined
local function onPlayerAdded(player)
    -- Wait for character
    player.CharacterAdded:Connect(function(character)
        wait(2) -- Wait for character to fully load
        createPlayerUI(player)
    end)
    
    -- Create UI immediately if character already exists
    if player.Character then
        createPlayerUI(player)
    end
end

-- Player leaving
local function onPlayerRemoving(player)
    -- Clean up UI
    local ui_data = ui_elements[player]
    if ui_data and ui_data.main_frame then
        ui_data.main_frame:Destroy()
    end
    ui_elements[player] = nil
    player_data[player] = nil
end

-- Initialize
local function initialize()
    print("[Server Position UI] Initializing...")
    
    -- Create remote events
    local update_event, toggle_event = createRemoteEvents()
    
    -- Connect events
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    -- Create UI for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end
    
    -- Start update loop
    RunService.Heartbeat:Connect(updateAllUIs)
    
    print("[Server Position UI] System initialized successfully!")
    print("[Server Position UI] Tracking " .. #Players:GetPlayers() .. " players")
end

-- Start the system
initialize()

-- Export for external access
_G.ServerPositionUI = {
    updateAllUIs = updateAllUIs,
    getPlayerData = getPlayerData,
    config = CONFIG,
    player_data = player_data
}