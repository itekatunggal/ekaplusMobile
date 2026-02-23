// lib/features/member/presentation/utils/member_registration_form_state.dart

import 'dart:io';

import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/province_model.dart';
import '../../data/models/regency_model.dart';
import '../../data/models/district_model.dart';
import '../../data/models/village_model.dart';
import '../../data/models/shipping_address_model.dart';

/// Class untuk mengelola semua form controllers dan state untuk Member Registration
class MemberRegistrationFormState {
  // === IDENTITY SECTION (Read-only from User data) ===
  // Controllers untuk data identitas yang sudah ada
  final TextEditingController namaController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController birthPlaceController;
  final TextEditingController dateOfBirthController;

  // === COMPANY INFO SECTION ===
  final TextEditingController companyNameController;
  final TextEditingController nikController;
  final TextEditingController npwpController;

  // === ADDRESS SECTION ===
  final TextEditingController addressController;
  final TextEditingController rtController;
  final TextEditingController rwController;
  final TextEditingController postalCodeController;

  // === SUPPORTING DATA SECTION ===
  final TextEditingController contactPersonController;
  final TextEditingController factoryAddressController;
  final TextEditingController emailCompanyController;
  final TextEditingController faxController;

  // === COMPANY TYPE & BRANCH ===
  String? companyType; // 'Company' or 'Individual'
  String? companyTitle; // Gelar: PT, CV, UD, Toko, Home Industri, Freelance
  String? companySuffix; // Singkatan: BP, IBU, PT, CV, TK, HI, UD
  String? productNeed; // Kebutuhan produk
  Branch? selectedBranch;

  // === CASCADING ADDRESS DROPDOWNS ===
  ProvinceModel? selectedProvince;
  RegencyModel? selectedRegency;
  DistrictModel? selectedDistrict;
  VillageModel? selectedVillage;

  // === LISTS FOR DROPDOWNS ===
  List<Branch> branches = [];
  List<ProvinceModel> provinces = [];
  List<RegencyModel> regencies = [];
  List<DistrictModel> districts = [];
  List<VillageModel> villages = [];

  // === UPLOAD DOCUMENTS ===
  File? ktpFile;
  File? npwpFile;
  String? companyDocFilePath; // SIUP/TDP/NIB
  bool isPKP = false; // Pengusaha Kena Pajak checkbox

  // === SHIPPING ADDRESSES ===
  List<ShippingAddressModel> shippingAddresses = [];

  MemberRegistrationFormState({
    // Identity
    required this.namaController,
    required this.phoneController,
    required this.emailController,
    required this.birthPlaceController,
    required this.dateOfBirthController,
    // Company Info
    required this.companyNameController,
    required this.nikController,
    required this.npwpController,
    // Address
    required this.addressController,
    required this.rtController,
    required this.rwController,
    required this.postalCodeController,
    // Supporting Data
    required this.contactPersonController,
    required this.factoryAddressController,
    required this.emailCompanyController,
    required this.faxController,
  });

  /// Factory constructor untuk membuat instance baru dengan controllers kosong
  factory MemberRegistrationFormState.empty() {
    return MemberRegistrationFormState(
      // Identity
      namaController: TextEditingController(),
      phoneController: TextEditingController(),
      emailController: TextEditingController(),
      birthPlaceController: TextEditingController(),
      dateOfBirthController: TextEditingController(),
      // Company Info
      companyNameController: TextEditingController(),
      nikController: TextEditingController(),
      npwpController: TextEditingController(),
      // Address
      addressController: TextEditingController(),
      rtController: TextEditingController(),
      rwController: TextEditingController(),
      postalCodeController: TextEditingController(),
      // Supporting Data
      contactPersonController: TextEditingController(),
      factoryAddressController: TextEditingController(),
      emailCompanyController: TextEditingController(),
      faxController: TextEditingController(),
    );
  }

  /// Factory constructor untuk membuat instance dengan data user yang sudah ada
  factory MemberRegistrationFormState.fromUserData({
    required String nama,
    required String phone,
    required String email,
    required String birthPlace,
    required String dateOfBirth,
  }) {
    return MemberRegistrationFormState(
      // Identity (pre-filled)
      namaController: TextEditingController(text: nama),
      phoneController: TextEditingController(text: phone),
      emailController: TextEditingController(text: email),
      birthPlaceController: TextEditingController(text: birthPlace),
      dateOfBirthController: TextEditingController(text: dateOfBirth),
      // Company Info (empty)
      companyNameController: TextEditingController(),
      nikController: TextEditingController(),
      npwpController: TextEditingController(),
      // Address (empty)
      addressController: TextEditingController(),
      rtController: TextEditingController(),
      rwController: TextEditingController(),
      postalCodeController: TextEditingController(),
      // Supporting Data (empty)
      contactPersonController: TextEditingController(),
      factoryAddressController: TextEditingController(),
      emailCompanyController: TextEditingController(),
      faxController: TextEditingController(),
    );
  }

  /// Dispose all controllers
  void dispose() {
    // Identity
    namaController.dispose();
    phoneController.dispose();
    emailController.dispose();
    birthPlaceController.dispose();
    dateOfBirthController.dispose();
    // Company Info
    companyNameController.dispose();
    nikController.dispose();
    npwpController.dispose();
    // Address
    addressController.dispose();
    rtController.dispose();
    rwController.dispose();
    postalCodeController.dispose();
    // Supporting Data
    contactPersonController.dispose();
    factoryAddressController.dispose();
    emailCompanyController.dispose();
    faxController.dispose();
    // Shipping Addresses
    for (final address in shippingAddresses) {
      address.dispose();
    }
  }

  // === SHIPPING ADDRESS METHODS ===

  /// Add new shipping address
  void addShippingAddress() {
    shippingAddresses.add(ShippingAddressModel.create());
  }

  /// Remove shipping address by index
  void removeShippingAddress(int index) {
    if (index >= 0 && index < shippingAddresses.length) {
      shippingAddresses[index].dispose();
      shippingAddresses.removeAt(index);
    }
  }

  /// Copy company address to shipping address
  void copyCompanyAddressToShipping(int index) {
    if (index >= 0 && index < shippingAddresses.length) {
      shippingAddresses[index].copyFromCompanyAddress(
        address: addressController.text,
        postalCode: postalCodeController.text,
        province: selectedProvince,
        regency: selectedRegency,
        district: selectedDistrict,
        companyProvinces: provinces,
        companyRegencies: regencies,
        companyDistricts: districts,
      );
    }
  }

  /// Clear shipping address fields
  void clearShippingAddress(int index) {
    if (index >= 0 && index < shippingAddresses.length) {
      shippingAddresses[index].clear();
    }
  }

  /// Reset dropdown selections ketika ada perubahan pada parent
  void resetRegency() {
    selectedRegency = null;
    regencies = [];
    resetDistrict();
  }

  void resetDistrict() {
    selectedDistrict = null;
    districts = [];
    resetVillage();
  }

  void resetVillage() {
    selectedVillage = null;
    villages = [];
  }

  /// Format company name: UPPERCASE + TRIM + add suffix based on user selection
  String getFormattedCompanyName() {
    String name = companyNameController.text.trim().toUpperCase();

    if (name.isEmpty) return '';

    // If user selected suffix, add it to the end
    if (companySuffix != null && companySuffix!.isNotEmpty) {
      return '$name $companySuffix';
    }

    return name;
  }

  /// Validate form before submission
  Map<String, String?> validate() {
    Map<String, String?> errors = {};

    // Identity
    if (birthPlaceController.text.trim().isEmpty) {
      errors['birthPlace'] = 'Tempat lahir wajib diisi';
    }
    if (dateOfBirthController.text.trim().isEmpty) {
      errors['dateOfBirth'] = 'Tanggal lahir wajib diisi';
    }

    // Company Type
    if (companyType == null || companyType!.isEmpty) {
      errors['companyType'] = 'Pilih jenis perusahaan';
    }

    // Company Title (Gelar Perusahaan) - wajib jika sudah pilih jenis perusahaan
    if (companyType != null && companyType!.isNotEmpty) {
      if (companyTitle == null || companyTitle!.isEmpty) {
        errors['companyTitle'] = 'Pilih gelar perusahaan';
      }
    }

    // Company Suffix (Sapaan) - wajib untuk Freelance
    if (companyType == 'Individual' && companyTitle == 'Freelance') {
      if (companySuffix == null || companySuffix!.isEmpty) {
        errors['companySuffix'] = 'Pilih sapaan (IBU/BP)';
      }
    }

    // Company Name
    if (companyNameController.text.trim().isEmpty) {
      errors['companyName'] = 'Nama perusahaan tidak boleh kosong';
    }

    // Kebutuhan Produk
    if (productNeed == null || productNeed!.trim().isEmpty) {
      errors['productNeed'] = 'Kebutuhan produk wajib diisi';
    }

    // // NIK
    // if (nikController.text.trim().isEmpty) {
    //   errors['nik'] = 'NIK tidak boleh kosong';
    // } else if (nikController.text.trim().length != 16) {
    //   errors['nik'] = 'NIK harus 16 digit';
    // }

    // // NPWP (Opsional untuk Perorangan, tapi jika diisi harus valid)
    // if (npwpController.text.trim().isNotEmpty) {
    //   if (npwpController.text.trim().length != 15) {
    //     errors['npwp'] = 'NPWP harus 15 digit';
    //   }
    // }

    // Branch
    if (selectedBranch == null) {
      errors['branch'] = 'Pilih cabang';
    }

    // Address
    if (addressController.text.trim().isEmpty) {
      errors['address'] = 'Alamat tidak boleh kosong';
    }

    // Province, Regency, District, Village
    if (selectedProvince == null) {
      errors['province'] = 'Pilih provinsi';
    }
    if (selectedRegency == null) {
      errors['regency'] = 'Pilih kota/kabupaten';
    }
    if (selectedDistrict == null) {
      errors['district'] = 'Pilih kecamatan';
    }
    // if (selectedVillage == null) {
    //   errors['village'] = 'Pilih kelurahan/desa';
    // }

    // RT/RW
    // if (rtController.text.trim().isEmpty) {
    //   errors['rt'] = 'RT tidak boleh kosong';
    // }
    // if (rwController.text.trim().isEmpty) {
    //   errors['rw'] = 'RW tidak boleh kosong';
    // }

    // Postal Code
    if (postalCodeController.text.trim().isEmpty) {
      errors['postalCode'] = 'Kode pos tidak boleh kosong';
    } else if (postalCodeController.text.trim().length != 5) {
      errors['postalCode'] = 'Kode pos harus 5 digit';
    }

    // Shipping Addresses: minimal 1 alamat pengiriman valid
    if (shippingAddresses.isEmpty) {
      errors['shippingAddresses'] = 'Minimal 1 alamat pengiriman harus diisi';
    } else {
      for (int i = 0; i < shippingAddresses.length; i++) {
        errors.addAll(shippingAddresses[i].validate(i));
      }
    }

    // // Contact Person
    // if (contactPersonController.text.trim().isEmpty) {
    //   errors['contactPerson'] = 'Contact person tidak boleh kosong';
    // }

    // // Email Company
    // if (emailCompanyController.text.trim().isEmpty) {
    //   errors['emailCompany'] = 'Email perusahaan tidak boleh kosong';
    // } else if (!_isValidEmail(emailCompanyController.text.trim())) {
    //   errors['emailCompany'] = 'Format email tidak valid';
    // }

    // // Document uploads
    // if (ktpFile == null) {
    //   errors['ktpFile'] = 'Upload foto KTP';
    // }
    // NPWP file: Opsional untuk Perorangan, tapi jika NPWP manual tidak diisi maka harus upload
    if (companyType == 'Individual') {
      // Untuk Perorangan: NPWP opsional (boleh tidak ada sama sekali)
      // Tidak perlu validasi NPWP file
    } else {
      // Untuk Badan atau lainnya: NPWP file tetap opsional
      // (bisa diisi manual atau upload)
    }

    return errors;
  }

  /// Check apakah user sudah mengisi sebagian form (untuk konfirmasi back)
  bool hasAnyInput() {
    final hasMainInput =
        companyType != null ||
        companyTitle != null ||
        (companySuffix != null && companySuffix!.isNotEmpty) ||
        selectedBranch != null ||
        companyNameController.text.trim().isNotEmpty ||
        nikController.text.trim().isNotEmpty ||
        npwpController.text.trim().isNotEmpty ||
        addressController.text.trim().isNotEmpty ||
        postalCodeController.text.trim().isNotEmpty ||
        contactPersonController.text.trim().isNotEmpty ||
        factoryAddressController.text.trim().isNotEmpty ||
        emailCompanyController.text.trim().isNotEmpty ||
        faxController.text.trim().isNotEmpty ||
        selectedProvince != null ||
        selectedRegency != null ||
        selectedDistrict != null ||
        selectedVillage != null ||
        ktpFile != null ||
        npwpFile != null ||
        (companyDocFilePath != null && companyDocFilePath!.trim().isNotEmpty) ||
        isPKP;

    if (hasMainInput) {
      return true;
    }

    for (final shipping in shippingAddresses) {
      if (shipping.sameAsCompanyAddress ||
          shipping.addressController.text.trim().isNotEmpty ||
          shipping.postalCodeController.text.trim().isNotEmpty ||
          shipping.selectedProvince != null ||
          shipping.selectedRegency != null ||
          shipping.selectedDistrict != null) {
        return true;
      }
    }

    return false;
  }

  // /// Helper: Email validation
  // bool _isValidEmail(String email) {
  //   return RegExp(
  //     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  //   ).hasMatch(email);
  // }

  /// Convert to JSON untuk API submission
  /// registrationType: 'GPID' untuk first registration, 'GCID' untuk perusahaan baru di group, 'BCID' untuk cabang
  Map<String, dynamic> toJson({
    String registrationType = 'GPID',
    String? parentGcid,
  }) {
    return toApiCustomerRegisterJson();
  }

  Map<String, dynamic> toApiCustomerRegisterJson() {
    // String registrationType = 'GPID',
    // String? parentGcid,
    // }) {
    final companyNameFormatted = getFormattedCompanyName();

    final hasShipping = shippingAddresses.isNotEmpty;
    final allShippingSameAsCompany =
        hasShipping && shippingAddresses.every((e) => e.sameAsCompanyAddress);

    final customerShippingAddress = shippingAddresses
        .map(
          (e) => {
            'label': e.labelController.text.trim().isEmpty
                ? 'Alamat Pengiriman'
                : e.labelController.text.trim(),
            'address': e.sameAsCompanyAddress
                ? addressController.text.trim()
                : e.addressController.text.trim(),
            'province': e.sameAsCompanyAddress
                ? selectedProvince?.name
                : e.selectedProvince?.name,
            'city': e.sameAsCompanyAddress
                ? selectedRegency?.name
                : e.selectedRegency?.name,
            'district': e.sameAsCompanyAddress
                ? selectedDistrict?.name
                : e.selectedDistrict?.name,
            'postal_code': e.sameAsCompanyAddress
                ? postalCodeController.text.trim()
                : e.postalCodeController.text.trim(),
            'pic_name': e.picNameController.text.trim(),
            'pic_phone': e.picPhoneController.text.trim(),
            'is_default': e.isDefault ? 1 : 0,
            'country':
                'Indonesia', // ini hanya untuk sementara (api development belum di build ulang) nanti hapus yaaa!!!
          },
        )
        .toList();

    // Generate BC_name with format: "COMPANY_NAME - DAERAH" (untuk SEMUA registration)
    // final bcName = selectedBranch != null
    //     ? '$companyNameFormatted - ${selectedBranch?.area?.toUpperCase()}'
    //     : companyNameFormatted;

    return {
      // Registration Metadata
      // 'type': registrationType,
      'source': 'ekaplus',
      'owner_full_name': namaController.text.trim(),
      'owner_phone': phoneController.text.trim(),
      'owner_email': emailController.text.trim(),
      'owner_place_of_birth': birthPlaceController.text.trim(),
      'owner_date_of_birth': _formatDateForApi(
        dateOfBirthController.text.trim(),
      ),

      // Company Info (kept for compatibility)
      'company_type': companyType,
      'company_title': companyTitle,
      'company_name': companyNameFormatted,
      'product_need': productNeed,
      // 'nik': nikController.text.trim(),
      // 'npwp': npwpController.text.trim(),

      // Branch
      'branch_id': selectedBranch?.id,
      'branch_name': selectedBranch?.branchName,
      'branch_area': selectedBranch?.area,

      // Company Address
      'company_address': addressController.text.trim(),
      'company_province': selectedProvince?.name,
      'company_city': selectedRegency?.name,
      'company_district': selectedDistrict?.name,
      // 'village': selectedVillage?.name,
      // 'rt': rtController.text.trim(),
      // 'rw': rwController.text.trim(),
      'company_postal_code': postalCodeController.text.trim(),

      'same_as_company_address': allShippingSameAsCompany ? 1 : 0,
      if (hasShipping) 'customer_shipping_address': customerShippingAddress,
      // Supporting Data
      // 'contact_person': contactPersonController.text.trim(),
      // 'factory_address': factoryAddressController.text.trim(),
      // 'email_company': emailCompanyController.text.trim(),
      // 'fax': faxController.text.trim(),

      // Shipping Addresses - jika sameAsCompanyAddress true, gunakan data alamat perusahaan
      // 'shipping_addresses': shippingAddresses.map((addr) {
      //   if (addr.sameAsCompanyAddress) {
      //     // Gunakan data alamat perusahaan terbaru
      //     return {
      //       'label': addr.labelController.text.trim().isEmpty
      //           ? 'Alamat Pengiriman'
      //           : addr.labelController.text.trim(),
      //       'address': addressController.text.trim(),
      //       'province': selectedProvince?.name,
      //       'province_code': selectedProvince?.code,
      //       'city': selectedRegency?.name,
      //       'city_code': selectedRegency?.code,
      //       'district': selectedDistrict?.name,
      //       'district_code': selectedDistrict?.code,
      //       'postal_code': postalCodeController.text.trim(),
      //       'same_as_company': true,
      //     };
      //   }
      //   return addr.toJson();
      // }).toList(),
    };
  }

  String _formatDateForApi(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return raw;

    try {
      return DateFormat(
        'dd MMMM yyyy',
        'id_ID',
      ).parseStrict(raw).toIso8601String().substring(0, 10);
    } catch (_) {}

    try {
      return DateFormat(
        'dd/MM/yyyy',
      ).parseStrict(raw).toIso8601String().substring(0, 10);
    } catch (_) {}

    return raw;
  }
}
