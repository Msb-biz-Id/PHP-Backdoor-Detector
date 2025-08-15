<?php
namespace App\Controllers\Admin;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;

class SubjectController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['admin']);
		$sql = 'SELECT s.id, s.name, s.code, s.subject_group FROM subjects s ORDER BY s.id DESC';
		$subjects = Database::pdo()->query($sql)->fetchAll();
		$this->render('admin/subjects/index', ['title' => 'Mata Pelajaran', 'subjects' => $subjects]);
	}
}