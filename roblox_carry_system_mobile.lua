--// Roblox Advanced Carry System v4.0 - MOBILE OPTIMIZED
--// Features: Touch controls, mobile UI, performance optimization
--// Compatible with: PC, Mobile, Tablet, Console

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Mobile detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isTablet = isMobile and GuiService:GetScreenResolution().Y > 1000
local isConsole = UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled

-- Configuration
local CARRY_DISTANCE = 12 -- Increased for mobile
local CARRY_DURATION = 30
local DEBOUNCE_TIME = 2
local UI_DURATION = 15 -- Longer for mobile
local TOUCH_HOLD_TIME = 0.5 -- Time to hold for carry request

-- Mobile-specific settings
local MOBILE_UI_SCALE = isTablet and 1.2 or 1.0
local TOUCH_TARGET_SIZE = 20 -- Size of touch target
local VIBRATION_ENABLED = true -- Haptic feedback

-- Animation IDs for different carry styles
local CARRY_ANIMATIONS = {
    {
        Name = "Piggyback",
        Id = "rbxassetid://507770239",
        Description = "Classic piggyback ride",
        Style = "Piggyback",
        Icon = "🐷"
    },
    {
        Name = "Bridal Carry",
        Id = "rbxassetid://507770677",
        Description = "Romantic bridal style",
        Style = "Bridal",
        Icon = "💕"
    },
    {
        Name = "Fireman Carry",
        Id = "rbxassetid://507770818",
        Description = "Over shoulder carry",
        Style = "Fireman",
        Icon = "🚒"
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
local requestCooldowns = {}
local touchStartTime = 0
local touchStartPosition = Vector2.new()
local isTouching = false
local touchConnection = nil

-- Mobile UI scaling
local function getMobileScale()
    local screenSize = GuiService:GetScreenResolution()
    local baseScale = math.min(screenSize.X, screenSize.Y) / 1080
    return math.clamp(baseScale * MOBILE_UI_SCALE, 0.8, 1.5)
end

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

-- Mobile haptic feedback
local function vibrateDevice(intensity)
    if VIBRATION_ENABLED and isMobile then
        -- Note: This requires a custom module for actual vibration
        -- For now, we'll use a visual feedback
        print("📳 Vibration: " .. intensity)
    end
end

-- Debounce system with mobile optimization
local function canRequestCarry(targetPlayer)
    local currentTime = tick()
    local lastRequest = requestCooldowns[targetPlayer.UserId] or 0
    
    if currentTime - lastRequest < DEBOUNCE_TIME then
        local waitTime = math.ceil(DEBOUNCE_TIME - (currentTime - lastRequest))
        return false, "Please wait " .. waitTime .. " seconds before requesting again."
    end
    
    return true, ""
end

local function setRequestCooldown(targetPlayer)
    requestCooldowns[targetPlayer.UserId] = tick()
end

-- Mobile-optimized carry request UI
local function createCarryRequestUI(targetPlayer, animationStyle)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CarryRequestUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local mobileScale = getMobileScale()
    local baseSize = isTablet and 400 or 350
    local baseHeight = isTablet and 250 or 200
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, baseSize * mobileScale, 0, baseHeight * mobileScale)
    mainFrame.Position = UDim2.new(0.5, -(baseSize * mobileScale) / 2, 0.3, -(baseHeight * mobileScale) / 2)
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
    title.Size = UDim2.new(1, 0, 0, 60 * mobileScale)
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
    playerName.Size = UDim2.new(1, -20, 0, 40 * mobileScale)
    playerName.Position = UDim2.new(0, 10, 0, 60 * mobileScale)
    playerName.BackgroundTransparency = 1
    playerName.Text = targetPlayer.Name .. " wants to carry you!"
    playerName.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerName.TextScaled = true
    playerName.Font = Enum.Font.Gotham
    playerName.Parent = mainFrame
    
    -- Animation style
    local styleLabel = Instance.new("TextLabel")
    styleLabel.Name = "Style"
    styleLabel.Size = UDim2.new(1, -20, 0, 30 * mobileScale)
    styleLabel.Position = UDim2.new(0, 10, 0, 100 * mobileScale)
    styleLabel.BackgroundTransparency = 1
    styleLabel.Text = "Style: " .. animationStyle
    styleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    styleLabel.TextScaled = true
    styleLabel.Font = Enum.Font.Gotham
    styleLabel.Parent = mainFrame
    
    -- Buttons container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 0, 70 * mobileScale)
    buttonContainer.Position = UDim2.new(0, 10, 1, -80 * mobileScale)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    -- Accept button (larger for mobile)
    local acceptButton = Instance.new("TextButton")
    acceptButton.Name = "AcceptButton"
    acceptButton.Size = UDim2.new(0.48, 0, 1, 0)
    acceptButton.Position = UDim2.new(0, 0, 0, 0)
    acceptButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    acceptButton.BorderSizePixel = 0
    acceptButton.Text = "✓ ACCEPT"
    acceptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    acceptButton.TextScaled = true
    acceptButton.Font = Enum.Font.GothamBold
    acceptButton.Parent = buttonContainer
    
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 12)
    acceptCorner.Parent = acceptButton
    
    -- Reject button (larger for mobile)
    local rejectButton = Instance.new("TextButton")
    rejectButton.Name = "RejectButton"
    rejectButton.Size = UDim2.new(0.48, 0, 1, 0)
    rejectButton.Position = UDim2.new(0.52, 0, 0, 0)
    rejectButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    rejectButton.BorderSizePixel = 0
    rejectButton.Text = "✗ REJECT"
    rejectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rejectButton.TextScaled = true
    rejectButton.Font = Enum.Font.GothamBold
    rejectButton.Parent = buttonContainer
    
    local rejectCorner = Instance.new("UICorner")
    rejectCorner.CornerRadius = UDim.new(0, 12)
    rejectCorner.Parent = rejectButton
    
    -- Timer label
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "Timer"
    timerLabel.Size = UDim2.new(1, 0, 0, 25 * mobileScale)
    timerLabel.Position = UDim2.new(0, 0, 1, -30 * mobileScale)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "Auto-reject in 15 seconds"
    timerLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    timerLabel.TextScaled = true
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.Parent = mainFrame
    
    -- Mobile touch feedback
    local function addTouchFeedback(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            vibrateDevice("light")
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = hoverColor,
                Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset * 1.05, button.Size.Y.Scale, button.Size.Y.Offset * 1.05)
            })
            tween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = normalColor,
                Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset / 1.05, button.Size.Y.Scale, button.Size.Y.Offset / 1.05)
            })
            tween:Play()
        end)
        
        button.MouseButton1Click:Connect(function()
            vibrateDevice("medium")
        end)
    end
    
    addTouchFeedback(acceptButton, Color3.fromRGB(70, 220, 70), Color3.fromRGB(50, 200, 50))
    addTouchFeedback(rejectButton, Color3.fromRGB(220, 70, 70), Color3.fromRGB(200, 50, 50))
    
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
        Size = UDim2.new(0, baseSize * mobileScale, 0, baseHeight * mobileScale),
        Position = UDim2.new(0.5, -(baseSize * mobileScale) / 2, 0.3, -(baseHeight * mobileScale) / 2)
    })
    tween:Play()
    
    return screenGui
end

-- Mobile-optimized carry selection UI
local function createCarrySelectionUI(targetPlayer)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CarrySelectionUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local mobileScale = getMobileScale()
    local baseSize = isTablet and 450 or 400
    local baseHeight = isTablet and 400 or 350
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, baseSize * mobileScale, 0, baseHeight * mobileScale)
    mainFrame.Position = UDim2.new(0.5, -(baseSize * mobileScale) / 2, 0.5, -(baseHeight * mobileScale) / 2)
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
    title.Size = UDim2.new(1, 0, 0, 60 * mobileScale)
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
    playerName.Size = UDim2.new(1, -20, 0, 40 * mobileScale)
    playerName.Position = UDim2.new(0, 10, 0, 60 * mobileScale)
    playerName.BackgroundTransparency = 1
    playerName.Text = "Carrying: " .. targetPlayer.Name
    playerName.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerName.TextScaled = true
    playerName.Font = Enum.Font.Gotham
    playerName.Parent = mainFrame
    
    -- Scrolling frame for animations
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "AnimationList"
    scrollFrame.Size = UDim2.new(1, -20, 1, -120 * mobileScale)
    scrollFrame.Position = UDim2.new(0, 10, 0, 100 * mobileScale)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.Parent = mainFrame
    
    -- Animation buttons
    for i, animation in ipairs(CARRY_ANIMATIONS) do
        local animButton = Instance.new("TextButton")
        animButton.Name = "Anim_" .. i
        animButton.Size = UDim2.new(1, 0, 0, 80 * mobileScale)
        animButton.Position = UDim2.new(0, 0, 0, (i - 1) * 90 * mobileScale)
        animButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        animButton.BorderSizePixel = 0
        animButton.Text = ""
        animButton.Parent = scrollFrame
        
        local animCorner = Instance.new("UICorner")
        animCorner.CornerRadius = UDim.new(0, 12)
        animCorner.Parent = animButton
        
        -- Animation icon
        local animIcon = Instance.new("TextLabel")
        animIcon.Name = "Icon"
        animIcon.Size = UDim2.new(0, 60 * mobileScale, 0, 60 * mobileScale)
        animIcon.Position = UDim2.new(0, 10, 0, 10 * mobileScale)
        animIcon.BackgroundTransparency = 1
        animIcon.Text = animation.Icon
        animIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        animIcon.TextScaled = true
        animIcon.Font = Enum.Font.Gotham
        animIcon.Parent = animButton
        
        -- Animation name
        local animName = Instance.new("TextLabel")
        animName.Name = "Name"
        animName.Size = UDim2.new(1, -80 * mobileScale, 0, 35 * mobileScale)
        animName.Position = UDim2.new(0, 80 * mobileScale, 0, 10 * mobileScale)
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
        animDesc.Size = UDim2.new(1, -80 * mobileScale, 0, 25 * mobileScale)
        animDesc.Position = UDim2.new(0, 80 * mobileScale, 0, 45 * mobileScale)
        animDesc.BackgroundTransparency = 1
        animDesc.Text = animation.Description
        animDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
        animDesc.TextScaled = true
        animDesc.TextXAlignment = Enum.TextXAlignment.Left
        animDesc.Font = Enum.Font.Gotham
        animDesc.Parent = animButton
        
        -- Mobile touch feedback
        animButton.MouseEnter:Connect(function()
            vibrateDevice("light")
            local tween = TweenService:Create(animButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(70, 70, 70),
                Size = UDim2.new(1, 0, 0, 85 * mobileScale)
            })
            tween:Play()
        end)
        
        animButton.MouseLeave:Connect(function()
            local tween = TweenService:Create(animButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Size = UDim2.new(1, 0, 0, 80 * mobileScale)
            })
            tween:Play()
        end)
        
        -- Click to select
        animButton.MouseButton1Click:Connect(function()
            vibrateDevice("medium")
            requestCarryEvent:FireServer(targetPlayer, animation)
            closeCarryUI()
        end)
    end
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #CARRY_ANIMATIONS * 90 * mobileScale)
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(1, -20, 0, 50 * mobileScale)
    cancelButton.Position = UDim2.new(0, 10, 1, -60 * mobileScale)
    cancelButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "CANCEL"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextScaled = true
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Parent = mainFrame
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 12)
    cancelCorner.Parent = cancelButton
    
    cancelButton.MouseButton1Click:Connect(function()
        vibrateDevice("light")
        closeCarryUI()
    end)
    
    -- Animate in
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, baseSize * mobileScale, 0, baseHeight * mobileScale),
        Position = UDim2.new(0.5, -(baseSize * mobileScale) / 2, 0.5, -(baseHeight * mobileScale) / 2)
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

-- Mobile touch detection
local function onTouchStarted(input, gameProcessed)
    if gameProcessed then return end
    
    isTouching = true
    touchStartTime = tick()
    touchStartPosition = input.Position
    
    -- Start touch hold detection
    task.spawn(function()
        while isTouching do
            task.wait(0.1)
            if tick() - touchStartTime >= TOUCH_HOLD_TIME then
                -- Touch held long enough, check for player
                local target = workspace:FindPartOnRay(Ray.new(
                    workspace.CurrentCamera.CFrame.Position,
                    workspace.CurrentCamera.CFrame.LookVector * 1000
                ))
                
                if target and target.Parent then
                    local humanoid = target.Parent:FindFirstChild("Humanoid")
                    if humanoid then
                        local player = Players:GetPlayerFromCharacter(target.Parent)
                        if player and player ~= LocalPlayer then
                            onPlayerClicked(player)
                            break
                        end
                    end
                end
            end
        end
    end)
end

local function onTouchEnded(input, gameProcessed)
    if gameProcessed then return end
    
    isTouching = false
end

-- Handle player click (for PC)
local function onPlayerClicked(targetPlayer)
    if targetPlayer == LocalPlayer then return end
    if isCarrying or isBeingCarried then return end
    if not isPlayerInRange(targetPlayer) then
        print("Player too far away!")
        vibrateDevice("heavy")
        return
    end
    
    local canRequest, errorMsg = canRequestCarry(targetPlayer)
    if not canRequest then
        print(errorMsg)
        vibrateDevice("heavy")
        return
    end
    
    setRequestCooldown(targetPlayer)
    vibrateDevice("medium")
    carryUI = createCarrySelectionUI(targetPlayer)
end

-- Handle remote events
requestCarryEvent.OnClientEvent:Connect(function(requester, animationData)
    if isBeingCarried or isCarrying then
        rejectCarryEvent:FireServer(requester)
        return
    end
    
    vibrateDevice("medium")
    carryUI = createCarryRequestUI(requester, animationData.Name)
end)

acceptCarryEvent.OnClientEvent:Connect(function(accepter, animationData)
    closeCarryUI()
    isCarrying = true
    currentCarried = accepter
    startCarryAnimation(animationData)
    vibrateDevice("success")
    
    -- Auto stop after duration
    task.wait(CARRY_DURATION)
    stopCarry()
end)

rejectCarryEvent.OnClientEvent:Connect(function(rejecter)
    closeCarryUI()
    vibrateDevice("light")
    print(rejecter.Name .. " rejected your carry request")
end)

startCarryEvent.OnClientEvent:Connect(function(carrier, animationData)
    isBeingCarried = true
    currentCarrier = carrier
    startCarryAnimation(animationData)
    vibrateDevice("success")
    
    -- Auto stop after duration
    task.wait(CARRY_DURATION)
    stopCarry()
end)

stopCarryEvent.OnClientEvent:Connect(function()
    stopCarry()
    vibrateDevice("light")
end)

-- Mobile touch controls
if isMobile then
    UserInputService.TouchStarted:Connect(onTouchStarted)
    UserInputService.TouchEnded:Connect(onTouchEnded)
    
    -- Add mobile-specific context actions
    ContextActionService:BindAction("StopCarry", function()
        if isCarrying or isBeingCarried then
            stopCarryEvent:FireServer()
            stopCarry()
        end
    end, false, Enum.KeyCode.ButtonB)
    
    print("📱 Mobile controls enabled")
else
    -- PC mouse controls
    local Mouse = LocalPlayer:GetMouse()
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
    
    print("🖱️ PC controls enabled")
end

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
print("🚀 Advanced Carry System v4.0 - Mobile Optimized loaded!")
print("Device: " .. (isMobile and "Mobile" or "PC"))
print("Controls:")
if isMobile then
    print("  Hold touch on player body to request carry")
    print("  B button - Stop current carry")
else
    print("  Click on player body to request carry")
    print("  F2 - Stop current carry")
end
print("  UI will show carry options and accept/reject buttons")

-- Show initial help
task.wait(2)
print("💡 Tip: Get close to other players and " .. (isMobile and "hold touch" or "click") .. " on their body to start carrying!")