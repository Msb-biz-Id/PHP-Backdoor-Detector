<div class="card">
	<div class="card-header d-flex justify-content-between align-items-center">
		<h5 class="card-title mb-0">Penilaian - <?php echo htmlspecialchars($assignment['class'] ?? ''); ?> / <?php echo htmlspecialchars($assignment['subject'] ?? ''); ?> (<?php echo htmlspecialchars($assignment['year'] ?? ''); ?>)</h5>
		<a class="btn btn-sm btn-primary" href="<?php echo base_url('teacher/assessments/' . (int)$assignment['id'] . '/create'); ?>">Buat Penilaian</a>
	</div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Judul</th>
						<th>Jenis</th>
						<th>Bobot</th>
						<th>Aksi</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($assessments as $as): ?>
					<tr>
						<td><?php echo (int)$as['id']; ?></td>
						<td><?php echo htmlspecialchars($as['title']); ?></td>
						<td><?php echo htmlspecialchars($as['assessment_type']); ?></td>
						<td><?php echo htmlspecialchars((string)$as['weight']); ?></td>
						<td><a class="btn btn-sm btn-secondary" href="<?php echo base_url('teacher/assessments/' . (int)$assignment['id'] . '/' . (int)$as['id'] . '/grades'); ?>">Input Nilai</a></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>