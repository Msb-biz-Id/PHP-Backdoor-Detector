<?php
namespace App\Core;

declare(strict_types=1);

use PDO;
use PDOException;

class Database
{
    private static ?PDO $pdo = null;

    public static function pdo(): PDO
    {
        if (self::$pdo === null) {
            $dsn = 'sqlite:' . DB_PATH;
            self::$pdo = new PDO($dsn);
            self::$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            self::$pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
            self::$pdo->exec('PRAGMA foreign_keys = ON');
        }
        return self::$pdo;
    }

    public static function initialize(): void
    {
        $dbDir = dirname(DB_PATH);
        if (!is_dir($dbDir)) {
            mkdir($dbDir, 0777, true);
        }
        $isFresh = !file_exists(DB_PATH);
        $pdo = self::pdo();
        if ($isFresh) {
            touch(DB_PATH);
        }
        // Check if users table exists
        $stmt = $pdo->query("SELECT name FROM sqlite_master WHERE type='table' AND name='users'");
        $exists = (bool)$stmt->fetchColumn();
        if (!$exists) {
            self::migrate();
            self::seed();
        }
    }

    private static function migrate(): void
    {
        $schemaFile = BASE_PATH . '/database/schema.sql';
        if (!file_exists($schemaFile)) {
            throw new \RuntimeException('Schema file not found: ' . $schemaFile);
        }
        $sql = file_get_contents($schemaFile);
        if ($sql === false) {
            throw new \RuntimeException('Unable to read schema file');
        }
        self::pdo()->exec($sql);
    }

    private static function seed(): void
    {
        $pdo = self::pdo();
        // Default admin user
        $passwordHash = password_hash('admin123', PASSWORD_BCRYPT);
        $pdo->prepare('INSERT INTO users (name, email, password_hash, role, created_at) VALUES (?,?,?,?,CURRENT_TIMESTAMP)')
            ->execute(['Administrator', 'admin@demo.com', $passwordHash, 'admin']);
        // Default academic year
        $pdo->prepare('INSERT INTO academic_years (name, semester, is_active) VALUES (?,?,1)')
            ->execute(['2024/2025', 'Ganjil']);
        // Default class and subject
        $pdo->prepare('INSERT INTO classes (name, grade_level, major) VALUES (?,?,?)')
            ->execute(['X-1', 10, 'Umum']);
        $pdo->prepare('INSERT INTO subjects (name, code, subject_group) VALUES (?,?,?)')
            ->execute(['Matematika', 'MAT', 'Umum']);
        // Default teacher and student users
        $teacherPass = password_hash('guru123', PASSWORD_BCRYPT);
        $studentPass = password_hash('siswa123', PASSWORD_BCRYPT);
        $pdo->prepare('INSERT INTO users (name, email, password_hash, role, created_at) VALUES (?,?,?,?,CURRENT_TIMESTAMP)')
            ->execute(['Guru Satu', 'guru@demo.com', $teacherPass, 'teacher']);
        $pdo->prepare('INSERT INTO users (name, email, password_hash, role, created_at) VALUES (?,?,?,?,CURRENT_TIMESTAMP)')
            ->execute(['Siswa Satu', 'siswa@demo.com', $studentPass, 'student']);
        // Make teacher and student profiles
        $pdo->exec('INSERT INTO teachers (user_id, nip, phone) VALUES ((SELECT id FROM users WHERE email="guru@demo.com"), "19800101", "08123456789")');
        $pdo->exec('INSERT INTO students (user_id, nisn, gender, birthdate, address) VALUES ((SELECT id FROM users WHERE email="siswa@demo.com"), "1234567890", "L", "2009-01-01", "-" )');
        // Enroll student and assign teacher to subject/class
        $pdo->exec('INSERT INTO enrollments (academic_year_id, class_id, student_id)
            VALUES ((SELECT id FROM academic_years WHERE is_active=1 LIMIT 1), (SELECT id FROM classes LIMIT 1), (SELECT s.id FROM students s JOIN users u ON u.id=s.user_id WHERE u.email="siswa@demo.com"))');
        $pdo->exec('INSERT INTO assignments (academic_year_id, class_id, subject_id, teacher_id)
            VALUES ((SELECT id FROM academic_years WHERE is_active=1 LIMIT 1), (SELECT id FROM classes LIMIT 1), (SELECT id FROM subjects LIMIT 1), (SELECT t.id FROM teachers t JOIN users u ON u.id=t.user_id WHERE u.email="guru@demo.com"))');
    }
}