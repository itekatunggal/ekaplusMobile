<?php
// database/api/products/get_by_id.php
// Get product by ID from database with its variants

require_once '../config.php';

try {
    // Get ID from query parameter
    $id = isset($_GET['id']) ? $_GET['id'] : null;

    if (!$id) {
        sendError('Product ID is required', 400);
    }

    $pdo = getDBConnection();

    // Query to get product by ID with category
    $sql = "SELECT
                p.id,
                p.name,
                p.item_category_id,
                p.disabled,
                p.is_hot_deals,
                p.created_at,
                p.updated_at,
                c.id as category_id,
                c.name as category_name,
                c.image as category_image
            FROM products p
            LEFT JOIN item_categories c ON p.item_category_id = c.id
            WHERE p.id = :id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['id' => $id]);

    $product = $stmt->fetch();

    if (!$product) {
        sendNotFound('Product not found');
    }

    // Get variants for this product
    $variantSql = "SELECT
                    id,
                    code,
                    name,
                    color,
                    type,
                    description,
                    image
                FROM product_variants
                WHERE product_id = :product_id
                ORDER BY name ASC";

    $variantStmt = $pdo->prepare($variantSql);
    $variantStmt->execute(['product_id' => $product['id']]);
    $variants = $variantStmt->fetchAll();

    // Convert variant IDs to integers
    $variantList = [];
    foreach ($variants as $variant) {
        $variantList[] = [
            'id' => (int)$variant['id'],
            'code' => $variant['code'],
            'name' => $variant['name'],
            'color' => $variant['color'],
            'type' => $variant['type'],
            'description' => $variant['description'],
            'image' => $variant['image']
        ];
    }

    // Build category object
    $itemCategory = null;
    if ($product['category_id']) {
        $itemCategory = [
            'id' => (int)$product['category_id'],
            'name' => $product['category_name'],
            'image' => $product['category_image']
        ];
    }

    $result = [
        'id' => (int)$product['id'],
        'name' => $product['name'],
        'itemCategory' => $itemCategory,
        'variants' => $variantList,
        'disabled' => (int)$product['disabled'],
        'isHotDeals' => (bool)$product['is_hot_deals']
    ];

    sendSuccess($result, 'Product retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve product: ' . $e->getMessage(), 500);
}
?>
