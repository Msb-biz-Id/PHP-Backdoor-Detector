// Game Configuration
const config = {
    canvas: {
        width: 400,
        height: 600
    },
    bird: {
        x: 80,
        width: 34,
        height: 24,
        gravity: 0.5,
        jumpStrength: -8,
        colors: ['#FFD700', '#FFA500', '#FF6347'] // Gold, Orange, Tomato
    },
    pipes: {
        width: 52,
        gap: 150,
        speed: 2,
        spacing: 200,
        colors: {
            top: '#2ECC40',
            bottom: '#27AE60',
            border: '#1E8449'
        }
    },
    game: {
        fps: 60
    }
};

// Game State
let gameState = {
    bird: {
        y: config.canvas.height / 2,
        velocity: 0,
        rotation: 0
    },
    pipes: [],
    score: 0,
    bestScore: localStorage.getItem('flappyBirdBest') || 0,
    gameStatus: 'waiting', // waiting, playing, paused, gameover
    frame: 0,
    isMuted: false
};

// Canvas Setup
const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');
canvas.width = config.canvas.width;
canvas.height = config.canvas.height;

// DOM Elements
const startScreen = document.getElementById('startScreen');
const gameOverScreen = document.getElementById('gameOverScreen');
const currentScoreEl = document.getElementById('currentScore');
const bestScoreEl = document.getElementById('bestScore');
const finalScoreEl = document.getElementById('finalScore');
const finalBestEl = document.getElementById('finalBest');
const startBtn = document.getElementById('startBtn');
const restartBtn = document.getElementById('restartBtn');
const pauseBtn = document.getElementById('pauseBtn');
const muteBtn = document.getElementById('muteBtn');

// Initialize best score display
bestScoreEl.textContent = gameState.bestScore;

// Sound Effects (using Web Audio API)
class SoundManager {
    constructor() {
        this.audioContext = null;
        this.sounds = {};
        this.initialized = false;
    }

    init() {
        if (this.initialized) return;
        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            this.initialized = true;
            this.createSounds();
        } catch (e) {
            console.log('Web Audio API not supported');
        }
    }

    createSounds() {
        // Jump sound
        this.sounds.jump = () => {
            if (gameState.isMuted || !this.audioContext) return;
            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();
            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);
            oscillator.frequency.value = 400;
            oscillator.frequency.exponentialRampToValueAtTime(600, this.audioContext.currentTime + 0.1);
            gainNode.gain.value = 0.1;
            gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.1);
            oscillator.start();
            oscillator.stop(this.audioContext.currentTime + 0.1);
        };

        // Score sound
        this.sounds.score = () => {
            if (gameState.isMuted || !this.audioContext) return;
            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();
            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);
            oscillator.frequency.value = 800;
            oscillator.frequency.exponentialRampToValueAtTime(1200, this.audioContext.currentTime + 0.1);
            gainNode.gain.value = 0.1;
            gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.1);
            oscillator.start();
            oscillator.stop(this.audioContext.currentTime + 0.1);
        };

        // Game over sound
        this.sounds.gameOver = () => {
            if (gameState.isMuted || !this.audioContext) return;
            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();
            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);
            oscillator.frequency.value = 300;
            oscillator.frequency.exponentialRampToValueAtTime(100, this.audioContext.currentTime + 0.3);
            gainNode.gain.value = 0.1;
            gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.3);
            oscillator.start();
            oscillator.stop(this.audioContext.currentTime + 0.3);
        };
    }

    play(soundName) {
        if (this.sounds[soundName]) {
            this.sounds[soundName]();
        }
    }
}

const soundManager = new SoundManager();

// Pipe Management
class Pipe {
    constructor(x) {
        this.x = x;
        this.topHeight = Math.random() * (config.canvas.height - config.pipes.gap - 100) + 50;
        this.bottomY = this.topHeight + config.pipes.gap;
        this.passed = false;
    }

    update() {
        this.x -= config.pipes.speed;
    }

    draw() {
        // Draw top pipe
        ctx.fillStyle = config.pipes.colors.top;
        ctx.fillRect(this.x, 0, config.pipes.width, this.topHeight);
        
        // Top pipe border
        ctx.strokeStyle = config.pipes.colors.border;
        ctx.lineWidth = 2;
        ctx.strokeRect(this.x, 0, config.pipes.width, this.topHeight);
        
        // Top pipe cap
        ctx.fillStyle = config.pipes.colors.border;
        ctx.fillRect(this.x - 5, this.topHeight - 30, config.pipes.width + 10, 30);
        
        // Draw bottom pipe
        ctx.fillStyle = config.pipes.colors.bottom;
        ctx.fillRect(this.x, this.bottomY, config.pipes.width, config.canvas.height - this.bottomY);
        
        // Bottom pipe border
        ctx.strokeStyle = config.pipes.colors.border;
        ctx.strokeRect(this.x, this.bottomY, config.pipes.width, config.canvas.height - this.bottomY);
        
        // Bottom pipe cap
        ctx.fillStyle = config.pipes.colors.border;
        ctx.fillRect(this.x - 5, this.bottomY, config.pipes.width + 10, 30);
    }

    isOffScreen() {
        return this.x + config.pipes.width < 0;
    }

    checkCollision(birdX, birdY, birdWidth, birdHeight) {
        // Check if bird is within pipe x range
        if (birdX + birdWidth > this.x && birdX < this.x + config.pipes.width) {
            // Check if bird hits top or bottom pipe
            if (birdY < this.topHeight || birdY + birdHeight > this.bottomY) {
                return true;
            }
        }
        return false;
    }

    checkScore(birdX) {
        if (!this.passed && birdX > this.x + config.pipes.width) {
            this.passed = true;
            return true;
        }
        return false;
    }
}

// Bird Drawing
function drawBird() {
    ctx.save();
    
    // Calculate bird position and rotation
    const birdX = config.bird.x;
    const birdY = gameState.bird.y;
    const rotation = Math.min(Math.max(gameState.bird.velocity * 3, -30), 90) * Math.PI / 180;
    
    // Translate and rotate
    ctx.translate(birdX + config.bird.width / 2, birdY + config.bird.height / 2);
    ctx.rotate(rotation);
    
    // Draw bird body
    ctx.fillStyle = config.bird.colors[0];
    ctx.beginPath();
    ctx.ellipse(0, 0, config.bird.width / 2, config.bird.height / 2, 0, 0, Math.PI * 2);
    ctx.fill();
    
    // Draw wing
    ctx.fillStyle = config.bird.colors[1];
    ctx.beginPath();
    ctx.ellipse(-5, 0, 8, 6, -0.2, 0, Math.PI * 2);
    ctx.fill();
    
    // Draw beak
    ctx.fillStyle = config.bird.colors[2];
    ctx.beginPath();
    ctx.moveTo(config.bird.width / 2 - 2, 0);
    ctx.lineTo(config.bird.width / 2 + 8, 0);
    ctx.lineTo(config.bird.width / 2 - 2, 4);
    ctx.closePath();
    ctx.fill();
    
    // Draw eye
    ctx.fillStyle = 'white';
    ctx.beginPath();
    ctx.arc(8, -3, 5, 0, Math.PI * 2);
    ctx.fill();
    
    ctx.fillStyle = 'black';
    ctx.beginPath();
    ctx.arc(9, -3, 2, 0, Math.PI * 2);
    ctx.fill();
    
    ctx.restore();
}

// Background Drawing
function drawBackground() {
    // Sky gradient
    const gradient = ctx.createLinearGradient(0, 0, 0, config.canvas.height);
    gradient.addColorStop(0, '#87CEEB');
    gradient.addColorStop(1, '#98D8E8');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, config.canvas.width, config.canvas.height);
    
    // Clouds
    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    const cloudOffset = (gameState.frame * 0.2) % (config.canvas.width + 100);
    
    // Cloud 1
    drawCloud(100 - cloudOffset, 100);
    drawCloud(300 - cloudOffset, 200);
    drawCloud(500 - cloudOffset, 150);
    
    // Ground
    ctx.fillStyle = '#8B7355';
    ctx.fillRect(0, config.canvas.height - 50, config.canvas.width, 50);
    
    // Grass
    ctx.fillStyle = '#228B22';
    ctx.fillRect(0, config.canvas.height - 50, config.canvas.width, 10);
}

function drawCloud(x, y) {
    ctx.beginPath();
    ctx.arc(x, y, 25, 0, Math.PI * 2);
    ctx.arc(x + 25, y, 35, 0, Math.PI * 2);
    ctx.arc(x + 50, y, 25, 0, Math.PI * 2);
    ctx.fill();
}

// Game Functions
function jump() {
    if (gameState.gameStatus === 'playing') {
        gameState.bird.velocity = config.bird.jumpStrength;
        soundManager.play('jump');
    }
}

function updateBird() {
    // Apply gravity
    gameState.bird.velocity += config.bird.gravity;
    gameState.bird.y += gameState.bird.velocity;
    
    // Check boundaries
    if (gameState.bird.y < 0) {
        gameState.bird.y = 0;
        gameState.bird.velocity = 0;
    }
    
    if (gameState.bird.y + config.bird.height > config.canvas.height - 50) {
        gameOver();
    }
}

function updatePipes() {
    // Add new pipes
    if (gameState.pipes.length === 0 || 
        gameState.pipes[gameState.pipes.length - 1].x < config.canvas.width - config.pipes.spacing) {
        gameState.pipes.push(new Pipe(config.canvas.width));
    }
    
    // Update and check pipes
    gameState.pipes = gameState.pipes.filter(pipe => {
        pipe.update();
        
        // Check collision
        if (pipe.checkCollision(config.bird.x, gameState.bird.y, config.bird.width, config.bird.height)) {
            gameOver();
        }
        
        // Check score
        if (pipe.checkScore(config.bird.x)) {
            gameState.score++;
            currentScoreEl.textContent = gameState.score;
            soundManager.play('score');
        }
        
        return !pipe.isOffScreen();
    });
}

function gameLoop() {
    // Clear canvas
    ctx.clearRect(0, 0, config.canvas.width, config.canvas.height);
    
    // Draw background
    drawBackground();
    
    if (gameState.gameStatus === 'playing') {
        // Update game state
        updateBird();
        updatePipes();
        gameState.frame++;
    }
    
    // Draw game elements
    gameState.pipes.forEach(pipe => pipe.draw());
    drawBird();
    
    // Continue game loop
    requestAnimationFrame(gameLoop);
}

function startGame() {
    soundManager.init();
    
    // Reset game state
    gameState.bird.y = config.canvas.height / 2;
    gameState.bird.velocity = 0;
    gameState.pipes = [];
    gameState.score = 0;
    gameState.frame = 0;
    gameState.gameStatus = 'playing';
    
    // Update UI
    currentScoreEl.textContent = 0;
    startScreen.classList.add('hidden');
    gameOverScreen.classList.add('hidden');
    pauseBtn.textContent = 'Pause';
}

function gameOver() {
    if (gameState.gameStatus === 'gameover') return;
    
    gameState.gameStatus = 'gameover';
    soundManager.play('gameOver');
    
    // Update best score
    if (gameState.score > gameState.bestScore) {
        gameState.bestScore = gameState.score;
        localStorage.setItem('flappyBirdBest', gameState.bestScore);
        bestScoreEl.textContent = gameState.bestScore;
    }
    
    // Show game over screen
    finalScoreEl.textContent = gameState.score;
    finalBestEl.textContent = gameState.bestScore;
    gameOverScreen.classList.remove('hidden');
}

function togglePause() {
    if (gameState.gameStatus === 'playing') {
        gameState.gameStatus = 'paused';
        pauseBtn.textContent = 'Resume';
    } else if (gameState.gameStatus === 'paused') {
        gameState.gameStatus = 'playing';
        pauseBtn.textContent = 'Pause';
    }
}

function toggleMute() {
    gameState.isMuted = !gameState.isMuted;
    muteBtn.textContent = gameState.isMuted ? 'Unmute' : 'Mute';
}

// Event Listeners
startBtn.addEventListener('click', startGame);
restartBtn.addEventListener('click', startGame);
pauseBtn.addEventListener('click', togglePause);
muteBtn.addEventListener('click', toggleMute);

// Keyboard controls
document.addEventListener('keydown', (e) => {
    if (e.code === 'Space') {
        e.preventDefault();
        if (gameState.gameStatus === 'waiting') {
            startGame();
        } else {
            jump();
        }
    }
});

// Mouse/Touch controls
canvas.addEventListener('click', () => {
    if (gameState.gameStatus === 'waiting') {
        startGame();
    } else {
        jump();
    }
});

canvas.addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (gameState.gameStatus === 'waiting') {
        startGame();
    } else {
        jump();
    }
});

// Start game loop
gameLoop();