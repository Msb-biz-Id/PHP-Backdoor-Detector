<?php
namespace App\Controllers\Admin;

declare(strict_types=1);

use App\Core\Controller;
use App\Core\Database;

class UserController extends Controller
{
	public function index(): void
	{
		$this->requireAuth(['admin']);
		$users = Database::pdo()->query('SELECT id, name, email, role, created_at FROM users ORDER BY id DESC')->fetchAll();
		$this->render('admin/users/index', ['title' => 'Pengguna', 'users' => $users]);
	}
}