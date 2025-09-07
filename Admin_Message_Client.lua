--// Admin Message Client v2.0
--// Center Top UI with Open/Close
--// Beautiful Message Interface

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local adminMessageSubmitted = ReplicatedStorage:WaitForChild("AdminMessageSubmitted")
local adminMessageRequest = ReplicatedStorage:WaitForChild("AdminMessageRequest")
local adminNotification = ReplicatedStorage:WaitForChild("AdminNotification")

-- Configuration
local UI_CONFIG = {
    -- Menu Settings
    MENU_WIDTH = 400,
    MENU_HEIGHT = 500,
    BUTTON_WIDTH = 100,
    BUTTON_HEIGHT = 35,
    CORNER_RADIUS = 12,
    PADDING = 16,
    
    -- Position Settings (Center Top)
    POSITION_X = 0.5,  -- Center horizontally
    POSITION_Y = 0.05, -- 5% from top
    
    -- Animation Settings
    SLIDE_DURATION = 0.4,
    FADE_DURATION = 0.3,
    
    -- Colors
    PRIMARY_COLOR = Color3.fromRGB(20, 20, 20),
    SECONDARY_COLOR = Color3.fromRGB(30, 30, 30),
    ACCENT_COLOR = Color3.fromRGB(0, 162, 255),
    TEXT_COLOR = Color3.fromRGB(255, 255, 255),
    SUCCESS_COLOR = Color3.fromRGB(46, 204, 113),
    ERROR_COLOR = Color3.fromRGB(231, 76, 60),
    WARNING_COLOR = Color3.fromRGB(241, 196, 15),
    
    -- Priority Colors
    PRIORITY_COLORS = {
        Low = Color3.fromRGB(100, 150, 255),
        Medium = Color3.fromRGB(255, 193, 7),
        High = Color3.fromRGB(255, 152, 0),
        Urgent = Color3.fromRGB(244, 67, 54)
    },
    
    -- Sound Settings
    ENABLE_SOUND = true,
    SOUND_ID = "rbxasset://sounds/electronicpingshort.wav",
    SOUND_VOLUME = 0.4
}

-- Create main UI
local function createMainUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminMessageMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    
    -- Message button (always visible)
    local messageButton = Instance.new("TextButton")
    messageButton.Name = "MessageButton"
    messageButton.Size = UDim2.new(0, UI_CONFIG.BUTTON_WIDTH, 0, UI_CONFIG.BUTTON_HEIGHT)
    messageButton.Position = UDim2.new(UI_CONFIG.POSITION_X, -UI_CONFIG.BUTTON_WIDTH/2, UI_CONFIG.POSITION_Y, 0)
    messageButton.BackgroundColor3 = UI_CONFIG.ACCENT_COLOR
    messageButton.BorderSizePixel = 0
    messageButton.Text = "💬 Message Admin"
    messageButton.TextColor3 = Color3.new(1, 1, 1)
    messageButton.TextScaled = true
    messageButton.Font = Enum.Font.GothamBold
    messageButton.ZIndex = 5
    messageButton.Parent = screenGui
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = messageButton
    
    -- Main menu frame (hidden by default)
    local menuFrame = Instance.new("Frame")
    menuFrame.Name = "MenuFrame"
    menuFrame.Size = UDim2.new(0, UI_CONFIG.MENU_WIDTH, 0, UI_CONFIG.MENU_HEIGHT)
    menuFrame.Position = UDim2.new(UI_CONFIG.POSITION_X, -UI_CONFIG.MENU_WIDTH/2, UI_CONFIG.POSITION_Y, UI_CONFIG.BUTTON_HEIGHT + 15)
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
    header.Size = UDim2.new(1, 0, 0, 60)
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
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Message Admin"
    title.TextColor3 = UI_CONFIG.TEXT_COLOR
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 6
    title.Parent = header
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -45, 0.5, -17.5)
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
    content.Size = UDim2.new(1, -UI_CONFIG.PADDING*2, 1, -80)
    content.Position = UDim2.new(0, UI_CONFIG.PADDING, 0, 70)
    content.BackgroundTransparency = 1
    content.ZIndex = 5
    content.Parent = menuFrame
    
    -- Category selection
    local categoryLabel = Instance.new("TextLabel")
    categoryLabel.Name = "CategoryLabel"
    categoryLabel.Size = UDim2.new(1, 0, 0, 20)
    categoryLabel.Position = UDim2.new(0, 0, 0, 0)
    categoryLabel.BackgroundTransparency = 1
    categoryLabel.Text = "Category:"
    categoryLabel.TextColor3 = UI_CONFIG.TEXT_COLOR
    categoryLabel.TextScaled = true
    categoryLabel.Font = Enum.Font.Gotham
    categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
    categoryLabel.ZIndex = 6
    categoryLabel.Parent = content
    
    local categoryDropdown = Instance.new("TextButton")
    categoryDropdown.Name = "CategoryDropdown"
    categoryDropdown.Size = UDim2.new(1, 0, 0, 35)
    categoryDropdown.Position = UDim2.new(0, 0, 0, 25)
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
    
    -- Priority selection
    local priorityLabel = Instance.new("TextLabel")
    priorityLabel.Name = "PriorityLabel"
    priorityLabel.Size = UDim2.new(1, 0, 0, 20)
    priorityLabel.Position = UDim2.new(0, 0, 0, 75)
    priorityLabel.BackgroundTransparency = 1
    priorityLabel.Text = "Priority:"
    priorityLabel.TextColor3 = UI_CONFIG.TEXT_COLOR
    priorityLabel.TextScaled = true
    priorityLabel.Font = Enum.Font.Gotham
    priorityLabel.TextXAlignment = Enum.TextXAlignment.Left
    priorityLabel.ZIndex = 6
    priorityLabel.Parent = content
    
    local priorityDropdown = Instance.new("TextButton")
    priorityDropdown.Name = "PriorityDropdown"
    priorityDropdown.Size = UDim2.new(1, 0, 0, 35)
    priorityDropdown.Position = UDim2.new(0, 0, 0, 100)
    priorityDropdown.BackgroundColor3 = UI_CONFIG.SECONDARY_COLOR
    priorityDropdown.BorderSizePixel = 0
    priorityDropdown.Text = "Click to select priority"
    priorityDropdown.TextColor3 = UI_CONFIG.TEXT_COLOR
    priorityDropdown.TextScaled = true
    priorityDropdown.Font = Enum.Font.Gotham
    priorityDropdown.ZIndex = 6
    priorityDropdown.Parent = content
    
    local priorityCorner = Instance.new("UICorner")
    priorityCorner.CornerRadius = UDim.new(0, 6)
    priorityCorner.Parent = priorityDropdown
    
    -- Message input
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Size = UDim2.new(1, 0, 0, 20)
    messageLabel.Position = UDim2.new(0, 0, 0, 150)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = "Message:"
    messageLabel.TextColor3 = UI_CONFIG.TEXT_COLOR
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.ZIndex = 6
    messageLabel.Parent = content
    
    local messageBox = Instance.new("TextBox")
    messageBox.Name = "MessageBox"
    messageBox.Size = UDim2.new(1, 0, 0, 120)
    messageBox.Position = UDim2.new(0, 0, 0, 175)
    messageBox.BackgroundColor3 = UI_CONFIG.SECONDARY_COLOR
    messageBox.BorderSizePixel = 0
    messageBox.Text = ""
    messageBox.PlaceholderText = "Type your message here... (10-500 characters)"
    messageBox.TextColor3 = UI_CONFIG.TEXT_COLOR
    messageBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    messageBox.TextScaled = false
    messageBox.Font = Enum.Font.Gotham
    messageBox.TextSize = 14
    messageBox.TextWrapped = true
    messageBox.MultiLine = true
    messageBox.ZIndex = 6
    messageBox.Parent = content
    
    local messageCorner = Instance.new("UICorner")
    messageCorner.CornerRadius = UDim.new(0, 6)
    messageCorner.Parent = messageBox
    
    -- Character count
    local charCount = Instance.new("TextLabel")
    charCount.Name = "CharCount"
    charCount.Size = UDim2.new(1, 0, 0, 15)
    charCount.Position = UDim2.new(0, 0, 0, 300)
    charCount.BackgroundTransparency = 1
    charCount.Text = "0/500 characters"
    charCount.TextColor3 = Color3.fromRGB(150, 150, 150)
    charCount.TextScaled = true
    charCount.Font = Enum.Font.Gotham
    charCount.TextXAlignment = Enum.TextXAlignment.Right
    charCount.ZIndex = 6
    charCount.Parent = content
    
    -- Submit button
    local submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Size = UDim2.new(1, 0, 0, 40)
    submitButton.Position = UDim2.new(0, 0, 0, 325)
    submitButton.BackgroundColor3 = UI_CONFIG.SUCCESS_COLOR
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Send Message"
    submitButton.TextColor3 = Color3.new(1, 1, 1)
    submitButton.TextScaled = true
    submitButton.Font = Enum.Font.GothamBold
    submitButton.ZIndex = 6
    submitButton.Parent = content
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 8)
    submitCorner.Parent = submitButton
    
    return screenGui, messageButton, menuFrame, closeButton, categoryDropdown, priorityDropdown, messageBox, charCount, submitButton
end

-- Create dropdown menu
local function createDropdown(parent, items, callback, isPriority)
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown"
    dropdown.Size = UDim2.new(1, 0, 0, #items * 30)
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
        itemButton.Size = UDim2.new(1, -10, 0, 25)
        itemButton.Position = UDim2.new(0, 5, 0, (i-1) * 30 + 5)
        itemButton.BackgroundColor3 = UI_CONFIG.PRIMARY_COLOR
        itemButton.BorderSizePixel = 0
        itemButton.Text = item
        itemButton.TextColor3 = isPriority and UI_CONFIG.PRIORITY_COLORS[item] or UI_CONFIG.TEXT_COLOR
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
    local screenGui = PlayerGui:FindFirstChild("AdminMessageMenu")
    if not screenGui then return end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(0.5, -150, 0.15, 0)
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
    notification.Position = UDim2.new(0.5, -150, -0.1, 0)
    local slideIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -150, 0.15, 0)
    })
    slideIn:Play()
    
    -- Auto remove after 4 seconds
    task.wait(4)
    local slideOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -150, -0.1, 0)
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
local screenGui, messageButton, menuFrame, closeButton, categoryDropdown, priorityDropdown, messageBox, charCount, submitButton = createMainUI()

-- Variables
local selectedCategory = nil
local selectedPriority = nil
local categoryDropdownMenu = nil
local priorityDropdownMenu = nil

-- Toggle menu
local function toggleMenu()
    menuFrame.Visible = not menuFrame.Visible
    
    if menuFrame.Visible then
        playSound()
        -- Request categories and priorities
        adminMessageRequest:FireServer("getCategories")
        adminMessageRequest:FireServer("getPriorities")
        adminMessageRequest:FireServer("getMessageCount")
        adminMessageRequest:FireServer("getCooldown")
    end
end

-- Handle message button click
messageButton.MouseButton1Click:Connect(toggleMenu)

-- Handle close button click
closeButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
end)

-- Handle category dropdown
categoryDropdown.MouseButton1Click:Connect(function()
    if categoryDropdownMenu then
        categoryDropdownMenu.Visible = not categoryDropdownMenu.Visible
    end
end)

-- Handle priority dropdown
priorityDropdown.MouseButton1Click:Connect(function()
    if priorityDropdownMenu then
        priorityDropdownMenu.Visible = not priorityDropdownMenu.Visible
    end
end)

-- Handle character count
messageBox:GetPropertyChangedSignal("Text"):Connect(function()
    local text = messageBox.Text
    local count = #text
    charCount.Text = count .. "/500 characters"
    
    if count > 500 then
        charCount.TextColor3 = UI_CONFIG.ERROR_COLOR
    elseif count < 10 then
        charCount.TextColor3 = UI_CONFIG.WARNING_COLOR
    else
        charCount.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- Handle submit button
submitButton.MouseButton1Click:Connect(function()
    if not selectedCategory then
        showNotification("Please select a category", false)
        return
    end
    
    if not selectedPriority then
        showNotification("Please select a priority", false)
        return
    end
    
    local message = messageBox.Text
    if #message < 10 then
        showNotification("Message too short (minimum 10 characters)", false)
        return
    end
    
    if #message > 500 then
        showNotification("Message too long (maximum 500 characters)", false)
        return
    end
    
    -- Submit message
    adminMessageSubmitted:FireServer(selectedCategory, selectedPriority, message)
    
    -- Reset form
    selectedCategory = nil
    selectedPriority = nil
    categoryDropdown.Text = "Click to select category"
    priorityDropdown.Text = "Click to select priority"
    messageBox.Text = ""
    
    -- Close menu
    menuFrame.Visible = false
end)

-- Handle message response
adminMessageSubmitted.OnClientEvent:Connect(function(success, message)
    showNotification(message, success)
end)

-- Handle request responses
adminMessageRequest.OnClientEvent:Connect(function(responseType, data)
    if responseType == "categories" then
        if categoryDropdownMenu then
            categoryDropdownMenu:Destroy()
        end
        
        categoryDropdownMenu = createDropdown(categoryDropdown, data, function(category)
            selectedCategory = category
            categoryDropdown.Text = category
        end, false)
    elseif responseType == "priorities" then
        if priorityDropdownMenu then
            priorityDropdownMenu:Destroy()
        end
        
        priorityDropdownMenu = createDropdown(priorityDropdown, data, function(priority)
            selectedPriority = priority
            priorityDropdown.Text = priority
            priorityDropdown.TextColor3 = UI_CONFIG.PRIORITY_COLORS[priority] or UI_CONFIG.TEXT_COLOR
        end, true)
    elseif responseType == "messageCount" then
        -- Update UI with message count info
        local remaining = data.remaining
        if remaining <= 0 then
            submitButton.BackgroundColor3 = UI_CONFIG.ERROR_COLOR
            submitButton.Text = "No messages remaining"
        else
            submitButton.BackgroundColor3 = UI_CONFIG.SUCCESS_COLOR
            submitButton.Text = "Send Message (" .. remaining .. " remaining)"
        end
    elseif responseType == "cooldown" then
        if data > 0 then
            submitButton.BackgroundColor3 = UI_CONFIG.WARNING_COLOR
            submitButton.Text = "Cooldown: " .. data .. "s"
        end
    end
end)

-- Handle admin notifications
adminNotification.OnClientEvent:Connect(function(notificationData)
    if notificationData.type == "new_message" then
        showNotification("New message from " .. notificationData.sender .. " (" .. notificationData.priority .. ")", true)
    end
end)

-- Close dropdowns when clicking outside
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if categoryDropdownMenu and categoryDropdownMenu.Visible then
            categoryDropdownMenu.Visible = false
        end
        if priorityDropdownMenu and priorityDropdownMenu.Visible then
            priorityDropdownMenu.Visible = false
        end
    end
end)

-- Initialize
print("[AdminMessage] Client system initialized")
print("[AdminMessage] Message button available in center top")
print("[AdminMessage] Click the message button to open the menu")