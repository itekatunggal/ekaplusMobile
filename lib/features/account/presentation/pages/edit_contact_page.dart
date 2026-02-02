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
      isPhone ? 'Contoh:  08123456789' : 'Contoh: user@example.com';
  String get confirmHintText =>
      isPhone ? 'Konfirmasi nomor handphone baru' : 'Konfirmasi email baru';
  String get otpInfoText => isPhone
      ? 'Kode OTP akan dikirim ke nomor baru'
      : 'Kode verifikasi akan dikirim ke email baru';
  String get buttonText => isPhone ? 'Kirim Kode OTP' : 'Kirim Kode Verifikasi';

  /// Helper untuk normalize phone number
  /// Menghapus semua karakter non-digit (+, -, spasi, dll)
  String _normalizePhone(String phone) {
    return phone.trim().replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Helper untuk convert phone ke format 62xxx
  String _toInternationalFormat(String phone) {
    String normalized = _normalizePhone(phone);

    if (normalized.startsWith('0')) {
      return '62${normalized.substring(1)}';
    } else if (normalized.startsWith('62')) {
      return normalized;
    }

    return normalized;
  }

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
        child: Column(
          children: [
            Expanded(
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
                            // Normalize dulu (hapus +, -, spasi, dll)
                            String normalized = _normalizePhone(value);

                            // Validasi panjang setelah dinormalisasi
                            if (normalized.length < 10 ||
                                normalized.length > 15) {
                              return 'Nomor handphone tidak valid (10-15 digit)';
                            }

                            // Validasi hanya berisi angka setelah normalisasi
                            if (!RegExp(r'^[0-9]+$').hasMatch(normalized)) {
                              return 'Nomor handphone hanya boleh berisi angka';
                            }

                            // Convert ke format international untuk comparison
                            String internationalFormat = _toInternationalFormat(
                              value,
                            );
                            String currentInternationalFormat =
                                _toInternationalFormat(widget.currentValue);

                            if (internationalFormat ==
                                currentInternationalFormat) {
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

                          if (isPhone) {
                            // Normalize kedua nomor dan convert ke international format
                            String confirmedInternational =
                                _toInternationalFormat(value);
                            String originalInternational =
                                _toInternationalFormat(_valueController.text);

                            if (confirmedInternational !=
                                originalInternational) {
                              return 'Nomor tidak cocok';
                            }
                          } else {
                            final compareValue = value.toLowerCase();
                            final originalValue = _valueController.text
                                .toLowerCase();

                            if (compareValue != originalValue) {
                              return 'Email tidak cocok';
                            }
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
                    ],
                  ),
                ),
              ),
            ),

            // Button di bawah (sticky)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileUpdateLoading;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.secondaryColor,
                          disabledBackgroundColor: AppColors.secondaryColor
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
                                  color: AppColors.blackColor,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (isPhone) {
        // Normalize phone number (hapus semua non-digit)
        String newPhone = _normalizePhone(_valueController.text);

        // Convert ke format international
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
