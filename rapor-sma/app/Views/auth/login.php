<p class="login-box-msg">Masuk untuk memulai sesi</p>
<?php if (!empty($error ?? '')): ?>
<div class="alert alert-danger py-2 px-3"><?php echo htmlspecialchars($error); ?></div>
<?php endif; ?>
<form action="<?php echo base_url('login'); ?>" method="post">
	<div class="input-group mb-3">
		<input type="email" class="form-control" name="email" placeholder="Email" required />
		<div class="input-group-append"><div class="input-group-text"><span class="fas fa-envelope"></span></div></div>
	</div>
	<div class="input-group mb-3">
		<input type="password" class="form-control" name="password" placeholder="Password" required />
		<div class="input-group-append"><div class="input-group-text"><span class="fas fa-lock"></span></div></div>
	</div>
	<div class="row">
		<div class="col-12">
			<button type="submit" class="btn btn-primary btn-block">Masuk</button>
		</div>
	</div>
</form>
<div class="mt-3 small text-muted">
	Demo: admin@demo.com / admin123, guru@demo.com / guru123, siswa@demo.com / siswa123
</div>