<div class="card">
	<div class="card-header"><h5 class="card-title">Penilaian - Kelas & Mapel Diampu</h5></div>
	<div class="card-body p-0">
		<div class="table-responsive">
			<table class="table table-striped mb-0">
				<thead>
					<tr>
						<th>ID</th>
						<th>Tahun</th>
						<th>Kelas</th>
						<th>Mapel</th>
						<th>Aksi</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($assignments as $a): ?>
					<tr>
						<td><?php echo (int)$a['id']; ?></td>
						<td><?php echo htmlspecialchars($a['year']); ?></td>
						<td><?php echo htmlspecialchars($a['class']); ?></td>
						<td><?php echo htmlspecialchars($a['subject']); ?></td>
						<td><a class="btn btn-sm btn-primary" href="<?php echo base_url('teacher/assessments/' . (int)$a['id']); ?>">Kelola</a></td>
					</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		</div>
	</div>
</div>