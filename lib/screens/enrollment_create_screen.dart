import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'karyakarta_dashboard_screen.dart';

/// ============================================================
/// NEW WELFARE SCHEME PROPOSAL FORM
/// Wired to the REAL ApiService (not mock methods):
///   - ApiService().getSchemesRaw()            -> scheme dropdown
///   - ApiService().getMembersRaw()             -> "Existing Member" search
///   - ApiService().calculateSlab(dob, schemeId)-> joining fee / per-event
///   - ApiService().createMemberWithFiles(...)  -> creates a brand-new member
///     (only used when Registration Mode = New Member)
///   - ApiService().createKaryakartaEnrollment(...) -> submits the proposal
///
/// IMPORTANT — field-name assumptions:
/// Your raw member/scheme JSON keys aren't visible to me (member_model.dart /
/// scheme_model.dart weren't shared), so every place that reads a key off
/// a raw Map tries a short list of likely candidates via `_pick()` /
/// `_pickId()`. If a field shows up blank, open member_model.dart /
/// scheme_model.dart (or print one raw record) and add the real key to
/// the candidate list — search for "ADJUST KEYS" below.
/// ============================================================

class EnrollmentCreateScreen extends StatefulWidget {
  final bool isMemberSelfEnroll; // true when opened from Member dashboard
  const EnrollmentCreateScreen({super.key, this.isMemberSelfEnroll = false});

  @override
  State<EnrollmentCreateScreen> createState() => _EnrollmentCreateScreenState();
}

class _EnrollmentCreateScreenState extends State<EnrollmentCreateScreen> {
  // ---------------- Top controls ----------------
  List<Map<String, dynamic>> _schemes = [];
  String? _selectedSchemeId;
  String? _selectedSchemeName;
  bool _loadingSchemes = true;

  // New Member (0) / Existing Member (1)
  int _mode = 0;
  // NEW — Karyakarta search state (replaces the broken locked display)
  final _karyakartaSearchCtrl = TextEditingController();
  List<Map<String, dynamic>> _karyakartaResults = [];
  Map<String, dynamic>? _selectedKaryakarta; // {sa_code, name, mobile, village}
  bool _searchingKaryakarta = false;

  final _existingQueryCtrl = TextEditingController();
  bool _fetchingMember = false;
  bool _memberLocked = false; // true once a member is fetched/created
  int? _memberId; // set after fetching an existing member OR creating a new one

  // ---------------- Section 1: Personal Information ----------------
  final _fullNameCtrl = TextEditingController();
  String? _gotra;
  DateTime? _dob;
  String _gender = 'Female (कन्या / महिला)';
  final _mobileCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();

  static const _genderOptions = [
    'Female (कन्या / महिला)',
    'Male (पुरुष)',
    'Other',
  ];

  // // TODO: swap for ApiService().getGotras() if you want the live master list.
  // static const _gotraOptions = [
  //   'Ambiya',
  //   'Anival',
  //   'Dayama',
  //   'Chauhan',
  //   'Prajapati',
  //   'Rathod',
  //   'Solanki',
  // ];

  // ---------------- Section 2: Family & Nominee Details ----------------
  final _fatherNameCtrl = TextEditingController();
  final _motherNameCtrl = TextEditingController();
  final _guardianNameCtrl = TextEditingController();
  final _nomineeNameCtrl = TextEditingController();
  String _nomineeRelation = 'Father (पिता)';

  static const _nomineeRelationOptions = [
    'Father (पिता)',
    'Mother (माता)',
    'Spouse (पति/पत्नी)',
    'Son (पुत्र)',
    'Daughter (पुत्री)',
    'Guardian (संरक्षक)',
  ];

  // ---------------- Section 3: Contact & Residential Address ----------------
  // These hold the *display name* actually submitted to the backend.
  String? _state;
  String? _district;
  String? _taluka;
  final _villageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  // NEW — dynamic master data loaded from API
  List<Map<String, dynamic>> _gotraList = [];
  bool _loadingGotras = true;

  List<Map<String, dynamic>> _statesList = [];
  String? _selectedStateId;
  bool _loadingStates = true;

  List<Map<String, dynamic>> _districtsList = [];
  String? _selectedDistrictId;
  bool _loadingDistricts = false;

  List<Map<String, dynamic>> _talukasList = [];
  String? _selectedTalukaId;
  bool _loadingTalukas = false;

  // ---------------- Section 4: Documents Upload ----------------
  final Map<String, PlatformFile?> _documents = {
    'Passport Photo': null,
    'Member Govt ID': null,
    'Parent/Guardian ID': null,
    'Auth / Consent Letter': null,
  };

  // ---------------- Calculated summary ----------------
  String _ageGroup = '-';
  double _joiningFee = 0;
  double _perEvent = 0;
  String _paymentMode = 'Cash Handover';
  static const _paymentModes = ['Cash Handover', 'UPI', 'Bank Transfer', 'Cheque'];

  bool _agreed = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isMemberSelfEnroll) {
      // Member self-enroll: always "existing member" flow, never create-new.
      _mode = 1;
    } else {
      // Karyakarta flow: tag is locked to the logged-in SA.
      _selectedKaryakarta = {
        'sa_code': kSaCode,
        'name': kFullName,
        'mobile': kMobile,
        'village': kVillage,
      };
    }
    _loadSchemes();
    _loadGotras();
    _loadStates();
  }

  @override
  void dispose() {
    _existingQueryCtrl.dispose();
    _karyakartaSearchCtrl.dispose(); // NEW
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _aadhaarCtrl.dispose();
    _fatherNameCtrl.dispose();
    _motherNameCtrl.dispose();
    _guardianNameCtrl.dispose();
    _nomineeNameCtrl.dispose();
    _villageCtrl.dispose();
    _addressCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // small helpers for reading unknown raw-JSON key names
  // ============================================================
  String _pick(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return '';
  }

  int? _pickId(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v == null) continue;
      if (v is int) return v;
      final parsed = int.tryParse(v.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  // ============================================================
  // DATA LOADING
  // ============================================================
  Future<void> _loadSchemes() async {
    setState(() => _loadingSchemes = true);
    final schemes = await ApiService().getSchemesRaw();
    setState(() {
      _schemes = schemes;
      if (_schemes.isNotEmpty) {
        // ADJUST KEYS: raw scheme id/name field names.
        // _selectedSchemeId = _pickId(_schemes.first, ['id', 'scheme_id']).toString();
        final firstId = _pickId(_schemes.first, ['id', 'scheme_id']);
        _selectedSchemeId = firstId?.toString();
        _selectedSchemeName = _pick(_schemes.first, ['scheme_name', 'name', 'title']);
      }
      _loadingSchemes = false;
    });
    _recalculateRates();
  }

  Future<void> _fetchExistingMember() async {
    final query = _existingQueryCtrl.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter Member ID, Mobile, or Aadhaar number first.')),
      );
      return;
    }
    setState(() => _fetchingMember = true);
    try {
      final all = await ApiService().getMembersRaw();
      final q = query.toLowerCase();
      // ADJUST KEYS: candidate key names to match on.
      final match = all.cast<Map<String, dynamic>?>().firstWhere(
            (m) {
          if (m == null) return false;
          final id = _pick(m, ['id', 'member_id']).toLowerCase();
          final mobile = _pick(m, ['mobile', 'member_mobile', 'phone']).toLowerCase();
          final aadhaar = _pick(m, ['aadhaar', 'aadhaar_number']).toLowerCase();
          return id == q || mobile == q || aadhaar == q;
        },
        orElse: () => null,
      );

      if (match == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No member found for that ID/Mobile/Aadhaar.')),
          );
        }
        return;
      }

      setState(() {
        _memberId = _pickId(match, ['id', 'member_id']);
        _fullNameCtrl.text = _pick(match, ['name', 'full_name', 'member_name']);
        final g = _pick(match, ['gotra']);
        _gotra = g.isEmpty ? null : g;
        final dobStr = _pick(match, ['dob', 'date_of_birth']);
        _dob = dobStr.isEmpty ? null : DateTime.tryParse(dobStr);
        final genderStr = _pick(match, ['gender']);
        if (genderStr.isNotEmpty) _gender = genderStr;
        _mobileCtrl.text = _pick(match, ['mobile', 'member_mobile', 'phone']);
        _aadhaarCtrl.text = _pick(match, ['aadhaar', 'aadhaar_number']);
        _fatherNameCtrl.text = _pick(match, ['father_name']);
        _motherNameCtrl.text = _pick(match, ['mother_name']);
        _guardianNameCtrl.text = _pick(match, ['guardian_name']);
        _villageCtrl.text = _pick(match, ['village', 'village_city']);
        _addressCtrl.text = _pick(match, ['address', 'full_address']);
        _pinCtrl.text = _pick(match, ['pin_code', 'pincode']);
        _memberLocked = true;
      });
      _onDobChanged(_dob);
      _recalculateRates();
    } finally {
      if (mounted) setState(() => _fetchingMember = false);
    }
  }
  // NEW — Gotra master list
  Future<void> _loadGotras() async {
    setState(() => _loadingGotras = true);
    final list = await ApiService().getGotras();
    setState(() {
      _gotraList = list;
      _loadingGotras = false;
    });
  }

  // NEW — State master list
  Future<void> _loadStates() async {
    setState(() => _loadingStates = true);
    final list = await ApiService().getStates();
    setState(() {
      _statesList = list;
      _loadingStates = false;
    });
  }

  // NEW — Districts for a selected state
  Future<void> _loadDistricts(String stateId) async {
    setState(() {
      _loadingDistricts = true;
      _districtsList = [];
      _selectedDistrictId = null;
      _district = null;
      _talukasList = [];
      _selectedTalukaId = null;
      _taluka = null;
    });
    final list = await ApiService().getDistricts(stateId);
    setState(() {
      _districtsList = list;
      _loadingDistricts = false;
    });
  }

  // NEW — Talukas for a selected district
  Future<void> _loadTalukas(String districtId) async {
    setState(() {
      _loadingTalukas = true;
      _talukasList = [];
      _selectedTalukaId = null;
      _taluka = null;
    });
    final list = await ApiService().getTalukas(districtId);
    setState(() {
      _talukasList = list;
      _loadingTalukas = false;
    });
  }
  // NEW — searches karyakartas by SA Code / Name / Mobile / Village.
// TODO: adjust the field getters below (k.saCode, k.fullName, etc.)
// to match your actual KaryakartaModel property names.
// ============ NEW ============
  Future<void> _searchKaryakarta() async {
    final query = _karyakartaSearchCtrl.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type the SA Code to search (e.g. SA1239).')),
      );
      return;
    }

    setState(() {
      _searchingKaryakarta = true;
      _karyakartaResults = [];
    });
    try {
      // NEW — GET /api/member/search-karyakarta?code=SA1234
      final result = await ApiService().searchKaryakartaByCode(query);

      if (result == null) {
        if (mounted) {
          setState(() => _selectedKaryakarta = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No Karyakarta found for that SA Code.')),
          );
        }
        return;
      }

      final match = {
        'sa_code': _pick(result, ['karyakarta_code', 'sa_code', 'code']),
        'name': _pick(result, ['full_name', 'name']),
        'mobile': _pick(result, ['mobile', 'phone']),
        'village': _pick(result, ['taluka', 'village', 'district']),
      };

      setState(() {
        _karyakartaResults = [match];
        _selectedKaryakarta = match; // auto-select the single exact match
      });
    } finally {
      if (mounted) setState(() => _searchingKaryakarta = false);
    }
  }

  // Future<void> _recalculateRates() async {
  //   if (_selectedSchemeId == null || _dob == null) return;
  //   final schemeId = int.tryParse(_selectedSchemeId!);
  //   if (schemeId == null) return;
  //   try {
  //     final res = await ApiService().calculateSlab(_dob!.toIso8601String(), schemeId);
  //     final data = Map<String, dynamic>.from(res['data'] ?? res);
  //     setState(() {
  //       // ADJUST KEYS if your API returns different field names.
  //       final fee = _pick(data, ['joining_fee']);
  //       final perEvent = _pick(data, ['per_event_installment', 'per_event']);
  //       final ageGroup = _pick(data, ['age_group', 'slab_name']);
  //       if (fee.isNotEmpty) _joiningFee = double.tryParse(fee) ?? _joiningFee;
  //       if (perEvent.isNotEmpty) _perEvent = double.tryParse(perEvent) ?? _perEvent;
  //       if (ageGroup.isNotEmpty) _ageGroup = ageGroup;
  //     });
  //   } catch (_) {
  //     // Non-fatal: keep whatever values were already shown.
  //   }
  // }
  bool _calculatingRates = false; // NEW — add this as a state field near _joiningFee etc.

  Future<void> _recalculateRates() async {
    if (_selectedSchemeId == null || _dob == null) return;
    final schemeId = int.tryParse(_selectedSchemeId!);
    if (schemeId == null) return;

    setState(() => _calculatingRates = true);
    try {
      // FIX: send plain "YYYY-MM-DD", not toIso8601String() (which includes
      // time + milliseconds and fails most backend date validators).
      final dobStr = _formatDob(_dob!);
      final res = await ApiService().calculateSlab(dobStr, schemeId);

      debugPrint('SLAB CALC RESPONSE for dob=$dobStr schemeId=$schemeId => $res'); // TEMP DEBUG

      if (res['success'] == false) {
        // Backend responded but rejected the request — surface it instead of
        // silently leaving fees at 0.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message']?.toString() ?? 'Could not calculate fees for this scheme/DOB.')),
          );
        }
        return;
      }

      final data = Map<String, dynamic>.from(res['data'] ?? res);
      setState(() {
        // ADJUST KEYS if your API returns different field names — check the
        // debugPrint output above to confirm the real key names.
        final fee = _pick(data, ['joining_fee']);
        final perEvent = _pick(data, ['per_event_installment', 'per_event']);
        final ageGroup = _pick(data, ['age_group', 'slab_name']);
        if (fee.isNotEmpty) _joiningFee = double.tryParse(fee) ?? _joiningFee;
        if (perEvent.isNotEmpty) _perEvent = double.tryParse(perEvent) ?? _perEvent;
        if (ageGroup.isNotEmpty) _ageGroup = ageGroup;
      });
    } catch (e) {
      debugPrint('🔴 _recalculateRates error: $e'); // TEMP DEBUG
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to calculate fees: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _calculatingRates = false);
    }
  }

  void _onDobChanged(DateTime? picked) {
    if (picked == null) return;
    setState(() {
      _dob = picked;
      final now = DateTime.now();
      var age = now.year - picked.year;
      if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) {
        age--;
      }
      _ageGroup = age < 18 ? 'Minor (<18)' : (age <= 60 ? 'Adult (18-60)' : 'Senior (60+)');
    });
    _recalculateRates();
  }
  String _formatDob(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ============================================================
  // DOCUMENT PICKING (real file_picker — already in your pubspec)
  // ============================================================
  Future<void> _pickDocument(String key) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _documents[key] = result.files.single);
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================
  static const Map<String, String> _paymentModeApiValues = {
    'Cash Handover': 'cash',
    'UPI': 'upi',
    'Bank Transfer': 'bank_transfer',
    'Cheque': 'cheque',
  };

  Future<void> _submit() async {
    if (_selectedSchemeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a welfare scheme.')),
      );
      return;
    }
    if (_fullNameCtrl.text.trim().isEmpty ||
        _gotra == null ||
        _dob == null ||
        _mobileCtrl.text.trim().length != 10 ||
        _aadhaarCtrl.text.trim().length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields in Personal Information.')),
      );
      return;
    }
    if (_fatherNameCtrl.text.trim().isEmpty ||
        _motherNameCtrl.text.trim().isEmpty ||
        _nomineeNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete Family & Nominee Details.')),
      );
      return;
    }
    if (_state == null ||
        _district == null ||
        _taluka == null ||
        _villageCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty ||
        _pinCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the Contact & Residential Address (select State/District/Taluka).')),
      );
      return;
    }
    // if (!_agreed) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please agree to the Trust rules and welfare terms.')),
    //   );
    //   return;
    // }
    //
    // setState(() => _submitting = true);
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Trust rules and welfare terms.')),
      );
      return;
    }
    // NEW — stop early with a clear message instead of letting the backend
    // reject with a confusing "joining_fee_paid is required" error.
    if (_joiningFee <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joining fee could not be calculated. Please re-select the scheme or date of birth and try again.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      // Step 1: for a brand-new member we have to create the member record
      // first — createKaryakartaEnrollment() requires an existing memberId.
      if (_mode == 0 && _memberId == null) {
        // ADJUST KEYS: match exactly what member_registration_screen.dart
        // sends to createMember()/createMemberWithFiles() for these fields.
        final memberPayload = {
          'full_name': _fullNameCtrl.text.trim(),
          'gotra': _gotra,
          'dob': _dob != null
              ? '${_dob!.year.toString().padLeft(4, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}'
              : null, // date-only, matches member_registration_screen.dart's format
          'gender': _gender,
          'mobile': _mobileCtrl.text.trim(),
          'aadhaar_no': _aadhaarCtrl.text.trim(),        // FIXED — was 'aadhaar_number'
          'father_name': _fatherNameCtrl.text.trim(),
          'mother_name': _motherNameCtrl.text.trim(),
          'guardian_name': _guardianNameCtrl.text.trim(),
          'nominee_name': _nomineeNameCtrl.text.trim(),
          'nominee_relation': _nomineeRelation,
          'state': _state,
          'district': _district,
          'taluka': _taluka,
          'village': _villageCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'pincode': _pinCtrl.text.trim(),               // FIXED — was 'pin_code'
        };

        // final createRes = await ApiService().createMemberWithFiles(
        //   memberPayload,
        //   passportPhoto: _documents['Passport Photo'],
        //   govtIdProof: _documents['Member Govt ID'],
        //   authConsentLetter: _documents['Auth / Consent Letter'],
        // );
        final createRes = await ApiService().createKaryakartaMemberWithFiles(
          memberPayload,
          passportPhoto: _documents['Passport Photo'],
          govtIdProof: _documents['Member Govt ID'],
          authConsentLetter: _documents['Auth / Consent Letter'],
        );

        if (createRes['success'] != true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(createRes['message']?.toString() ?? 'Failed to create member.')),
            );
          }
          return;
        }

        final createdData = Map<String, dynamic>.from(createRes['data'] ?? createRes);
        _memberId = _pickId(createdData, ['id', 'member_id']);
        if (_memberId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Member was created but no ID was returned — check createMember response shape.')),
            );
          }
          return;
        }
      }

      if (_memberId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fetch an existing member before submitting.')),
        );
        return;
      }

      final schemeId = int.tryParse(_selectedSchemeId!) ?? 0;
      // final result = await ApiService().createKaryakartaEnrollment(
      //   memberId: _memberId!,
      //   schemeId: schemeId,
      //   joiningFeePaid: _joiningFee,
      //   // paymentMode: _paymentMode,
      //   paymentMode: _paymentModeApiValues[_paymentMode] ?? _paymentMode.toLowerCase(),
      //   nomineeName: _nomineeNameCtrl.text.trim(), // NEW — fixes "Field 'nominee_name' is required"
      //   nomineeRelation: _nomineeRelation, // NEW — sent alongside, drop this line if backend rejects it
      //   fatherDocFile: _documents['Parent/Guardian ID'],
      //   authFile: _documents['Auth / Consent Letter'],
      //   docFile: _documents['Member Govt ID'],
      //   photoFile: _documents['Passport Photo'],
      // );
      final result = widget.isMemberSelfEnroll
          ? await ApiService().submitMemberEnrollment(
        {
          'scheme_id': schemeId,
          'joining_fee_paid': _joiningFee,
          'payment_mode': _paymentModeApiValues[_paymentMode] ?? _paymentMode.toLowerCase(),
          'nominee_name': _nomineeNameCtrl.text.trim(),
          'nominee_relation': _nomineeRelation,
          if (_selectedKaryakarta != null) 'karyakarta_code': _selectedKaryakarta!['sa_code'],
        },
        fatherDocFile: _documents['Parent/Guardian ID'],
        authFile: _documents['Auth / Consent Letter'],
        docFile: _documents['Member Govt ID'],
        photoFile: _documents['Passport Photo'],
      )
          : await ApiService().createKaryakartaEnrollment(
        memberId: _memberId!,
        schemeId: schemeId,
        joiningFeePaid: _joiningFee,
        paymentMode: _paymentModeApiValues[_paymentMode] ?? _paymentMode.toLowerCase(),
        nomineeName: _nomineeNameCtrl.text.trim(),
        nomineeRelation: _nomineeRelation,
        fatherDocFile: _documents['Parent/Guardian ID'],
        authFile: _documents['Auth / Consent Letter'],
        docFile: _documents['Member Govt ID'],
        photoFile: _documents['Passport Photo'],
      );

      if (!mounted) return;
      final success = result['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? (success ? 'Proposal submitted.' : 'Submission failed.'))),
      );
      if (success) {
        Navigator.of(context).pop(true); // tells the list screen to refresh
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.bg,
      appBar: AppBar(
        backgroundColor: KColors.navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Welfare Scheme Proposal Form',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              _selectedSchemeName == null || _selectedSchemeName!.isEmpty
                  ? 'Registers proposal under selected scheme rules.'
                  : 'Scheme: $_selectedSchemeName',
              style: const TextStyle(fontSize: 11, color: Color(0xFFB9B3E0)),
            ),
          ],
        ),
      ),
      body: _loadingSchemes
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildTopSelectorCard(),
          _buildPersonalInfoCard(),
          _buildFamilyNomineeCard(),
          _buildAddressCard(),
          _buildDocumentsCard(),
          _buildSummaryCard(),
          _buildAgreeAndActions(),
        ],
      ),
    );
  }

  // ---- Top: Scheme + SA Code + Registration Mode ----
  Widget _buildTopSelectorCard() {
    return card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Welfare Scheme *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedSchemeId,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: KColors.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            items: _schemes.map((s) {
              final id = _pickId(s, ['id', 'scheme_id']).toString();
              final name = _pick(s, ['scheme_name', 'name', 'title']);
              return DropdownMenuItem<String>(value: id, child: Text(name));
            }).toList(),
            onChanged: (v) {
              final scheme = _schemes.firstWhere(
                    (s) => _pickId(s, ['id', 'scheme_id']).toString() == v,
                orElse: () => {},
              );
              setState(() {
                _selectedSchemeId = v;
                _selectedSchemeName = _pick(scheme, ['scheme_name', 'name', 'title']);
              });
              _recalculateRates();
            },
          ),
          const SizedBox(height: 16),
          // ============ NEW ============
        const Text('Tagged Karyakarta (SA Code)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
          if (!widget.isMemberSelfEnroll)
            _buildLockedKaryakartaBox()
          else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _karyakartaSearchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Type SA Code (e.g. SA4281), Name or Village...',
                    filled: true,
                    fillColor: KColors.bg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _searchingKaryakarta ? null : _searchKaryakarta,
                icon: _searchingKaryakarta
                    ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.search, size: 16),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          // if (_karyakartaResults.isNotEmpty) ...[
          //   const SizedBox(height: 8),
          //   ..._karyakartaResults.map((k) {
          //     final selected = _selectedKaryakarta != null &&
          //         _selectedKaryakarta!['sa_code'] == k['sa_code'];
          //     return InkWell(
          //       onTap: () => setState(() => _selectedKaryakarta = k),
          //       child: Container(
          //         margin: const EdgeInsets.only(bottom: 6),
          //         padding: const EdgeInsets.all(10),
          //         decoration: BoxDecoration(
          //           color: selected ? KColors.primary.withOpacity(.08) : KColors.bg,
          //           borderRadius: BorderRadius.circular(10),
          //           border: Border.all(color: selected ? KColors.primary : Colors.grey.shade300),
          //         ),
          //         child: Row(
          //           children: [
          //             Expanded(
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text('${k['sa_code']} - ${k['name']}',
          //                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
          //                   Text('${k['village']}${k['mobile'].toString().isNotEmpty ? ' • ${k['mobile']}' : ''}',
          //                       style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          //                 ],
          //               ),
          //             ),
          //             if (selected) const Icon(Icons.check_circle, color: KColors.primary, size: 18),
          //           ],
          //         ),
          //       ),
          //     );
          //   }),
          // ],
            // Search-result list card intentionally hidden — the
            // "ASSIGNED SOCIAL ACTIVIST" box below already shows the
            // same info once _searchKaryakarta() auto-selects the match.
            // if (_karyakartaResults.isNotEmpty) ...[
            //   ... (kept commented out, not deleted, in case needed later)
            // ],
          const SizedBox(height: 8),
          if (_selectedKaryakarta != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: KColors.bg, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ASSIGNED SOCIAL ACTIVIST',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${_selectedKaryakarta!['sa_code']} - ${_selectedKaryakarta!['name']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${_selectedKaryakarta!['village']} | Mob: ${_selectedKaryakarta!['mobile']}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration:
                    BoxDecoration(color: KColors.green.withOpacity(.12), borderRadius: BorderRadius.circular(8)),
                    child: const Text('SELECTED',
                        style: TextStyle(fontSize: 11, color: KColors.green, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: KColors.bg, borderRadius: BorderRadius.circular(10)),
              child: Text('No Karyakarta selected yet — search above and tap a result.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ),
        ], // end of else (member self-enroll search UI)
          if (!widget.isMemberSelfEnroll) ...[
          const SizedBox(height: 16),
          const Text('Member Registration Mode',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(color: KColors.bg, borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(child: _modeSegment('New Member', 0)),
                Expanded(child: _modeSegment('Existing Member', 1)),
              ],
            ),
          ),
    ],
        ],
      ),
    );
  }

  // Widget _modeSegment(String label, int index) {
  //   final selected = _mode == index;
  // Locked "Tagged Karyakarta" box (logged-in SA, not editable)
  Widget _buildLockedKaryakartaBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KColors.primary.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$kSaCode – $kFullName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (kVillage.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(kVillage,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ],
            ),
          ),
          const Icon(Icons.lock, size: 15, color: Color(0xFF3B2FB5)),
          const SizedBox(width: 4),
          const Text('Locked',
              style: TextStyle(
                  color: Color(0xFF3B2FB5), fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _modeSegment(String label, int index) {
    final selected = _mode == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = index;
          if (_mode == 0) {
            // Switching to New Member clears any fetched/locked record.
            _memberLocked = false;
            _memberId = null;
            _existingQueryCtrl.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? KColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ---- Existing Member search bar (only shown when _mode == 1) ----
  Widget _buildExistingMemberSearchCard() {
    return card(
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _existingQueryCtrl,
              decoration: InputDecoration(
                hintText: 'Type 7-Digit Member ID, Mobile, or Aadhaar number...',
                filled: true,
                fillColor: KColors.bg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _fetchingMember ? null : _fetchExistingMember,
            icon: _fetchingMember
                ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.search, size: 16),
            label: const Text('Fetch Member Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: KColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Section 1: Personal Information ----
  Widget _buildPersonalInfoCard() {
    return card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('1', 'PERSONAL INFORMATION'),
          const SizedBox(height: 12),
          _labeledField(
            'Member Full Name (as per documents) *',
            TextField(
              controller: _fullNameCtrl,
              enabled: !_memberLocked,
              decoration: _fieldDecoration('Member Full Name'),
            ),
          ),
          const SizedBox(height: 12),
          _labeledField(
            'Gotra *',
            DropdownButtonFormField<String>(
              value: _gotra,
              isExpanded: true,
              decoration: _fieldDecoration(_loadingGotras ? 'Loading Gotras...' : 'Select Gotra'),
              items: _gotraList.map((g) {
                // Backend returns gotra_en / gotra_hi (confirmed from API response).
                final nameEn = _pick(g, ['gotra_en', 'name_en', 'name', 'gotra_name']);
                final nameHi = _pick(g, ['gotra_hi', 'name_hi']);
                final label = nameEn.isNotEmpty ? nameEn : (nameHi.isNotEmpty ? nameHi : '-');
                final value = nameEn.isNotEmpty ? nameEn : label;
                return DropdownMenuItem<String>(value: value, child: Text(label));
              }).toList(),
              onChanged: (_memberLocked || _loadingGotras) ? null : (v) => setState(() => _gotra = v),
            ),
          ),
          const SizedBox(height: 12),
          _labeledField(
            'Date of Birth *',
            InkWell(
              onTap: _memberLocked
                  ? null
                  : () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000, 1, 1),
                  firstDate: DateTime(1930),
                  lastDate: DateTime.now(),
                );
                _onDobChanged(picked);
              },
              child: InputDecorator(
                decoration: _fieldDecoration('dd-mm-yyyy').copyWith(
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
                ),
                child: Text(
                  _dob == null
                      ? 'dd-mm-yyyy'
                      : '${_dob!.day.toString().padLeft(2, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.year}',
                  style: TextStyle(color: _dob == null ? Colors.grey.shade500 : Colors.black87),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  'Gender *',
                  DropdownButtonFormField<String>(
                    value: _gender,
                    isExpanded: true,
                    decoration: _fieldDecoration(''),
                    items: _genderOptions
                        .map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 12.5))))
                        .toList(),
                    onChanged: _memberLocked ? null : (v) => setState(() => _gender = v ?? _gender),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _labeledField(
                  'Age at Enrollment',
                  InputDecorator(
                    decoration: _fieldDecoration('Auto Calculated'),
                    child: Text(_ageGroup, style: const TextStyle(fontSize: 12.5)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  'Mobile Number (Exact 10 Digits) *',
                  TextField(
                    controller: _mobileCtrl,
                    enabled: !_memberLocked,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: _fieldDecoration('10-Digit Mobile').copyWith(counterText: ''),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _labeledField(
                  'Aadhaar Number (12 Digits) *',
                  TextField(
                    controller: _aadhaarCtrl,
                    enabled: !_memberLocked,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    decoration: _fieldDecoration('12-Digit Number').copyWith(counterText: ''),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Section 2: Family & Nominee Details ----
  Widget _buildFamilyNomineeCard() {
    return card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('2', 'FAMILY & NOMINEE DETAILS'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  'Father Name *',
                  TextField(controller: _fatherNameCtrl, decoration: _fieldDecoration('Father Name')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _labeledField(
                  'Mother Name *',
                  TextField(controller: _motherNameCtrl, decoration: _fieldDecoration('Mother Name')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _labeledField(
            'Guardian Name',
            TextField(controller: _guardianNameCtrl, decoration: _fieldDecoration('Guardian Name')),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  'Nominee Full Name *',
                  TextField(controller: _nomineeNameCtrl, decoration: _fieldDecoration('Nominee Full Name')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _labeledField(
                  'Nominee Relation *',
                  DropdownButtonFormField<String>(
                    value: _nomineeRelation,
                    isExpanded: true,
                    decoration: _fieldDecoration(''),
                    items: _nomineeRelationOptions
                        .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12.5))))
                        .toList(),
                    onChanged: (v) => setState(() => _nomineeRelation = v ?? _nomineeRelation),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Section 3: Contact & Residential Address ----
  Widget _buildAddressCard() {
    return card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('3', 'CONTACT & RESIDENTIAL ADDRESS (LOCATION MASTER)'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  'State *',
                  DropdownButtonFormField<String>(
                    value: _selectedStateId,
                    isExpanded: true,
                    decoration: _fieldDecoration(_loadingStates ? 'Loading...' : 'Select State'),
                    items: _statesList.map((s) {
                      final id = _pickId(s, ['id', 'state_id'])?.toString() ?? '';
                      final name = _pick(s, ['name', 'state_name']);
                      return DropdownMenuItem<String>(value: id, child: Text(name, style: const TextStyle(fontSize: 12.5)));
                    }).toList(),
                    onChanged: _loadingStates
                        ? null
                        : (v) {
                      if (v == null) return;
                      final match = _statesList.firstWhere(
                            (s) => (_pickId(s, ['id', 'state_id'])?.toString() ?? '') == v,
                        orElse: () => {},
                      );
                      setState(() {
                        _selectedStateId = v;
                        _state = _pick(match, ['name', 'state_name']);
                      });
                      _loadDistricts(v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _labeledField(
                  'District *',
                  DropdownButtonFormField<String>(
                    value: _selectedDistrictId,
                    isExpanded: true,
                    decoration: _fieldDecoration(
                      _selectedStateId == null
                          ? 'Select State first'
                          : (_loadingDistricts ? 'Loading...' : 'Select District'),
                    ),
                    items: _districtsList.map((d) {
                      final id = _pickId(d, ['id', 'district_id'])?.toString() ?? '';
                      final name = _pick(d, ['name', 'district_name']);
                      return DropdownMenuItem<String>(value: id, child: Text(name, style: const TextStyle(fontSize: 12.5)));
                    }).toList(),
                    onChanged: (_selectedStateId == null || _loadingDistricts)
                        ? null
                        : (v) {
                      if (v == null) return;
                      final match = _districtsList.firstWhere(
                            (d) => (_pickId(d, ['id', 'district_id'])?.toString() ?? '') == v,
                        orElse: () => {},
                      );
                      setState(() {
                        _selectedDistrictId = v;
                        _district = _pick(match, ['name', 'district_name']);
                      });
                      _loadTalukas(v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  'Taluka / Tehsil *',
                  DropdownButtonFormField<String>(
                    value: _selectedTalukaId,
                    isExpanded: true,
                    decoration: _fieldDecoration(
                      _selectedDistrictId == null
                          ? 'Select District first'
                          : (_loadingTalukas ? 'Loading...' : 'Select Taluka'),
                    ),
                    items: _talukasList.map((t) {
                      final id = _pickId(t, ['id', 'taluka_id'])?.toString() ?? '';
                      final name = _pick(t, ['name', 'taluka_name']);
                      return DropdownMenuItem<String>(value: id, child: Text(name, style: const TextStyle(fontSize: 12.5)));
                    }).toList(),
                    onChanged: (_selectedDistrictId == null || _loadingTalukas)
                        ? null
                        : (v) {
                      if (v == null) return;
                      final match = _talukasList.firstWhere(
                            (t) => (_pickId(t, ['id', 'taluka_id'])?.toString() ?? '') == v,
                        orElse: () => {},
                      );
                      setState(() {
                        _selectedTalukaId = v;
                        _taluka = _pick(match, ['name', 'taluka_name']);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _labeledField(
                  'Village / City *',
                  TextField(controller: _villageCtrl, decoration: _fieldDecoration('Village Name')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _labeledField(
            'Full Residential Address *',
            TextField(controller: _addressCtrl, decoration: _fieldDecoration('Complete Residential Address')),
          ),
          const SizedBox(height: 12),
          _labeledField(
            'PIN Code *',
            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: _fieldDecoration('PIN Code').copyWith(counterText: ''),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Section 4: Documents Upload ----
  Widget _buildDocumentsCard() {
    return card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('4', 'DOCUMENTS UPLOAD (PHOTO & PROOFS)'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _documents.keys.map((label) {
              return SizedBox(
                width: 150,
                child: _labeledField(
                  label,
                  OutlinedButton.icon(
                    onPressed: () => _pickDocument(label),
                    icon: const Icon(Icons.upload_file, size: 15),
                    label: Text(
                      _documents[label]?.name ?? 'Choose File',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Calculated summary strip ----
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KColors.green.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KColors.green.withValues(alpha: .25)),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: [
          // _summaryItem('CALCULATED AGE GROUP', _ageGroup),
          // _summaryItem('JOINING FEE (PAYABLE ONCE)', '₹${_joiningFee.toStringAsFixed(0)}.00'),
          // _summaryItem('PER-EVENT CONTRIBUTION', '₹${_perEvent.toStringAsFixed(0)}.00', valueColor: KColors.primary),
          _summaryItem('CALCULATED AGE GROUP', _ageGroup),
          _summaryItem(
            'JOINING FEE (PAYABLE ONCE)',
            _calculatingRates ? 'Calculating…' : '₹${_joiningFee.toStringAsFixed(0)}.00',
          ),
          _summaryItem(
            'PER-EVENT CONTRIBUTION',
            _calculatingRates ? 'Calculating…' : '₹${_perEvent.toStringAsFixed(0)}.00',
            valueColor: KColors.primary,
          ),
          SizedBox(
            width: 160,
            child: _labeledField(
              'Payment Mode',
              DropdownButtonFormField<String>(
                value: _paymentMode,
                isExpanded: true,
                decoration: _fieldDecoration(''),
                items: _paymentModes
                    .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12.5))))
                    .toList(),
                onChanged: (v) => setState(() => _paymentMode = v ?? _paymentMode),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  // ---- Agree checkbox + Cancel/Submit ----
  Widget _buildAgreeAndActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                activeColor: KColors.primary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'I agree to all Trust rules, waiting periods and community welfare terms & conditions.',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Submit Proposal to Office', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- shared small helpers ----
  Widget _sectionLabel(String number, String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth < 360 ? 11.5 : 13.0;

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: KColors.primary.withValues(alpha: .12), shape: BoxShape.circle),
          child: Text(number, style: const TextStyle(color: KColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize, color: KColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _labeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
          const SizedBox(height: 6),
        ],
        field,
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
      filled: true,
      fillColor: KColors.bg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}