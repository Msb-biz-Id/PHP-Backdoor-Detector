-- Carry System Client (UI minimalis, mobile-friendly, animasi, ringan, DEBOUNCE, CLEAN)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Remotes
local folder = ReplicatedStorage:WaitForChild("CarrySystem")
local EvCarryRequest = folder:WaitForChild("CarryRequest")
local EvCarryPrompt  = folder:WaitForChild("CarryPrompt")
local EvCarryReply   = folder:WaitForChild("CarryReply")
local EvCarryBegin   = folder:WaitForChild("CarryBegin")
local EvStopCarry    = folder:WaitForChild("StopCarry")
local EvCarryEnded   = folder:WaitForChild("CarryEnded")

-- 3 preset animasi (GENDONG1, GENDONG2, GENDONG3)
-- Ganti ID sesuai aset Anda jika perlu
local ANIMS = {
	GENDONG1 = { carrier = 106628053522111, target = 73677695199247 },
	GENDONG2 = { carrier = 104241740124439, target = 130886148962953 },
	GENDONG3 = { carrier = 135762724932274, target = 138639627248456 },
}

-- State
local ui = nil
local selectedTargetName = nil
local selectedAnimKey = "GENDONG1"
local isCarryingOrCarried = false
local playingTrack = nil

-- CLIENT-SIDE DEBOUNCE
local clientDebounce = {
	uiInteraction = 0,
	playerSelection = 0,
	buttonClick = 0,
	animationPlay = 0
}
local CLIENT_DEBOUNCE_TIME = 0.25 -- 250ms debounce untuk UI

-- Debounce function untuk client
local function checkClientDebounce(actionType)
	local currentTime = tick()
	if currentTime - clientDebounce[actionType] < CLIENT_DEBOUNCE_TIME then
		return false
	end
	clientDebounce[actionType] = currentTime
	return true
end

local function destroyUI()
	if ui then
		ui:Destroy()
		ui = nil
	end
end

local function stopLocalAnim()
	if playingTrack and playingTrack.IsPlaying then
		playingTrack:Stop(0.15)
	end
	playingTrack = nil
end

local function playLocalAnim(animId)
	if not animId or animId == 0 then return end

	-- Debounce animation playing
	if not checkClientDebounce("animationPlay") then return end

	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = hum
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. tostring(animId)

	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0.1)
	playingTrack = track
end

local function buildAnimGrid(parent, scale)
	local grid = Instance.new("Frame")
	grid.Name = "AnimGrid"
	grid.BackgroundTransparency = 1
	grid.Size = UDim2.new(1, -20, 0, math.floor(70 * scale))
	grid.Position = UDim2.new(0, 10, 0, math.floor(62 * scale))
	grid.Parent = parent

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0, math.floor(68 * scale), 0, math.floor(28 * scale))
	layout.CellPadding = UDim2.new(0, math.floor(8 * scale), 0, math.floor(8 * scale))
	layout.FillDirectionMaxCells = 3
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = grid

	local names = { "GENDONG1", "GENDONG2", "GENDONG3" }
	for _, key in ipairs(names) do
		local b = Instance.new("TextButton")
		b.Name = "Anim_" .. key
		b.Size = UDim2.new(0, 0, 0, 0)
		b.BackgroundColor3 = (selectedAnimKey == key) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
		b.BorderSizePixel = 0
		b.Text = key
		b.TextColor3 = Color3.fromRGB(255,255,255)
		b.TextSize = math.floor(12 * scale)
		b.Font = Enum.Font.GothamBold
		b.Parent = grid

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = b

		-- Debounced animation selection
		b.MouseButton1Click:Connect(function()
			if checkClientDebounce("buttonClick") then
				selectedAnimKey = key
				for _, btn in ipairs(grid:GetChildren()) do
					if btn:IsA("TextButton") then
						btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					end
				end
				b.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			end
		end)
	end
end

local function buildUI()
	if ui then ui:Destroy() end

	ui = Instance.new("ScreenGui")
	ui.Name = "CarryMenu"
	ui.ResetOnSpawn = false
	ui.IgnoreGuiInset = true
	ui.Parent = PlayerGui

	local mobile = UserInputService.TouchEnabled
	local scale = mobile and 0.92 or 1

	local height = isCarryingOrCarried and 120 or 160
	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.Size = UDim2.new(0, math.floor(240 * scale), 0, math.floor(height * scale))
	frame.Position = UDim2.new(1, -math.floor(260 * scale), 0.5, -math.floor((height/2) * scale))
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.Parent = ui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, math.floor(26 * scale))
	title.Position = UDim2.new(0, 10, 0, math.floor(8 * scale))
	title.BackgroundTransparency = 1
	title.Text = "Carry"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = math.floor(16 * scale)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, math.floor(24 * scale), 0, math.floor(24 * scale))
	close.Position = UDim2.new(1, -math.floor(30 * scale), 0, math.floor(8 * scale))
	close.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
	close.BorderSizePixel = 0
	close.Text = "X"
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.GothamBold
	close.TextSize = math.floor(14 * scale)
	close.Parent = frame
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = close

	-- Debounced close button
	close.MouseButton1Click:Connect(function()
		if checkClientDebounce("uiInteraction") then
			destroyUI()
		end
	end)

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.Size = UDim2.new(1, -20, 0, math.floor(20 * scale))
	status.Position = UDim2.new(0, 10, 0, math.floor(40 * scale))
	status.BackgroundTransparency = 1
	status.Text = isCarryingOrCarried and "Status: Carrying" or (selectedTargetName and ("Selected: " .. selectedTargetName) or "Click player to select")
	status.TextColor3 = Color3.fromRGB(220, 220, 220)
	status.Font = Enum.Font.Gotham
	status.TextSize = math.floor(13 * scale)
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = frame

	if not isCarryingOrCarried then
		buildAnimGrid(frame, scale)
	end

	local mainBtn = Instance.new("TextButton")
	mainBtn.Name = "MainAction"
	mainBtn.Size = UDim2.new(1, -20, 0, math.floor(36 * scale))
	mainBtn.Position = UDim2.new(0, 10, 1, -math.floor(46 * scale))
	mainBtn.BackgroundColor3 = isCarryingOrCarried and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(0, 170, 255)
	mainBtn.BorderSizePixel = 0
	mainBtn.Text = isCarryingOrCarried and "Stop Carry" or "Carry"
	mainBtn.TextColor3 = Color3.fromRGB(255,255,255)
	mainBtn.Font = Enum.Font.GothamBold
	mainBtn.TextSize = math.floor(14 * scale)
	mainBtn.Parent = frame
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = mainBtn

	if isCarryingOrCarried then
		-- Debounced stop carry button
		mainBtn.MouseButton1Click:Connect(function()
			if checkClientDebounce("buttonClick") then
				EvStopCarry:FireServer()
			end
		end)
	else
		mainBtn.Active = (selectedTargetName ~= nil)
		mainBtn.AutoButtonColor = mainBtn.Active
		mainBtn.BackgroundColor3 = mainBtn.Active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(70, 70, 70)

		-- Debounced carry button
		mainBtn.MouseButton1Click:Connect(function()
			if not selectedTargetName then return end
			if checkClientDebounce("buttonClick") then
				EvCarryRequest:FireServer(selectedTargetName, selectedAnimKey)
			end
		end)
	end
end

local function pickFromRay()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local mousePos = UserInputService:GetMouseLocation()
	local unitRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	if player.Character then
		params.FilterDescendantsInstances = { player.Character }
	end
	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, params)
	if not result then return end
	local hit = result.Instance
	if not hit then return end
	local model = hit:FindFirstAncestorOfClass("Model")
	if not model then return end
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local plr = Players:GetPlayerFromCharacter(model)
	if not plr or plr == player then return end
	return plr
end

-- Debounced player selection
local function selectPlayer(picked)
	if checkClientDebounce("playerSelection") then
		selectedTargetName = picked.Name
		buildUI()
	end
end

-- Select target -> buka menu (sebelum carry)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local picked = pickFromRay()
		if picked then
			selectPlayer(picked)
		end
	end
end)

UserInputService.TouchTap:Connect(function()
	local picked = pickFromRay()
	if picked then
		selectPlayer(picked)
	end
end)

-- Prompt (TARGET: tombol Terima/Tolak berdampingan)
EvCarryPrompt.OnClientEvent:Connect(function(carrierName, animKey)
	local old = PlayerGui:FindFirstChild("CarryConfirm")
	if old then old:Destroy() end

	local g = Instance.new("ScreenGui")
	g.Name = "CarryConfirm"
	g.ResetOnSpawn = false
	g.Parent = PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 260, 0, 120)
	frame.Position = UDim2.new(0.5, -130, 0.6, -60)
	frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.Parent = g
	local cor = Instance.new("UICorner"); cor.CornerRadius = UDim.new(0,8); cor.Parent = frame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -20, 0, 50)
	lbl.Position = UDim2.new(0, 10, 0, 10)
	lbl.BackgroundTransparency = 1
	lbl.Text = "Permintaan carry dari: " .. carrierName
	lbl.TextColor3 = Color3.fromRGB(255,255,255)
	lbl.TextSize = 16
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = frame

	local accept = Instance.new("TextButton")
	accept.Size = UDim2.new(0.5, -15, 0, 34)
	accept.Position = UDim2.new(0, 10, 1, -44)
	accept.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	accept.BorderSizePixel = 0
	accept.Text = "TERIMA"
	accept.TextColor3 = Color3.fromRGB(255,255,255)
	accept.Font = Enum.Font.GothamBold
	accept.TextSize = 14
	accept.Parent = frame
	local ac = Instance.new("UICorner"); ac.CornerRadius = UDim.new(0,6); ac.Parent = accept

	local decline = Instance.new("TextButton")
	decline.Size = UDim2.new(0.5, -15, 0, 34)
	decline.Position = UDim2.new(0.5, 5, 1, -44)
	decline.BackgroundColor3 = Color3.fromRGB(255, 110, 110)
	decline.BorderSizePixel = 0
	decline.Text = "TOLAK"
	decline.TextColor3 = Color3.fromRGB(255,255,255)
	decline.Font = Enum.Font.GothamBold
	decline.TextSize = 14
	decline.Parent = frame
	local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0,6); dc.Parent = decline

	-- Debounced accept/decline buttons
	accept.MouseButton1Click:Connect(function()
		if checkClientDebounce("buttonClick") then
			EvCarryReply:FireServer(true, carrierName)
			g:Destroy()
		end
	end)
	decline.MouseButton1Click:Connect(function()
		if checkClientDebounce("buttonClick") then
			EvCarryReply:FireServer(false, carrierName)
			g:Destroy()
		end
	end)
end)

-- Mulai carry: tampilkan Stop dan putar animasi lokal sesuai peran saya
EvCarryBegin.OnClientEvent:Connect(function(otherName, animKey)
	isCarryingOrCarried = true
	buildUI()

	-- Tentukan peran: jika saya pengirim request (punya selectedTargetName == otherName), saya carrier.
	local iAmCarrier = (selectedTargetName == otherName)
	local cfg = ANIMS[animKey] or ANIMS.GENDONG1
	local animId = iAmCarrier and cfg.carrier or cfg.target

	stopLocalAnim()
	playLocalAnim(animId)
end)

-- Stop: hentikan anim & tutup menu + reset selection
EvCarryEnded.OnClientEvent:Connect(function()
	isCarryingOrCarried = false
	selectedTargetName = nil
	stopLocalAnim()
	destroyUI()
end)

print("✅ Carry System Client loaded - CLEAN & OPTIMIZED!")
print("⏱️ Client Debounce: " .. (CLIENT_DEBOUNCE_TIME * 1000) .. "ms")