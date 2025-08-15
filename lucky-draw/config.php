<?php

declare(strict_types=1);

// Database configuration
// You can override these via environment variables: MYSQL_HOST, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD

define('DB_HOST', getenv('MYSQL_HOST') ?: '127.0.0.1');
define('DB_NAME', getenv('MYSQL_DATABASE') ?: 'lucky_draw_db');
define('DB_USER', getenv('MYSQL_USER') ?: 'root');
define('DB_PASS', getenv('MYSQL_PASSWORD') ?: '');
define('DB_CHARSET', 'utf8mb4');