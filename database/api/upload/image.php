<?php
// api/upload/image.php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "success" => false,
        "message" => "Method not allowed"
    ]);
    exit();
}

try {
    // Validasi file upload
    if (!isset($_FILES['image'])) {
        throw new Exception("No image file uploaded");
    }

    $file = $_FILES['image'];
    $type = $_POST['type'] ?? 'general'; // category, product, member, etc

    // Validasi tipe file
    $allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
    $file_type = mime_content_type($file['tmp_name']);

    if (!in_array($file_type, $allowed_types)) {
        throw new Exception("Invalid file type. Only JPEG, PNG, and GIF allowed");
    }

    // Validasi ukuran file (max 5MB)
    $max_size = 5 * 1024 * 1024; // 5MB
    if ($file['size'] > $max_size) {
        throw new Exception("File size too large. Maximum 5MB");
    }

    // Generate unique filename
    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = uniqid() . '_' . time() . '.' . $extension;

    // Create upload directory if not exists
    $upload_dir = "../../uploads/$type/";
    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    $target_path = $upload_dir . $filename;

    // Move uploaded file
    if (move_uploaded_file($file['tmp_name'], $target_path)) {
        $relative_path = "uploads/$type/$filename";

        echo json_encode([
            "success" => true,
            "message" => "Image uploaded successfully",
            "data" => [
                "filename" => $filename,
                "path" => $relative_path,
                "url" => "http://localhost/ekaplus_backend/$relative_path"
            ]
        ]);
    } else {
        throw new Exception("Failed to move uploaded file");
    }

} catch(Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}
?>
