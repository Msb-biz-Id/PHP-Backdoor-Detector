--// Roblox Simple Carry System v5.0 - FIXED & OPTIMIZED
--// Features: Simple UI, Right-side menu, Fixed remote events, Optimized debounce

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Mobile detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Configuration
local CARRY_DISTANCE = 15
local CARRY_DURATION = 30
local DEBOUNCE_TIME = 3
local UI_DURATION = 10

-- Simple emote data
local CARRY_ANIMATIONS = {
    {Name = "Piggyback", Id = "rbxassetid://507770239", Icon = "🐷"},
    {Name = "Bridal", Id = "rbxassetid://507770677", Icon = "💕"},
    {Name = "Fireman", Id = "rbxassetid://507770818", Icon = "🚒"}
}

-- Variables
local carryUI = nil
local isCarrying = false
local isBeingCarried = false
local currentCarrier = nil
local currentCarried = nil
local carryAnimation = nil
local requestCooldowns = {}
local lastTouchTime = 0
local isTouching = false

-- Close carry UI function (defined early)
local function closeCarryUI()
    if carryUI then
        local mainFrame = carryUI:FindFirstChild("MainFrame")
        if mainFrame then
            TweenService:Create(mainFrame, TweenInfo.new(0.2), {
                Position = UDim2.new(1, 0, 0.5, mainFrame.Size.Y.Offset / 2)
            }):Play()
            
            task.wait(0.2)
        end
        carryUI:Destroy()
        carryUI = nil
    end
end

-- Create RemoteEvents
local function createRemoteEvents()
    local folder = ReplicatedStorage:FindFirstChild("CarrySystemEvents")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "CarrySystemEvents"
        folder.Parent = ReplicatedStorage
    end
    
    local events = {}
    local eventNames = {"RequestCarry", "AcceptCarry", "RejectCarry", "StartCarry", "StopCarry"}
    
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
print("RemoteEvents created:", events and "Success" or "Failed")

-- Debounce system
local function canRequestCarry(targetPlayer)
    local currentTime = tick()
    local lastRequest = requestCooldowns[targetPlayer.UserId] or 0
    
    if currentTime - lastRequest < DEBOUNCE_TIME then
        local waitTime = math.ceil(DEBOUNCE_TIME - (currentTime - lastRequest))
        return false, "Wait " .. waitTime .. "s"
    end
    return true, ""
end

local function setRequestCooldown(targetPlayer)
    requestCooldowns[targetPlayer.UserId] = tick()
end

-- Check if player is in range
local function isPlayerInRange(targetPlayer)
    if not Character or not targetPlayer.Character then return false end
    
    local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart or not targetRootPart then return false end
    
    local distance = (humanoidRootPart.Position - targetRootPart.Position).Magnitude
    return distance <= CARRY_DISTANCE
end

-- Create simple carry selection UI (right side)
local function createCarrySelectionUI(targetPlayer)
    if carryUI then closeCarryUI() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CarrySelectionUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main frame (right side)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 300)
    mainFrame.Position = UDim2.new(1, -220, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Carry " .. targetPlayer.Name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    -- Animation buttons
    for i, animation in ipairs(CARRY_ANIMATIONS) do
        local animButton = Instance.new("TextButton")
        animButton.Name = "Anim_" .. i
        animButton.Size = UDim2.new(1, -20, 0, 50)
        animButton.Position = UDim2.new(0, 10, 0, 60 + (i - 1) * 60)
        animButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        animButton.BorderSizePixel = 0
        animButton.Text = animation.Icon .. " " .. animation.Name
        animButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        animButton.TextScaled = true
        animButton.Font = Enum.Font.Gotham
        animButton.Parent = mainFrame
        
        local animCorner = Instance.new("UICorner")
        animCorner.CornerRadius = UDim.new(0, 8)
        animCorner.Parent = animButton
        
        -- Hover effect
        animButton.MouseEnter:Connect(function()
            TweenService:Create(animButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        end)
        animButton.MouseLeave:Connect(function()
            TweenService:Create(animButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        end)
        
        -- Click to select
        animButton.MouseButton1Click:Connect(function()
            if events and events.RequestCarry then
                events.RequestCarry:FireServer(targetPlayer, animation)
            end
            closeCarryUI()
        end)
    end
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        closeCarryUI()
    end)
    
    -- Animate in from right
    mainFrame.Position = UDim2.new(1, 0, 0.5, -150)
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -220, 0.5, -150)
    }):Play()
    
    carryUI = screenGui
    return screenGui
end

-- Create simple accept/reject UI (right side)
local function createAcceptRejectUI(requester, animationData)
    if carryUI then closeCarryUI() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AcceptRejectUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main frame (right side)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 250, 0, 200)
    mainFrame.Position = UDim2.new(1, -270, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = requester.Name .. " wants to carry you!"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    -- Style info
    local styleLabel = Instance.new("TextLabel")
    styleLabel.Name = "Style"
    styleLabel.Size = UDim2.new(1, -20, 0, 30)
    styleLabel.Position = UDim2.new(0, 10, 0, 50)
    styleLabel.BackgroundTransparency = 1
    styleLabel.Text = "Style: " .. animationData.Name
    styleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    styleLabel.TextScaled = true
    styleLabel.Font = Enum.Font.Gotham
    styleLabel.Parent = mainFrame
    
    -- Buttons
    local acceptButton = Instance.new("TextButton")
    acceptButton.Name = "AcceptButton"
    acceptButton.Size = UDim2.new(0.45, 0, 0, 40)
    acceptButton.Position = UDim2.new(0, 10, 1, -60)
    acceptButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    acceptButton.BorderSizePixel = 0
    acceptButton.Text = "✓ Accept"
    acceptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    acceptButton.TextScaled = true
    acceptButton.Font = Enum.Font.GothamBold
    acceptButton.Parent = mainFrame
    
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 8)
    acceptCorner.Parent = acceptButton
    
    local rejectButton = Instance.new("TextButton")
    rejectButton.Name = "RejectButton"
    rejectButton.Size = UDim2.new(0.45, 0, 0, 40)
    rejectButton.Position = UDim2.new(0.55, 0, 1, -60)
    rejectButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    rejectButton.BorderSizePixel = 0
    rejectButton.Text = "✗ Reject"
    rejectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rejectButton.TextScaled = true
    rejectButton.Font = Enum.Font.GothamBold
    rejectButton.Parent = mainFrame
    
    local rejectCorner = Instance.new("UICorner")
    rejectCorner.CornerRadius = UDim.new(0, 8)
    rejectCorner.Parent = rejectButton
    
    -- Button functionality
    closeButton.MouseButton1Click:Connect(function()
        if events and events.RejectCarry then
            events.RejectCarry:FireServer(requester)
        end
        closeCarryUI()
    end)
    
    acceptButton.MouseButton1Click:Connect(function()
        if events and events.AcceptCarry then
            events.AcceptCarry:FireServer(requester)
        end
        closeCarryUI()
    end)
    
    rejectButton.MouseButton1Click:Connect(function()
        if events and events.RejectCarry then
            events.RejectCarry:FireServer(requester)
        end
        closeCarryUI()
    end)
    
    -- Auto-reject timer
    local timeLeft = UI_DURATION
    local timerConnection
    timerConnection = RunService.Heartbeat:Connect(function()
        timeLeft = timeLeft - RunService.Heartbeat:Wait()
        if timeLeft <= 0 then
            timerConnection:Disconnect()
            if events and events.RejectCarry then
                events.RejectCarry:FireServer(requester)
            end
            closeCarryUI()
        end
    end)
    
    -- Animate in from right
    mainFrame.Position = UDim2.new(1, 0, 0.5, -100)
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -270, 0.5, -100)
    }):Play()
    
    carryUI = screenGui
    return screenGui
end


-- Start carry animation
local function startCarryAnimation(animationData)
    if carryAnimation then carryAnimation:Stop() end
    carryAnimation = Humanoid:LoadAnimation(animationData.Id)
    carryAnimation:Play()
    print("Started " .. animationData.Name .. " carry")
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

-- Handle player click
local function onPlayerClicked(targetPlayer)
    if targetPlayer == LocalPlayer then return end
    if isCarrying or isBeingCarried then return end
    if not isPlayerInRange(targetPlayer) then
        print("Player too far!")
        return
    end
    
    local canRequest, errorMsg = canRequestCarry(targetPlayer)
    if not canRequest then
        print(errorMsg)
        return
    end
    
    setRequestCooldown(targetPlayer)
    createCarrySelectionUI(targetPlayer)
end

-- Mobile touch detection
local function onTouchStarted(input, gameProcessed)
    if gameProcessed then return end
    
    isTouching = true
    lastTouchTime = tick()
    
    task.spawn(function()
        while isTouching do
            task.wait(0.1)
            if tick() - lastTouchTime >= 0.5 then
                local camera = workspace.CurrentCamera
                local unitRay = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
                local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
                
                if raycastResult and raycastResult.Instance then
                    local character = raycastResult.Instance.Parent
                    local humanoid = character:FindFirstChild("Humanoid")
                    
                    if humanoid then
                        local player = Players:GetPlayerFromCharacter(character)
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

-- Handle remote events
if events.RequestCarry then
    events.RequestCarry.OnClientEvent:Connect(function(requester, animationData)
        if isBeingCarried or isCarrying then
            if events.RejectCarry then
                events.RejectCarry:FireServer(requester)
            end
            return
        end
        createAcceptRejectUI(requester, animationData)
    end)
end

if events.AcceptCarry then
    events.AcceptCarry.OnClientEvent:Connect(function(accepter, animationData)
        closeCarryUI()
        isCarrying = true
        currentCarried = accepter
        startCarryAnimation(animationData)
        
        task.wait(CARRY_DURATION)
        stopCarry()
    end)
end

if events.RejectCarry then
    events.RejectCarry.OnClientEvent:Connect(function(rejecter)
        closeCarryUI()
        print(rejecter.Name .. " rejected carry")
    end)
end

if events.StartCarry then
    events.StartCarry.OnClientEvent:Connect(function(carrier, animationData)
        isBeingCarried = true
        currentCarrier = carrier
        startCarryAnimation(animationData)
        
        task.wait(CARRY_DURATION)
        stopCarry()
    end)
end

if events.StopCarry then
    events.StopCarry.OnClientEvent:Connect(function()
        stopCarry()
    end)
end

-- Input handling
if isMobile then
    UserInputService.TouchStarted:Connect(onTouchStarted)
    UserInputService.TouchEnded:Connect(onTouchEnded)
    print("📱 Mobile controls enabled")
else
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

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F5 then
        if carryUI then
            closeCarryUI()
        else
            print("No UI to close")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F6 then
        if isCarrying or isBeingCarried then
            if events and events.StopCarry then
                events.StopCarry:FireServer()
            end
            stopCarry()
        end
    end
end)

-- Cleanup
LocalPlayer.CharacterAdded:Connect(function(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    closeCarryUI()
    stopCarry()
end)

-- Initialize
print("🚀 Simple Carry System v5.0 loaded!")
print("Controls:")
if isMobile then
    print("  Hold touch on player to request carry")
    print("  F5 - Close UI")
    print("  F6 - Stop carry")
else
    print("  Click on player to request carry")
    print("  F5 - Close UI")
    print("  F6 - Stop carry")
end
print("  UI appears on right side")