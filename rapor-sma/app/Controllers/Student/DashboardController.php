<?php
namespace App\Controllers\Student;

declare(strict_types=1);

use App\Core\Controller;

class DashboardController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['student']);
		$this->render('dashboard/student', ['title' => 'Dashboard Siswa']);
	}
}