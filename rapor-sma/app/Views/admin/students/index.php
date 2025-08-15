<div class="card">
	<div class="card-header"><h5 class="card-title">Daftar Siswa</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Nama</th>
						<th>Email</th>
						<th>NISN</th>
						<th>JK</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($students as $s): ?>
					<tr>
						<td><?php echo (int)$s['id']; ?></td>
						<td><?php echo htmlspecialchars($s['name']); ?></td>
						<td><?php echo htmlspecialchars($s['email']); ?></td>
						<td><?php echo htmlspecialchars((string)$s['nisn']); ?></td>
						<td><?php echo htmlspecialchars((string)$s['gender']); ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>