<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['POST']);

$data = request_data();
$name = trim((string)($data['name'] ?? ''));
$email = strtolower(trim((string)($data['email'] ?? '')));
$password = (string)($data['password'] ?? '');

if ($name === '' || $email === '' || $password === '') {
    json_response(['success' => false, 'message' => 'Nama, email, dan password wajib diisi.'], 422);
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    json_response(['success' => false, 'message' => 'Format email tidak valid.'], 422);
}
if (strlen($password) < 8) {
    json_response(['success' => false, 'message' => 'Password minimal 8 karakter.'], 422);
}

$stmt = $pdo->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
$stmt->execute(['email' => $email]);
if ($stmt->fetch()) {
    json_response(['success' => false, 'message' => 'Email sudah terdaftar.'], 409);
}

$stmt = $pdo->prepare('INSERT INTO users (name, email, password_hash) VALUES (:name, :email, :password_hash)');
$stmt->execute([
    'name' => $name,
    'email' => $email,
    'password_hash' => password_hash($password, PASSWORD_DEFAULT),
]);
$userId = (int)$pdo->lastInsertId();
$token = issue_token($pdo, $userId);

json_response([
    'success' => true,
    'message' => 'Registrasi berhasil.',
    'data' => [
        'user' => ['id' => $userId, 'name' => $name, 'email' => $email],
        'token' => $token,
        'token_type' => 'Bearer'
    ]
], 201);
