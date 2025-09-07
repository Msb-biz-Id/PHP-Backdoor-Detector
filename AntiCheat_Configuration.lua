--// Anti-Cheat Configuration File
--// Customize detection settings here
--// Place this in ServerScriptService

local AntiCheatConfig = {}

-- Detection Settings
AntiCheatConfig.MAX_SPEED = 50                    -- Maximum allowed speed (studs/second)
AntiCheatConfig.MAX_JUMP_POWER = 100              -- Maximum jump power
AntiCheatConfig.MAX_HEALTH = 200                  -- Maximum health
AntiCheatConfig.MAX_WALKSPEED = 30                -- Maximum walkspeed
AntiCheatConfig.FLY_DETECTION_HEIGHT = 20         -- Height threshold for fly detection
AntiCheatConfig.TELEPORT_DISTANCE = 100           -- Maximum teleport distance
AntiCheatConfig.NOCLIP_DETECTION = true           -- Enable noclip detection

-- Timing Settings
AntiCheatConfig.CHECK_INTERVAL = 0.1              -- How often to check (seconds)
AntiCheatConfig.VIOLATION_COOLDOWN = 5            -- Cooldown between violations
AntiCheatConfig.KICK_DELAY = 2                    -- Delay before kicking

-- Violation Limits
AntiCheatConfig.MAX_VIOLATIONS = 3                -- Max violations before kick
AntiCheatConfig.VIOLATION_RESET_TIME = 60         -- Time to reset violations (seconds)

-- Logging Settings
AntiCheatConfig.LOG_VIOLATIONS = true             -- Log violations to console
AntiCheatConfig.LOG_TO_DISCORD = false            -- Log to Discord webhook
AntiCheatConfig.DISCORD_WEBHOOK = ""              -- Discord webhook URL

-- Whitelist Settings
AntiCheatConfig.ENABLE_WHITELIST = true           -- Enable whitelist system
AntiCheatConfig.WHITELIST_IDS = {                 -- Whitelisted user IDs
    -- Add trusted user IDs here
    -- Example: 123456789, 987654321
}

-- Auto Ban System
AntiCheatConfig.ENABLE_AUTO_BAN = false           -- Enable automatic banning
AntiCheatConfig.BAN_DURATION = 24                 -- Ban duration in hours
AntiCheatConfig.BAN_REASON = "Cheating detected by Anti-Cheat System"

-- Advanced Settings
AntiCheatConfig.ENABLE_ADMIN_COMMANDS = true      -- Enable admin commands
AntiCheatConfig.ENABLE_VIOLATION_RESET = true     -- Enable violation reset
AntiCheatConfig.ENABLE_DATA_STORAGE = true        -- Enable DataStore for bans
AntiCheatConfig.ENABLE_MESSAGING_SERVICE = false  -- Enable cross-server messaging

-- Detection Sensitivity (0.1 = Very Sensitive, 1.0 = Normal, 2.0 = Less Sensitive)
AntiCheatConfig.SPEED_SENSITIVITY = 1.0           -- Speed hack detection sensitivity
AntiCheatConfig.FLY_SENSITIVITY = 1.0             -- Fly hack detection sensitivity
AntiCheatConfig.TELEPORT_SENSITIVITY = 1.0        -- Teleport detection sensitivity
AntiCheatConfig.NOCLIP_SENSITIVITY = 1.0          -- Noclip detection sensitivity

-- Custom Detection Rules
AntiCheatConfig.CUSTOM_RULES = {
    -- Add custom detection rules here
    -- Example: Check for specific tools, scripts, etc.
}

-- Notification Settings
AntiCheatConfig.NOTIFY_ADMINS = true              -- Notify admins of violations
AntiCheatConfig.NOTIFY_PLAYERS = false            -- Notify players of violations
AntiCheatConfig.NOTIFICATION_DURATION = 5         -- Notification duration (seconds)

-- Performance Settings
AntiCheatConfig.MAX_PLAYERS_PER_CHECK = 50        -- Max players to check per cycle
AntiCheatConfig.ENABLE_PERFORMANCE_MODE = false   -- Enable performance mode (less accurate)
AntiCheatConfig.CHECK_INTERVAL_PERFORMANCE = 0.5  -- Check interval in performance mode

-- Debug Settings
AntiCheatConfig.ENABLE_DEBUG = false              -- Enable debug mode
AntiCheatConfig.DEBUG_LEVEL = 1                   -- Debug level (1-3)
AntiCheatConfig.LOG_DETECTION_DETAILS = false     -- Log detailed detection info

return AntiCheatConfig