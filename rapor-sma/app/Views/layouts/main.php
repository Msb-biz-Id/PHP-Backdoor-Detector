<?php
use App\Core\Auth;
?><!DOCTYPE html>
<html lang="id">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<title><?php echo isset($title) ? htmlspecialchars($title) . ' - ' : ''; ?><?php echo htmlspecialchars(APP_NAME); ?></title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css" />
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@5.15.4/css/all.min.css" />
	<link rel="stylesheet" href="<?php echo base_url('assets/css/app.css'); ?>" />
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
	<nav class="main-header navbar navbar-expand navbar-white navbar-light">
		<ul class="navbar-nav">
			<li class="nav-item">
				<a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
			</li>
		</ul>
		<ul class="navbar-nav ml-auto">
			<li class="nav-item">
				<a class="nav-link" href="<?php echo base_url('logout'); ?>">Keluar</a>
			</li>
		</ul>
	</nav>
	<aside class="main-sidebar sidebar-dark-primary elevation-4">
		<a href="<?php echo base_url('dashboard'); ?>" class="brand-link">
			<span class="brand-text font-weight-light">Rapor SMA</span>
		</a>
		<div class="sidebar">
			<nav class="mt-2">
				<ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu">
					<?php if (Auth::userRole() === 'admin'): ?>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('admin/dashboard'); ?>"><i class="nav-icon fas fa-tachometer-alt"></i><p>Dashboard</p></a></li>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('admin/users'); ?>"><i class="nav-icon fas fa-users-cog"></i><p>Pengguna</p></a></li>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('admin/students'); ?>"><i class="nav-icon fas fa-user-graduate"></i><p>Siswa</p></a></li>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('admin/teachers'); ?>"><i class="nav-icon fas fa-chalkboard-teacher"></i><p>Guru</p></a></li>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('admin/classes'); ?>"><i class="nav-icon fas fa-school"></i><p>Kelas</p></a></li>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('admin/subjects'); ?>"><i class="nav-icon fas fa-book"></i><p>Mapel</p></a></li>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('admin/academic-years'); ?>"><i class="nav-icon fas fa-calendar-alt"></i><p>Tahun Ajaran</p></a></li>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('admin/assignments'); ?>"><i class="nav-icon fas fa-tasks"></i><p>Penugasan</p></a></li>
					<?php elseif (Auth::userRole() === 'teacher'): ?>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('teacher/dashboard'); ?>"><i class="nav-icon fas fa-tachometer-alt"></i><p>Dashboard</p></a></li>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('teacher/grades'); ?>"><i class="nav-icon fas fa-clipboard-list"></i><p>Nilai</p></a></li>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('teacher/assessments'); ?>"><i class="nav-icon fas fa-tasks"></i><p>Penilaian</p></a></li>
					<?php else: ?>
					<li class="nav-item"><a class="nav-link" href="<?php echo base_url('student/dashboard'); ?>"><i class="nav-icon fas fa-tachometer-alt"></i><p>Dashboard</p></a></li>
					<?php endif; ?>
				</ul>
			</nav>
		</div>
	</aside>
	<div class="content-wrapper">
		<section class="content pt-3">
			<div class="container-fluid">
				<?php echo $content; ?>
			</div>
		</section>
	</div>
	<footer class="main-footer text-sm">
		<div class="float-right d-none d-sm-inline">Kurikulum Merdeka</div>
		<strong>&copy; <?php echo date('Y'); ?> Rapor SMA.</strong>
	</footer>
</div>
<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
<script src="<?php echo base_url('assets/js/app.js'); ?>"></script>
</body>
</html>