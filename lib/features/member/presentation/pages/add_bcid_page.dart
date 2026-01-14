// lib/features/member/presentation/pages/add_bcid_page.dart

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../constant.dart';
import '../../../../core/shared_widgets/custom_header.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/cubit/auth_session_cubit.dart';
import '../../../auth/presentation/cubit/auth_session_state.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/province_model.dart';
import '../../data/models/regency_model.dart';
import '../../data/models/district_model.dart';
import '../../data/models/village_model.dart';
import '../../data/services/member_storage_service.dart';
import '../cubit/member_registration_cubit.dart';

class AddBCIDPage extends StatefulWidget {
  const AddBCIDPage({super.key});

  @override
  State<AddBCIDPage> createState() => _AddBCIDPageState();
}

class _AddBCIDPageState extends State<AddBCIDPage> {
  final _formKey = GlobalKey<FormState>();
  final MemberStorageService _storageService =
      myinjection<MemberStorageService>();
  late MemberRegistrationCubit _memberCubit;

  // User data
  int _userId = 0;
  String _userEmail = '';

  // Dropdown data
  List<Map<String, dynamic>> _approvedGCIDs = [];
  Map<String, dynamic>? _selectedGCID;

  // Branch data
  List<BranchModel> _branches = [];
  BranchModel? _selectedBranch;

  // Address data (cascading)
  List<ProvinceModel> _provinces = [];
  ProvinceModel? _selectedProvince;
  List<RegencyModel> _regencies = [];
  RegencyModel? _selectedRegency;
  List<DistrictModel> _districts = [];
  DistrictModel? _selectedDistrict;
  List<VillageModel> _villages = [];
  VillageModel? _selectedVillage;

  // Form controllers - Only editable fields for BCID
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  // Supporting data (optional)
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _emailCompanyController = TextEditingController();
  final TextEditingController _faxController = TextEditingController();
  final TextEditingController _factoryAddressController =
      TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _memberCubit = myinjection<MemberRegistrationCubit>();
    _loadInitialData();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _postalCodeController.dispose();
    _contactPersonController.dispose();
    _emailCompanyController.dispose();
    _faxController.dispose();
    _factoryAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Get user data
    final authState = context.read<AuthSessionCubit>().state;
    if (authState is AuthSessionAuthenticated) {
      _userId = authState.user.id;
      _userEmail = authState.user.email;
    }

    // Load approved GCIDs for this user
    final approvedGCIDs = await _storageService.getApprovedGCIDsByUserId(
      _userId,
    );

    // Load branches and provinces
    _memberCubit.loadBranches();
    _memberCubit.loadProvinces();

    setState(() {
      _approvedGCIDs = approvedGCIDs;
      _isLoading = false;
    });
  }

  void _onGCIDSelected(Map<String, dynamic>? gcid) {
    if (gcid == null) return;

    setState(() {
      _selectedGCID = gcid;
      // No need to pre-fill anything, just store the selection
    });
  }

  void _onProvinceSelected(ProvinceModel? province) {
    if (province == null) return;

    setState(() {
      _selectedProvince = province;
      _selectedRegency = null;
      _selectedDistrict = null;
      _selectedVillage = null;
      _regencies = [];
      _districts = [];
      _villages = [];
    });

    _memberCubit.loadRegencies(province.code);
  }

  void _onRegencySelected(RegencyModel? regency) {
    if (regency == null) return;

    setState(() {
      _selectedRegency = regency;
      _selectedDistrict = null;
      _selectedVillage = null;
      _districts = [];
      _villages = [];
    });

    _memberCubit.loadDistricts(regency.code);
  }

  void _onDistrictSelected(DistrictModel? district) {
    if (district == null) return;

    setState(() {
      _selectedDistrict = district;
      _selectedVillage = null;
      _villages = [];
    });

    _memberCubit.loadVillages(district.code);
  }

  void _onVillageSelected(VillageModel? village) {
    setState(() {
      _selectedVillage = village;
    });
  }

  void _submitBCIDRegistration() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap lengkapi semua field yang wajib diisi',
            style: TextStyle(fontFamily: AppFonts.primaryFont),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedGCID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih perusahaan induk terlebih dahulu',
            style: TextStyle(fontFamily: AppFonts.primaryFont),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    final gcName = _selectedGCID!['gc_name'] ?? _selectedGCID!['company_name'];
    final bcName = _companyNameController.text.trim().toUpperCase();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.account_tree, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text(
              'Konfirmasi Cabang',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan mendaftarkan cabang baru:',
              style: TextStyle(fontFamily: AppFonts.primaryFont, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Perusahaan Induk', gcName),
            _buildInfoRow('Nama Cabang', bcName),
            _buildInfoRow('Cabang', _selectedBranch?.name ?? '-'),
            _buildInfoRow('Alamat', _addressController.text.trim()),
            const SizedBox(height: 12),
            Text(
              'Pengajuan akan masuk ke daftar pending dan menunggu persetujuan admin.',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 12,
                color: AppColors.grayColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: AppColors.grayColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _submitToStorage();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: Text(
              'Ajukan',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 12,
                color: AppColors.grayColor,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitToStorage() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final companyName = _companyNameController.text.trim().toUpperCase();
      final parentGcid = _selectedGCID!['gcid'];
      final gcName =
          _selectedGCID!['gc_name'] ?? _selectedGCID!['company_name'];

      // Generate BC_name with format: "GC_NAME - DAERAH"
      final bcName = _selectedBranch != null
          ? '$gcName - ${_selectedBranch!.daerah.toUpperCase()}'
          : companyName;

      final bcidData = {
        // Registration Metadata
        'member_id': 'MBR_$timestamp',
        'user_id': _userId,
        'status': 'pending',
        'registration_type': 'BCID',

        // GPID (will be same as parent after approval)
        'gpid': _selectedGCID!['gpid'],
        'gp_name': _selectedGCID!['gp_name'],

        // GCID (from parent)
        'gcid': parentGcid,
        'gc_name': gcName,

        // BCID (new branch) - Admin will set proper format: GPID(3)+GCID(3)+BranchID(2)
        'bcid': null, // Will be set by admin (e.g., 00100101)
        'bc_name': bcName,
        'parent_gcid': parentGcid,

        // Identity (from parent GCID)
        'nama': _selectedGCID!['nama'],
        'email': _selectedGCID!['email'],
        'phone': _selectedGCID!['phone'],
        'birthPlace': _selectedGCID!['birthPlace'],
        'dateOfBirth': _selectedGCID!['dateOfBirth'],

        // Company Info (from parent GCID)
        'company_name': companyName,
        'company_type': _selectedGCID!['company_type'],
        'nik': _selectedGCID!['nik'],
        'npwp': _selectedGCID!['npwp'],

        // Branch (user can change)
        'branch_id': _selectedBranch?.id,
        'branch_name': _selectedBranch?.name,
        'branch_daerah': _selectedBranch?.daerah,

        // Address (user can change)
        'address': _addressController.text.trim(),
        'province_code': _selectedProvince?.code,
        'province_name': _selectedProvince?.name,
        'regency_code': _selectedRegency?.code,
        'regency_name': _selectedRegency?.name,
        'district_code': _selectedDistrict?.code,
        'district_name': _selectedDistrict?.name,
        'village_code': _selectedVillage?.code,
        'village_name': _selectedVillage?.name,
        'rt': _rtController.text.trim(),
        'rw': _rwController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),

        // Supporting Data (optional)
        'contact_person': _contactPersonController.text.trim(),
        'factory_address': _factoryAddressController.text.trim(),
        'email_company': _emailCompanyController.text.trim(),
        'fax': _faxController.text.trim(),

        // Audit
        'created_by': _userEmail,
        'created_at': DateTime.now().toIso8601String(),
        'updated_by': _userEmail,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _storageService.saveMemberRegistration(bcidData);

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(Icons.check_circle, color: Colors.green[700], size: 60),
          title: Text(
            'Berhasil!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Pengajuan cabang Anda telah berhasil dikirim dan sedang menunggu persetujuan admin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 13,
              color: AppColors.grayColor,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.goNamed('memberList', extra: {'initialTabIndex': 0});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: Text(
                  'Lihat Daftar Pengajuan',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan pengajuan: $e',
            style: TextStyle(fontFamily: AppFonts.primaryFont),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: const CustomHeaderAppBar(
        title: 'Tambah Cabang',
        subtitle: 'Registrasi Cabang Perusahaan',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BlocProvider.value(
              value: _memberCubit,
              child:
                  BlocConsumer<
                    MemberRegistrationCubit,
                    MemberRegistrationState
                  >(
                    listener: (context, state) {
                      if (state is MemberRegistrationBranchesLoaded) {
                        setState(() => _branches = state.branches);
                      } else if (state is MemberRegistrationProvincesLoaded) {
                        setState(() => _provinces = state.provinces);
                      } else if (state is MemberRegistrationRegenciesLoaded) {
                        setState(() => _regencies = state.regencies);
                      } else if (state is MemberRegistrationDistrictsLoaded) {
                        setState(() => _districts = state.districts);
                      } else if (state is MemberRegistrationVillagesLoaded) {
                        setState(() => _villages = state.villages);
                      }
                    },
                    builder: (context, state) {
                      return _buildForm();
                    },
                  ),
            ),
    );
  }

  Widget _buildForm() {
    if (_approvedGCIDs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.orange[300]),
              const SizedBox(height: 16),
              Text(
                'Tidak Ada Perusahaan Aktif',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda belum memiliki perusahaan yang disetujui. Silakan daftarkan perusahaan utama terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 13,
                  color: AppColors.grayColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.goNamed('memberRegistration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Daftar Perusahaan Baru',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data identitas dan perusahaan diambil dari perusahaan induk. Anda hanya perlu mengisi nama cabang, lokasi, dan alamat.',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Select Parent GCID
            _buildSectionTitle('Perusahaan Induk'),
            const SizedBox(height: 12),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedGCID,
              decoration: InputDecoration(
                labelText: 'Pilih Perusahaan Induk *',
                hintText: 'Pilih perusahaan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _approvedGCIDs.map((gcid) {
                final name = gcid['gc_name'] ?? gcid['company_name'];
                return DropdownMenuItem(
                  value: gcid,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onGCIDSelected,
              validator: (value) {
                if (value == null) return 'Pilih perusahaan induk';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Company Name (Branch Name)
            _buildSectionTitle('Nama Cabang'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _companyNameController,
              decoration: InputDecoration(
                labelText: 'Nama Cabang *',
                hintText: 'Contoh: OLYMPIC ABADI - BOGOR',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama cabang tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Branch Selection
            _buildSectionTitle('Cabang Eka Tunggal'),
            const SizedBox(height: 12),
            DropdownButtonFormField<BranchModel>(
              value: _selectedBranch,
              decoration: InputDecoration(
                labelText: 'Pilih Cabang *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _branches.map((branch) {
                return DropdownMenuItem(
                  value: branch,
                  child: Text(
                    branch.name,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedBranch = value);
              },
              validator: (value) {
                if (value == null) return 'Pilih cabang';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Address Section
            _buildSectionTitle('Alamat Cabang'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Alamat Lengkap *',
                hintText: 'Jalan, Nomor, Komplek',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Alamat tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Province
            DropdownButtonFormField<ProvinceModel>(
              value: _selectedProvince,
              decoration: InputDecoration(
                labelText: 'Provinsi *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _provinces.map((province) {
                return DropdownMenuItem(
                  value: province,
                  child: Text(
                    province.name,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onProvinceSelected,
              validator: (value) {
                if (value == null) return 'Pilih provinsi';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Regency
            DropdownButtonFormField<RegencyModel>(
              value: _selectedRegency,
              decoration: InputDecoration(
                labelText: 'Kota/Kabupaten *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _regencies.map((regency) {
                return DropdownMenuItem(
                  value: regency,
                  child: Text(
                    regency.name,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onRegencySelected,
              validator: (value) {
                if (value == null) return 'Pilih kota/kabupaten';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // District
            DropdownButtonFormField<DistrictModel>(
              value: _selectedDistrict,
              decoration: InputDecoration(
                labelText: 'Kecamatan *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _districts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(
                    district.name,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onDistrictSelected,
              validator: (value) {
                if (value == null) return 'Pilih kecamatan';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Village
            DropdownButtonFormField<VillageModel>(
              value: _selectedVillage,
              decoration: InputDecoration(
                labelText: 'Kelurahan/Desa *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _villages.map((village) {
                return DropdownMenuItem(
                  value: village,
                  child: Text(
                    village.name,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onVillageSelected,
              validator: (value) {
                if (value == null) return 'Pilih kelurahan/desa';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // RT RW
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rtController,
                    decoration: InputDecoration(
                      labelText: 'RT *',
                      hintText: '001',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'RT wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rwController,
                    decoration: InputDecoration(
                      labelText: 'RW *',
                      hintText: '002',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'RW wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Postal Code
            TextFormField(
              controller: _postalCodeController,
              decoration: InputDecoration(
                labelText: 'Kode Pos *',
                hintText: '12345',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.number,
              maxLength: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kode pos tidak boleh kosong';
                }
                if (value.trim().length != 5) {
                  return 'Kode pos harus 5 digit';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Supporting Data (Optional)
            _buildSectionTitle('Data Pendukung (Opsional)'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactPersonController,
              decoration: InputDecoration(
                labelText: 'Contact Person',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _emailCompanyController,
              decoration: InputDecoration(
                labelText: 'Email Cabang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _faxController,
              decoration: InputDecoration(
                labelText: 'Fax',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _factoryAddressController,
              decoration: InputDecoration(
                labelText: 'Alamat Pabrik',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBCIDRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Ajukan Cabang',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.blackColor,
      ),
    );
  }
}
