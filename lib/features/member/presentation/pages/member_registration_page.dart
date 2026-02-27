// lib/features/member/presentation/pages/member_registration_page.dart

import 'dart:io';
import 'dart:convert';

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/member/data/models/district_model.dart';
import 'package:ekaplus_ekatunggal/features/member/data/models/province_model.dart';
import 'package:ekaplus_ekatunggal/features/member/data/models/regency_model.dart';
import 'package:ekaplus_ekatunggal/features/member/data/models/shipping_address_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../injection.dart' as di;
import '../../../auth/presentation/cubit/auth_session_cubit.dart';
import '../cubit/member_registration_cubit.dart';
import '../utils/member_registration_form_state.dart';
import '../widgets/identity_section_widget.dart';
import '../widgets/company_info_section_widget.dart';
import '../widgets/address_section_widget.dart';
import '../widgets/shipping_address_section_widget.dart';
// import '../widgets/supporting_data_section_widget.dart';
// import '../widgets/upload_documents_section_widget.dart';
import '../widgets/member_confirmation_dialog.dart';
import '../../domain/entities/member_registration.dart';
import '../../domain/entities/active_member_company.dart';
import '../../domain/usecases/get_active_member_companies_by_user_id.dart';
import '../enums/member_registration_intent.dart';

class MemberRegistrationPage extends StatefulWidget {
  final MemberRegistration? initialRegistration;
  final MemberRegistrationIntent? intent;
  final int? parentGcidId;
  final String? parentGcName;
  final ActiveMemberCompany? parentActiveCompany;

  const MemberRegistrationPage({
    super.key,
    this.initialRegistration,
    this.intent,
    this.parentGcidId,
    this.parentGcName,
    this.parentActiveCompany,
  });

  @override
  State<MemberRegistrationPage> createState() => _MemberRegistrationPageState();
}

class _MemberRegistrationPageState extends State<MemberRegistrationPage> {
  late MemberRegistrationFormState _formState;
  late MemberRegistrationCubit _memberCubit;

  Map<String, String?> _errors = {};
  bool _isSubmitting = false;
  DateTime? _selectedBirthDate;
  DateTime? _selectedBranchPicBirthDate;
  ActiveMemberCompany? _defaultHierarchySourceForNewCompany;
  final GetActiveMemberCompaniesByUserId _getActiveMemberCompaniesByUserId = di
      .myinjection<GetActiveMemberCompaniesByUserId>();

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _identityKey = GlobalKey();
  final GlobalKey _companyInfoKey = GlobalKey();
  final GlobalKey _addressKey = GlobalKey();
  final GlobalKey _shippingAddressKey = GlobalKey();
  final GlobalKey _supportingDataKey = GlobalKey();
  final GlobalKey _documentsKey = GlobalKey();

  bool get _isEditMode => widget.initialRegistration != null;
  int? get _editingRegistrationId => widget.initialRegistration?.id;
  bool get _isBcidMode =>
      !_isEditMode &&
      widget.intent ==
          MemberRegistrationIntent.addBranchToExistingGroupCustomer;

  static const Map<String, String> _companyTitleSuffixMap = {
    'Toko': 'TK',
    'Home Industri': 'HI',
    'PT': 'PT',
    'CV': 'CV',
    'UD': 'UD',
  };

  @override
  void initState() {
    super.initState();

    _memberCubit = di.myinjection<MemberRegistrationCubit>();

    final authState = context.read<AuthSessionCubit>().state;

    String userName = '';
    String userEmail = '';
    String userPhone = '';

    if (authState is AuthSessionAuthenticated) {
      userName = authState.user.fullName;
      userPhone = authState.user.phone;
      userEmail = authState.user.email;
    }

    _formState = MemberRegistrationFormState.fromUserData(
      nama: '',
      phone: '',
      email: '',
      birthPlace: '',
      dateOfBirth: '',
    );
    _formState.userNamaController.text = userName;
    _formState.userPhoneController.text = userPhone;
    _formState.userEmailController.text = userEmail;

    _selectedBirthDate = _parseBirthDate(_formState.dateOfBirthController.text);
    _selectedBranchPicBirthDate = _parseBirthDate(
      _formState.branchPicDateOfBirthController.text,
    );
    _formState.namaController.addListener(_syncBranchPicIfLinked);
    _formState.phoneController.addListener(_syncBranchPicIfLinked);
    _formState.emailController.addListener(_syncBranchPicIfLinked);
    _formState.birthPlaceController.addListener(_syncBranchPicIfLinked);

    if (_isEditMode) {
      _prefillFromRegistration(widget.initialRegistration!);
      _loadShippingAddressesForEdit(widget.initialRegistration!.id);
    } else if (_isBcidMode && widget.parentActiveCompany != null) {
      _prefillFromActiveCompany(widget.parentActiveCompany!);
    } else if (widget.intent == MemberRegistrationIntent.newCompany) {
      _loadDefaultHierarchyForNewCompany();
    }
  }

  Future<void> _loadDefaultHierarchyForNewCompany() async {
    try {
      final result = await _getActiveMemberCompaniesByUserId.execute();
      if (!mounted) return;
      result.fold((_) {}, (companies) {
        if (companies.isEmpty) return;
        final ownerSource = companies.firstWhere(
          (e) => e.memberIsOwner,
          orElse: () => companies.first,
        );
        setState(() {
          _defaultHierarchySourceForNewCompany = ownerSource;
        });
      });
    } catch (_) {
      // Hidden defaults only; form should remain usable if this lookup fails.
    }
  }

  void _prefillFromActiveCompany(ActiveMemberCompany company) {
    _formState.namaController.text =
        (company.customerOwnerName?.trim().isNotEmpty ?? false)
        ? company.customerOwnerName!
        : _formState.namaController.text;
    _formState.phoneController.text =
        (company.customerOwnerPhone?.trim().isNotEmpty ?? false)
        ? company.customerOwnerPhone!
        : _formState.phoneController.text;
    _formState.emailController.text =
        (company.customerOwnerEmail?.trim().isNotEmpty ?? false)
        ? company.customerOwnerEmail!
        : _formState.emailController.text;
    _formState.birthPlaceController.text =
        (company.customerOwnerPlaceOfBirth?.trim().isNotEmpty ?? false)
        ? company.customerOwnerPlaceOfBirth!
        : _formState.birthPlaceController.text;

    final dobRaw = (company.customerOwnerDateOfBirth ?? '').trim();
    if (dobRaw.isNotEmpty) {
      final parsed = DateTime.tryParse(dobRaw);
      if (parsed != null) {
        _selectedBirthDate = parsed;
        _formState.dateOfBirthController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(parsed.toLocal());
      }
    }

    _formState.companyType = company.customerCompanyType;
    _formState.companyTitle = company.customerCompanyTitle;
    _prefillCompanyNameAndSuffix(
      company.customerCompanyName ?? company.gcName ?? '',
      company.customerCompanyTitle,
    );
    _formState.productNeed = null;
    // BCID flow: PIC Branch should be entered per branch, do not prefill.
    _formState.branchPicSameAsOwner = false;
    _formState.branchPicNameController.clear();
    _formState.branchPicPhoneController.clear();
    _formState.branchPicEmailController.clear();
    _formState.branchPicBirthPlaceController.clear();
    _formState.branchPicDateOfBirthController.clear();
    _selectedBranchPicBirthDate = null;
  }

  void _prefillFromRegistration(MemberRegistration registration) {
    _formState.namaController.text = registration.user.fullName;
    _formState.phoneController.text = registration.user.phone;
    _formState.emailController.text = registration.user.email;
    _formState.birthPlaceController.text = registration.user.placeOfBirth;
    if (registration.user.dateOfBirth != null) {
      final dt = registration.user.dateOfBirth!;
      _selectedBirthDate = dt;
      _formState.dateOfBirthController.text = DateFormat(
        'dd MMMM yyyy',
        'id_ID',
      ).format(dt.toLocal());
    }

    _formState.companyType = registration.entity.isEmpty
        ? null
        : registration.entity;
    _formState.companyTitle = registration.companyTitle;
    _formState.productNeed = registration.productNeed;
    _prefillCompanyNameAndSuffix(
      registration.businessName,
      registration.companyTitle,
    );
    _formState.selectedBranch = registration.branch.id == 0
        ? null
        : registration.branch;

    _formState.addressController.text = registration.address;
    _formState.postalCodeController.text = registration.postalCode;
    _formState.selectedProvince = registration.province.isEmpty
        ? null
        : ProvinceModel(code: '', name: registration.province);
    _formState.selectedRegency = registration.city.isEmpty
        ? null
        : RegencyModel(code: '', name: registration.city, provinceId: '');
    _formState.selectedDistrict = registration.district.isEmpty
        ? null
        : DistrictModel(code: '', name: registration.district, regencyId: '');
    _formState.branchPicNameController.text =
        registration.branchOwnerName ?? '';
    _formState.branchPicPhoneController.text =
        registration.branchOwnerPhone ?? '';
    _formState.branchPicEmailController.text =
        registration.branchOwnerEmail ?? '';
    _formState.branchPicBirthPlaceController.text =
        registration.branchOwnerPlaceOfBirth ?? '';
    final branchPicDob = _parseBirthDate(
      registration.branchOwnerDateOfBirth ?? '',
    );
    if (branchPicDob != null) {
      _selectedBranchPicBirthDate = branchPicDob;
      _formState.branchPicDateOfBirthController.text = DateFormat(
        'dd MMMM yyyy',
        'id_ID',
      ).format(branchPicDob.toLocal());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_formState.selectedProvince != null &&
          _formState.selectedProvince!.code.isNotEmpty) {
        _memberCubit.loadRegencies(_formState.selectedProvince!.code);
      }
      if (_formState.selectedRegency != null &&
          _formState.selectedRegency!.code.isNotEmpty) {
        _memberCubit.loadDistricts(_formState.selectedRegency!.code);
      }
    });
  }

  void _prefillCompanyNameAndSuffix(String fullName, String? companyTitle) {
    final raw = fullName.trim();
    if (raw.isEmpty) {
      _formState.companyNameController.clear();
      return;
    }

    String? suffix;
    if (companyTitle == 'Freelance') {
      final upper = raw.toUpperCase();
      if (upper.endsWith(' IBU')) suffix = 'IBU';
      if (upper.endsWith(' BP')) suffix = 'BP';
    } else if (companyTitle != null && companyTitle.isNotEmpty) {
      suffix = _companyTitleSuffixMap[companyTitle];
    }

    if (suffix != null && suffix.isNotEmpty) {
      final upper = raw.toUpperCase();
      final suffixToken = ' $suffix';
      if (upper.endsWith(suffixToken)) {
        _formState.companySuffix = suffix;
        _formState.companyNameController.text = raw
            .substring(0, raw.length - suffixToken.length)
            .trim();
        return;
      }
      _formState.companySuffix = suffix;
    }

    _formState.companyNameController.text = raw;
  }

  Future<void> _loadShippingAddressesForEdit(int parentId) async {
    try {
      final token = await SessionManager.getToken();
      Future<http.Response> fetchWithSpec(Map<String, dynamic> spec) async {
        final uri = Uri.parse(
          '${ApiConfig.baseUrl}/api/resource/customer_register_address'
          '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
        );
        return http.get(
          uri,
          headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        );
      }

      http.Response response = await fetchWithSpec({
        'fields': ['*'],
        'filters': [
          ['customer_register_id', '=', parentId.toString()],
        ],
        'order_by': [
          ['idx_row', 'asc'],
          ['id', 'asc'],
        ],
      });
      if (response.statusCode != 200) {
        response = await fetchWithSpec({
          'fields': ['*'],
          'filters': [
            ['parent_id', '=', parentId.toString()],
            ['parent_type', '=', 'customer_register'],
          ],
          'order_by': [
            ['idx', 'asc'],
            ['id', 'asc'],
          ],
        });
      }
      if (response.statusCode != 200) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];
      if (data is! List) return;

      final shipping = <ShippingAddressModel>[];
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final model = ShippingAddressModel.create();
        model.labelController.text = (item['label'] ?? '').toString();
        model.addressController.text = (item['address'] ?? '').toString();
        model.postalCodeController.text = (item['postal_code'] ?? '')
            .toString();
        model.picNameController.text = (item['pic_name'] ?? '').toString();
        model.picPhoneController.text = _displayPhone(
          (item['pic_phone'] ?? '').toString(),
        );
        model.isDefault = item['is_default'] == 1 || item['is_default'] == true;
        model.sameAsCompanyAddress =
            model.addressController.text.trim() ==
                _formState.addressController.text.trim() &&
            (item['province']?.toString() ?? '') ==
                (_formState.selectedProvince?.name ?? '') &&
            (item['city']?.toString() ?? '') ==
                (_formState.selectedRegency?.name ?? '') &&
            (item['district']?.toString() ?? '') ==
                (_formState.selectedDistrict?.name ?? '') &&
            model.postalCodeController.text.trim() ==
                _formState.postalCodeController.text.trim();

        final provinceName = (item['province'] ?? '').toString();
        final cityName = (item['city'] ?? '').toString();
        final districtName = (item['district'] ?? '').toString();
        if (provinceName.isNotEmpty) {
          model.selectedProvince = ProvinceModel(code: '', name: provinceName);
        }
        if (cityName.isNotEmpty) {
          model.selectedRegency = RegencyModel(
            code: '',
            name: cityName,
            provinceId: '',
          );
        }
        if (districtName.isNotEmpty) {
          model.selectedDistrict = DistrictModel(
            code: '',
            name: districtName,
            regencyId: '',
          );
        }
        shipping.add(model);
      }

      if (!mounted) return;
      setState(() {
        for (final old in _formState.shippingAddresses) {
          old.dispose();
        }
        _formState.shippingAddresses = shipping.isEmpty
            ? [ShippingAddressModel.create()]
            : shipping;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final address in _formState.shippingAddresses) {
          _memberCubit.loadShippingProvinces(address.id);
          if (address.selectedProvince != null &&
              address.selectedProvince!.code.isNotEmpty) {
            _memberCubit.loadShippingRegencies(
              address.id,
              address.selectedProvince!.code,
            );
          }
          if (address.selectedRegency != null &&
              address.selectedRegency!.code.isNotEmpty) {
            _memberCubit.loadShippingDistricts(
              address.id,
              address.selectedRegency!.code,
            );
          }
        }
      });
    } catch (_) {}
  }

  String _displayPhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62') && digits.length > 2) {
      return '0${digits.substring(2)}';
    }
    if (digits.startsWith('0')) return digits;
    if (trimmed.startsWith('+62') && digits.length > 2) {
      return '0${digits.substring(2)}';
    }
    return trimmed;
  }

  DateTime? _parseBirthDate(String value) {
    if (value.trim().isEmpty) return null;

    // Preferred display format: "01 Februari 2000"
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').parseStrict(value.trim());
    } catch (_) {}

    // Fallback for older stored format: "01/02/2000"
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(value.trim());
    } catch (_) {}

    return null;
  }

  void _syncBranchPicIfLinked() {
    if (!_formState.branchPicSameAsOwner) return;
    _formState.syncBranchPicWithOwner();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _formState.namaController.removeListener(_syncBranchPicIfLinked);
    _formState.phoneController.removeListener(_syncBranchPicIfLinked);
    _formState.emailController.removeListener(_syncBranchPicIfLinked);
    _formState.birthPlaceController.removeListener(_syncBranchPicIfLinked);
    _formState.dispose();
    _scrollController.dispose();
    _memberCubit.close();
    super.dispose();
  }

  void _onCompanyTypeChanged(String? type) {
    setState(() {
      _formState.companyType = type;
      _errors.remove('companyType');
    });
  }

  void _onBranchChanged(Branch? branch) {
    setState(() {
      _formState.selectedBranch = branch;
      _errors.remove('branch');
    });
  }

  Future<void> _selectBirthDate() async {
    final DateTime initial = _selectedBirthDate ?? DateTime(2000);
    DateTime tempPicked = initial;

    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 320,
          color: AppColors.whiteColor,
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text('Batal'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text('Selesai'),
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _selectedBirthDate = tempPicked;
                          _formState.dateOfBirthController.text = DateFormat(
                            'dd MMMM yyyy',
                            'id_ID',
                          ).format(_selectedBirthDate!);
                          if (_formState.branchPicSameAsOwner) {
                            _formState.branchPicDateOfBirthController.text =
                                _formState.dateOfBirthController.text;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initial,
                  minimumDate: DateTime(1950),
                  maximumDate: DateTime.now(),
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime picked) {
                    tempPicked = picked;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectBranchPicBirthDate() async {
    final DateTime initial = _selectedBranchPicBirthDate ?? DateTime(2000);
    DateTime tempPicked = initial;

    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 320,
          color: AppColors.whiteColor,
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text('Batal'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text('Selesai'),
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _selectedBranchPicBirthDate = tempPicked;
                          _formState.branchPicDateOfBirthController.text =
                              DateFormat(
                                'dd MMMM yyyy',
                                'id_ID',
                              ).format(_selectedBranchPicBirthDate!);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initial,
                  minimumDate: DateTime(1950),
                  maximumDate: DateTime.now(),
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime picked) {
                    tempPicked = picked;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    final errors = _formState.validate();

    if (errors.isNotEmpty) {
      setState(() => _errors = errors);

      AppSnackbar.showRaw(context, 
        SnackBar(
          content: Text(
            'Masih ada field wajib diisi atau error (${errors.length})!',
          ),
          backgroundColor: Colors.red,
        ),
      );

      _scrollToFirstError(errors);
      return;
    }

    setState(() => _errors = {});

    final Map<String, File> files = {};

    if (_formState.ktpFile != null) {
      files['ktp_image'] = _formState.ktpFile!;
    }
    if (_formState.npwpFile != null) {
      files['npwp_image'] = _formState.npwpFile!;
    }

    final formData = _formState.toApiCustomerRegisterJson();
    final authState = context.read<AuthSessionCubit>().state;
    if (authState is AuthSessionAuthenticated) {
      formData['ekaplus_user'] = authState.user.id;
    }
    final hierarchySource =
        widget.parentActiveCompany ?? _defaultHierarchySourceForNewCompany;

    final needsOwnerPermission = (!_isEditMode && _isBcidMode);
    if (needsOwnerPermission &&
        hierarchySource != null &&
        !hierarchySource.memberIsOwner) {
      AppSnackbar.showRaw(context, 
        const SnackBar(
          content: Text(
            'Akun sharing tidak memiliki hak untuk menambah cabang (BCID)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isEditMode && widget.intent == MemberRegistrationIntent.newCompany) {
      formData['registration_mode'] = 'gcid';
      if (hierarchySource?.nbidId != null) {
        formData['nbid'] = hierarchySource!.nbidId;
      }
      if (hierarchySource?.gpidId != null) {
        formData['gpid'] = hierarchySource!.gpidId;
      }
    }
    if (_isBcidMode) {
      final selectedGcid = hierarchySource?.gcidId ?? widget.parentGcidId;
      if (selectedGcid != null) {
        formData['gcid'] = selectedGcid;
      }
      if (hierarchySource?.nbidId != null) {
        formData['nbid'] = hierarchySource!.nbidId;
      }
      if (hierarchySource?.gpidId != null) {
        formData['gpid'] = hierarchySource!.gpidId;
      }
      formData['registration_mode'] = 'bcid';
    }
    if (_editingRegistrationId != null) {
      formData['id'] = _editingRegistrationId;
    }

    await _showConfirmationDialog(formData, files);
  }

  void _scrollToFirstError(Map<String, String?> errors) {
    GlobalKey? target;

    if (errors.containsKey('ownerName') ||
        errors.containsKey('ownerPhone') ||
        errors.containsKey('ownerEmail') ||
        errors.containsKey('branchPicName') ||
        errors.containsKey('branchPicPhone') ||
        errors.containsKey('branchPicEmail') ||
        errors.containsKey('birthPlace') ||
        errors.containsKey('dateOfBirth')) {
      target = _identityKey;
    } else if (errors.containsKey('companyType') ||
        errors.containsKey('nik') ||
        errors.containsKey('companyTitle') ||
        errors.containsKey('companySuffix') ||
        errors.containsKey('companyName') ||
        errors.containsKey('productNeed') ||
        errors.containsKey('branch')) {
      target = _companyInfoKey;
    } else if (errors.containsKey('address') ||
        errors.containsKey('province') ||
        errors.containsKey('regency') ||
        errors.containsKey('district') ||
        errors.containsKey('postalCode')) {
      target = _addressKey;
    } else if (_hasShippingAddressError(errors)) {
      target = _shippingAddressKey;
    } else if (errors.containsKey('contactPerson')) {
      target = _supportingDataKey;
    } else if (errors.containsKey('ktpFile')) {
      target = _documentsKey;
    }

    if (target?.currentContext != null) {
      Scrollable.ensureVisible(
        target!.currentContext!,
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  bool _hasShippingAddressError(Map<String, String?> errors) {
    if (errors.containsKey('shippingAddresses')) {
      return true;
    }

    return errors.keys.any((key) => key.startsWith('shipping'));
  }

  Future<bool> _showDiscardChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Data form yang sudah diisi belum disimpan. Yakin ingin kembali?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<bool> _onWillPop() async {
    if (_isSubmitting) {
      return false;
    }

    if (!_formState.hasAnyInput()) {
      return true;
    }

    return _showDiscardChangesDialog();
  }

  Future<void> _handleBackPressed() async {
    final canPop = await _onWillPop();
    if (!mounted) return;
    if (canPop) {
      context.pop();
    }
  }

  Future<void> _showConfirmationDialog(
    Map<String, dynamic> formData,
    Map<String, File> files,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MemberConfirmationDialog(
        formData: formData,
        onClose: () => Navigator.pop(context),
        onEdit: () => Navigator.pop(context),
        onConfirm: () async {
          Navigator.pop(context);
          await _submitToDatabase(formData, files);
        },
      ),
    );
  }

  Future<void> _submitToDatabase(
    Map<String, dynamic> formData,
    Map<String, File> files,
  ) async {
    setState(() => _isSubmitting = true);
    await _memberCubit.submitRegistration(formData, files: files);
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _memberCubit,
      child: BlocConsumer<MemberRegistrationCubit, MemberRegistrationState>(
        listener: (context, state) {
          if (state is MemberRegistrationSuccess) {
            AppSnackbar.showRaw(context, 
              SnackBar(
                content: Text(
                  _isEditMode
                      ? 'Pengajuan berhasil diperbarui'
                      : 'Pengajuan berhasil dikirim',
                ),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.of(context).pop();
            context.pushReplacementNamed('memberList');
          }

          if (state is MemberRegistrationError) {
            AppSnackbar.showRaw(context, 
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              appBar: CustomHeaderAppBar(
                title: _isEditMode ? 'Ubah Pengajuan' : 'Hubungkan Usaha',
                subtitle: _isEditMode
                    ? 'Perbarui Draft Pengajuan'
                    : 'Lengkapi Profil Anda',
                onBackPressed: _handleBackPressed,
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            key: _identityKey,
                            child: IdentitySectionWidget(
                              formState: _formState,
                              onSelectBirthDate: _selectBirthDate,
                              onStateChanged: () => setState(() {}),
                              ownerNameError: _errors['ownerName'],
                              ownerPhoneError: _errors['ownerPhone'],
                              ownerEmailError: _errors['ownerEmail'],
                              branchPicNameError: _errors['branchPicName'],
                              branchPicPhoneError: _errors['branchPicPhone'],
                              branchPicEmailError: _errors['branchPicEmail'],
                              birthPlaceError: _errors['birthPlace'],
                              dateOfBirthError: _errors['dateOfBirth'],
                              onSelectBranchPicBirthDate:
                                  _selectBranchPicBirthDate,
                              birthFieldsReadOnly: _isBcidMode,
                            ),
                          ),
                          Container(
                            key: _companyInfoKey,
                            child: CompanyInfoSectionWidget(
                              formState: _formState,
                              onCompanyTypeChanged: _onCompanyTypeChanged,
                              onBranchChanged: _onBranchChanged,
                              companyTypeError: _errors['companyType'],
                              companyTitleError: _errors['companyTitle'],
                              companySuffixError: _errors['companySuffix'],
                              companyNameError: _errors['companyName'],
                              productNeedError: _errors['productNeed'],
                              // nikError: _errors['nik'],
                              // npwpError: _errors['npwp'],
                              branchError: _errors['branch'],
                              lockCompanyIdentityFields: _isBcidMode,
                            ),
                          ),
                          Container(
                            key: _addressKey,
                            child: AddressSectionWidget(
                              formState: _formState,
                              onStateChanged: () => setState(() {}),
                              addressError: _errors['address'],
                              provinceError: _errors['province'],
                              regencyError: _errors['regency'],
                              districtError: _errors['district'],
                              // villageError: _errors['village'],
                              // rtError: _errors['rt'],
                              // rwError: _errors['rw'],
                              postalCodeError: _errors['postalCode'],
                            ),
                          ),
                          // Shipping Address Section
                          Container(
                            key: _shippingAddressKey,
                            child: ShippingAddressSectionWidget(
                              formState: _formState,
                              errors: _errors,
                              onStateChanged: () => setState(() {}),
                            ),
                          ),
                          // Container(
                          //   key: _supportingDataKey,
                          //   child: SupportingDataSectionWidget(
                          //     formState: _formState,
                          //     contactPersonError: _errors['contactPerson'],
                          //     emailCompanyError: _errors['emailCompany'],
                          //     factoryAddressError: _errors['factoryAddress'],
                          //     faxError: _errors['fax'],
                          //   ),
                          // ),
                          // Container(
                          //   key: _documentsKey,
                          //   child: UploadDocumentsSectionWidget(
                          //     formState: _formState,
                          //     ktpFileError: _errors['ktpFile'],
                          //     npwpFileError: _errors['npwpFile'],
                          //     onStateChanged: () => setState(() {}),
                          //   ),
                          // ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryColor,
                                  foregroundColor:
                                      Colors.black, // warna teks/icon
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const CircularProgressIndicator()
                                    : const Text('Kirim Pengajuan'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
