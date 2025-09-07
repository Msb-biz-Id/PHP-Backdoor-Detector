# 🛡️ Anti-Cheat Server System - Installation Guide

## 🚨 **Sistem Anti-Cheat Lengkap untuk Roblox**

Sistem ini akan **otomatis mendeteksi dan kick** player yang menggunakan cheat dengan berbagai metode deteksi canggih.

---

## 🎯 **Fitur Deteksi:**

### **1. Speed Hack Detection**
- ✅ Deteksi kecepatan berlebihan
- ✅ Monitoring pergerakan real-time
- ✅ Threshold yang dapat disesuaikan

### **2. Fly Hack Detection**
- ✅ Deteksi terbang tanpa alat
- ✅ Monitoring waktu di udara
- ✅ Pengecekan gravitasi

### **3. Teleport Hack Detection**
- ✅ Deteksi teleportasi jarak jauh
- ✅ Monitoring perpindahan posisi
- ✅ Threshold jarak maksimal

### **4. Noclip Detection**
- ✅ Deteksi melewati dinding
- ✅ Monitoring collision
- ✅ Pengecekan posisi dalam objek

### **5. Stat Hack Detection**
- ✅ Jump Power berlebihan
- ✅ Health berlebihan
- ✅ WalkSpeed berlebihan

### **6. Script Injection Detection**
- ✅ Deteksi script mencurigakan
- ✅ Monitoring LocalScript
- ✅ Pengecekan script tidak sah

### **7. Remote Exploit Detection**
- ✅ Deteksi eksploitasi remote
- ✅ Monitoring aktivitas mencurigakan
- ✅ Pengecekan pattern aneh

### **8. Anti-AFK Detection**
- ✅ Deteksi anti-AFK tools
- ✅ Monitoring pola pergerakan
- ✅ Pengecekan aktivitas otomatis

---

## 📁 **File yang Dibuat:**

### **1. `AntiCheat_Server_System.lua`** - Script Utama
- **Server-side only** (aman dari bypass)
- **Comprehensive detection** system
- **Auto kick & ban** functionality
- **Logging system** lengkap

### **2. `AntiCheat_Configuration.lua`** - File Konfigurasi
- **Customizable settings**
- **Detection thresholds**
- **Whitelist system**
- **Performance tuning**

### **3. `AntiCheat_Installation_Guide.md`** - Panduan Instalasi
- **Step-by-step** installation
- **Configuration guide**
- **Troubleshooting tips**

---

## 🚀 **Cara Instalasi:**

### **Metode 1: Roblox Studio (Recommended)**

#### **Langkah 1: Setup Scripts**
1. **Buka Roblox Studio**
2. **Buat game baru** atau buka game existing
3. **ServerScriptService** → **Insert Object** → **Script**
4. **Rename** menjadi "AntiCheat_Server_System"
5. **Copy-paste** script utama

#### **Langkah 2: Setup Configuration**
1. **ServerScriptService** → **Insert Object** → **ModuleScript**
2. **Rename** menjadi "AntiCheat_Configuration"
3. **Copy-paste** file konfigurasi
4. **Edit settings** sesuai kebutuhan

#### **Langkah 3: Test & Deploy**
1. **Klik Play** untuk test
2. **Check console** untuk log
3. **Publish** ke Roblox

### **Metode 2: Server Script (Advanced)**

#### **Langkah 1: Upload Script**
1. **Buka game** di Roblox Studio
2. **ServerScriptService** → **Insert Object** → **Script**
3. **Paste** script lengkap
4. **Save** dan **Publish**

#### **Langkah 2: Configure Settings**
```lua
-- Edit di bagian ANTI_CHEAT_CONFIG
MAX_SPEED = 50,                    -- Ubah threshold speed
MAX_VIOLATIONS = 3,                -- Ubah max violations
ENABLE_AUTO_BAN = true,            -- Aktifkan auto ban
WHITELIST_IDS = {123456789},       -- Tambah user ID whitelist
```

---

## ⚙️ **Konfigurasi:**

### **Detection Settings:**
```lua
-- Speed Detection
MAX_SPEED = 50,                    -- Max speed (studs/sec)
MAX_JUMP_POWER = 100,              -- Max jump power
MAX_HEALTH = 200,                  -- Max health
MAX_WALKSPEED = 30,                -- Max walkspeed

-- Distance Detection
FLY_DETECTION_HEIGHT = 20,         -- Fly detection height
TELEPORT_DISTANCE = 100,           -- Max teleport distance
```

### **Violation Settings:**
```lua
-- Violation Limits
MAX_VIOLATIONS = 3,                -- Max violations before kick
VIOLATION_COOLDOWN = 5,            -- Cooldown between violations
VIOLATION_RESET_TIME = 60,         -- Time to reset violations
```

### **Whitelist System:**
```lua
-- Whitelist Configuration
ENABLE_WHITELIST = true,           -- Enable whitelist
WHITELIST_IDS = {                  -- Add trusted user IDs
    123456789,                     -- Admin 1
    987654321,                     -- Admin 2
    -- Add more IDs here
}
```

### **Auto Ban System:**
```lua
-- Auto Ban Configuration
ENABLE_AUTO_BAN = true,            -- Enable auto ban
BAN_DURATION = 24,                 -- Ban duration (hours)
BAN_REASON = "Cheating detected"   -- Ban reason
```

---

## 🎮 **Cara Menggunakan:**

### **Admin Commands:**
```
/kick [username] - Kick player
/ban [username] [hours] - Ban player
/violations [username] - Check violations
```

### **Monitoring:**
- **Console Logs** - Check F9 console
- **Violation Tracking** - Real-time monitoring
- **Player Data** - Detailed player info

### **Whitelist Management:**
- **Add User IDs** to whitelist
- **Remove User IDs** from whitelist
- **Check whitelist status**

---

## 📊 **Logging System:**

### **Console Logs:**
```
[AntiCheat] 2024-01-15 14:30:25 - PlayerName (123456): Speed Hack - Speed: 75.5 studs/sec (Max: 50)
[AntiCheat] 2024-01-15 14:30:30 - PlayerName (123456): KICK - Multiple violations detected
```

### **Discord Integration:**
```lua
-- Setup Discord webhook
LOG_TO_DISCORD = true,
DISCORD_WEBHOOK = "https://discord.com/api/webhooks/...",
```

### **DataStore Logs:**
- **Banned players** stored in DataStore
- **Violation history** tracked
- **Cross-server** ban system

---

## 🔧 **Troubleshooting:**

### **Script Tidak Berjalan:**
- ✅ Pastikan script di **ServerScriptService**
- ✅ Check console untuk error
- ✅ Pastikan **DataStore** enabled

### **False Positives:**
- ✅ **Tingkatkan threshold** detection
- ✅ **Tambahkan ke whitelist**
- ✅ **Adjust sensitivity** settings

### **Performance Issues:**
- ✅ **Kurangi CHECK_INTERVAL**
- ✅ **Enable PERFORMANCE_MODE**
- ✅ **Limit MAX_PLAYERS_PER_CHECK**

### **Bypass Attempts:**
- ✅ **Server-side only** (tidak bisa di-bypass)
- ✅ **Multiple detection** methods
- ✅ **Real-time monitoring**

---

## 🛡️ **Security Features:**

### **Anti-Bypass:**
- **Server-side execution** only
- **No client-side** components
- **Encrypted detection** methods

### **Data Protection:**
- **DataStore** untuk ban list
- **Encrypted** violation logs
- **Secure** admin commands

### **Performance:**
- **Optimized** detection loops
- **Efficient** memory usage
- **Scalable** untuk banyak player

---

## 📈 **Performance Tips:**

### **Untuk Server Kecil (< 20 players):**
```lua
CHECK_INTERVAL = 0.1,              -- 100ms
MAX_VIOLATIONS = 3,                -- 3 violations
ENABLE_PERFORMANCE_MODE = false,   -- Full detection
```

### **Untuk Server Besar (> 50 players):**
```lua
CHECK_INTERVAL = 0.2,              -- 200ms
MAX_VIOLATIONS = 5,                -- 5 violations
ENABLE_PERFORMANCE_MODE = true,    -- Performance mode
MAX_PLAYERS_PER_CHECK = 25,        -- Limit per check
```

### **Untuk Server Sangat Besar (> 100 players):**
```lua
CHECK_INTERVAL = 0.5,              -- 500ms
MAX_VIOLATIONS = 7,                -- 7 violations
ENABLE_PERFORMANCE_MODE = true,    -- Performance mode
MAX_PLAYERS_PER_CHECK = 20,        -- Limit per check
```

---

## 🎯 **Customization:**

### **Tambah Detection Baru:**
```lua
-- Di function runDetectionLoop()
checkCustomHack(player)  -- Tambah function baru
```

### **Ubah Threshold:**
```lua
-- Di ANTI_CHEAT_CONFIG
MAX_SPEED = 75,                    -- Lebih toleran
MAX_JUMP_POWER = 150,              -- Lebih toleran
```

### **Tambah Whitelist:**
```lua
-- Di WHITELIST_IDS
WHITELIST_IDS = {
    123456789,                     -- Admin 1
    987654321,                     -- Admin 2
    555666777,                     -- VIP Player
}
```

---

## ⚠️ **Important Notes:**

### **Server-Side Only:**
- Script **HARUS** di ServerScriptService
- **TIDAK** bisa di-bypass oleh client
- **Aman** dari exploit

### **DataStore Requirements:**
- **Enable DataStore** di game settings
- **API Services** harus aktif
- **DataStore** untuk ban persistence

### **Performance Considerations:**
- **Monitor** server performance
- **Adjust** detection intervals
- **Use** performance mode jika perlu

---

## 🚀 **Quick Start:**

1. **Copy** `AntiCheat_Server_System.lua`
2. **Paste** di ServerScriptService
3. **Edit** configuration sesuai kebutuhan
4. **Test** di Studio
5. **Publish** ke Roblox

**Sistem anti-cheat siap melindungi server Anda! 🛡️**

---

## 📞 **Support:**

Jika mengalami masalah:
1. **Check console** untuk error
2. **Verify** script placement
3. **Test** configuration
4. **Monitor** performance

**Sistem ini akan otomatis mendeteksi dan kick cheater! 🎯**