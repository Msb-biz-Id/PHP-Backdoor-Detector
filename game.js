// Game variables
const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');
const scoreElement = document.getElementById('score');

// Game constants
const GRAVITY = 0.6;
const JUMP_STRENGTH = -12;
const PIPE_WIDTH = 80;
const PIPE_GAP = 200;
const PIPE_SPEED = 2;
const BIRD_SIZE = 30;

// Game state
let gameState = 'start'; // 'start', 'playing', 'gameOver'
let score = 0;
let pipes = [];
let particles = [];

// Bird object
const bird = {
    x: 100,
    y: canvas.height / 2,
    velocity: 0,
    rotation: 0
};

// Pipe generation
let pipeTimer = 0;
const PIPE_SPAWN_RATE = 120; // frames between pipes

// Initialize game
function init() {
    bird.x = 100;
    bird.y = canvas.height / 2;
    bird.velocity = 0;
    bird.rotation = 0;
    score = 0;
    pipes = [];
    particles = [];
    pipeTimer = 0;
    updateScore();
}

// Update score display
function updateScore() {
    scoreElement.textContent = `Score: ${score}`;
}

// Create pipe
function createPipe() {
    const minHeight = 50;
    const maxHeight = canvas.height - PIPE_GAP - minHeight;
    const topHeight = Math.random() * (maxHeight - minHeight) + minHeight;
    
    pipes.push({
        x: canvas.width,
        topHeight: topHeight,
        bottomY: topHeight + PIPE_GAP,
        bottomHeight: canvas.height - (topHeight + PIPE_GAP),
        scored: false
    });
}

// Create particle effect
function createParticles(x, y, color = '#FFD700') {
    for (let i = 0; i < 8; i++) {
        particles.push({
            x: x,
            y: y,
            vx: (Math.random() - 0.5) * 8,
            vy: (Math.random() - 0.5) * 8,
            life: 30,
            maxLife: 30,
            color: color
        });
    }
}

// Update bird physics
function updateBird() {
    if (gameState === 'playing') {
        bird.velocity += GRAVITY;
        bird.y += bird.velocity;
        
        // Rotation based on velocity
        bird.rotation = Math.min(Math.max(bird.velocity * 0.1, -0.5), 0.5);
        
        // Check boundaries
        if (bird.y < 0) {
            bird.y = 0;
            bird.velocity = 0;
        }
        
        if (bird.y > canvas.height - BIRD_SIZE) {
            gameState = 'gameOver';
        }
    }
}

// Update pipes
function updatePipes() {
    if (gameState === 'playing') {
        // Spawn new pipes
        pipeTimer++;
        if (pipeTimer >= PIPE_SPAWN_RATE) {
            createPipe();
            pipeTimer = 0;
        }
        
        // Move pipes
        for (let i = pipes.length - 1; i >= 0; i--) {
            const pipe = pipes[i];
            pipe.x -= PIPE_SPEED;
            
            // Remove off-screen pipes
            if (pipe.x + PIPE_WIDTH < 0) {
                pipes.splice(i, 1);
                continue;
            }
            
            // Check scoring
            if (!pipe.scored && pipe.x + PIPE_WIDTH < bird.x) {
                pipe.scored = true;
                score++;
                updateScore();
                createParticles(bird.x, bird.y, '#00FF00');
            }
            
            // Check collision
            if (checkCollision(bird, pipe)) {
                gameState = 'gameOver';
                createParticles(bird.x, bird.y, '#FF0000');
            }
        }
    }
}

// Update particles
function updateParticles() {
    for (let i = particles.length - 1; i >= 0; i--) {
        const particle = particles[i];
        particle.x += particle.vx;
        particle.y += particle.vy;
        particle.vy += 0.3; // gravity
        particle.life--;
        
        if (particle.life <= 0) {
            particles.splice(i, 1);
        }
    }
}

// Check collision between bird and pipe
function checkCollision(bird, pipe) {
    const birdLeft = bird.x - BIRD_SIZE / 2;
    const birdRight = bird.x + BIRD_SIZE / 2;
    const birdTop = bird.y - BIRD_SIZE / 2;
    const birdBottom = bird.y + BIRD_SIZE / 2;
    
    const pipeLeft = pipe.x;
    const pipeRight = pipe.x + PIPE_WIDTH;
    
    // Check if bird is within pipe's horizontal range
    if (birdRight > pipeLeft && birdLeft < pipeRight) {
        // Check collision with top pipe or bottom pipe
        if (birdTop < pipe.topHeight || birdBottom > pipe.bottomY) {
            return true;
        }
    }
    
    return false;
}

// Make bird jump
function jump() {
    if (gameState === 'start') {
        gameState = 'playing';
    }
    
    if (gameState === 'playing') {
        bird.velocity = JUMP_STRENGTH;
        createParticles(bird.x - 20, bird.y, '#87CEEB');
    }
    
    if (gameState === 'gameOver') {
        init();
        gameState = 'start';
    }
}

// Draw bird
function drawBird() {
    ctx.save();
    ctx.translate(bird.x, bird.y);
    ctx.rotate(bird.rotation);
    
    // Bird body
    ctx.fillStyle = '#FFD700';
    ctx.beginPath();
    ctx.arc(0, 0, BIRD_SIZE / 2, 0, Math.PI * 2);
    ctx.fill();
    
    // Bird wing
    ctx.fillStyle = '#FFA500';
    ctx.beginPath();
    ctx.ellipse(-8, -5, 12, 8, 0, 0, Math.PI * 2);
    ctx.fill();
    
    // Bird eye
    ctx.fillStyle = 'white';
    ctx.beginPath();
    ctx.arc(5, -8, 6, 0, Math.PI * 2);
    ctx.fill();
    
    ctx.fillStyle = 'black';
    ctx.beginPath();
    ctx.arc(7, -8, 3, 0, Math.PI * 2);
    ctx.fill();
    
    // Bird beak
    ctx.fillStyle = '#FF4500';
    ctx.beginPath();
    ctx.moveTo(12, -3);
    ctx.lineTo(20, 0);
    ctx.lineTo(12, 3);
    ctx.closePath();
    ctx.fill();
    
    ctx.restore();
}

// Draw pipe
function drawPipe(pipe) {
    const gradient = ctx.createLinearGradient(pipe.x, 0, pipe.x + PIPE_WIDTH, 0);
    gradient.addColorStop(0, '#228B22');
    gradient.addColorStop(0.5, '#32CD32');
    gradient.addColorStop(1, '#228B22');
    
    ctx.fillStyle = gradient;
    
    // Top pipe
    ctx.fillRect(pipe.x, 0, PIPE_WIDTH, pipe.topHeight);
    
    // Bottom pipe
    ctx.fillRect(pipe.x, pipe.bottomY, PIPE_WIDTH, pipe.bottomHeight);
    
    // Pipe caps
    ctx.fillStyle = '#006400';
    ctx.fillRect(pipe.x - 5, pipe.topHeight - 30, PIPE_WIDTH + 10, 30);
    ctx.fillRect(pipe.x - 5, pipe.bottomY, PIPE_WIDTH + 10, 30);
}

// Draw particles
function drawParticles() {
    particles.forEach(particle => {
        const alpha = particle.life / particle.maxLife;
        ctx.globalAlpha = alpha;
        ctx.fillStyle = particle.color;
        ctx.beginPath();
        ctx.arc(particle.x, particle.y, 3, 0, Math.PI * 2);
        ctx.fill();
    });
    ctx.globalAlpha = 1;
}

// Draw background
function drawBackground() {
    const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
    gradient.addColorStop(0, '#87CEEB');
    gradient.addColorStop(1, '#98FB98');
    
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Draw clouds
    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    for (let i = 0; i < 5; i++) {
        const x = (Date.now() * 0.01 + i * 100) % (canvas.width + 100) - 50;
        const y = 50 + i * 30;
        drawCloud(x, y);
    }
}

// Draw cloud
function drawCloud(x, y) {
    ctx.beginPath();
    ctx.arc(x, y, 20, 0, Math.PI * 2);
    ctx.arc(x + 25, y, 25, 0, Math.PI * 2);
    ctx.arc(x + 50, y, 20, 0, Math.PI * 2);
    ctx.arc(x + 25, y - 15, 20, 0, Math.PI * 2);
    ctx.fill();
}

// Draw game over screen
function drawGameOver() {
    ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    ctx.fillStyle = 'white';
    ctx.font = 'bold 48px Arial';
    ctx.textAlign = 'center';
    ctx.fillText('Game Over!', canvas.width / 2, canvas.height / 2 - 50);
    
    ctx.font = '24px Arial';
    ctx.fillText(`Final Score: ${score}`, canvas.width / 2, canvas.height / 2);
    
    ctx.font = '18px Arial';
    ctx.fillText('Press SPACE or Click to restart', canvas.width / 2, canvas.height / 2 + 50);
}

// Draw start screen
function drawStartScreen() {
    ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    ctx.fillStyle = 'white';
    ctx.font = 'bold 36px Arial';
    ctx.textAlign = 'center';
    ctx.fillText('Flappy Bird', canvas.width / 2, canvas.height / 2 - 50);
    
    ctx.font = '18px Arial';
    ctx.fillText('Press SPACE or Click to start!', canvas.width / 2, canvas.height / 2 + 20);
}

// Main game loop
function gameLoop() {
    // Clear canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw background
    drawBackground();
    
    // Update game objects
    updateBird();
    updatePipes();
    updateParticles();
    
    // Draw pipes
    pipes.forEach(drawPipe);
    
    // Draw bird
    drawBird();
    
    // Draw particles
    drawParticles();
    
    // Draw UI overlays
    if (gameState === 'start') {
        drawStartScreen();
    } else if (gameState === 'gameOver') {
        drawGameOver();
    }
    
    requestAnimationFrame(gameLoop);
}

// Event listeners
document.addEventListener('keydown', (e) => {
    if (e.code === 'Space') {
        e.preventDefault();
        jump();
    }
});

canvas.addEventListener('click', jump);

// Prevent context menu on right click
canvas.addEventListener('contextmenu', (e) => e.preventDefault());

// Initialize and start game
init();
gameLoop();