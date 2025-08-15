<div class="card">
	<div class="card-header"><h5 class="card-title">Daftar Penugasan</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Tahun</th>
						<th>Kelas</th>
						<th>Mapel</th>
						<th>Guru</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($items as $i): ?>
					<tr>
						<td><?php echo (int)$i['id']; ?></td>
						<td><?php echo htmlspecialchars($i['year']); ?></td>
						<td><?php echo htmlspecialchars($i['class']); ?></td>
						<td><?php echo htmlspecialchars($i['subject']); ?></td>
						<td><?php echo htmlspecialchars($i['teacher']); ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>