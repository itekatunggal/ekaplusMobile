// lib/features/member/presentation/widgets/address_section_widget.dart

// ignore_for_file: unused_field

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/member_registration_cubit.dart';
import '../utils/member_registration_form_state.dart';
import '../../data/models/province_model.dart';
import '../../data/models/regency_model.dart';
import '../../data/models/district_model.dart';
// import '../../data/models/village_model.dart';

/// Widget untuk section alamat dengan cascading dropdowns
class AddressSectionWidget extends StatefulWidget {
  final MemberRegistrationFormState formState;
  final VoidCallback onStateChanged;
  final String? addressError;
  final String? provinceError;
  final String? regencyError;
  final String? districtError;
  final String? villageError;
  final String? rtError;
  final String? rwError;
  final String? postalCodeError;

  const AddressSectionWidget({
    super.key,
    required this.formState,
    required this.onStateChanged,
    this.addressError,
    this.provinceError,
    this.regencyError,
    this.districtError,
    this.villageError,
    this.rtError,
    this.rwError,
    this.postalCodeError,
  });

  @override
  State<AddressSectionWidget> createState() => _AddressSectionWidgetState();
}

class _AddressSectionWidgetState extends State<AddressSectionWidget> {
  bool _isLoadingProvinces = false;
  bool _isLoadingRegencies = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingVillages = false;

  @override
  void initState() {
    super.initState();
    // Load provinces on init
    _loadProvinces();
  }

  void _loadProvinces() {
    setState(() => _isLoadingProvinces = true);
    context.read<MemberRegistrationCubit>().loadProvinces();
  }

  void _onProvinceChanged(ProvinceModel? province) {
    setState(() {
      widget.formState.selectedProvince = province;
      widget.formState.resetRegency(); // Reset semua child selections
      _isLoadingRegencies = true;
    });
    widget.onStateChanged();

    if (province != null) {
      context.read<MemberRegistrationCubit>().loadRegencies(province.code);
    }
  }

  void _onRegencyChanged(RegencyModel? regency) {
    setState(() {
      widget.formState.selectedRegency = regency;
      widget.formState.resetDistrict(); // Reset semua child selections
      _isLoadingDistricts = true;
    });
    widget.onStateChanged();

    if (regency != null) {
      context.read<MemberRegistrationCubit>().loadDistricts(regency.code);
    }
  }

  void _onDistrictChanged(DistrictModel? district) {
    setState(() {
      widget.formState.selectedDistrict = district;
      widget.formState.resetVillage(); // Reset semua child selections
      _isLoadingVillages = true;
    });
    widget.onStateChanged();

    if (district != null) {
      context.read<MemberRegistrationCubit>().loadVillages(district.code);
    }
  }

  // void _onVillageChanged(VillageModel? village) {
  //   setState(() {
  //     widget.formState.selectedVillage = village;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemberRegistrationCubit, MemberRegistrationState>(
      listener: (context, state) {
        if (state is MemberRegistrationProvincesLoaded) {
          setState(() {
            widget.formState.provinces = state.provinces;
            _isLoadingProvinces = false;
          });
        } else if (state is MemberRegistrationRegenciesLoaded) {
          setState(() {
            widget.formState.regencies = state.regencies;
            _isLoadingRegencies = false;
          });
        } else if (state is MemberRegistrationDistrictsLoaded) {
          setState(() {
            widget.formState.districts = state.districts;
            _isLoadingDistricts = false;
          });
        } else if (state is MemberRegistrationVillagesLoaded) {
          setState(() {
            widget.formState.villages = state.villages;
            _isLoadingVillages = false;
          });
        } else if (state is MemberRegistrationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          setState(() {
            _isLoadingProvinces = false;
            _isLoadingRegencies = false;
            _isLoadingDistricts = false;
            _isLoadingVillages = false;
          });
        }
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: AppColors.whiteColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              const Text(
                'Alamat Perusahaan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Alamat Lengkap
              _buildTextField(
                label: 'Alamat Lengkap *',
                controller: widget.formState.addressController,
                textCapitalization: TextCapitalization.sentences,
                icon: Icons.home_outlined,
                maxLines: 3,
                errorText: widget.addressError,
                onChanged: (_) => widget.onStateChanged(),
              ),
              const SizedBox(height: 16),

              // Province Dropdown
              _buildProvinceDropdown(),
              const SizedBox(height: 16),

              // Regency Dropdown
              _buildRegencyDropdown(),
              const SizedBox(height: 16),

              // District Dropdown
              _buildDistrictDropdown(),
              const SizedBox(height: 16),

              // Village Dropdown
              // _buildVillageDropdown(),
              // const SizedBox(height: 16),

              // RT & RW Row
              // Row(
              //   children: [
              //     Expanded(
              //       child: _buildTextField(
              //         label: 'RT *',
              //         controller: widget.formState.rtController,
              //         icon: Icons.numbers,
              //         keyboardType: TextInputType.number,
              //         maxLength: 3,
              //         errorText: widget.rtError,
              //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: _buildTextField(
              //         label: 'RW *',
              //         controller: widget.formState.rwController,
              //         icon: Icons.numbers,
              //         keyboardType: TextInputType.number,
              //         maxLength: 3,
              //         errorText: widget.rwError,
              //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 16),

              // Kode Pos
              _buildTextField(
                label: 'Kode Pos *',
                controller: widget.formState.postalCodeController,
                icon: Icons.local_post_office_outlined,
                keyboardType: TextInputType.number,
                maxLength: 5,
                errorText: widget.postalCodeError,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => widget.onStateChanged(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provinsi *',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ProvinceModel>(
          initialValue: widget.formState.selectedProvince,
          decoration: InputDecoration(
            prefixIcon: _isLoadingProvinces
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.map_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: widget.provinceError,
            hintText: 'Pilih Provinsi',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: widget.formState.provinces.map((province) {
            return DropdownMenuItem(
              value: province,
              child: Text(province.name),
            );
          }).toList(),
          onChanged: _isLoadingProvinces ? null : _onProvinceChanged,
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildRegencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kota/Kabupaten *',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RegencyModel>(
          initialValue: widget.formState.selectedRegency,
          decoration: InputDecoration(
            prefixIcon: _isLoadingRegencies
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.location_city_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: widget.regencyError,
            hintText: 'Pilih Kota/Kabupaten',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: widget.formState.regencies.map((regency) {
            return DropdownMenuItem(value: regency, child: Text(regency.name));
          }).toList(),
          onChanged:
              widget.formState.selectedProvince == null || _isLoadingRegencies
              ? null
              : _onRegencyChanged,
          isExpanded: true,
        ),
        if (widget.formState.selectedProvince == null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Pilih provinsi terlebih dahulu',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  Widget _buildDistrictDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kecamatan *',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DistrictModel>(
          initialValue: widget.formState.selectedDistrict,
          decoration: InputDecoration(
            prefixIcon: _isLoadingDistricts
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.apartment_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: widget.districtError,
            hintText: 'Pilih Kecamatan',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: widget.formState.districts.map((district) {
            return DropdownMenuItem(
              value: district,
              child: Text(district.name),
            );
          }).toList(),
          onChanged:
              widget.formState.selectedRegency == null || _isLoadingDistricts
              ? null
              : _onDistrictChanged,
          isExpanded: true,
        ),
        if (widget.formState.selectedRegency == null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Pilih kota/kabupaten terlebih dahulu',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  // Widget _buildVillageDropdown() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Kelurahan/Desa *',
  //         style: const TextStyle(
  //           fontSize: 12,
  //           color: Colors.black54,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       DropdownButtonFormField<VillageModel>(
  //         initialValue: widget.formState.selectedVillage,
  //         decoration: InputDecoration(
  //           prefixIcon: _isLoadingVillages
  //               ? const SizedBox(
  //                   width: 20,
  //                   height: 20,
  //                   child: Padding(
  //                     padding: EdgeInsets.all(12),
  //                     child: CircularProgressIndicator(strokeWidth: 2),
  //                   ),
  //                 )
  //               : const Icon(Icons.place_outlined, size: 20),
  //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //           errorText: widget.villageError,
  //           hintText: 'Pilih Kelurahan/Desa',
  //           contentPadding: const EdgeInsets.symmetric(
  //             horizontal: 16,
  //             vertical: 12,
  //           ),
  //         ),
  //         items: widget.formState.villages.map((village) {
  //           return DropdownMenuItem(value: village, child: Text(village.name));
  //         }).toList(),
  //         onChanged:
  //             widget.formState.selectedDistrict == null || _isLoadingVillages
  //             ? null
  //             : _onVillageChanged,
  //         isExpanded: true,
  //       ),
  //       if (widget.formState.selectedDistrict == null)
  //         Padding(
  //           padding: const EdgeInsets.only(top: 4, left: 12),
  //           child: Text(
  //             'Pilih kecamatan terlebih dahulu',
  //             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    textCapitalization,
    int? maxLength,
    int? maxLines,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          maxLength: maxLength,
          maxLines: maxLines ?? 1,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: errorText,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
