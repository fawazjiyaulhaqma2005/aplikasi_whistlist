<?php
function bearer_token(): ?string
{
    $headers = function_exists('getallheaders') ? getallheaders() : [];
    $authorization = $headers['Authorization'] ?? $headers['authorization'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if (preg_match('/Bearer\s+(.+)/i', $authorization, $matches)) {
        return trim($matches[1]);
    }
    return null;
}

function authenticated_user(PDO $pdo): array
{
    $token = bearer_token();
    if (!$token) {
        json_response(['success' => false, 'message' => 'Token autentikasi diperlukan.'], 401);
    }

    $stmt = $pdo->prepare(
        'SELECT u.id, u.name, u.email
         FROM user_tokens t
         JOIN users u ON u.id = t.user_id
         WHERE t.token_hash = :token_hash AND t.expires_at > NOW()
         LIMIT 1'
    );
    $stmt->execute(['token_hash' => hash('sha256', $token)]);
    $user = $stmt->fetch();

    if (!$user) {
        json_response(['success' => false, 'message' => 'Token tidak valid atau sudah kedaluwarsa.'], 401);
    }
    return $user;
}

function issue_token(PDO $pdo, int $userId): string
{
    $token = bin2hex(random_bytes(32));
    $stmt = $pdo->prepare(
        'INSERT INTO user_tokens (user_id, token_hash, expires_at)
         VALUES (:user_id, :token_hash, DATE_ADD(NOW(), INTERVAL 30 DAY))'
    );
    $stmt->execute([
        'user_id' => $userId,
        'token_hash' => hash('sha256', $token),
    ]);
    return $token;
}
