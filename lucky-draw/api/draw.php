<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=UTF-8');

require_once __DIR__ . '/../db.php';

$rawBody = file_get_contents('php://input');
$payload = json_decode($rawBody, true);
$karyawanId = isset($payload['karyawan_id']) ? (int)$payload['karyawan_id'] : 0;

if ($karyawanId <= 0) {
	http_response_code(400);
	echo json_encode(['status' => 'error', 'message' => 'Parameter karyawan_id tidak valid']);
	exit;
}

$pdo = get_db_connection();

try {
	$pdo->beginTransaction();

	// Ensure selected employee exists and has not already won
	$sqlCandidate = 'SELECT k.id, k.nama
		FROM karyawan k
		LEFT JOIN winners w ON w.karyawan_id = k.id
		WHERE k.id = ? AND w.karyawan_id IS NULL
		FOR UPDATE';
	$stmt = $pdo->prepare($sqlCandidate);
	$stmt->execute([$karyawanId]);
	$candidate = $stmt->fetch();
	if (!$candidate) {
		throw new RuntimeException('Karyawan tidak ditemukan atau sudah menjadi pemenang.');
	}

	// Fetch the highest-order unassigned gift
	$sqlGift = 'SELECT id, urut, nama_hadiah FROM gift WHERE is_assigned = 0 ORDER BY urut DESC LIMIT 1 FOR UPDATE';
	$stmtGift = $pdo->query($sqlGift);
	$gift = $stmtGift->fetch();
	if (!$gift) {
		throw new RuntimeException('Hadiah sudah habis.');
	}

	// Insert winner (unique constraint on karyawan_id prevents duplicates)
	$sqlInsertWinner = 'INSERT INTO winners (karyawan_id, gift_id) VALUES (?, ?)';
	$stmtIns = $pdo->prepare($sqlInsertWinner);
	$stmtIns->execute([$karyawanId, (int)$gift['id']]);

	// Mark gift as assigned
	$sqlUpdateGift = 'UPDATE gift SET is_assigned = 1 WHERE id = ?';
	$stmtUpd = $pdo->prepare($sqlUpdateGift);
	$stmtUpd->execute([(int)$gift['id']]);

	$pdo->commit();

	echo json_encode([
		'status' => 'ok',
		'winner' => [
			'id' => (int)$candidate['id'],
			'nama' => $candidate['nama'],
		],
		'gift' => [
			'id' => (int)$gift['id'],
			'urut' => (int)$gift['urut'],
			'nama_hadiah' => $gift['nama_hadiah'],
		],
	]);
} catch (Throwable $e) {
	if ($pdo->inTransaction()) {
		$pdo->rollBack();
	}
	http_response_code(400);
	echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}