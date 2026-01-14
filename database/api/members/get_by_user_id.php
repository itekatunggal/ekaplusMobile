<?php
// api/members/get_by_user_id.php
include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

// Get user_id from query parameter
$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : '';

if (empty($user_id)) {
    echo json_encode([
        "success" => false,
        "message" => "user_id parameter is required"
    ]);
    exit();
}

try {
    $query = "SELECT * FROM member_register
              WHERE user_id = :user_id
              ORDER BY created_at DESC";

    $stmt = $db->prepare($query);
    $stmt->bindParam(':user_id', $user_id);
    $stmt->execute();

    $registrations = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $registrations[] = [
            'member_id' => $row['member_id'],
            'user_id' => $row['user_id'],
            'status' => $row['status'],
            'registration_type' => $row['registration_type'],

            'gpid' => $row['gpid'],
            'gp_name' => $row['gp_name'],
            'gcid' => $row['gcid'],
            'gc_name' => $row['gc_name'],
            'bcid' => $row['bcid'],
            'bc_name' => $row['bc_name'],
            'parent_gcid' => $row['parent_gcid'],

            'nama' => $row['nama'],
            'email' => $row['email'],
            'phone' => $row['phone'],
            'birthPlace' => $row['birthPlace'],
            'dateOfBirth' => $row['dateOfBirth'],

            'company_name' => $row['company_name'],
            'company_type' => $row['company_type'],
            'nik' => $row['nik'],
            'npwp' => $row['npwp'],

            'branch_id' => $row['branch_id'],
            'branch_name' => $row['branch_name'],
            'branch_daerah' => $row['branch_daerah'],

            'address' => $row['address'],
            'province_code' => $row['province_code'],
            'province_name' => $row['province_name'],
            'regency_code' => $row['regency_code'],
            'regency_name' => $row['regency_name'],
            'district_code' => $row['district_code'],
            'district_name' => $row['district_name'],
            'village_code' => $row['village_code'],
            'village_name' => $row['village_name'],
            'rt' => $row['rt'],
            'rw' => $row['rw'],
            'postal_code' => $row['postal_code'],

            'contact_person' => $row['contact_person'],
            'factory_address' => $row['factory_address'],
            'email_company' => $row['email_company'],
            'fax' => $row['fax'],

            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
        ];
    }

    echo json_encode([
        "success" => true,
        "data" => $registrations
    ]);

} catch(PDOException $exception) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $exception->getMessage()
    ]);
}
?>
