// lib/features/account/presentation/pages/edit_contact_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum ContactType { phone, email }

class EditContactPage extends StatefulWidget {
  final String userId;
  final String currentValue;
  // final String verifiedPassword;
  final ContactType type;

  const EditContactPage({
    super.key,
    required this.userId,
    required this.currentValue,
    // required this.verifiedPassword,
    required this.type,
  });

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  late TextEditingController _valueController;
  late TextEditingController _confirmValueController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController();
    _confirmValueController = TextEditingController();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _confirmValueController.dispose();
    super.dispose();
  }

  bool get isPhone => widget.type == ContactType.phone;

  String get title => isPhone ? 'Ubah Nomor Handphone' : 'Ubah Email';
  String get fieldLabel => isPhone ? 'Nomor Handphone Baru' : 'Email Baru';
  String get confirmLabel =>
      isPhone ? 'Konfirmasi Nomor Handphone' : 'Konfirmasi Email';
  String get currentLabel => isPhone ? 'Nomor saat ini:' : 'Email saat ini:';
  String get hintText =>
      isPhone ? 'Contoh: 081234567890' : 'Contoh: user@example.com';
  String get confirmHintText =>
      isPhone ? 'Konfirmasi nomor handphone baru' : 'Konfirmasi email baru';
  String get otpInfoText => isPhone
      ? 'Kode OTP akan dikirim ke nomor baru'
      : 'Kode verifikasi akan dikirim ke email baru';
  String get buttonText => isPhone ? 'Kirim Kode OTP' : 'Kirim Kode Verifikasi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(title: title, onLeadingPressed: () => context.pop()),
      body: BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
        listener: (context, state) {
          if (state is ProfileUpdateAwaitingVerification) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );

            final cubit = context.read<ProfileUpdateCubit>();
            final newValue = isPhone ? state.pendingPhone : state.pendingEmail;

            context.pushNamed(
              'otp-verification',
              extra: {
                'phoneNumber': newValue ?? '',
                'title': isPhone
                    ? 'Verifikasi Nomor Handphone'
                    : 'Verifikasi Email',
                'subtitle': isPhone
                    ? 'Masukkan kode OTP yang dikirim ke nomor baru'
                    : 'Masukkan kode verifikasi yang dikirim ke email baru',
                'nextRoute': 'verify-contact-complete',
                'isPasswordReset': false,
                'cubit': cubit,
                'userId': widget.userId,
                'contactType': widget.type,
                // 'password': widget.verifiedPassword,
              },
            );
          } else if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Value Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLabel,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: AppColors.grayColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.currentValue,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // New Value
                Text(
                  fieldLabel,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _valueController,
                  keyboardType: isPhone
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${isPhone ? 'Nomor handphone' : 'Email'} tidak boleh kosong';
                    }

                    if (isPhone) {
                      if (!RegExp(r'^[0-9+]+$').hasMatch(value)) {
                        return 'Nomor handphone tidak valid';
                      }

                      // Normalize for comparison
                      String normalizedNew = value.replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      );
                      if (normalizedNew.startsWith('0')) {
                        normalizedNew = '62${normalizedNew.substring(1)}';
                      }

                      String normalizedCurrent = widget.currentValue.replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      );
                      if (normalizedCurrent.startsWith('0')) {
                        normalizedCurrent =
                            '62${normalizedCurrent.substring(1)}';
                      }

                      if (normalizedNew == normalizedCurrent) {
                        return 'Nomor baru sama dengan nomor lama';
                      }
                    } else {
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      if (value.toLowerCase() ==
                          widget.currentValue.toLowerCase()) {
                        return 'Email baru sama dengan email lama';
                      }
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Value
                Text(
                  confirmLabel,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmValueController,
                  keyboardType: isPhone
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: confirmHintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi ${isPhone ? 'nomor' : 'email'} tidak boleh kosong';
                    }

                    final compareValue = isPhone ? value : value.toLowerCase();
                    final originalValue = isPhone
                        ? _valueController.text
                        : _valueController.text.toLowerCase();

                    if (compareValue != originalValue) {
                      return '${isPhone ? 'Nomor' : 'Email'} tidak cocok';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),
                Text(
                  otpInfoText,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 12,
                    color: AppColors.grayColor,
                  ),
                ),
                const SizedBox(height: 24),

                BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileUpdateLoading;

                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: AppColors.primaryColor
                            .withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              buttonText,
                              style: TextStyle(
                                fontFamily: AppFonts.primaryFont,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (isPhone) {
        // Normalize phone number
        String newPhone = _valueController.text.trim().replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        if (newPhone.startsWith('0')) {
          newPhone = '62${newPhone.substring(1)}';
        }

        context.read<ProfileUpdateCubit>().requestPhoneUpdate(
          userId: widget.userId,
          newPhone: newPhone,
          password: "widget.verifiedPassword",
        );
      } else {
        context.read<ProfileUpdateCubit>().requestEmailUpdate(
          userId: widget.userId,
          newEmail: _valueController.text.trim().toLowerCase(),
          password: "widget.verifiedPassword",
        );
      }
    }
  }
}
