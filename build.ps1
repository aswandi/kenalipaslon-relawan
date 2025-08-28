# ===== CONFIG =====
$zipName = "deploy.zip"
$buildDir = "deploy_build"

Write-Host "=== 1. Hapus folder build lama ==="
Remove-Item -Recurse -Force $buildDir -ErrorAction SilentlyContinue
Remove-Item -Force $zipName -ErrorAction SilentlyContinue

Write-Host "=== 2. Composer install (production mode) ==="
composer install --optimize-autoloader --no-dev

Write-Host "=== 3. Build Vue (Vite) ==="
npm install
npm run build

Write-Host "=== 4. Copy project ke folder build ==="
New-Item -ItemType Directory -Path $buildDir | Out-Null
robocopy . $buildDir /E /XD $buildDir node_modules .git tests /XF .env.example .gitignore

Write-Host "=== 5. Hapus file dev di build ==="
Remove-Item -Recurse -Force "$buildDir\node_modules" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$buildDir\tests" -ErrorAction SilentlyContinue

Write-Host "=== 6. Cache config Laravel ==="
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache

Write-Host "=== 7. Kompres jadi $zipName ==="
Compress-Archive -Path "$buildDir\*" -DestinationPath $zipName -Force

Write-Host "=== Selesai! File siap upload: $zipName ==="
