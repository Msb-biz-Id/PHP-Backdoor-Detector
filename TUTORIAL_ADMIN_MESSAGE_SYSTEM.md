# 📨 TUTORIAL LENGKAP ROBLOX ADMIN MESSAGE SYSTEM
## Discord Webhook + Toggle Menu

---

## 📋 **DAFTAR ISI**

1. [Pengenalan](#pengenalan)
2. [Setup Discord Webhook](#setup-discord-webhook)
3. [Instalasi Script](#instalasi-script)
4. [Konfigurasi](#konfigurasi)
5. [Cara Penggunaan](#cara-penggunaan)
6. [Troubleshooting](#troubleshooting)
7. [FAQ](#faq)

---

## 🎯 **PENGENALAN**

**Roblox Admin Message System** adalah sistem untuk mengirim pesan ke admin dengan fitur:
- ✅ **Toggle Menu** di top center
- ✅ **Discord Webhook** integration
- ✅ **Admin Notification** in-game
- ✅ **Message History** tracking
- ✅ **Auto-close** menu
- ✅ **Character limit** protection

---

## 🔧 **SETUP DISCORD WEBHOOK**

### **1. Buat Discord Server**
1. **Buka Discord**
2. **Buat server baru** atau gunakan yang ada
3. **Beri nama** server (contoh: "Roblox Admin Messages")

### **2. Buat Text Channel**
1. **Klik kanan** di server
2. **Create Channel** → **Text Channel**
3. **Beri nama** channel (contoh: "admin-messages")

### **3. Buat Webhook**
1. **Klik kanan** pada channel
2. **Edit Channel** → **Integrations** → **Webhooks**
3. **Create Webhook**
4. **Copy Webhook URL**

### **4. Test Webhook**
```json
{
  "content": "Test message from Roblox Admin System"
}
```

---

## 📦 **INSTALASI SCRIPT**

### **1. Client Script (LocalScript)**

1. **Buka Roblox Studio**
2. **Pilih StarterGui** → **Insert** → **LocalScript**
3. **Rename** menjadi "AdminMessageSystem"
4. **Paste** script client
5. **Save**

### **2. Server Script**

1. **Pilih ServerScriptService**
2. **Insert** → **ServerScript**
3. **Rename** menjadi "AdminMessageServer"
4. **Paste** script server
5. **Save**

### **3. Publish Game**

1. **File** → **Publish to Roblox**
2. **Set permissions** untuk semua player
3. **Publish**

---

## ⚙️ **KONFIGURASI**

### **1. Discord Webhook URL**
```lua
-- Di kedua script (client & server)
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL_HERE"
```

### **2. Admin User ID**
```lua
-- Ganti dengan User ID admin
local ADMIN_USER_ID = 123456789
```

### **3. Settings Lainnya**
```lua
-- Client script
local MENU_DURATION = 30 -- Detik
local MAX_MESSAGE_LENGTH = 500 -- Karakter

-- Server script
local WEBHOOK_ENABLED = true -- Enable/disable webhook
```

---

## 🎮 **CARA PENGGUNAAN**

### **1. Buka Menu**
- **Klik** tombol 📨 di top center
- **Atau tekan F9**

### **2. Tulis Pesan**
- **Ketik** pesan di text box
- **Maksimal** 500 karakter
- **Character counter** di kanan bawah

### **3. Kirim Pesan**
- **📤 Send to Admin** - Kirim ke admin in-game
- **💬 Discord** - Kirim ke Discord webhook

### **4. Menu Auto-Close**
- **Tutup otomatis** setelah 30 detik
- **Atau klik** tombol ×

---

## 🎨 **FITUR UI**

### **1. Toggle Button (Top Center)**
- **Position**: Top center screen
- **Size**: 60x60 pixels
- **Icon**: 📨
- **Hover effect**: Scale up
- **Click**: Toggle menu

### **2. Message Menu**
- **Position**: Top center (below button)
- **Size**: 400x500 pixels
- **Features**:
  - Player info display
  - Message input (multi-line)
  - Character counter
  - Send buttons
  - Status updates

### **3. Admin Notification**
- **Position**: Top center (for admin)
- **Size**: 400x200 pixels
- **Features**:
  - Message content
  - Player info
  - Auto-close (30s)
  - Close button

---

## 🔧 **TROUBLESHOOTING**

### **❌ Menu Tidak Muncul**
**Solusi:**
1. Check console (F9) untuk error
2. Verify LocalScript placement
3. Check StarterGui permissions

### **❌ Discord Webhook Tidak Work**
**Solusi:**
1. Verify webhook URL benar
2. Check Discord server permissions
3. Test webhook manual
4. Check console untuk error

### **❌ Admin Tidak Terima Notifikasi**
**Solusi:**
1. Verify ADMIN_USER_ID benar
2. Check admin ada di game
3. Check console untuk error
4. Verify RemoteEvents created

### **❌ Error "HttpService not enabled"**
**Solusi:**
1. Enable HttpService di Game Settings
2. Go to Game Settings → Security
3. Enable "Allow HTTP Requests"

---

## 📊 **DEBUG COMMANDS**

### **Console Commands (F9)**
```
📨 Admin Message System loaded!
Controls:
  Click 📨 button (top center) to open menu
  F9 - Toggle menu
  Send messages to admin or Discord
  Auto-close after 30 seconds
```

### **Server Console**
```
📨 Admin Message System - Server loaded!
Configuration:
  Discord Webhook: Enabled
  Admin User ID: 123456789
  Webhook URL: Configured
👑 Admin found: AdminName
```

---

## ❓ **FAQ**

### **Q: Bagaimana cara dapat User ID admin?**
**A:** 
1. Buka profile admin di Roblox
2. Copy URL: `https://www.roblox.com/users/USER_ID/profile`
3. USER_ID adalah User ID admin

### **Q: Apakah webhook aman?**
**A:** Ya, webhook hanya bisa mengirim pesan, tidak bisa membaca atau mengubah data.

### **Q: Bisa ganti posisi menu?**
**A:** Ya, edit position di script:
```lua
-- Toggle button position
toggleButton.Position = UDim2.new(0.5, -30, 0, 20)

-- Menu position
mainFrame.Position = UDim2.new(0.5, -200, 0, 100)
```

### **Q: Bisa tambah fitur lain?**
**A:** Ya, bisa tambah:
- Message history
- File attachments
- Priority levels
- Auto-responses

---

## 🚀 **ADVANCED FEATURES**

### **1. Message History**
```lua
-- Server script
events.GetMessageHistory.OnServerEvent:Connect(function(player)
    if player.UserId == ADMIN_USER_ID then
        events.GetMessageHistory:FireClient(player, messageHistory)
    end
end)
```

### **2. Auto-Response**
```lua
-- Server script
local function sendAutoResponse(player, message)
    if string.find(message:lower(), "help") then
        -- Send help response
    end
end
```

### **3. Priority System**
```lua
-- Client script
local PRIORITY_LEVELS = {
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3,
    URGENT = 4
}
```

---

## 📱 **MOBILE SUPPORT**

### **Touch Controls**
- **Tap** toggle button untuk buka menu
- **Tap** send buttons untuk kirim
- **Tap** close button untuk tutup

### **Mobile Optimization**
- **Larger buttons** untuk touch
- **Responsive design**
- **Touch-friendly** input

---

## 🎯 **QUICK START GUIDE**

### **1. Setup (5 menit)**
1. **Buat Discord webhook**
2. **Copy webhook URL**
3. **Dapat User ID admin**
4. **Paste di script**

### **2. Install (2 menit)**
1. **Paste client script** di LocalScript
2. **Paste server script** di ServerScript
3. **Save dan publish**

### **3. Test (1 menit)**
1. **Join game**
2. **Klik 📨 button**
3. **Tulis pesan**
4. **Kirim ke admin/Discord**

---

## 🔄 **UPDATE LOG**

### **v1.0 - Initial Release**
- ✅ Toggle menu di top center
- ✅ Discord webhook integration
- ✅ Admin notification system
- ✅ Message history tracking
- ✅ Auto-close functionality
- ✅ Character limit protection

---

## 📞 **SUPPORT**

Jika mengalami masalah:
1. **Check console** (F9) untuk error
2. **Verify** webhook URL dan admin ID
3. **Test** di game yang berbeda
4. **Check** Discord server permissions

---

## 🎉 **KESIMPULAN**

**Roblox Admin Message System** adalah solusi lengkap untuk komunikasi admin dengan fitur Discord webhook dan UI yang user-friendly. Sistem ini mudah diinstall, configure, dan digunakan.

**Ready to use!** 🚀

---

*Script dibuat dengan ❤️ untuk komunitas Roblox*