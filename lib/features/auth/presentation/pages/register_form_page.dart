// lib/features/auth/presentation/pages/register_form_page.dart
// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/widgets/personal_info_section_widget.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/widgets/birth_info_section_widget.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/widgets/contact_info_section_widget.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/widgets/password_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RegisterFormPage extends StatefulWidget {
  final String phoneNumber;

  const RegisterFormPage({super.key, required this.phoneNumber});

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // phone controller dibuat di state
  late final TextEditingController _phoneController;

  // State
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isNavigating = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_updateFullNameSafe);
    _lastNameController.addListener(_updateFullNameSafe);

    _phoneController = TextEditingController(text: widget.phoneNumber);

    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (!mounted || _isDisposed) return;
    setState(() {});
  }

  // safe update full name (avoid writing to controller after dispose)
  void _updateFullNameSafe() {
    if (_isDisposed) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final combined = '$firstName $lastName'.trim();

    if (!mounted || _isDisposed) return;

    try {
      if (_fullNameController.text != combined) {
        _fullNameController.text = combined;
      }
    } catch (e) {
      debugPrint('⚠️ Could not update fullNameController: $e');
    }
  }

  // Helper: Capitalize each word (untuk save ke DB)
  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // Helper: Trim dan remove multiple spaces
  String _cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  void dispose() {
    _isDisposed = true;

    try {
      _firstNameController.removeListener(_updateFullNameSafe);
      _lastNameController.removeListener(_updateFullNameSafe);
      _passwordController.removeListener(_onPasswordChanged);
    } catch (_) {}

    try {
      _firstNameController.dispose();
      _lastNameController.dispose();
      _fullNameController.dispose();
      _usernameController.dispose();
      _emailController.dispose();
      _birthPlaceController.dispose();
      _birthDateController.dispose();
      _passwordController.dispose();
      _confirmPasswordController.dispose();
      _phoneController.dispose();
    } catch (_) {}

    super.dispose();
  }

  // Auto-copy JSON to clipboard (fire-and-forget ok)
  Future<void> _autoCopyJsonToClipboard() async { return; /*
    try {
      debugPrint('✅ JSON AUTO-COPIED TO CLIPBOARD!');
      debugPrint('📁 Also saved to: ${storageService.getAssetsFilePath()}');
    } catch (e) {
      debugPrint('⚠️ Could not copy to clipboard: $e');
    }
  */ }

  // Validators
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }

    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasDigit && !hasSpecialChar) {
      return 'Kata sandi harus mengandung minimal 1 angka atau simbol';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Kata sandi tidak sama';
    }
    return null;
  }

  // Date Picker
  Future<void> _selectBirthDate() async {
    final DateTime initial = _selectedDate ?? DateTime(2000);
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
                        if (!mounted || _isDisposed) return;
                        setState(() {
                          _selectedDate = tempPicked;
                          _birthDateController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(_selectedDate!);
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

  // Submit Form
  void _submitForm() {
    if (_formKey.currentState == null) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null) {
      AppSnackbar.showRaw(context, 
        const SnackBar(
          content: Text('Silakan pilih jenis kelamin'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
      return;
    }

    // Guard: set navigating immediately to prevent double taps
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    // Clean and capitalize data before saving
    final firstName = _capitalizeWords(_cleanText(_firstNameController.text));
    final lastName = _capitalizeWords(_cleanText(_lastNameController.text));
    final fullName = '$firstName $lastName'.trim();
    final birthPlace = _capitalizeWords(_cleanText(_birthPlaceController.text));
    final email = _cleanText(_emailController.text).toLowerCase();
    final username = _usernameController.text.trim().isEmpty
        ? null
        : _cleanText(_usernameController.text).toLowerCase();

    debugPrint('📝 Registering user...');
    debugPrint('Phone: ${widget.phoneNumber}');
    debugPrint('Full Name: $fullName');
    debugPrint('Email: $email');
    debugPrint('Gender: $_selectedGender');

    // Dispatch event (bloc will handle saving)
    context.read<AuthBloc>().add(
      RegisterUserEvent(
        phone: widget.phoneNumber,
        firstName: firstName,
        lastName: lastName,
        username: username ?? '',
        email: email,
        dateOfBirth: _selectedDate!,
        birthPlace: birthPlace,
        gender: _selectedGender!,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final primaryColor = AppColors.primaryColor;
    final yellowColor = const Color(0xFFFDD100);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: const CustomHeaderAppBar(
        title: 'Daftar',
        subtitle: 'Lengkapi Profil Anda',
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (!mounted || _isDisposed) return;

          if (state is RegisterSuccess) {
            debugPrint('✅ RegisterSuccess (listener)');
            // 1. Tutup keyboard/hapus fokus secara paksa sebelum navigasi
            FocusScope.of(context).unfocus();

            if (mounted && !_isDisposed) {
              AppSnackbar.showRaw(context, 
                const SnackBar(
                  content: Text('Registrasi berhasil — mengarahkan ke login'),
                  backgroundColor: Colors.green,
                  duration: Duration(milliseconds: 900),
                ),
              );
            }

            // 2. 🔥 PENTING: Reset state AuthBloc sebelum navigasi
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted || _isDisposed) return;

              // Reset state dulu
              context.read<AuthBloc>().add(ResetAuthEvent());

              // Kasih jeda kecil untuk state reset
              await Future.delayed(const Duration(milliseconds: 100));

              if (!mounted || _isDisposed) return;
              // Baru navigasi
              context.go('/login');
            });

            return;
          }

          if (state is RegisterError) {
            debugPrint('❌ Registration Error: ${state.message}');
            // Re-enable button so user can retry
            if (mounted && !_isDisposed) {
              setState(() => _isNavigating = false);
              AppSnackbar.showRaw(context, 
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primaryColor,
                ),
              );
            }
            return;
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // 1. Personal Info Section
                      PersonalInfoSectionWidget(
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        fullNameController: _fullNameController,
                        usernameController: _usernameController,
                        validateName: _validateName,
                      ),

                      // 2. Birth Info Section
                      BirthInfoSectionWidget(
                        birthPlaceController: _birthPlaceController,
                        birthDateController: _birthDateController,
                        selectedGender: _selectedGender,
                        onGenderChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        onSelectBirthDate: _selectBirthDate,
                        validateRequired: _validateRequired,
                      ),

                      // 3. Contact Info Section
                      ContactInfoSectionWidget(
                        emailController: _emailController,
                        phoneController: _phoneController,
                        validateEmail: _validateEmail,
                      ),

                      // 4. Password Section
                      PasswordSectionWidget(
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        obscurePassword: _obscurePassword,
                        obscureConfirmPassword: _obscureConfirmPassword,
                        onTogglePassword: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        onToggleConfirmPassword: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                        validatePassword: _validatePassword,
                        validateConfirmPassword: _validateConfirmPassword,
                      ),

                      const SizedBox(height: 16),
                      // Submit Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (isLoading || _isNavigating)
                                    ? null
                                    : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: yellowColor,
                                  foregroundColor: AppColors.blackColor,
                                  disabledBackgroundColor: Colors.grey[300],
                                  elevation: 0,
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
                                          color: AppColors.blackColor,
                                        ),
                                      )
                                    : const Text(
                                        'Simpan & Daftar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
