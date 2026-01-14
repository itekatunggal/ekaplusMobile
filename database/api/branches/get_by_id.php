<?php
// database/api/branches/get_by_id.php
// Get branch by ID from database

require_once '../config.php';

try {
    // Get ID from query parameter
    $id = isset($_GET['id']) ? $_GET['id'] : null;

    if (!$id) {
        sendError('Branch ID is required', 400);
    }

    $pdo = getDBConnection();

    // Query to get branch by ID
    $sql = "SELECT
                id,
                name,
                daerah,
                address,
                lat,
                lng,
                pulau,
                wilayah,
                url,
                token,
                disabled,
                created_at,
                updated_at
            FROM branches
            WHERE id = :id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['id' => $id]);

    $branch = $stmt->fetch();

    if (!$branch) {
        sendNotFound('Branch not found');
    }

    // Convert numeric strings to proper types
    $branch['id'] = (int)$branch['id'];
    $branch['lat'] = (float)$branch['lat'];
    $branch['lng'] = (float)$branch['lng'];
    $branch['disabled'] = (int)$branch['disabled'];

    sendSuccess($branch, 'Branch retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve branch: ' . $e->getMessage(), 500);
}
?>
