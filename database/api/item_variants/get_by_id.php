<?php
// database/api/item_variants/get_by_id.php
// Get variant by ID from database

require_once '../config.php';

try {
    // Get ID from query parameter
    $id = isset($_GET['id']) ? $_GET['id'] : null;

    if (!$id) {
        sendError('Variant ID is required', 400);
    }

    $pdo = getDBConnection();

    // Query to get variant by ID
    $sql = "SELECT
                id,
                item_id,
                code,
                name,
                color,
                type,
                description,
                image,
                created_at,
                updated_at
            FROM item_variants
            WHERE id = :id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['id' => $id]);

    $variant = $stmt->fetch();

    if (!$variant) {
        sendNotFound('Variant not found');
    }

    // Convert numeric strings to proper types
    $variant['id'] = (int)$variant['id'];
    $variant['item_id'] = (int)$variant['item_id'];

    sendSuccess($variant, 'Variant retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve variant: ' . $e->getMessage(), 500);
}
?>
