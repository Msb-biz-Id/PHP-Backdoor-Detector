<?php
declare(strict_types=1);

define('BASE_PATH', realpath(__DIR__ . '/..'));

define('DB_PATH', BASE_PATH . '/database/app.sqlite');

define('APP_NAME', 'Rapor SMA - Kurikulum Merdeka');

define('APP_TIMEZONE', 'Asia/Jakarta');
date_default_timezone_set(APP_TIMEZONE);

function base_url(string $path = ''): string {
    $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https');
    $scheme = $https ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
    $scriptName = $_SERVER['SCRIPT_NAME'] ?? '';
    $dir = rtrim(str_replace('/index.php', '', $scriptName), '/');
    $base = $scheme . '://' . $host . $dir;
    if ($path === '') {
        return $base . '/';
    }
    return rtrim($base, '/') . '/' . ltrim($path, '/');
}

if (!function_exists('str_starts_with')) {
	function str_starts_with(string $haystack, string $needle): bool {
		return substr($haystack, 0, strlen($needle)) === $needle;
	}
}