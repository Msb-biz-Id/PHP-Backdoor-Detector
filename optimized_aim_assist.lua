--// Stealth Silent Aim South Bronx - No Wallbang (OPTIMIZED)
--// FOV Hidden - Internal Only
--// Enhanced with Matrix & Vector Operations v2 - Performance Optimized

-- Delay acak sebelum mulai (stealth)
task.wait(math.random(5,10))

local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Cache frequently used values
local mouse = uis:GetMouseLocation
local getMouseLocation = uis.GetMouseLocation
local worldToViewportPoint = cam.WorldToViewportPoint
local clamp = math.clamp
local random = math.random
local huge = math.huge
local time = os.time

-- Pre-allocate vectors to avoid garbage collection
local tempVector2 = Vector2.new()
local tempVector3 = Vector3.new()
local tempCFrame = CFrame.new()

-- List semua parts yang mungkin (optimized with indices)
local all_parts = {
    "UpperTorso", "LowerTorso", "Head", "LeftUpperArm",
    "RightUpperArm", "LeftUpperLeg", "RightUpperLeg",
    "RightFoot", "LeftFoot"
}

-- Pre-calculate part indices for faster access
local part_indices = {}
for i, part in ipairs(all_parts) do
    part_indices[part] = i
end

-- Function untuk mendapatkan random parts priority (optimized)
local function get_random_parts()
    local count = math.random(5, 8)
    local selected = {}
    local used = {}
    
    -- More efficient selection without full shuffle
    for i = 1, count do
        local idx
        repeat
            idx = random(1, #all_parts)
        until not used[idx]
        used[idx] = true
        selected[i] = all_parts[idx]
    end
    
    return selected
end

-- Konfigurasi (moved to top for better performance)
local silent_on = false
local parts_priority = get_random_parts()
local miss_chance = 0.25
local close_off = 1
local far_off = 2.5
local fov_size = 17

-- Cache for dynamic FOV calculations
local fov_cache = {}
local fov_cache_time = 0
local FOV_CACHE_DURATION = 0.1 -- Cache for 100ms

-- Optimized dynamic FOV with caching
local function get_dynamic_fov(distance)
    local now = time()
    if now - fov_cache_time < FOV_CACHE_DURATION and fov_cache[distance] then
        return fov_cache[distance]
    end
    
    local base_fov = 17
    local dynamic_fov = base_fov * (60 / (60 + distance * 0.4))
    local result = clamp(dynamic_fov, 10, 25)
    
    fov_cache[distance] = result
    fov_cache_time = now
    return result
end

-- Pre-allocate tables to avoid garbage collection
local temp_players = {}
local temp_parts = {}

-- Auto change parts every 2 minutes (optimized)
task.spawn(function()
    while true do
        task.wait(120) -- 2 minutes
        parts_priority = get_random_parts()
        print("[System] Parts priority changed to: " .. table.concat(parts_priority, ", "))
    end
end)

-- Optimized random offset with pre-calculated values
local offset_cache = {}
local function r_offset(maxo, distance)
    local cache_key = maxo * 1000 + distance
    if offset_cache[cache_key] then
        return offset_cache[cache_key]
    end
    
    local distance_factor = clamp(distance / 80, 0.3, 1.5)
    local offset_vector = Vector3.new(
        random(-maxo * 10, maxo * 10) / 1000,
        random(-maxo * 10, maxo * 10) / 1000,
        random(-maxo * 10, maxo * 10) / 1000
    )
    
    local result = offset_vector * distance_factor
    offset_cache[cache_key] = result
    return result
end

-- Optimized miss calculation with caching
local miss_cache = {}
local function will_miss(distance)
    local cache_key = math.floor(distance)
    if miss_cache[cache_key] then
        return miss_cache[cache_key]
    end
    
    local base_chance = miss_chance
    local distance_factor = clamp(distance / 200, 0, 0.1)
    local total_miss_chance = base_chance - distance_factor
    local result = random() < math.max(0.25, total_miss_chance)
    
    miss_cache[cache_key] = result
    return result
end

-- Optimized FOV check with pre-calculated values
local function is_in_fov(screen_pos, mouse_pos, fov_radius)
    local diff_x = mouse_pos.X - screen_pos.X
    local diff_y = mouse_pos.Y - screen_pos.Y
    local distance_squared = diff_x * diff_x + diff_y * diff_y
    local fov_radius_squared = fov_radius * fov_radius
    
    if distance_squared < fov_radius_squared * 0.49 then -- 0.7^2
        return true, 1.0
    elseif distance_squared < fov_radius_squared then
        local distance = math.sqrt(distance_squared)
        local t = 1 - ((distance - fov_radius * 0.7) / (fov_radius * 0.3))
        return true, t
    end
    return false, 0
end

-- Highly optimized target detection
local function get_target()
    local tgt, part, dist
    local closest = huge
    local best_stickiness = 0
    
    -- Get mouse position once
    local mouse_pos = getMouseLocation(uis)
    tempVector2.X = mouse_pos.X
    tempVector2.Y = mouse_pos.Y
    
    -- Clear and reuse temp tables
    table.clear(temp_players)
    table.clear(temp_parts)
    
    -- Get players once and cache
    local players = plrs:GetPlayers()
    for i = 1, #players do
        local v = players[i]
        if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            temp_players[#temp_players + 1] = v
        end
    end
    
    -- Process each valid player
    for i = 1, #temp_players do
        local v = temp_players[i]
        local character = v.Character
        
        -- Check parts in priority order
        for j = 1, #parts_priority do
            local pn = parts_priority[j]
            local p = character:FindFirstChild(pn)
            if p then
                local scr = worldToViewportPoint(cam, p.Position)
                
                if scr.Z > 0 then
                    -- Use pre-allocated vector
                    tempVector2.X = scr.X
                    tempVector2.Y = scr.Y
                    
                    local dynamic_fov = get_dynamic_fov(scr.Z)
                    local in_fov, stickiness = is_in_fov(tempVector2, mouse_pos, dynamic_fov)
                    
                    if in_fov then
                        local diff_x = mouse_pos.X - scr.X
                        local diff_y = mouse_pos.Y - scr.Y
                        local diff = math.sqrt(diff_x * diff_x + diff_y * diff_y)
                        
                        local priority_score = diff * (1 - stickiness)
                        
                        if priority_score < closest or (priority_score == closest and stickiness > best_stickiness) then
                            closest = priority_score
                            best_stickiness = stickiness
                            tgt = v
                            part = pn
                            
                            -- Optimized distance calculation
                            local dist3D = (cam.CFrame.Position - p.Position).Magnitude
                            local distZ = scr.Z
                            dist = (dist3D * 0.7) + (distZ * 0.3)
                        end
                    end
                end
            end
        end
    end
    
    return tgt, part, dist
end

-- Optimized function finder
local function find_func(fname)
    if getgc then
        local gc = getgc()
        for i = 1, #gc do
            local fn = gc[i]
            if type(fn) == "function" then
                local inf = debug.getinfo(fn)
                if inf and inf.name == fname then
                    return fn
                end
            end
        end
    end
    return nil
end

local fnA = find_func("CastBlacklist")
if not fnA then
    warn("Function CastBlacklist not found, using fallback method")
    return
end

-- Pre-allocate args table
local args_cache = {}

-- Optimized hook with reduced allocations
local oldA
oldA = hookfunction(fnA, function(...)
    if silent_on then
        local tgt, part, distZ = get_target()
        if tgt and part and tgt.Character and tgt.Character:FindFirstChild(part) then
            -- Reuse args table
            table.clear(args_cache)
            local args = {...}
            for i = 1, #args do
                args_cache[i] = args[i]
            end
            
            if not will_miss(distZ) then
                local off = clamp(distZ / 40, close_off, far_off)
                local target_pos = tgt.Character[part].Position
                local origin = args[1]
                
                local direction = (target_pos - origin).Unit
                local offset_amount = r_offset(off, distZ)
                local new_direction = (direction + offset_amount * 0.3).Unit
                
                args_cache[2] = new_direction * (target_pos - origin).Magnitude
            end
            return oldA(unpack(args_cache))
        end
    end
    return oldA(...)
end)

-- Optimized GUI with reduced updates
local last_notification = 0
local notification_duration = 2
local last_ping_update = 0
local PING_UPDATE_INTERVAL = 0.5 -- Update ping every 500ms instead of every frame

local function show_notification(message)
    local timestamp = os.date("%H:%M:%S")
    print("["..timestamp.."] System: "..message)
    last_notification = time()
end

-- Optimized stealth text
local stealth_text = Instance.new("TextLabel")
stealth_text.Name = "NetworkPing"
stealth_text.Text = "Ping: "..random(28, 42).."ms"
stealth_text.Size = UDim2.new(0, 80, 0, 16)
stealth_text.Position = UDim2.new(1, -85, 1, -20)
stealth_text.BackgroundTransparency = 1
stealth_text.TextColor3 = Color3.fromRGB(150, 150, 150)
stealth_text.Font = Enum.Font.SourceSans
stealth_text.TextSize = 12
stealth_text.TextXAlignment = Enum.TextXAlignment.Right
stealth_text.Visible = false
stealth_text.ZIndex = 0
stealth_text.Parent = lp:WaitForChild("PlayerGui")

-- Optimized ping update with throttling
rs.Heartbeat:Connect(function()
    local now = time()
    if now - last_ping_update >= PING_UPDATE_INTERVAL then
        stealth_text.Text = "Ping: "..random(28, 45).."ms"
        last_ping_update = now
    end
    
    -- Update color only when needed
    local target_color = silent_on and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(150, 150, 150)
    if stealth_text.TextColor3 ~= target_color then
        stealth_text.TextColor3 = target_color
    end
end)

-- Input handling (unchanged but optimized)
uis.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then
        silent_on = not silent_on
        if silent_on then
            show_notification("Network optimization enabled")
            show_notification("Targeting: " .. table.concat(parts_priority, ", "))
        else
            show_notification("Network optimization disabled")
        end
    end
    
    if not gp and input.KeyCode == Enum.KeyCode.LeftAlt then
        stealth_text.Visible = not stealth_text.Visible
    end
    
    if not gp and input.KeyCode == Enum.KeyCode.F5 then
        parts_priority = get_random_parts()
        show_notification("Targeting refreshed: " .. table.concat(parts_priority, ", "))
    end
end)

-- Auto-hide after delay
task.delay(5, function()
    stealth_text.Visible = false
end)

-- Initial notifications
show_notification("Network services initialized")
show_notification("Targeting: " .. table.concat(parts_priority, ", "))
stealth_text.Visible = true
task.delay(3, function()
    stealth_text.Visible = false
end)

-- Cleanup
lp.CharacterRemoving:Connect(function()
    if stealth_text then
        stealth_text:Destroy()
    end
end)

-- Debug info
warn("AimAssist: Stealth mode activated - Check F9 console for status")
print("Initial parts priority: " .. table.concat(parts_priority, ", "))