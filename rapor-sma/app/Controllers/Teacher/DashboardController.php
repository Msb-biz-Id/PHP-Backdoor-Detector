<?php
namespace App\Controllers\Teacher;

declare(strict_types=1);

use App\Core\Controller;

class DashboardController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['teacher']);
		$this->render('dashboard/teacher', ['title' => 'Dashboard Guru']);
	}
}