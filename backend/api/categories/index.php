<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['GET']);

$stmt = $pdo->query('SELECT id, name, icon FROM categories ORDER BY name ASC');
json_response(['success' => true, 'data' => $stmt->fetchAll()]);
