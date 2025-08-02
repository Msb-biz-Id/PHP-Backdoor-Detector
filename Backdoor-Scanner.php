<?php
// Set timezone ke Asia/Jakarta
putenv("TZ=Asia/Jakarta");

// Pengaturan PHP untuk lingkungan audit/debugging
// display_errors diaktifkan untuk memudahkan debugging jika ada masalah pada scanner itu sendiri
// error_reporting diatur ke E_ALL untuk menangkap semua jenis error, warning, dan notices
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Pengaturan eksekusi skrip untuk pemindaian besar
// set_time_limit(0) menghilangkan batas waktu eksekusi
// memory_limit '1024M' mengalokasikan memori hingga 1GB, dapat disesuaikan jika diperlukan
set_time_limit(0);
ini_set('memory_limit', '1024M');

// Direktori root yang akan dipindai.
// __DIR__ adalah konstanta ajaib yang mengembalikan direktori file saat ini.
// Anda bisa mengubahnya ke $_SERVER['DOCUMENT_ROOT'] untuk memindai seluruh situs web,
// atau ke path spesifik lain seperti '/var/www/html'.
$scan_root = __DIR__;

// Lokasi database signatur backdoor dalam format JSON
$signature_db_path = 'signatures.json';

// Array global untuk menyimpan semua temuan backdoor
$findings = [];

// --- Fungsi-fungsi Pembantu ---

/**
 * Memuat database signatur dari file JSON.
 * Fungsi ini memastikan file ada dan dapat dibaca, serta format JSON valid.
 * @param string $path Path ke file JSON signatur.
 * @return array Array signatur yang dimuat.
 */
function loadSignatures($path) {
    if (!file_exists($path) || !is_readable($path)) {
        // Hentikan eksekusi dan tampilkan pesan error yang jelas jika file signatur tidak ditemukan
        die("<div class='container' style='color: #ff6b6b; text-align: center;'><strong>Error:</strong> Database signatur tidak ditemukan atau tidak dapat dibaca di " . htmlspecialchars($path) . ".<br>Pastikan 'signatures.json' berada di direktori yang sama dengan skrip scanner ini.</div></body></html>");
    }
    $json_content = file_get_contents($path);
    $data = json_decode($json_content, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        // Hentikan eksekusi dan tampilkan pesan error yang jelas jika format JSON tidak valid
        die("<div class='container' style='color: #ff6b6b; text-align: center;'><strong>Error:</strong> JSON tidak valid di database signatur: " . json_last_error_msg() . "</div></body></html>");
    }
    return $data['signatures'] ?? []; // Mengembalikan array signatur, atau array kosong jika tidak ada
}

/**
 * Mendapatkan daftar semua file PHP dalam direktori yang diberikan secara rekursif.
 * Fungsi ini mengabaikan direktori dan ekstensi file yang umum tidak relevan
 * untuk mengurangi waktu pemindaian dan false positives.
 * @param string $dir Direktori yang akan dipindai.
 * @param array $files Array referensi untuk menyimpan daftar file.
 * @return array Daftar path file PHP lengkap.
 */
function getAllPhpFiles($dir, &$files = []) {
    $ignored_dirs = ['.', '..', '.git', '.svn', 'vendor', 'node_modules', 'cache', 'logs', 'temp', 'tmp'];
    $ignored_extensions = ['jpg', 'png', 'gif', 'css', 'js', 'html', 'txt', 'xml', 'md', 'json', 'sql', 'log'];

    if (!is_dir($dir)) {
        error_log("Warning: Direktori tidak ditemukan atau tidak dapat dibaca: " . $dir);
        return [];
    }

    $items = scandir($dir);
    if ($items === false) {
        error_log("Warning: Gagal membaca isi direktori: " . $dir);
        return [];
    }

    foreach ($items as $item) {
        if (in_array($item, $ignored_dirs)) {
            continue; // Lewati direktori yang diabaikan
        }

        $path = rtrim($dir, '/') . '/' . $item;
        if (is_dir($path)) {
            getAllPhpFiles($path, $files); // Panggil fungsi secara rekursif untuk subdirektori
        } else {
            $extension = pathinfo($path, PATHINFO_EXTENSION);
            // Hanya tambahkan file dengan ekstensi .php dan bukan yang ada di daftar ekstensi diabaikan
            if (strtolower($extension) === 'php' && !in_array(strtolower($extension), $ignored_extensions)) {
                $files[] = $path;
            }
        }
    }
    return $files;
}

/**
 * Memindai satu file untuk mencari pola signatur backdoor.
 * Mengidentifikasi nomor baris awal dan akhir dari kecocokan, serta konteks kode di sekitarnya.
 * @param string $filePath Path lengkap ke file yang akan dipindai.
 * @param array $signatures Array signatur yang dimuat dari database.
 */
function scanFile($filePath, $signatures) {
    global $findings; // Mengakses variabel global $findings untuk menyimpan temuan

    if (!is_readable($filePath)) {
        error_log("Warning: File tidak dapat dibaca, dilewati: " . $filePath);
        return;
    }

    $content = file_get_contents($filePath);
    if ($content === false) {
        error_log("Warning: Gagal mendapatkan konten file, dilewati: " . $filePath);
        return;
    }

    // Pisahkan konten file menjadi baris-baris untuk penentuan nomor baris yang akurat
    $lines = explode("\n", $content);
    $lowerContent = strtolower($content); // Konten dalam huruf kecil untuk pencarian case-insensitive

    // Iterasi setiap signatur yang dimuat
    foreach ($signatures as $signature) {
        // Pastikan signatur memiliki kunci yang diperlukan
        if (!isset($signature['id']) || !isset($signature['name']) || !isset($signature['severity']) || !isset($signature['patterns'])) {
            error_log("Warning: Signatur tidak lengkap, dilewati: " . json_encode($signature));
            continue;
        }

        foreach ($signature['patterns'] as $pattern) {
            // Gunakan preg_match_all untuk menemukan semua kecocokan dalam file
            if (@preg_match_all('/' . $pattern . '/i', $lowerContent, $matches, PREG_OFFSET_CAPTURE | PREG_PATTERN_ORDER)) {
                foreach ($matches[0] as $match) {
                    $matched_text = $match[0]; // Teks yang cocok dengan pola
                    $offset_start = $match[1]; // Posisi awal teks yang cocok
                    $offset_end = $offset_start + strlen($matched_text);

                    // --- Menentukan Nomor Baris Awal dan Akhir ---
                    $start_line = 1;
                    $end_line = 1;
                    $current_char_offset = 0;

                    for ($ln = 0; $ln < count($lines); $ln++) {
                        $line_length = strlen($lines[$ln]) + 1; // Panjang baris +1 untuk newline

                        if ($current_char_offset + $line_length > $offset_start && $start_line == 1) {
                            $start_line = $ln + 1;
                        }
                        if ($current_char_offset + $line_length >= $offset_end) {
                            $end_line = $ln + 1;
                            break;
                        }
                        $current_char_offset += $line_length;
                        if ($ln + 1 == count($lines) && $start_line <= $ln + 1) {
                             $end_line = $ln + 1;
                        }
                    }

                    // --- Mendapatkan Konteks Kode di Sekitar Temuan ---
                    $context_lines_before_index = max(0, $start_line - 1 - 2); // 2 baris sebelum start_line
                    $context_lines_after_index = min(count($lines), $end_line + 2); // 2 baris setelah end_line

                    $context_array = array_slice($lines, $context_lines_before_index, ($context_lines_after_index - $context_lines_before_index));
                    $context = implode("\n", $context_array);

                    // Tambahkan temuan ke array $findings global
                    $findings[] = [
                        'file' => $filePath,
                        'signature_id' => $signature['id'],
                        'signature_name' => $signature['name'],
                        'severity' => $signature['severity'],
                        'matched_pattern' => $pattern,
                        'matched_text' => $matched_text,
                        'start_line' => $start_line,
                        'end_line' => $end_line,
                        'context' => htmlspecialchars($context),
                        // Menggunakan operator null coalescing (??) untuk fallback ke versi Inggris jika _id tidak ada
                        'description' => $signature['description_id'] ?? $signature['description'] ?? 'No description available.',
                        'remediation' => $signature['remediation_id'] ?? $signature['remediation'] ?? 'No remediation steps provided.'
                    ];
                }
            }
        }
    }
}

// --- Logika Ekspor CSV ---
if (isset($_GET['export']) && $_GET['export'] == 'csv') {
    $allSignatures = loadSignatures($signature_db_path);
    $phpFilesToScan = getAllPhpFiles($scan_root);

    foreach ($phpFilesToScan as $file) {
        if ($file === $_SERVER['SCRIPT_FILENAME']) {
            continue;
        }
        scanFile($file, $allSignatures);
    }

    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="laporan_scan_backdoor_' . date('Ymd_His') . '.csv"');
    header('Pragma: no-cache');
    header('Expires: 0');

    $output = fopen('php://output', 'w');

    fputcsv($output, [
        'Lokasi File',
        'ID Signatur',
        'Nama Signatur',
        'Tingkat Keparahan',
        'Pola Cocok',
        'Teks yang Cocok',
        'Baris Awal',
        'Baris Akhir',
        'Deskripsi',
        'Remediasi'
    ]);

    foreach ($findings as $finding) {
        fputcsv($output, [
            $finding['file'],
            $finding['signature_id'],
            $finding['signature_name'],
            $finding['severity'],
            $finding['matched_pattern'],
            $finding['matched_text'],
            $finding['start_line'],
            $finding['end_line'],
            $finding['description'],
            $finding['remediation']
        ]);
    }
    fclose($output);
    exit();
}


// --- Proses Utama Pemindaian ---
$start_time = microtime(true);

$allSignatures = loadSignatures($signature_db_path);
$phpFilesToScan = getAllPhpFiles($scan_root);

$filter_severity = isset($_GET['severity']) ? strtoupper($_GET['severity']) : 'ALL';

foreach ($phpFilesToScan as $file) {
    if ($file === $_SERVER['SCRIPT_FILENAME']) {
        continue;
    }
    scanFile($file, $allSignatures);
}

$end_time = microtime(true);
$scan_duration = round($end_time - $start_time, 2);

$filtered_findings = [];
if ($filter_severity === 'ALL') {
    $filtered_findings = $findings;
} else {
    foreach ($findings as $finding) {
        if (strtoupper($finding['severity']) === $filter_severity) {
            $filtered_findings[] = $finding;
        }
    }
}

$severity_order = ['CRITICAL' => 4, 'HIGH' => 3, 'MEDIUM' => 2, 'LOW' => 1];
usort($filtered_findings, function($a, $b) use ($severity_order) {
    $a_severity = $severity_order[strtoupper($a['severity'])] ?? 0;
    $b_severity = $severity_order[strtoupper($b['severity'])] ?? 0;
    return $b_severity <=> $a_severity;
});

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Professional Backdoor Scanner</title>
    <style>
        /* CSS Umum */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #1a1a2e; /* Warna latar belakang utama */
            color: #00ff00; /* Warna teks hijau neon */
            margin: 0;
            padding: 20px;
            line-height: 1.6;
            overflow-x: hidden; /* Mencegah scroll horizontal body */
            position: relative; /* Diperlukan untuk background canvas */
            min-height: 100vh; /* Pastikan body setidaknya setinggi viewport */
        }
        body::before { /* Efek overlay untuk background */
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5); /* Semi-transparan agar animasi terlihat */
            z-index: -1;
        }
        canvas {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -2; /* Di bawah body content */
        }

        .container {
            max-width: 1200px;
            margin: 20px auto;
            background-color: rgba(42, 42, 74, 0.9); /* Latar belakang semi-transparan */
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0, 255, 0, 0.3); /* Cahaya hijau */
            position: relative;
            z-index: 1; /* Pastikan konten di atas background */
        }
        h1 {
            color: #00ff00; /* Hijau neon */
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #00ff00; /* Border hijau neon */
            padding-bottom: 15px;
            text-shadow: 0 0 10px #00ff00; /* Efek neon */
        }
        .info-box {
            background-color: rgba(62, 62, 107, 0.7); /* Lebih gelap, semi-transparan */
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 5px solid #00ff00; /* Border hijau neon */
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
        }
        .info-box div {
            flex: 1;
            min-width: 250px;
            margin-right: 20px;
        }
        .info-box p {
            margin: 5px 0;
            font-size: 0.95em;
            color: #00ee00; /* Teks hijau sedikit lebih terang */
        }
        .info-box b {
            color: #ffffff; /* Putih untuk teks bold */
        }

        /* Gaya Tabel */
        .results-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 30px;
            font-size: 0.9em;
            color: #00ff00; /* Teks tabel hijau neon */
        }
        .results-table th, .results-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #00aa00; /* Border hijau gelap */
            vertical-align: top;
        }
        .results-table th {
            background-color: rgba(0, 100, 0, 0.8); /* Header tabel hijau gelap */
            color: #ffffff; /* Teks header putih */
            text-transform: uppercase;
            font-size: 0.9em;
            text-shadow: 0 0 5px rgba(0, 255, 0, 0.5);
        }
        .results-table tbody tr:nth-child(even) {
            background-color: rgba(51, 51, 85, 0.7); /* Baris genap sedikit berbeda, semi-transparan */
        }
        .results-table tbody tr:hover {
            background-color: rgba(0, 200, 0, 0.3); /* Hover hijau transparan */
            cursor: pointer;
        }

        /* Pewarnaan Tingkat Keparahan */
        .severity-CRITICAL { color: #ff0000; font-weight: bold; text-shadow: 0 0 5px #ff0000; } /* Merah */
        .severity-HIGH { color: #ffaa00; font-weight: bold; text-shadow: 0 0 5px #ffaa00; } /* Oranye */
        .severity-MEDIUM { color: #00ffff; font-weight: bold; text-shadow: 0 0 5px #00ffff; } /* Cyan */
        .severity-LOW { color: #88ff88; font-weight: bold; } /* Hijau Muda */

        /* Pesan Jika Tidak Ada Temuan */
        .no-findings {
            text-align: center;
            color: #00ff00;
            font-size: 1.3em;
            padding: 30px;
            background-color: rgba(0, 100, 0, 0.7);
            border-radius: 8px;
            margin-top: 30px;
            text-shadow: 0 0 5px rgba(0, 255, 0, 0.5);
        }

        /* Konteks Kode */
        .code-context {
            background-color: rgba(0, 0, 0, 0.7); /* Background hitam transparan */
            padding: 10px;
            border-radius: 5px;
            font-family: 'Consolas', 'Monaco', monospace;
            white-space: pre-wrap;
            word-break: break-all;
            font-size: 0.85em;
            margin-top: 8px;
            border: 1px solid #00ff00; /* Border hijau neon */
            overflow-x: auto;
            max-height: 180px;
            overflow-y: auto;
            color: #00ff00; /* Teks kode hijau neon */
        }
        .code-context strong {
            color: #ff0000; /* Merah untuk highlight */
            background-color: rgba(255, 0, 0, 0.3); /* Background merah transparan */
            padding: 0 3px;
            border-radius: 2px;
            text-shadow: none; /* Hapus shadow di sini agar tidak terlalu ramai */
        }

        /* Footer */
        .footer {
            text-align: center;
            margin-top: 40px;
            font-size: 0.8em;
            color: #00cc00; /* Hijau gelap untuk footer */
        }
        .footer a {
            color: #00ffff; /* Biru cyber untuk link footer */
            text-decoration: none;
            text-shadow: 0 0 5px #00ffff;
        }
        .footer a:hover {
            text-decoration: underline;
            color: #00eeff;
        }

        /* Tombol Ekspor dan Filter */
        .actions {
            clear: both;
            overflow: auto;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
        }
        .export-button, .filter-select {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 5px;
            font-weight: bold;
            transition: background-color 0.3s ease, box-shadow 0.3s ease;
            margin-top: 10px;
            text-shadow: 0 0 5px rgba(0, 255, 0, 0.5);
        }
        .export-button {
            background-color: #00aa00; /* Hijau tombol */
            color: #ffffff; /* Teks putih */
            text-decoration: none;
            border: none;
            cursor: pointer;
            box-shadow: 0 0 10px rgba(0, 255, 0, 0.4);
        }
        .export-button:hover {
            background-color: #008800; /* Hijau lebih gelap saat hover */
            box-shadow: 0 0 15px rgba(0, 255, 0, 0.6);
        }

        .filter-group label {
            margin-right: 10px;
            font-weight: bold;
            color: #00ff00;
        }
        .filter-group select {
            padding: 8px 12px;
            border-radius: 5px;
            border: 1px solid #00ff00; /* Border hijau neon */
            background-color: rgba(62, 62, 107, 0.7); /* Background gelap transparan */
            color: #00ff00; /* Teks hijau neon */
            font-size: 0.9em;
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            background-image: url('data:image/svg+xml;utf8,<svg fill="%2300ff00" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/><path d="M0 0h24v24H0z" fill="none"/></svg>');
            background-repeat: no-repeat;
            background-position: right 8px center;
            background-size: 20px;
            cursor: pointer;
            min-width: 150px;
            box-shadow: 0 0 8px rgba(0, 255, 0, 0.3);
        }
        .filter-group select:hover {
            border-color: #00ffff;
        }
        .filter-group select:focus {
            outline: none;
            border-color: #00ffff;
            box-shadow: 0 0 0 2px rgba(0, 255, 255, 0.5);
        }

        /* --- CSS Responsif Tabel --- */
        @media screen and (max-width: 768px) {
            .container { padding: 15px; margin: 10px auto; }
            h1 { font-size: 1.8em; padding-bottom: 10px; margin-bottom: 20px; }
            .info-box { flex-direction: column; margin-right: 0; }
            .info-box div { margin-right: 0; margin-bottom: 10px; }
            .info-box p { font-size: 0.9em; }

            .results-table thead {
                border: none;
                clip: rect(0 0 0 0);
                height: 1px;
                margin: -1px;
                overflow: hidden;
                padding: 0;
                position: absolute;
                width: 1px;
            }

            .results-table tr {
                display: block;
                margin-bottom: 1.5em;
                border: 1px solid #00ff00;
                border-radius: 8px;
                background-color: rgba(42, 42, 74, 0.8);
                padding: 10px;
                box-shadow: 0 0 10px rgba(0, 255, 0, 0.2);
            }

            .results-table td {
                border-bottom: 1px solid #00aa00;
                display: flex;
                align-items: flex-start;
                padding: 8px 10px;
                text-align: left;
                position: relative;
            }

            .results-table td::before {
                content: attr(data-label) ": ";
                flex-basis: 120px;
                flex-shrink: 0;
                font-weight: bold;
                color: #00ffff;
                text-align: left;
                padding-right: 10px;
            }

            .results-table tr:last-child td {
                border-bottom: none;
            }

            .results-table td[data-label="Kode yang Cocok"] {
                flex-direction: column;
                padding: 8px 10px;
                text-align: left;
            }
            .results-table td[data-label="Kode yang Cocok"]::before {
                content: attr(data-label);
                width: auto;
                flex-basis: auto;
                margin-bottom: 5px;
            }

            .code-context {
                margin-top: 0;
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <canvas id="matrixCanvas"></canvas>
    <div class="container">
        <h1>Hasil Pemindaian Backdoor Profesional</h1>

        <div class="info-box">
            <div>
                <p><strong>Direktori Pemindaian Utama:</strong> <?= htmlspecialchars($scan_root) ?></p>
                <p><strong>File PHP Dipindai:</strong> <?= count($phpFilesToScan) ?></p>
            </div>
            <div>
                <p><strong>Total Temuan:</strong> <?= count($findings) ?></p>
                <p><strong>Durasi Pemindaian:</strong> <?= $scan_duration ?> detik</p>
            </div>
        </div>

        <?php if (!empty($findings) || $filter_severity !== 'ALL'): ?>
            <div class="actions">
                <div class="filter-group">
                    <label for="severityFilter">Filter Keparahan:</label>
                    <select id="severityFilter" onchange="window.location.href='?severity=' + this.value;">
                        <option value="ALL" <?= $filter_severity === 'ALL' ? 'selected' : '' ?>>Semua</option>
                        <option value="CRITICAL" <?= $filter_severity === 'CRITICAL' ? 'selected' : '' ?>>KRITIS</option>
                        <option value="HIGH" <?= $filter_severity === 'HIGH' ? 'selected' : '' ?>>TINGGI</option>
                        <option value="MEDIUM" <?= $filter_severity === 'MEDIUM' ? 'selected' : '' ?>>SEDANG</option>
                        <option value="LOW" <?= $filter_severity === 'LOW' ? 'selected' : '' ?>>RENDAH</option>
                    </select>
                </div>
                <a href="?export=csv" class="export-button">Ekspor ke CSV</a>
            </div>
        <?php endif; ?>

        <?php if (empty($filtered_findings)): ?>
            <div class="no-findings">
                <?php if ($filter_severity !== 'ALL'): ?>
                    <p>🎉 Tidak ada file yang sesuai dengan tingkat keparahan **<?= htmlspecialchars(strtoupper($filter_severity)) ?>** yang terdeteksi.</p>
                    <p>Coba pilih "Semua" pada filter untuk melihat semua temuan.</p>
                <?php else: ?>
                    <p>🎉 **Tidak ada file mencurigakan** yang terdeteksi berdasarkan signatur saat ini. Ini kabar baik!</p>
                    <p>💡 **Tips Audit:** Selalu pastikan database signatur Anda **diperbarui** dan lakukan pemindaian secara **rutin**.</p>
                <?php endif; ?>
            </div>
        <?php else: ?>
            <table class="results-table">
                <thead>
                    <tr>
                        <th>Lokasi File</th>
                        <th>Signatur</th>
                        <th>Keparahan</th>
                        <th>Baris</th>
                        <th>Kode yang Cocok</th>
                        <th>Deskripsi</th>
                        <th>Remediasi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($filtered_findings as $finding): ?>
                        <tr>
                            <td data-label="Lokasi File"><?= htmlspecialchars($finding['file']) ?></td>
                            <td data-label="Signatur">
                                <strong><?= htmlspecialchars($finding['signature_name']) ?></strong>
                                <br><small>ID: <?= htmlspecialchars($finding['signature_id']) ?></small>
                            </td>
                            <td data-label="Keparahan" class="severity-<?= strtoupper($finding['severity']) ?>"><?= htmlspecialchars($finding['severity']) ?></td>
                            <td data-label="Baris"><?= htmlspecialchars($finding['start_line']) ?> - <?= htmlspecialchars($finding['end_line']) ?></td>
                            <td data-label="Kode yang Cocok">
                                <div class="code-context">
                                    <?php
                                    // Highlighting teks yang cocok dalam konteks
                                    $highlighted_context = str_replace(
                                        htmlspecialchars($finding['matched_text']),
                                        '<strong>' . htmlspecialchars($finding['matched_text']) . '</strong>',
                                        $finding['context']
                                    );
                                    echo $highlighted_context;
                                    ?>
                                </div>
                            </td>
                            <td data-label="Deskripsi"><?= htmlspecialchars($finding['description']) ?></td>
                            <td data-label="Remediasi"><?= htmlspecialchars($finding['remediation']) ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>

    <div class="footer">
        Pemindai Backdoor Profesional - Di buat oleh <a href="http://www.msb.biz.id" target="_blank">Msb</a>
        <br>
        <small>Penting: Alat ini adalah pemindai berbasis signatur. Untuk keamanan maksimal, kombinasikan dengan audit manual dan praktik keamanan terbaik.</small>
    </div>

    <script>
        // Matrix Rain Effect (JavaScript untuk Canvas Background)
        const canvas = document.getElementById('matrixCanvas');
        const ctx = canvas.getContext('2d');

        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        const katakana = 'アァカサタナハマヤャラワガザダバパヰヱヲンヴヵヶキィクグズツヅテデドニヒビピフブプヘベペホボポマミムメモヤユヨラリルレロワン';
        const latin = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        const nums = '0123456789';
        const chars = katakana + latin + nums;

        const fontSize = 16;
        const columns = canvas.width / fontSize;

        const drops = [];
        for (let x = 0; x < columns; x++) {
            drops[x] = 1;
        }

        function draw() {
            ctx.fillStyle = 'rgba(26, 26, 46, 0.05)'; // Sedikit transparan untuk efek 'trail'
            ctx.fillRect(0, 0, canvas.width, canvas.height);

            ctx.fillStyle = '#00ff00'; // Warna teks hijau neon
            ctx.font = `${fontSize}px monospace`;

            for (let i = 0; i < drops.length; i++) {
                const text = chars.charAt(Math.floor(Math.random() * chars.length));
                ctx.fillText(text, i * fontSize, drops[i] * fontSize);

                if (drops[i] * fontSize > canvas.height && Math.random() > 0.975) {
                    drops[i] = 0;
                }
                drops[i]++;
            }
        }

        setInterval(draw, 35); // Kecepatan animasi

        // Update canvas size on window resize
        window.addEventListener('resize', () => {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            // Reset drops array for new dimensions
            const newColumns = canvas.width / fontSize;
            drops.length = 0; // Clear existing drops
            for (let x = 0; x < newColumns; x++) {
                drops[x] = 1;
            }
        });
    </script>
</body>
</html>