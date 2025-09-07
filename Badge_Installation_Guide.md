# 🏆 Badge System - Installation Guide

## 🎯 **Sistem Lencana Otomatis untuk Roblox**

Sistem ini akan **otomatis memberikan lencana** kepada player saat join ke server dengan berbagai jenis lencana dan kondisi.

---

## 🏅 **Jenis Lencana:**

### **1. Welcome Badges (Lencana Selamat Datang):**
- ✅ **First Join** - Pertama kali join server
- ✅ **Welcome Back** - Player yang kembali
- ✅ **Newcomer** - Player baru (kurang dari 7 hari)

### **2. Milestone Badges (Lencana Pencapaian):**
- ✅ **Level Badges** - Level 5, 10, 25, 50
- ✅ **Playtime Badges** - 1 jam, 5 jam, 24 jam
- ✅ **Join Count Badges** - 10, 50, 100 kali join

### **3. Special Badges (Lencana Khusus):**
- ✅ **VIP Badge** - Member VIP
- ✅ **Admin Badge** - Administrator
- ✅ **Beta Tester** - Tester beta
- ✅ **Early Supporter** - Pendukung awal

---

## 📁 **File yang Dibuat:**

### **1. `Badge_System_Server.lua`** - Script Server Lengkap
- **Comprehensive badge system**
- **Auto award** functionality
- **DataStore integration**
- **Advanced features**

### **2. `Badge_Notification_Client.lua`** - Script Client
- **Beautiful notifications**
- **Badge collection UI**
- **Sound effects**
- **Animations**

### **3. `Badge_System_Simple.lua`** - Script Sederhana
- **Easy setup**
- **Basic functionality**
- **Minimal configuration**
- **Quick deployment**

### **4. `Badge_Installation_Guide.md`** - Panduan Instalasi
- **Step-by-step** installation
- **Configuration guide**
- **Usage examples**

---

## 🚀 **Cara Instalasi:**

### **Metode 1: Full System (Recommended)**

#### **Langkah 1: Setup Server Script**
1. **Buka Roblox Studio**
2. **ServerScriptService** → **Insert Object** → **Script**
3. **Rename** menjadi "Badge_System_Server"
4. **Copy-paste** script server lengkap
5. **Save** dan **Publish**

#### **Langkah 2: Setup Client Script**
1. **StarterPlayer** → **StarterPlayerScripts** → **Insert Object** → **LocalScript**
2. **Rename** menjadi "Badge_Notification_Client"
3. **Copy-paste** script client
4. **Save** dan **Publish**

### **Metode 2: Simple System (Quick Setup)**

#### **Langkah 1: Setup Simple Script**
1. **ServerScriptService** → **Insert Object** → **Script**
2. **Copy-paste** `Badge_System_Simple.lua`
3. **Save** dan **Publish**

---

## ⚙️ **Konfigurasi:**

### **Badge Settings:**
```lua
-- Di BADGE_CONFIG
ENABLE_BADGES = true,                    -- Enable badge system
BADGE_DELAY = 2,                        -- Delay sebelum award (detik)
AUTO_AWARD_WELCOME = true,              -- Auto award welcome badges
AUTO_AWARD_MILESTONE = true,            -- Auto award milestone badges
AUTO_AWARD_SPECIAL = true,              -- Auto award special badges
```

### **Badge Types:**
```lua
-- Tambah badge baru
BADGE_DATA = {
    ["Custom_Badge"] = {
        name = "Custom Badge",
        description = "Custom description",
        icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        rarity = "Rare",
        color = Color3.fromRGB(255, 100, 100)
    }
}
```

### **Milestone Conditions:**
```lua
-- Tambah milestone baru
MILESTONE_BADGES = {
    {name = "Level_100", condition = "level", value = 100},
    {name = "Playtime_48H", condition = "playtime", value = 172800},
    {name = "Join_Count_200", condition = "joins", value = 200}
}
```

---

## 🎮 **Cara Menggunakan:**

### **Automatic Badge Awarding:**
- **Welcome badges** diberikan otomatis saat join
- **Milestone badges** diberikan saat kondisi terpenuhi
- **Special badges** diberikan berdasarkan status player

### **Manual Badge Awarding:**
```lua
-- Award badge manual
_G.BadgeSystem.awardBadge(player, "Custom_Badge", "Manual award")

-- Check if player has badge
local hasBadge = _G.BadgeSystem.hasBadge(player, "Level_10")

-- Update player level
_G.BadgeSystem.updatePlayerLevel(player, 25)

-- Set special status
_G.BadgeSystem.setPlayerSpecialStatus(player, "vip", true)
```

### **Client Features:**
- **Press B** untuk buka badge collection
- **Automatic notifications** saat dapat badge
- **Sound effects** dan animasi
- **Badge collection UI**

---

## 📊 **Badge Rarity System:**

### **Rarity Levels:**
- **Common** - Warna abu-abu
- **Uncommon** - Warna hijau
- **Rare** - Warna biru
- **Epic** - Warna ungu
- **Legendary** - Warna emas

### **Rarity Colors:**
```lua
RARITY_COLORS = {
    Common = Color3.fromRGB(150, 150, 150),
    Uncommon = Color3.fromRGB(100, 200, 100),
    Rare = Color3.fromRGB(100, 150, 255),
    Epic = Color3.fromRGB(200, 100, 255),
    Legendary = Color3.fromRGB(255, 215, 0)
}
```

---

## 🎨 **Customization:**

### **Ubah Badge Appearance:**
```lua
-- Di BADGE_DATA
["Badge_Name"] = {
    name = "Badge Name",
    description = "Badge description",
    icon = "rbxasset://textures/ui/GuiImagePlaceholder.png",  -- Ganti icon
    rarity = "Rare",                                          -- Ganti rarity
    color = Color3.fromRGB(255, 100, 100)                    -- Ganti warna
}
```

### **Ubah Notification Settings:**
```lua
-- Di NOTIFICATION_CONFIG
WIDTH = 350,                    -- Lebar notification
HEIGHT = 80,                    -- Tinggi notification
DISPLAY_DURATION = 5,           -- Durasi tampil (detik)
ENABLE_SOUND = true,            -- Enable sound
SOUND_VOLUME = 0.5              -- Volume sound
```

### **Ubah Position:**
```lua
-- Di NOTIFICATION_CONFIG
POSITION_X = 0.5,               -- Posisi X (0.5 = tengah)
POSITION_Y = 0.1,               -- Posisi Y (0.1 = atas)
OFFSET_Y = 0                    -- Offset tambahan
```

---

## 🔧 **Troubleshooting:**

### **Badge Tidak Muncul:**
- ✅ Pastikan script di **ServerScriptService**
- ✅ Check console untuk error
- ✅ Pastikan **DataStore** enabled
- ✅ Check **BADGE_DELAY** setting

### **Notification Tidak Muncul:**
- ✅ Pastikan client script di **StarterPlayerScripts**
- ✅ Check **RemoteEvent** connection
- ✅ Verify **ReplicatedStorage** access

### **Data Tidak Tersimpan:**
- ✅ Pastikan **DataStore** enabled di game settings
- ✅ Check **API Services** status
- ✅ Verify **DataStore** permissions

### **Performance Issues:**
- ✅ **Kurangi CHECK_INTERVAL**
- ✅ **Limit** jumlah badge checks
- ✅ **Optimize** DataStore calls

---

## 📈 **Performance Tips:**

### **Untuk Server Kecil (< 20 players):**
```lua
CHECK_INTERVAL = 1,              -- 1 detik
BADGE_DELAY = 2,                -- 2 detik
AUTO_AWARD_ALL = true           -- Award semua badge
```

### **Untuk Server Besar (> 50 players):**
```lua
CHECK_INTERVAL = 5,              -- 5 detik
BADGE_DELAY = 3,                -- 3 detik
AUTO_AWARD_ESSENTIAL = true     -- Award badge penting saja
```

---

## 🎯 **Usage Examples:**

### **Award Badge untuk Event:**
```lua
-- Event khusus
_G.BadgeSystem.awardBadge(player, "Event_Participant", "Participated in special event")
```

### **Award Badge untuk Achievement:**
```lua
-- Achievement system
if playerLevel >= 50 then
    _G.BadgeSystem.awardBadge(player, "Level_50", "Reached level 50")
end
```

### **Award Badge untuk Purchase:**
```lua
-- Gamepass purchase
_G.BadgeSystem.setPlayerSpecialStatus(player, "vip", true)
```

---

## 🚀 **Quick Start:**

### **Untuk Pemula:**
1. **Copy** `Badge_System_Simple.lua`
2. **Paste** di ServerScriptService
3. **Save** dan **Publish**
4. **Test** di Studio

### **Untuk Advanced:**
1. **Copy** server script ke ServerScriptService
2. **Copy** client script ke StarterPlayerScripts
3. **Configure** settings
4. **Test** dan **Publish**

---

## ⚠️ **Important Notes:**

### **DataStore Requirements:**
- **Enable DataStore** di game settings
- **API Services** harus aktif
- **DataStore** untuk badge persistence

### **Server-Side Only:**
- **Badge logic** di server (aman)
- **Client script** hanya untuk UI
- **Tidak bisa** di-bypass

---

## 🎉 **Features:**

### **Automatic Features:**
- ✅ **Auto award** welcome badges
- ✅ **Auto award** milestone badges
- ✅ **Auto award** special badges
- ✅ **Auto save** player data
- ✅ **Auto track** playtime

### **Manual Features:**
- ✅ **Manual award** badges
- ✅ **Manual update** player stats
- ✅ **Manual set** special status
- ✅ **Manual check** badge status

### **UI Features:**
- ✅ **Beautiful notifications**
- ✅ **Badge collection UI**
- ✅ **Sound effects**
- ✅ **Animations**
- ✅ **Rarity colors**

---

## 🏆 **Ready to Use:**

**Sistem badge ini akan:**
1. **Otomatis memberikan** lencana saat join
2. **Menyimpan data** player secara permanen
3. **Menampilkan notifikasi** yang indah
4. **Menyediakan UI** untuk melihat koleksi
5. **Mendukung** berbagai jenis lencana
6. **Mudah dikustomisasi** sesuai kebutuhan

**Player akan senang mendapatkan lencana! 🏅**