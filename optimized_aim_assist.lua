--// Stealth Silent Aim South Bronx - No Wallbang (OPTIMIZED VERSION)
--// FOV Hidden - Internal Only
--// Enhanced with Matrix & Vector Operations v2 + Performance Optimizations

-- Delay acak sebelum mulai (stealth)
task.wait(math.random(5,10))

local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Performance optimization: Cache frequently used values
local cached_players = {}
local last_player_update = 0
local player_update_interval = 0.5 -- Update player list every 500ms

-- Object pooling for memory efficiency
local vector2_pool = {}
local vector3_pool = {}
local temp_vec2 = Vector2.new()
local temp_vec3 = Vector3.new()

-- Cache for FOV calculations
local fov_cache = {}
local last_fov_update = 0
local fov_update_interval = 1 -- Update FOV cache every second

-- Mouse position caching
local mouse_vec = Vector2.new()
local last_mouse_update = 0
local mouse_update_interval = 1/60 -- 60fps max

-- Frame rate limiting
local last_target_check = 0
local target_check_interval = 1/60 -- 60fps max

-- Pre-built notification templates
local notification_templates = {
    enabled = "Network optimization enabled",
    disabled = "Network optimization disabled",
    targeting = "Targeting: %s",
    refreshed = "Targeting refreshed: %s"
}

-- List semua parts yang mungkin
local all_parts = {
    "UpperTorso", "LowerTorso", "Head", "LeftUpperArm",
    "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm",
    "UpperTorso", "LowerTorso", "LeftUpperLeg", "RightUpperLeg",
    "RightFoot", "UpperTorso", "LowerTorso", "UpperTorso", "LowerTorso",
    "RightFoot", "LeftFoot",
    "UpperTorso", "LowerTorso", "Head", "LeftFoot",
}

-- Object pooling functions
local function get_vector2(x, y)
    local vec = table.remove(vector2_pool) or Vector2.new()
    vec.X = x or 0
    vec.Y = y or 0
    return vec
end

local function return_vector2(vec)
    if vec and #vector2_pool < 50 then -- Limit pool size
        table.insert(vector2_pool, vec)
    end
end

local function get_vector3(x, y, z)
    local vec = table.remove(vector3_pool) or Vector3.new()
    vec.X = x or 0
    vec.Y = y or 0
    vec.Z = z or 0
    return vec
end

local function return_vector3(vec)
    if vec and #vector3_pool < 50 then -- Limit pool size
        table.insert(vector3_pool, vec)
    end
end

-- Pre-generate multiple parts sets for faster cycling
local parts_sets = {}
local current_set_index = 1
local parts_generation_interval = 120 -- 2 minutes

-- Function untuk mendapatkan random parts priority (optimized)
local function generate_parts_sets()
    for i = 1, 10 do -- Generate 10 sets
        local count = math.random(5, 8)
        local shuffled = {}
        
        -- Copy all parts
        for j, part in ipairs(all_parts) do
            shuffled[j] = part
        end
        
        -- Fisher-Yates shuffle with optimized random
        local indices = {}
        for j = 1, #shuffled do 
            indices[j] = j 
        end
        
        for j = #shuffled, 2, -1 do
            local k = math.random(1, j)
            indices[j], indices[k] = indices[k], indices[j]
        end
        
        -- Select parts
        local selected = {}
        for j = 1, count do
            table.insert(selected, shuffled[indices[j]])
        end
        
        parts_sets[i] = selected
    end
end

-- Get next parts set (much faster than regenerating)
local function get_next_parts_set()
    current_set_index = (current_set_index % #parts_sets) + 1
    return parts_sets[current_set_index]
end

-- Initialize parts sets
generate_parts_sets()

-- Konfigurasi
local silent_on = false
local parts_priority = parts_sets[1] -- Use first generated set
local miss_chance = 0.25
local close_off = 1
local far_off = 2.5
local fov_size = 17

-- Pre-calculate FOV values for common distances
local function precalculate_fov()
    for distance = 10, 200, 5 do
        local base_fov = 17
        local dynamic_fov = base_fov * (60 / (60 + distance * 0.4))
        fov_cache[distance] = math.clamp(dynamic_fov, 10, 25)
    end
end

-- Initialize FOV cache
precalculate_fov()

-- Get cached FOV value
local function get_cached_fov(distance)
    local rounded_dist = math.floor(distance / 5) * 5
    return fov_cache[rounded_dist] or fov_cache[200] -- Fallback to max distance
end

-- Update mouse position cache
local function update_mouse_cache()
    local current_time = tick()
    if current_time - last_mouse_update > mouse_update_interval then
        local mouse = uis:GetMouseLocation()
        mouse_vec.X = mouse.X
        mouse_vec.Y = mouse.Y
        last_mouse_update = current_time
    end
end

-- Update player cache
local function update_player_cache()
    local current_time = tick()
    if current_time - last_player_update > player_update_interval then
        cached_players = {}
        for _, v in ipairs(plrs:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                table.insert(cached_players, v)
            end
        end
        last_player_update = current_time
    end
end

-- Matrix transformation untuk random offset yang proportional dengan jarak (optimized)
local function r_offset(maxo, distance)
    local distance_factor = math.clamp(distance / 80, 0.3, 1.5)
    
    -- Reuse vector3 from pool
    local offset_vector = get_vector3(
        math.random(-maxo * 10, maxo * 10) / 1000,
        math.random(-maxo * 10, maxo * 10) / 1000,
        math.random(-maxo * 10, maxo * 10) / 1000
    )
    
    -- Apply distance factor
    offset_vector = offset_vector * distance_factor
    return offset_vector
end

-- Random miss yang lebih jarang dengan probability yang lebih realistis
local function will_miss(distance)
    local base_chance = miss_chance
    local distance_factor = math.clamp(distance / 200, 0, 0.1)
    local total_miss_chance = base_chance - distance_factor
    return math.random() < math.max(0.25, total_miss_chance)
end

-- Optimized FOV check with stickiness
local function is_in_fov(screen_pos, mouse_pos, fov_radius)
    local diff_x = mouse_pos.X - screen_pos.X
    local diff_y = mouse_pos.Y - screen_pos.Y
    local distance = math.sqrt(diff_x * diff_x + diff_y * diff_y)
    
    if distance < fov_radius * 0.7 then
        return true, 1.0
    elseif distance < fov_radius then
        local t = 1 - ((distance - fov_radius * 0.7) / (fov_radius * 0.3))
        return true, t
    end
    return false, 0
end

-- Highly optimized target detection
local function get_target()
    local current_time = tick()
    if current_time - last_target_check < target_check_interval then
        return nil, nil, nil -- Skip this frame for performance
    end
    last_target_check = current_time
    
    -- Update caches
    update_mouse_cache()
    update_player_cache()
    
    local tgt, part, dist
    local closest = math.huge
    local best_stickiness = 0
    
    -- Use cached players instead of plrs:GetPlayers()
    for _, v in ipairs(cached_players) do
        if v.Character then
            for _, pn in ipairs(parts_priority) do
                local p = v.Character:FindFirstChild(pn)
                if p then
                    local scr = cam:WorldToViewportPoint(p.Position)
                    
                    if scr.Z > 0 then
                        -- Use cached FOV
                        local dynamic_fov = get_cached_fov(scr.Z)
                        
                        -- Reuse vector2 from pool
                        local scr_vec = get_vector2(scr.X, scr.Y)
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
                        
                        -- Return vector to pool
                        return_vector2(scr_vec)
                    end
                end
            end
        end
    end
    
    return tgt, part, dist
end

-- Optimized function finder with caching
local function find_func(fname)
    if getgc then
        for _, fn in ipairs(getgc()) do
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

-- Optimized hook with reduced calculations
local oldA
oldA = hookfunction(fnA, function(...)
    if silent_on then
        local tgt, part, distZ = get_target()
        if tgt and part and tgt.Character and tgt.Character:FindFirstChild(part) then
            local args = {...}
            
            if not will_miss(distZ) then
                local off = math.clamp(distZ / 40, close_off, far_off)
                
                local target_pos = tgt.Character[part].Position
                local origin = args[1]
                
                local direction = (target_pos - origin).Unit
                local offset_amount = r_offset(off, distZ)
                local new_direction = (direction + offset_amount * 0.3).Unit
                
                args[2] = new_direction * (target_pos - origin).Magnitude
                
                -- Return offset vector to pool
                return_vector3(offset_amount)
            end
            return oldA(unpack(args))
        end
    end
    return oldA(...)
end)

-- Optimized GUI with reduced updates
local last_notification = 0
local notification_duration = 2

-- Optimized notification system
local function show_notification(template, ...)
    local current_time = os.time()
    if current_time - last_notification > notification_duration then
        local message = string.format(notification_templates[template] or template, ...)
        local timestamp = os.date("%H:%M:%S")
        print("["..timestamp.."] System: "..message)
        last_notification = current_time
    end
end

-- Stealth indicator with reduced updates
local stealth_text = Instance.new("TextLabel")
stealth_text.Name = "NetworkPing"
stealth_text.Text = "Ping: "..math.random(28, 42).."ms"
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

-- Optimized heartbeat with frame limiting
local last_ping_update = 0
local ping_update_interval = 0.1 -- Update ping every 100ms instead of every frame

rs.Heartbeat:Connect(function()
    local current_time = tick()
    if current_time - last_ping_update > ping_update_interval then
        stealth_text.Text = "Ping: "..math.random(28, 45).."ms"
        
        if silent_on then
            stealth_text.TextColor3 = Color3.fromRGB(100, 200, 100)
        else
            stealth_text.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        
        last_ping_update = current_time
    end
end)

-- Auto change parts with optimized cycling
task.spawn(function()
    while true do
        task.wait(parts_generation_interval)
        parts_priority = get_next_parts_set()
        show_notification("targeting", table.concat(parts_priority, ", "))
    end
end)

-- Optimized input handling
uis.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then
        silent_on = not silent_on
        if silent_on then
            show_notification("enabled")
            show_notification("targeting", table.concat(parts_priority, ", "))
        else
            show_notification("disabled")
        end
    end
    
    if not gp and input.KeyCode == Enum.KeyCode.LeftAlt then
        stealth_text.Visible = not stealth_text.Visible
    end
    
    if not gp and input.KeyCode == Enum.KeyCode.F5 then
        parts_priority = get_next_parts_set()
        show_notification("refreshed", table.concat(parts_priority, ", "))
    end
end)

-- Auto-hide with optimized timing
task.delay(5, function()
    stealth_text.Visible = false
end)

-- Initial notifications
show_notification("enabled")
show_notification("targeting", table.concat(parts_priority, ", "))
stealth_text.Visible = true
task.delay(3, function()
    stealth_text.Visible = false
end)

-- Cleanup with memory management
lp.CharacterRemoving:Connect(function()
    if stealth_text then
        stealth_text:Destroy()
    end
    
    -- Clear object pools
    vector2_pool = {}
    vector3_pool = {}
end)

-- Debug info
warn("AimAssist: Stealth mode activated (OPTIMIZED) - Check F9 console for status")
print("Initial parts priority: " .. table.concat(parts_priority, ", "))
print("Performance optimizations: Object pooling, caching, frame limiting enabled")