<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
require_method(['GET']);

$user = authenticated_user($pdo);
json_response(['success' => true, 'data' => ['user' => $user]]);
