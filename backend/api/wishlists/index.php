<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['GET', 'POST']);

$user = authenticated_user($pdo);

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->prepare(
        'SELECT w.id, w.destination, w.location, w.category_id,
                c.name AS category_name, w.estimated_budget, w.priority,
                w.description, w.photo_url, w.status, w.created_at
         FROM wishlists w
         LEFT JOIN categories c ON c.id = w.category_id
         WHERE w.user_id = :user_id
         ORDER BY w.created_at DESC'
    );
    $stmt->execute(['user_id' => $user['id']]);
    json_response(['success' => true, 'data' => $stmt->fetchAll()]);
}

$data = request_data();
$destination = trim((string)($data['destination'] ?? ''));
if ($destination === '') {
    json_response(['success' => false, 'message' => 'Nama destinasi wajib diisi.'], 422);
}

$categoryId = isset($data['category_id']) && $data['category_id'] !== '' ? (int)$data['category_id'] : null;
$budget = isset($data['estimated_budget']) && $data['estimated_budget'] !== '' ? (float)$data['estimated_budget'] : null;
$priority = (string)($data['priority'] ?? 'Sedang');
$status = (string)($data['status'] ?? 'Belum Dikunjungi');
$allowedPriority = ['Rendah', 'Sedang', 'Tinggi'];
$allowedStatus = ['Belum Dikunjungi', 'Sudah Dikunjungi'];

if (!in_array($priority, $allowedPriority, true) || !in_array($status, $allowedStatus, true)) {
    json_response(['success' => false, 'message' => 'Nilai prioritas atau status tidak valid.'], 422);
}

$stmt = $pdo->prepare(
    'INSERT INTO wishlists
     (user_id, destination, location, category_id, estimated_budget, priority, description, photo_url, status)
     VALUES
     (:user_id, :destination, :location, :category_id, :budget, :priority, :description, :photo_url, :status)'
);
$stmt->execute([
    'user_id' => $user['id'],
    'destination' => $destination,
    'location' => trim((string)($data['location'] ?? '')) ?: null,
    'category_id' => $categoryId,
    'budget' => $budget,
    'priority' => $priority,
    'description' => trim((string)($data['description'] ?? '')) ?: null,
    'photo_url' => trim((string)($data['photo_url'] ?? '')) ?: null,
    'status' => $status,
]);

$id = (int)$pdo->lastInsertId();
json_response(['success' => true, 'message' => 'Wishlist berhasil ditambahkan.', 'data' => ['id' => $id]], 201);
