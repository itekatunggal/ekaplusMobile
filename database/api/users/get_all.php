<?php
// database/api/users/get_all.php
// Get all users from database

require_once '../config.php';

try {
    $pdo = getDBConnection();

    // Query to get all users (exclude password and sensitive data)
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
            ORDER BY full_name ASC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    $users = $stmt->fetchAll();

    // Convert numeric strings to proper types
    foreach ($users as &$user) {
        $user['id'] = (int)$user['id'];
    }

    sendSuccess($users, 'Users retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve users: ' . $e->getMessage(), 500);
}
?>
