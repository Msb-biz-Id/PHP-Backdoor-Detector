<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

function get_db_connection(): PDO {
	static $pdo = null;
	if ($pdo instanceof PDO) {
		return $pdo;
	}

	$dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=' . DB_CHARSET;
	$options = [
		PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
		PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
		PDO::ATTR_EMULATE_PREPARES => false,
	];

	try {
		$pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
	} catch (PDOException $e) {
		http_response_code(500);
		header('Content-Type: text/plain; charset=UTF-8');
		echo 'Gagal koneksi database: ' . $e->getMessage();
		exit;
	}

	return $pdo;
}