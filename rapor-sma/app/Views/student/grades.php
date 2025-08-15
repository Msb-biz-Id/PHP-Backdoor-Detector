<div class="card">
	<div class="card-header"><h5 class="card-title">Nilai Saya</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>Tahun</th>
						<th>Kelas</th>
						<th>Mapel</th>
						<th>Komponen</th>
						<th>Nilai</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($rows as $r): ?>
					<tr>
						<td><?php echo htmlspecialchars($r['year']); ?></td>
						<td><?php echo htmlspecialchars($r['class']); ?></td>
						<td><?php echo htmlspecialchars($r['subject']); ?></td>
						<td><?php echo htmlspecialchars($r['title']); ?></td>
						<td><?php echo htmlspecialchars((string)$r['score']); ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>