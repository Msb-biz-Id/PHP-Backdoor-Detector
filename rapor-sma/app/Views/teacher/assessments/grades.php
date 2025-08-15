<div class="card">
	<div class="card-header"><h5 class="card-title">Input Nilai - <?php echo htmlspecialchars($assessment['title']); ?> (<?php echo htmlspecialchars($assessment['assessment_type']); ?>)</h5></div>
	<div class="card-body p-0">
		<form action="<?php echo base_url('teacher/assessments/' . (int)$assignmentId . '/' . (int)$assessmentId . '/grades'); ?>" method="post">
			<div class="table-responsive">
				<table class="table table-striped mb-0">
					<thead>
						<tr>
							<th>Peserta</th>
							<th>Nilai</th>
						</tr>
					</thead>
					<tbody>
						<?php foreach ($enrollments as $e): $eid=(int)$e['enrollment_id']; ?>
						<tr>
							<td><?php echo htmlspecialchars($e['student_name']); ?></td>
							<td style="max-width:150px">
								<input type="number" step="0.01" min="0" max="100" class="form-control" name="score[<?php echo $eid; ?>]" value="<?php echo isset($gradeMap[$eid]) ? htmlspecialchars((string)$gradeMap[$eid]) : ''; ?>" />
							</td>
						</tr>
						<?php endforeach; ?>
					</tbody>
				</table>
			</div>
			<div class="p-3"><button class="btn btn-primary">Simpan Nilai</button>
				<a class="btn btn-secondary" href="<?php echo base_url('teacher/assessments/' . (int)$assignmentId); ?>">Kembali</a>
			</div>
		</form>
	</div>
</div>