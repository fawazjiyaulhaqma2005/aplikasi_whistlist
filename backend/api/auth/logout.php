<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['POST']);

$token = bearer_token();
if (!$token) {
    json_response(['success' => false, 'message' => 'Token autentikasi diperlukan.'], 401);
}

$stmt = $pdo->prepare('DELETE FROM user_tokens WHERE token_hash = :token_hash');
$stmt->execute(['token_hash' => hash('sha256', $token)]);

json_response(['success' => true, 'message' => 'Logout berhasil.']);
