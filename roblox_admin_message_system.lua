--// Roblox Admin Message System v1.0
--// Features: Discord Webhook, Toggle Menu, Message to Admin
--// Menu Position: Top Center

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Configuration
local DISCORD_WEBHOOK_URL = "YOUR_DISCORD_WEBHOOK_URL_HERE" -- Replace with your webhook URL
local ADMIN_USER_ID = 123456789 -- Replace with admin's UserId
local MENU_DURATION = 30 -- How long menu stays open
local MAX_MESSAGE_LENGTH = 500

-- Variables
local adminMenu = nil
local isMenuOpen = false
local messageHistory = {}

-- Create RemoteEvents
local function createRemoteEvents()
    local folder = ReplicatedStorage:FindFirstChild("AdminMessageEvents")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "AdminMessageEvents"
        folder.Parent = ReplicatedStorage
    end
    
    local events = {}
    local eventNames = {"SendMessageToAdmin", "SendToDiscord", "GetMessageHistory"}
    
    for _, name in ipairs(eventNames) do
        local event = folder:FindFirstChild(name)
        if not event then
            event = Instance.new("RemoteEvent")
            event.Name = name
            event.Parent = folder
        end
        events[name] = event
    end
    
    return events
end

-- Get RemoteEvents
local events = createRemoteEvents()

-- Create toggle button (top center)
local function createToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminMessageToggle"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 60, 0, 60)
    toggleButton.Position = UDim2.new(0.5, -30, 0, 20)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "📨"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = screenGui
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 30)
    corner.Parent = toggleButton
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.3
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = toggleButton.ZIndex - 1
    shadow.Parent = screenGui
    
    -- Hover effect
    toggleButton.MouseEnter:Connect(function()
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 70),
            Size = UDim2.new(0, 65, 0, 65),
            Position = UDim2.new(0.5, -32.5, 0, 17.5)
        }):Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            Size = UDim2.new(0, 60, 0, 60),
            Position = UDim2.new(0.5, -30, 0, 20)
        }):Play()
    end)
    
    -- Click to toggle menu
    toggleButton.MouseButton1Click:Connect(function()
        if isMenuOpen then
            closeAdminMenu()
        else
            openAdminMenu()
        end
    end)
    
    return screenGui
end

-- Create admin message menu
local function createAdminMenu()
    if adminMenu then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminMessageMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main frame (top center)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0, 100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.3
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 0, 50)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "📨 Message Admin"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 20)
    closeCorner.Parent = closeButton
    
    -- Player info
    local playerInfo = Instance.new("TextLabel")
    playerInfo.Name = "PlayerInfo"
    playerInfo.Size = UDim2.new(1, -20, 0, 30)
    playerInfo.Position = UDim2.new(0, 10, 0, 60)
    playerInfo.BackgroundTransparency = 1
    playerInfo.Text = "From: " .. LocalPlayer.Name .. " (ID: " .. LocalPlayer.UserId .. ")"
    playerInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerInfo.TextScaled = true
    playerInfo.Font = Enum.Font.Gotham
    playerInfo.Parent = mainFrame
    
    -- Message input
    local messageInput = Instance.new("TextBox")
    messageInput.Name = "MessageInput"
    messageInput.Size = UDim2.new(1, -20, 0, 200)
    messageInput.Position = UDim2.new(0, 10, 0, 100)
    messageInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    messageInput.BorderSizePixel = 0
    messageInput.Text = ""
    messageInput.PlaceholderText = "Type your message to admin here...\n\nExamples:\n• Report a player\n• Ask for help\n• Report a bug\n• Request assistance"
    messageInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    messageInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageInput.TextScaled = true
    messageInput.Font = Enum.Font.Gotham
    messageInput.TextWrapped = true
    messageInput.ClearTextOnFocus = false
    messageInput.MultiLine = true
    messageInput.Parent = mainFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = messageInput
    
    -- Character count
    local charCount = Instance.new("TextLabel")
    charCount.Name = "CharCount"
    charCount.Size = UDim2.new(1, -20, 0, 20)
    charCount.Position = UDim2.new(0, 10, 0, 310)
    charCount.BackgroundTransparency = 1
    charCount.Text = "0/" .. MAX_MESSAGE_LENGTH .. " characters"
    charCount.TextColor3 = Color3.fromRGB(150, 150, 150)
    charCount.TextScaled = true
    charCount.Font = Enum.Font.Gotham
    charCount.TextXAlignment = Enum.TextXAlignment.Right
    charCount.Parent = mainFrame
    
    -- Update character count
    messageInput.Changed:Connect(function(property)
        if property == "Text" then
            local text = messageInput.Text
            charCount.Text = #text .. "/" .. MAX_MESSAGE_LENGTH .. " characters"
            
            if #text > MAX_MESSAGE_LENGTH then
                charCount.TextColor3 = Color3.fromRGB(255, 100, 100)
                messageInput.Text = text:sub(1, MAX_MESSAGE_LENGTH)
            else
                charCount.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
    end)
    
    -- Send button
    local sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.Size = UDim2.new(0.6, 0, 0, 50)
    sendButton.Position = UDim2.new(0, 10, 1, -70)
    sendButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    sendButton.BorderSizePixel = 0
    sendButton.Text = "📤 Send to Admin"
    sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendButton.TextScaled = true
    sendButton.Font = Enum.Font.GothamBold
    sendButton.Parent = mainFrame
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 8)
    sendCorner.Parent = sendButton
    
    -- Discord button
    local discordButton = Instance.new("TextButton")
    discordButton.Name = "DiscordButton"
    discordButton.Size = UDim2.new(0.35, 0, 0, 50)
    discordButton.Position = UDim2.new(0.65, 0, 1, -70)
    discordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    discordButton.BorderSizePixel = 0
    discordButton.Text = "💬 Discord"
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextScaled = true
    discordButton.Font = Enum.Font.GothamBold
    discordButton.Parent = mainFrame
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 8)
    discordCorner.Parent = discordButton
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 1, -40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready to send message"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    -- Button functionality
    closeButton.MouseButton1Click:Connect(function()
        closeAdminMenu()
    end)
    
    sendButton.MouseButton1Click:Connect(function()
        sendMessageToAdmin(messageInput.Text)
    end)
    
    discordButton.MouseButton1Click:Connect(function()
        sendToDiscord(messageInput.Text)
    end)
    
    -- Hover effects
    local function addHoverEffect(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
        end)
    end
    
    addHoverEffect(closeButton, Color3.fromRGB(255, 150, 150), Color3.fromRGB(255, 100, 100))
    addHoverEffect(sendButton, Color3.fromRGB(70, 220, 70), Color3.fromRGB(50, 200, 50))
    addHoverEffect(discordButton, Color3.fromRGB(134, 157, 238), Color3.fromRGB(114, 137, 218))
    
    -- Animate in from top
    mainFrame.Position = UDim2.new(0.5, -200, 0, -500)
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -200, 0, 100)
    }):Play()
    
    adminMenu = screenGui
    isMenuOpen = true
    
    -- Auto close after duration
    task.wait(MENU_DURATION)
    if isMenuOpen then
        closeAdminMenu()
    end
    
    return screenGui
end

-- Close admin menu
local function closeAdminMenu()
    if not adminMenu then return end
    
    local mainFrame = adminMenu:FindFirstChild("MainFrame")
    if mainFrame then
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0.5, -200, 0, -500)
        }):Play()
        
        task.wait(0.2)
    end
    
    adminMenu:Destroy()
    adminMenu = nil
    isMenuOpen = false
end

-- Open admin menu
local function openAdminMenu()
    if isMenuOpen then return end
    createAdminMenu()
end

-- Send message to admin
local function sendMessageToAdmin(message)
    if not message or message == "" then
        updateStatus("Please enter a message!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    if #message > MAX_MESSAGE_LENGTH then
        updateStatus("Message too long!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    updateStatus("Sending to admin...", Color3.fromRGB(255, 255, 100))
    
    -- Send to admin via RemoteEvent
    if events and events.SendMessageToAdmin then
        events.SendMessageToAdmin:FireServer(message, LocalPlayer.Name, LocalPlayer.UserId)
    end
    
    -- Add to history
    table.insert(messageHistory, {
        message = message,
        timestamp = os.time(),
        type = "admin"
    })
    
    updateStatus("Message sent to admin!", Color3.fromRGB(100, 255, 100))
    
    -- Clear input
    if adminMenu then
        local messageInput = adminMenu:FindFirstChild("MainFrame"):FindFirstChild("MessageInput")
        if messageInput then
            messageInput.Text = ""
        end
    end
    
    -- Close menu after delay
    task.wait(2)
    closeAdminMenu()
end

-- Send to Discord webhook
local function sendToDiscord(message)
    if not message or message == "" then
        updateStatus("Please enter a message!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    if #message > MAX_MESSAGE_LENGTH then
        updateStatus("Message too long!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    if DISCORD_WEBHOOK_URL == "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        updateStatus("Discord webhook not configured!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    updateStatus("Sending to Discord...", Color3.fromRGB(255, 255, 100))
    
    -- Send to Discord via RemoteEvent
    if events and events.SendToDiscord then
        events.SendToDiscord:FireServer(message, LocalPlayer.Name, LocalPlayer.UserId)
    end
    
    -- Add to history
    table.insert(messageHistory, {
        message = message,
        timestamp = os.time(),
        type = "discord"
    })
    
    updateStatus("Message sent to Discord!", Color3.fromRGB(100, 255, 100))
    
    -- Clear input
    if adminMenu then
        local messageInput = adminMenu:FindFirstChild("MainFrame"):FindFirstChild("MessageInput")
        if messageInput then
            messageInput.Text = ""
        end
    end
    
    -- Close menu after delay
    task.wait(2)
    closeAdminMenu()
end

-- Update status label
local function updateStatus(text, color)
    if adminMenu then
        local statusLabel = adminMenu:FindFirstChild("MainFrame"):FindFirstChild("Status")
        if statusLabel then
            statusLabel.Text = text
            statusLabel.TextColor3 = color
        end
    end
end

-- Handle remote events
if events.SendMessageToAdmin then
    events.SendMessageToAdmin.OnClientEvent:Connect(function(success, message)
        if success then
            updateStatus("Admin received your message!", Color3.fromRGB(100, 255, 100))
        else
            updateStatus("Failed to send to admin: " .. (message or "Unknown error"), Color3.fromRGB(255, 100, 100))
        end
    end)
end

if events.SendToDiscord then
    events.SendToDiscord.OnClientEvent:Connect(function(success, message)
        if success then
            updateStatus("Message sent to Discord!", Color3.fromRGB(100, 255, 100))
        else
            updateStatus("Failed to send to Discord: " .. (message or "Unknown error"), Color3.fromRGB(255, 100, 100))
        end
    end)
end

-- Keyboard shortcut (F9 to toggle menu)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F9 then
        if isMenuOpen then
            closeAdminMenu()
        else
            openAdminMenu()
        end
    end
end)

-- Cleanup on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    closeAdminMenu()
end)

-- Initialize
createToggleButton()

print("📨 Admin Message System loaded!")
print("Controls:")
print("  Click 📨 button (top center) to open menu")
print("  F9 - Toggle menu")
print("  Send messages to admin or Discord")
print("  Auto-close after " .. MENU_DURATION .. " seconds")

-- Show initial help
task.wait(2)
print("💡 Tip: Click the 📨 button in the top center to message admin!")