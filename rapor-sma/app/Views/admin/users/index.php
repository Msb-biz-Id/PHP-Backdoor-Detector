<div class="card">
	<div class="card-header"><h5 class="card-title">Daftar Pengguna</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Nama</th>
						<th>Email</th>
						<th>Role</th>
						<th>Dibuat</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($users as $u): ?>
					<tr>
						<td><?php echo (int)$u['id']; ?></td>
						<td><?php echo htmlspecialchars($u['name']); ?></td>
						<td><?php echo htmlspecialchars($u['email']); ?></td>
						<td><span class="badge badge-secondary text-uppercase"><?php echo htmlspecialchars($u['role']); ?></span></td>
						<td><?php echo htmlspecialchars($u['created_at']); ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>