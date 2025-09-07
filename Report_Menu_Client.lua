--// Report Menu Client v2.0
--// Top Left Corner UI
--// Beautiful Report Interface

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local reportSubmitted = ReplicatedStorage:WaitForChild("ReportSubmitted")
local reportRequest = ReplicatedStorage:WaitForChild("ReportRequest")

-- Configuration
local UI_CONFIG = {
    -- Menu Settings
    MENU_WIDTH = 300,
    MENU_HEIGHT = 400,
    BUTTON_WIDTH = 80,
    BUTTON_HEIGHT = 30,
    CORNER_RADIUS = 12,
    PADDING = 16,
    
    -- Position Settings (Top Left)
    POSITION_X = 0.02,  -- 2% from left
    POSITION_Y = 0.02,  -- 2% from top
    
    -- Animation Settings
    SLIDE_DURATION = 0.3,
    FADE_DURATION = 0.2,
    
    -- Colors
    PRIMARY_COLOR = Color3.fromRGB(25, 25, 25),
    SECONDARY_COLOR = Color3.fromRGB(35, 35, 35),
    ACCENT_COLOR = Color3.fromRGB(0, 162, 255),
    TEXT_COLOR = Color3.fromRGB(255, 255, 255),
    SUCCESS_COLOR = Color3.fromRGB(46, 204, 113),
    ERROR_COLOR = Color3.fromRGB(231, 76, 60),
    
    -- Sound Settings
    ENABLE_SOUND = true,
    SOUND_ID = "rbxasset://sounds/electronicpingshort.wav",
    SOUND_VOLUME = 0.3
}

-- Create main UI
local function createMainUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ReportMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    
    -- Report button (always visible)
    local reportButton = Instance.new("TextButton")
    reportButton.Name = "ReportButton"
    reportButton.Size = UDim2.new(0, UI_CONFIG.BUTTON_WIDTH, 0, UI_CONFIG.BUTTON_HEIGHT)
    reportButton.Position = UDim2.new(UI_CONFIG.POSITION_X, 0, UI_CONFIG.POSITION_Y, 0)
    reportButton.BackgroundColor3 = UI_CONFIG.ERROR_COLOR
    reportButton.BorderSizePixel = 0
    reportButton.Text = "🚨 Report"
    reportButton.TextColor3 = Color3.new(1, 1, 1)
    reportButton.TextScaled = true
    reportButton.Font = Enum.Font.GothamBold
    reportButton.ZIndex = 5
    reportButton.Parent = screenGui
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = reportButton
    
    -- Main menu frame (hidden by default)
    local menuFrame = Instance.new("Frame")
    menuFrame.Name = "MenuFrame"
    menuFrame.Size = UDim2.new(0, UI_CONFIG.MENU_WIDTH, 0, UI_CONFIG.MENU_HEIGHT)
    menuFrame.Position = UDim2.new(UI_CONFIG.POSITION_X, 0, UI_CONFIG.POSITION_Y, UI_CONFIG.BUTTON_HEIGHT + 10)
    menuFrame.BackgroundColor3 = UI_CONFIG.PRIMARY_COLOR
    menuFrame.BorderSizePixel = 0
    menuFrame.Visible = false
    menuFrame.ZIndex = 4
    menuFrame.Parent = screenGui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, UI_CONFIG.CORNER_RADIUS)
    menuCorner.Parent = menuFrame
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.ZIndex = 3
    shadow.Parent = menuFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = UI_CONFIG.SECONDARY_COLOR
    header.BorderSizePixel = 0
    header.ZIndex = 5
    header.Parent = menuFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, UI_CONFIG.CORNER_RADIUS)
    headerCorner.Parent = header
    
    -- Header title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Report Player"
    title.TextColor3 = UI_CONFIG.TEXT_COLOR
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 6
    title.Parent = header
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0.5, -15)
    closeButton.BackgroundColor3 = UI_CONFIG.ERROR_COLOR
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.ZIndex = 6
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -UI_CONFIG.PADDING*2, 1, -70)
    content.Position = UDim2.new(0, UI_CONFIG.PADDING, 0, 60)
    content.BackgroundTransparency = 1
    content.ZIndex = 5
    content.Parent = menuFrame
    
    -- Player selection
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Name = "PlayerLabel"
    playerLabel.Size = UDim2.new(1, 0, 0, 20)
    playerLabel.Position = UDim2.new(0, 0, 0, 0)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = "Select Player:"
    playerLabel.TextColor3 = UI_CONFIG.TEXT_COLOR
    playerLabel.TextScaled = true
    playerLabel.Font = Enum.Font.Gotham
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.ZIndex = 6
    playerLabel.Parent = content
    
    local playerDropdown = Instance.new("TextButton")
    playerDropdown.Name = "PlayerDropdown"
    playerDropdown.Size = UDim2.new(1, 0, 0, 30)
    playerDropdown.Position = UDim2.new(0, 0, 0, 25)
    playerDropdown.BackgroundColor3 = UI_CONFIG.SECONDARY_COLOR
    playerDropdown.BorderSizePixel = 0
    playerDropdown.Text = "Click to select player"
    playerDropdown.TextColor3 = UI_CONFIG.TEXT_COLOR
    playerDropdown.TextScaled = true
    playerDropdown.Font = Enum.Font.Gotham
    playerDropdown.ZIndex = 6
    playerDropdown.Parent = content
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = playerDropdown
    
    -- Category selection
    local categoryLabel = Instance.new("TextLabel")
    categoryLabel.Name = "CategoryLabel"
    categoryLabel.Size = UDim2.new(1, 0, 0, 20)
    categoryLabel.Position = UDim2.new(0, 0, 0, 70)
    categoryLabel.BackgroundTransparency = 1
    categoryLabel.Text = "Select Category:"
    categoryLabel.TextColor3 = UI_CONFIG.TEXT_COLOR
    categoryLabel.TextScaled = true
    categoryLabel.Font = Enum.Font.Gotham
    categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
    categoryLabel.ZIndex = 6
    categoryLabel.Parent = content
    
    local categoryDropdown = Instance.new("TextButton")
    categoryDropdown.Name = "CategoryDropdown"
    categoryDropdown.Size = UDim2.new(1, 0, 0, 30)
    categoryDropdown.Position = UDim2.new(0, 0, 0, 95)
    categoryDropdown.BackgroundColor3 = UI_CONFIG.SECONDARY_COLOR
    categoryDropdown.BorderSizePixel = 0
    categoryDropdown.Text = "Click to select category"
    categoryDropdown.TextColor3 = UI_CONFIG.TEXT_COLOR
    categoryDropdown.TextScaled = true
    categoryDropdown.Font = Enum.Font.Gotham
    categoryDropdown.ZIndex = 6
    categoryDropdown.Parent = content
    
    local categoryCorner = Instance.new("UICorner")
    categoryCorner.CornerRadius = UDim.new(0, 6)
    categoryCorner.Parent = categoryDropdown
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescLabel"
    descLabel.Size = UDim2.new(1, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 140)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = "Description (Optional):"
    descLabel.TextColor3 = UI_CONFIG.TEXT_COLOR
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 6
    descLabel.Parent = content
    
    local descBox = Instance.new("TextBox")
    descBox.Name = "DescBox"
    descBox.Size = UDim2.new(1, 0, 0, 60)
    descBox.Position = UDim2.new(0, 0, 0, 165)
    descBox.BackgroundColor3 = UI_CONFIG.SECONDARY_COLOR
    descBox.BorderSizePixel = 0
    descBox.Text = ""
    descBox.PlaceholderText = "Describe the issue..."
    descBox.TextColor3 = UI_CONFIG.TEXT_COLOR
    descBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    descBox.TextScaled = true
    descBox.Font = Enum.Font.Gotham
    descBox.TextWrapped = true
    descBox.ZIndex = 6
    descBox.Parent = content
    
    local descCorner = Instance.new("UICorner")
    descCorner.CornerRadius = UDim.new(0, 6)
    descCorner.Parent = descBox
    
    -- Submit button
    local submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Size = UDim2.new(1, 0, 0, 35)
    submitButton.Position = UDim2.new(0, 0, 0, 240)
    submitButton.BackgroundColor3 = UI_CONFIG.SUCCESS_COLOR
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Submit Report"
    submitButton.TextColor3 = Color3.new(1, 1, 1)
    submitButton.TextScaled = true
    submitButton.Font = Enum.Font.GothamBold
    submitButton.ZIndex = 6
    submitButton.Parent = content
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 8)
    submitCorner.Parent = submitButton
    
    return screenGui, reportButton, menuFrame, closeButton, playerDropdown, categoryDropdown, descBox, submitButton
end

-- Create dropdown menu
local function createDropdown(parent, items, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown"
    dropdown.Size = UDim2.new(1, 0, 0, #items * 25)
    dropdown.Position = UDim2.new(0, 0, 1, 5)
    dropdown.BackgroundColor3 = UI_CONFIG.SECONDARY_COLOR
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 10
    dropdown.Parent = parent
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdown
    
    for i, item in ipairs(items) do
        local itemButton = Instance.new("TextButton")
        itemButton.Name = "Item" .. i
        itemButton.Size = UDim2.new(1, -10, 0, 20)
        itemButton.Position = UDim2.new(0, 5, 0, (i-1) * 25 + 5)
        itemButton.BackgroundColor3 = UI_CONFIG.PRIMARY_COLOR
        itemButton.BorderSizePixel = 0
        itemButton.Text = item
        itemButton.TextColor3 = UI_CONFIG.TEXT_COLOR
        itemButton.TextScaled = true
        itemButton.Font = Enum.Font.Gotham
        itemButton.ZIndex = 11
        itemButton.Parent = dropdown
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 4)
        itemCorner.Parent = itemButton
        
        itemButton.MouseButton1Click:Connect(function()
            callback(item)
            dropdown.Visible = false
        end)
    end
    
    return dropdown
end

-- Show notification
local function showNotification(message, isSuccess)
    local screenGui = PlayerGui:FindFirstChild("ReportMenu")
    if not screenGui then return end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 250, 0, 50)
    notification.Position = UDim2.new(0.5, -125, 0.1, 0)
    notification.BackgroundColor3 = isSuccess and UI_CONFIG.SUCCESS_COLOR or UI_CONFIG.ERROR_COLOR
    notification.BorderSizePixel = 0
    notification.ZIndex = 15
    notification.Parent = screenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = message
    notifText.TextColor3 = Color3.new(1, 1, 1)
    notifText.TextScaled = true
    notifText.Font = Enum.Font.Gotham
    notifText.ZIndex = 16
    notifText.Parent = notification
    
    -- Animate in
    notification.Position = UDim2.new(0.5, -125, -0.1, 0)
    local slideIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -125, 0.1, 0)
    })
    slideIn:Play()
    
    -- Auto remove after 3 seconds
    task.wait(3)
    local slideOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -125, -0.1, 0)
    })
    slideOut:Play()
    slideOut.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Play sound
local function playSound()
    if not UI_CONFIG.ENABLE_SOUND then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = UI_CONFIG.SOUND_ID
    sound.Volume = UI_CONFIG.SOUND_VOLUME
    sound.Parent = SoundService
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Initialize UI
local screenGui, reportButton, menuFrame, closeButton, playerDropdown, categoryDropdown, descBox, submitButton = createMainUI()

-- Variables
local selectedPlayer = nil
local selectedCategory = nil
local playerDropdownMenu = nil
local categoryDropdownMenu = nil

-- Toggle menu
local function toggleMenu()
    menuFrame.Visible = not menuFrame.Visible
    
    if menuFrame.Visible then
        playSound()
        -- Request player list and categories
        reportRequest:FireServer("getPlayerList")
        reportRequest:FireServer("getCategories")
    end
end

-- Handle report button click
reportButton.MouseButton1Click:Connect(toggleMenu)

-- Handle close button click
closeButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
end)

-- Handle player dropdown
playerDropdown.MouseButton1Click:Connect(function()
    if playerDropdownMenu then
        playerDropdownMenu.Visible = not playerDropdownMenu.Visible
    end
end)

-- Handle category dropdown
categoryDropdown.MouseButton1Click:Connect(function()
    if categoryDropdownMenu then
        categoryDropdownMenu.Visible = not categoryDropdownMenu.Visible
    end
end)

-- Handle submit button
submitButton.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        showNotification("Please select a player", false)
        return
    end
    
    if not selectedCategory then
        showNotification("Please select a category", false)
        return
    end
    
    local description = descBox.Text
    
    -- Submit report
    reportSubmitted:FireServer(selectedPlayer, selectedCategory, description)
    
    -- Reset form
    selectedPlayer = nil
    selectedCategory = nil
    playerDropdown.Text = "Click to select player"
    categoryDropdown.Text = "Click to select category"
    descBox.Text = ""
    
    -- Close menu
    menuFrame.Visible = false
end)

-- Handle report response
reportSubmitted.OnClientEvent:Connect(function(success, message)
    showNotification(message, success)
end)

-- Handle player list response
reportRequest.OnClientEvent:Connect(function(responseType, data)
    if responseType == "playerList" then
        if playerDropdownMenu then
            playerDropdownMenu:Destroy()
        end
        
        playerDropdownMenu = createDropdown(playerDropdown, data, function(playerName)
            selectedPlayer = playerName
            playerDropdown.Text = playerName
        end)
    elseif responseType == "categories" then
        if categoryDropdownMenu then
            categoryDropdownMenu:Destroy()
        end
        
        categoryDropdownMenu = createDropdown(categoryDropdown, data, function(category)
            selectedCategory = category
            categoryDropdown.Text = category
        end)
    end
end)

-- Close dropdowns when clicking outside
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if playerDropdownMenu and playerDropdownMenu.Visible then
            playerDropdownMenu.Visible = false
        end
        if categoryDropdownMenu and categoryDropdownMenu.Visible then
            categoryDropdownMenu.Visible = false
        end
    end
end)

-- Initialize
print("[ReportMenu] Client system initialized")
print("[ReportMenu] Report button available in top left corner")
print("[ReportMenu] Click the report button to open the menu")