<?php

declare(strict_types=1);

header('Content-Type: text/plain; charset=UTF-8');

require_once __DIR__ . '/db.php';

$pdo = get_db_connection();

$schemaPath = __DIR__ . '/schema.sql';
if (!file_exists($schemaPath)) {
	echo "schema.sql tidak ditemukan\n";
	exit(1);
}

$sql = file_get_contents($schemaPath);
if ($sql === false) {
	echo "Gagal membaca schema.sql\n";
	exit(1);
}

try {
	$pdo->beginTransaction();
	$pdo->exec($sql);
	$pdo->commit();
	echo "Schema berhasil diterapkan dan hadiah disiapkan.\n";
} catch (Throwable $e) {
	if ($pdo->inTransaction()) { $pdo->rollBack(); }
	echo "Gagal menerapkan schema: " . $e->getMessage() . "\n";
	exit(1);
}