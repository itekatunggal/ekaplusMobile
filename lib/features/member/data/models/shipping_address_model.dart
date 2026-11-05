// lib/features/member/data/models/shipping_address_model.dart

import 'package:flutter/material.dart';
import 'province_model.dart';
import 'regency_model.dart';
import 'district_model.dart';
import 'village_model.dart';

/// Model untuk menyimpan data alamat pengiriman
class ShippingAddressModel {
  final String id;
  final TextEditingController addressController;
  final TextEditingController postalCodeController;
  final TextEditingController labelController; // Label alamat (Rumah, Kantor, dll)
  final TextEditingController picNameController;
  final TextEditingController picPhoneController;
  final TextEditingController picEmailController;
  String type;

  ProvinceModel? selectedProvince;
  RegencyModel? selectedRegency;
  DistrictModel? selectedDistrict;
  VillageModel? selectedVillage;

  List<ProvinceModel> provinces;
  List<RegencyModel> regencies;
  List<DistrictModel> districts;
  List<VillageModel> villages;

  bool sameAsCompanyAddress;
  bool isDefault;

  ShippingAddressModel({
    required this.id,
    TextEditingController? addressController,
    TextEditingController? postalCodeController,
    TextEditingController? labelController,
    TextEditingController? picNameController,
    TextEditingController? picPhoneController,
    TextEditingController? picEmailController,
    this.selectedProvince,
    this.selectedRegency,
    this.selectedDistrict,
    this.selectedVillage,
    List<ProvinceModel>? provinces,
    List<RegencyModel>? regencies,
    List<DistrictModel>? districts,
    List<VillageModel>? villages,
    this.sameAsCompanyAddress = false,
    this.isDefault = false,
    this.type = 'Shipping',
  })  : addressController = addressController ?? TextEditingController(),
        postalCodeController = postalCodeController ?? TextEditingController(),
        labelController = labelController ?? TextEditingController(),
        picNameController = picNameController ?? TextEditingController(),
        picPhoneController = picPhoneController ?? TextEditingController(),
        picEmailController = picEmailController ?? TextEditingController(),
        provinces = provinces ?? [],
        regencies = regencies ?? [],
        districts = districts ?? [],
        villages = villages ?? [];

  /// Factory constructor untuk membuat instance baru dengan ID unik
  factory ShippingAddressModel.create() {
    return ShippingAddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Copy from company address
  void copyFromCompanyAddress({
    required String address,
    required String postalCode,
    required ProvinceModel? province,
    required RegencyModel? regency,
    required DistrictModel? district,
    required VillageModel? village,
    required List<ProvinceModel> companyProvinces,
    required List<RegencyModel> companyRegencies,
    required List<DistrictModel> companyDistricts,
    required List<VillageModel> companyVillages,
  }) {
    addressController.text = address;
    postalCodeController.text = postalCode;
    selectedProvince = province;
    selectedRegency = regency;
    selectedDistrict = district;
    selectedVillage = village;
    provinces = companyProvinces;
    regencies = companyRegencies;
    districts = companyDistricts;
    villages = companyVillages;
  }

  /// Clear all fields
  void clear() {
    addressController.clear();
    postalCodeController.clear();
    labelController.clear();
    picNameController.clear();
    picPhoneController.clear();
    picEmailController.clear();
    type = 'Shipping';
    selectedProvince = null;
    selectedRegency = null;
    selectedDistrict = null;
    selectedVillage = null;
    regencies = [];
    districts = [];
    villages = [];
  }

  /// Reset cascading dropdowns
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

  /// Dispose controllers
  void dispose() {
    addressController.dispose();
    postalCodeController.dispose();
    labelController.dispose();
    picNameController.dispose();
    picPhoneController.dispose();
    picEmailController.dispose();
  }

  /// Validate shipping address
  Map<String, String?> validate(int index) {
    Map<String, String?> errors = {};

    if (labelController.text.trim().isEmpty) {
      errors['shippingLabel_$index'] = 'Label alamat wajib diisi';
    }

    if (picNameController.text.trim().isEmpty) {
      errors['shippingPicName_$index'] = 'Nama penanggung jawab wajib diisi';
    }

    if (picPhoneController.text.trim().isEmpty) {
      errors['shippingPicPhone_$index'] = 'No HP penanggung jawab wajib diisi';
    } else if (picPhoneController.text.trim().length < 10) {
      errors['shippingPicPhone_$index'] = 'No HP penanggung jawab tidak valid';
    }
    if (picEmailController.text.trim().isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(
          picEmailController.text.trim(),
        )) {
      errors['shippingPicEmail_$index'] =
          'Email penanggung jawab tidak valid';
    }

    // Skip address-region validation if same as company address
    if (sameAsCompanyAddress) return errors;

    if (addressController.text.trim().isEmpty) {
      errors['shippingAddress_$index'] = 'Alamat pengiriman tidak boleh kosong';
    }

    if (selectedProvince == null) {
      errors['shippingProvince_$index'] = 'Pilih provinsi';
    }

    if (selectedRegency == null) {
      errors['shippingRegency_$index'] = 'Pilih kota/kabupaten';
    }

    if (selectedDistrict == null) {
      errors['shippingDistrict_$index'] = 'Pilih kecamatan';
    }

    if (selectedVillage == null) {
      errors['shippingVillage_$index'] = 'Pilih kelurahan/desa';
    }

    return errors;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': labelController.text.trim().isEmpty
          ? 'Alamat Pengiriman'
          : labelController.text.trim(),
      'type': type,
      'address': addressController.text.trim(),
      'province': selectedProvince?.name,
      'province_code': selectedProvince?.code,
      'city': selectedRegency?.name,
      'city_code': selectedRegency?.code,
      'district': selectedDistrict?.name,
      'district_code': selectedDistrict?.code,
      'village': selectedVillage?.name,
      if (postalCodeController.text.trim().isNotEmpty)
        'postal_code': postalCodeController.text.trim(),
      'pic_name': picNameController.text.trim(),
      'pic_phone': picPhoneController.text.trim(),
      'pic_email': picEmailController.text.trim(),
      'is_default': isDefault ? 1 : 0,
      'same_as_company': sameAsCompanyAddress,
    };
  }
}
