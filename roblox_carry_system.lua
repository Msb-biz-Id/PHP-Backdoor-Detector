--// Roblox Advanced Carry System v3.0
--// Features: Click to carry, 3 animations, UI system, debounce optimization
--// Click on player body to request carry

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local CARRY_DISTANCE = 10 -- Maximum distance to request carry
local CARRY_DURATION = 30 -- How long carry lasts (seconds)
local DEBOUNCE_TIME = 2 -- Debounce time between requests
local UI_DURATION = 10 -- How long UI stays open

-- Animation IDs for different carry styles
local CARRY_ANIMATIONS = {
    {
        Name = "Piggyback",
        Id = "rbxassetid://507770239", -- Adjust with actual animation IDs
        Description = "Classic piggyback ride",
        Style = "Piggyback"
    },
    {
        Name = "Bridal Carry",
        Id = "rbxassetid://507770677",
        Description = "Romantic bridal style",
        Style = "Bridal"
    },
    {
        Name = "Fireman Carry",
        Id = "rbxassetid://507770818",
        Description = "Over shoulder carry",
        Style = "Fireman"
    }
}

-- Variables
local carryUI = nil
local isCarrying = false
local isBeingCarried = false
local currentCarrier = nil
local currentCarried = nil
local carryAnimation = nil
local lastRequestTime = 0
local requestCooldowns = {} -- Player-specific cooldowns

-- Create RemoteEvents for carry system
local function createRemoteEvents()
    local folder = Instance.new("Folder")
    folder.Name = "CarrySystemEvents"
    folder.Parent = ReplicatedStorage
    
    local requestCarryEvent = Instance.new("RemoteEvent")
    requestCarryEvent.Name = "RequestCarry"
    requestCarryEvent.Parent = folder
    
    local acceptCarryEvent = Instance.new("RemoteEvent")
    acceptCarryEvent.Name = "AcceptCarry"
    acceptCarryEvent.Parent = folder
    
    local rejectCarryEvent = Instance.new("RemoteEvent")
    rejectCarryEvent.Name = "RejectCarry"
    rejectCarryEvent.Parent = folder
    
    local startCarryEvent = Instance.new("RemoteEvent")
    startCarryEvent.Name = "StartCarry"
    startCarryEvent.Parent = folder
    
    local stopCarryEvent = Instance.new("RemoteEvent")
    stopCarryEvent.Name = "StopCarry"
    stopCarryEvent.Parent = folder
    
    return requestCarryEvent, acceptCarryEvent, rejectCarryEvent, startCarryEvent, stopCarryEvent
end

-- Get or create RemoteEvents
local requestCarryEvent, acceptCarryEvent, rejectCarryEvent, startCarryEvent, stopCarryEvent = createRemoteEvents()

-- Debounce system
local function canRequestCarry(targetPlayer)
    local currentTime = tick()
    local lastRequest = requestCooldowns[targetPlayer.UserId] or 0
    
    if currentTime - lastRequest < DEBOUNCE_TIME then
        return false, "Please wait " .. math.ceil(DEBOUNCE_TIME - (currentTime - lastRequest)) .. " seconds before requesting again."
    end
    
    return true, ""
end

local function setRequestCooldown(targetPlayer)
    requestCooldowns[targetPlayer.UserId] = tick()
end

-- Create carry request UI
local function createCarryRequestUI(targetPlayer, animationStyle)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CarryRequestUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -175, 0.3, -100)
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
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🚀 Carry Request"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Player name
    local playerName = Instance.new("TextLabel")
    playerName.Name = "PlayerName"
    playerName.Size = UDim2.new(1, -20, 0, 30)
    playerName.Position = UDim2.new(0, 10, 0, 50)
    playerName.BackgroundTransparency = 1
    playerName.Text = targetPlayer.Name .. " wants to carry you!"
    playerName.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerName.TextScaled = true
    playerName.Font = Enum.Font.Gotham
    playerName.Parent = mainFrame
    
    -- Animation style
    local styleLabel = Instance.new("TextLabel")
    styleLabel.Name = "Style"
    styleLabel.Size = UDim2.new(1, -20, 0, 25)
    styleLabel.Position = UDim2.new(0, 10, 0, 80)
    styleLabel.BackgroundTransparency = 1
    styleLabel.Text = "Style: " .. animationStyle
    styleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    styleLabel.TextScaled = true
    styleLabel.Font = Enum.Font.Gotham
    styleLabel.Parent = mainFrame
    
    -- Buttons container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 0, 50)
    buttonContainer.Position = UDim2.new(0, 10, 1, -60)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    -- Accept button
    local acceptButton = Instance.new("TextButton")
    acceptButton.Name = "AcceptButton"
    acceptButton.Size = UDim2.new(0.45, 0, 1, 0)
    acceptButton.Position = UDim2.new(0, 0, 0, 0)
    acceptButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    acceptButton.BorderSizePixel = 0
    acceptButton.Text = "✓ Accept"
    acceptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    acceptButton.TextScaled = true
    acceptButton.Font = Enum.Font.GothamBold
    acceptButton.Parent = buttonContainer
    
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 8)
    acceptCorner.Parent = acceptButton
    
    -- Reject button
    local rejectButton = Instance.new("TextButton")
    rejectButton.Name = "RejectButton"
    rejectButton.Size = UDim2.new(0.45, 0, 1, 0)
    rejectButton.Position = UDim2.new(0.55, 0, 0, 0)
    rejectButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    rejectButton.BorderSizePixel = 0
    rejectButton.Text = "✗ Reject"
    rejectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rejectButton.TextScaled = true
    rejectButton.Font = Enum.Font.GothamBold
    rejectButton.Parent = buttonContainer
    
    local rejectCorner = Instance.new("UICorner")
    rejectCorner.CornerRadius = UDim.new(0, 8)
    rejectCorner.Parent = rejectButton
    
    -- Timer label
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "Timer"
    timerLabel.Size = UDim2.new(1, 0, 0, 20)
    timerLabel.Position = UDim2.new(0, 0, 1, -30)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "Auto-reject in 10 seconds"
    timerLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    timerLabel.TextScaled = true
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.Parent = mainFrame
    
    -- Button hover effects
    local function addHoverEffect(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = hoverColor
            })
            tween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = normalColor
            })
            tween:Play()
        end)
    end
    
    addHoverEffect(acceptButton, Color3.fromRGB(70, 220, 70), Color3.fromRGB(50, 200, 50))
    addHoverEffect(rejectButton, Color3.fromRGB(220, 70, 70), Color3.fromRGB(200, 50, 50))
    
    -- Button functionality
    acceptButton.MouseButton1Click:Connect(function()
        acceptCarryEvent:FireServer(targetPlayer)
        closeCarryUI()
    end)
    
    rejectButton.MouseButton1Click:Connect(function()
        rejectCarryEvent:FireServer(targetPlayer)
        closeCarryUI()
    end)
    
    -- Auto-reject timer
    local timeLeft = UI_DURATION
    local timerConnection
    timerConnection = RunService.Heartbeat:Connect(function()
        timeLeft = timeLeft - RunService.Heartbeat:Wait()
        timerLabel.Text = "Auto-reject in " .. math.ceil(timeLeft) .. " seconds"
        
        if timeLeft <= 0 then
            timerConnection:Disconnect()
            rejectCarryEvent:FireServer(targetPlayer)
            closeCarryUI()
        end
    end)
    
    -- Animate in
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 350, 0, 200),
        Position = UDim2.new(0.5, -175, 0.3, -100)
    })
    tween:Play()
    
    return screenGui
end

-- Create carry animation selection UI
local function createCarrySelectionUI(targetPlayer)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CarrySelectionUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎭 Select Carry Style"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Player name
    local playerName = Instance.new("TextLabel")
    playerName.Name = "PlayerName"
    playerName.Size = UDim2.new(1, -20, 0, 30)
    playerName.Position = UDim2.new(0, 10, 0, 50)
    playerName.BackgroundTransparency = 1
    playerName.Text = "Carrying: " .. targetPlayer.Name
    playerName.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerName.TextScaled = true
    playerName.Font = Enum.Font.Gotham
    playerName.Parent = mainFrame
    
    -- Animation buttons
    for i, animation in ipairs(CARRY_ANIMATIONS) do
        local animButton = Instance.new("TextButton")
        animButton.Name = "Anim_" .. i
        animButton.Size = UDim2.new(1, -20, 0, 50)
        animButton.Position = UDim2.new(0, 10, 0, 90 + (i - 1) * 60)
        animButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        animButton.BorderSizePixel = 0
        animButton.Text = ""
        animButton.Parent = mainFrame
        
        local animCorner = Instance.new("UICorner")
        animCorner.CornerRadius = UDim.new(0, 8)
        animCorner.Parent = animButton
        
        -- Animation name
        local animName = Instance.new("TextLabel")
        animName.Name = "Name"
        animName.Size = UDim2.new(1, -60, 0, 25)
        animName.Position = UDim2.new(0, 50, 0, 5)
        animName.BackgroundTransparency = 1
        animName.Text = animation.Name
        animName.TextColor3 = Color3.fromRGB(255, 255, 255)
        animName.TextScaled = true
        animName.TextXAlignment = Enum.TextXAlignment.Left
        animName.Font = Enum.Font.GothamBold
        animName.Parent = animButton
        
        -- Animation description
        local animDesc = Instance.new("TextLabel")
        animDesc.Name = "Description"
        animDesc.Size = UDim2.new(1, -60, 0, 20)
        animDesc.Position = UDim2.new(0, 50, 0, 25)
        animDesc.BackgroundTransparency = 1
        animDesc.Text = animation.Description
        animDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
        animDesc.TextScaled = true
        animDesc.TextXAlignment = Enum.TextXAlignment.Left
        animDesc.Font = Enum.Font.Gotham
        animDesc.Parent = animButton
        
        -- Animation icon
        local animIcon = Instance.new("TextLabel")
        animIcon.Name = "Icon"
        animIcon.Size = UDim2.new(0, 30, 0, 30)
        animIcon.Position = UDim2.new(0, 10, 0, 10)
        animIcon.BackgroundTransparency = 1
        animIcon.Text = "🎭"
        animIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        animIcon.TextScaled = true
        animIcon.Font = Enum.Font.Gotham
        animIcon.Parent = animButton
        
        -- Hover effect
        animButton.MouseEnter:Connect(function()
            local tween = TweenService:Create(animButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            })
            tween:Play()
        end)
        
        animButton.MouseLeave:Connect(function()
            local tween = TweenService:Create(animButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            })
            tween:Play()
        end)
        
        -- Click to select
        animButton.MouseButton1Click:Connect(function()
            requestCarryEvent:FireServer(targetPlayer, animation)
            closeCarryUI()
        end)
    end
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(1, -20, 0, 40)
    cancelButton.Position = UDim2.new(0, 10, 1, -50)
    cancelButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextScaled = true
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Parent = mainFrame
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 8)
    cancelCorner.Parent = cancelButton
    
    cancelButton.MouseButton1Click:Connect(function()
        closeCarryUI()
    end)
    
    -- Animate in
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150)
    })
    tween:Play()
    
    return screenGui
end

-- Close carry UI
local function closeCarryUI()
    if carryUI then
        local mainFrame = carryUI:FindFirstChild("MainFrame")
        if mainFrame then
            local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            
            tween:Play()
            tween.Completed:Connect(function()
                if carryUI then
                    carryUI:Destroy()
                    carryUI = nil
                end
            end)
        else
            carryUI:Destroy()
            carryUI = nil
        end
    end
end

-- Check if player is in range
local function isPlayerInRange(targetPlayer)
    if not Character or not targetPlayer.Character then
        return false
    end
    
    local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart or not targetRootPart then
        return false
    end
    
    local distance = (humanoidRootPart.Position - targetRootPart.Position).Magnitude
    return distance <= CARRY_DISTANCE
end

-- Start carry animation
local function startCarryAnimation(animationData)
    if carryAnimation then
        carryAnimation:Stop()
    end
    
    carryAnimation = Humanoid:LoadAnimation(animationData.Id)
    carryAnimation:Play()
    
    print("Started " .. animationData.Name .. " carry animation")
end

-- Stop carry
local function stopCarry()
    if carryAnimation then
        carryAnimation:Stop()
        carryAnimation = nil
    end
    
    isCarrying = false
    isBeingCarried = false
    currentCarrier = nil
    currentCarried = nil
    
    print("Carry stopped")
end

-- Handle mouse click on player
local function onPlayerClicked(targetPlayer)
    if targetPlayer == LocalPlayer then return end
    if isCarrying or isBeingCarried then return end
    if not isPlayerInRange(targetPlayer) then
        print("Player too far away!")
        return
    end
    
    local canRequest, errorMsg = canRequestCarry(targetPlayer)
    if not canRequest then
        print(errorMsg)
        return
    end
    
    setRequestCooldown(targetPlayer)
    carryUI = createCarrySelectionUI(targetPlayer)
end

-- Handle remote events
requestCarryEvent.OnClientEvent:Connect(function(requester, animationData)
    if isBeingCarried or isCarrying then
        rejectCarryEvent:FireServer(requester)
        return
    end
    
    carryUI = createCarryRequestUI(requester, animationData.Name)
end)

acceptCarryEvent.OnClientEvent:Connect(function(accepter, animationData)
    closeCarryUI()
    isCarrying = true
    currentCarried = accepter
    startCarryAnimation(animationData)
    
    -- Auto stop after duration
    task.wait(CARRY_DURATION)
    stopCarry()
end)

rejectCarryEvent.OnClientEvent:Connect(function(rejecter)
    closeCarryUI()
    print(rejecter.Name .. " rejected your carry request")
end)

startCarryEvent.OnClientEvent:Connect(function(carrier, animationData)
    isBeingCarried = true
    currentCarrier = carrier
    startCarryAnimation(animationData)
    
    -- Auto stop after duration
    task.wait(CARRY_DURATION)
    stopCarry()
end)

stopCarryEvent.OnClientEvent:Connect(function()
    stopCarry()
end)

-- Mouse click detection
Mouse.Button1Down:Connect(function()
    local target = Mouse.Target
    if target and target.Parent then
        local humanoid = target.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local player = Players:GetPlayerFromCharacter(target.Parent)
            if player then
                onPlayerClicked(player)
            end
        end
    end
end)

-- Keyboard shortcut (F2 to stop carry)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F2 then
        if isCarrying or isBeingCarried then
            stopCarryEvent:FireServer()
            stopCarry()
        end
    end
end)

-- Cleanup on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    
    -- Close UI if open
    closeCarryUI()
    
    -- Stop any ongoing carry
    stopCarry()
end)

-- Initialize
print("🚀 Advanced Carry System loaded!")
print("Controls:")
print("  Click on player body to request carry")
print("  F2 - Stop current carry")
print("  UI will show carry options and accept/reject buttons")

-- Show initial help
task.wait(2)
print("💡 Tip: Get close to other players and click on their body to start carrying!")