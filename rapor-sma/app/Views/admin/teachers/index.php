<div class="card">
	<div class="card-header"><h5 class="card-title">Daftar Guru</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Nama</th>
						<th>Email</th>
						<th>NIP</th>
						<th>HP</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($teachers as $t): ?>
					<tr>
						<td><?php echo (int)$t['id']; ?></td>
						<td><?php echo htmlspecialchars($t['name']); ?></td>
						<td><?php echo htmlspecialchars($t['email']); ?></td>
						<td><?php echo htmlspecialchars((string)$t['nip']); ?></td>
						<td><?php echo htmlspecialchars((string)$t['phone']); ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>