// lib/features/member/presentation/widgets/upload_documents_section_widget.dart

// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/member_registration_form_state.dart';

/// Widget untuk section upload dokumen
class UploadDocumentsSectionWidget extends StatefulWidget {
  final MemberRegistrationFormState formState;
  final String? ktpFileError;
  final String? npwpFileError;
  final VoidCallback? onStateChanged;
  // final String? companyDocFileError;

  const UploadDocumentsSectionWidget({
    super.key,
    required this.formState,
    this.ktpFileError,
    this.npwpFileError,
    this.onStateChanged,
    // this.companyDocFileError,
  });

  @override
  State<UploadDocumentsSectionWidget> createState() =>
      _UploadDocumentsSectionWidgetState();
}

class _UploadDocumentsSectionWidgetState
    extends State<UploadDocumentsSectionWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage({
    required String type,
    required ImageSource source,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        setState(() {
          if (type == 'ktp') {
            widget.formState.ktpFile = file;
          } else if (type == 'npwp') {
            widget.formState.npwpFile = file;
            // } else if (type == 'companyDoc') {
            //   widget.formState.companyDocFilePath = image.path;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog({required String type, required String title}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(type: type, source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(type: type, source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(String type) {
    setState(() {
      if (type == 'ktp') {
        widget.formState.ktpFile = null;
      } else if (type == 'npwp') {
        widget.formState.npwpFile = null;
        // } else if (type == 'companyDoc') {
        //   widget.formState.companyDocFilePath = null;
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
              'Status Pajak',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            // PKP Checkbox
            Container(
              decoration: BoxDecoration(
                color: widget.formState.isPKP
                    ? AppColors.primaryColor.withValues(alpha: 0.05)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.formState.isPKP
                      ? AppColors.primaryColor.withValues(alpha: 0.3)
                      : Colors.grey[300]!,
                ),
              ),
              child: CheckboxListTile(
                value: widget.formState.isPKP,
                onChanged: (value) {
                  setState(() {
                    widget.formState.isPKP = value ?? false;
                    // Clear NPWP file if PKP is unchecked
                    if (!widget.formState.isPKP) {
                      widget.formState.npwpFile = null;
                    }
                  });
                  widget.onStateChanged?.call();
                },
                title: const Text(
                  'Pengusaha Kena Pajak (PKP)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Centang jika Anda terdaftar sebagai PKP',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                activeColor: AppColors.primaryColor,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
              ),
            ),

            // Show NPWP upload only if PKP is checked
            if (widget.formState.isPKP) ...[
              const SizedBox(height: 16),

              // Upload NPWP
              _buildUploadField(
                title: 'Foto NPWP',
                description: 'Upload foto NPWP untuk verifikasi status PKP',
                icon: Icons.assignment_outlined,
                filePath: widget.formState.npwpFile?.path,
                errorText: widget.npwpFileError,
                onUploadPressed: () =>
                    _showImageSourceDialog(type: 'npwp', title: 'NPWP'),
                onRemovePressed: () => _removeImage('npwp'),
              ),
              const SizedBox(height: 16),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.teal[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Persyaratan Upload:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Format: JPG, PNG\n• Ukuran maksimal: 5 MB\n• Pastikan foto jelas dan dapat dibaca',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.teal[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadField({
    required String title,
    required String description,
    required IconData icon,
    required String? filePath,
    String? errorText,
    required VoidCallback onUploadPressed,
    required VoidCallback onRemovePressed,
  }) {
    final bool hasFile = filePath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (hasFile) ...[
                // Preview Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: Image.file(
                    File(filePath),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const Divider(height: 1),
              ],
              // Upload/Remove Button
              InkWell(
                onTap: hasFile ? onRemovePressed : onUploadPressed,
                borderRadius: BorderRadius.vertical(
                  bottom: const Radius.circular(8),
                  top: hasFile ? Radius.zero : const Radius.circular(8),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasFile ? Icons.delete_outline : Icons.upload_outlined,
                        color: hasFile ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasFile ? 'Hapus Gambar' : 'Upload Gambar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: hasFile ? Colors.red : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
