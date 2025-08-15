<?php
namespace App\Controllers\Admin;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;

class AcademicYearController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['admin']);
		$sql = 'SELECT id, name, semester, is_active FROM academic_years ORDER BY id DESC';
		$years = Database::pdo()->query($sql)->fetchAll();
		$this->render('admin/academic_years/index', ['title' => 'Tahun Ajaran', 'years' => $years]);
	}
}