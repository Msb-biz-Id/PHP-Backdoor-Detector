<?php
namespace App\Controllers\Admin;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;

class StudentController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['admin']);
		$sql = 'SELECT s.id, u.name, u.email, s.nisn, s.gender FROM students s JOIN users u ON u.id=s.user_id ORDER BY s.id DESC';
		$students = Database::pdo()->query($sql)->fetchAll();
		$this->render('admin/students/index', ['title' => 'Siswa', 'students' => $students]);
	}
}