<?php
namespace App\Controllers\Admin;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;

class AssignmentController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['admin']);
		$sql = 'SELECT a.id, ay.name AS year, c.name AS class, s.name AS subject, u.name AS teacher
		FROM assignments a
		JOIN academic_years ay ON ay.id=a.academic_year_id
		JOIN classes c ON c.id=a.class_id
		JOIN subjects s ON s.id=a.subject_id
		JOIN teachers t ON t.id=a.teacher_id
		JOIN users u ON u.id=t.user_id
		ORDER BY a.id DESC';
		$items = Database::pdo()->query($sql)->fetchAll();
		$this->render('admin/assignments/index', ['title' => 'Penugasan', 'items' => $items]);
	}
}