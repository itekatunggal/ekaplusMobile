// lib/features/member/presentation/pages/member_registration_page.dart

import 'dart:io';

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection.dart' as di;
import '../../../auth/presentation/cubit/auth_session_cubit.dart';
import '../cubit/member_registration_cubit.dart';
import '../utils/member_registration_form_state.dart';
import '../widgets/identity_section_widget.dart';
import '../widgets/company_info_section_widget.dart';
import '../widgets/address_section_widget.dart';
import '../widgets/supporting_data_section_widget.dart';
import '../widgets/upload_documents_section_widget.dart';
import '../widgets/member_confirmation_dialog.dart';
import '../../domain/usecases/get_member_registrations_by_user_id.dart';
import '../../domain/entities/member_registration.dart';

class MemberRegistrationPage extends StatefulWidget {
  const MemberRegistrationPage({super.key});

  @override
  State<MemberRegistrationPage> createState() => _MemberRegistrationPageState();
}

class _MemberRegistrationPageState extends State<MemberRegistrationPage> {
  late MemberRegistrationFormState _formState;
  late MemberRegistrationCubit _memberCubit;

  Map<String, String?> _errors = {};
  bool _isSubmitting = false;

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _companyInfoKey = GlobalKey();
  final GlobalKey _addressKey = GlobalKey();
  final GlobalKey _supportingDataKey = GlobalKey();
  final GlobalKey _documentsKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _memberCubit = di.myinjection<MemberRegistrationCubit>();

    final authState = context.read<AuthSessionCubit>().state;

    String userName = '';
    String userEmail = '';
    String userPhone = '';
    String userBirthPlace = '';
    String userDateOfBirth = '';
    int userId = 0;

    if (authState is AuthSessionAuthenticated) {
      userName = authState.user.fullName;
      userPhone = authState.user.phone;
      userEmail = authState.user.email;
      userId = authState.user.id;
    }

    _formState = MemberRegistrationFormState.fromUserData(
      nama: userName,
      phone: userPhone,
      email: userEmail,
      birthPlace: userBirthPlace,
      dateOfBirth: userDateOfBirth,
    );

    _checkExistingRegistration(userId);
  }

  Future<void> _checkExistingRegistration(int userId) async {
    if (userId == 0) return;

    final usecase = di.myinjection<GetMemberRegistrationsByUserId>();

    final result = await usecase.execute();

    result.fold((_) {}, (registrations) {
      if (registrations.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAlreadyRegisteredDialog(registrations.last);
        });
      }
    });
  }

  void _showAlreadyRegisteredDialog(MemberRegistration registration) {
    final status = registration.status;

    String message;
    int initialTabIndex;

    if (status == 'approved') {
      message = 'Anda sudah terdaftar sebagai member dan telah disetujui.';
      initialTabIndex = 1;
    } else {
      message = 'Anda sudah memiliki pengajuan member yang sedang diproses.';
      initialTabIndex = 0;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Informasi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.goNamed(
                'memberList',
                extra: {'initialTabIndex': initialTabIndex},
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
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

  Future<void> _handleSubmit() async {
    final errors = _formState.validate();

    if (errors.isNotEmpty) {
      setState(() => _errors = errors);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon lengkapi semua field (${errors.length} error)'),
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

    final formData = _formState.toJson();

    await _showConfirmationDialog(formData, files);
  }

  void _scrollToFirstError(Map<String, String?> errors) {
    GlobalKey? target;

    if (errors.containsKey('companyType') || errors.containsKey('nik')) {
      target = _companyInfoKey;
    } else if (errors.containsKey('address')) {
      target = _addressKey;
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

  Future<void> _showConfirmationDialog(
    Map<String, dynamic> formData,
    Map<String, File> files,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MemberConfirmationDialog(
        formData: formData,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pengajuan berhasil dikirim'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.of(context).pop();
            context.pushReplacementNamed('memberList');
          }

          if (state is MemberRegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: const CustomHeaderAppBar(
              title: 'Hubungkan Usaha',
              subtitle: 'Lengkapi Profil Anda',
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        IdentitySectionWidget(formState: _formState),
                        Container(
                          key: _companyInfoKey,
                          child: CompanyInfoSectionWidget(
                            formState: _formState,
                            onCompanyTypeChanged: _onCompanyTypeChanged,
                            onBranchChanged: _onBranchChanged,
                            companyTypeError: _errors['companyType'],
                            companyNameError: _errors['companyName'],
                            nikError: _errors['nik'],
                            npwpError: _errors['npwp'],
                            branchError: _errors['branch'],
                          ),
                        ),
                        Container(
                          key: _addressKey,
                          child: AddressSectionWidget(
                            formState: _formState,
                            addressError: _errors['address'],
                            provinceError: _errors['province'],
                            regencyError: _errors['regency'],
                            districtError: _errors['district'],
                            villageError: _errors['village'],
                            rtError: _errors['rt'],
                            rwError: _errors['rw'],
                            postalCodeError: _errors['postalCode'],
                          ),
                        ),
                        Container(
                          key: _supportingDataKey,
                          child: SupportingDataSectionWidget(
                            formState: _formState,
                            contactPersonError: _errors['contactPerson'],
                            emailCompanyError: _errors['emailCompany'],
                            factoryAddressError: _errors['factoryAddress'],
                            faxError: _errors['fax'],
                          ),
                        ),
                        Container(
                          key: _documentsKey,
                          child: UploadDocumentsSectionWidget(
                            formState: _formState,
                            ktpFileError: _errors['ktpFile'],
                            npwpFileError: _errors['npwpFile'],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryColor,
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
          );
        },
      ),
    );
  }
}
