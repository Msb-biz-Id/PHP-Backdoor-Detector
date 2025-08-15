<?php
namespace App\Controllers\Teacher;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;
use App\Core\Auth;

class GradeController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['teacher']);
		$teacherIdSql = 'SELECT t.id FROM teachers t WHERE t.user_id = ?';
		$stmt = Database::pdo()->prepare($teacherIdSql);
		$stmt->execute([Auth::userId()]);
		$teacherId = (int)$stmt->fetchColumn();
		$sql = 'SELECT a.id, ay.name AS year, c.name AS class, s.name AS subject
		FROM assignments a
		JOIN academic_years ay ON ay.id=a.academic_year_id
		JOIN classes c ON c.id=a.class_id
		JOIN subjects s ON s.id=a.subject_id
		WHERE a.teacher_id = ?
		ORDER BY a.id DESC';
		$stmt = Database::pdo()->prepare($sql);
		$stmt->execute([$teacherId]);
		$assignments = $stmt->fetchAll();
		$this->render('teacher/grades/index', ['title' => 'Nilai', 'assignments' => $assignments]);
	}
}