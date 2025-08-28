@echo off
chcp 65001 >nul
echo 🚀 Mempersiapkan aplikasi untuk server Ubuntu dengan Nginx...

REM Membuat direktori sementara untuk build
set BUILD_DIR=build_for_cpanel
if exist %BUILD_DIR% rmdir /s /q %BUILD_DIR%
mkdir %BUILD_DIR%

echo 📁 Menyalin file Laravel...

REM Copy semua file Laravel kecuali yang tidak diperlukan
robocopy . %BUILD_DIR% /E /XD node_modules .git storage\logs bootstrap\cache %BUILD_DIR% /XF *.log .env

cd %BUILD_DIR%

echo 🔧 Install dependencies dan build assets...

REM Install npm dependencies dan build
call npm install
call npm run build

if errorlevel 1 (
    echo ❌ Build gagal! Pastikan npm dan dependencies tersedia.
    pause
    exit /b 1
)

echo 🧹 Membersihkan file development...

REM Hapus file yang tidak diperlukan untuk production
rmdir /s /q node_modules 2>nul
rmdir /s /q .git 2>nul
rmdir /s /q tests 2>nul
rmdir /s /q .github 2>nul
del package.json 2>nul
del package-lock.json 2>nul
del vite.config.js 2>nul
del tailwind.config.js 2>nul
del postcss.config.js 2>nul
rmdir /s /q resources\js 2>nul
rmdir /s /q resources\css 2>nul
rmdir /s /q resources\sass 2>nul

echo ⚙️ Mengoptimalkan autoload...

REM Optimize composer autoload (jika composer tersedia di local)
where composer >nul 2>nul
if %errorlevel% equ 0 (
    call composer install --no-dev --optimize-autoloader
    call composer dump-autoload --optimize
) else (
    echo ⚠️ Composer tidak tersedia, pastikan vendor folder sudah di-commit
)

echo 📝 Membuat file konfigurasi untuk Nginx + Ubuntu...

REM Membuat nginx configuration
mkdir nginx-config 2>nul
(
echo server {
echo     listen 80;
echo     listen [::]:80;
echo     server_name yourdomain.com www.yourdomain.com;
echo     return 301 https://$server_name$request_uri;
echo }
echo.
echo server {
echo     listen 443 ssl http2;
echo     listen [::]:443 ssl http2;
echo     server_name yourdomain.com www.yourdomain.com;
echo.
echo     # SSL Configuration
echo     ssl_certificate /etc/ssl/certs/yourdomain.com.crt;
echo     ssl_certificate_key /etc/ssl/private/yourdomain.com.key;
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
echo     ssl_prefer_server_ciphers off;
echo     ssl_session_cache shared:SSL:10m;
echo.
echo     root /var/www/yourdomain.com/public;
echo     index index.php index.html index.htm;
echo.
echo     # Security headers
echo     add_header X-Frame-Options "SAMEORIGIN" always;
echo     add_header X-Content-Type-Options "nosniff" always;
echo     add_header X-XSS-Protection "1; mode=block" always;
echo     add_header Referrer-Policy "no-referrer-when-downgrade" always;
echo     add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
echo.
echo     # Gzip compression
echo     gzip on;
echo     gzip_vary on;
echo     gzip_min_length 1024;
echo     gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
echo.
echo     # Handle Vue.js history mode routing
echo     location / {
echo         try_files $uri $uri/ @fallback;
echo     }
echo.
echo     # Handle API routes
echo     location /api {
echo         try_files $uri $uri/ /index.php?$query_string;
echo     }
echo.
echo     # Handle admin routes if any
echo     location /admin {
echo         try_files $uri $uri/ /index.php?$query_string;
echo     }
echo.
echo     # Fallback for Vue.js routes
echo     location @fallback {
echo         rewrite ^.*$ /index.html last;
echo     }
echo.
echo     # PHP handling
echo     location ~ \.php$ {
echo         fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
echo         fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
echo         include fastcgi_params;
echo         fastcgi_hide_header X-Powered-By;
echo     }
echo.
echo     # Static file caching
echo     location ~* \.(js^|css^|png^|jpg^|jpeg^|gif^|ico^|svg^|webp^)$ {
echo         expires 1y;
echo         add_header Cache-Control "public, immutable";
echo         access_log off;
echo     }
echo.
echo     # Security: deny access to sensitive files
echo     location ~ /\.(env^|git^|svn) {
echo         deny all;
echo         return 404;
echo     }
echo.
echo     location ~ /\.ht {
echo         deny all;
echo         return 404;
echo     }
echo.
echo     # Deny access to storage and bootstrap/cache
echo     location ~ ^/(storage^|bootstrap/cache) {
echo         deny all;
echo         return 404;
echo     }
echo }
) > nginx-config\site.conf

REM Membuat file .env.production untuk production
(
echo APP_NAME=Laravel
echo APP_ENV=production
echo APP_KEY=
echo APP_DEBUG=false
echo APP_URL=https://yourdomain.com
echo.
echo LOG_CHANNEL=stack
echo LOG_DEPRECATIONS_CHANNEL=null
echo LOG_LEVEL=error
echo.
echo DB_CONNECTION=mysql
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_DATABASE=your_database_name
echo DB_USERNAME=your_database_user
echo DB_PASSWORD=your_database_password
echo.
echo BROADCAST_DRIVER=log
echo CACHE_DRIVER=file
echo FILESYSTEM_DISK=local
echo QUEUE_CONNECTION=sync
echo SESSION_DRIVER=file
echo SESSION_LIFETIME=120
echo.
echo MEMCACHED_HOST=127.0.0.1
echo.
echo REDIS_HOST=127.0.0.1
echo REDIS_PASSWORD=null
echo REDIS_PORT=6379
echo.
echo MAIL_MAILER=smtp
echo MAIL_HOST=mailpit
echo MAIL_PORT=1025
echo MAIL_USERNAME=null
echo MAIL_PASSWORD=null
echo MAIL_ENCRYPTION=null
echo MAIL_FROM_ADDRESS="hello@example.com"
echo MAIL_FROM_NAME="${APP_NAME}"
echo.
echo PUSHER_APP_ID=
echo PUSHER_APP_KEY=
echo PUSHER_APP_SECRET=
echo PUSHER_HOST=
echo PUSHER_PORT=443
echo PUSHER_SCHEME=https
echo PUSHER_APP_CLUSTER=mt1
echo.
echo VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
echo VITE_PUSHER_HOST="${PUSHER_HOST}"
echo VITE_PUSHER_PORT="${PUSHER_PORT}"
echo VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
echo VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
) > .env.production

echo 📄 Membuat panduan deployment...

(
echo === PANDUAN DEPLOYMENT KE SERVER UBUNTU ===
echo.
echo 1. PERSIAPAN SERVER:
echo    sudo apt update
echo    sudo apt install nginx php8.2-fpm php8.2-mysql php8.2-xml php8.2-mbstring php8.2-curl php8.2-zip unzip
echo    sudo systemctl enable nginx php8.2-fpm
echo.
echo 2. UPLOAD FILE:
echo    - Upload zip file ke server
echo    - Extract ke /var/www/yourdomain.com/
echo    - Set ownership: sudo chown -R www-data:www-data /var/www/yourdomain.com
echo    - Set permission: sudo chmod -R 755 /var/www/yourdomain.com
echo    - Set permission khusus: sudo chmod -R 775 /var/www/yourdomain.com/storage
echo    - Set permission khusus: sudo chmod -R 775 /var/www/yourdomain.com/bootstrap/cache
echo.
echo 3. KONFIGURASI NGINX:
echo    - Copy nginx-config/site.conf ke /etc/nginx/sites-available/yourdomain.com
echo    - Edit sesuai domain dan path Anda
echo    - sudo ln -s /etc/nginx/sites-available/yourdomain.com /etc/nginx/sites-enabled/
echo    - sudo nginx -t  (test konfigurasi^)
echo    - sudo systemctl reload nginx
echo.
echo 4. KONFIGURASI DATABASE:
echo    sudo mysql -u root -p
echo    CREATE DATABASE laravel_db;
echo    CREATE USER 'laravel_user'@'localhost' IDENTIFIED BY 'strong_password';
echo    GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel_user'@'localhost';
echo    FLUSH PRIVILEGES;
echo    EXIT;
echo.
echo 5. KONFIGURASI APLIKASI:
echo    - Rename .env.production menjadi .env
echo    - Edit konfigurasi database di .env
echo    - Generate APP_KEY: php artisan key:generate
echo    - Run migration: php artisan migrate
echo    - Cache config: php artisan config:cache
echo    - Cache route: php artisan route:cache
echo    - Cache view: php artisan view:cache
echo.
echo 6. SSL CERTIFICATE (Let's Encrypt^):
echo    sudo apt install certbot python3-certbot-nginx
echo    sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
echo    sudo systemctl enable certbot.timer
echo.
echo 7. FIREWALL:
echo    sudo ufw allow 22
echo    sudo ufw allow 80
echo    sudo ufw allow 443
echo    sudo ufw enable
echo.
echo 8. MONITORING LOG:
echo    - Nginx error log: sudo tail -f /var/log/nginx/error.log
echo    - Laravel log: sudo tail -f /var/www/yourdomain.com/storage/logs/laravel.log
echo    - PHP-FPM log: sudo tail -f /var/log/php8.2-fpm.log
echo.
echo === TROUBLESHOOTING ===
echo.
echo 500 Internal Server Error:
echo - Periksa permission folder storage/ dan bootstrap/cache/
echo - Periksa konfigurasi .env
echo - Periksa nginx error log
echo - Pastikan PHP-FPM berjalan: sudo systemctl status php8.2-fpm
echo.
echo 403 Forbidden:
echo - Periksa ownership dan permission file
echo - sudo chown -R www-data:www-data /var/www/yourdomain.com
echo.
echo Vue Router tidak berfungsi:
echo - Periksa konfigurasi nginx untuk fallback routing
echo - Reload nginx: sudo systemctl reload nginx
echo.
echo Database connection error:
echo - Test koneksi: php artisan tinker, DB::connection^^^(^^^)^^^->getPdo^^^(^^^);
echo - Periksa konfigurasi database di .env
echo.
echo === OPTIMASI PERFORMA ===
echo.
echo 1. OPCache PHP:
echo    sudo nano /etc/php/8.2/fpm/php.ini
echo    opcache.enable=1
echo    opcache.memory_consumption=256
echo    opcache.max_accelerated_files=20000
echo    sudo systemctl restart php8.2-fpm
echo.
echo 2. Redis Cache (opsional^):
echo    sudo apt install redis-server
echo    composer require predis/predis
echo    Edit .env: CACHE_DRIVER=redis, SESSION_DRIVER=redis
echo.
echo 3. Supervisor untuk Queue (jika menggunakan queue^):
echo    sudo apt install supervisor
echo    sudo nano /etc/supervisor/conf.d/laravel-worker.conf
echo.
echo === BACKUP AUTOMATION ===
echo.
echo 1. Database backup script:
echo    nano ~/backup-db.sh
echo    #!/bin/bash
echo    mysqldump -u laravel_user -p laravel_db ^> /backup/db-$(date +%%Y%%m%%d).sql
echo    find /backup/ -name "db-*.sql" -mtime +7 -delete
echo.
echo 2. Crontab untuk automation:
echo    crontab -e
echo    0 2 * * * ~/backup-db.sh
echo    0 3 * * * tar -czf /backup/files-$(date +%%Y%%m%%d).tar.gz /var/www/yourdomain.com
) > DEPLOYMENT_GUIDE.txt
) > DEPLOYMENT_GUIDE.txt

echo 🗜️ Membuat file zip...

cd ..

REM Get current date for filename
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set BUILD_DATE=%datetime:~0,8%

powershell -command "Compress-Archive -Path '%BUILD_DIR%\*' -DestinationPath 'laravel-vue-production-%BUILD_DATE%.zip' -Force"

echo ✅ Build selesai!
echo 📦 File zip tersedia: laravel-vue-production-%BUILD_DATE%.zip
echo 📖 Baca DEPLOYMENT_GUIDE.txt untuk panduan deployment Ubuntu
echo 🌐 Lihat nginx-config/site.conf untuk konfigurasi Nginx
echo.
echo 🚨 LANGKAH SELANJUTNYA:
echo    1. Upload zip ke server Ubuntu
echo    2. Extract ke /var/www/yourdomain.com/
echo    3. Setup nginx dengan konfigurasi yang disediakan
echo    4. Konfigurasi database MySQL
echo    5. Setup SSL dengan Let's Encrypt
echo    6. Test aplikasi

pause
