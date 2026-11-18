# Travel Wishlist Flutter - Starter

## Cara memasang
1. Ekstrak ZIP ini.
2. Buka PowerShell pada folder hasil ekstrak.
3. Jalankan `flutter create .` untuk membuat folder platform Android/iOS dan file proyek standar (jika diminta menimpa, jangan timpa `lib/main.dart` atau `pubspec.yaml`).
4. Jalankan `flutter pub get`.

## Mengatur alamat API
Di `lib/main.dart`, ubah `defaultValue` pada `baseUrl` menjadi alamat IPv4 laptop, misalnya:
`http://192.168.1.5:8090`

Untuk mencari IP laptop, jalankan `ipconfig` dan cari IPv4 Address pada Wi-Fi. HP dan laptop harus terhubung ke Wi-Fi yang sama. Backend Docker harus aktif dan port API 8090 dapat diakses dari HP.

Alternatif saat menjalankan:
`flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8090`

Untuk Android Emulator gunakan:
`http://10.0.2.2:8090`

## Jalankan
`flutter run`

Starter ini menyediakan login, register, daftar wishlist, tambah, edit, hapus, kategori, dan penyimpanan token login. Upload foto belum dimasukkan pada tahap awal.
