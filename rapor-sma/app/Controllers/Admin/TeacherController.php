<?php
namespace App\Controllers\Admin;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;

class TeacherController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['admin']);
		$sql = 'SELECT t.id, u.name, u.email, t.nip, t.phone FROM teachers t JOIN users u ON u.id=t.user_id ORDER BY t.id DESC';
		$teachers = Database::pdo()->query($sql)->fetchAll();
		$this->render('admin/teachers/index', ['title' => 'Guru', 'teachers' => $teachers]);
	}
}