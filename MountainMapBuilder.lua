--// MOUNTAIN PEAK CHALLENGE MAP BUILDER
--// Realistic Mountain Map with 20 Checkpoints
--// Difficulty: EXTREME
--// Features: Weather, Lighting, Terrain, Checkpoints, Realistic Environment

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local MOUNTAIN_CONFIG = {
    HEIGHT = 500, -- Base height of mountain
    WIDTH = 200,  -- Base width
    CHECKPOINTS = 20,
    DIFFICULTY = "EXTREME",
    WEATHER_ENABLED = true,
    LIGHTING_ENABLED = true,
    SOUND_ENABLED = true
}

-- Color schemes for different altitudes
local ALTITUDE_COLORS = {
    {altitude = 0, color = Color3.fromRGB(34, 139, 34)},    -- Forest Green
    {altitude = 100, color = Color3.fromRGB(107, 142, 35)}, -- Olive Green
    {altitude = 200, color = Color3.fromRGB(160, 82, 45)},  -- Saddle Brown
    {altitude = 300, color = Color3.fromRGB(139, 69, 19)},  -- Saddle Brown Dark
    {altitude = 400, color = Color3.fromRGB(105, 105, 105)}, -- Dim Gray
    {altitude = 500, color = Color3.fromRGB(255, 255, 255)} -- Snow White
}

-- Checkpoint data with realistic positions
local CHECKPOINT_DATA = {
    {name = "Base Camp", position = Vector3.new(0, 10, 0), difficulty = 1, description = "Starting point"},
    {name = "Forest Trail", position = Vector3.new(50, 25, 30), difficulty = 2, description = "Dense forest path"},
    {name = "Rocky Outcrop", position = Vector3.new(80, 45, 60), difficulty = 3, description = "First major climb"},
    {name = "Waterfall Base", position = Vector3.new(120, 35, 90), difficulty = 3, description = "Crystal clear mountain stream"},
    {name = "Eagle's Nest", position = Vector3.new(150, 80, 120), difficulty = 4, description = "Spectacular cliff view"},
    {name = "Pine Ridge", position = Vector3.new(180, 110, 150), difficulty = 4, description = "Alpine forest zone"},
    {name = "Stone Bridge", position = Vector3.new(200, 90, 180), difficulty = 5, description = "Ancient rock formation"},
    {name = "Windy Pass", position = Vector3.new(220, 130, 200), difficulty = 5, description = "Exposed ridge crossing"},
    {name = "Crystal Cave", position = Vector3.new(250, 100, 220), difficulty = 6, description = "Hidden ice cave"},
    {name = "Alpine Meadow", position = Vector3.new(280, 140, 250), difficulty = 6, description = "High altitude grassland"},
    {name = "Thunder Peak", position = Vector3.new(300, 180, 280), difficulty = 7, description = "Lightning-prone summit"},
    {name = "Frozen Lake", position = Vector3.new(320, 160, 300), difficulty = 7, description = "Glacial meltwater"},
    {name = "Avalanche Zone", position = Vector3.new(350, 200, 320), difficulty = 8, description = "Dangerous snow slope"},
    {name = "Ice Wall", position = Vector3.new(380, 240, 350), difficulty = 8, description = "Vertical ice climbing"},
    {name = "Storm Ridge", position = Vector3.new(400, 280, 380), difficulty = 9, description = "Extreme weather exposure"},
    {name = "Crystal Summit", position = Vector3.new(420, 320, 400), difficulty = 9, description = "Rare mineral deposits"},
    {name = "Death Drop", position = Vector3.new(450, 360, 420), difficulty = 10, description = "Sheer cliff face"},
    {name = "Frozen Falls", position = Vector3.new(480, 340, 450), difficulty = 10, description = "Frozen waterfall climb"},
    {name = "Storm's Eye", position = Vector3.new(500, 400, 480), difficulty = 11, description = "Eye of the storm"},
    {name = "PEAK CONQUEST", position = Vector3.new(520, 450, 500), difficulty = 12, description = "ULTIMATE CHALLENGE - MOUNTAIN PEAK"}
}

-- Terrain generation function
local function generateMountainTerrain()
    local terrain = workspace.Terrain
    local region = Region3.new(
        Vector3.new(-300, -20, -300),
        Vector3.new(800, 500, 800)
    )
    
    -- Clear existing terrain
    terrain:FillRegion(region, 4, Enum.Material.Air)
    
    -- Generate base mountain shape using noise
    local size = Vector3.new(1100, 520, 1100)
    local resolution = 4
    local seed = math.random(1, 1000000)
    
    -- Create mountain base
    for x = -300, 800, resolution do
        for z = -300, 800, resolution do
            local distance = math.sqrt(x*x + z*z)
            local height = math.max(0, MOUNTAIN_CONFIG.HEIGHT - distance * 0.3)
            
            -- Add noise for realistic terrain
            local noise = math.noise(x * 0.01, z * 0.01, seed) * 50
            height = height + noise
            
            -- Create terrain column
            local region = Region3.new(
                Vector3.new(x, 0, z),
                Vector3.new(x + resolution, height, z + resolution)
            )
            
            -- Determine material based on height
            local material = Enum.Material.Grass
            if height > 400 then
                material = Enum.Material.Snow
            elseif height > 300 then
                material = Enum.Material.Rock
            elseif height > 200 then
                material = Enum.Material.Ground
            end
            
            terrain:FillRegion(region, 4, material)
        end
    end
    
    print("✓ Mountain terrain generated")
end

-- Create realistic vegetation
local function createVegetation()
    local vegetationFolder = Instance.new("Folder")
    vegetationFolder.Name = "Vegetation"
    vegetationFolder.Parent = workspace
    
    -- Tree types for different altitudes
    local treeTypes = {
        {name = "Pine", model = "rbxassetid://131961136", minHeight = 0, maxHeight = 200},
        {name = "Oak", model = "rbxassetid://131961136", minHeight = 0, maxHeight = 150},
        {name = "Alpine", model = "rbxassetid://131961136", minHeight = 150, maxHeight = 350},
        {name = "Dead", model = "rbxassetid://131961136", minHeight = 300, maxHeight = 500}
    }
    
    -- Generate trees
    for i = 1, 200 do
        local x = math.random(-200, 600)
        local z = math.random(-200, 600)
        local distance = math.sqrt(x*x + z*z)
        local height = math.max(0, MOUNTAIN_CONFIG.HEIGHT - distance * 0.3)
        
        if height > 10 and height < 400 then
            local treeType = treeTypes[math.random(1, #treeTypes)]
            if height >= treeType.minHeight and height <= treeType.maxHeight then
                local tree = Instance.new("Model")
                tree.Name = treeType.name .. "Tree_" .. i
                tree.Parent = vegetationFolder
                
                local trunk = Instance.new("Part")
                trunk.Name = "Trunk"
                trunk.Size = Vector3.new(2, math.random(8, 15), 2)
                trunk.Position = Vector3.new(x, height + trunk.Size.Y/2, z)
                trunk.Material = Enum.Material.Wood
                trunk.BrickColor = BrickColor.new("Brown")
                trunk.Anchored = true
                trunk.Parent = tree
                
                local leaves = Instance.new("Part")
                leaves.Name = "Leaves"
                leaves.Size = Vector3.new(math.random(6, 12), math.random(6, 12), math.random(6, 12))
                leaves.Position = Vector3.new(x, height + trunk.Size.Y + leaves.Size.Y/2, z)
                leaves.Material = Enum.Material.Grass
                leaves.BrickColor = BrickColor.new("Bright green")
                leaves.Anchored = true
                leaves.Shape = Enum.PartType.Ball
                leaves.Parent = tree
            end
        end
    end
    
    print("✓ Vegetation created")
end

-- Create rocks and boulders
local function createRocks()
    local rocksFolder = Instance.new("Folder")
    rocksFolder.Name = "Rocks"
    rocksFolder.Parent = workspace
    
    for i = 1, 150 do
        local x = math.random(-250, 650)
        local z = math.random(-250, 650)
        local distance = math.sqrt(x*x + z*z)
        local height = math.max(0, MOUNTAIN_CONFIG.HEIGHT - distance * 0.3)
        
        if height > 5 then
            local rock = Instance.new("Part")
            rock.Name = "Rock_" .. i
            rock.Size = Vector3.new(
                math.random(3, 8),
                math.random(2, 6),
                math.random(3, 8)
            )
            rock.Position = Vector3.new(x, height + rock.Size.Y/2, z)
            rock.Material = Enum.Material.Rock
            rock.BrickColor = BrickColor.new("Dark stone grey")
            rock.Anchored = true
            rock.Shape = Enum.PartType.Ball
            rock.Parent = rocksFolder
        end
    end
    
    print("✓ Rocks and boulders placed")
end

-- Create checkpoints
local function createCheckpoints()
    local checkpointsFolder = Instance.new("Folder")
    checkpointsFolder.Name = "Checkpoints"
    checkpointsFolder.Parent = workspace
    
    for i, data in ipairs(CHECKPOINT_DATA) do
        local checkpoint = Instance.new("Model")
        checkpoint.Name = "Checkpoint_" .. i .. "_" .. data.name
        checkpoint.Parent = checkpointsFolder
        
        -- Checkpoint base
        local base = Instance.new("Part")
        base.Name = "Base"
        base.Size = Vector3.new(8, 1, 8)
        base.Position = data.position
        base.Material = Enum.Material.Neon
        base.BrickColor = BrickColor.new("Bright blue")
        base.Anchored = true
        base.CanCollide = false
        base.Parent = checkpoint
        
        -- Checkpoint pole
        local pole = Instance.new("Part")
        pole.Name = "Pole"
        pole.Size = Vector3.new(1, 6, 1)
        pole.Position = data.position + Vector3.new(0, 3.5, 0)
        pole.Material = Enum.Material.Neon
        pole.BrickColor = BrickColor.new("Bright blue")
        pole.Anchored = true
        pole.CanCollide = false
        pole.Parent = checkpoint
        
        -- Checkpoint number
        local number = Instance.new("Part")
        number.Name = "Number"
        number.Size = Vector3.new(2, 2, 0.2)
        number.Position = data.position + Vector3.new(0, 5, 0)
        number.Material = Enum.Material.Neon
        number.BrickColor = BrickColor.new("Bright yellow")
        number.Anchored = true
        number.CanCollide = false
        number.Parent = checkpoint
        
        -- Number text
        local numberGui = Instance.new("SurfaceGui")
        numberGui.Face = Enum.NormalId.Front
        numberGui.Parent = number
        
        local numberLabel = Instance.new("TextLabel")
        numberLabel.Size = UDim2.new(1, 0, 1, 0)
        numberLabel.BackgroundTransparency = 1
        numberLabel.Text = tostring(i)
        numberLabel.TextColor3 = Color3.new(0, 0, 0)
        numberLabel.TextScaled = true
        numberLabel.Font = Enum.Font.SourceSansBold
        numberLabel.Parent = numberGui
        
        -- Checkpoint info
        local info = Instance.new("Part")
        info.Name = "Info"
        info.Size = Vector3.new(6, 1, 0.2)
        info.Position = data.position + Vector3.new(0, 1, 0)
        info.Material = Enum.Material.Neon
        info.BrickColor = BrickColor.new("Bright green")
        info.Anchored = true
        info.CanCollide = false
        info.Parent = checkpoint
        
        -- Info text
        local infoGui = Instance.new("SurfaceGui")
        infoGui.Face = Enum.NormalId.Front
        infoGui.Parent = info
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 1, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = data.name .. " (Diff: " .. data.difficulty .. ")"
        infoLabel.TextColor3 = Color3.new(0, 0, 0)
        infoLabel.TextScaled = true
        infoLabel.Font = Enum.Font.SourceSans
        infoLabel.Parent = infoGui
        
        -- Glowing effect
        local pointLight = Instance.new("PointLight")
        pointLight.Color = Color3.new(0, 0.5, 1)
        pointLight.Brightness = 2
        pointLight.Range = 20
        pointLight.Parent = pole
        
        -- Pulsing animation
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
        local tween = TweenService:Create(pole, tweenInfo, {Size = Vector3.new(1.2, 6.2, 1.2)})
        tween:Play()
    end
    
    print("✓ " .. #CHECKPOINT_DATA .. " checkpoints created")
end

-- Create weather effects
local function createWeather()
    if not MOUNTAIN_CONFIG.WEATHER_ENABLED then return end
    
    local weatherFolder = Instance.new("Folder")
    weatherFolder.Name = "Weather"
    weatherFolder.Parent = workspace
    
    -- Snow particles
    local snow = Instance.new("Part")
    snow.Name = "Snow"
    snow.Size = Vector3.new(1000, 1, 1000)
    snow.Position = Vector3.new(250, 500, 250)
    snow.Material = Enum.Material.Air
    snow.Transparency = 1
    snow.Anchored = true
    snow.CanCollide = false
    snow.Parent = weatherFolder
    
    local snowAttachment = Instance.new("Attachment")
    snowAttachment.Parent = snow
    
    local snowParticles = Instance.new("ParticleEmitter")
    snowParticles.Parent = snowAttachment
    snowParticles.Texture = "rbxasset://textures/particles/snow.png"
    snowParticles.Lifetime = NumberRange.new(10, 15)
    snowParticles.Rate = 100
    snowParticles.SpreadAngle = Vector2.new(45, 45)
    snowParticles.Speed = NumberRange.new(5, 15)
    snowParticles.VelocityInheritance = 0
    snowParticles.Color = ColorSequence.new(Color3.new(1, 1, 1))
    snowParticles.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0.1)
    }
    
    -- Wind effect
    local wind = Instance.new("Part")
    wind.Name = "Wind"
    wind.Size = Vector3.new(1, 1, 1)
    wind.Position = Vector3.new(250, 250, 250)
    wind.Material = Enum.Material.Air
    wind.Transparency = 1
    wind.Anchored = true
    wind.CanCollide = false
    wind.Parent = weatherFolder
    
    local windAttachment = Instance.new("Attachment")
    windAttachment.Parent = wind
    
    local windParticles = Instance.new("ParticleEmitter")
    windParticles.Parent = windAttachment
    windParticles.Texture = "rbxasset://textures/particles/fire_main.dds"
    windParticles.Lifetime = NumberRange.new(2, 4)
    windParticles.Rate = 50
    windParticles.SpreadAngle = Vector2.new(30, 30)
    windParticles.Speed = NumberRange.new(20, 30)
    windParticles.VelocityInheritance = 0
    windParticles.Color = ColorSequence.new(Color3.new(0.8, 0.8, 0.8))
    windParticles.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 0.05)
    }
    
    print("✓ Weather effects created")
end

-- Setup lighting
local function setupLighting()
    if not MOUNTAIN_CONFIG.LIGHTING_ENABLED then return end
    
    -- Atmospheric lighting
    Lighting.Ambient = Color3.new(0.2, 0.3, 0.5)
    Lighting.Brightness = 2
    Lighting.ColorShift_Bottom = Color3.new(0.1, 0.1, 0.2)
    Lighting.ColorShift_Top = Color3.new(0.8, 0.9, 1)
    Lighting.ExposureCompensation = 0.5
    Lighting.FogColor = Color3.new(0.7, 0.8, 0.9)
    Lighting.FogEnd = 1000
    Lighting.FogStart = 200
    Lighting.GeographicLatitude = 45
    Lighting.OutdoorAmbient = Color3.new(0.3, 0.4, 0.6)
    Lighting.ShadowSoftness = 0.2
    Lighting.TimeOfDay = "14:00:00"
    
    -- Sun rays
    local sunRays = Instance.new("SunRaysEffect")
    sunRays.Intensity = 0.1
    sunRays.Spread = 0.2
    sunRays.Parent = Lighting
    
    -- Bloom effect
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.3
    bloom.Size = 24
    bloom.Threshold = 0.9
    bloom.Parent = Lighting
    
    -- Color correction
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Brightness = 0.1
    colorCorrection.Contrast = 0.1
    colorCorrection.Saturation = 0.1
    colorCorrection.TintColor = Color3.new(0.9, 0.95, 1)
    colorCorrection.Parent = Lighting
    
    print("✓ Lighting configured")
end

-- Create sound effects
local function createSounds()
    if not MOUNTAIN_CONFIG.SOUND_ENABLED then return end
    
    local soundFolder = Instance.new("Folder")
    soundFolder.Name = "Sounds"
    soundFolder.Parent = workspace
    
    -- Wind sound
    local windSound = Instance.new("Sound")
    windSound.Name = "Wind"
    windSound.SoundId = "rbxassetid://131961136" -- Replace with actual wind sound
    windSound.Volume = 0.3
    windSound.Looped = true
    windSound.Parent = soundFolder
    windSound:Play()
    
    -- Ambient mountain sounds
    local ambientSound = Instance.new("Sound")
    ambientSound.Name = "Ambient"
    ambientSound.SoundId = "rbxassetid://131961136" -- Replace with actual ambient sound
    ambientSound.Volume = 0.2
    ambientSound.Looped = true
    ambientSound.Parent = soundFolder
    ambientSound:Play()
    
    print("✓ Sound effects created")
end

-- Create spawn points
local function createSpawnPoints()
    local spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "SpawnPoints"
    spawnFolder.Parent = workspace
    
    -- Main spawn at base camp
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "BaseCampSpawn"
    spawn.Position = Vector3.new(0, 15, 0)
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.BrickColor = BrickColor.new("Bright green")
    spawn.Material = Enum.Material.Neon
    spawn.Anchored = true
    spawn.Parent = spawnFolder
    
    -- Checkpoint spawns
    for i, data in ipairs(CHECKPOINT_DATA) do
        if i % 5 == 0 then -- Every 5th checkpoint has a spawn
            local checkpointSpawn = Instance.new("SpawnLocation")
            checkpointSpawn.Name = "CheckpointSpawn_" .. i
            checkpointSpawn.Position = data.position + Vector3.new(0, 5, 0)
            checkpointSpawn.Size = Vector3.new(4, 1, 4)
            checkpointSpawn.BrickColor = BrickColor.new("Bright blue")
            checkpointSpawn.Material = Enum.Material.Neon
            checkpointSpawn.Anchored = true
            checkpointSpawn.Parent = spawnFolder
        end
    end
    
    print("✓ Spawn points created")
end

-- Create leaderboard
local function createLeaderboard()
    local leaderboard = Instance.new("Model")
    leaderboard.Name = "Leaderboard"
    leaderboard.Parent = workspace
    
    local leaderboardPart = Instance.new("Part")
    leaderboardPart.Name = "LeaderboardPart"
    leaderboardPart.Size = Vector3.new(8, 10, 1)
    leaderboardPart.Position = Vector3.new(-50, 5, 0)
    leaderboardPart.Material = Enum.Material.Neon
    leaderboardPart.BrickColor = BrickColor.new("Bright yellow")
    leaderboardPart.Anchored = true
    leaderboardPart.Parent = leaderboard
    
    local leaderboardGui = Instance.new("SurfaceGui")
    leaderboardGui.Face = Enum.NormalId.Front
    leaderboardGui.Parent = leaderboardPart
    
    local leaderboardLabel = Instance.new("TextLabel")
    leaderboardLabel.Size = UDim2.new(1, 0, 1, 0)
    leaderboardLabel.BackgroundTransparency = 1
    leaderboardLabel.Text = "MOUNTAIN PEAK CHALLENGE\n\nCheckpoints: 20\nDifficulty: EXTREME\n\nClimb to the peak!\n\nCheckpoints:\n"
    leaderboardLabel.TextColor3 = Color3.new(0, 0, 0)
    leaderboardLabel.TextScaled = true
    leaderboardLabel.Font = Enum.Font.SourceSansBold
    leaderboardLabel.TextXAlignment = Enum.TextXAlignment.Left
    leaderboardLabel.TextYAlignment = Enum.TextYAlignment.Top
    leaderboardLabel.Parent = leaderboardGui
    
    -- Add checkpoint list
    local checkpointList = ""
    for i, data in ipairs(CHECKPOINT_DATA) do
        checkpointList = checkpointList .. i .. ". " .. data.name .. " (Diff: " .. data.difficulty .. ")\n"
    end
    
    leaderboardLabel.Text = leaderboardLabel.Text .. checkpointList
    
    print("✓ Leaderboard created")
end

-- Main build function
local function buildMountainMap()
    print("🏔️ BUILDING MOUNTAIN PEAK CHALLENGE MAP...")
    print("Difficulty: EXTREME")
    print("Checkpoints: " .. MOUNTAIN_CONFIG.CHECKPOINTS)
    print("")
    
    -- Clear existing map
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name ~= "Camera" and obj.Name ~= "Terrain" then
            obj:Destroy()
        end
    end
    
    -- Build map components
    generateMountainTerrain()
    createVegetation()
    createRocks()
    createCheckpoints()
    createWeather()
    setupLighting()
    createSounds()
    createSpawnPoints()
    createLeaderboard()
    
    print("")
    print("✅ MOUNTAIN PEAK CHALLENGE MAP COMPLETE!")
    print("🏔️ 20 Checkpoints created")
    print("🌲 Realistic environment generated")
    print("❄️ Weather effects active")
    print("💡 Dynamic lighting configured")
    print("🔊 Ambient sounds playing")
    print("")
    print("🎯 CHALLENGE: Reach the peak at checkpoint 20!")
    print("⚠️  WARNING: This is an EXTREME difficulty map!")
end

-- Auto-build on script run
buildMountainMap()

-- Export function for manual building
_G.BuildMountainMap = buildMountainMap

print("🔧 Use _G.BuildMountainMap() to rebuild the map anytime!")