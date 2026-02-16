// lib/features/member/presentation/widgets/shipping_address_section_widget.dart

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/member_registration_cubit.dart';
import '../utils/member_registration_form_state.dart';
import '../../data/models/province_model.dart';
import '../../data/models/regency_model.dart';
import '../../data/models/district_model.dart';
import '../../data/models/shipping_address_model.dart';

/// Widget untuk section alamat pengiriman dengan support multiple addresses
class ShippingAddressSectionWidget extends StatefulWidget {
  final MemberRegistrationFormState formState;
  final Map<String, String?> errors;
  final VoidCallback onStateChanged;

  const ShippingAddressSectionWidget({
    super.key,
    required this.formState,
    required this.errors,
    required this.onStateChanged,
  });

  @override
  State<ShippingAddressSectionWidget> createState() =>
      _ShippingAddressSectionWidgetState();
}

class _ShippingAddressSectionWidgetState
    extends State<ShippingAddressSectionWidget> {
  // Track loading states per address
  final Map<String, bool> _isLoadingProvinces = {};
  final Map<String, bool> _isLoadingRegencies = {};
  final Map<String, bool> _isLoadingDistricts = {};

  @override
  void initState() {
    super.initState();
    // Initialize with one shipping address if empty
    if (widget.formState.shippingAddresses.isEmpty) {
      widget.formState.addShippingAddress();
    }
    // Load provinces for all addresses
    _loadProvincesForAll();
  }

  void _loadProvincesForAll() {
    for (final address in widget.formState.shippingAddresses) {
      _loadProvinces(address);
    }
  }

  void _loadProvinces(ShippingAddressModel address) {
    setState(() => _isLoadingProvinces[address.id] = true);
    context.read<MemberRegistrationCubit>().loadShippingProvinces(address.id);
  }

  void _onProvinceChanged(
    ShippingAddressModel address,
    ProvinceModel? province,
  ) {
    setState(() {
      address.selectedProvince = province;
      address.resetRegency();
      _isLoadingRegencies[address.id] = true;
    });

    if (province != null) {
      context.read<MemberRegistrationCubit>().loadShippingRegencies(
        address.id,
        province.code,
      );
    }
    widget.onStateChanged();
  }

  void _onRegencyChanged(ShippingAddressModel address, RegencyModel? regency) {
    setState(() {
      address.selectedRegency = regency;
      address.resetDistrict();
      _isLoadingDistricts[address.id] = true;
    });

    if (regency != null) {
      context.read<MemberRegistrationCubit>().loadShippingDistricts(
        address.id,
        regency.code,
      );
    }
    widget.onStateChanged();
  }

  void _onDistrictChanged(
    ShippingAddressModel address,
    DistrictModel? district,
  ) {
    setState(() {
      address.selectedDistrict = district;
    });
    widget.onStateChanged();
  }

  void _onSameAsCompanyToggled(ShippingAddressModel address, bool value) {
    if (value && !_isCompanyAddressComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi alamat perusahaan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      if (value) {
        // Ensure only one shipping address can use company address.
        for (final shippingAddress in widget.formState.shippingAddresses) {
          if (shippingAddress.id != address.id) {
            shippingAddress.sameAsCompanyAddress = false;
          }
        }
      }

      address.sameAsCompanyAddress = value;
      if (value) {
        // Copy company address data
        final index = widget.formState.shippingAddresses.indexOf(address);
        widget.formState.copyCompanyAddressToShipping(index);
      } else {
        // Clear the fields
        address.clear();
        _loadProvinces(address);
      }
    });
    widget.onStateChanged();
  }

  bool _isCompanyAddressComplete() {
    return widget.formState.addressController.text.trim().isNotEmpty &&
        widget.formState.selectedProvince != null &&
        widget.formState.selectedRegency != null &&
        widget.formState.selectedDistrict != null &&
        widget.formState.postalCodeController.text.trim().isNotEmpty;
  }

  bool _hasActiveSameAsCompanyAddress() {
    return widget.formState.shippingAddresses.any(
      (address) => address.sameAsCompanyAddress,
    );
  }

  bool _showSameAsCompanyToggle(ShippingAddressModel address) {
    if (!_isCompanyAddressComplete()) {
      return false;
    }

    final hasActiveAddress = _hasActiveSameAsCompanyAddress();
    if (!hasActiveAddress) {
      return true;
    }

    // Keep showing toggle only for the active card.
    return address.sameAsCompanyAddress;
  }

  void _addNewAddress() {
    setState(() {
      widget.formState.addShippingAddress();
      final newAddress = widget.formState.shippingAddresses.last;
      _loadProvinces(newAddress);
    });
    widget.onStateChanged();
  }

  void _removeAddress(int index) {
    if (widget.formState.shippingAddresses.length > 1) {
      setState(() {
        widget.formState.removeShippingAddress(index);
      });
      widget.onStateChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemberRegistrationCubit, MemberRegistrationState>(
      listener: (context, state) {
        if (state is MemberRegistrationShippingProvincesLoaded) {
          setState(() {
            final address = widget.formState.shippingAddresses.firstWhere(
              (a) => a.id == state.addressId,
              orElse: () => widget.formState.shippingAddresses.first,
            );
            address.provinces = state.provinces;
            _isLoadingProvinces[state.addressId] = false;
          });
        } else if (state is MemberRegistrationShippingRegenciesLoaded) {
          setState(() {
            final address = widget.formState.shippingAddresses.firstWhere(
              (a) => a.id == state.addressId,
              orElse: () => widget.formState.shippingAddresses.first,
            );
            address.regencies = state.regencies;
            _isLoadingRegencies[state.addressId] = false;
          });
        } else if (state is MemberRegistrationShippingDistrictsLoaded) {
          setState(() {
            final address = widget.formState.shippingAddresses.firstWhere(
              (a) => a.id == state.addressId,
              orElse: () => widget.formState.shippingAddresses.first,
            );
            address.districts = state.districts;
            _isLoadingDistricts[state.addressId] = false;
          });
        } else if (state is MemberRegistrationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          setState(() {
            _isLoadingProvinces.clear();
            _isLoadingRegencies.clear();
            _isLoadingDistricts.clear();
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Build cards for each shipping address
          ...widget.formState.shippingAddresses.asMap().entries.map((entry) {
            final index = entry.key;
            final address = entry.value;
            return _buildAddressCard(address, index);
          }),

          // Add new address button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextButton.icon(
              onPressed: _addNewAddress,
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryColor,
              ),
              label: const Text(
                'Tambah Alamat Pengiriman',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(ShippingAddressModel address, int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: AppColors.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alamat Pengiriman ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.formState.shippingAddresses.length > 1)
                  IconButton(
                    onPressed: () => _removeAddress(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Hapus alamat',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_showSameAsCompanyToggle(address)) ...[
              // Toggle "Sama dengan Alamat Perusahaan"
              Container(
                decoration: BoxDecoration(
                  color: address.sameAsCompanyAddress
                      ? AppColors.secondaryColor.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: address.sameAsCompanyAddress
                        ? AppColors.secondaryColor
                        : Colors.grey[300]!,
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  title: const Text(
                    'Sama Dengan Alamat Perusahaan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  value: address.sameAsCompanyAddress,
                  onChanged: (value) => _onSameAsCompanyToggled(address, value),
                  activeColor: AppColors.secondaryColor,
                  dense: true,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Jika sama dengan alamat perusahaan, tampilkan preview
            if (address.sameAsCompanyAddress)
              _buildCompanyAddressPreview()
            else
              // Address fields (editable)
              Column(
                children: [
                  // Alamat Lengkap
                  _buildTextField(
                    label: 'Alamat Lengkap',
                    controller: address.addressController,
                    textCapitalization: TextCapitalization.sentences,
                    icon: Icons.home_outlined,
                    maxLines: 3,
                    errorText: widget.errors['shippingAddress_$index'],
                  ),
                  const SizedBox(height: 16),

                  // Province Dropdown
                  _buildProvinceDropdown(address, index),
                  const SizedBox(height: 16),

                  // Regency Dropdown
                  _buildRegencyDropdown(address, index),
                  const SizedBox(height: 16),

                  // District Dropdown
                  _buildDistrictDropdown(address, index),
                  const SizedBox(height: 16),

                  // Kode Pos
                  _buildTextField(
                    label: 'Kode Pos',
                    controller: address.postalCodeController,
                    icon: Icons.local_post_office_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    errorText: widget.errors['shippingPostalCode_$index'],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown(ShippingAddressModel address, int index) {
    final isLoading = _isLoadingProvinces[address.id] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Provinsi',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ProvinceModel>(
          value: address.selectedProvince,
          decoration: InputDecoration(
            prefixIcon: isLoading
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
            errorText: widget.errors['shippingProvince_$index'],
            hintText: 'Pilih Provinsi',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: address.provinces.map((province) {
            return DropdownMenuItem(
              value: province,
              child: Text(province.name),
            );
          }).toList(),
          onChanged: isLoading
              ? null
              : (value) => _onProvinceChanged(address, value),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildRegencyDropdown(ShippingAddressModel address, int index) {
    final isLoading = _isLoadingRegencies[address.id] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kota/Kabupaten',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RegencyModel>(
          value: address.selectedRegency,
          decoration: InputDecoration(
            prefixIcon: isLoading
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
            errorText: widget.errors['shippingRegency_$index'],
            hintText: 'Pilih Kota/Kabupaten',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: address.regencies.map((regency) {
            return DropdownMenuItem(value: regency, child: Text(regency.name));
          }).toList(),
          onChanged: address.selectedProvince == null || isLoading
              ? null
              : (value) => _onRegencyChanged(address, value),
          isExpanded: true,
        ),
        if (address.selectedProvince == null)
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

  Widget _buildDistrictDropdown(ShippingAddressModel address, int index) {
    final isLoading = _isLoadingDistricts[address.id] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kecamatan',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DistrictModel>(
          value: address.selectedDistrict,
          decoration: InputDecoration(
            prefixIcon: isLoading
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
            errorText: widget.errors['shippingDistrict_$index'],
            hintText: 'Pilih Kecamatan',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: address.districts.map((district) {
            return DropdownMenuItem(
              value: district,
              child: Text(district.name),
            );
          }).toList(),
          onChanged: address.selectedRegency == null || isLoading
              ? null
              : (value) => _onDistrictChanged(address, value),
          isExpanded: true,
        ),
        if (address.selectedRegency == null)
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

  /// Preview alamat perusahaan (read-only) - selalu menampilkan data terbaru
  Widget _buildCompanyAddressPreview() {
    final formState = widget.formState;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Data akan mengikuti Alamat Perusahaan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreviewRow('Alamat', formState.addressController.text),
          _buildPreviewRow('Provinsi', formState.selectedProvince?.name ?? '-'),
          _buildPreviewRow(
            'Kota/Kabupaten',
            formState.selectedRegency?.name ?? '-',
          ),
          _buildPreviewRow(
            'Kecamatan',
            formState.selectedDistrict?.name ?? '-',
          ),
          _buildPreviewRow('Kode Pos', formState.postalCodeController.text),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    int? maxLength,
    int? maxLines,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
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
