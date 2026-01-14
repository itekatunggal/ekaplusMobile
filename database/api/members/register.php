<?php
// api/members/register.php
include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

// Get POST data
$data = json_decode(file_get_contents("php://input"));

if (empty($data)) {
    echo json_encode([
        "success" => false,
        "message" => "No data provided"
    ]);
    exit();
}

try {
    // Validate required fields
    $required_fields = ['user_id', 'registration_type', 'gc_name', 'branch_id'];
    foreach ($required_fields as $field) {
        if (empty($data->$field)) {
            throw new Exception("Field '$field' is required");
        }
    }

    // Generate member_id
    $member_id = 'MBR_' . round(microtime(true) * 1000);

    // Insert member registration
    $query = "INSERT INTO member_register SET
                member_id = :member_id,
                user_id = :user_id,
                status = 'pending',
                registration_type = :registration_type,

                gpid = :gpid,
                gp_name = :gp_name,
                gcid = :gcid,
                gc_name = :gc_name,
                bcid = :bcid,
                bc_name = :bc_name,
                parent_gcid = :parent_gcid,

                nama = :nama,
                email = :email,
                phone = :phone,
                birthPlace = :birthPlace,
                dateOfBirth = :dateOfBirth,

                company_name = :company_name,
                company_type = :company_type,
                nik = :nik,
                npwp = :npwp,

                branch_id = :branch_id,
                branch_name = :branch_name,
                branch_daerah = :branch_daerah,

                address = :address,
                province_code = :province_code,
                province_name = :province_name,
                regency_code = :regency_code,
                regency_name = :regency_name,
                district_code = :district_code,
                district_name = :district_name,
                village_code = :village_code,
                village_name = :village_name,
                rt = :rt,
                rw = :rw,
                postal_code = :postal_code,

                contact_person = :contact_person,
                factory_address = :factory_address,
                email_company = :email_company,
                fax = :fax,

                created_at = NOW(),
                updated_at = NOW()";

    $stmt = $db->prepare($query);

    // Bind values
    $stmt->bindParam(':member_id', $member_id);
    $stmt->bindParam(':user_id', $data->user_id);
    $stmt->bindParam(':registration_type', $data->registration_type);

    $stmt->bindParam(':gpid', $data->gpid);
    $stmt->bindParam(':gp_name', $data->gp_name);
    $stmt->bindParam(':gcid', $data->gcid);
    $stmt->bindParam(':gc_name', $data->gc_name);
    $stmt->bindParam(':bcid', $data->bcid);
    $stmt->bindParam(':bc_name', $data->bc_name);
    $stmt->bindParam(':parent_gcid', $data->parent_gcid);

    $stmt->bindParam(':nama', $data->nama);
    $stmt->bindParam(':email', $data->email);
    $stmt->bindParam(':phone', $data->phone);
    $stmt->bindParam(':birthPlace', $data->birthPlace);
    $stmt->bindParam(':dateOfBirth', $data->dateOfBirth);

    $stmt->bindParam(':company_name', $data->company_name);
    $stmt->bindParam(':company_type', $data->company_type);
    $stmt->bindParam(':nik', $data->nik);
    $stmt->bindParam(':npwp', $data->npwp);

    $stmt->bindParam(':branch_id', $data->branch_id);
    $stmt->bindParam(':branch_name', $data->branch_name);
    $stmt->bindParam(':branch_daerah', $data->branch_daerah);

    $stmt->bindParam(':address', $data->address);
    $stmt->bindParam(':province_code', $data->province_code);
    $stmt->bindParam(':province_name', $data->province_name);
    $stmt->bindParam(':regency_code', $data->regency_code);
    $stmt->bindParam(':regency_name', $data->regency_name);
    $stmt->bindParam(':district_code', $data->district_code);
    $stmt->bindParam(':district_name', $data->district_name);
    $stmt->bindParam(':village_code', $data->village_code);
    $stmt->bindParam(':village_name', $data->village_name);
    $stmt->bindParam(':rt', $data->rt);
    $stmt->bindParam(':rw', $data->rw);
    $stmt->bindParam(':postal_code', $data->postal_code);

    $contact_person = $data->contact_person ?? null;
    $factory_address = $data->factory_address ?? null;
    $email_company = $data->email_company ?? null;
    $fax = $data->fax ?? null;

    $stmt->bindParam(':contact_person', $contact_person);
    $stmt->bindParam(':factory_address', $factory_address);
    $stmt->bindParam(':email_company', $email_company);
    $stmt->bindParam(':fax', $fax);

    if ($stmt->execute()) {
        echo json_encode([
            "success" => true,
            "message" => "Registration submitted successfully",
            "data" => [
                "member_id" => $member_id
            ]
        ]);
    } else {
        throw new Exception("Failed to insert registration");
    }

} catch(Exception $exception) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $exception->getMessage()
    ]);
}
?>
