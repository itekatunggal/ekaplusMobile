<?php
// api/categories/get_all.php
include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

try {
    // Join dengan item_types untuk mendapatkan type object
    $query = "SELECT
                ic.id,
                ic.name,
                ic.icon,
                ic.image,
                ic.description,
                ic.title,
                ic.subtitle,
                ic.type_id,
                ic.docstatus,
                ic.status,
                ic.disabled,
                ic.created_at,
                ic.updated_at,
                it.id as type_id_val,
                it.name as type_name
              FROM item_categories ic
              LEFT JOIN item_types it ON ic.type_id = it.id
              WHERE ic.status = 'Enabled'
              ORDER BY ic.id ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();

    $categories = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $categories[] = [
            'id' => (int)$row['id'],
            'name' => $row['name'],
            'icon' => $row['icon'],
            'image' => $row['image'],
            'description' => $row['description'],
            'title' => $row['title'],
            'subtitle' => $row['subtitle'],
            'type' => [
                'id' => (int)$row['type_id_val'],
                'name' => $row['type_name']
            ],
            'docstatus' => (int)$row['docstatus'],
            'status' => $row['status'],
            'disabled' => (int)$row['disabled'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
        ];
    }

    echo json_encode([
        "success" => true,
        "data" => $categories
    ]);

} catch(PDOException $exception) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $exception->getMessage()
    ]);
}
?>
