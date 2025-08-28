# Kenali Paslon - Relawan

Aplikasi web untuk manajemen relawan pemenangan pasangan calon. Dibangun dengan framework Laravel.

## Tentang Proyek

Proyek ini bertujuan untuk menyediakan platform digital bagi para relawan untuk berkoordinasi, mengelola data pemilih, dan menjalankan program-program pemenangan secara efektif dan terukur.

## Memulai

Untuk menjalankan proyek ini secara lokal, ikuti langkah-langkah berikut.

### Prasyarat

Pastikan Anda memiliki software berikut terinstal:
*   PHP >= 8.1
*   Composer
*   Node.js & NPM
*   Database (misalnya MySQL, PostgreSQL, atau SQLite)

### Instalasi

1.  Clone repositori:
    ```sh
    git clone https://github.com/aswandi/kenalipaslon-relawan.git
    ```
2.  Masuk ke direktori proyek:
    ```sh
    cd kenalipaslon-relawan
    ```
3.  Install dependensi PHP:
    ```sh
    composer install
    ```
4.  Install dependensi JavaScript:
    ```sh
    npm install
    ```
5.  Salin file `.env.backup` menjadi `.env`:
    ```sh
    cp .env.backup .env
    ```
6.  Buat kunci aplikasi:
    ```sh
    php artisan key:generate
    ```
7.  Konfigurasikan koneksi database Anda di file `.env`.
8.  Jalankan migrasi database:
    ```sh
    php artisan migrate
    ```
9.  Jalankan server pengembangan:
    ```sh
    php artisan serve
    ```