--// Server Position UI - Quick Start Version
--// Minimal setup untuk testing cepat
--// Mobile Optimized dengan Performance

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Configuration
local CONFIG = {
    ui_width = 250,
    ui_height = 300,
    max_players = 6,
    update_interval = 0.2,
    ui_position = UDim2.new(0, 10, 0, 10),
}

-- Data storage
local player_data = {}
local ui_elements = {}
local last_update = 0

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

-- Create UI for player
local function createPlayerUI(player)
    local player_gui = player:WaitForChild("PlayerGui")
    
    -- Main Frame
    local main_frame = Instance.new("Frame")
    main_frame.Name = "PositionUI_Quick"
    main_frame.Size = UDim2.new(0, CONFIG.ui_width, 0, CONFIG.ui_height)
    main_frame.Position = CONFIG.ui_position
    main_frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main_frame.BorderSizePixel = 0
    main_frame.ZIndex = 10
    main_frame.Parent = player_gui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = main_frame
    
    -- Title
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 25)
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
    title_text.TextSize = 11
    title_text.Font = Enum.Font.SourceSansBold
    title_text.TextXAlignment = Enum.TextXAlignment.Left
    title_text.Parent = title
    
    -- Toggle button
    local toggle_btn = Instance.new("TextButton")
    toggle_btn.Size = UDim2.new(0, 20, 0, 20)
    toggle_btn.Position = UDim2.new(1, -25, 0, 2.5)
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
    content.Size = UDim2.new(1, -8, 1, -35)
    content.Position = UDim2.new(0, 4, 0, 30)
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
    ui_elements[player] = {
        main_frame = main_frame,
        content = content,
        player_list = player_list,
        status = status,
        toggle_btn = toggle_btn,
        minimized = false
    }
    
    -- Toggle functionality
    toggle_btn.MouseButton1Click:Connect(function()
        local ui = ui_elements[player]
        if not ui then return end
        
        ui.minimized = not ui.minimized
        
        if ui.minimized then
            local tween = TweenService:Create(
                main_frame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quart),
                {Size = UDim2.new(0, CONFIG.ui_width, 0, 25)}
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
    end)
    
    return main_frame
end

-- Create player info frame
local function createPlayerInfo(data, index)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 45)
    frame.Position = UDim2.new(0, 2, 0, (index - 1) * 50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = ui_elements[data.name] and ui_elements[data.name].player_list
    
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
    name.TextSize = 10
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
    pos.TextSize = 8
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
    height.TextSize = 8
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
    speed.TextSize = 8
    speed.Font = Enum.Font.SourceSans
    speed.TextXAlignment = Enum.TextXAlignment.Right
    speed.Parent = frame
    
    return frame
end

-- Update all UIs
local function updateAllUIs()
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
    
    -- Update UIs
    for _, player in ipairs(all_players) do
        local ui = ui_elements[player]
        if ui and not ui.minimized then
            -- Clear existing
            for _, child in ipairs(ui.player_list:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            -- Create new
            for i, data in ipairs(display_players) do
                createPlayerInfo(data, i)
            end
            
            -- Update status
            ui.status.Text = string.format("Tracking %d players", #display_players)
            ui.content.CanvasSize = UDim2.new(0, 0, 0, #display_players * 50)
        end
    end
end

-- Player events
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        createPlayerUI(player)
    end)
    
    if player.Character then
        createPlayerUI(player)
    end
end

local function onPlayerRemoving(player)
    local ui = ui_elements[player]
    if ui and ui.main_frame then
        ui.main_frame:Destroy()
    end
    ui_elements[player] = nil
    player_data[player] = nil
end

-- Initialize
local function initialize()
    print("[Server Position UI] Quick Start initializing...")
    
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end
    
    -- Update loop
    task.spawn(function()
        while true do
            updateAllUIs()
            wait(CONFIG.update_interval)
        end
    end)
    
    print("[Server Position UI] Quick Start ready!")
end

-- Start
initialize()

-- Export
_G.ServerPositionUI_Quick = {
    updateAllUIs = updateAllUIs,
    getPlayerData = getPlayerData,
    config = CONFIG
}