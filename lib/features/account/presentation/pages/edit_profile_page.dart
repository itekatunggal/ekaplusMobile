import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_logged_in_view.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/profile_picture_options.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 68,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Ubah Profil',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Bantuan',
            onPressed: () => AppSnackbar.show(
              context,
              message: 'Pilih data yang ingin diubah',
              type: AppSnackbarType.info,
            ),
            icon: const Icon(Icons.help_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, state) {
          if (state is AuthSessionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          if (state is! AuthSessionAuthenticated) {
            return _SignedOutState(onBack: () => context.goNamed('account'));
          }
          return _ProfileContent(user: state.user);
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [
                    AccountAvatar(
                      user: user,
                      size: 92,
                      showCamera: true,
                      onTap: () => _editPhoto(context),
                    ),
                    const SizedBox(height: 9),
                    TextButton(
                      onPressed: () => _editPhoto(context),
                      child: const Text(
                        'Ubah Foto Profil',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ProfileSection(
                      title: 'Informasi Akun Personal',
                      children: [
                        _ProfileDataRow(
                          label: 'Nama Lengkap',
                          value: user.fullName,
                          onTap: () => context.pushNamed(
                            'edit-name',
                            extra: {
                              'userId': user.phone,
                              'currentName': user.fullName,
                            },
                          ),
                        ),
                        _ProfileDataRow(
                          label: 'Gender',
                          value: _genderLabel(user.gender),
                          onTap: () => _editPersonalData(context),
                        ),
                        _ProfileDataRow(
                          label: 'Tempat Lahir',
                          value: user.placeOfBirth.trim().isEmpty
                              ? 'Belum diisi'
                              : user.placeOfBirth,
                          onTap: () => _editPersonalData(context),
                        ),
                        _ProfileDataRow(
                          label: 'Tanggal Lahir',
                          value: _formatDate(user.dateOfBirth),
                          onTap: () => _editPersonalData(context),
                        ),
                        // _ProfileDataRow(
                        //   label: 'Role',
                        //   value: _roleLabel(user.role),
                        // ),
                        _ProfileDataRow(
                          label: 'Nomor Handphone',
                          value: user.phone,
                          verified: user.isPhoneVerified,
                          onTap: () => _changeContact(context, type: 'phone'),
                        ),
                        _ProfileDataRow(
                          label: 'Email',
                          value: user.email,
                          verified: user.isEmailVerified,
                          onTap: () => _changeContact(context, type: 'email'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ProfileSection(
                      title: 'Pengaturan Akun & Keamanan',
                      children: [
                        _SecurityRow(
                          icon: Icons.alternate_email_rounded,
                          iconColor: const Color(0xFF2563EB),
                          iconBackground: const Color(0xFFEFF6FF),
                          title: 'Username',
                          subtitle: user.username.trim().isEmpty
                              ? 'Belum diatur'
                              : '@${user.username}',
                          actionLabel: 'Ubah',
                          onTap: () => context.pushNamed(
                            'edit-username',
                            extra: {
                              'userId': user.phone,
                              'currentUsername': user.username,
                            },
                          ),
                        ),
                        _SecurityRow(
                          icon: Icons.lock_outline_rounded,
                          iconColor: const Color(0xFFD97706),
                          iconBackground: const Color(0xFFFFFBEB),
                          title: 'Ganti Kata Sandi',
                          subtitle: 'Perbarui keamanan akun Anda',
                          onTap: () => _changePassword(context),
                        ),
                        _SecurityRow(
                          icon: Icons.verified_user_outlined,
                          iconColor: const Color(0xFF7C3AED),
                          iconBackground: const Color(0xFFF5F3FF),
                          title: 'PIN Transaksi',
                          subtitle: 'Keamanan pembayaran & persetujuan',
                          badge: 'Segera',
                          onTap: () => AppSnackbar.show(
                            context,
                            message: 'PIN transaksi akan segera tersedia',
                            type: AppSnackbarType.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pastikan data profil Anda selalu valid untuk mempermudah proses verifikasi dan transaksi Ekatunggal.',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text(
                      'Selesai',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _editPhoto(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ProfilePictureOptionsSheet(
        user: user,
        onDismiss: () => Navigator.pop(sheetContext),
      ),
    );
  }

  void _editPersonalData(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileUpdateCubit>(),
        child: _EditPersonalDataSheet(user: user),
      ),
    );
  }

  String _genderLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'male':
      case 'laki-laki':
        return 'Laki-laki';
      case 'female':
      case 'perempuan':
        return 'Perempuan';
      default:
        return value.trim().isEmpty ? 'Belum diisi' : value;
    }
  }

  String _roleLabel(String value) {
    if (value.trim().isEmpty) return '-';
    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Belum diisi';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final local = value.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  void _changeContact(BuildContext context, {required String type}) {
    final isPhone = type == 'phone';
    if ((user.password ?? '').isNotEmpty) {
      context.pushNamed(
        'verify-password',
        extra: {
          'userId': user.phone,
          'title': isPhone ? 'Ubah Nomor Handphone' : 'Ubah Email',
          'subtitle': 'Masukkan password untuk verifikasi',
          'nextRoute': 'edit-contact',
          'nextRouteExtra': isPhone
              ? {'currentPhone': user.phone, 'type': 'phone'}
              : {'currentEmail': user.email, 'type': 'email'},
        },
      );
      return;
    }
    context.pushNamed(
      'edit-contact',
      extra: isPhone
          ? {'userId': user.phone, 'currentPhone': user.phone, 'type': 'phone'}
          : {'userId': user.phone, 'currentEmail': user.email, 'type': 'email'},
    );
  }

  void _changePassword(BuildContext context) {
    if ((user.password ?? '').isNotEmpty) {
      context.pushNamed(
        'verify-password',
        extra: {
          'userId': user.phone,
          'title': 'Ganti Kata Sandi',
          'subtitle': 'Masukkan password lama untuk verifikasi',
          'nextRoute': 'change-password',
        },
      );
      return;
    }
    context.pushNamed('change-password', extra: {'verifyOldPassword': 'old'});
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: accountCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .45,
                ),
              ),
            ),
          ),
          ...List.generate(
            children.length,
            (index) => Column(
              children: [
                children[index],
                if (index != children.length - 1)
                  const Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: Color(0xFFF1F5F9),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDataRow extends StatelessWidget {
  const _ProfileDataRow({
    required this.label,
    required this.value,
    this.onTap,
    this.verified = false,
  });
  final String label;
  final String value;
  final bool verified;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                ),
                if (verified) const AccountStatusBadge(label: 'Terverifikasi'),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.isEmpty ? '-' : value,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (onTap != null)
                    const Text(
                      'Ubah',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.actionLabel,
    this.badge,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFECACA)),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (badge != null) ...[
              AccountStatusBadge(label: badge!),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: Color(0xFFCBD5E1),
              ),
            ] else
              const Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: Color(0xFFCBD5E1),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditPersonalDataSheet extends StatefulWidget {
  const _EditPersonalDataSheet({required this.user});
  final User user;

  @override
  State<_EditPersonalDataSheet> createState() => _EditPersonalDataSheetState();
}

class _EditPersonalDataSheetState extends State<_EditPersonalDataSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _birthPlaceController;
  late String _gender;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _birthPlaceController = TextEditingController(
      text: widget.user.placeOfBirth,
    );
    final gender = widget.user.gender.trim().toLowerCase();
    _gender = gender == 'female' || gender == 'perempuan' ? 'female' : 'male';
    _birthDate = widget.user.dateOfBirth;
    context.read<ProfileUpdateCubit>().reset();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileUpdateCubit, ProfileUpdateState>(
      listener: (context, state) async {
        if (state is ProfileUpdateSuccess) {
          await context.read<AuthSessionCubit>().updateUser(state.user);
          if (!context.mounted) return;
          AppSnackbar.show(
            context,
            message: state.message,
            type: AppSnackbarType.success,
          );
          Navigator.pop(context);
        } else if (state is ProfileUpdateError) {
          AppSnackbar.show(
            context,
            message: state.message,
            type: AppSnackbarType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileUpdateLoading;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Ubah Data Pribadi',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Perubahan akan disimpan ke data akun Anda.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration('Nama Lengkap'),
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Nama lengkap wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: _inputDecoration('Gender'),
                      items: const [
                        DropdownMenuItem(
                          value: 'male',
                          child: Text('Laki-laki'),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Perempuan'),
                        ),
                      ],
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _gender = value);
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _birthPlaceController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration('Tempat Lahir'),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isLoading ? null : _selectBirthDate,
                      child: InputDecorator(
                        decoration: _inputDecoration('Tanggal Lahir'),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _birthDate == null
                                    ? 'Pilih tanggal lahir'
                                    : _numericDate(_birthDate!),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _birthDate == null
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 19,
                              color: Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : _save,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate?.toLocal() ?? DateTime(now.year - 18);
    final selected = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Pilih tanggal lahir',
    );
    if (selected == null || !mounted) return;
    setState(() {
      _birthDate = DateTime.utc(selected.year, selected.month, selected.day);
    });
  }

  String _numericDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileUpdateCubit>().updatePersonalData(
      fullName: _nameController.text.trim(),
      gender: _gender,
      placeOfBirth: _birthPlaceController.text.trim(),
      dateOfBirth: _birthDate,
    );
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 52,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 14),
            const Text(
              'Sesi akun sudah berakhir',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onBack,
              child: const Text('Kembali ke Akun'),
            ),
          ],
        ),
      ),
    );
  }
}
