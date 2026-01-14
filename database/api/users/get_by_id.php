<?php
// database/api/users/get_by_id.php
// Get user by ID from database

require_once '../config.php';

try {
    // Get ID from query parameter (can be numeric id or user_id string)
    $id = isset($_GET['id']) ? $_GET['id'] : null;

    if (!$id) {
        sendError('User ID is required', 400);
    }

    $pdo = getDBConnection();

    // Query to get user by ID or user_id (exclude password)
    $sql = "SELECT
                id,
                user_id,
                full_name,
                phone,
                email,
                profile_picture,
                created_at,
                updated_at
            FROM users
            WHERE id = :id OR user_id = :user_id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['id' => $id, 'user_id' => $id]);

    $user = $stmt->fetch();

    if (!$user) {
        sendNotFound('User not found');
    }

    // Convert numeric strings to proper types
    $user['id'] = (int)$user['id'];

    sendSuccess($user, 'User retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve user: ' . $e->getMessage(), 500);
}
?>
