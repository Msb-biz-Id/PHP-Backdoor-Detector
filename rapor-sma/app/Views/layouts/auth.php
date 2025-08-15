<?php
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
<body class="hold-transition login-page">
<div class="login-box">
	<div class="login-logo">
		<a href="#"><b>Rapor</b> SMA</a>
	</div>
	<div class="card">
		<div class="card-body login-card-body">
			<?php echo $content; ?>
		</div>
	</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
<script src="<?php echo base_url('assets/js/app.js'); ?>"></script>
</body>
</html>