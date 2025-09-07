# 💬 Admin Message System - Installation Guide

## 📨 **Sistem Menu Pesan Admin dengan Discord Webhook**

Sistem ini akan membuat **menu pesan admin di tengah atas** yang terhubung ke Discord webhook untuk mengirim pesan ke admin secara otomatis.

---

## 🎯 **Fitur Utama:**

### **1. Menu UI di Tengah Atas:**
- ✅ **Message Button** - Tombol "💬 Message Admin" yang selalu terlihat
- ✅ **Open/Close Menu** - Menu yang bisa dibuka dan ditutup
- ✅ **Category Selection** - Pilih kategori pesan
- ✅ **Priority Selection** - Pilih prioritas pesan
- ✅ **Message Input** - Input pesan dengan character counter
- ✅ **Beautiful UI** - Interface yang modern dan menarik

### **2. Discord Webhook Integration:**
- ✅ **Automatic Sending** - Kirim pesan otomatis ke Discord
- ✅ **Rich Embeds** - Format pesan yang indah dengan embed
- ✅ **Priority Colors** - Warna berbeda berdasarkan prioritas
- ✅ **Sender Information** - Info lengkap pengirim pesan
- ✅ **Timestamp** - Waktu pesan dibuat
- ✅ **Server ID** - ID server tempat pesan dibuat

### **3. Message Categories:**
- ✅ **Bug Report** - Laporan bug
- ✅ **Feature Request** - Permintaan fitur
- ✅ **Player Issue** - Masalah player
- ✅ **Server Problem** - Masalah server
- ✅ **General Question** - Pertanyaan umum
- ✅ **Complaint** - Keluhan
- ✅ **Suggestion** - Saran
- ✅ **Other** - Lainnya

### **4. Priority Levels:**
- ✅ **Low** - Prioritas rendah (Biru)
- ✅ **Medium** - Prioritas sedang (Kuning)
- ✅ **High** - Prioritas tinggi (Orange)
- ✅ **Urgent** - Prioritas mendesak (Merah)

### **5. Advanced Features:**
- ✅ **Message Cooldown** - Delay antar pesan (120 detik)
- ✅ **Max Messages Limit** - Batas pesan per player (3 pesan)
- ✅ **Character Counter** - Hitung karakter real-time
- ✅ **Data Storage** - Simpan data pesan permanen
- ✅ **Admin Commands** - Command untuk admin
- ✅ **Notifications** - Notifikasi sukses/error

---

## 📁 **File yang Dibuat:**

### **1. `Admin_Message_System.lua`** - Script Server Lengkap
- **Comprehensive message system**
- **Discord webhook integration**
- **Data storage system**
- **Admin commands**

### **2. `Admin_Message_Client.lua`** - Script Client
- **Beautiful UI** di tengah atas
- **Open/close functionality**
- **Dropdown menus**
- **Character counter**

### **3. `Admin_Message_Simple.lua`** - Script Sederhana
- **Easy setup**
- **Basic functionality**
- **Minimal configuration**
- **Quick deployment**

### **4. `Admin_Message_Installation_Guide.md`** - Panduan Lengkap
- **Step-by-step** installation
- **Discord webhook setup**
- **Configuration guide**
- **Troubleshooting tips**

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
3. **Rename** menjadi "Admin_Message_System"
4. **Copy-paste** script server lengkap
5. **Edit Discord webhook URL** di `ADMIN_MESSAGE_CONFIG.DISCORD_WEBHOOK_URL`
6. **Add admin user IDs** di `ADMIN_MESSAGE_CONFIG.ADMIN_USER_IDS`
7. **Save** dan **Publish**

#### **Langkah 3: Setup Client Script**
1. **StarterPlayer** → **StarterPlayerScripts** → **Insert Object** → **LocalScript**
2. **Rename** menjadi "Admin_Message_Client"
3. **Copy-paste** script client
4. **Save** dan **Publish**

### **Metode 2: Simple System (Quick Setup)**

#### **Langkah 1: Setup Simple Script**
1. **ServerScriptService** → **Insert Object** → **Script**
2. **Copy-paste** `Admin_Message_Simple.lua`
3. **Edit Discord webhook URL** di `ADMIN_MESSAGE_CONFIG.DISCORD_WEBHOOK_URL`
4. **Add admin user IDs** di `ADMIN_MESSAGE_CONFIG.ADMIN_USER_IDS`
5. **Save** dan **Publish**

---

## 🔧 **Setup Discord Webhook:**

### **Langkah 1: Buat Webhook**
1. **Buka Discord Server**
2. **Server Settings** → **Integrations** → **Webhooks**
3. **Create Webhook**
4. **Copy Webhook URL**

### **Langkah 2: Konfigurasi Script**
```lua
-- Di ADMIN_MESSAGE_CONFIG
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL_HERE",
ENABLE_DISCORD_LOGS = true,
```

### **Langkah 3: Add Admin User IDs**
```lua
-- Di ADMIN_MESSAGE_CONFIG
ADMIN_USER_IDS = {  -- Add admin user IDs here
    123456789,      -- Admin 1
    987654321,      -- Admin 2
    555666777,      -- Admin 3
}
```

### **Langkah 4: Test Webhook**
- **Join game** dan test message system
- **Check Discord channel** untuk pesan
- **Verify** format pesan

---

## ⚙️ **Konfigurasi:**

### **Discord Webhook Settings:**
```lua
-- Di ADMIN_MESSAGE_CONFIG
DISCORD_WEBHOOK_URL = "YOUR_WEBHOOK_URL",  -- Discord webhook URL
ENABLE_DISCORD_LOGS = true,                -- Enable Discord logging
SAVE_MESSAGES_TO_DISCORD = true,           -- Save messages to Discord
```

### **Message Settings:**
```lua
-- Di ADMIN_MESSAGE_CONFIG
MAX_MESSAGES_PER_PLAYER = 3,               -- Max messages per player
MESSAGE_COOLDOWN = 120,                    -- Cooldown (seconds)
MAX_MESSAGE_LENGTH = 500,                  -- Max message length
MIN_MESSAGE_LENGTH = 10,                   -- Min message length
```

### **UI Settings:**
```lua
-- Di UI_CONFIG (Client)
MENU_POSITION = "CenterTop",               -- Menu position
MENU_SIZE = {width = 400, height = 500},   -- Menu size
BUTTON_SIZE = {width = 100, height = 35},  -- Button size
```

### **Message Categories:**
```lua
-- Tambah kategori baru
MESSAGE_CATEGORIES = {
    "Bug Report",
    "Feature Request", 
    "Player Issue",
    "Server Problem",
    "General Question",
    "Complaint",
    "Suggestion",
    "Custom Category",  -- Tambah kategori baru
    "Other"
}
```

### **Priority Levels:**
```lua
-- Tambah prioritas baru
PRIORITY_LEVELS = {
    "Low",
    "Medium", 
    "High",
    "Critical",  -- Tambah prioritas baru
    "Urgent"
}
```

---

## 🎮 **Cara Menggunakan:**

### **Player Usage:**
1. **Klik tombol "💬 Message Admin"** di tengah atas
2. **Pilih kategori** pesan
3. **Pilih prioritas** pesan
4. **Tulis pesan** (10-500 karakter)
5. **Klik "Send Message"**

### **Admin Commands:**
```
/messages - Lihat jumlah pesan
/clearmessages - Hapus semua data pesan
/respond [messageId] [response] - Balas pesan
```

### **Discord Notifications:**
- **Pesan otomatis** dikirim ke Discord
- **Format embed** yang indah
- **Warna berbeda** berdasarkan prioritas
- **Info lengkap** pengirim dan pesan

---

## 📊 **Discord Webhook Format:**

### **Message Embed:**
```json
{
  "title": "📨 New Admin Message",
  "color": 16711680,
  "fields": [
    {
      "name": "👤 From",
      "value": "PlayerName (123456789)",
      "inline": true
    },
    {
      "name": "📋 Category",
      "value": "Bug Report",
      "inline": true
    },
    {
      "name": "⚡ Priority",
      "value": "High",
      "inline": true
    },
    {
      "name": "📝 Message",
      "value": "Player message here",
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
POSITION_X = 0.5,  -- 50% dari kiri (0.5 = tengah, 0.02 = kiri, 0.98 = kanan)
POSITION_Y = 0.05, -- 5% dari atas (0.05 = atas, 0.5 = tengah, 0.95 = bawah)
```

### **Ubah Warna UI:**
```lua
-- Di UI_CONFIG
PRIMARY_COLOR = Color3.fromRGB(20, 20, 20),    -- Warna utama
SECONDARY_COLOR = Color3.fromRGB(30, 30, 30),  -- Warna sekunder
ACCENT_COLOR = Color3.fromRGB(0, 162, 255),    -- Warna aksen
SUCCESS_COLOR = Color3.fromRGB(46, 204, 113),  -- Warna sukses
ERROR_COLOR = Color3.fromRGB(231, 76, 60),     -- Warna error
```

### **Ubah Ukuran Menu:**
```lua
-- Di UI_CONFIG
MENU_WIDTH = 400,    -- Lebar menu
MENU_HEIGHT = 500,   -- Tinggi menu
BUTTON_WIDTH = 100,  -- Lebar tombol
BUTTON_HEIGHT = 35,  -- Tinggi tombol
```

### **Ubah Priority Colors:**
```lua
-- Di UI_CONFIG
PRIORITY_COLORS = {
    Low = Color3.fromRGB(100, 150, 255),      -- Biru
    Medium = Color3.fromRGB(255, 193, 7),     -- Kuning
    High = Color3.fromRGB(255, 152, 0),       -- Orange
    Urgent = Color3.fromRGB(244, 67, 54)      -- Merah
}
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

### **Pesan Tidak Terkirim:**
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
MESSAGE_COOLDOWN = 60,              -- 60 detik
MAX_MESSAGES_PER_PLAYER = 5,        -- 5 pesan
MAX_MESSAGE_LENGTH = 1000,          -- 1000 karakter
```

### **Untuk Server Besar (> 50 players):**
```lua
MESSAGE_COOLDOWN = 120,             -- 120 detik
MAX_MESSAGES_PER_PLAYER = 3,        -- 3 pesan
MAX_MESSAGE_LENGTH = 500,           -- 500 karakter
```

---

## 🎯 **Usage Examples:**

### **Custom Message Category:**
```lua
-- Tambah kategori baru
MESSAGE_CATEGORIES = {
    "Bug Report",
    "Feature Request", 
    "Player Issue",
    "Server Problem",
    "General Question",
    "Complaint",
    "Suggestion",
    "Technical Support",  -- Kategori baru
    "Billing Issue",      -- Kategori baru
    "Other"
}
```

### **Custom Priority Level:**
```lua
-- Tambah prioritas baru
PRIORITY_LEVELS = {
    "Low",
    "Medium", 
    "High",
    "Critical",  -- Prioritas baru
    "Emergency", -- Prioritas baru
    "Urgent"
}
```

### **Custom Discord Message:**
```lua
-- Ubah format Discord message
local embed = {
    {
        title = "📨 PESAN ADMIN BARU",  -- Judul custom
        color = priorityColors[priority] or 3447003,
        fields = {
            -- Custom fields
        }
    }
}
```

---

## 🚀 **Quick Start:**

### **Untuk Pemula:**
1. **Buat Discord webhook**
2. **Copy** `Admin_Message_Simple.lua`
3. **Paste** di ServerScriptService
4. **Edit webhook URL** dan admin IDs
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

### **Admin Setup:**
- **Add admin user IDs** ke konfigurasi
- **Admin commands** hanya untuk admin
- **Webhook URL** jangan di-share

### **Security:**
- **Server-side** message processing (aman)
- **Client script** hanya untuk UI
- **Admin verification** built-in

---

## 🎉 **Features:**

### **Automatic Features:**
- ✅ **Auto send** ke Discord
- ✅ **Auto format** pesan
- ✅ **Auto cooldown** system
- ✅ **Auto character** counter

### **Manual Features:**
- ✅ **Manual message** submission
- ✅ **Manual admin** commands
- ✅ **Manual data** management

### **UI Features:**
- ✅ **Beautiful interface**
- ✅ **Open/close** functionality
- ✅ **Dropdown menus**
- ✅ **Character counter**
- ✅ **Priority colors**
- ✅ **Notifications**

---

## 🏆 **Ready to Use:**

**Sistem pesan admin ini akan:**
1. **Menampilkan menu** di tengah atas
2. **Mengirim pesan** otomatis ke Discord
3. **Menyimpan data** pesan
4. **Memberikan notifikasi** kepada player
5. **Menyediakan admin** commands
6. **Mudah dikustomisasi** sesuai kebutuhan

**Server Anda akan memiliki sistem komunikasi admin yang profesional! 💬**