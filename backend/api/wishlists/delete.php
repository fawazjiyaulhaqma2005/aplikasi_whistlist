<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['DELETE']);

$user = authenticated_user($pdo);
$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id) {
    json_response(['success' => false, 'message' => 'ID wishlist tidak valid.'], 422);
}

$stmt = $pdo->prepare('DELETE FROM wishlists WHERE id = :id AND user_id = :user_id');
$stmt->execute(['id' => $id, 'user_id' => $user['id']]);

if ($stmt->rowCount() === 0) {
    json_response(['success' => false, 'message' => 'Wishlist tidak ditemukan.'], 404);
}
json_response(['success' => true, 'message' => 'Wishlist berhasil dihapus.']);
