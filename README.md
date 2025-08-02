# Professional PHP Backdoor Scanner

## Pendahuluan

**Professional PHP Backdoor Scanner** adalah alat audit keamanan yang dirancang khusus untuk mendeteksi dan mengidentifikasi *backdoor*, *webshell*, serta kode-kode mencurigakan lainnya yang sering disisipkan ke dalam aplikasi PHP. Dengan arsitektur berbasis signatur yang kuat dan antarmuka yang intuitif, alat ini menjadi aset tak ternilai bagi auditor keamanan, pengembang, dan administrator sistem dalam menjaga integritas dan keamanan aplikasi web berbasis PHP.

Ancaman siber terus berevolusi, dan *backdoor* seringkali menjadi pintu masuk utama bagi penyerang untuk mempertahankan akses persisten ke server Anda. Alat ini membantu mengidentifikasi keberadaan anomali kode, termasuk teknik obfuscasi canggih, perintah eksekusi shell yang disalahgunakan, dan indikator aktivitas jahat lainnya yang mungkin terlewat oleh tinjauan manual.

## Fitur Utama

* **Pemindaian Berbasis Signatur Canggih:** Menggunakan database signatur JSON yang ekstensif dan dapat diperbarui, dirancang untuk mendeteksi berbagai jenis pola kode berbahaya, termasuk:
    * Teknik obfuscasi (`base64_decode`, `gzinflate`, `str_rot13`, `eval`).
    * Fungsi eksekusi perintah sistem (`system()`, `exec()`, `passthru()`, `shell_exec()`, `popen()`).
    * Mekanisme unggah *webshell* (`copy($_FILES)`, `move_uploaded_file`).
    * Indikator *webshell* umum (`c99`, `r57`, `PhpSpy`).
    * Pola terkait injeksi konten SEO *blackhat* atau *defacement* (nama merek judi online, kata kunci *gacor*, *maxwin*).
    * Deteksi pola kompleks di seluruh baris kode.
* **Identifikasi Lokasi Kode Akurat:** Menyediakan *file path* lengkap, **nomor baris awal**, dan **nomor baris akhir** dari setiap temuan yang cocok, mempercepat proses investigasi manual.
* **Konteks Kode Interaktif:** Menyajikan cuplikan kode di sekitar temuan (beberapa baris sebelum dan sesudah), dengan bagian yang cocok **disorot** untuk memudahkan analisis kontekstual.
* **Klasifikasi Tingkat Keparahan (Severity):** Setiap temuan diklasifikasikan ke dalam tingkat keparahan (CRITICAL, HIGH, MEDIUM, LOW), memungkinkan Anda memprioritaskan mitigasi ancaman secara efektif.
* **Antarmuka Pengguna Responsif & Estetis:**
    * Desain UI yang modern dengan nuansa "hacker profesional" (tema gelap, teks hijau neon/biru cyber, efek *glow*).
    * **Tabel hasil yang responsif** dengan tata letak *card* pada perangkat seluler, memastikan keterbacaan optimal tanpa *horizontal scrolling*.
    * Animasi *background* efek hujan matriks (*Matrix rain effect*) untuk pengalaman visual yang imersif.
* **Filter Temuan Interaktif:** Saring hasil pemindaian secara *real-time* berdasarkan tingkat keparahan, memungkinkan Anda untuk fokus pada ancaman paling mendesak.
* **Ekspor Laporan Audit:** Kemampuan untuk mengekspor semua temuan ke dalam file CSV (*Comma Separated Values*), yang dapat dengan mudah diimpor dan dianalisis di *spreadsheet software* seperti Microsoft Excel atau Google Sheets.
* **Laporan dalam Bahasa Indonesia:** Deskripsi dan saran remediasi untuk setiap signatur disajikan dalam Bahasa Indonesia untuk kemudahan pemahaman.

## Memulai

### Prasyarat

* **Server Web:** Apache, Nginx, LiteSpeed, atau server web lain yang mendukung PHP.
* **PHP:** Versi 7.4 atau lebih tinggi (direkomendasikan PHP 8.x+ untuk performa dan keamanan terbaik).
    * Ekstensi PHP `json` harus diaktifkan (umumnya aktif secara *default*).
    * Ekstensi PHP `gd` mungkin diperlukan untuk beberapa efek visual di masa depan (tidak wajib untuk fitur saat ini).
* **Akses File:** Skrip memerlukan izin baca yang memadai ke file dan direktori yang akan dipindai.

### Instalasi Cepat

1.  **Unduh File:**
    * Kloning repositori ini atau unduh file `Backdoor_scanner.php` dan `signatures.json` secara manual.
2.  **Tempatkan di Server:**
    * Unggah kedua file (`Backdoor_scanner.php` dan `signatures.json`) ke direktori *web root* atau direktori lain yang ingin Anda pindai di server PHP Anda (misalnya, `/public_html/` atau `htdocs/`).
    * **Sangat direkomendasikan untuk menempatkan *scanner* di lokasi yang tidak mudah diakses publik atau melindunginya dengan otentikasi HTTP dasar.** Hapus skrip ini dari server setelah selesai digunakan untuk mengurangi risiko keamanan.
3.  **Konfigurasi (Opsional):**
    * Buka `Backdoor_scanner.php` menggunakan editor teks.
    * Pada baris sekitar **~20**, Anda dapat menyesuaikan variabel `$scan_root` untuk menentukan direktori utama yang akan dipindai. Secara *default*, `$scan_root` diatur ke direktori di mana skrip `Backdoor_scanner.php` berada (`__DIR__`).
        ```php
        $scan_root = __DIR__; // Pindai direktori tempat skrip berada
        // Atau untuk memindai seluruh web root:
        // $scan_root = $_SERVER['DOCUMENT_ROOT'];
        // Atau untuk direktori spesifik:
        // $scan_root = '/path/to/your/website/files';
        ```
    * Periksa juga variabel `$signature_db_path` (sekitar baris 23) untuk memastikan path ke `signatures.json` sudah benar jika Anda menempatkannya di lokasi lain.

## Cara Penggunaan

1.  **Akses Scanner:** Buka *browser* web Anda dan navigasikan ke URL `Backdoor_scanner.php` di server Anda (misalnya, `https://yourdomain.com/Backdoor_scanner.php`).
2.  **Mulai Pemindaian:** Skrip akan secara otomatis memulai pemindaian saat halaman dimuat.
3.  **Menganalisis Hasil:**
    * Tabel hasil akan menampilkan daftar file yang cocok dengan signatur.
    * Perhatikan **tingkat keparahan**, **lokasi file**, dan **konteks kode** untuk memahami potensi ancaman.
    * Gunakan *dropdown* **"Filter Keparahan"** di bagian atas tabel untuk menyaring temuan berdasarkan tingkat risikonya.
4.  **Ekspor Laporan:**
    * Klik tombol **"Ekspor ke CSV"** untuk mengunduh laporan lengkap dari semua temuan ke komputer Anda. Ini sangat berguna untuk dokumentasi audit dan analisis *offline*.

## Signatur Kustom

Alat ini menggunakan file `signatures.json` eksternal sebagai database signaturnya. Anda dapat dengan mudah mengedit atau menambahkan signatur Anda sendiri untuk mendeteksi pola kode tertentu.

**Struktur `signatures.json`:**

```json
{
  "signatures": [
    {
      "id": "UNIQUE_SIGNATURE_ID",
      "name": "Nama Signatur Yang Mudah Dipahami",
      "severity": "CRITICAL", // atau "HIGH", "MEDIUM", "LOW"
      "patterns": [
        "regex_pattern_1",
        "regex_pattern_2" // Daftar pola regex (case-insensitive)
      ],
      "description": "Deskripsi singkat dalam Bahasa Inggris.",
      "description_id": "Deskripsi singkat dalam Bahasa Indonesia.",
      "remediation": "Saran remediasi dalam Bahasa Inggris.",
      "remediation_id": "Saran remediasi dalam Bahasa Indonesia."
    }
    // ... signatur lainnya
  ]
}
