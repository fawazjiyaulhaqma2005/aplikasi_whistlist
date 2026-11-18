<?php
require_once __DIR__ . '/../includes/bootstrap.php';
require_method(['GET']);

$pdo->query('SELECT 1');
json_response([
    'success' => true,
    'message' => 'Travel Wishlist API is running',
    'database' => 'connected'
]);
