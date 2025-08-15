<div class="card">
	<div class="card-header"><h5 class="card-title">Daftar Mata Pelajaran</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Nama</th>
						<th>Kode</th>
						<th>Kelompok</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($subjects as $s): ?>
					<tr>
						<td><?php echo (int)$s['id']; ?></td>
						<td><?php echo htmlspecialchars($s['name']); ?></td>
						<td><?php echo htmlspecialchars($s['code']); ?></td>
						<td><?php echo htmlspecialchars((string)$s['subject_group']); ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>