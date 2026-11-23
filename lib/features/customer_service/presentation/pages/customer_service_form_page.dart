import 'dart:typed_data';

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum CustomerServiceFormType { feedback, complaint }

class CustomerServiceFormPage extends StatefulWidget {
  const CustomerServiceFormPage({super.key, required this.type});

  final CustomerServiceFormType type;

  @override
  State<CustomerServiceFormPage> createState() =>
      _CustomerServiceFormPageState();
}

class _CustomerServiceFormPageState extends State<CustomerServiceFormPage> {
  static const _inputTextStyle = TextStyle(
    fontFamily: AppFonts.primaryFont,
    color: Color(0xFF1E293B),
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedCategory;
  XFile? _attachment;
  Uint8List? _attachmentBytes;
  bool _isPickingAttachment = false;

  bool get _isFeedback => widget.type == CustomerServiceFormType.feedback;

  List<String> get _categories => _isFeedback
      ? const ['Pelayanan', 'Produk', 'Aplikasi EKA+', 'Fitur Baru', 'Lainnya']
      : const [
          'Aplikasi EKA+',
          'Pesanan',
          'Tagihan atau Pembayaran',
          'Pengiriman',
          'Produk',
          'Lainnya',
        ];

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Payload ini siap diteruskan ke service API Ekaplus setelah endpoint tersedia.
    // final payload = {
    //   'name': _nameController.text.trim(),
    //   'type': _selectedCategory,
    //   'message': _messageController.text.trim(),
    //   'attachment_name': _attachment?.name,
    //   'attachment_bytes': _attachmentBytes,
    // };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _isFeedback
                ? 'Form masukan sudah siap. Pengiriman akan aktif setelah API tersedia.'
                : 'Form kendala sudah siap. Pengiriman akan aktif setelah API tersedia.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _pickAttachment() async {
    if (_isPickingAttachment) return;
    setState(() => _isPickingAttachment = true);

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null) return;

      final length = await image.length();
      const maxBytes = 5 * 1024 * 1024;
      if (length > maxBytes) {
        if (!mounted) return;
        AppSnackbar.show(
          context,
          message: 'Ukuran gambar maksimal 5 MB',
          type: AppSnackbarType.warning,
        );
        return;
      }

      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _attachment = image;
        _attachmentBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: 'Gambar tidak dapat dipilih. Silakan coba lagi.',
        type: AppSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isPickingAttachment = false);
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachment = null;
      _attachmentBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isFeedback ? 'BERI MASUKAN' : 'LAPORKAN KENDALA';
    final detailLabel = _isFeedback ? 'Masukan Anda' : 'Kendala Anda';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 52,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
            size: 22,
          ),
        ),
        titleSpacing: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Image.asset(
              'assets/icons/icon_app.png',
              width: 34,
              height: 34,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
            children: [
              _FormIntro(isFeedback: _isFeedback),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0E4E7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Nama'),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _nameController,
                      style: _inputTextStyle,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        hintText: 'Masukkan nama Anda',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) return 'Nama wajib diisi';
                        if (name.length < 2) return 'Nama terlalu singkat';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(
                      _isFeedback ? 'Jenis Masukan' : 'Jenis Kendala',
                    ),
                    const SizedBox(height: 7),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      isExpanded: true,
                      style: _inputTextStyle,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      menuMaxHeight: 280,
                      itemHeight: 48,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      decoration: _inputDecoration(
                        hintText: _isFeedback
                            ? 'Pilih jenis masukan'
                            : 'Pilih jenis kendala',
                        prefixIcon: _isFeedback
                            ? Icons.rate_review_outlined
                            : Icons.report_problem_outlined,
                      ),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _inputTextStyle,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                      validator: (value) => value == null
                          ? (_isFeedback
                                ? 'Pilih jenis masukan'
                                : 'Pilih jenis kendala')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(detailLabel),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _messageController,
                      style: _inputTextStyle,
                      minLines: 5,
                      maxLines: 7,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        hintText: _isFeedback
                            ? 'Tulis masukan atau saran Anda di sini'
                            : 'Ceritakan kendala yang Anda alami',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        final message = value?.trim() ?? '';
                        if (message.isEmpty) {
                          return _isFeedback
                              ? 'Masukan wajib diisi'
                              : 'Kendala wajib diisi';
                        }
                        if (message.length < 10) {
                          return 'Tuliskan minimal 10 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Lampiran Gambar', isRequired: false),
                    const SizedBox(height: 7),
                    _AttachmentField(
                      image: _attachmentBytes,
                      fileName: _attachment?.name,
                      isLoading: _isPickingAttachment,
                      onPick: _pickAttachment,
                      onRemove: _removeAttachment,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          _isFeedback ? 'KIRIM MASUKAN' : 'KIRIM LAPORAN',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? prefixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      alignLabelWithHint: alignLabelWithHint,
      hintStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        color: Color(0xFF94A3B8),
        fontSize: 11,
        height: 1.35,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 10,
        height: 1.25,
        fontWeight: FontWeight.w400,
      ),
      counterStyle: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        color: Color(0xFF94A3B8),
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, color: AppColors.primaryColor, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: _fieldBorder(const Color(0xFFE2E8F0)),
      enabledBorder: _fieldBorder(const Color(0xFFE2E8F0)),
      focusedBorder: _fieldBorder(AppColors.primaryColor, width: 1.4),
      errorBorder: _fieldBorder(const Color(0xFFDC2626)),
      focusedErrorBorder: _fieldBorder(const Color(0xFFDC2626), width: 1.4),
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _FormIntro extends StatelessWidget {
  const _FormIntro({required this.isFeedback});

  final bool isFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEFF2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFeedback
                  ? Icons.rate_review_outlined
                  : Icons.report_problem_outlined,
              color: AppColors.primaryColor,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isFeedback
                  ? 'Masukan Anda membantu kami meningkatkan kualitas layanan Ekatunggal.'
                  : 'Sampaikan kendala secara jelas agar dapat kami tindak lanjuti dengan tepat.',
              style: const TextStyle(
                color: Color(0xFF7F1D2D),
                fontSize: 11,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.isRequired = true});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        isRequired ? '$text *' : text,
        style: const TextStyle(
          fontFamily: AppFonts.primaryFont,
          color: Color(0xFF334155),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      if (!isRequired) ...[
        const SizedBox(width: 6),
        const Text(
          '(Opsional)',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ],
  );
}

class _AttachmentField extends StatelessWidget {
  const _AttachmentField({
    required this.image,
    required this.fileName,
    required this.isLoading,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? image;
  final String? fileName;
  final bool isLoading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Material(
        color: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: InkWell(
          onTap: isLoading ? null : onPick,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        )
                      : const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.primaryColor,
                          size: 22,
                        ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih gambar dari galeri',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          color: Color(0xFF1E293B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'JPG atau PNG, maksimal 5 MB',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          color: Color(0xFF94A3B8),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.memory(
              image!,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName ?? 'Lampiran gambar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    color: Color(0xFF1E293B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                InkWell(
                  onTap: isLoading ? null : onPick,
                  borderRadius: BorderRadius.circular(7),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                    child: Text(
                      'Ganti gambar',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: AppColors.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hapus lampiran',
            onPressed: isLoading ? null : onRemove,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.primaryColor,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}
