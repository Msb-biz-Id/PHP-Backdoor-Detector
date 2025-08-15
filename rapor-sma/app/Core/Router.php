<?php
namespace App\Core;

declare(strict_types=1);

class Router
{
	public function dispatch(string $method, string $uri): void
	{
		$path = parse_url($uri, PHP_URL_PATH) ?: '/';
		$path = trim($path, '/');

		if ($path === '' || $path === 'dashboard') {
			if (!Auth::check()) {
				$this->call('AuthController@login');
				return;
			}
			$role = Auth::userRole();
			if ($role === 'admin') {
				$this->call('Admin\\DashboardController@index');
			} elseif ($role === 'teacher') {
				$this->call('Teacher\\DashboardController@index');
			} else {
				$this->call('Student\\DashboardController@index');
			}
			return;
		}

		if ($path === 'login' && $method === 'GET') {
			$this->call('AuthController@login');
			return;
		}
		if ($path === 'login' && $method === 'POST') {
			$this->call('AuthController@doLogin');
			return;
		}
		if ($path === 'logout') {
			$this->call('AuthController@logout');
			return;
		}

		// Admin routes (prefix admin)
		if (str_starts_with($path, 'admin')) {
			if (!Auth::check()) {
				header('Location: ' . base_url('login'));
				return;
			}
			if (Auth::userRole() !== 'admin') {
				http_response_code(403);
				echo 'Forbidden';
				return;
			}
			$sub = trim(substr($path, strlen('admin')), '/');
			if ($sub === '' || $sub === 'dashboard') {
				$this->call('Admin\\DashboardController@index');
				return;
			}
			$segments = explode('/', $sub);
			$resource = $segments[0] ?? '';
			$controllerMap = [
				'users' => 'Admin\\UserController@index',
				'students' => 'Admin\\StudentController@index',
				'teachers' => 'Admin\\TeacherController@index',
				'classes' => 'Admin\\ClassController@index',
				'subjects' => 'Admin\\SubjectController@index',
				'academic-years' => 'Admin\\AcademicYearController@index',
				'assignments' => 'Admin\\AssignmentController@index',
			];
			if (isset($controllerMap[$resource])) {
				$this->call($controllerMap[$resource]);
				return;
			}
		}

		// Teacher routes
		if (str_starts_with($path, 'teacher')) {
			if (!Auth::check()) {
				header('Location: ' . base_url('login'));
				return;
			}
			if (Auth::userRole() !== 'teacher') {
				http_response_code(403);
				echo 'Forbidden';
				return;
			}
			$sub = trim(substr($path, strlen('teacher')), '/');
			if ($sub === '' || $sub === 'dashboard') {
				$this->call('Teacher\\DashboardController@index');
				return;
			}
			$segments = array_values(array_filter(explode('/', $sub), fn($s) => $s !== ''));
			$resource = $segments[0] ?? '';
			if ($resource === 'grades') {
				$this->call('Teacher\\GradeController@index');
				return;
			}
			if ($resource === 'assessments') {
				// /teacher/assessments
				if (count($segments) === 1) {
					$this->call('Teacher\\AssessmentController@index');
					return;
				}
				// /teacher/assessments/{assignmentId}
				if (count($segments) === 2 && ctype_digit($segments[1])) {
					$this->call('Teacher\\AssessmentController@show', [(int)$segments[1]]);
					return;
				}
				// /teacher/assessments/{assignmentId}/create
				if (count($segments) === 3 && ctype_digit($segments[1]) && $segments[2] === 'create') {
					if ($method === 'GET') {
						$this->call('Teacher\\AssessmentController@create', [(int)$segments[1]]);
					} else {
						$this->call('Teacher\\AssessmentController@store', [(int)$segments[1]]);
					}
					return;
				}
				// /teacher/assessments/{assignmentId}/{assessmentId}/grades
				if (count($segments) === 4 && ctype_digit($segments[1]) && ctype_digit($segments[2]) && $segments[3] === 'grades') {
					if ($method === 'GET') {
						$this->call('Teacher\\AssessmentController@grades', [(int)$segments[1], (int)$segments[2]]);
					} else {
						$this->call('Teacher\\AssessmentController@saveGrades', [(int)$segments[1], (int)$segments[2]]);
					}
					return;
				}
			}
		}

		// Student routes
		if (str_starts_with($path, 'student')) {
			if (!Auth::check()) {
				header('Location: ' . base_url('login'));
				return;
			}
			if (Auth::userRole() !== 'student') {
				http_response_code(403);
				echo 'Forbidden';
				return;
			}
			$sub = trim(substr($path, strlen('student')), '/');
			if ($sub === '' || $sub === 'dashboard') {
				$this->call('Student\\DashboardController@index');
				return;
			}
			$segments = explode('/', $sub);
			$resource = $segments[0] ?? '';
			if ($resource === 'grades') {
				$this->call('Student\\GradeController@index');
				return;
			}
			if ($resource === 'report') {
				$this->call('Student\\ReportController@index');
				return;
			}
		}

		http_response_code(404);
		echo 'Not Found';
	}

	private function call(string $target, array $params = []): void
	{
		[$controller, $method] = explode('@', $target);
		$fqcn = 'App\\Controllers\\' . $controller;
		if (!class_exists($fqcn)) {
			http_response_code(500);
			echo 'Controller not found: ' . htmlspecialchars($fqcn);
			return;
		}
		$obj = new $fqcn();
		if (!method_exists($obj, $method)) {
			http_response_code(500);
			echo 'Method not found: ' . htmlspecialchars($method);
			return;
		}
		$obj->$method(...$params);
	}
}