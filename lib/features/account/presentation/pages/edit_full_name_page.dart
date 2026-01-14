// lib/features/account/presentation/pages/edit_full_name_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditFullNamePage extends StatefulWidget {
  final String userId;
  final String currentName;

  const EditFullNamePage({
    super.key,
    required this.userId,
    required this.currentName,
  });

  @override
  State<EditFullNamePage> createState() => _EditFullNamePageState();
}

class _EditFullNamePageState extends State<EditFullNamePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Split current name into first and last name
    final nameParts = widget.currentName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        title: 'Ubah Nama',
        onLeadingPressed: () => context.pop(),
      ),
      resizeToAvoidBottomInset: true,
      body: BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            // Update auth session with new user data
            context.read<AuthSessionCubit>().updateUser(state.user);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
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
                        // Info text
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Nama akan ditampilkan sebagai: Nama Depan + Nama Belakang',
                                  style: TextStyle(
                                    fontFamily: AppFonts.primaryFont,
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // First Name
                        Text(
                          'Nama Depan',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, size: 20),
                            hintText: 'Contoh: John',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.blackColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama depan tidak boleh kosong';
                            }
                            if (value.trim().length < 2) {
                              return 'Nama depan minimal 2 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Last Name
                        Text(
                          'Nama Belakang',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, size: 20),
                            hintText: 'Contoh: Doe (opsional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.blackColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            // Last name is optional, but if filled, must be at least 2 chars
                            if (value != null && value.trim().isNotEmpty) {
                              if (value.trim().length < 2) {
                                return 'Nama belakang minimal 2 karakter';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Nama belakang bersifat opsional',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 12,
                            color: AppColors.grayColor,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Preview
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama Lengkap:',
                                style: TextStyle(
                                  fontFamily: AppFonts.primaryFont,
                                  fontSize: 12,
                                  color: AppColors.grayColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _firstNameController,
                                builder: (context, firstValue, child) {
                                  return ValueListenableBuilder<
                                    TextEditingValue
                                  >(
                                    valueListenable: _lastNameController,
                                    builder: (context, lastValue, child) {
                                      final firstName = _firstNameController
                                          .text
                                          .trim();
                                      final lastName = _lastNameController.text
                                          .trim();
                                      final fullName = lastName.isEmpty
                                          ? firstName
                                          : '$firstName $lastName';

                                      return Text(
                                        fullName.isEmpty ? '-' : fullName,
                                        style: TextStyle(
                                          fontFamily: AppFonts.primaryFont,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Button di luar scroll view, akan tetap fixed di bawah
              Container(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileUpdateLoading;

                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSave,
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
                                'Simpan',
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
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = lastName.isEmpty ? firstName : '$firstName $lastName';

      // Check if name changed
      if (fullName != widget.currentName) {
        context.read<ProfileUpdateCubit>().updateName(
          userId: widget.userId,
          fullName: fullName,
        );
      } else {
        context.pop();
      }
    }
  }
}
