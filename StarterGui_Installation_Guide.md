# StarterGui Position UI - Installation Guide

## 📱 UI Otomatis Muncul untuk Semua Player

### 🚀 Fitur Utama
- **Auto-Loading**: UI otomatis muncul saat player join
- **Real-time Tracking**: Posisi dan ketinggian semua player
- **Mobile Optimized**: Otomatis detect dan optimize untuk mobile
- **Performance Optimized**: Debouncing dan throttling untuk smooth performance
- **Keyboard Shortcuts**: F1 untuk toggle, F2 untuk reset posisi

---

## 📋 Cara Install

### Method 1: StarterGui (Recommended)
1. **Buka Studio**: Buka Roblox Studio
2. **StarterGui**: Buka StarterGui di Explorer
3. **Create Script**: Klik kanan → Insert Object → Script
4. **Paste Code**: Copy script dari `StarterGui_Position_UI.lua`
5. **Publish**: Publish ke game
6. **Test**: Join game, UI akan muncul otomatis

### Method 2: StarterPlayerScripts
1. **Buka Studio**: Buka Roblox Studio
2. **StarterPlayer**: Buka StarterPlayer → StarterPlayerScripts
3. **Create Script**: Klik kanan → Insert Object → Script
4. **Paste Code**: Copy script dari `StarterGui_Position_UI.lua`
5. **Publish**: Publish ke game

### Method 3: LocalScript di StarterGui
1. **Buka Studio**: Buka Roblox Studio
2. **StarterGui**: Buka StarterGui
3. **Create LocalScript**: Klik kanan → Insert Object → LocalScript
4. **Paste Code**: Copy script dari `StarterGui_Position_UI.lua`
5. **Publish**: Publish ke game

---

## ⚙️ Konfigurasi

### Basic Settings
```lua
local CONFIG = {
    -- UI Settings
    ui_width = IS_MOBILE and 250 or 300,        -- Lebar UI
    ui_height = IS_MOBILE and 350 or 400,       -- Tinggi UI
    max_players_display = IS_MOBILE and 6 or 8, -- Max player
    update_interval = PERFORMANCE_LEVEL == "LOW" and 0.2 or 0.15,
    
    -- Position Settings
    ui_position = UDim2.new(0, 10, 0, 10),      -- Posisi UI
    background_color = Color3.fromRGB(20, 20, 20),
    text_color = Color3.fromRGB(255, 255, 255),
    accent_color = Color3.fromRGB(0, 150, 255),
    
    -- Mobile optimizations
    mobile_scale = 0.85,
    font_size_small = IS_MOBILE and 9 or 10,
    font_size_medium = IS_MOBILE and 10 or 11,
    font_size_large = IS_MOBILE and 11 or 12,
}
```

### Performance Levels
Script otomatis detect device dan set performance level:

- **HIGH**: Desktop dengan hardware bagus
- **MEDIUM**: Mobile modern
- **LOW**: Mobile lama atau device lemah

---

## 🎮 Cara Penggunaan

### UI Controls
- **Toggle Button (−/+)**: Minimize/maximize UI
- **Drag**: Drag UI untuk pindah posisi
- **Scroll**: Scroll untuk melihat semua player
- **Auto-Update**: Data update otomatis

### Keyboard Shortcuts
- **F1**: Toggle UI visibility (Show/Hide)
- **F2**: Reset posisi UI ke default
- **Drag**: Drag UI untuk pindah posisi

### Data yang Ditampilkan
- **Player Name**: Nama dan display name
- **Position**: Koordinat X, Y, Z (real-time)
- **Height**: Ketinggian dengan warna hijau highlight
- **Speed**: Kecepatan pergerakan dengan warna kuning

### Sorting
- Player diurutkan berdasarkan **ketinggian** (tertinggi ke terendah)
- Update otomatis saat player bergerak

---

## 📱 Mobile Optimization

### Auto-Detection
Script otomatis detect mobile devices dan menyesuaikan:
- Ukuran UI lebih kecil (250x350 vs 300x400)
- Font size lebih kecil
- Max player display lebih sedikit (6 vs 8)
- Update interval lebih lambat (0.2s vs 0.15s)

### Mobile Features
- **Responsive Design**: UI menyesuaikan ukuran layar
- **Touch Controls**: Button yang mudah di-touch
- **Performance Scaling**: Auto-adjust berdasarkan device capability
- **Smooth Scrolling**: Optimized untuk touch scrolling

---

## ⚡ Performance Optimization

### Built-in Optimizations
- **Debouncing System**: Mencegah excessive function calls
- **Update Throttling**: Limit update frequency berdasarkan device
- **Memory Management**: Auto-cleanup saat player leave
- **Efficient Rendering**: Hanya update yang berubah

### Performance Levels
- **HIGH**: Desktop - Update setiap 0.15s, 8 players
- **MEDIUM**: Mobile modern - Update setiap 0.15s, 6 players
- **LOW**: Mobile lama - Update setiap 0.2s, 6 players

---

## 🔧 Troubleshooting

### UI Tidak Muncul
1. **Check StarterGui**: Pastikan script di StarterGui
2. **Check Console**: Lihat F9 console untuk error
3. **Check Script**: Pastikan script tidak error
4. **Restart**: Restart game dan coba lagi

### UI Muncul Tapi Kosong
1. **Wait**: Tunggu beberapa detik untuk data load
2. **Check Players**: Pastikan ada player lain di game
3. **Check Character**: Pastikan player punya character
4. **Check Console**: Lihat error di console

### Performance Issues
1. **Mobile**: Script otomatis optimize untuk mobile
2. **Reduce Players**: Kurangi `max_players_display`
3. **Increase Interval**: Tingkatkan `update_interval`
4. **Check Device**: Pastikan device support

### Mobile Issues
1. **Auto-Detection**: Script otomatis detect mobile
2. **Restart**: Restart game dan coba lagi
3. **Check Touch**: Pastikan touch controls work
4. **Check Size**: UI otomatis menyesuaikan ukuran

---

## 📊 Monitoring & Debug

### Console Output
Script akan print status ke console:
```
[StarterGui Position UI] Initializing...
[StarterGui Position UI] Device: Mobile
[StarterGui Position UI] Performance Level: MEDIUM
[StarterGui Position UI] System initialized successfully!
```

### Debug Commands
```lua
-- Toggle UI visibility
_G.StarterGuiPositionUI.toggleVisibility()

-- Force update
_G.StarterGuiPositionUI.updateUI()

-- Get player data
_G.StarterGuiPositionUI.getPlayerData(Players.LocalPlayer)

-- Get config
print(_G.StarterGuiPositionUI.config)
```

---

## 🛡️ Safety & Security

### Client-Side Safety
- Script berjalan di client, aman dari server exploit
- Data real-time dari client, tidak bisa di-manipulasi server
- Auto-cleanup saat player leave

### Error Handling
- Graceful fallbacks untuk semua functions
- Auto-recovery dari errors
- Memory leak prevention

---

## 🔄 Updates & Maintenance

### Auto-Loading
Script include auto-loading:
- UI muncul otomatis saat player join
- Data update otomatis
- Auto-cleanup saat player leave

### Manual Controls
```lua
-- Toggle visibility
_G.StarterGuiPositionUI.toggleVisibility()

-- Force update
_G.StarterGuiPositionUI.updateUI()

-- Cleanup
_G.StarterGuiPositionUI.cleanup()
```

---

## 📝 Customization Examples

### Custom Colors
```lua
CONFIG.background_color = Color3.fromRGB(30, 30, 30)  -- Darker background
CONFIG.accent_color = Color3.fromRGB(255, 100, 0)     -- Orange accent
CONFIG.text_color = Color3.fromRGB(200, 200, 200)     -- Gray text
```

### Custom Position
```lua
-- Top right corner
CONFIG.ui_position = UDim2.new(1, -310, 0, 10)

-- Bottom left corner
CONFIG.ui_position = UDim2.new(0, 10, 1, -410)

-- Center screen
CONFIG.ui_position = UDim2.new(0.5, -150, 0.5, -200)
```

### Custom Size
```lua
-- Larger UI
CONFIG.ui_width = 350
CONFIG.ui_height = 450
CONFIG.max_players_display = 10

-- Smaller UI
CONFIG.ui_width = 200
CONFIG.ui_height = 250
CONFIG.max_players_display = 4
```

---

## ⚠️ Important Notes

### StarterGui Requirements
- Script harus di StarterGui atau StarterPlayerScripts
- Perlu permission untuk create UI
- Perlu access ke Players service

### Performance Considerations
- Jangan set `max_players_display` terlalu tinggi
- Adjust `update_interval` berdasarkan kebutuhan
- Monitor memory usage di client

### Compatibility
- Compatible dengan semua Roblox games
- Works di Studio dan Live servers
- Mobile dan Desktop support

---

## 📞 Support

### Common Issues
1. **UI Not Showing**: Pastikan script di StarterGui
2. **Empty UI**: Tunggu beberapa detik untuk data load
3. **Performance**: Script auto-optimize, restart jika perlu
4. **Mobile**: Script auto-detect, restart jika perlu

### Debug Steps
1. **Check Console**: Lihat F9 console untuk error
2. **Check Script**: Pastikan script tidak error
3. **Check Position**: Pastikan UI tidak di luar layar
4. **Check Players**: Pastikan ada player lain di game

---

## 📈 Changelog

### v1.0.0 (StarterGui)
- Auto-loading UI untuk semua player
- Mobile optimization
- Performance levels
- Keyboard shortcuts
- Real-time tracking
- Debouncing system