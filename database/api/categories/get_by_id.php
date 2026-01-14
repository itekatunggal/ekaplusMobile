<?php
// database/api/categories/get_by_id.php
// Get category by ID from database

require_once '../config.php';

try {
    // Get ID from query parameter
    $id = isset($_GET['id']) ? $_GET['id'] : null;

    if (!$id) {
        sendError('Category ID is required', 400);
    }

    $pdo = getDBConnection();

    // Query to get category by ID with its type
    $sql = "SELECT
                c.id,
                c.name,
                c.icon,
                c.image,
                c.description,
                c.title,
                c.subtitle,
                c.type_id,
                c.docstatus,
                c.status,
                c.disabled,
                c.created_at,
                c.created_by,
                c.updated_at,
                c.updated_by,
                t.id as type_id,
                t.name as type_name
            FROM item_categories c
            LEFT JOIN item_types t ON c.type_id = t.id
            WHERE c.id = :id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['id' => $id]);

    $category = $stmt->fetch();

    if (!$category) {
        sendNotFound('Category not found');
    }

    // Transform data to match Flutter model structure
    $type = null;
    if ($category['type_id']) {
        $type = [
            'id' => (int)$category['type_id'],
            'name' => $category['type_name']
        ];
    }

    $result = [
        'id' => (int)$category['id'],
        'name' => $category['name'],
        'icon' => $category['icon'],
        'image' => $category['image'],
        'description' => $category['description'],
        'title' => $category['title'],
        'subtitle' => $category['subtitle'],
        'type' => $type,
        'docstatus' => (int)$category['docstatus'],
        'status' => $category['status'],
        'disabled' => (int)$category['disabled'],
        'created_at' => $category['created_at'],
        'created_by' => null,
        'updated_at' => $category['updated_at'],
        'updated_by' => null,
        'owner' => null
    ];

    sendSuccess($result, 'Category retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve category: ' . $e->getMessage(), 500);
}
?>
