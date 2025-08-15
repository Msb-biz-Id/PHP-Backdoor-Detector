<?php
namespace App\Controllers\Student;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;
use App\Core\Auth;

class ReportController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['student']);
		$studentId = Database::pdo()->prepare('SELECT s.id FROM students s WHERE s.user_id=?');
		$studentId->execute([Auth::userId()]);
		$studentId = (int)$studentId->fetchColumn();
		// Aggregate weighted average per subject for active year
		$sql = 'WITH active_year AS (
			SELECT id FROM academic_years WHERE is_active=1 LIMIT 1
		), sc AS (
			SELECT e.id AS enrollment_id, a.subject_id
			FROM enrollments e JOIN assignments a ON a.class_id=e.class_id AND a.academic_year_id=e.academic_year_id
			WHERE e.student_id=? AND e.academic_year_id=(SELECT id FROM active_year)
		), ga AS (
			SELECT sc.subject_id, g.enrollment_id, g.score, ass.weight
			FROM grades g JOIN assessments ass ON ass.id=g.assessment_id JOIN sc ON sc.enrollment_id=g.enrollment_id
		)
		SELECT s.name as subject, ROUND(SUM(score*weight)/NULLIF(SUM(weight),0),2) as final_score
		FROM ga JOIN subjects s ON s.id=ga.subject_id
		GROUP BY ga.subject_id
		ORDER BY s.name ASC';
		$stmt = Database::pdo()->prepare($sql);
		$stmt->execute([$studentId]);
		$items = $stmt->fetchAll();
		$this->render('student/report', ['title' => 'Rapor Saya', 'items' => $items]);
	}
}