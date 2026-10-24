const assert = require('assert');
const fs = require('fs');
const path = require('path');

console.log('=== Nexora Angular Automated Test Suite ===');

// Test 1: Verify angular.json integrity
const angularConfig = JSON.parse(fs.readFileSync(path.join(__dirname, 'angular.json'), 'utf8'));
assert(angularConfig.projects['inventory-web'], 'Angular project definition missing');
console.log('PASS: Angular workspace configuration verified.');

// Test 2: Verify tsconfig integrity
const tsConfig = JSON.parse(fs.readFileSync(path.join(__dirname, 'tsconfig.app.json'), 'utf8'));
assert(tsConfig.files.includes('src/main.ts'), 'main.ts missing from tsconfig files');
console.log('PASS: TypeScript compilation configurations verified.');

// Test 3: Verify AppComponent source code exports
const appSource = fs.readFileSync(path.join(__dirname, 'src/app/app.component.ts'), 'utf8');
assert(appSource.includes('export class AppComponent'), 'AppComponent definition missing');
assert(appSource.includes('export interface Product'), 'Product model interface missing');
console.log('PASS: Angular Standalone Components and Interfaces verified.');

// Test 4: Verify production distribution index and env loader
const indexHtml = fs.readFileSync(path.join(__dirname, 'src/index.html'), 'utf8');
assert(indexHtml.includes('<script src="env.js"></script>'), 'Runtime environment injection script tag missing');
console.log('PASS: Runtime environment provider verified.');

console.log('\nAll 4 test specs executed successfully with 0 failures.');
process.exit(0);
