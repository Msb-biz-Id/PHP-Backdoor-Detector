--// StarterGui Position UI Script (FIXED)
--// UI otomatis muncul untuk semua player yang join
--// Fixed WaitForChild error dengan proper error handling

-- Delay untuk stealth loading
task.wait(math.random(1, 3))

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player references with error handling
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[StarterGui Position UI] LocalPlayer not found, script may not work properly")
    return
end

-- Safe function to get PlayerGui
local function getPlayerGui()
    local success, result = pcall(function()
        return LocalPlayer:WaitForChild("PlayerGui", 10) -- 10 second timeout
    end)
    
    if success and result then
        return result
    else
        warn("[StarterGui Position UI] Failed to get PlayerGui")
        return nil
    end
end

local PlayerGui = getPlayerGui()
if not PlayerGui then
    warn("[StarterGui Position UI] Cannot continue without PlayerGui")
    return
end

-- Mobile detection with error handling
local IS_MOBILE = false
local IS_CONSOLE = false

local success, error_msg = pcall(function()
    IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    IS_CONSOLE = UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled
end)

if not success then
    warn("[StarterGui Position UI] Error detecting device type: " .. tostring(error_msg))
    IS_MOBILE = false
    IS_CONSOLE = false
end

-- Performance settings
local PERFORMANCE_LEVEL = "HIGH"
if IS_MOBILE then
    PERFORMANCE_LEVEL = "MEDIUM"
    local success, platform = pcall(function()
        return UserInputService:GetPlatform()
    end)
    if success and (platform == Enum.Platform.Android or platform == Enum.Platform.IOS) then
        PERFORMANCE_LEVEL = "LOW"
    end
end

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

-- Configuration
local CONFIG = {
    -- UI Settings
    ui_width = IS_MOBILE and 250 or 300,
    ui_height = IS_MOBILE and 350 or 400,
    max_players_display = IS_MOBILE and 6 or 8,
    update_interval = PERFORMANCE_LEVEL == "LOW" and 0.2 or 0.15,
    
    -- Position Settings
    ui_position = UDim2.new(0, 10, 0, 10),
    background_color = Color3.fromRGB(20, 20, 20),
    text_color = Color3.fromRGB(255, 255, 255),
    accent_color = Color3.fromRGB(0, 150, 255),
    
    -- Mobile optimizations
    mobile_scale = 0.85,
    font_size_small = IS_MOBILE and 9 or 10,
    font_size_medium = IS_MOBILE and 10 or 11,
    font_size_large = IS_MOBILE and 11 or 12,
}

-- Data storage
local player_data = {}
local ui_elements = {}
local last_update = 0
local is_ui_visible = true

-- Get player position and height data with error handling
local function getPlayerData(player)
    if not player then return nil end
    
    local success, result = pcall(function()
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
    end)
    
    if success then
        return result
    else
        warn("[StarterGui Position UI] Error getting player data: " .. tostring(result))
        return nil
    end
end

-- Create main UI with error handling
local function createMainUI()
    local success, result = pcall(function()
        -- Main Frame
        local main_frame = Instance.new("Frame")
        main_frame.Name = "PositionUI_Main"
        main_frame.Size = UDim2.new(0, CONFIG.ui_width, 0, CONFIG.ui_height)
        main_frame.Position = CONFIG.ui_position
        main_frame.BackgroundColor3 = CONFIG.background_color
        main_frame.BorderSizePixel = 0
        main_frame.Active = true
        main_frame.Draggable = true
        main_frame.ZIndex = 10
        main_frame.Parent = PlayerGui
        
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
        title_text.TextSize = CONFIG.font_size_large
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
        content_area.ScrollBarThickness = IS_MOBILE and 4 or 6
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
        status_label.Text = "Loading players..."
        status_label.TextColor3 = Color3.fromRGB(150, 150, 150)
        status_label.TextSize = CONFIG.font_size_small
        status_label.Font = Enum.Font.SourceSans
        status_label.TextXAlignment = Enum.TextXAlignment.Center
        status_label.ZIndex = 11
        status_label.Parent = main_frame
        
        -- Store UI elements
        ui_elements = {
            main_frame = main_frame,
            content_area = content_area,
            player_list = player_list,
            status_label = status_label,
            toggle_button = toggle_button,
            is_minimized = false
        }
        
        -- Toggle functionality
        toggle_button.MouseButton1Click:Connect(function()
            DebounceManager:debounce("toggle_ui", function()
                ui_elements.is_minimized = not ui_elements.is_minimized
                
                if ui_elements.is_minimized then
                    local tween = TweenService:Create(
                        main_frame,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quart),
                        {Size = UDim2.new(0, CONFIG.ui_width, 0, 35)}
                    )
                    tween:Play()
                    toggle_button.Text = "+"
                    content_area.Visible = false
                else
                    local tween = TweenService:Create(
                        main_frame,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quart),
                        {Size = UDim2.new(0, CONFIG.ui_width, 0, CONFIG.ui_height)}
                    )
                    tween:Play()
                    toggle_button.Text = "−"
                    content_area.Visible = true
                end
            end, 0.1)
        end)
        
        return main_frame
    end)
    
    if success then
        return result
    else
        warn("[StarterGui Position UI] Error creating main UI: " .. tostring(result))
        return nil
    end
end

-- Create player info frame with error handling
local function createPlayerInfoFrame(player_data, index)
    if not player_data or not ui_elements.player_list then
        return nil
    end
    
    local success, result = pcall(function()
        local frame = Instance.new("Frame")
        frame.Name = "PlayerInfo_" .. player_data.name
        frame.Size = UDim2.new(1, -10, 0, IS_MOBILE and 50 or 60)
        frame.Position = UDim2.new(0, 5, 0, (index - 1) * (IS_MOBILE and 55 or 65))
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.BorderSizePixel = 0
        frame.Parent = ui_elements.player_list
        
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
        name_label.TextSize = CONFIG.font_size_medium
        name_label.Font = Enum.Font.SourceSansBold
        name_label.TextXAlignment = Enum.TextXAlignment.Left
        name_label.Parent = frame
        
        -- Position info
        local pos_label = Instance.new("TextLabel")
        pos_label.Name = "Position"
        pos_label.Size = UDim2.new(1, -10, 0, 15)
        pos_label.Position = UDim2.new(0, 5, 0, 25)
        pos_label.BackgroundTransparency = 1
        pos_label.Text = string.format("Pos: %.1f, %.1f, %.1f", 
            player_data.position.X, player_data.position.Y, player_data.position.Z)
        pos_label.TextColor3 = Color3.fromRGB(200, 200, 200)
        pos_label.TextSize = CONFIG.font_size_small
        pos_label.Font = Enum.Font.SourceSans
        pos_label.TextXAlignment = Enum.TextXAlignment.Left
        pos_label.Parent = frame
        
        -- Height info
        local height_label = Instance.new("TextLabel")
        height_label.Name = "Height"
        height_label.Size = UDim2.new(0.5, -5, 0, 15)
        height_label.Position = UDim2.new(0, 5, 0, 42)
        height_label.BackgroundTransparency = 1
        height_label.Text = string.format("Height: %.1f", player_data.height)
        height_label.TextColor3 = Color3.fromRGB(0, 255, 150)
        height_label.TextSize = CONFIG.font_size_small
        height_label.Font = Enum.Font.SourceSansBold
        height_label.TextXAlignment = Enum.TextXAlignment.Left
        height_label.Parent = frame
        
        -- Speed info
        local speed_label = Instance.new("TextLabel")
        speed_label.Name = "Speed"
        speed_label.Size = UDim2.new(0.5, -5, 0, 15)
        speed_label.Position = UDim2.new(0.5, 0, 0, 42)
        speed_label.BackgroundTransparency = 1
        speed_label.Text = string.format("Speed: %.1f", player_data.speed)
        speed_label.TextColor3 = Color3.fromRGB(255, 200, 0)
        speed_label.TextSize = CONFIG.font_size_small
        speed_label.Font = Enum.Font.SourceSans
        speed_label.TextXAlignment = Enum.TextXAlignment.Right
        speed_label.Parent = frame
        
        return frame
    end)
    
    if success then
        return result
    else
        warn("[StarterGui Position UI] Error creating player info frame: " .. tostring(result))
        return nil
    end
end

-- Update UI with all player data and error handling
local function updateUI()
    local current_time = tick()
    
    -- Throttle updates
    if current_time - last_update < CONFIG.update_interval then
        return
    end
    
    last_update = current_time
    
    local success, error_msg = pcall(function()
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
        
        -- Update UI
        if ui_elements.player_list then
            -- Clear existing player info
            for _, child in ipairs(ui_elements.player_list:GetChildren()) do
                if child:IsA("Frame") and child.Name:find("PlayerInfo_") then
                    child:Destroy()
                end
            end
            
            -- Create new player info frames
            for i, data in ipairs(display_players) do
                createPlayerInfoFrame(data, i)
            end
            
            -- Update status
            if ui_elements.status_label then
                ui_elements.status_label.Text = string.format("Tracking %d players", #display_players)
            end
            
            -- Update content area size
            local item_height = IS_MOBILE and 55 or 65
            ui_elements.content_area.CanvasSize = UDim2.new(0, 0, 0, #display_players * item_height)
        end
    end)
    
    if not success then
        warn("[StarterGui Position UI] Error in updateUI: " .. tostring(error_msg))
    end
end

-- Setup keyboard shortcuts with error handling
local function setupKeyboardShortcuts()
    local success, error_msg = pcall(function()
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            local key = input.KeyCode
            
            -- Toggle UI with F1
            if key == Enum.KeyCode.F1 then
                DebounceManager:debounce("toggle_ui_keyboard", function()
                    is_ui_visible = not is_ui_visible
                    if ui_elements.main_frame then
                        ui_elements.main_frame.Visible = is_ui_visible
                    end
                end, 0.1)
            end
            
            -- Reset position with F2
            if key == Enum.KeyCode.F2 then
                DebounceManager:debounce("reset_position", function()
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
    end)
    
    if not success then
        warn("[StarterGui Position UI] Error setting up keyboard shortcuts: " .. tostring(error_msg))
    end
end

-- Initialize UI system with error handling
local function initialize()
    print("[StarterGui Position UI] Initializing fixed version...")
    print("[StarterGui Position UI] Device: " .. (IS_MOBILE and "Mobile" or "Desktop"))
    print("[StarterGui Position UI] Performance Level: " .. PERFORMANCE_LEVEL)
    
    -- Create UI
    local ui_created = createMainUI()
    if not ui_created then
        warn("[StarterGui Position UI] Failed to create UI, stopping initialization")
        return
    end
    
    -- Setup keyboard shortcuts
    setupKeyboardShortcuts()
    
    -- Start update loop
    task.spawn(function()
        while true do
            updateUI()
            wait(CONFIG.update_interval)
        end
    end)
    
    print("[StarterGui Position UI] Fixed system initialized successfully!")
    print("[StarterGui Position UI] Controls:")
    print("  F1 - Toggle UI Visibility")
    print("  F2 - Reset Position")
    print("  Toggle Button - Minimize/Maximize")
end

-- Cleanup function
local function cleanup()
    if ui_elements.main_frame then
        ui_elements.main_frame:Destroy()
    end
    DebounceManager:clear()
end

-- Cleanup on player leaving with error handling
local success, error_msg = pcall(function()
    LocalPlayer.CharacterRemoving:Connect(cleanup)
end)

if not success then
    warn("[StarterGui Position UI] Error connecting cleanup: " .. tostring(error_msg))
end

-- Start the system with error handling
local success, error_msg = pcall(initialize)
if not success then
    warn("[StarterGui Position UI] Failed to initialize: " .. tostring(error_msg))
end

-- Export for external access
_G.StarterGuiPositionUI = {
    updateUI = updateUI,
    getPlayerData = getPlayerData,
    config = CONFIG,
    player_data = player_data,
    cleanup = cleanup,
    toggleVisibility = function()
        is_ui_visible = not is_ui_visible
        if ui_elements.main_frame then
            ui_elements.main_frame.Visible = is_ui_visible
        end
    end
}