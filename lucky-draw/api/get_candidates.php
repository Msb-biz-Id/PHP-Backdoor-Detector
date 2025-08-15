<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=UTF-8');

require_once __DIR__ . '/../db.php';

$pdo = get_db_connection();

// Fetch candidates who have not won yet
$sqlCandidates = 'SELECT k.id, k.nama
FROM karyawan k
LEFT JOIN winners w ON w.karyawan_id = k.id
WHERE w.karyawan_id IS NULL
ORDER BY k.nama ASC';
$stmt = $pdo->query($sqlCandidates);
$candidates = $stmt->fetchAll();

// Remaining gifts count
$sqlGifts = 'SELECT COUNT(*) AS cnt FROM gift WHERE is_assigned = 0';
$remainingGifts = (int)($pdo->query($sqlGifts)->fetch()['cnt'] ?? 0);

echo json_encode([
	'candidates' => $candidates,
	'remaining_gifts' => $remainingGifts,
]);