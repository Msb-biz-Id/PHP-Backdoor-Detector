<div class="card">
	<div class="card-header"><h5 class="card-title">Tahun Ajaran</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Nama</th>
						<th>Semester</th>
						<th>Status</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($years as $y): ?>
					<tr>
						<td><?php echo (int)$y['id']; ?></td>
						<td><?php echo htmlspecialchars($y['name']); ?></td>
						<td><?php echo htmlspecialchars($y['semester']); ?></td>
						<td><?php echo $y['is_active'] ? '<span class="badge badge-success">Aktif</span>' : '<span class="badge badge-secondary">Nonaktif</span>'; ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>