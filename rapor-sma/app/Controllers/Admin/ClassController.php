<?php
namespace App\Controllers\Admin;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;

class ClassController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['admin']);
		$sql = 'SELECT c.id, c.name, c.grade_level, c.major FROM classes c ORDER BY c.id DESC';
		$classes = Database::pdo()->query($sql)->fetchAll();
		$this->render('admin/classes/index', ['title' => 'Kelas', 'classes' => $classes]);
	}
}