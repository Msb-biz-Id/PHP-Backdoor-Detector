<div class="card">
	<div class="card-header"><h5 class="card-title">Kelas & Mapel Diampu</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Tahun</th>
						<th>Kelas</th>
						<th>Mapel</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($assignments as $a): ?>
					<tr>
						<td><?php echo (int)$a['id']; ?></td>
						<td><?php echo htmlspecialchars($a['year']); ?></td>
						<td><?php echo htmlspecialchars($a['class']); ?></td>
						<td><?php echo htmlspecialchars($a['subject']); ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>