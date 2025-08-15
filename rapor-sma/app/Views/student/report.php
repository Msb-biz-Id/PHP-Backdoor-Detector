<div class="card">
	<div class="card-header"><h5 class="card-title">Rapor Saya (Tahun Ajaran Aktif)</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>Mapel</th>
						<th>Nilai Akhir</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($items as $i): ?>
					<tr>
						<td><?php echo htmlspecialchars($i['subject']); ?></td>
						<td><?php echo htmlspecialchars((string)$i['final_score']); ?></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>