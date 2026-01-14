<?php
// database/api/branches/get_all.php
// Get all branches from database

require_once '../config.php';

try {
    $pdo = getDBConnection();

    // Query to get all active branches
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
            WHERE disabled = 0
            ORDER BY name ASC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    $branches = $stmt->fetchAll();

    // Convert numeric strings to proper types
    foreach ($branches as &$branch) {
        $branch['id'] = (int)$branch['id'];
        $branch['lat'] = (float)$branch['lat'];
        $branch['lng'] = (float)$branch['lng'];
        $branch['disabled'] = (int)$branch['disabled'];
    }

    sendSuccess($branches, 'Branches retrieved successfully');

} catch (PDOException $e) {
    sendError('Failed to retrieve branches: ' . $e->getMessage(), 500);
}
?>
