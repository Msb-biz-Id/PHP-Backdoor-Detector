<?php
namespace App\Controllers;

declare(strict_types=1);

use App\Core\Auth;
use App\Core\Controller;

class AuthController extends Controller
{
	public function login(): void
	{
		if (Auth::check()) {
			$this->redirect('dashboard');
			return;
		}
		$this->render('auth/login', ['title' => 'Masuk'], 'auth');
	}

	public function doLogin(): void
	{
		$email = trim($_POST['email'] ?? '');
		$password = (string)($_POST['password'] ?? '');
		if ($email === '' || $password === '') {
			$this->render('auth/login', ['title' => 'Masuk', 'error' => 'Email dan password wajib diisi'], 'auth');
			return;
		}
		if (!Auth::attempt($email, $password)) {
			$this->render('auth/login', ['title' => 'Masuk', 'error' => 'Kredensial tidak valid'], 'auth');
			return;
		}
		$this->redirect('dashboard');
	}

	public function logout(): void
	{
		Auth::logout();
		$this->redirect('login');
	}
}