# Travel Wishlist

Aplikasi mobile berbasis Flutter untuk mengelola daftar tempat wisata yang ingin dikunjungi. Aplikasi terhubung dengan backend PHP dan database MySQL.

## Teknologi
- Flutter dan Dart
- PHP 8.2
- MySQL 8
- Docker dan Docker Compose
- REST API

## Struktur Proyek
- `flutter/` - aplikasi mobile Flutter
- `backend/` - REST API PHP
- `database/` - struktur dan inisialisasi database
- `docker-compose.yml` - konfigurasi Docker
- `.env.example` - contoh konfigurasi environment

## Konfigurasi Backend
1. Salin `.env.example` menjadi `.env`.
2. Isi password database pada file `.env`.
3. Jalankan:

```bash
docker compose up --build -d
cd flutter
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8090
flutter run --dart-define=API_BASE_URL=http://IP-LAPTOP:8090

### Langkah 2 — Masukkan file ke daftar persiapan Git

Jalankan:

```powershell
git add .git status --short
git diff --cached --stat
@'
# Travel Wishlist

Aplikasi mobile berbasis Flutter untuk mengelola daftar tempat wisata yang ingin dikunjungi. Aplikasi terhubung dengan backend PHP dan database MySQL.

## Teknologi
- Flutter dan Dart
- PHP 8.2
- MySQL 8
- Docker dan Docker Compose
- REST API

## Struktur Proyek
- flutter/ : aplikasi mobile Flutter
- backend/ : REST API PHP
- database/ : inisialisasi database
- docker-compose.yml : konfigurasi Docker
- .env.example : contoh konfigurasi

## Konfigurasi Backend
1. Salin .env.example menjadi .env.
2. Isi password database pada file .env.
3. Jalankan docker compose up --build -d.

Backend tersedia di http://localhost:8090.

Endpoint pemeriksaan:
http://localhost:8090/api/health.php

## Menjalankan Flutter
Masuk ke folder flutter, kemudian jalankan:

    flutter pub get

Untuk emulator Android:

    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8090

Untuk HP Android, gunakan IP laptop yang aktif:

    flutter run --dart-define=API_BASE_URL=http://IP-LAPTOP:8090

## Keamanan
- Jangan unggah file .env.
- Jangan unggah password asli.
- File upload pengguna tidak disertakan dalam repositori.
