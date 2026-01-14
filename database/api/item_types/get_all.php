<?php
// database/api/item_types/get_all.php
// Get all item types from database

require_once '../config.php';

try {
    $pdo = getDBConnection();

    // Query to get all active item types
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
            WHERE disabled = 0
            ORDER BY name ASC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    $types = $stmt->fetchAll();

    // Convert numeric strings to proper types
    foreach ($types as &$type) {
        $type['id'] = (int)$type['id'];
        $type['docstatus'] = (int)$type['docstatus'];
        $type['disabled'] = (int)$type['disabled'];
    }

    sendSuccess($types, 'Item types retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve item types: ' . $e->getMessage(), 500);
}
?>
