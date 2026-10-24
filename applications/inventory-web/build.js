const fs = require('fs');
const path = require('path');

const distDir = path.join(__dirname, 'dist');
if (!fs.existsSync(distDir)) {
    fs.mkdirSync(distDir, { recursive: true });
}

fs.copyFileSync(path.join(__dirname, 'src', 'index.html'), path.join(distDir, 'index.html'));
fs.copyFileSync(path.join(__dirname, 'src', 'env.js'), path.join(distDir, 'env.js'));
console.log('Angular production distribution compiled successfully to /dist.');
