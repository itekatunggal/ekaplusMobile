<?php
// database/api/item_types/get_by_id.php
// Get item type by ID from database

require_once '../config.php';

try {
    // Get ID from query parameter
    $id = isset($_GET['id']) ? $_GET['id'] : null;

    if (!$id) {
        sendError('Item type ID is required', 400);
    }

    $pdo = getDBConnection();

    // Query to get item type by ID
    $sql = "SELECT
                id,
                name,
                image,
                description,
                docstatus,
                status,
                type_name,
                disabled,
                created_at,
                created_by,
                updated_at,
                updated_by
            FROM item_types
            WHERE id = :id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['id' => $id]);

    $type = $stmt->fetch();

    if (!$type) {
        sendNotFound('Item type not found');
    }

    // Convert numeric strings to proper types
    $type['id'] = (int)$type['id'];
    $type['docstatus'] = (int)$type['docstatus'];
    $type['disabled'] = (int)$type['disabled'];

    sendSuccess($type, 'Item type retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve item type: ' . $e->getMessage(), 500);
}
?>
