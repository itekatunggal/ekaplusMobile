<?php
// database/api/items/get_by_id.php
// Get item (Individual SKU) by ID from database with its branches

require_once '../config.php';

try {
    // Get ID from query parameter (can be numeric id or code)
    $id = $_GET['id'] ?? null;

    if (!$id) {
        sendError('Item ID or code is required', 400);
    }

    $pdo = getDBConnection();

    // Query to get item by ID or code with category
    $sql = "SELECT
                i.id,
                i.code,
                i.name,
                i.uom,
                i.group_name,
                i.item_category_id,
                i.generator_item,
                i.image,
                i.description,
                i.disabled,
                i.panjang,
                i.tinggi,
                i.lebar,
                i.diameter,
                i.created_at,
                i.updated_at,
                c.id as category_id,
                c.name as category_name
            FROM items i
            LEFT JOIN item_categories c ON i.item_category_id = c.id
            WHERE i.id = :id OR i.code = :code";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['id' => $id, 'code' => $id]);

    $item = $stmt->fetch();

    if (!$item) {
        sendNotFound('Item not found');
    }

    // Get branches for this item
    $branchSql = "SELECT
                    b.id,
                    b.name
                FROM branches b
                INNER JOIN item_branches ib ON b.id = ib.branch_id
                WHERE ib.item_id = :item_id
                ORDER BY b.name ASC";

    $branchStmt = $pdo->prepare($branchSql);
    $branchStmt->execute(['item_id' => $item['id']]);
    $branches = $branchStmt->fetchAll();

    // Convert branch IDs to integers
    $branchList = [];
    foreach ($branches as $branch) {
        $branchList[] = [
            'id' => (int)$branch['id'],
            'name' => $branch['name']
        ];
    }

    // Build category object
    $category = null;
    if ($item['category_id']) {
        $category = [
            'id' => (int)$item['category_id'],
            'name' => $item['category_name']
        ];
    }

    $result = [
        'id' => (int)$item['id'],
        'code' => $item['code'],
        'name' => $item['name'],
        'uom' => $item['uom'],
        'group' => $item['group_name'],
        'category' => $category,
        'generator_item' => $item['generator_item'],
        'image' => $item['image'],
        'description' => $item['description'],
        'disabled' => (int)$item['disabled'],
        'panjang' => $item['panjang'],
        'tinggi' => $item['tinggi'],
        'lebar' => $item['lebar'],
        'diameter' => $item['diameter'],
        'branches' => $branchList
    ];

    sendSuccess($result, 'Item retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve item: ' . $e->getMessage(), 500);
}
