<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['POST']);

$user = authenticated_user($pdo);

if (!isset($_FILES['photo']) || $_FILES['photo']['error'] !== UPLOAD_ERR_OK) {
    json_response(['success' => false, 'message' => 'Pilih foto yang akan diunggah.'], 422);
}

$file = $_FILES['photo'];
if ($file['size'] > 5 * 1024 * 1024) {
    json_response(['success' => false, 'message' => 'Ukuran foto maksimal 5 MB.'], 422);
}

$mime = mime_content_type($file['tmp_name']);
$extensions = [
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp',
];
if (!isset($extensions[$mime])) {
    json_response(['success' => false, 'message' => 'Format foto harus JPG, PNG, atau WEBP.'], 422);
}

$filename = bin2hex(random_bytes(16)) . '.' . $extensions[$mime];
$destination = __DIR__ . '/../../uploads/' . $filename;

if (!move_uploaded_file($file['tmp_name'], $destination)) {
    json_response(['success' => false, 'message' => 'Foto gagal disimpan.'], 500);
}

$baseUrl = rtrim(getenv('APP_URL') ?: '', '/');
$photoPath = '/uploads/' . $filename;

json_response([
    'success' => true,
    'message' => 'Foto berhasil diunggah.',
    'data' => [
        'photo_url' => $photoPath,
        'full_url' => $baseUrl . $photoPath
    ]
], 201);
