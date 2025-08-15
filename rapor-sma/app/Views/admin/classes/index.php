<div class="card">
	<div class="card-header"><h5 class="card-title">Daftar Kelas</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Nama</th>
						<th>Tingkat</th>
						<th>Jurusan</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($classes as $c): ?>
					<tr>
						<td><?php echo (int)$c['id']; ?></td>
						<td><?php echo htmlspecialchars($c['name']); ?></td>
						<td><?php echo (int)$c['grade_level']; ?></td>
						<td><?php echo htmlspecialchars((string)$c['major']); ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>