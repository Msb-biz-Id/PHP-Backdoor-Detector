(function(){
	'use strict';

	const nameList = document.getElementById('name-list');
	const startBtn = document.getElementById('start-btn');
	const refreshBtn = document.getElementById('refresh-btn');
	const winnerArea = document.getElementById('winner-area');
	const infoCandidates = document.getElementById('info-candidates');
	const infoGifts = document.getElementById('info-gifts');

	let candidates = [];
	let giftsLeft = 0;
	let isRunning = false;
	let scrollTimer = null;
	let highlightedIndex = -1;

	function showToast(message) {
		const t = document.createElement('div');
		t.className = 'toast';
		t.textContent = message;
		document.body.appendChild(t);
		setTimeout(() => t.remove(), 3000);
	}

	async function loadCandidates() {
		const res = await fetch('api/get_candidates.php');
		if (!res.ok) throw new Error('Gagal memuat kandidat');
		const data = await res.json();
		candidates = data.candidates || [];
		giftsLeft = Number(data.remaining_gifts || 0);
		infoCandidates.textContent = `Kandidat: ${candidates.length}`;
		infoGifts.textContent = `Sisa Hadiah: ${giftsLeft}`;
		renderList();
		updateButtonsState();
	}

	function updateButtonsState() {
		const disable = candidates.length === 0 || giftsLeft === 0 || isRunning;
		startBtn.disabled = disable;
	}

	function renderList() {
		nameList.innerHTML = '';
		for (const c of candidates) {
			const li = document.createElement('li');
			li.dataset.id = String(c.id);
			li.textContent = c.nama;
			nameList.appendChild(li);
		}
	}

	function highlight(index) {
		const items = nameList.children;
		if (highlightedIndex >= 0 && items[highlightedIndex]) {
			items[highlightedIndex].classList.remove('highlight');
		}
		highlightedIndex = index;
		if (items[highlightedIndex]) {
			items[highlightedIndex].classList.add('highlight');
			// Ensure visibility
			const box = document.getElementById('scroll-box');
			const el = items[highlightedIndex];
			const top = el.offsetTop;
			const height = el.offsetHeight;
			const boxTop = box.scrollTop;
			const boxHeight = box.clientHeight;
			if (top < boxTop || top + height > boxTop + boxHeight) {
				box.scrollTop = Math.max(0, top - (boxHeight / 2) + (height / 2));
			}
		}
	}

	function getRandomInt(min, max) {
		return Math.floor(Math.random() * (max - min + 1)) + min;
	}

	async function startDraw() {
		if (isRunning) return;
		if (candidates.length === 0) { showToast('Tidak ada kandidat.'); return; }
		if (giftsLeft <= 0) { showToast('Hadiah sudah habis.'); updateButtonsState(); return; }
		isRunning = true;
		startBtn.disabled = true;
		refreshBtn.disabled = true;
		winnerArea.textContent = '';

		let idx = 0;
		let intervalMs = 50; // fast cycle
		const minRunMs = 5000; // at least 5s
		const extraMs = getRandomInt(1000, 4000); // add 1-4s random
		const totalMs = minRunMs + extraMs;

		scrollTimer = setInterval(() => {
			if (candidates.length === 0) return;
			idx = (idx + 1) % candidates.length;
			highlight(idx);
		}, intervalMs);

		await new Promise(resolve => setTimeout(resolve, totalMs));

		clearInterval(scrollTimer);
		scrollTimer = null;

		// Slow down deceleration effect (optional)
		for (let d = 0; d < 8; d++) {
			await new Promise(r => setTimeout(r, 100 + d * 60));
			idx = (idx + 1) % candidates.length;
			highlight(idx);
		}

		const chosen = candidates[idx];

		try {
			const res = await fetch('api/draw.php', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ karyawan_id: chosen.id })
			});
			const data = await res.json();
			if (!res.ok || data.status !== 'ok') {
				throw new Error(data.message || 'Gagal menyimpan pemenang');
			}

			// Remove chosen from candidates and UI
			candidates = candidates.filter(c => c.id !== chosen.id);
			renderList();

			winnerArea.innerHTML = `${data.winner.nama} menang!` +
				`<div class="winner-badge">Hadiah #${data.gift.urut}: ${data.gift.nama_hadiah}</div>`;

			infoCandidates.textContent = `Kandidat: ${candidates.length}`;
			giftsLeft = Math.max(0, giftsLeft - 1);
			infoGifts.textContent = `Sisa Hadiah: ${giftsLeft}`;

			showToast('Pemenang disimpan.');
		} catch (err) {
			console.error(err);
			showToast(err.message || 'Terjadi kesalahan.');
		} finally {
			isRunning = false;
			refreshBtn.disabled = false;
			updateButtonsState();
		}
	}

	startBtn.addEventListener('click', startDraw);
	refreshBtn.addEventListener('click', () => { loadCandidates().catch(e => showToast(String(e))); });

	// Initial load
	loadCandidates().catch(e => showToast(String(e)));
})();