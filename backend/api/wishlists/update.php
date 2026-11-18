<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['PUT', 'PATCH']);

$user = authenticated_user($pdo);
$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id) {
    json_response(['success' => false, 'message' => 'ID wishlist tidak valid.'], 422);
}

$check = $pdo->prepare('SELECT id FROM wishlists WHERE id = :id AND user_id = :user_id');
$check->execute(['id' => $id, 'user_id' => $user['id']]);
if (!$check->fetch()) {
    json_response(['success' => false, 'message' => 'Wishlist tidak ditemukan.'], 404);
}

$data = request_data();
$allowed = ['destination', 'location', 'category_id', 'estimated_budget', 'priority', 'description', 'photo_url', 'status'];
$fields = [];
$params = ['id' => $id, 'user_id' => $user['id']];

foreach ($allowed as $field) {
    if (array_key_exists($field, $data)) {
        $fields[] = "{$field} = :{$field}";
        $value = $data[$field];
        if (in_array($field, ['location', 'description', 'photo_url'], true) && $value === '') {
            $value = null;
        }
        if (in_array($field, ['category_id', 'estimated_budget'], true) && $value === '') {
            $value = null;
        }
        $params[$field] = $value;
    }
}

if (!$fields) {
    json_response(['success' => false, 'message' => 'Tidak ada data yang diperbarui.'], 422);
}
if (isset($data['priority']) && !in_array($data['priority'], ['Rendah', 'Sedang', 'Tinggi'], true)) {
    json_response(['success' => false, 'message' => 'Prioritas tidak valid.'], 422);
}
if (isset($data['status']) && !in_array($data['status'], ['Belum Dikunjungi', 'Sudah Dikunjungi'], true)) {
    json_response(['success' => false, 'message' => 'Status tidak valid.'], 422);
}

$sql = 'UPDATE wishlists SET ' . implode(', ', $fields) . ' WHERE id = :id AND user_id = :user_id';
$stmt = $pdo->prepare($sql);
$stmt->execute($params);

json_response(['success' => true, 'message' => 'Wishlist berhasil diperbarui.']);
