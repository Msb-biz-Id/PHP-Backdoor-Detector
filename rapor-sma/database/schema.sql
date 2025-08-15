-- Users
CREATE TABLE users (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	email TEXT NOT NULL UNIQUE,
	password_hash TEXT NOT NULL,
	role TEXT NOT NULL CHECK(role IN ('admin','teacher','student')),
	created_at TEXT NOT NULL,
	updated_at TEXT
);

-- Teachers
CREATE TABLE teachers (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	user_id INTEGER NOT NULL UNIQUE,
	nip TEXT,
	phone TEXT,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Students
CREATE TABLE students (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	user_id INTEGER NOT NULL UNIQUE,
	nisn TEXT,
	gender TEXT CHECK(gender IN ('L','P')),
	birthdate TEXT,
	address TEXT,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Academic Years
CREATE TABLE academic_years (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	semester TEXT NOT NULL CHECK(semester IN ('Ganjil','Genap')),
	is_active INTEGER NOT NULL DEFAULT 0
);

-- Classes
CREATE TABLE classes (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	grade_level INTEGER NOT NULL,
	major TEXT
);

-- Subjects
CREATE TABLE subjects (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	code TEXT NOT NULL,
	subject_group TEXT
);

-- Assignments (teacher teaches subject in class in a year)
CREATE TABLE assignments (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	academic_year_id INTEGER NOT NULL,
	class_id INTEGER NOT NULL,
	subject_id INTEGER NOT NULL,
	teacher_id INTEGER NOT NULL,
	UNIQUE(academic_year_id, class_id, subject_id, teacher_id),
	FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE,
	FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
	FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
	FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE
);

-- Enrollments (student joins class in year)
CREATE TABLE enrollments (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	academic_year_id INTEGER NOT NULL,
	class_id INTEGER NOT NULL,
	student_id INTEGER NOT NULL,
	UNIQUE(academic_year_id, class_id, student_id),
	FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE,
	FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
	FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

-- Assessments (type of assessment per subject)
CREATE TABLE assessments (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	assignment_id INTEGER NOT NULL,
	title TEXT NOT NULL,
	weight REAL NOT NULL DEFAULT 1,
	assessment_type TEXT NOT NULL CHECK(assessment_type IN ('Formatif','Sumatif','Proyek','UTS','UAS')),
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
);

-- Grades (score per assessment per student)
CREATE TABLE grades (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	assessment_id INTEGER NOT NULL,
	enrollment_id INTEGER NOT NULL,
	score REAL NOT NULL CHECK(score >= 0 AND score <= 100),
	feedback TEXT,
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TEXT,
	UNIQUE(assessment_id, enrollment_id),
	FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE,
	FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE
);

-- Reports (final per subject per student)
CREATE TABLE report_items (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	assignment_id INTEGER NOT NULL,
	enrollment_id INTEGER NOT NULL,
	final_score REAL NOT NULL,
	predicate TEXT,
	description TEXT,
	UNIQUE(assignment_id, enrollment_id),
	FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
	FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE
);