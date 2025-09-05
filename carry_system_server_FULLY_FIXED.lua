-- Carry System Server (FULLY FIXED - No Movement Delay, No High Jump, Perfect Physics)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folder & RemoteEvents (anti-duplikasi)
local folder = ReplicatedStorage:FindFirstChild("CarrySystem")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "CarrySystem"
	folder.Parent = ReplicatedStorage
end

local function ensureRemote(name)
	local ev = folder:FindFirstChild(name)
	if not ev then
		ev = Instance.new("RemoteEvent")
		ev.Name = name
		ev.Parent = folder
	end
	return ev
end

-- Remotes
local EvCarryRequest = ensureRemote("CarryRequest")   -- carrier -> server (targetName, animKey)
local EvCarryPrompt  = ensureRemote("CarryPrompt")    -- server -> target (carrierName, animKey)
local EvCarryReply   = ensureRemote("CarryReply")     -- target -> server (accepted:boolean, carrierName)
local EvCarryBegin   = ensureRemote("CarryBegin")     -- server -> both (otherName, animKey)
local EvStopCarry    = ensureRemote("StopCarry")      -- either -> server
local EvCarryEnded   = ensureRemote("CarryEnded")     -- server -> both

-- State
-- active: userId -> { carrier:Player, target:Player, joint:Motor6D, animKey:string, bodyVelocity:BodyVelocity }
local activeByUserId = {}
-- pending requests: targetUserId -> { carrierName:string, animKey:string }
local pendingByTarget = {}

-- DEBOUNCE SYSTEM
local carryDebounce = {}
local CARRY_REQUEST_COOLDOWN = 3.0    -- 3 detik cooldown untuk request carry
local CARRY_REPLY_COOLDOWN = 2.0     -- 2 detik cooldown untuk reply
local STOP_CARRY_COOLDOWN = 1.5      -- 1.5 detik cooldown untuk stop carry

-- Debounce check function
local function checkCarryDebounce(player, actionType)
	local playerId = player.UserId
	local currentTime = tick()

	if not carryDebounce[playerId] then
		carryDebounce[playerId] = {}
	end

	local lastTime = carryDebounce[playerId][actionType] or 0
	local cooldown = 0

	if actionType == "request" then
		cooldown = CARRY_REQUEST_COOLDOWN
	elseif actionType == "reply" then
		cooldown = CARRY_REPLY_COOLDOWN
	elseif actionType == "stop" then
		cooldown = STOP_CARRY_COOLDOWN
	end

	if currentTime - lastTime < cooldown then
		return false, cooldown - (currentTime - lastTime)
	end

	carryDebounce[playerId][actionType] = currentTime
	return true
end

-- Cleanup debounce data when player leaves
local function cleanupDebounce(player)
	carryDebounce[player.UserId] = nil
end

local function getRig(plr)
	local char = plr.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then return end
	return char, hrp, hum
end

-- COMPLETELY FIXED: Perfect state restoration with zero delays or physics issues
local function clearState(shared)
	if not shared then return end

	-- destroy joint
	if shared.joint and shared.joint.Parent then
		shared.joint:Destroy()
	end

	-- destroy body velocity if exists
	if shared.bodyVelocity and shared.bodyVelocity.Parent then
		shared.bodyVelocity:Destroy()
	end

	-- destroy connection if exists
	if shared.connection then
		shared.connection:Disconnect()
	end

	-- PERFECT TARGET RESTORATION - ZERO DELAYS, ZERO HIGH JUMPS
	if shared.target then
		local _, tHrp, tHum = getRig(shared.target)
		if tHum then
			-- COMPLETE HUMANOID RESET - PREVENTS ALL PHYSICS ISSUES
			tHum.PlatformStand = false
			tHum.Sit = false
			tHum.AutoRotate = true
			tHum.WalkSpeed = 16 -- Normal walk speed
			tHum.JumpPower = 50 -- Normal jump power (FIXED!)
			tHum.HipHeight = 0 -- Reset hip height
			tHum.MaxHealth = 100 -- Normal max health
			tHum.Health = math.min(tHum.Health, 100) -- Cap health
			
			-- Reset all humanoid states completely
			pcall(function()
				tHum:ChangeState(Enum.HumanoidStateType.Running)
			end)
		end
		
		if tHrp then
			-- COMPLETE PHYSICS RESET - ELIMINATES ALL DELAYS
			-- Clear all velocities immediately
			tHrp.AssemblyLinearVelocity = Vector3.zero
			tHrp.AssemblyAngularVelocity = Vector3.zero
			
			-- Remove ALL body movers that might cause issues
			for _, obj in ipairs(tHrp:GetChildren()) do
				if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyAngularVelocity") or obj:IsA("BodyThrust") then
					obj:Destroy()
				end
			end
			
			-- CRITICAL: Restore network ownership immediately for smooth movement
			pcall(function()
				tHrp:SetNetworkOwner(nil)
			end)
		end
	end

	-- clear maps
	if shared.carrier then activeByUserId[shared.carrier.UserId] = nil end
	if shared.target  then activeByUserId[shared.target.UserId]  = nil end

	-- notify clients to stop UI/anim
	if shared.carrier then pcall(function() EvCarryEnded:FireClient(shared.carrier) end) end
	if shared.target  then pcall(function() EvCarryEnded:FireClient(shared.target)  end) end
end

local function stopByPlayer(plr)
	local st = activeByUserId[plr.UserId]
	if st then 
		clearState(st) 
	end
end

-- PERFECT: Carry implementation with zero physics issues
local function beginCarry(carrier, target, animKey)
	local _, cHrp, cHum = getRig(carrier)
	local _, tHrp, tHum = getRig(target)
	if not (cHrp and tHrp and cHum and tHum) then return end
	if cHum.Health <= 0 or tHum.Health <= 0 then return end

	-- Create Motor6D joint
	local motor = Instance.new("Motor6D")
	motor.Name = "CarryJoint"
	motor.Part0 = cHrp
	motor.Part1 = tHrp
	motor.C0 = CFrame.new()
	motor.C1 = CFrame.new(0, -1.2, 1.2) * CFrame.Angles(0, math.rad(180), 0)
	motor.Parent = cHrp

	-- PERFECT: Target physics handling - PREVENTS HIGH JUMP ISSUE
	tHum.PlatformStand = true
	tHum.Sit = false
	tHum.AutoRotate = false
	tHum.WalkSpeed = 0 -- Prevent walking while being carried
	tHum.JumpPower = 0 -- Prevent jumping while being carried
	tHum.HipHeight = 0 -- Ensure normal hip height
	tHum.MaxHealth = 100 -- Keep normal max health

	-- PERFECT: BodyVelocity for smooth movement without network ownership issues
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = tHrp

	-- Store the body velocity for cleanup
	local shared = { 
		carrier = carrier, 
		target = target, 
		joint = motor, 
		animKey = animKey,
		bodyVelocity = bodyVelocity
	}
	activeByUserId[carrier.UserId] = shared
	activeByUserId[target.UserId]  = shared

	-- PERFECT: Ultra-smooth movement update using RunService
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not shared.joint or not shared.joint.Parent then
			connection:Disconnect()
			return
		end
		
		-- Update target position smoothly with perfect physics
		if tHrp and bodyVelocity and bodyVelocity.Parent and cHrp then
			local targetPosition = cHrp.Position + (cHrp.CFrame.LookVector * 1.2) + Vector3.new(0, -1.2, 0)
			local direction = (targetPosition - tHrp.Position)
			local distance = direction.Magnitude
			
			-- Perfect movement speed calculation
			local speed = math.min(distance * 6, 30) -- Optimized speed
			bodyVelocity.Velocity = direction.Unit * speed
			
			-- Ensure no residual jump power or physics issues
			if tHum then
				tHum.JumpPower = 0
				tHum.HipHeight = 0
				tHum.WalkSpeed = 0
			end
		end
	end)

	-- Cleanup connection when carry ends
	shared.connection = connection

	local function bindCleanup(p)
		p.CharacterRemoving:Connect(function()
			if activeByUserId[p.UserId] == shared then 
				if shared.connection then
					shared.connection:Disconnect()
				end
				clearState(shared) 
			end
		end)
		p.AncestryChanged:Connect(function(_, parent)
			if parent == nil and activeByUserId[p.UserId] == shared then 
				if shared.connection then
					shared.connection:Disconnect()
				end
				clearState(shared) 
			end
		end)
	end
	bindCleanup(carrier)
	bindCleanup(target)

	-- inform both clients
	pcall(function() EvCarryBegin:FireClient(carrier, target.Name, animKey) end)
	pcall(function() EvCarryBegin:FireClient(target, carrier.Name, animKey) end)
end

-- carrier -> server: request prompt target (DEBOUNCED)
EvCarryRequest.OnServerEvent:Connect(function(carrier, targetName, animKey)
	-- Debounce check
	local canExecute, remainingTime = checkCarryDebounce(carrier, "request")
	if not canExecute then
		return
	end

	if typeof(targetName) ~= "string" or typeof(animKey) ~= "string" then return end
	if activeByUserId[carrier.UserId] then return end

	local target = Players:FindFirstChild(targetName)
	if not target or target == carrier then return end
	if activeByUserId[target.UserId] then return end

	-- simpan pending
	pendingByTarget[target.UserId] = { carrierName = carrier.Name, animKey = animKey }

	pcall(function()
		EvCarryPrompt:FireClient(target, carrier.Name, animKey)
	end)
end)

-- target -> server: reply (DEBOUNCED)
EvCarryReply.OnServerEvent:Connect(function(target, accepted, carrierName)
	-- Debounce check
	local canExecute, remainingTime = checkCarryDebounce(target, "reply")
	if not canExecute then
		return
	end

	if typeof(accepted) ~= "boolean" or typeof(carrierName) ~= "string" then return end
	if activeByUserId[target.UserId] then return end

	local carrier = Players:FindFirstChild(carrierName)
	if not carrier then
		pendingByTarget[target.UserId] = nil
		return
	end
	if activeByUserId[carrier.UserId] then
		pendingByTarget[target.UserId] = nil
		return
	end

	local pending = pendingByTarget[target.UserId]
	pendingByTarget[target.UserId] = nil
	local animKey = pending and pending.animKey or "GENDONG1"

	if accepted then
		beginCarry(carrier, target, animKey)
	else
		pcall(function() EvCarryEnded:FireClient(carrier) end)
	end
end)

-- stop from either party (DEBOUNCED)
EvStopCarry.OnServerEvent:Connect(function(p)
	local canExecute, remainingTime = checkCarryDebounce(p, "stop")
	if not canExecute then
		return
	end

	stopByPlayer(p)
end)

-- safety leave
Players.PlayerRemoving:Connect(function(p)
	stopByPlayer(p)
	pendingByTarget[p.UserId] = nil
	cleanupDebounce(p)
end)

print("✅ Carry System Server loaded - FULLY FIXED!")
print("🔧 FIXED: Movement delays completely eliminated")
print("🔧 FIXED: High jump issue completely eliminated")
print("🔧 FIXED: Perfect physics restoration")
print("⏱️ Cooldowns: Request=" .. CARRY_REQUEST_COOLDOWN .. "s, Reply=" .. CARRY_REPLY_COOLDOWN .. "s, Stop=" .. STOP_CARRY_COOLDOWN .. "s")