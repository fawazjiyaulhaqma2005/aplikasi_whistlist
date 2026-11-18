<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['GET']);

$user = authenticated_user($pdo);
$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id) {
    json_response(['success' => false, 'message' => 'ID wishlist tidak valid.'], 422);
}

$stmt = $pdo->prepare(
    'SELECT w.id, w.destination, w.location, w.category_id,
            c.name AS category_name, w.estimated_budget, w.priority,
            w.description, w.photo_url, w.status, w.created_at
     FROM wishlists w
     LEFT JOIN categories c ON c.id = w.category_id
     WHERE w.id = :id AND w.user_id = :user_id LIMIT 1'
);
$stmt->execute(['id' => $id, 'user_id' => $user['id']]);
$item = $stmt->fetch();

if (!$item) {
    json_response(['success' => false, 'message' => 'Wishlist tidak ditemukan.'], 404);
}
json_response(['success' => true, 'data' => $item]);
