<?php

declare(strict_types=1);

?><!doctype html>
<html lang="id">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Lucky Draw - PHP Native</title>
	<link rel="stylesheet" href="assets/styles.css">
</head>
<body>
	<div class="container">
		<h1>Lucky Draw</h1>

		<div class="controls">
			<button id="start-btn" class="btn">Mulai</button>
			<button id="refresh-btn" class="btn btn-secondary">Muat Ulang Nama</button>
		</div>

		<div id="info" class="info">
			<span id="info-candidates">Kandidat: 0</span>
			<span id="info-gifts">Sisa Hadiah: 0</span>
		</div>

		<div id="scroll-box" class="scroll-box">
			<ul id="name-list" class="name-list"></ul>
		</div>

		<div id="winner-area" class="winner-area" aria-live="polite"></div>
	</div>

	<script src="assets/app.js"></script>
</body>
</html>