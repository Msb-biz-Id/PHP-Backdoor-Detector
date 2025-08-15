<?php
namespace App\Controllers\Student;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;
use App\Core\Auth;

class GradeController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['student']);
		$studentId = Database::pdo()->prepare('SELECT s.id FROM students s WHERE s.user_id=?');
		$studentId->execute([Auth::userId()]);
		$studentId = (int)$studentId->fetchColumn();
		$sql = 'SELECT s.name AS subject, ass.title, g.score, ay.name AS year, c.name AS class
			FROM grades g
			JOIN assessments ass ON ass.id=g.assessment_id
			JOIN assignments a ON a.id=ass.assignment_id
			JOIN subjects s ON s.id=a.subject_id
			JOIN enrollments e ON e.id=g.enrollment_id
			JOIN academic_years ay ON ay.id=e.academic_year_id
			JOIN classes c ON c.id=e.class_id
			WHERE e.student_id = ?
			ORDER BY ay.id DESC, s.name ASC';
		$stmt = Database::pdo()->prepare($sql);
		$stmt->execute([$studentId]);
		$rows = $stmt->fetchAll();
		$this->render('student/grades', ['title' => 'Nilai Saya', 'rows' => $rows]);
	}
}