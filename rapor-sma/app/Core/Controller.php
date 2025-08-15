<?php
namespace App\Core;

declare(strict_types=1);

class Controller
{
    protected function render(string $view, array $params = [], ?string $layout = 'main'): void
    {
        $viewFile = BASE_PATH . '/app/Views/' . ltrim($view, '/');
        $viewFile = preg_match('/\.php$/', $viewFile) ? $viewFile : $viewFile . '.php';
        if (!file_exists($viewFile)) {
            http_response_code(500);
            echo 'View not found: ' . htmlspecialchars($view);
            return;
        }
        extract($params, EXTR_SKIP);
        ob_start();
        include $viewFile;
        $content = (string)ob_get_clean();
        if ($layout === null) {
            echo $content;
            return;
        }
        $layoutFile = BASE_PATH . '/app/Views/layouts/' . $layout . '.php';
        if (!file_exists($layoutFile)) {
            echo $content;
            return;
        }
        include $layoutFile;
    }

    protected function redirect(string $path): void
    {
        header('Location: ' . base_url($path));
        exit;
    }

    protected function requireAuth(?array $roles = null): void
    {
        if (!Auth::check()) {
            $this->redirect('login');
        }
        if ($roles !== null && !in_array(Auth::userRole(), $roles, true)) {
            http_response_code(403);
            echo 'Forbidden';
            exit;
        }
    }
}