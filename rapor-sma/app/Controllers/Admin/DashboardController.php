<?php
namespace App\Controllers\Admin;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Auth;

class DashboardController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['admin']);
		$this->render('dashboard/admin', ['title' => 'Dashboard Admin']);
	}
}