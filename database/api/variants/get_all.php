<?php
// database/api/variants/get_all.php
// Get all variants from database

require_once '../config.php';

try {
    $pdo = getDBConnection();

    // Optional: filter by item_id if provided
    $itemId = isset($_GET['item_id']) ? $_GET['item_id'] : null;

    if ($itemId) {
        // Get variants for specific item/product
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
                WHERE item_id = :item_id
                ORDER BY name ASC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['item_id' => $itemId]);
    } else {
        // Get all variants
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
                ORDER BY name ASC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute();
    }

    $variants = $stmt->fetchAll();

    // Convert numeric strings to proper types
    foreach ($variants as &$variant) {
        $variant['id'] = (int)$variant['id'];
        $variant['item_id'] = (int)$variant['item_id'];
    }

    sendSuccess($variants, 'Variants retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve variants: ' . $e->getMessage(), 500);
}
?>
