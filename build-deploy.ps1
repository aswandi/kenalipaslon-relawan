# ===== CONFIG =====
$zipName = "deploy.zip"
$buildDir = "deploy_build"

Write-Host "=== 1. Bersihkan folder build lama ==="
Remove-Item -Recurse -Force $buildDir -ErrorAction SilentlyContinue
Remove-Item -Force $zipName -ErrorAction SilentlyContinue

Write-Host "=== 2. Composer install (production mode) ==="
composer install --optimize-autoloader --no-dev

Write-Host "=== 3. Build asset Vue/Vite ==="
npm install
npm run build

Write-Host "=== 4. Copy project ke folder build ==="
New-Item -ItemType Directory -Path $buildDir | Out-Null
robocopy . $buildDir /E /XD $buildDir node_modules .git tests /XF .env .env.example .gitignore bootstrap\cache\config.php

Write-Host "=== 5. Bersihkan file development di build ==="
Remove-Item -Recurse -Force "$buildDir\node_modules" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$buildDir\tests" -ErrorAction SilentlyContinue
Remove-Item -Force "$buildDir\.env" -ErrorAction SilentlyContinue
Remove-Item -Force "$buildDir\.env.example" -ErrorAction SilentlyContinue
Remove-Item -Force "$buildDir\bootstrap\cache\config.php" -ErrorAction SilentlyContinue

Write-Host "=== 6. Cache config Laravel (di lokal) ==="
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache

Write-Host "=== 7. Kompres menjadi $zipName ==="
Compress-Archive -Path "$buildDir\*" -DestinationPath $zipName -Force

Write-Host "=== Selesai! File siap upload: $zipName ==="
