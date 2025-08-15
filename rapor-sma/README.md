# Rapor SMA Kurikulum Merdeka (PHP MVC)

Teknologi: PHP 8, SQLite (PDO), AdminLTE 3, MVC sederhana.

## Menjalankan dengan Docker

1. Pastikan Docker & docker-compose terpasang
2. Jalankan:

```bash
docker compose up --build
```

Akses aplikasi di `http://localhost:8080`.

- Login demo:
  - Admin: `admin@demo.com` / `admin123`
  - Guru: `guru@demo.com` / `guru123`
  - Siswa: `siswa@demo.com` / `siswa123`

Database SQLite otomatis dibuat di `database/app.sqlite` pada run pertama.

## Struktur Direktori

- `public/` front controller (`index.php`), assets, `.htaccess`
- `app/Core/` core (`Router`, `Controller`, `Database`, `Auth`)
- `app/Controllers/` controller untuk `Admin`, `Teacher`, `Student`
- `app/Models/` model (contoh: `User`)
- `app/Views/` layout dan view AdminLTE
- `database/schema.sql` skema basis data

## Fitur Utama

- Role: Admin, Guru, Siswa
- Admin: dashboard, daftar pengguna/siswa/guru/kelas/mapel/tahun ajaran/penugasan
- Guru: dashboard, kelola penilaian (buat assessment), input nilai
- Siswa: dashboard, lihat nilai dan rapor (agregat berbobot per mapel di tahun aktif)

## Catatan

- Untuk produksi, tambahkan validasi, CSRF token, dan hardening keamanan.
- Pastikan folder `database/` writable oleh container.