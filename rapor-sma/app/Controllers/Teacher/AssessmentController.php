<?php
namespace App\Controllers\Teacher;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;
use App\Core\Auth;

class AssessmentController extends Controller
{
	private function getTeacherId(): int
	{
		$stmt = Database::pdo()->prepare('SELECT id FROM teachers WHERE user_id = ?');
		$stmt->execute([Auth::userId()]);
		return (int)$stmt->fetchColumn();
	}

	public function index(): void
	{
		$this->requireAuth(['teacher']);
		$teacherId = $this->getTeacherId();
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
		$this->render('teacher/assessments/index', ['title' => 'Penilaian', 'assignments' => $assignments]);
	}

	public function show(int $assignmentId): void
	{
		$this->requireAuth(['teacher']);
		$teacherId = $this->getTeacherId();
		// Ensure ownership
		$own = Database::pdo()->prepare('SELECT COUNT(1) FROM assignments WHERE id=? AND teacher_id=?');
		$own->execute([$assignmentId, $teacherId]);
		if (!$own->fetchColumn()) {
			http_response_code(403);
			echo 'Forbidden';
			return;
		}
		$assignment = Database::pdo()->prepare('SELECT a.*, ay.name AS year, c.name AS class, s.name AS subject FROM assignments a JOIN academic_years ay ON ay.id=a.academic_year_id JOIN classes c ON c.id=a.class_id JOIN subjects s ON s.id=a.subject_id WHERE a.id=?');
		$assignment->execute([$assignmentId]);
		$assignmentRow = $assignment->fetch();
		$assessments = Database::pdo()->prepare('SELECT * FROM assessments WHERE assignment_id = ? ORDER BY id DESC');
		$assessments->execute([$assignmentId]);
		$this->render('teacher/assessments/show', ['title' => 'Penilaian', 'assignment' => $assignmentRow, 'assessments' => $assessments->fetchAll()]);
	}

	public function create(int $assignmentId): void
	{
		$this->requireAuth(['teacher']);
		$this->render('teacher/assessments/create', ['title' => 'Buat Penilaian', 'assignmentId' => $assignmentId]);
	}

	public function store(int $assignmentId): void
	{
		$this->requireAuth(['teacher']);
		$title = trim($_POST['title'] ?? '');
		$type = trim($_POST['assessment_type'] ?? 'Formatif');
		$weight = (float)($_POST['weight'] ?? 1);
		if ($title === '' || $weight <= 0) {
			$this->render('teacher/assessments/create', ['title' => 'Buat Penilaian', 'assignmentId' => $assignmentId, 'error' => 'Judul dan bobot wajib diisi']);
			return;
		}
		$stmt = Database::pdo()->prepare('INSERT INTO assessments (assignment_id, title, weight, assessment_type) VALUES (?,?,?,?)');
		$stmt->execute([$assignmentId, $title, $weight, $type]);
		$this->redirect('teacher/assessments/' . $assignmentId);
	}

	public function grades(int $assignmentId, int $assessmentId): void
	{
		$this->requireAuth(['teacher']);
		// Fetch assessment and related enrollment list
		$assessmentStmt = Database::pdo()->prepare('SELECT a.*, ass.title, ass.assessment_type FROM assignments a JOIN assessments ass ON ass.assignment_id=a.id WHERE a.id=? AND ass.id=?');
		$assessmentStmt->execute([$assignmentId, $assessmentId]);
		$assessment = $assessmentStmt->fetch();
		if (!$assessment) {
			http_response_code(404);
			echo 'Not Found';
			return;
		}
		$enrollStmt = Database::pdo()->prepare('SELECT e.id AS enrollment_id, u.name AS student_name
			FROM enrollments e
			JOIN students s ON s.id=e.student_id
			JOIN users u ON u.id=s.user_id
			WHERE e.academic_year_id=? AND e.class_id=?
			ORDER BY u.name ASC');
		$enrollStmt->execute([(int)$assessment['academic_year_id'], (int)$assessment['class_id']]);
		$enrollments = $enrollStmt->fetchAll();
		// Current grades
		$gradeMap = [];
		if (!empty($enrollments)) {
			$ids = array_column($enrollments, 'enrollment_id');
			$placeholders = implode(',', array_fill(0, count($ids), '?'));
			$gStmt = Database::pdo()->prepare("SELECT enrollment_id, score FROM grades WHERE assessment_id=? AND enrollment_id IN ($placeholders)");
			$gStmt->execute(array_merge([$assessmentId], $ids));
			foreach ($gStmt->fetchAll() as $g) {
				$gradeMap[(int)$g['enrollment_id']] = (float)$g['score'];
			}
		}
		$this->render('teacher/assessments/grades', [
			'title' => 'Input Nilai',
			'assessment' => $assessment,
			'enrollments' => $enrollments,
			'gradeMap' => $gradeMap,
			'assignmentId' => $assignmentId,
			'assessmentId' => $assessmentId,
		]);
	}

	public function saveGrades(int $assignmentId, int $assessmentId): void
	{
		$this->requireAuth(['teacher']);
		$scores = $_POST['score'] ?? [];
		$pdo = Database::pdo();
		$pdo->beginTransaction();
		try {
			$insert = $pdo->prepare('INSERT INTO grades (assessment_id, enrollment_id, score) VALUES (?,?,?)
				ON CONFLICT(assessment_id, enrollment_id) DO UPDATE SET score=excluded.score, updated_at=CURRENT_TIMESTAMP');
			foreach ($scores as $enrollmentId => $score) {
				$enrollmentId = (int)$enrollmentId;
				$scoreVal = (float)$score;
				if ($enrollmentId > 0) {
					$insert->execute([$assessmentId, $enrollmentId, $scoreVal]);
				}
			}
			$pdo->commit();
		} catch (\Throwable $e) {
			$pdo->rollBack();
			throw $e;
		}
		$this->redirect('teacher/assessments/' . $assignmentId . '/' . $assessmentId . '/grades');
	}
}