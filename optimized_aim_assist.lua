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

-- Pre-calculate common values
local math_random = math.random
local math_clamp = math.clamp
local math_max = math.max
local Vector2_new = Vector2.new
local Vector3_new = Vector3.new

-- Cache frequently used values
local FOV_BASE = 17
local FOV_MIN = 10
local FOV_MAX = 25
local MISS_CHANCE_BASE = 0.25
local MISS_CHANCE_MIN = 0.25
local CLOSE_OFF = 1
local FAR_OFF = 2.5

-- Pre-allocate tables to avoid garbage collection
local temp_players = {}
local temp_parts = {}
local temp_vector2 = Vector2_new(0, 0)
local temp_vector3 = Vector3_new(0, 0, 0)

-- List semua parts yang mungkin (optimized with indices)
local all_parts = {
    "UpperTorso", "LowerTorso", "Head", "LeftUpperArm",
    "RightUpperArm", "LeftUpperLeg", "RightUpperLeg",
    "RightFoot", "LeftFoot"
}
local all_parts_count = #all_parts

-- Pre-calculate parts indices for faster access
local parts_indices = {}
for i = 1, all_parts_count do
    parts_indices[i] = i
end

-- Function untuk mendapatkan random parts priority (optimized)
local function get_random_parts()
    local count = math_random(5, 8)
    local selected = {}
    
    -- Fisher-Yates shuffle using pre-allocated indices
    for i = all_parts_count, 2, -1 do
        local j = math_random(1, i)
        parts_indices[i], parts_indices[j] = parts_indices[j], parts_indices[i]
    end
    
    -- Select parts using indices
    for i = 1, count do
        selected[i] = all_parts[parts_indices[i]]
    end
    
    return selected
end

-- Konfigurasi
local silent_on = false
local parts_priority = get_random_parts()
local miss_chance = MISS_CHANCE_BASE
local close_off = CLOSE_OFF
local far_off = FAR_OFF
local fov_size = FOV_BASE

-- Cache for dynamic FOV calculations
local fov_cache = {}
local fov_cache_size = 0
local FOV_CACHE_MAX = 100

-- Optimized dynamic FOV with caching
local function get_dynamic_fov(distance)
    local rounded_dist = math.floor(distance)
    
    -- Check cache first
    if fov_cache[rounded_dist] then
        return fov_cache[rounded_dist]
    end
    
    -- Calculate FOV
    local dynamic_fov = FOV_BASE * (60 / (60 + distance * 0.4))
    local result = math_clamp(dynamic_fov, FOV_MIN, FOV_MAX)
    
    -- Cache result (with size limit)
    if fov_cache_size < FOV_CACHE_MAX then
        fov_cache[rounded_dist] = result
        fov_cache_size = fov_cache_size + 1
    end
    
    return result
end

-- Optimized random offset calculation
local function r_offset(maxo, distance)
    local distance_factor = math_clamp(distance / 80, 0.3, 1.5)
    local scale = maxo * 10 / 1000
    
    -- Reuse vector to avoid allocations
    temp_vector3.X = math_random(-scale, scale)
    temp_vector3.Y = math_random(-scale, scale)
    temp_vector3.Z = math_random(-scale, scale)
    
    return temp_vector3 * distance_factor
end

-- Optimized miss calculation with caching
local miss_cache = {}
local function will_miss(distance)
    local rounded_dist = math.floor(distance / 10) * 10 -- Round to nearest 10
    
    if miss_cache[rounded_dist] then
        return miss_cache[rounded_dist]
    end
    
    local distance_factor = math_clamp(distance / 200, 0, 0.1)
    local total_miss_chance = MISS_CHANCE_BASE - distance_factor
    local result = math_random() < math_max(MISS_CHANCE_MIN, total_miss_chance)
    
    miss_cache[rounded_dist] = result
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

-- Optimized target detection with reduced allocations
local function get_target()
    local tgt, part, dist
    local closest = math.huge
    local best_stickiness = 0
    local mouse = uis:GetMouseLocation()
    
    -- Reuse vector to avoid allocations
    temp_vector2.X = mouse.X
    temp_vector2.Y = mouse.Y
    local mouse_vec = temp_vector2
    
    -- Clear and reuse players table
    local players = plrs:GetPlayers()
    local player_count = #players
    
    for i = 1, player_count do
        local v = players[i]
        if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local character = v.Character
            local parts_count = #parts_priority
            
            for j = 1, parts_count do
                local pn = parts_priority[j]
                local p = character:FindFirstChild(pn)
                if p then
                    local scr = cam:WorldToViewportPoint(p.Position)
                    
                    if scr.Z > 0 then
                        -- Reuse vector for screen position
                        temp_vector2.X = scr.X
                        temp_vector2.Y = scr.Y
                        local scr_vec = temp_vector2
                        
                        local dynamic_fov = get_dynamic_fov(scr.Z)
                        local in_fov, stickiness = is_in_fov(scr_vec, mouse_vec, dynamic_fov)
                        
                        if in_fov then
                            local diff_x = mouse_vec.X - scr_vec.X
                            local diff_y = mouse_vec.Y - scr_vec.Y
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
    end
    
    return tgt, part, dist
end

-- Optimized function finder with caching
local function_cache = {}
local function find_func(fname)
    if function_cache[fname] then
        return function_cache[fname]
    end
    
    if getgc then
        for _,fn in ipairs(getgc()) do
            if type(fn) == "function" then
                local inf = debug.getinfo(fn)
                if inf and inf.name == fname then
                    function_cache[fname] = fn
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

-- Optimized hook with reduced calculations
local oldA
oldA = hookfunction(fnA, function(...)
    if silent_on then
        local tgt, part, distZ = get_target()
        if tgt and part and tgt.Character and tgt.Character:FindFirstChild(part) then
            local args = {...}
            
            if not will_miss(distZ) then
                local off = math_clamp(distZ / 40, close_off, far_off)
                
                local target_pos = tgt.Character[part].Position
                local origin = args[1]
                
                -- Optimized direction calculation
                local direction = (target_pos - origin).Unit
                local offset_amount = r_offset(off, distZ)
                
                -- Reuse vector for new direction
                temp_vector3.X = direction.X + offset_amount.X * 0.3
                temp_vector3.Y = direction.Y + offset_amount.Y * 0.3
                temp_vector3.Z = direction.Z + offset_amount.Z * 0.3
                
                local new_direction = temp_vector3.Unit
                args[2] = new_direction * (target_pos - origin).Magnitude
            end
            return oldA(unpack(args))
        end
    end
    return oldA(...)
end)

-- Optimized GUI with reduced updates
local last_notification = 0
local notification_duration = 2
local last_ping_update = 0
local PING_UPDATE_INTERVAL = 0.5 -- Update ping every 0.5 seconds instead of every frame

-- Optimized notification system
local function show_notification(message)
    local timestamp = os.date("%H:%M:%S")
    print("["..timestamp.."] System: "..message)
    last_notification = os.time()
end

-- Optimized stealth indicator
local stealth_text = Instance.new("TextLabel")
stealth_text.Name = "NetworkPing"
stealth_text.Text = "Ping: "..math_random(28, 42).."ms"
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
local current_time = 0
rs.Heartbeat:Connect(function()
    current_time = current_time + rs.Heartbeat:Wait()
    
    -- Only update ping every 0.5 seconds
    if current_time - last_ping_update >= PING_UPDATE_INTERVAL then
        stealth_text.Text = "Ping: "..math_random(28, 45).."ms"
        last_ping_update = current_time
        
        -- Update color based on status
        if silent_on then
            stealth_text.TextColor3 = Color3.fromRGB(100, 200, 100)
        else
            stealth_text.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end)

-- Auto change parts every 2 minutes (optimized)
task.spawn(function()
    while true do
        task.wait(120) -- 2 minutes
        parts_priority = get_random_parts()
        print("[System] Parts priority changed to: " .. table.concat(parts_priority, ", "))
        
        -- Clear caches periodically to prevent memory buildup
        fov_cache = {}
        fov_cache_size = 0
        miss_cache = {}
    end
end)

-- Optimized input handling
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    local key = input.KeyCode
    if key == Enum.KeyCode.RightControl then
        silent_on = not silent_on
        if silent_on then
            show_notification("Network optimization enabled")
            show_notification("Targeting: " .. table.concat(parts_priority, ", "))
        else
            show_notification("Network optimization disabled")
        end
    elseif key == Enum.KeyCode.LeftAlt then
        stealth_text.Visible = not stealth_text.Visible
    elseif key == Enum.KeyCode.F5 then
        parts_priority = get_random_parts()
        show_notification("Targeting refreshed: " .. table.concat(parts_priority, ", "))
    end
end)

-- Auto-hide after 5 seconds
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