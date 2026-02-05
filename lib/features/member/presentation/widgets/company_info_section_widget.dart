// lib/features/member/presentation/widgets/company_info_section_widget.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/branch_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/member_registration_form_state.dart';

/// Widget untuk section informasi perusahaan
class CompanyInfoSectionWidget extends StatefulWidget {
  final MemberRegistrationFormState formState;
  final Function(String?) onCompanyTypeChanged;
  final Function(Branch?) onBranchChanged;
  final String? companyNameError;
  final String? nikError;
  final String? npwpError;
  final String? companyTypeError;
  final String? branchError;

  const CompanyInfoSectionWidget({
    super.key,
    required this.formState,
    required this.onCompanyTypeChanged,
    required this.onBranchChanged,
    this.companyNameError,
    this.nikError,
    this.npwpError,
    this.companyTypeError,
    this.branchError,
  });

  @override
  State<CompanyInfoSectionWidget> createState() =>
      _CompanyInfoSectionWidgetState();
}

class _CompanyInfoSectionWidgetState extends State<CompanyInfoSectionWidget> {
  final List<String> _companyTypes = ['Company', 'Individual'];
  final List<String> _companyTitles = ['PT', 'CV', 'UD'];
  final List<String> _individualTitles = [
    'Toko',
    'Home Industri',
    'Freelance',
  ];
  final List<String> _productNeeds = [
    'Bahan Baku Springbed & Sofa',
    'Furniture',
  ];
  final Map<String, String> _titleAbbreviations = {
    'Toko': 'TK',
    'Home Industri': 'HI',
    'PT': 'PT',
    'CV': 'CV',
    'UD': 'UD',
  };
  final TextEditingController _suffixController = TextEditingController();
  String? _selectedTitle;
  String? _selectedSuffix;
  String _formattedCompanyName = '';
  late BranchCubit bCubit;

  List<String> get _currentTitles {
    if (widget.formState.companyType == 'Company') {
      return _companyTitles;
    } else if (widget.formState.companyType == 'Individual') {
      return _individualTitles;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    bCubit = context.read<BranchCubit>();
    _selectedSuffix = widget.formState.companySuffix;
    _suffixController.text = _selectedSuffix ?? '';
    widget.formState.companyNameController.addListener(_updateFormattedName);
  }

  @override
  void dispose() {
    widget.formState.companyNameController.removeListener(_updateFormattedName);
    _suffixController.dispose();
    super.dispose();
  }

  bool get _isFreelanceIndividual {
    return widget.formState.companyType == 'Individual' &&
        _selectedTitle == 'Freelance';
  }

  String? _getAbbreviationForTitle(String? title) {
    if (title == null) return null;
    if (title == 'Freelance') return null;
    return _titleAbbreviations[title] ?? title;
  }

  void _setSuffix(String? suffix, {bool updateFormattedName = true}) {
    _selectedSuffix = suffix;
    _suffixController.text = suffix ?? '';
    widget.formState.companySuffix = suffix;
    if (updateFormattedName) {
      _updateFormattedName();
    }
  }

  void _updateFormattedName() {
    setState(() {
      final cleanName = widget.formState.companyNameController.text
          .trim()
          .toUpperCase();
      if (cleanName.isEmpty) {
        _formattedCompanyName = '';
        return;
      }

      // For Company/Individual with suffix
      if ((widget.formState.companyType == 'Company' ||
              widget.formState.companyType == 'Individual') &&
          _selectedSuffix != null &&
          _selectedSuffix!.isNotEmpty) {
        _formattedCompanyName = '$cleanName $_selectedSuffix';
      } else {
        _formattedCompanyName = cleanName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
              'Informasi Perusahaan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            // Jenis Perusahaan Dropdown
            _buildDropdownField(
              label: 'Jenis Perusahaan',
              value: widget.formState.companyType,
              items: _companyTypes,
              onChanged: (value) {
                widget.onCompanyTypeChanged(value);
                _selectedTitle = null;
                _setSuffix(null, updateFormattedName: false);
                _updateFormattedName();
              },
              errorText: widget.companyTypeError,
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 12),

            // Gelar Perusahaan
            _buildDropdownField(
              label: 'Gelar Perusahaan',
              value: _selectedTitle,
              items: _currentTitles,
              onChanged: (value) {
                _selectedTitle = value;
                if (_isFreelanceIndividual) {
                  _setSuffix(null, updateFormattedName: false);
                } else {
                  _setSuffix(_getAbbreviationForTitle(value),
                      updateFormattedName: false);
                }
                _updateFormattedName();
              },
              icon: Icons.apartment_outlined,
            ),
            const SizedBox(height: 12),

            // Company Name Field with suffix
            if (widget.formState.companyType == 'Company' ||
                widget.formState.companyType == 'Individual') ...[
              _buildCompanyNameWithSuffix(),
            ] else ...[
              _buildTextField(
                label: 'Nama',
                controller: widget.formState.companyNameController,
                errorText: widget.companyNameError,
                textCapitalization: TextCapitalization.characters,
                icon: Icons.business_outlined,
                onChanged: (value) {
                  widget.formState.companyNameController.value = widget
                      .formState
                      .companyNameController
                      .value
                      .copyWith(
                        text: value.toUpperCase(),
                        selection: TextSelection.collapsed(
                          offset: value.toUpperCase().length,
                        ),
                      );
                  _updateFormattedName();
                },
              ),
            ],
            const SizedBox(height: 8),

            // Preview formatted name
            if (_formattedCompanyName.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondaryColor, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.business,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formattedCompanyName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // NIK Field
            _buildTextField(
              label: 'NIK *',
              controller: widget.formState.nikController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              errorText: widget.nikError,
              icon: Icons.badge_outlined,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),

            // NPWP Field
            _buildTextField(
              label: 'NPWP',
              controller: widget.formState.npwpController,
              keyboardType: TextInputType.number,
              maxLength: 15,
              errorText: widget.npwpError,
              icon: Icons.credit_card_outlined,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),

            // Kebutuhan Produk
            _buildDropdownField(
              label: 'Kebutuhan Produk',
              value: widget.formState.productNeed,
              items: _productNeeds,
              onChanged: (value) {
                setState(() {
                  widget.formState.productNeed = value;
                });
              },
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 12),

            // Branch Dropdown
            _buildBranchDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyNameWithSuffix() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name Field
            Expanded(
              child: TextFormField(
                controller: widget.formState.companyNameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.business_outlined, size: 20),
                  hintText: 'Nama Usaha',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.blackColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.blackColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  errorText: widget.companyNameError,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  widget.formState.companyNameController.value = widget
                      .formState
                      .companyNameController
                      .value
                      .copyWith(
                        text: value.toUpperCase(),
                        selection: TextSelection.collapsed(
                          offset: value.toUpperCase().length,
                        ),
                      );
                  _updateFormattedName();
                },
              ),
            ),
            const SizedBox(width: 8),
            // Suffix (Abbreviation)
            SizedBox(
              width: 105,
              child: _isFreelanceIndividual
                  ? DropdownButtonFormField<String>(
                      initialValue: _selectedSuffix,
                      isExpanded: true,
                      menuMaxHeight: 200,
                      borderRadius: BorderRadius.circular(8),
                      decoration: InputDecoration(
                        hintText: 'Pilih',
                        hintStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        filled: true,
                        fillColor: AppColors.whiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.blackColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.blackColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'IBU',
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('IBU',
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'BP',
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child:
                                Text('BP', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        _setSuffix(value);
                      },
                      dropdownColor: AppColors.whiteColor,
                    )
                  : TextFormField(
                      controller: _suffixController,
                      readOnly: true,
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        hintText: 'Singkatan',
                        hintStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        filled: true,
                        fillColor: AppColors.whiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.blackColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.blackColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Cabang Terdekat',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),

        BlocBuilder<BranchCubit, BranchState>(
          bloc: bCubit..fetchBranches(),
          builder: (context, state) {
            if (state is BranchLoading) {
              return const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is BranchListLoaded) {
              return DropdownButtonFormField<Branch>(
                initialValue: widget.formState.selectedBranch,
                menuMaxHeight: 250,
                dropdownColor: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(8),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                  hintText: 'Pilih Cabang',
                  filled: true,
                  fillColor: AppColors.whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.blackColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.blackColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  errorText: widget.branchError,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: state.branches.map((branch) {
                  return DropdownMenuItem<Branch>(
                    value: branch,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${branch.branchName} - ${branch.city}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: widget.onBranchChanged,
                isExpanded: true,
                // onChanged: (value) {},
              );
            }

            if (state is BranchError) {
              return Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? errorText,
    required IconData icon,
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
        DropdownButtonFormField<String>(
          value: value,
          menuMaxHeight: 200, // Limit height to show ~5 items
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            hintText: 'Pilih $label',
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            filled: true,
            fillColor: AppColors.whiteColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blackColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blackColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              // PERBAIKAN 2: Padding kiri kanan 8
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(item, style: const TextStyle(fontSize: 14)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: AppColors.whiteColor,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLength,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    Function(String)? onChanged,
    required IconData icon,
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
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            filled: true,
            fillColor: AppColors.whiteColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blackColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blackColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorText: errorText,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
