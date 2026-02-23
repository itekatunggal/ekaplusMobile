// lib/features/member/data/models/shipping_address_model.dart

import 'package:flutter/material.dart';
import 'province_model.dart';
import 'regency_model.dart';
import 'district_model.dart';

/// Model untuk menyimpan data alamat pengiriman
class ShippingAddressModel {
  final String id;
  final TextEditingController addressController;
  final TextEditingController postalCodeController;
  final TextEditingController labelController; // Label alamat (Rumah, Kantor, dll)
  final TextEditingController picNameController;
  final TextEditingController picPhoneController;

  ProvinceModel? selectedProvince;
  RegencyModel? selectedRegency;
  DistrictModel? selectedDistrict;

  List<ProvinceModel> provinces;
  List<RegencyModel> regencies;
  List<DistrictModel> districts;

  bool sameAsCompanyAddress;
  bool isDefault;

  ShippingAddressModel({
    required this.id,
    TextEditingController? addressController,
    TextEditingController? postalCodeController,
    TextEditingController? labelController,
    TextEditingController? picNameController,
    TextEditingController? picPhoneController,
    this.selectedProvince,
    this.selectedRegency,
    this.selectedDistrict,
    List<ProvinceModel>? provinces,
    List<RegencyModel>? regencies,
    List<DistrictModel>? districts,
    this.sameAsCompanyAddress = false,
    this.isDefault = false,
  })  : addressController = addressController ?? TextEditingController(),
        postalCodeController = postalCodeController ?? TextEditingController(),
        labelController = labelController ?? TextEditingController(),
        picNameController = picNameController ?? TextEditingController(),
        picPhoneController = picPhoneController ?? TextEditingController(),
        provinces = provinces ?? [],
        regencies = regencies ?? [],
        districts = districts ?? [];

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
    required List<ProvinceModel> companyProvinces,
    required List<RegencyModel> companyRegencies,
    required List<DistrictModel> companyDistricts,
  }) {
    addressController.text = address;
    postalCodeController.text = postalCode;
    selectedProvince = province;
    selectedRegency = regency;
    selectedDistrict = district;
    provinces = companyProvinces;
    regencies = companyRegencies;
    districts = companyDistricts;
  }

  /// Clear all fields
  void clear() {
    addressController.clear();
    postalCodeController.clear();
    labelController.clear();
    picNameController.clear();
    picPhoneController.clear();
    selectedProvince = null;
    selectedRegency = null;
    selectedDistrict = null;
    regencies = [];
    districts = [];
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
  }

  /// Dispose controllers
  void dispose() {
    addressController.dispose();
    postalCodeController.dispose();
    labelController.dispose();
    picNameController.dispose();
    picPhoneController.dispose();
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

    if (postalCodeController.text.trim().isEmpty) {
      errors['shippingPostalCode_$index'] = 'Kode pos tidak boleh kosong';
    } else if (postalCodeController.text.trim().length != 5) {
      errors['shippingPostalCode_$index'] = 'Kode pos harus 5 digit';
    }

    return errors;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': labelController.text.trim().isEmpty
          ? 'Alamat Pengiriman'
          : labelController.text.trim(),
      'address': addressController.text.trim(),
      'province': selectedProvince?.name,
      'province_code': selectedProvince?.code,
      'city': selectedRegency?.name,
      'city_code': selectedRegency?.code,
      'district': selectedDistrict?.name,
      'district_code': selectedDistrict?.code,
      'postal_code': postalCodeController.text.trim(),
      'pic_name': picNameController.text.trim(),
      'pic_phone': picPhoneController.text.trim(),
      'is_default': isDefault ? 1 : 0,
      'same_as_company': sameAsCompanyAddress,
    };
  }
}
