# 🚨 Report Menu System - Installation Guide

## 📋 **Sistem Menu Report dengan Discord Webhook**

Sistem ini akan membuat **menu report di pojok kiri atas** yang terhubung ke Discord webhook untuk mengirim laporan secara otomatis.

---

## 🎯 **Fitur Utama:**

### **1. Menu UI di Pojok Kiri Atas:**
- ✅ **Report Button** - Tombol report yang selalu terlihat
- ✅ **Dropdown Menu** - Menu yang muncul saat diklik
- ✅ **Player Selection** - Pilih player yang dilaporkan
- ✅ **Category Selection** - Pilih kategori laporan
- ✅ **Description Box** - Deskripsi laporan (opsional)

### **2. Discord Webhook Integration:**
- ✅ **Automatic Sending** - Kirim laporan otomatis ke Discord
- ✅ **Rich Embeds** - Format laporan yang indah
- ✅ **Player Information** - Info lengkap reporter dan reported
- ✅ **Timestamp** - Waktu laporan dibuat
- ✅ **Server ID** - ID server tempat laporan dibuat

### **3. Report Categories:**
- ✅ **Cheating/Hacking** - Laporan cheat/hack
- ✅ **Harassment/Bullying** - Laporan bullying
- ✅ **Inappropriate Content** - Konten tidak pantas
- ✅ **Spam/Advertising** - Spam dan iklan
- ✅ **Exploiting/Glitching** - Eksploitasi bug
- ✅ **Scamming** - Penipuan
- ✅ **Other** - Lainnya

### **4. Advanced Features:**
- ✅ **Report Cooldown** - Delay antar laporan
- ✅ **Max Reports Limit** - Batas laporan per player
- ✅ **Auto Kick System** - Kick otomatis setelah X laporan
- ✅ **Data Storage** - Simpan data laporan
- ✅ **Admin Commands** - Command untuk admin

---

## 📁 **File yang Dibuat:**

### **1. `Report_Menu_System.lua`** - Script Server Lengkap
- **Comprehensive report system**
- **Discord webhook integration**
- **Data storage system**
- **Admin commands**

### **2. `Report_Menu_Client.lua`** - Script Client
- **Beautiful UI** di pojok kiri atas
- **Dropdown menus**
- **Notifications**
- **Sound effects**

### **3. `Report_System_Simple.lua`** - Script Sederhana
- **Easy setup**
- **Basic functionality**
- **Minimal configuration**
- **Quick deployment**

### **4. `Report_Installation_Guide.md`** - Panduan Instalasi
- **Step-by-step** installation
- **Discord webhook setup**
- **Configuration guide**

---

## 🚀 **Cara Instalasi:**

### **Metode 1: Full System (Recommended)**

#### **Langkah 1: Setup Discord Webhook**
1. **Buka Discord Server** Anda
2. **Server Settings** → **Integrations** → **Webhooks**
3. **Create Webhook** → **Copy Webhook URL**
4. **Paste URL** ke script

#### **Langkah 2: Setup Server Script**
1. **Buka Roblox Studio**
2. **ServerScriptService** → **Insert Object** → **Script**
3. **Rename** menjadi "Report_Menu_System"
4. **Copy-paste** script server lengkap
5. **Edit Discord webhook URL** di `REPORT_CONFIG.DISCORD_WEBHOOK_URL`
6. **Save** dan **Publish**

#### **Langkah 3: Setup Client Script**
1. **StarterPlayer** → **StarterPlayerScripts** → **Insert Object** → **LocalScript**
2. **Rename** menjadi "Report_Menu_Client"
3. **Copy-paste** script client
4. **Save** dan **Publish**

### **Metode 2: Simple System (Quick Setup)**

#### **Langkah 1: Setup Simple Script**
1. **ServerScriptService** → **Insert Object** → **Script**
2. **Copy-paste** `Report_System_Simple.lua`
3. **Edit Discord webhook URL** di `REPORT_CONFIG.DISCORD_WEBHOOK_URL`
4. **Save** dan **Publish**

---

## 🔧 **Setup Discord Webhook:**

### **Langkah 1: Buat Webhook**
1. **Buka Discord Server**
2. **Server Settings** → **Integrations** → **Webhooks**
3. **Create Webhook**
4. **Copy Webhook URL**

### **Langkah 2: Konfigurasi Script**
```lua
-- Di REPORT_CONFIG
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL_HERE",
ENABLE_DISCORD_LOGS = true,
```

### **Langkah 3: Test Webhook**
- **Join game** dan test report system
- **Check Discord channel** untuk laporan
- **Verify** format laporan

---

## ⚙️ **Konfigurasi:**

### **Discord Webhook Settings:**
```lua
-- Di REPORT_CONFIG
DISCORD_WEBHOOK_URL = "YOUR_WEBHOOK_URL",  -- Discord webhook URL
ENABLE_DISCORD_LOGS = true,                -- Enable Discord logging
SAVE_REPORTS_TO_DISCORD = true,            -- Save reports to Discord
```

### **Report Settings:**
```lua
-- Di REPORT_CONFIG
MAX_REPORTS_PER_PLAYER = 5,                -- Max reports per player
REPORT_COOLDOWN = 60,                      -- Cooldown (seconds)
AUTO_KICK_ON_REPORTS = false,              -- Auto kick enabled
KICK_THRESHOLD = 10,                       -- Reports before kick
```

### **UI Settings:**
```lua
-- Di UI_CONFIG (Client)
MENU_POSITION = "TopLeft",                 -- Menu position
MENU_SIZE = {width = 300, height = 400},   -- Menu size
BUTTON_SIZE = {width = 80, height = 30},   -- Button size
```

### **Report Categories:**
```lua
-- Tambah kategori baru
REPORT_CATEGORIES = {
    "Cheating/Hacking",
    "Harassment/Bullying", 
    "Inappropriate Content",
    "Spam/Advertising",
    "Exploiting/Glitching",
    "Scamming",
    "Custom Category",  -- Tambah kategori baru
    "Other"
}
```

---

## 🎮 **Cara Menggunakan:**

### **Player Usage:**
1. **Klik tombol "🚨 Report"** di pojok kiri atas
2. **Pilih player** yang ingin dilaporkan
3. **Pilih kategori** laporan
4. **Tulis deskripsi** (opsional)
5. **Klik "Submit Report"**

### **Admin Commands:**
```
/reports - Lihat jumlah laporan
/clearreports - Hapus semua data laporan
```

### **Discord Notifications:**
- **Laporan otomatis** dikirim ke Discord
- **Format embed** yang indah
- **Info lengkap** reporter dan reported
- **Timestamp** dan server ID

---

## 📊 **Discord Webhook Format:**

### **Report Embed:**
```json
{
  "title": "🚨 New Report Received",
  "color": 16711680,
  "fields": [
    {
      "name": "👤 Reporter",
      "value": "PlayerName (123456789)",
      "inline": true
    },
    {
      "name": "🎯 Reported Player",
      "value": "ReportedPlayer (987654321)",
      "inline": true
    },
    {
      "name": "📋 Category",
      "value": "Cheating/Hacking",
      "inline": true
    },
    {
      "name": "📝 Description",
      "value": "Player description here",
      "inline": false
    },
    {
      "name": "🕐 Time",
      "value": "2024-01-15 14:30:25",
      "inline": true
    },
    {
      "name": "🆔 Server ID",
      "value": "game.JobId",
      "inline": true
    }
  ]
}
```

---

## 🎨 **Customization:**

### **Ubah Posisi Menu:**
```lua
-- Di UI_CONFIG
POSITION_X = 0.02,  -- 2% dari kiri (0.02 = kiri, 0.98 = kanan)
POSITION_Y = 0.02,  -- 2% dari atas (0.02 = atas, 0.98 = bawah)
```

### **Ubah Warna UI:**
```lua
-- Di UI_CONFIG
PRIMARY_COLOR = Color3.fromRGB(25, 25, 25),    -- Warna utama
SECONDARY_COLOR = Color3.fromRGB(35, 35, 35),  -- Warna sekunder
ACCENT_COLOR = Color3.fromRGB(0, 162, 255),    -- Warna aksen
SUCCESS_COLOR = Color3.fromRGB(46, 204, 113),  -- Warna sukses
ERROR_COLOR = Color3.fromRGB(231, 76, 60),     -- Warna error
```

### **Ubah Ukuran Menu:**
```lua
-- Di UI_CONFIG
MENU_WIDTH = 300,    -- Lebar menu
MENU_HEIGHT = 400,   -- Tinggi menu
BUTTON_WIDTH = 80,   -- Lebar tombol
BUTTON_HEIGHT = 30,  -- Tinggi tombol
```

### **Ubah Sound:**
```lua
-- Di UI_CONFIG
ENABLE_SOUND = true,                           -- Enable sound
SOUND_ID = "rbxasset://sounds/electronicpingshort.wav",  -- Sound ID
SOUND_VOLUME = 0.3                            -- Volume
```

---

## 🔧 **Troubleshooting:**

### **Menu Tidak Muncul:**
- ✅ Pastikan client script di **StarterPlayerScripts**
- ✅ Check console untuk error
- ✅ Verify **RemoteEvent** connection
- ✅ Check **ReplicatedStorage** access

### **Discord Webhook Tidak Bekerja:**
- ✅ **Verify webhook URL** yang benar
- ✅ **Check Discord permissions**
- ✅ **Test webhook** manual
- ✅ **Check console** untuk error

### **Report Tidak Terkirim:**
- ✅ Pastikan script di **ServerScriptService**
- ✅ Check **HttpService** enabled
- ✅ Verify **webhook URL** format
- ✅ Check **cooldown** settings

### **UI Tidak Responsive:**
- ✅ Check **UserInputService** access
- ✅ Verify **TweenService** enabled
- ✅ Check **ZIndex** settings
- ✅ Restart **client script**

---

## 📈 **Performance Tips:**

### **Untuk Server Kecil (< 20 players):**
```lua
REPORT_COOLDOWN = 30,              -- 30 detik
MAX_REPORTS_PER_PLAYER = 3,        -- 3 laporan
AUTO_KICK_THRESHOLD = 5            -- 5 laporan
```

### **Untuk Server Besar (> 50 players):**
```lua
REPORT_COOLDOWN = 60,              -- 60 detik
MAX_REPORTS_PER_PLAYER = 5,        -- 5 laporan
AUTO_KICK_THRESHOLD = 10           -- 10 laporan
```

---

## 🎯 **Usage Examples:**

### **Custom Report Category:**
```lua
-- Tambah kategori baru
REPORT_CATEGORIES = {
    "Cheating/Hacking",
    "Harassment/Bullying", 
    "Inappropriate Content",
    "Spam/Advertising",
    "Exploiting/Glitching",
    "Scamming",
    "Team Killing",        -- Kategori baru
    "Griefing",           -- Kategori baru
    "Other"
}
```

### **Custom Discord Message:**
```lua
-- Ubah format Discord message
local embed = {
    {
        title = "🚨 LAPORAN BARU DITERIMA",  -- Judul custom
        color = 16711680,
        fields = {
            -- Custom fields
        }
    }
}
```

### **Custom UI Position:**
```lua
-- Pindah ke pojok kanan atas
POSITION_X = 0.98,  -- Kanan
POSITION_Y = 0.02,  -- Atas
```

---

## 🚀 **Quick Start:**

### **Untuk Pemula:**
1. **Buat Discord webhook**
2. **Copy** `Report_System_Simple.lua`
3. **Paste** di ServerScriptService
4. **Edit webhook URL**
5. **Save** dan **Publish**

### **Untuk Advanced:**
1. **Buat Discord webhook**
2. **Copy** server script ke ServerScriptService
3. **Copy** client script ke StarterPlayerScripts
4. **Edit webhook URL** dan konfigurasi
5. **Test** dan **Publish**

---

## ⚠️ **Important Notes:**

### **Discord Webhook Requirements:**
- **Valid webhook URL** dari Discord
- **Proper permissions** di Discord server
- **HttpService** enabled di Roblox

### **Security:**
- **Server-side** report processing (aman)
- **Client script** hanya untuk UI
- **Webhook URL** jangan di-share

---

## 🎉 **Features:**

### **Automatic Features:**
- ✅ **Auto send** ke Discord
- ✅ **Auto format** laporan
- ✅ **Auto cooldown** system
- ✅ **Auto kick** setelah X laporan

### **Manual Features:**
- ✅ **Manual report** submission
- ✅ **Manual admin** commands
- ✅ **Manual data** management

### **UI Features:**
- ✅ **Beautiful interface**
- ✅ **Dropdown menus**
- ✅ **Notifications**
- ✅ **Sound effects**
- ✅ **Animations**

---

## 🏆 **Ready to Use:**

**Sistem report ini akan:**
1. **Menampilkan menu** di pojok kiri atas
2. **Mengirim laporan** otomatis ke Discord
3. **Menyimpan data** laporan
4. **Memberikan notifikasi** kepada player
5. **Menyediakan admin** commands
6. **Mudah dikustomisasi** sesuai kebutuhan

**Server Anda akan memiliki sistem laporan yang profesional! 🚨**