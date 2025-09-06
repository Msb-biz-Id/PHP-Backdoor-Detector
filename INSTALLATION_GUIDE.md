# MDPL UI System - Installation & Usage Guide

## 📱 Mobile-Optimized Roblox UI Control System

### 🚀 Features
- **Height Adjustment**: Slider control untuk mengatur tinggi UI (30-120px)
- **Position Control**: Reset posisi ke tengah atas layar
- **Mobile Optimized**: Otomatis detect dan optimize untuk mobile devices
- **Debouncing System**: Mencegah lag dan stuttering
- **Performance Levels**: Auto-adjust berdasarkan kemampuan device
- **Smooth Animations**: Tweening untuk transisi yang halus

---

## 📋 Cara Install

### Method 1: Executor (Recommended)
1. **Download Script**: Copy script dari `MDPL_UI_System.lua`
2. **Buka Executor**: 
   - Synapse X
   - KRNL
   - Script-Ware
   - Fluxus
3. **Paste Script**: Masukkan script ke executor
4. **Execute**: Tekan Execute/Run
5. **Done**: UI akan muncul di layar

### Method 2: Bookmarklet (Browser)
1. **Buka Roblox**: Login ke game yang diinginkan
2. **F12**: Buka Developer Console
3. **Paste Script**: Copy-paste script ke console
4. **Enter**: Tekan Enter untuk execute

### Method 3: Mobile Executor
1. **Download Mobile Executor**:
   - Arceus X (Android)
   - Script-Ware Mobile
   - Delta (iOS)
2. **Load Script**: Import file script
3. **Execute**: Run script di game

---

## 🎮 Controls & Usage

### Keyboard Shortcuts
- **F1**: Toggle UI (Show/Hide)
- **F2**: Reset Position ke tengah atas
- **↑ Arrow**: Tingkatkan tinggi UI
- **↓ Arrow**: Kurangi tinggi UI

### UI Controls
- **Slider**: Drag untuk fine-tune tinggi
- **Reset Button**: Kembalikan posisi ke tengah
- **Close Button (×)**: Hide UI (bisa di-show lagi dengan F1)

### Mobile Controls
- **Touch Slider**: Tap dan drag untuk adjust tinggi
- **Touch Buttons**: Tap untuk reset posisi
- **Auto-Scale**: UI otomatis menyesuaikan ukuran layar mobile

---

## ⚙️ Configuration

### Performance Levels
Script otomatis detect device dan set performance level:

- **HIGH**: Desktop dengan hardware bagus
- **MEDIUM**: Mobile modern
- **LOW**: Mobile lama atau device lemah

### Customization
Edit bagian `UI_CONFIG` untuk customize:

```lua
local UI_CONFIG = {
    base_height = 50,        -- Tinggi default
    min_height = 30,         -- Tinggi minimum
    max_height = 120,        -- Tinggi maximum
    height_step = 5,         -- Step untuk arrow keys
    center_x = 0.5,          -- Posisi X tengah (0.5 = center)
    top_y = 0.05,            -- Posisi Y dari atas (0.05 = 5%)
    tween_duration = 0.3,    -- Durasi animasi
    mobile_scale = 0.8,      -- Scale untuk mobile
}
```

---

## 🔧 Troubleshooting

### UI Tidak Muncul
1. **Check Console**: Lihat F9 console untuk error messages
2. **Re-execute**: Coba run script lagi
3. **Check Game**: Pastikan game allow custom UI
4. **Mobile Issue**: Restart game dan try lagi

### UI Terlalu Kecil/Besar di Mobile
1. **Auto-Detection**: Script otomatis detect mobile
2. **Manual Scale**: Edit `mobile_scale` di config
3. **Performance**: Script auto-adjust berdasarkan device

### Lag atau Stuttering
1. **Debouncing**: Script sudah include debouncing system
2. **Performance Level**: Script auto-detect dan adjust
3. **Update Throttle**: Script throttle updates untuk smooth performance

### UI Hilang
1. **F1**: Tekan F1 untuk toggle visibility
2. **Reset**: Tekan F2 untuk reset posisi
3. **Re-execute**: Run script lagi jika perlu

---

## 📊 Performance Tips

### Untuk Mobile
- Script otomatis optimize untuk mobile
- Menggunakan throttling untuk smooth performance
- Debouncing mencegah excessive updates
- Auto-scale berdasarkan device capability

### Untuk Desktop
- Full performance mode
- Smooth 60 FPS updates
- All animations enabled
- Full feature set

---

## 🛡️ Safety Features

### Stealth Loading
- Random delay sebelum start (1-3 detik)
- Minimal console output
- Clean UI design yang tidak mencurigakan

### Error Handling
- Graceful fallbacks untuk semua functions
- Auto-cleanup jika ada error
- Performance monitoring

### Memory Management
- Debouncing system mencegah memory leaks
- Auto-cleanup saat player leave
- Optimized object creation

---

## 📱 Mobile Compatibility

### Supported Devices
- **Android**: All versions (API 21+)
- **iOS**: iOS 10+
- **Tablets**: iPad, Android tablets
- **Low-end**: Auto-optimize untuk device lemah

### Performance Optimization
- **Touch Input**: Optimized untuk touch controls
- **Scale**: Auto-scale berdasarkan screen size
- **Throttling**: Reduced update frequency untuk mobile
- **Memory**: Minimal memory usage

---

## 🔄 Updates & Maintenance

### Auto-Update
Script include auto-cleanup dan performance monitoring.

### Manual Reset
```lua
-- Reset UI ke default
_G.MDPL_UI.resetPosition()
_G.MDPL_UI.adjustHeight(50)
```

### Cleanup
```lua
-- Hapus UI dan cleanup
_G.MDPL_UI.cleanup()
```

---

## 📞 Support

### Common Issues
1. **Script Error**: Check console (F9) untuk error details
2. **UI Not Showing**: Try F1 atau re-execute
3. **Mobile Issues**: Restart game dan try lagi
4. **Performance**: Script auto-optimize, tapi bisa manual adjust config

### Debug Mode
Enable debug mode dengan edit script:
```lua
-- Tambahkan di awal script
local DEBUG_MODE = true
```

---

## ⚠️ Disclaimer

- Script ini untuk educational purposes
- Gunakan dengan bijak dan sesuai ToS game
- Tidak bertanggung jawab atas konsekuensi penggunaan
- Test di private server dulu sebelum gunakan di public

---

## 📝 Changelog

### v1.0.0
- Initial release
- Mobile optimization
- Debouncing system
- Performance levels
- Smooth animations
- Touch controls
- Keyboard shortcuts