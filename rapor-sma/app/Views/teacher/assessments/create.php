<div class="card">
	<div class="card-header"><h5 class="card-title">Buat Penilaian</h5></div>
	<div class="card-body">
		<?php if (!empty($error ?? '')): ?><div class="alert alert-danger"><?php echo htmlspecialchars($error); ?></div><?php endif; ?>
		<form action="<?php echo base_url('teacher/assessments/' . (int)$assignmentId . '/create'); ?>" method="post">
			<div class="form-group">
				<label>Judul</label>
				<input type="text" name="title" class="form-control" required />
			</div>
			<div class="form-group">
				<label>Jenis</label>
				<select name="assessment_type" class="form-control">
					<option value="Formatif">Formatif</option>
					<option value="Sumatif">Sumatif</option>
					<option value="Proyek">Proyek</option>
					<option value="UTS">UTS</option>
					<option value="UAS">UAS</option>
				</select>
			</div>
			<div class="form-group">
				<label>Bobot</label>
				<input type="number" name="weight" step="0.1" min="0.1" class="form-control" value="1" required />
			</div>
			<button class="btn btn-primary" type="submit">Simpan</button>
			<a class="btn btn-secondary" href="<?php echo base_url('teacher/assessments/' . (int)$assignmentId); ?>">Batal</a>
		</form>
	</div>
</div>