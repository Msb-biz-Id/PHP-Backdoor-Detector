# Lucky Draw - PHP Native + MySQL

Aplikasi undian sederhana sesuai ketentuan:
- Menampilkan daftar karyawan (yang belum menang) dan melakukan scroll cepat, berhenti random minimal 5 detik, menyorot pemenang.
- Menyimpan pemenang ke database dan menghapusnya dari daftar kandidat.
- Mengambil hadiah dari `gift` dengan nomor urut paling besar (descending), memastikan tidak double.

## Prasyarat
- PHP 8.0+ dengan ekstensi PDO MySQL
- MySQL 5.7+ / MariaDB 10.3+
- Server web (Apache/Nginx) atau `php -S` untuk development

## Konfigurasi
Ubah kredensial database di `config.php` atau gunakan environment variable:
- MYSQL_HOST (default: 127.0.0.1)
- MYSQL_DATABASE (default: lucky_draw_db)
- MYSQL_USER (default: root)
- MYSQL_PASSWORD (default: kosong)

## Instalasi Database
1. Buat database terlebih dahulu di MySQL:
   ```sql
   CREATE DATABASE lucky_draw_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
2. Jalankan `setup.php` untuk membuat tabel dan seed 20 hadiah:
   - Via CLI: `php setup.php`
   - Atau via browser: buka `http://host/lucky-draw/setup.php`
3. Isi data karyawan pada tabel `karyawan` (contoh):
   ```sql
   INSERT INTO karyawan (nama) VALUES ('Andi'), ('Budi'), ('Citra'), ('Dewi');
   ```

## Menjalankan Aplikasi
- Pastikan direktori `lucky-draw/` dapat diakses oleh web server.
- Akses `index.php` di browser.
- Tombol "Mulai" akan melakukan pengundian, menghentikan scroll secara acak setelah minimal 5 detik, dan menyimpan pemenang beserta hadiah.

## Tabel
- `karyawan(id, nama)` – daftar karyawan (unik per nama disarankan)
- `gift(id, urut, nama_hadiah, is_assigned)` – 20 hadiah, diambil dari `urut` terbesar
- `winners(id, karyawan_id, gift_id, created_at)` – pemenang, `karyawan_id` unik (tidak bisa double), `gift_id` unik

## Catatan
- Endpoint API:
  - `api/get_candidates.php` – daftar kandidat + sisa hadiah
  - `api/draw.php` – simpan pemenang dan ambil hadiah `urut` terbesar (transaksional)
- Frontend akan menghapus pemenang dari daftar kandidat setelah sukses simpan.