<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['POST']);

$data = request_data();
$email = strtolower(trim((string)($data['email'] ?? '')));
$password = (string)($data['password'] ?? '');

if ($email === '' || $password === '') {
    json_response(['success' => false, 'message' => 'Email dan password wajib diisi.'], 422);
}

$stmt = $pdo->prepare('SELECT id, name, email, password_hash FROM users WHERE email = :email LIMIT 1');
$stmt->execute(['email' => $email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    json_response(['success' => false, 'message' => 'Email atau password salah.'], 401);
}

$token = issue_token($pdo, (int)$user['id']);
unset($user['password_hash']);

json_response([
    'success' => true,
    'message' => 'Login berhasil.',
    'data' => [
        'user' => $user,
        'token' => $token,
        'token_type' => 'Bearer'
    ]
]);
